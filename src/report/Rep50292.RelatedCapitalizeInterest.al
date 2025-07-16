report 50292 "Related Capitalize Interest"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    // DefaultRenderingLayout = LayoutName;
    ProcessingOnly = true;

    dataset
    {
        dataitem(RelatedLoan; "RelatedParty Loan")
        {
            // column(No_;"No.")
            // {

            // }
            trigger OnPreDataItem()
            begin

                DocNo := TrsyMgt.GenerateDocumentNumber();
                TODAY_Date := Today;
                GenSetup.Get(0);

                RelatedLoan.SetFilter("Original Disbursed Amount", '<>%1', 0);
            end;

            trigger OnAfterGetRecord()
            var
            begin
                //***************** CHECK PERIOD FOR RUNNNING *****************

                // is TODAY_Date End Month/End Quarter/ End Biannual / End Year ?
                if ((RelatedLoan.PeriodicPaymentOfInterest = RelatedLoan.PeriodicPaymentOfInterest::Monthly) and (RelatedLoan.Status = RelatedLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfMonth()
                        CapitalizeMethod(RelatedLoan."No.");
                end;
                if ((RelatedLoan.PeriodicPaymentOfInterest = RelatedLoan.PeriodicPaymentOfInterest::Quarterly) and (RelatedLoan.Status = RelatedLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfQuarter()
                        CapitalizeMethod(RelatedLoan."No.");
                end;
                if ((RelatedLoan.PeriodicPaymentOfInterest = RelatedLoan.PeriodicPaymentOfInterest::Biannually) and (RelatedLoan.Status = RelatedLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfBiAnnual()
                        CapitalizeMethod(RelatedLoan."No.");
                end;
                if ((RelatedLoan.PeriodicPaymentOfInterest = RelatedLoan.PeriodicPaymentOfInterest::Annually) and (RelatedLoan.Status = RelatedLoan.Status::Approved)) then begin
                    if true then //TrsyMgt.IsTodayEndOfYear()
                        CapitalizeMethod(RelatedLoan."No.");
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
    //                 field(No; RelatedLoanFilter."No.")
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
        TrsyMgt.PostTrsyJnlRelated()
    end;

    local procedure CapitalizeMethod(LoanPK: Code[20])
    var
        relatedLedgEntry: Record RelatedLedgerEntry;
        LoanNo: Code[20];

        j: Integer;
        LastLineNo: Integer;
    begin
        LoanNo := RelatedLoanFilter."No.";
        GenSetup.Get(0);

        j := 1;
        LastLineNo := 1;
        TrsyJnlTbl.Reset();
        if TrsyJnlTbl.FindLast() then
            LastLineNo := TrsyJnlTbl."Line No." + 1;

        // TrsyJnlTbl.DeleteAll();
        // RelatedLoan.Reset();
        // RelatedLoan.SetRange("No.", LoanPK);
        // RelatedLoan.SetFilter("Original Disbursed Amount", '<>%1', 0);

        // if RelatedLoan.Find('-') then begin

        AmountSum := 0; // Total Interest minus the payment.
        relatedLedgEntry.Reset();
        relatedLedgEntry.SetRange("Loan No.", RelatedLoan."No.");
        relatedLedgEntry.SetFilter(relatedLedgEntry."Document Type", '=%1|=%2|=%3|=%4|=%5', relatedLedgEntry."Document Type"::Interest, relatedLedgEntry."Document Type"::"Interest Paid", relatedLedgEntry."Document Type"::"Capitalized Interest", relatedLedgEntry."Document Type"::"Reversed Interest", relatedLedgEntry."Document Type"::Withholding);
        // relatedLedgEntry.SetRange(relatedLedgEntry."Document Type", relatedLedgEntry."Document Type"::Interest);
        if relatedLedgEntry.Find('-') then begin
            repeat
                AmountSum := AmountSum + relatedLedgEntry.Amount;
            until relatedLedgEntry.Next() = 0;
        end;
        //Create the treasury data
        if AmountSum > 0 then begin
            TrsyJnlTbl.Init();
            TrsyJnlTbl."Entry No." := LastLineNo + 1;
            TrsyJnlTbl."Account Type" := TrsyJnlTbl."Account Type"::Relatedparty;
            TrsyJnlTbl."Account No." := RelatedLoan."No.";
            TrsyJnlTbl."Posting Date" := Today;
            TrsyJnlTbl."Document No." := DocNo;
            TrsyJnlTbl.Description := RelatedLoan."No." + ' ' + RelatedLoan.Name + '-' + RelatedLoan."Bank Ref. No." + '-' + Format(RelatedLoan.PlacementDate) + ' ' + Format(RelatedLoan.MaturityDate) + ' ::' + 'Capitalization Interest';
            TrsyJnlTbl."Bal. Account Type" := TrsyJnlTbl."Bal. Account Type"::"Bank Account";
            TrsyJnlTbl."Bal. Account No." := RelatedLoan.FundSource;
            TrsyJnlTbl."Transaction Nature" := TrsyJnlTbl."Transaction Nature"::"Capitalized Interest";
            TrsyJnlTbl."Currency Code" := RelatedLoan.Currency;
            TrsyJnlTbl.Amount := AmountSum;
            TrsyJnlTbl."Shortcut Dimension 1 Code" := GenSetup."Shortcut Dimension 1 Code";
            TrsyJnlTbl.Validate("Shortcut Dimension 1 Code");
            TrsyJnlTbl.Insert();
        end;
        // end;


    end;

    var
        AmountSum: Decimal;
        RelatedLoanFilter: Record "Funder Loan";
        TrsyJnlTbl: Record "Trsy Journal";
        TrsyMgt: Codeunit "Treasury Mgt CU";
        TODAY_Date: Date;
        DocNo: Code[20];
        GenSetup: Record "Treasury General Setup";
}