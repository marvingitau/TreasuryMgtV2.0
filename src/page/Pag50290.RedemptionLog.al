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
                field("New Loan No."; Rec."New Loan No.")
                {
                    ApplicationArea = All;
                }
                field("Redemption Date"; Rec."Redemption Date")
                {
                    ApplicationArea = All;
                }
                field(PayingBank; Rec.PayingBank)
                {
                    ApplicationArea = All;
                    Caption = 'Paying Bank';
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
                field(AmountRemoved; Rec.AmountRemoved)
                {
                    ApplicationArea = All;
                    Caption = 'Amount Removed';
                }
                field(RemainingAmount; Rec.RemainingAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount ';
                }
                field(FloatingPrinc; Rec.FloatingPrinc)
                {
                    ApplicationArea = All;
                    Caption = 'Floating Principal ';
                }
                field(FloatingIntr; Rec.FloatingIntr)
                {
                    ApplicationArea = All;
                    Caption = 'Floating Interest ';
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