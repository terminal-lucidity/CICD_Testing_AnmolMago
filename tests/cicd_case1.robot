*** Settings ***
Library                 QWeb
Library                 String
Suite Setup             Open Browser    about:blank    chrome    --guest
Suite Teardown          Close All Browsers

*** Variables ***
${BASE_URL}             https://copado.okta.com/    

*** Test Cases ***
Direct Okta Login And MFA Verification
    [Documentation]    Automates direct login to Okta using a base URL and handles Okta Verify MFA push.
    [Tags]             okta_login
    GoTo           ${BASE_URL}
    VerifyText     Sign In
    TypeText       Username          ${C_EMAIL}
    TypeSecret     Password          ${C_PASSWORD}
    ClickText      Sign In
    VerifyText     Okta Verify
    ClickText      Send Push         timeout=60s   
    VerifyText     My Apps           timeout=15s