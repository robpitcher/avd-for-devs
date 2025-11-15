# US1 RemoteApp Validation - Manual Test Plan

**User Story**: Developer launches VS Code RemoteApp
**Success Criteria**: SC-001 (Launch ≤ 60s), SC-003 (Group-based access), SC-005 (Capacity error handling)

## Test Environment Setup

### Prerequisites
- AVD environment deployed successfully
- Entra ID security group created with test user(s) added
- Test user has AVD client installed (Windows/Web)

### Test Accounts
- **Admin Account**: For deployment and configuration verification
- **Test User 1**: Member of assigned Entra ID group
- **Test User 2**: NOT member of assigned group (negative test)

## Test Cases

### TC-001: RemoteApp Visibility (SC-003)

**Objective**: Verify only authorized users can see VS Code RemoteApp

**Steps**:
1. Log in to AVD web client as Test User 1 (in assigned group)
2. Navigate to workspace
3. Verify "Visual Studio Code" RemoteApp appears in available applications
4. Log out

**Expected Result**: RemoteApp is visible and accessible

**Steps (Negative)**:
1. Log in as Test User 2 (NOT in assigned group)
2. Navigate to workspace
3. Verify "Visual Studio Code" RemoteApp does NOT appear

**Expected Result**: RemoteApp is hidden; no unauthorized access

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

### TC-002: RemoteApp Launch Time (SC-001)

**Objective**: Verify VS Code launches within 60 seconds

**Steps**:
1. Log in to AVD client as Test User 1
2. Start timer
3. Click "Visual Studio Code" RemoteApp
4. Stop timer when VS Code window is fully interactive (can type in editor)

**Expected Result**: Launch time ≤ 60 seconds

**Measurement**:
- Launch Time: ______ seconds
- Session Host: ______
- Network Latency: ______ ms (if measurable)

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

### TC-003: Application Functionality

**Objective**: Verify VS Code operates normally as RemoteApp

**Steps**:
1. Launch VS Code RemoteApp (TC-002)
2. Create a new file (`Ctrl+N`)
3. Type sample code (e.g., JavaScript snippet)
4. Save file to user profile location
5. Open file from saved location
6. Install a VS Code extension (e.g., "Prettier")
7. Close and relaunch VS Code
8. Verify extension persists

**Expected Result**: All operations succeed; VS Code functions as expected

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

### TC-004: Concurrent Session Capacity (SC-005)

**Objective**: Verify capacity error when max sessions exceeded

**Prerequisites**:
- Single session host deployed
- `maxSessionsPerHost` parameter known (default: 10)

**Steps**:
1. Launch VS Code sessions from multiple test accounts (up to max sessions)
2. Attempt to launch one additional session beyond capacity
3. Observe error message or queue behavior

**Expected Result**:
- Sessions 1 to max: Successful launches
- Session beyond max: Clear error message or graceful queue/wait message

**Status**: ☐ Pass ☐ Fail
**Actual Max Sessions Before Error**: ______
**Error Message**: ______
**Notes**:

---

### TC-005: Session Persistence

**Objective**: Verify session reconnection after disconnect

**Steps**:
1. Launch VS Code RemoteApp
2. Create unsaved file with content
3. Disconnect session (close client WITHOUT signing out)
4. Wait 30 seconds
5. Reconnect to AVD workspace
6. Verify VS Code session resumes with unsaved file intact

**Expected Result**: Session reconnects; unsaved work preserved

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

## Summary

| Test Case | Status | Notes |
|-----------|--------|-------|
| TC-001 Visibility | ☐ | |
| TC-002 Launch Time | ☐ | |
| TC-003 Functionality | ☐ | |
| TC-004 Capacity | ☐ | |
| TC-005 Persistence | ☐ | |

**Overall Assessment**: ☐ Pass ☐ Fail

**Recommendations**:

**Tested By**: ______
**Date**: ______
