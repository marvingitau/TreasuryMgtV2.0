pageextension 50231 "Vendor Posting Group" extends 111
{
    layout
    {
        addafter("Payables Account")
        {
            field("Interest Expense"; Rec."Interest Expense")
            {
                ApplicationArea = All;
            }
            field("Interest Payable"; Rec."Interest Payable")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}