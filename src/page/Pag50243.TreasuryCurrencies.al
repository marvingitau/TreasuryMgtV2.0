page 50243 "Treasury Currencies"
{
    PageType = List;
    SourceTable = "Treasury Currency";
    ApplicationArea = Suite;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a currency code that you can select. The code must comply with ISO 4217.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a text to describe the currency code.';
                }
                field("ISO Code"; Rec."ISO Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a three-letter currency code defined in ISO 4217.';
                }
                field("ISO Numeric Code"; Rec."ISO Numeric Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a three-digit code number defined in ISO 4217.';
                }
                field(ExchangeRateDate; ExchangeRateDate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Exchange Rate Date';
                    Editable = false;
                    ToolTip = 'Specifies the date of the exchange rate in the Exchange Rate field. You can update the rate by choosing the Update Exchange Rates button.';

                    trigger OnDrillDown()
                    begin
                        DrillDownActionOnPage();
                    end;
                }
                field(ExchangeRateAmt; ExchangeRateAmt)
                {
                    ApplicationArea = Suite;
                    Caption = 'Exchange Rate';
                    DecimalPlaces = 0 : 7;
                    Editable = false;
                    ToolTip = 'Specifies the currency exchange rate. You can update the rate by choosing the Update Exchange Rates button.';

                    trigger OnDrillDown()
                    begin
                        DrillDownActionOnPage();
                    end;
                }
                /*
                field("EMU Currency"; Rec."EMU Currency")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies whether the currency is an EMU currency, for example DEM or EUR.';
                }
                field("Realized Gains Acc."; Rec."Realized Gains Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which realized exchange rate gains will be posted.';
                }
                field("Realized Losses Acc."; Rec."Realized Losses Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which realized exchange rate losses will be posted.';
                }
                field("Unrealized Gains Acc."; Rec."Unrealized Gains Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which unrealized exchange rate gains will be posted when the Adjust Exchange Rates batch job is run.';
                }
                field("Unrealized Losses Acc."; Rec."Unrealized Losses Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which unrealized exchange rate losses will be posted when the Adjust Exchange Rates batch job is run.';
                }
                field("Realized G/L Gains Account"; Rec."Realized G/L Gains Account")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account to post exchange rate gains to for currency adjustments between LCY and the additional reporting currency.';
                    Visible = false;
                }
                field("Realized G/L Losses Account"; Rec."Realized G/L Losses Account")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account to post exchange rate gains to for currency adjustments between LCY and the additional reporting currency.';
                    Visible = false;
                }
                field("Residual Gains Account"; Rec."Residual Gains Account")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account to post residual amount gains to, if you post in the general ledger application area in both LCY and an additional reporting currency.';
                    Visible = false;
                }
                field("Residual Losses Account"; Rec."Residual Losses Account")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account to post residual amount losses to, if you post in the general ledger application area in both LCY and an additional reporting currency.';
                    Visible = false;
                }
                field("Amount Rounding Precision"; Rec."Amount Rounding Precision")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the size of the interval to be used when rounding amounts in this currency.';
                }
                field("Amount Decimal Places"; Rec."Amount Decimal Places")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of decimal places the program will display for amounts in this currency.';
                }
                field("Invoice Rounding Precision"; Rec."Invoice Rounding Precision")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the size of the interval to be used when rounding amounts in this currency. You can specify invoice rounding for each currency in the Currency table.';
                }
                field("Invoice Rounding Type"; Rec."Invoice Rounding Type")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies whether an invoice amount will be rounded up or down. The program uses this information together with the interval for rounding that you have specified in the Invoice Rounding Precision field.';
                }
                field("Unit-Amount Rounding Precision"; Rec."Unit-Amount Rounding Precision")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the size of the interval to be used when rounding unit amounts (that is, item prices per unit) in this currency.';
                }
                field("Unit-Amount Decimal Places"; Rec."Unit-Amount Decimal Places")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of decimal places the program will display for amounts in this currency.';
                }
                field("Appln. Rounding Precision"; Rec."Appln. Rounding Precision")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the size of the interval that will be allowed as a rounding difference when you apply entries in different currencies to one another.';
                }
                field("Conv. LCY Rndg. Debit Acc."; Rec."Conv. LCY Rndg. Debit Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies conversion information that must also contain a debit account if you wish to insert correction lines for rounding differences in the general journals using the Insert Conv. LCY Rndg. Lines function.';
                }
                field("Conv. LCY Rndg. Credit Acc."; Rec."Conv. LCY Rndg. Credit Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies conversion information that must also contain a credit account if you wish to insert correction lines for rounding differences in the general journals using the Insert Conv. LCY Rndg. Lines function.';
                }
                field("Max. VAT Difference Allowed"; Rec."Max. VAT Difference Allowed")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the maximum VAT correction amount allowed for the currency.';
                    Visible = false;
                }
                field("VAT Rounding Type"; Rec."VAT Rounding Type")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how the program will round VAT when calculated for this currency.';
                    Visible = false;
                }
                field("Last Date Adjusted"; Rec."Last Date Adjusted")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies when the exchange rates were last adjusted, that is, the last date on which the Adjust Exchange Rates batch job was run.';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the last date on which any information in the Currency table was modified.';
                }
                field("Payment Tolerance %"; Rec."Payment Tolerance %")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the percentage that the payment or refund is allowed to be, less than the amount on the invoice or credit memo.';
                }
                field("Max. Payment Tolerance Amount"; Rec."Max. Payment Tolerance Amount")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the maximum allowed amount that the payment or refund can differ from the amount on the invoice or credit memo.';
                }*/
                // field(CurrencyFactor; CurrencyFactor)
                // {
                //     ApplicationArea = Suite;
                //     Caption = 'Currency Factor';
                //     DecimalPlaces = 1 : 6;
                //     ToolTip = 'Specifies the relationship between the additional reporting currency and the local currency. Amounts are recorded in both LCY and the additional reporting currency, using the relevant exchange rate and the currency factor.';

                //     trigger OnValidate()
                //     var
                //         CurrencyExchangeRate: Record "Currency Exchange Rate";
                //     begin
                //         CurrencyExchangeRate.SetCurrentCurrencyFactor(Rec.Code, CurrencyFactor);
                //     end;
                // }



            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CurrencyExchangeRate: Record "Treasury Currency Exch Rate";
    begin
        CurrencyFactor := CurrencyExchangeRate.GetCurrentCurrencyFactor(Rec.Code);
        CurrencyExchangeRate.GetLastestExchangeRate(Rec.Code, ExchangeRateDate, ExchangeRateAmt);
    end;

    local procedure DrillDownActionOnPage()
    var
        CurrExchRate: Record "Treasury Currency Exch Rate";
    begin
        CurrExchRate.SetRange("Currency Code", Rec.Code);
        PAGE.RunModal(0, CurrExchRate);
        CurrPage.Update(false);
    end;

    var
        ExchangeRateAmt: Decimal;
        CurrencyFactor: Decimal;
        ExchangeRateDate: Date;

}