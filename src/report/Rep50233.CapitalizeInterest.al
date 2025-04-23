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
            trigger OnPreDataItem()
            begin
                TODAY_Date := Today;
                TrsyJnlTbl.DeleteAll();
            end;

            trigger OnAfterGetRecord()
            var
            begin
                //***************** CHECK PERIOD FOR RUNNNING *****************

                // is TODAY_Date End Month/End Quarter/ End Biannual / End Year ?
                if ((FunderLoan.PeriodicPaymentOfInterest = FunderLoan.PeriodicPaymentOfInterest::Monthly) and (FunderLoan.Status = FunderLoan.Status::Approved)) then begin
                    if TrsyMgt.IsTodayEndOfMonth() then
                        CapitalizeMethod(FunderLoan."No.");
                end;

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

    trigger OnPostReport()
    begin
        // TrsyMgt.PostTrsyJnl()
    end;

    local procedure CapitalizeMethod(LoanPK: Code[20])
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
        TrsyJnlTbl.Reset();
        TrsyJnlTbl.FindLast();
        LastLineNo := TrsyJnlTbl."Line No.";

        // TrsyJnlTbl.DeleteAll();
        FunderLoan.Reset();
        FunderLoan.SetRange("No.", LoanPK);
        FunderLoan.SetFilter("Original Disbursed Amount", '<>%1', 0);

        if FunderLoan.Find('-') then begin

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
                TrsyJnlTbl."Entry No." := LastLineNo + 1;
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
        end;


    end;

    var
        AmountSum: Decimal;
        FunderLoanFilter: Record "Funder Loan";
        TrsyJnlTbl: Record "Trsy Journal";
        TrsyMgt: Codeunit "Treasury Mgt CU";
        TODAY_Date: Date;
}