# Contracts: AVD Dev Environment

## Scope
This directory defines the parameter contract for the Azure Virtual Desktop developer environment feature. It ensures consistency across deployments and acts as a reference for validation and potential automation.

## Files
- `parameters.schema.json`: JSON Schema describing required and optional parameters for Bicep template deployment.

## Usage
Validation (example using `ajv` via Node.js or tooling of choice):
```bash
npx ajv validate -s specs/001-avd-dev-vscode/contracts/parameters.schema.json -d deployment-params.json
```

## Extensions (Future)
- Add output schema (planned if multiple consuming systems)
- Add contract test harness executing `az deployment what-if` using schema-validated params
