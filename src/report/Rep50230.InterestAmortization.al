report 50230 "Interest Amortization"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(Loan; "Intr- Amort")
        {
            // RequestFilterFields = "No.";
            column(DueDate; DueDate)
            {

            }

        }

        // dataitem(Loan; "Funder Loan")
        // {
        //     // RequestFilterFields = "No.";
        //     column(No_; "No.")
        //     {

        //     }

        // }
    }

    // requestpage
    // {
    //     AboutTitle = 'Teaching tip title';
    //     AboutText = 'Teaching tip content';
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(GroupName)
    //             {
    //                 field(No; FunderNo)
    //                 {
    //                     TableRelation = "Funder Loan"."No.";
    //                     ApplicationArea = All;

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
            Type = RDLC;
            LayoutFile = './reports/interestamortization.rdlc';
        }
    }
    trigger OnPreReport()

    begin

    end;

    var
        // FunderNo: Code[20];
        FunderLoanTbl: Record "Funder Loan";

}