/*report 50235 "Mandate Form Agreement"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem(Portfolio; Portfolio)
        {
            column(Code; Code)
            {

            }
        }
    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(Name; SourceExpression)
                    {
                        
                    }
                }
            }
        }
    
        actions
        {
            area(processing)
            {
                action(LayoutName)
                {
                    
                }
            }
        }
    }
  
    rendering
    {
        layout(LayoutName)
        {
            Type = Word;
            LayoutFile = './reports/mandateformagreement.docx';
        }
    }

    var
        myInt: Integer;
}
  */