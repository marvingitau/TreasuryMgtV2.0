report 50246 "Redemption Document"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(FunderLoan; "Funder Loan")
        {
            column(No_; "No.")
            {

            }
            column(SecurityType; SecurityType)
            {

            }
            column(Name; Name)
            {

            }
            column(Issue_Date; PlacementDate) { }
            column(No_of_Days; LoanDurationDays) { }
            column(Face_Value; "Original Disbursed Amount") { }
            column(InterestRate; InterestRate) { }
            column(GrossInterest; GrossInterest) { }
            column(WithholdingTax; WithholdingTax) { }
            column(NetIntrest; NetIntrest) { }


            dataitem(RedemptionLog; "Redemption Log Tbl")
            {
                DataItemLink = "Loan No." = field("No.");
                DataItemLinkReference = FunderLoan;
                column(Redemption_Date; "Redemption Date")
                {

                }
                column(Confirmation_No; "New Loan No.")
                {

                }
                column(Partial_redemption_amount; AmountRemoved) { }
                column(New_Principal_Amount; RemainingAmount) { }

                column(Logo; Company.Picture)
                {

                }
                column(Insuer; Company.Name)
                {

                }
                column(Address; Company.Address)
                {

                }
                column(City; Company.City)
                {

                }
                column(Phone; Company."Phone No.")
                {

                }
            }
            trigger OnPreDataItem()
            begin
                Company.GET;
                Company.CALCFIELDS(Picture);
                if LoanNo <> '' then
                    FunderLoan.SetRange("No.", LoanNo);
            end;

            trigger OnAfterGetRecord()
            begin
                FunderLoan.CalcFields(GrossInterestamount);
                GrossInterest := FunderLoan.GrossInterestamount;
                FunderLoan.CalcFields(WthdoldingTax);
                WithholdingTax := FunderLoan.WthdoldingTax;
                FunderLoan.CalcFields(AccruedIntr_WthdoldingTax);
                NetIntrest := FunderLoan.AccruedIntr_WthdoldingTax;
            end;

        }
    }

    // requestpage
    // {
    //     // AboutTitle = 'Teaching tip title';
    //     // AboutText = 'Teaching tip content';
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(General)
    //             {
    //                 field(No; LoanNo)
    //                 {
    //                     TableRelation = "Funder Loan"."No.";
    //                 }
    //             }
    //         }
    //     }

    //     actions
    //     {
    //         area(processing)
    //         {
    //             action(LayoutName)
    //             {

    //             }
    //         }
    //     }
    // }

    rendering
    {
        layout(LayoutName)
        {
            Type = Word;
            LayoutFile = './reports/redemptiondocument.docx';
        }
    }

    var
        LoanNo: Code[20];
        FunderLoanTbl: Record "Funder Loan";
        Company: Record "Company Information";
        GrossInterest: Decimal;
        WithholdingTax: Decimal;
        NetIntrest: Decimal;

}