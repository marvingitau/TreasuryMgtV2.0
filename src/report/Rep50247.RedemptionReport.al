report 50247 "Redemption Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    Caption = 'Daily redemption report (full and partial)';

    dataset
    {
        dataitem(Redemption; "Redemption Log Tbl")
        {
            column(Loan_No_; "Loan No.") { }
            column(RedemptionType; RedemptionType) { }
            column(Redemption_Date; "Redemption Date") { }
            column(New_Loan_No_; "New Loan No.") { }
            column(PayingBank; PayingBank) { }
            column(PrincAmountRemoved; PrincAmountRemoved) { }
            column(IntrAmountRemoved; IntrAmountRemoved) { }
            column(AmountRemoved; AmountRemoved) { }
            column(RemainingAmount; RemainingAmount) { }
            trigger OnPreDataItem()
            begin
                if LoanNo <> '' then
                    Redemption.SetRange("Loan No.", LoanNo);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(Name; LoanNo)
                    {
                        TableRelation = "Funder Loan"."No.";
                        ApplicationArea = All;
                    }
                }
            }
        }


    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = './reports/redemptionrepo.rdlc';
        }
    }

    var
        LoanNo: Code[20];
}