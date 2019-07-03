BIPWeb Code Sample (Rails)
==========================

This is a sample of code developed by Jack Desert for BIP.

This code generates a PDF document outlining exactly what a particular resident
is charged for in a given month, based on that resident's needs and the care
provided by BIP.

Uses Prawn to write the PDF. See https://github.com/prawnpdf/prawn


Location of Files
-----------------

    SAMPLE FILE                      LOCATION IN FULL RAILS APP

    financial_report_controller.rb   app/controllers/people/
    financial_report_presenter.rb    app/presenters/
    financial_report/                app/models/concerns/


Control Flow
------------

1. A user clicks a "download" button on a page,
   which invokes the People::FinancialReportController

2. The People::FinancialReportController calls the FinancialReportPresenter

3. The FinancialReportPresenter calls each of the sections in financial_report/ directory.



-- Jack Desert


