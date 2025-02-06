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
            column(Original; Original)
            {

            }
            column(NewValue; NewValue)
            {

            }
            column(OldValue; OldValue)
            {

            }
            trigger OnAfterGetRecord()
            var
                funderLedgEntry: Record FunderLedgerEntry;
            begin
                FunderLoan.Reset();
                FunderLoan.SetFilter(Currency, '<>%1', '');
                if FunderLoan.Find('-') then begin
                    repeat
                        funderLedgEntry.Reset();
                        funderLedgEntry.SetRange("Loan No.", FunderLoan."No.");
                        // if not funderLedgEntry.Find('-') then
                        //     CurrReport.Skip();
                        // Error('No Funder Ledger Entry For %1', FunderLoan."No.");
                        if funderLedgEntry.Find('-') then begin
                            OldValue := funderLedgEntry."Amount(LCY)";
                            NewValue := FunderMgt.ConvertCurrencyAmount(FunderLoan.Currency, funderLedgEntry.Amount);
                            Difference := NewValue - OldValue;
                            Original := funderLedgEntry.Amount;
                        end;
                    until FunderLoan.Next() = 0;


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
    //                 field(Name; SourceExpression)
    //                 {

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
        FunderMgt: Codeunit FunderMgtCU;

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