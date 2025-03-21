page 50248 "Schedule Total"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 50245;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Line; Rec.Line)
                {

                }
                field(DueDate; Rec.DueDate)
                {

                }
                field(CalculationDate; Rec.CalculationDate)
                {

                }
                field(Interest; Rec.Interest)
                {

                }
                field(LoanNo; Rec.LoanNo)
                {

                }

                field(Amortization; Rec.Amortization)
                {

                }
                field(TotalPayment; Rec.TotalPayment)
                {

                }
                field(OutStandingAmt; Rec.OutStandingAmt)
                {

                }

                field(WithHldTaxAmt; Rec.WithHldTaxAmt)
                {

                }

                field(NetInterest; Rec.NetInterest)
                {

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