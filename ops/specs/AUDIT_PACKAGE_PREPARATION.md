
# Audit Package and Reproducible Freeze Preparation

This document outlines the process for preparing a self-contained, reproducible package for external security audits and bug bounty programs. The goal is to provide auditors with a clear, consistent, and verifiable environment to review the codebase.

## 1. Reproducible Environment Setup

To ensure auditors are working with the exact same environment used for development and internal testing, the following steps must be taken.

### 1.1 Pinning Dependencies

*   **Foundry Toolchain:**
    Ensure `foundryup` is used to install a specific, pinned version of the Foundry toolchain. The exact version used must be documented.
    ```bash
    # Example: Pin to a specific nightly or release commit/version
    # foundryup --version <FOUNDRY_COMMIT_HASH_OR_VERSION>
    # Record the output of `forge --version`
    ```
    The exact `forge --version` output should be documented in the `README.md` of the audit package or in a dedicated `VERSION.md` file.

*   **Solidity Compiler:**
    The `solc` version is typically managed by Foundry. Ensure the `foundry.toml` specifies the exact `solc` version.
    ```toml
    # foundry.toml
    solc_version = "0.8.X" # Replace with exact version, e.g., "0.8.20"
    ```

*   **Node.js/NPM (if applicable):**
    If the project uses Node.js for any scripts or Hardhat, ensure `nvm` or a similar tool is used to pin the Node.js version, and `package-lock.json` is up-to-date.

### 1.2 Docker Container (Optional but Recommended)

A `Dockerfile` can be provided to create a fully isolated and reproducible environment.
*   Ensure `docker/Dockerfile.baseline` (or a new `Dockerfile.audit`) contains all necessary system dependencies and the pinned Foundry toolchain.
*   Instructions for building and using this Docker image should be included in the audit package's `README.md`.

## 2. Preparing the Audit Package

The audit package should be a clean, self-contained snapshot of the relevant codebase and documentation.

### 2.1 Repository Cloning and Cleaning

1.  Clone the repository at the specific commit hash designated for the audit.
    ```bash
    git clone <repository_url> audit-package-repo
    cd audit-package-repo
    git checkout <AUDIT_COMMIT_HASH>
    ```
2.  Remove unnecessary files and directories that are not relevant to the audit (e.g., `.git` directory, `archive` directory, large generated files that can be regenerated, CI/CD configurations).
    ```bash
    rm -rf .git archive/generated/cache archive/generated/out .github .vscode
    # ... other cleanups as deemed appropriate for the specific audit
    ```

### 2.2 Documentation

Include comprehensive documentation for auditors:
*   **`README.md`:** Project overview, setup instructions (including how to verify the environment), how to run tests, and key entry points.
*   **`SPECIFICATIONS.md` (or similar):** Detailed protocol specifications, invariant descriptions, and threat models.
*   **`ARCHITECTURE.md`:** Overview of contract interactions and system design.
*   **`SCOPE.md`:** Clearly define the scope of the audit (which contracts, functions, and assumptions are in scope).
*   **`RISK_MITIGATION.md` (optional):** Document known risks and existing mitigation strategies.

### 2.3 Test Suite

Ensure the test suite is comprehensive and easy to run:
*   All relevant `foundry/test` files should be included.
*   Instructions on how to run all tests (`forge test`) and specific test suites should be in the `README.md`.
*   Invariant tests should be clearly documented and easy to execute.

### 2.4 Build and Verification Script

Provide a simple script (e.g., `audit-verify.sh` at the root of the audit package) that:
1.  Prints tool versions (`forge --version`, `solc --version`).
2.  Installs Foundry dependencies (`forge install`).
3.  Compiles all contracts (`forge build`).
4.  Runs all tests (`forge test`).
5.  Optionally generates code coverage reports (`forge coverage`).

This script serves as a quick way for auditors to verify their setup and the project's integrity.

## 3. Bug Bounty Program Considerations

While the bug bounty program itself is external, preparing for it involves similar steps to the audit package, with additional focus on:

*   **Clear Scope:** Define the exact scope of contracts and functionalities in scope for the bounty.
*   **Vulnerability Classification:** Provide a clear classification of vulnerability severity and corresponding rewards.
*   **Disclosure Policy:** Outline the responsible disclosure policy.
*   **Contact Information:** Clear channels for submitting findings.

The audit package serves as the foundational material for bug bounty participants to review.
