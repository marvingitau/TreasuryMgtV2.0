report 50233 "Capitalize Interest"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    // DefaultRenderingLayout = LayoutName;
    ProcessingOnly = true;

    dataset
    {
        dataitem(FunderLoan; "Funder Loan")
        {
            // column(No_;"No.")
            // {

            // }
            trigger OnAfterGetRecord()
            var
                funderLedgEntry: Record FunderLedgerEntry;
                LoanNo: Code[20];
                _docNo: Code[20];
                j: Integer;
                LastLineNo: Integer;
            begin
                LoanNo := FunderLoanFilter."No.";
                _docNo := TrsyMgt.GenerateDocumentNumber();
                j := 1;
                // TrsyJnlTbl.FindLast();
                // LastLineNo := TrsyJnlTbl."Line No.";

                TrsyJnlTbl.DeleteAll();
                FunderLoan.Reset();
                FunderLoan.SetFilter("No.", '<>%1', '');
                FunderLoan.SetFilter("Original Disbursed Amount", '<>%1', 0);
                if LoanNo <> '' then
                    FunderLoan.SetRange("No.", LoanNo);

                if FunderLoan.Find('-') then begin
                    repeat
                        AmountSum := 0; // Total Interest minus the payment.
                        funderLedgEntry.Reset();
                        funderLedgEntry.SetRange("Loan No.", FunderLoan."No.");
                        funderLedgEntry.SetFilter(funderLedgEntry."Document Type", '=%1|=%2|=%3', funderLedgEntry."Document Type"::Interest, funderLedgEntry."Document Type"::"Interest Paid", funderLedgEntry."Document Type"::"Capitalized Interest");
                        // funderLedgEntry.SetRange(funderLedgEntry."Document Type", funderLedgEntry."Document Type"::Interest);
                        if funderLedgEntry.Find('-') then begin
                            repeat
                                AmountSum := AmountSum + funderLedgEntry.Amount;
                            until funderLedgEntry.Next() = 0;
                        end;
                        //Create the treasury data
                        if AmountSum > 0 then begin
                            TrsyJnlTbl.Init();
                            TrsyJnlTbl."Entry No." := TrsyJnlTbl."Entry No." + j;
                            TrsyJnlTbl."Account Type" := TrsyJnlTbl."Account Type"::Funder;
                            TrsyJnlTbl."Account No." := FunderLoan."No.";
                            TrsyJnlTbl."Posting Date" := Today;
                            TrsyJnlTbl."Document No." := _docNo;
                            TrsyJnlTbl."Bal. Account Type" := TrsyJnlTbl."Bal. Account Type"::"Bank Account";
                            TrsyJnlTbl."Bal. Account No." := FunderLoan.FundSource;
                            TrsyJnlTbl."Transaction Nature" := TrsyJnlTbl."Transaction Nature"::"Capitalized Interest";
                            TrsyJnlTbl."Currency Code" := FunderLoan.Currency;
                            TrsyJnlTbl.Amount := AmountSum;
                            TrsyJnlTbl.Insert();


                        end;
                        j := j + 1;
                    until FunderLoan.Next() = 0;
                end;
                // TrsyMgt.PostCapitalization()
            end;
        }
    }

    requestpage
    {
        // AboutTitle = 'Teaching tip title';
        // AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(No; FunderLoanFilter."No.")
                    {
                        ApplicationArea = All;
                        TableRelation = "Funder Loan"."No.";
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = Excel;
    //         LayoutFile = 'mySpreadsheet.xlsx';
    //     }
    // }

    var
        AmountSum: Decimal;
        FunderLoanFilter: Record "Funder Loan";
        TrsyJnlTbl: Record "Trsy Journal";
        TrsyMgt: Codeunit "Treasury Mgt CU";
}