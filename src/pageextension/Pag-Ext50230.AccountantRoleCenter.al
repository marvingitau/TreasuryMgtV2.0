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
                action(PortfolioList)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Portfolio';
                    Image = ResourceJournal;
                    RunObject = page 50246;
                    ToolTip = 'Portfolio';
                }
                action(Funder)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Funders';
                    Image = CashReceiptJournal;
                    RunObject = Page "Funder List";
                    ToolTip = 'Funder';
                }
                action(RElatedParty)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Relatedparty/Customer';
                    Image = ResourceJournal;
                    RunObject = page "Related Party List";
                    ToolTip = 'Relatedparty/Customer';
                }
                action("Funder Loans")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Funder Loans';
                    Image = ResourceJournal;
                    RunObject = page 50271;
                    ToolTip = 'Funder Loans';
                }
                action(TrsyJnl)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Treasury Journal';
                    Image = ResourceJournal;
                    RunObject = page "Trsy Journal";
                    ToolTip = 'Treasury Journal';
                }
                // action(GLMapping)
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'G/L Mapping';
                //     Image = ResourceJournal;
                //     RunObject = page "Treasury Posting Group";
                //     ToolTip = 'G/L Mapping';
                // }
                // action(TrsCurrency)
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Treasury Foreign Exchange';
                //     Image = ResourceJournal;
                //     RunObject = page "Treasury Currencies";
                //     ToolTip = 'Treasury Foreign Exchange';
                // }


            }
        }
    }

    var
        myInt: Integer;
}