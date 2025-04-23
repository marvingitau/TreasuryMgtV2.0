enum 50238 TreasuryTransactionDocType
{
    Extensible = true;

    value(0; Interest)
    {
        Caption = 'Accruing Interest';
    }
    value(1; Withholding)
    {
        Caption = 'Withholding';
    }
    value(2; "Remaining Amount")
    {
        Caption = 'Remaining Amount';
    }
    value(3; "Original Amount")
    {
        Caption = 'Original Amount';
    }
    value(4; "Repayment")
    {
        Caption = 'Repayment';
    }
    value(5; "Interest Paid")
    {
        Caption = 'Interest Paid';
    }
    value(6; "Capitalized Interest")
    {
        Caption = 'Capitalized Interest';
    }
    value(7; "Secondary Amount")
    {
        Caption = 'Secondary Amount';
    }
    value(10; "Reversed Interest")
    {
        Caption = 'Reversed Interest';
    }
    // value(11; Redemption)
    // {
    //     Caption = 'Redemption';
    // }

}