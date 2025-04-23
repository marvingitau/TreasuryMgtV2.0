report 50245 ReminderAlertPerCategory
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(DataItemName; ReminderMaturityPerCategory)
        {
            column(Category; Category)
            {

            }
            column(LoanNo; LoanNo)
            {

            }
            column(MaturityDate; DueDate)
            {

            }
            column(TotalPayment; TotalPayment)
            {

            }
        }
    }

    // requestpage
    // {

    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(GroupName)
    //             {
    //                 field(Name; SourceExpression)
    //                 {

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
            LayoutFile = './reports/reminderalertcategory.rdlc';
        }
    }

    var
        myInt: Integer;
}