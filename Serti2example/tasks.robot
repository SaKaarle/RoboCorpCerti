*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library        RPA.HTTP
Library        RPA.Browser.Selenium    auto_close=${FALSE}
Library        RPA.Tables    
Library        Collections
Library        libraries/MyLibrary.py
Library        RPA.Excel.Files
Library        RPA.PDF

Resource        keywords/keywords.robot

*** Variables ***
${CSV_FILE_URL}=    https://robotsparebinindustries.com/orders.csv
${tilausNumero}


*** Tasks ***
OrderRobotsFromRobotSpareBin
    Open the robot order website
    ${robotOrders}=    Get orders
    #Close the annoying modal
    FOR    ${rows}    IN    @{robotOrders}
        Close the annoying modal
        Fill the form    ${rows}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${rows}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${rows}[Order number]
        #Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    # Create a ZIP file of the receipts
    [Teardown]    Close Browser

# Example Task
#     Python Teksti Output
#     Testi keyword
#     Log    ${TODAY}
    
*** Keywords ***

Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    ${CSV_FILE_URL}    overwrite=True
    ${robotOrders}=    Read Table From Csv    orders.csv    dialect=excel    header=True
    Log        ${robotOrders}
    FOR    ${row}    IN    @{robotOrders}
        Log    ${row}
        
    END
    [Return]    ${robotOrders}
    
Close the annoying modal
    #Wait Until Element Is Visible    css:.alert-buttons
    Click Button    css:.btn-danger
Fill the form
    [Arguments]    ${orderRow}
    ${head}=    Convert To Integer    ${orderRow}[Head]
    ${body}=    Convert To Integer    ${orderRow}[Body]
    ${legs}=    Convert To Integer    ${orderRow}[Legs]
    ${address}=    Convert To String     ${orderRow}[Address]
    Select From List By Value    id:head    ${head}
    Click Element    id-body-${body}
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input   ${legs}
    Input Text    id:address    ${address}

Preview the robot
    Click Element    id:preview
    Wait Until Element Is Visible    id:robot-preview


Submit until success
    Click Element    order
    Wait Until Element Is Visible    id:order-completion    timeout=1s
    Wait Until Element Is Visible    xpath://div[@id="receipt"]

Submit the order
    Wait Until Keyword Succeeds    10x    100ms    Submit until success
    # [Arguments]    ${alert-danger}
    # ${old_wait}=    Set Selenium Implicit Wait    5
    # Click Element    id:order-another
    # Set Selenium Implicit Wait    ${old_wait}
    # Wait Until Element Is Visible    div.alert-danger
    # Click Element    order

    
Store the receipt as a PDF file
    [Arguments]    ${tilausNumero}
    Wait Until Element Is Visible    xpath://div[@id="order-completion"]
    ${tilausNumero}    Get Text    xpath://div[@id="receipt"]/p[1]
    ${receipt}=    Get Element Attribute    xpath://div[@id="order-completion"]    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}${tilausNumero}.pdf
    [Return]    ${tilausNumero}
    # Wait Until Element Is Visible        id:order-completion
    # ${receipt}=    Get Element Attribute    id:order-completion    outerHTML
    # Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}sales_results.pdf


Take a screenshot of the robot
    [Arguments]    ${roboScreenshot}
    Capture Element Screenshot    xpath://div[@id="robot-preview"]/div[1]
...  ${OUTPUT_DIR}${/}robotti.png
    [Return]    ${roboScreenshot}

Embed the robot screenshot to the receipt PDF file

Go to order another robot
    # Wait Until Keyword Succeeds    10    1    Submit The Order
    Click Element    id:order-another
    [Return]    OrderRobotsFromRobotSpareBin
    

Create a ZIP file of the receipts


# LoopOrder
#     FOR    ${order}    IN    @{tables}
#         Log    ${order}
        
#     END
