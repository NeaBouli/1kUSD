pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface ISafetyAutomata {
    function isPaused() external view returns (bool);
    function pause() external;
}

interface IOracleAggregator {
    function getPriceWAD(address asset) external view returns (uint256 priceWAD, uint256 lastUpdated);
}

/**
 * @title GuardianMonitor
 * @notice Deterministische Rule-Checks; triggert SafetyAutomata.pause() bei Verstößen.
 *         Hält keine Funds. Ownership = DAO/Timelock.
 */
contract GuardianMonitor is Ownable, ReentrancyGuard {
    event RuleUpdated(address indexed asset, uint256 maxDeviationBps, uint256 maxStalenessSec, bool enabled);
    event PauseRequested(bytes32 indexed rule, address indexed asset, uint256 observed, uint256 threshold);
    event OracleChecked(address indexed asset, uint256 priceWAD, uint256 lastUpdated);

    struct Rule {
        uint256 maxDeviationBps;   // z.B. 100 = 1%
        uint256 maxStalenessSec;   // z.B. 300 = 5 Minuten
        bool enabled;
    }

    ISafetyAutomata public immutable safety;
    IOracleAggregator public immutable oracle;
    mapping(address => Rule) public rules; // pro Asset

    constructor(address _safety, address _oracle, address _owner) {
        safety = ISafetyAutomata(_safety);
        oracle = IOracleAggregator(_oracle);
        _transferOwnership(_owner);
    }

    function setRule(address asset, uint256 deviationBps, uint256 stalenessSec, bool enabled) external onlyOwner {
        require(deviationBps <= 10_000, "bad deviation");
        rules[asset] = Rule({
            maxDeviationBps: deviationBps,
            maxStalenessSec: stalenessSec,
            enabled: enabled
        });
        emit RuleUpdated(asset, deviationBps, stalenessSec, enabled);
    }

    /// @notice Prüft ein Asset gegen die Regel und pausiert bei Verstoß (falls GUARDIAN-Rechte).
    function checkAndPauseIfNeeded(address asset) external nonReentrant {
        Rule memory r = rules[asset];
        require(r.enabled, "rule disabled");

        (uint256 p, uint256 t) = oracle.getPriceWAD(asset);
        emit OracleChecked(asset, p, t);

        // R2: Staleness
        if (block.timestamp > t && (block.timestamp - t) > r.maxStalenessSec) {
            emit PauseRequested("STALE", asset, block.timestamp - t, r.maxStalenessSec);
            _attemptPause();
            return;
        }

        // R1: Deviation (gegen 1e18)
        uint256 base = 1e18;
        uint256 diff = p > base ? p - base : base - p;
        uint256 diffBps = (diff * 10_000) / base;
        if (diffBps > r.maxDeviationBps) {
            emit PauseRequested("DEVIATION", asset, diffBps, r.maxDeviationBps);
            _attemptPause();
            return;
        }
    }

    function _attemptPause() internal {
        if (!safety.isPaused()) {
            // Erwartung: GuardianMonitor hat GUARDIAN-Rechte im SafetyAutomata
            try safety.pause() { } catch { /* swallow: sunset/role might block */ }
        }
    }
}
