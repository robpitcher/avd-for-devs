# US2 Image Build Checklist - Review Guide

**User Story**: Administrator builds & updates custom AVD image
**Success Criteria**: SC-002 (Build ≤ 20 min), SC-004 (Repeatable process), SC-006 (Versioned images)

## Pre-Build Checklist

### Environment Setup
- [ ] Azure subscription with Image Builder permissions
- [ ] Resource group created (`rg-avd-dev`)
- [ ] Managed identity with required permissions
- [ ] Network access configured for Image Builder staging

### Template Validation
- [ ] Base image reference correct (`Windows-11`, `win11-22h2-ent-multi-session`)
- [ ] `install-vscode.ps1` script exists in `src/infra/scripts/`
- [ ] Script tested independently (optional pre-validation)
- [ ] Image name includes timestamp for versioning

## Build Process Checklist

### Execution
- [ ] Image Builder template deployed successfully
- [ ] Build job started
- [ ] Build job completed (check Azure Portal or CLI)
- [ ] Build duration recorded: ______ minutes

### Build Logs Review
- [ ] Customization script executed without errors
- [ ] VS Code installed successfully (check logs for "installation completed")
- [ ] Winget package resolution successful
- [ ] No warning messages about missing dependencies
- [ ] Final image generalization completed

### Validation Commands
```powershell
# Check Image Builder template status
Get-AzImageBuilderTemplate -ResourceGroupName rg-avd-dev -Name <template-name>

# View run output
Get-AzImageBuilderTemplateRunOutput -ResourceGroupName rg-avd-dev -ImageTemplateName <template-name>

# Verify managed image
Get-AzImage -ResourceGroupName rg-avd-dev -ImageName <image-name>
```

## Post-Build Validation

### Image Verification
- [ ] Managed image resource created
- [ ] Image tagged with version/timestamp
- [ ] Image ID captured for deployment
- [ ] Image size within expected range (typically 30-50 GB for Windows 11)

### Deployment Test
- [ ] Deploy test session host using new image
- [ ] VM provisions successfully
- [ ] VS Code installed at expected path: `C:\Program Files\Microsoft VS Code\Code.exe`
- [ ] VS Code launches and functions correctly
- [ ] VS Code version recorded: ______

### Update Process
- [ ] Old image retained (versioned naming prevents overwrite)
- [ ] New image reference updated in parameters
- [ ] Session hosts redeployed with new image
- [ ] Users can access new environment

## Troubleshooting

### Common Issues

**Issue**: Build fails at customization step
**Check**:
- Script syntax errors
- Winget availability on base image
- Network connectivity for package download

**Issue**: Build exceeds 20-minute target (SC-002)
**Check**:
- Base image download time (network speed)
- Script optimization opportunities
- Azure region capacity

**Issue**: VS Code not found after build
**Check**:
- Script execution logs
- Install path in script vs RemoteApp path
- User vs machine-wide installation

## Success Criteria Validation

| Criteria | Target | Actual | Pass/Fail |
|----------|--------|--------|-----------|
| SC-002: Build Duration | ≤ 20 min | _____ min | ☐ Pass ☐ Fail |
| SC-004: Repeatable | Documented process | ☐ Yes | ☐ Pass ☐ Fail |
| SC-006: Versioned | Timestamp naming | ☐ Yes | ☐ Pass ☐ Fail |

## Notes

**Build Date**: ______
**Image Version**: ______
**Reviewed By**: ______
