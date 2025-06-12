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

                DocNo := TrsyMgt.GenerateDocumentNumber();
                TODAY_Date := Today;
                GenSetup.Get(0);

                FunderLoan.SetFilter("Original Disbursed Amount", '<>%1', 0);
            end;

            trigger OnAfterGetRecord()
            var
            begin
                //***************** CHECK PERIOD FOR RUNNNING *****************

                // is TODAY_Date End Month/End Quarter/ End Biannual / End Year ?
                if ((FunderLoan.PeriodicPaymentOfInterest = FunderLoan.PeriodicPaymentOfInterest::Monthly) and (FunderLoan.Status = FunderLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfMonth()
                        CapitalizeMethod(FunderLoan."No.");
                end;
                if ((FunderLoan.PeriodicPaymentOfInterest = FunderLoan.PeriodicPaymentOfInterest::Quarterly) and (FunderLoan.Status = FunderLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfQuarter()
                        CapitalizeMethod(FunderLoan."No.");
                end;
                if ((FunderLoan.PeriodicPaymentOfInterest = FunderLoan.PeriodicPaymentOfInterest::Biannually) and (FunderLoan.Status = FunderLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfBiAnnual()
                        CapitalizeMethod(FunderLoan."No.");
                end;
                if ((FunderLoan.PeriodicPaymentOfInterest = FunderLoan.PeriodicPaymentOfInterest::Annually) and (FunderLoan.Status = FunderLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfYear()
                        CapitalizeMethod(FunderLoan."No.");
                end;

            end;

        }
    }

    // requestpage
    // {
    //     // AboutTitle = 'Teaching tip title';
    //     // AboutText = 'Teaching tip content';
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(GroupName)
    //             {
    //                 field(No; FunderLoanFilter."No.")
    //                 {
    //                     ApplicationArea = All;
    //                     TableRelation = "Funder Loan"."No.";
    //                 }
    //             }
    //         }
    //     }

    //     actions
    //     {
    //         area(processing)
    //         {
    //             action(LayoutName)
    //             {

    //             }
    //         }
    //     }
    // }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = Excel;
    //         LayoutFile = 'mySpreadsheet.xlsx';
    //     }
    // }
    trigger OnPreReport()
    begin
        TrsyJnlTbl.Reset();
        TrsyJnlTbl.DeleteAll();
    end;

    trigger OnPostReport()
    begin
        TrsyMgt.PostTrsyJnl()
    end;

    local procedure CapitalizeMethod(LoanPK: Code[20])
    var
        funderLedgEntry: Record FunderLedgerEntry;
        LoanNo: Code[20];

        j: Integer;
        LastLineNo: Integer;
    begin
        LoanNo := FunderLoanFilter."No.";
        GenSetup.Get(0);

        j := 1;
        LastLineNo := 1;
        TrsyJnlTbl.Reset();
        if TrsyJnlTbl.FindLast() then
            LastLineNo := TrsyJnlTbl."Line No." + 1;

        // TrsyJnlTbl.DeleteAll();
        // FunderLoan.Reset();
        // FunderLoan.SetRange("No.", LoanPK);
        // FunderLoan.SetFilter("Original Disbursed Amount", '<>%1', 0);

        // if FunderLoan.Find('-') then begin

        AmountSum := 0; // Total Interest minus the payment.
        funderLedgEntry.Reset();
        funderLedgEntry.SetRange("Loan No.", FunderLoan."No.");
        funderLedgEntry.SetFilter(funderLedgEntry."Document Type", '=%1|=%2|=%3|=%4|=%5', funderLedgEntry."Document Type"::Interest, funderLedgEntry."Document Type"::"Interest Paid", funderLedgEntry."Document Type"::"Capitalized Interest", funderLedgEntry."Document Type"::"Reversed Interest", funderLedgEntry."Document Type"::Withholding);
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
            TrsyJnlTbl."Document No." := DocNo;
            TrsyJnlTbl.Description := FunderLoan."No." + ' ' + FunderLoan.Name + '-' + FunderLoan."Bank Ref. No." + '-' + Format(FunderLoan.PlacementDate) + ' ' + Format(FunderLoan.MaturityDate) + ' ::' + 'Capitalization Interest';
            TrsyJnlTbl."Bal. Account Type" := TrsyJnlTbl."Bal. Account Type"::"Bank Account";
            TrsyJnlTbl."Bal. Account No." := FunderLoan.FundSource;
            TrsyJnlTbl."Transaction Nature" := TrsyJnlTbl."Transaction Nature"::"Capitalized Interest";
            TrsyJnlTbl."Currency Code" := FunderLoan.Currency;
            TrsyJnlTbl.Amount := AmountSum;
            TrsyJnlTbl."Shortcut Dimension 1 Code" := GenSetup."Shortcut Dimension 1 Code";
            TrsyJnlTbl.Validate("Shortcut Dimension 1 Code");
            TrsyJnlTbl.Insert();
        end;
        // end;


    end;

    var
        AmountSum: Decimal;
        FunderLoanFilter: Record "Funder Loan";
        TrsyJnlTbl: Record "Trsy Journal";
        TrsyMgt: Codeunit "Treasury Mgt CU";
        TODAY_Date: Date;
        DocNo: Code[20];
        GenSetup: Record "Treasury General Setup";
}