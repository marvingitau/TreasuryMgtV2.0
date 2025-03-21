report 50236 "Subscription Form"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(Funders; Funders)
        {
            column(No_; "No.")
            {

            }
            column(Logo; Company.Picture)
            {

            }
            trigger OnPreDataItem()
            begin
                Company.get();
                Company.CalcFields(Picture)
            end;
        }
    }


    rendering
    {
        layout(LayoutName)
        {
            Type = Word;
            LayoutFile = './reports/subscriptionform.docx';
        }
    }

    var
        Company: Record "Company Information";
}
