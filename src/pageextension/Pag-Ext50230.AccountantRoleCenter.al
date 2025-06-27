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
                group("Portfolio")
                {
                    Caption = 'Portfolio';
                    action(PortfolioList)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Portfolio List';
                        Image = ResourceJournal;
                        RunObject = page 50246;
                        ToolTip = 'Portfolio';
                    }
                    action(PortfolioRenewalList)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Portfolio Renewal List';
                        Image = ReOpen;
                        RunObject = page 50297;
                        ToolTip = 'Portfolio Renewal List';
                    }
                }
                action(Funder)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Funders';
                    Image = CashReceiptJournal;
                    RunObject = Page "Funder List";
                    ToolTip = 'Funder';
                }
                group("Relatedparty/Customer")
                {
                    // action(RElatedParty)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Relatedparty/Customer';
                    //     Image = ResourceJournal;
                    //     RunObject = page "Related Party List";
                    //     ToolTip = 'Relatedparty/Customer';
                    // }
                    action("Relatedparty Portfolio")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Portfolio';
                        Image = ResourceJournal;
                        RunObject = page "Portfolio List RelalatedParty";
                        ToolTip = 'Portfolio';
                    }
                    action("RelatedParty List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'RelatedParty/Customer';
                        Image = ResourceJournal;
                        RunObject = page "RelatedParty List";
                        ToolTip = 'RelatedParty/Customer';
                    }
                    action("RelatedParty Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'RelatedParty/Customer Loan';
                        Image = ResourceJournal;
                        RunObject = page "RelatedParty Loans List";
                        ToolTip = 'RelatedParty/Customer';
                    }
                }

                action("Funder Loans")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Funder Loans';
                    Image = ResourceJournal;
                    RunObject = page 50281;
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
                // action("Treasury Reports")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Treasury Reports';
                //     Image = ResourceJournal;
                //     RunObject = page "Treasury Reports";
                //     ToolTip = 'Treasury Reports';

                // }
                group("Treasury Reports")
                {
                    Caption = 'Treasury Reports';
                    action("Debt Maturity By Category")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Category;

                        Caption = 'Debt Maturity By Category';
                        ToolTip = 'Debt Maturity By Category';
                        RunObject = report "Debt Maturity Category";

                    }
                    action("Debt Maturity By Currency")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Currencies;

                        Caption = 'Debt Maturity By Currency';
                        ToolTip = 'Debt Maturity By Currency';
                        RunObject = report "Debt Maturity Currency";

                    }
                    action("Redemption Report")
                    {
                        ApplicationArea = All;
                        Caption = 'Redemption Report';
                        Image = Report;
                        // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                        RunObject = report "Redemption Report";

                    }
                    action("Interest accrual & capitalization report")
                    {
                        ApplicationArea = All;
                        Caption = 'Interest accrual & capitalization report';
                        Image = AccountingPeriods;
                        // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                        RunObject = report "Intre. Accru & Cap";

                    }
                }

                action("Treasury Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Treasury Setup';
                    Image = ResourceJournal;
                    RunObject = page "General Setup";
                    ToolTip = 'Treasury Setup';
                }
                action("Funder Change List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Funder Change List';
                    Image = ResourceJournal;
                    RunObject = page "Funder Change List";
                    ToolTip = 'Funder Change List';
                }
                action("Interest  Rate Change Group")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Interest  Rate Change Group';
                    Image = ResourceJournal;
                    RunObject = page "Intr. Rate Change Group";
                    ToolTip = 'Interest  Rate Change Group';
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