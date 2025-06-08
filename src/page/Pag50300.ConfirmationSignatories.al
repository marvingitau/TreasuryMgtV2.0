page 50300 "Confirmation Signatories"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Confirmation Signatories";

    //  SourceTableView = WHERE("XX" = CONST(False));
    layout
    {
        area(Content)
        {
            repeater(Gen)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                }
            }
        }

    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(ActionName)
    //         {

    //             trigger OnAction()
    //             begin

    //             end;
    //         }
    //     }
    // }
}