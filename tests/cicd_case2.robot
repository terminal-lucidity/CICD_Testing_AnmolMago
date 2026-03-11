*** Settings ***
Library                 QWeb
Library                 QForce
Library                 String
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Variables ***
${BASE_URL}             https://copadotrial35224378.my.salesforce.com
${STORY_ID}             US-0000048

*** Test Cases ***
Complete CI/CD Metadata Commit Workflow
    [Documentation]    Full workflow for Apex and Profile commits with re-commit validation.
    [Tags]             SF_Login    testgen
    Login To Salesforce
    
    # 1. Select Apex Class using Add Operation
    ClickText      ${STORY_ID}
    ClickText      Commit Changes
    ClickText      Clear date
    Filter Metadata Type    ApexClass
    ClickCheckbox    Select Item 1    on    partial_match=False
    ClickText    Remove selected option

    # 2. Select Profile as Full
    Filter Metadata Type    Profile
    Sleep         10s
    ClickCheckbox    Select Item 12    on    partial_match=False
    ClickText    Show actions    anchor=CRT_UseCse_2
    ClickText    Change Operation
    ClickText    Full
    ClickText    Save

    # 3. Perform Initial Commit
    ClickElement    xpath=//button[contains(@class, 'slds-button') and text()='Commit Changes']     anchor=Cancel
    ClickText    Commit                        partial_match=False  
    Wait For Commit To Finish

    # 4. Verify Metadata Persistence & Logs
    ClickText         User Stories
    ClickText         ${STORY_ID}
    ClickText         Build
    ClickText         (2)
    VerifyText        MyNewRobotClass                   partial_match=False    
    VerifyText        ApexClass
    VerifyText        Profile
    
    Navigate To Story
    ClickText         User Stories
    ClickText         ${STORY_ID}
    ClickText         User Story Commit
    ClickText         Success Details
    ClickText         Logs
    VerifyText        START Initial setup
    ClickText         Close
    
    # 5. Verify No-Change Re-commit
    Navigate To Story
    ClickText         Commit Changes
    ClickText         Previously Committed
    ClickCheckbox     Select Item 1     on                partial_match=False
    ClickCheckbox     Select Item 2     on                partial_match=False
    ClickText         Commit Changes                      anchor=Cancel
    ClickText         Commit                              partial_match=False
    Wait For Commit To Finish
    VerifyText        Completed      anchor=SFDX Commit    timeout=10
    ClickText         Success Details
    VerifyText        Execution Outcome
    VerifyText        No Changes
    ClickText         Close
    
    # 6. Verify Re-create Feature Branch
    Navigate To Story
    ClickText         Commit Changes
    ClickText         Previously Committed
    ClickCheckbox     Select Item 1     on                partial_match=False
    ClickCheckbox     Select Item 2     on                partial_match=False
    ClickText         Commit Changes                      anchor=Cancel
    ClickText         No                                  anchor=Re-create Feature Branch
    ClickText         Commit                              partial_match=False
    Wait For Commit To Finish
    ClickText         Success Details                     partial_match=False
    VerifyText        Execution Outcome                   partial_match=False
    VerifyText        Pushing all changes to feature/${STORY_ID}
    ClickText         Close

*** Keywords ***
Login To Salesforce
    GoTo           ${BASE_URL}
    TypeText       Username          ${S_EMAIL}
    TypeSecret     Password          ${S_PASSWORD}
    ClickText      Log In
    ${otp_code}=   Get OTP    ${org_url}         ${COPADO_MFA_SECRET}
    TypeText       Verification Code            ${otp_code}
    ClickText      Verify
    ClickText      User Stories

Navigate To Story
    ClickText         User Stories
    ClickText         ${STORY_ID}

Filter Metadata Type
    [Arguments]    ${type}
    TypeText      All Types    ${EMPTY}
    PressKey      All Types    {DOWN}
    ClickText     ${type}
    ClickText     Get Changes

Wait For Commit To Finish
    [Documentation]    Reusable loop to monitor Salesforce background jobs.
    FOR    ${i}    IN RANGE    20
        RefreshPage
        ${status}=    IsText    Successful    timeout=5
        IF    ${status} == True
            Log    Commit finished successfully!
            BREAK
        END
        VerifyText    In Progress    timeout=10
        Log           Commit still in progress... attempt ${i+1} of 20
        Sleep         30s
    END

