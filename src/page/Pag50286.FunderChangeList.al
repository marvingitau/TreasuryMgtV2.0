page 50286 "Funder Change List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Funder Change";
    CardPageId = "Funder Change Card";
    // Caption = 'Funder Change List';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Portfolio; Rec.Portfolio)
                {
                    ApplicationArea = All;
                }
                field("Funder Type"; Rec."Funder Type")
                {
                    ApplicationArea = All;
                }
                field("Counterparty Name"; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
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