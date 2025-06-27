report 50285 "OD Interest Calculation"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    // DefaultRenderingLayout = LayoutName;
    ProcessingOnly = true;

    //Process Closed Tranactions
    dataset
    {
        dataitem("Overdraft Ledger Entries"; "Overdraft Ledger Entries")
        {
            trigger OnPreDataItem()
            begin
                "Overdraft Ledger Entries".SetRange(Closed, true);
                "Overdraft Ledger Entries".SetRange(Processed, false);
                if (PostingStartDate <> 0D) and (PostingEndDate <> 0D) then begin
                    "Overdraft Ledger Entries".SetRange("Posting Date", PostingStartDate, PostingEndDate);
                end;
                if FunderNo <> '' then
                    "Overdraft Ledger Entries".SetRange("Funder No.", FunderNo);
            end;

            trigger OnAfterGetRecord()
            var
                _docNo: Code[20];
                _placementDate: Date;
                _maturityDate: Date;
                _durationDate: Integer;
                _interestRate_Active: Decimal;
                _calculatedInterest: Decimal;
                _openingBalance: Decimal;
                _closingBalance: Decimal;
                _absoluteBalance: Decimal;
                _witHldTaxAmount: Decimal;

                _withholdingAcc: Code[20];
            begin
                LoanTbl.Reset();
                LoanTbl.SetRange("No.", "Overdraft Ledger Entries"."Loan No.");
                if not LoanTbl.Find('-') then
                    Error('Missing Loan %1 during Overdraft interest posting', "Overdraft Ledger Entries"."Loan No.");

                _maturityDate := LoanTbl.MaturityDate;
                _placementDate := LoanTbl.PlacementDate;
                if (_placementDate = 0D) or (_maturityDate = 0D) then
                    CurrReport.Skip();

                _docNo := TrsyMgt.GenerateDocumentNumber();
                FunderTbl.Reset();
                FunderTbl.SetRange("No.", "Funder No.");
                if not FunderTbl.Find('-') then
                    Error('Missing Funder %1 during Overdraft interest posting', "Funder No.");

                GenSetup.Get();
                _withholdingAcc := GenSetup.FunderWithholdingAcc;
                // ***************** Create interest
                _interestRate_Active := TrsyMgt.GetInterestRateSchedule(LoanTbl."No.", Today, 'FUNDER_REPORT');
                _durationDate := (_maturityDate - _placementDate);
                // _absoluteBalance := Abs("Closing Bal." - "Opening Bal.");
                _absoluteBalance := Abs("Closing Bal.");

                if _absoluteBalance <= 0 then
                    CurrReport.Skip();

                if LoanTbl.InterestMethod = LoanTbl.InterestMethod::"30/360" then begin
                    _calculatedInterest := ((_interestRate_Active / 100) * _absoluteBalance) * (30 / 360);
                end else if LoanTbl.InterestMethod = LoanTbl.InterestMethod::"Actual/360" then begin
                    _calculatedInterest := ((_interestRate_Active / 100) * _absoluteBalance) * (_durationDate / 360);
                end else if LoanTbl.InterestMethod = LoanTbl.InterestMethod::"Actual/364" then begin
                    _calculatedInterest := ((_interestRate_Active / 100) * _absoluteBalance) * (_durationDate / 364);
                end else if LoanTbl.InterestMethod = LoanTbl.InterestMethod::"Actual/365" then begin
                    _calculatedInterest := ((_interestRate_Active / 100) * _absoluteBalance) * (_durationDate / 365);
                end
                else if LoanTbl.InterestMethod = LoanTbl.InterestMethod::"30/365" then begin
                    _calculatedInterest := ((_interestRate_Active / 100) * _absoluteBalance) * (30 / 365);
                end;

                _witHldTaxAmount := 0;
                if LoanTbl.TaxStatus = LoanTbl.TaxStatus::Taxable then begin
                    LoanTbl.TestField(Withldtax);
                    _witHldTaxAmount := (LoanTbl.Withldtax / 100) * _calculatedInterest;
                end;
                "Overdraft Ledger Entries"."Calculated Interest" := _calculatedInterest;
                "Overdraft Ledger Entries"."Calculated Witholding Amount" := Abs(_witHldTaxAmount);
                // "Overdraft Ledger Entries".Processed := true;
                "Overdraft Ledger Entries".Modify();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(PostingStartDate; PostingStartDate)
                    {
                        Caption = 'Posting Start Date';
                        ShowMandatory = true;
                        ApplicationArea = All;
                    }
                    field(PostingEndDate; PostingEndDate)
                    {
                        Caption = 'Posting End Date';
                        ShowMandatory = true;
                        ApplicationArea = All;
                    }
                    field(FunderNo; FunderNo)
                    {
                        Caption = 'Funder No.';
                        TableRelation = Funders."No.";
                        ApplicationArea = All;
                    }
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

    trigger OnPreReport()
    begin
        // LoanNo := "Overdraft Ledger Entries".GetFilter("Loan No.");
        /*
        if (PostingStartDate = 0D) then
            Error('Posting Start Date Missing');
        if (PostingEndDate = 0D) then
            Error('Posting End Date Missing');
        */
    end;

    trigger OnPostReport()
    begin
        Message(' Overdraft interest Calculation Done');
    end;

    var
        PostingStartDate: Date;
        PostingEndDate: Date;
        LoanNo: Code[20];
        FunderNo: Code[20];
        OverdraftLedgerEntryTbl: Record "Overdraft Ledger Entries";
        BankAccount: Record "Bank Account";
        FunderTbl: Record Funders;
        LoanTbl: Record "Funder Loan";
        FunderMgt: Codeunit FunderMgtCU;
        TrsyMgt: Codeunit "Treasury Mgt CU";
        GenSetup: Record "Treasury General Setup";
}