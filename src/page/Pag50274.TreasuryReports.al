page 50274 "Treasury Reports"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = 50280;

    layout
    {
        area(Content)
        {
            group(General)
            {
                // field(Name; NameSource)
                // {

                // }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Reminder On Intr. Due")
            {
                ApplicationArea = Basic, Suite;
                Image = Currencies;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Reminder On Intr. Due';
                ToolTip = 'Reminder On Intr. Due';
                RunObject = report "Reminder On Intr. Due";

            }
        }
        area(Reporting)
        {
            action("Debt Maturity By Category")
            {
                ApplicationArea = Basic, Suite;
                Image = Category;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Debt Maturity By Category';
                ToolTip = 'Debt Maturity By Category';
                RunObject = report "Debt Maturity Category";

            }
            action("Debt Maturity By Currency")
            {
                ApplicationArea = Basic, Suite;
                Image = Currencies;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Debt Maturity By Currency';
                ToolTip = 'Debt Maturity By Currency';
                RunObject = report "Debt Maturity Currency";

            }


        }
    }

    var
        myInt: Integer;
}