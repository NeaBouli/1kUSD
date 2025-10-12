# CI Reports — JSON Schema (Concept)
**Status:** Spec (no code). **Language:** EN.

## unit.json
{ "suite":"string","passed":123,"failed":0,"skipped":0,"durationMs":12345,"coverage":{"statements":0.93,"branches":0.86,"functions":0.91} }

## invariants.json
{ "invariants":[{"name":"I1","checks":100000,"violations":0,"maxSteps":1024,"seed":"hex"}] }

## gas.json
{ "methods":[{"name":"PSM.swapTo1kUSD","gas":123456}],"commit":"<sha>" }

## slither.json / mythril.json
{ "tool":"slither","version":"x.y.z","findings":[{"id":"reentrancy-1","severity":"HIGH","contract":"PSM","function":"swapTo1kUSD","location":"file.sol:123","message":"..."}] }

## security-findings.json
{ "summary":{"critical":0,"high":0,"medium":0,"low":0},"findings":[] }
