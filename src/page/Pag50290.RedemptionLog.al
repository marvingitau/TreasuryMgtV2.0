page 50290 "Redemption Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Redemption Log Tbl";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Line; Rec.Line)
                {
                    ApplicationArea = All;
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                }
                field("Redemption Date"; Rec."Redemption Date")
                {
                    ApplicationArea = All;
                }
                field(RedemptionType; Rec.RedemptionType)
                {
                    ApplicationArea = All;
                    Caption = 'Redemption Type';
                }
                field(PrincAmountRemoved; Rec.PrincAmountRemoved)
                {
                    ApplicationArea = All;
                    Caption = 'Principal Removed';
                }
                field(IntrAmountRemoved; Rec.IntrAmountRemoved)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Removed';
                }
                field(PayingBank; Rec.PayingBank)
                {
                    ApplicationArea = All;
                    Caption = 'Paying Bank';
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