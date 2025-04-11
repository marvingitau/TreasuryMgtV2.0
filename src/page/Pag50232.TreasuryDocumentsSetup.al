page 50232 "Treasury Documents Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Treasury Document Setup";
    CardPageId = 50247;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Description"; Rec."Document Description")
                {
                    ApplicationArea = All;
                }
                field(Ownership; Rec.Ownership)
                {
                    ApplicationArea = All;
                }
                field("Must Attached"; Rec."Must Attached")
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