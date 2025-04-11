page 50284 "Country Region"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 50284;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Country Name"; Rec."Country Name")
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