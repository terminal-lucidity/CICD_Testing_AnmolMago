*** Settings ***
Library                 QWeb
Library                 QForce
Library                 String
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Variables ***
${BASE_URL}            https://copadotrial35224378.my.salesforce.com

*** Test Cases ***
TC001: Direct SF Login And MFA Verification
    [Documentation]    Automates direct login to Okta using a base URL and handles Okta Verify MFA push.
    [Tags]             okta_login    testgen
    GoTo           ${BASE_URL}
    TypeText       Username          ${S_EMAIL}
    TypeSecret     Password          ${S_PASSWORD}
    ClickText      Log In

    ${otp_code}=   Get OTP    ${org_url}         ${COPADO_MFA_SECRET}
    TypeText       Verification Code            ${otp_code}
    ClickText      Verify
    ClickText      User Stories
    ClickText      New
    ClickText      User Story                   anchor=Select a record type
    ClickText      Next                         anchor=Select a record type

    ${RANDOM_STR}=  Generate Random String    6    [LETTERS]
    TypeText        Title          ${RANDOM_STR}
    ComboBox         Search Projects...       Trial - Salesforce Source Format
    ComboBox         Search Credentials...    Dev1-SFP
    ClickElement    xpath=//button[normalize-space(.)='Save' and not(contains(., '&'))]
    
    ClickText       User Stories
    VerifyText      ${RANDOM_STR}    timeout=15s
    
TC002: Verify Tab Visibility and Cleanup
    [Documentation]    Explores story tabs and validates deletion functionality.
    [Tags]             cleanup
    # Exploring tabs as required by the assignment
    ClickText       User Story
    ClickText       Build
    ClickText       Test
    ClickText       Deliver
    ClickText       Related
    
    # Deletion Functionality (Cleanup)
    ClickText       Show more actions    anchor=Open Pull Request
    ClickText       Delete
    ClickText       Delete
    
    # Final Visibility check: Ensure it's gone from the list
    ClickText       User Stories
    VerifyNoText    ${RANDOM_STR}    timeout=10s