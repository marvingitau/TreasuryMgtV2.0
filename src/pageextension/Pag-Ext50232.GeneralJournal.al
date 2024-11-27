pageextension 50232 "General Journal" extends "General Journal"
{
    layout
    {
        addbefore("Document No.")
        {
            // field("Transaction Nature"; Rec."Transaction Nature")
            // {
            //     ApplicationArea = All;
            // }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}