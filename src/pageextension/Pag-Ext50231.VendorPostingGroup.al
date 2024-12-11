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
        addafter("Credit Rounding Account")
        {
            field("Treasury Enabled (Local)"; Rec."Treasury Enabled (Local)")
            {
                Caption = 'Local A/C';
                ToolTip = 'This is utilized by Treasury Module';
                ApplicationArea = All;
            }
            field("Treasury Enabled (Foreign)"; Rec."Treasury Enabled (Foreign)")
            {
                Caption = 'Foreign A/C';
                ToolTip = 'This is utilized by Treasury Module';
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