page 50298 "Disbur. Tranched Entry"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Disbur. Tranched Entry";
    Caption = 'Disbursed Tranches Entries';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Line; Rec.Line)
                {
                    ApplicationArea = All;
                }
                field(PortfolioRecLineNo; Rec.PortfolioRecLineNo)
                {
                    ApplicationArea = All;
                }
                field(DisbursedTrachNo; Rec.DisbursedTrachNo)
                {
                    ApplicationArea = All;
                }
                field(GLAccount; Rec.GLAccount)
                {
                    ApplicationArea = All;
                }
                field(BankAccount; Rec.BankAccount)
                {
                    ApplicationArea = All;
                }
                field(TranchedAmount; Rec.TranchedAmount)
                {
                    ApplicationArea = All;
                }
                field(BankRefNo; Rec.BankRefNo)
                {
                    ApplicationArea = All;
                }
                field("Fee %"; Rec."Fee %")
                {
                    ApplicationArea = All;
                }
                field(utilized; Rec.utilized)
                {
                    ApplicationArea = All;
                }
                field(LoanNo; Rec.LoanNo)
                {
                    ApplicationArea = All;
                }

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
}