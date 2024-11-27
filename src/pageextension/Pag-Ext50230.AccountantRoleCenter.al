pageextension 50230 AccountantRoleCenter extends 9027
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter(Action16)
        {
            group("Treasury Management")
            {
                Caption = 'Treasury Management';
                action(Funder)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Funders';
                    Image = CashReceiptJournal;
                    RunObject = Page "Funder List";
                    ToolTip = 'Funder';
                }

                action(TrsyJnl)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Treasury Journal';
                    Image = ResourceJournal;
                    RunObject = page "Trsy Journal";
                    ToolTip = 'Treasury Journal';
                }

            }
        }
    }

    var
        myInt: Integer;
}