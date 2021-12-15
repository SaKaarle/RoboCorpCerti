*** Settings ***
Documentation     Viikon myyntidata ja exporttaus PDF:ksi.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.PDF

*** Tasks ***
Viikon myyntidata ja exporttaus PDF:ksi
    Open the intranet website
    Log in
    Download the Excel
    Fill Form from Excel n submit
    CollectData
    ExportToPDF
    [Teardown]    LogOutNClose

*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/

Log in
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form
Fill Form from Excel n submit

    Open Workbook    SalesData.xlsx
    ${sales_reps}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${sales_reps}    IN    @{sales_reps}
        Fill and Submit the form for one person    ${sales_reps}
    END

Fill and Submit the form for one person
    [Arguments]    ${sales_rep}
    Input Text  firstname    ${sales_rep}[First Name]
    Input Text    lastname    ${sales_rep}[Last Name]
    Input Text    salesresult    ${sales_rep}[Sales]
    Select From List By Value    salestarget    ${sales_rep}[Sales Target]
    Click Button    Submit    
    # Edellinen tehtävä ilman excelii

    # Input Text    firstname    Max
    # Input Text    lastname    Power
    # Input Text    salesresult    123
    # Select From List By Value    salestarget    20000
    # Click Button    Submit
    
Download the Excel
    Download    https://robotsparebinindustries.com/SalesData.xlsx    overwrite=True
CollectData
    Screenshot    css:div.sales-summary    ${OUTPUT_DIR}${/}sales_summary.png

ExportToPDF
    Wait Until Element Is Visible    id:sales-results
    ${sales_results_html}=    Get Element Attribute    id:sales-results    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}sales_results.pdf

LogOutNClose
    Click Button    Log out
    Close Browser