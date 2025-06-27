report 50232 ReEvaluateFX
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(FunderLoan; "Funder Loan")
        {
            column(Funder_No_; "Funder No.")
            {

            }
            column(Name; Name)
            {

            }
            column("Loan_No"; "No.")
            {

            }
            column(Original; Original)
            {

            }
            column(NewValue; NewValue)
            {

            }
            column(OldValue; OldValue)
            {

            }
            column(Currency; Kurrency)
            {

            }
            column(Difference; Difference)
            {

            }
            trigger OnPreDataItem()
            begin
                DocNo := TrsyMgt.GenerateDocumentNumber();
                FunderLoan.Reset();
                FunderLoan.SetFilter(Currency, '<>%1', '');
                if LoanNo <> '' then
                    FunderLoan.SetFilter("No.", '=%1', LoanNo);

            end;

            trigger OnAfterGetRecord()
            var
                funderLedgEntry: Record FunderLedgerEntry;
                bankAccount: Record "Bank Account";
                bankLedgerEntry: Record "Bank Account Ledger Entry";
                generalLedgerEntry: Record "G/L Entry";
                currency: Record Currency;
                _bankAcc: Code[20];
            begin
                currency.Reset();
                currency.SetFilter(Code, '=%1', FunderLoan.Currency);
                if not currency.Find('-') then
                    Error('Currency %1 not found', FunderLoan.Currency);

                _bankAcc := FunderLoan.FundSource;
                FunderName := FunderLoan.Name;
                bankLedgerEntry.Reset();
                bankLedgerEntry.SetRange("Bank Account No.", _bankAcc);
                bankLedgerEntry.SetRange("External Document No.", FunderLoan."Bank Ref. No.");
                if bankLedgerEntry.Find('+') then begin
                    Original := bankLedgerEntry.Amount;
                    OldValue := bankLedgerEntry."Amount (LCY)";
                    NewValue := FunderMgt.ConvertCurrencyAmount(FunderLoan.Currency, FunderLoan."Original Disbursed Amount", FunderLoan.CustomFX);
                    Difference := Round((NewValue - OldValue), 0.01, '=');
                    Kurrency := FunderLoan.Currency;
                end;
                if Difference < 0 then begin
                    //Loss
                    if FunderLoan.EnableGLPosting = true then
                        FunderMgt.FXGainLossGLPosting('loss', _bankAcc, currency."Realized Gains Acc.", abs(Difference), 'Loss Transaction', FunderLoan.Currency, DocNo, FunderLoan."Bank Ref. No.");
                end;
                if Difference > 0 then begin
                    //Gain
                    if FunderLoan.EnableGLPosting = true then
                        FunderMgt.FXGainLossGLPosting('gain', _bankAcc, currency."Realized Gains Acc.", Difference, 'Loss Transaction', FunderLoan.Currency, DocNo, FunderLoan."Bank Ref. No.");
                end;


                /**funderLedgEntry.Reset();
                funderLedgEntry.SetRange("Loan No.", FunderLoan."No.");
                // if not funderLedgEntry.Find('-') then
                //     CurrReport.Skip();
                // Error('No Funder Ledger Entry For %1', FunderLoan."No.");
                if funderLedgEntry.Find('-') then begin
                    OldValue := funderLedgEntry."Amount(LCY)";
                    NewValue := FunderMgt.ConvertCurrencyAmount(FunderLoan.Currency, funderLedgEntry.Amount, FunderLoan.CustomFX);
                    Difference := NewValue - OldValue;
                    Original := funderLedgEntry.Amount;
                end;*/
                // until FunderLoan.Next() = 0;


                // end;
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
                    field(No; LoanNo)
                    {
                        ApplicationArea = All;
                        TableRelation = "Funder Loan"."No.";
                    }
                }
            }
        }


    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = './reports/FXEval.rdlc';
        }
    }

    var
        OldValue: Decimal;
        NewValue: Decimal;
        Difference: Decimal;
        Original: Decimal;
        Kurrency: Code[20];
        FunderName: Text[500];
        FunderMgt: Codeunit FunderMgtCU;
        DocNo: Code[20];
        TrsyMgt: Codeunit "Treasury Mgt CU";
        LoanNo: Code[20];

    // trigger OnPreReport()
    // var
    //     funderLedgEntry: Record FunderLedgerEntry;
    // begin
    //     FunderLoan.Reset();
    //     FunderLoan.SetFilter(Currency, '<>%1', '');
    //     if FunderLoan.Find('-') then begin
    //         repeat
    //             funderLedgEntry.Reset();
    //             funderLedgEntry.SetRange("Loan No.", FunderLoan."No.");
    //             if not funderLedgEntry.FindFirst() then
    //                 Error('No Funder Ledger Entry For %1', FunderLoan."No.");
    //             OldValue := funderLedgEntry."Amount(LCY)";
    //             NewValue := FunderMgt.ConvertCurrencyAmount(FunderLoan.Currency, funderLedgEntry.Amount);
    //             Difference := NewValue - OldValue;
    //             Original := funderLedgEntry.Amount;
    //         until FunderLoan.Next() = 0;


    //     end;
    // end;
}