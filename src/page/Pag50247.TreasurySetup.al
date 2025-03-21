page 50247 "Treasury Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Treasury Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    DataCaptionExpression = '';
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Finace Manager Email"; Rec."Finace Manager Email")
                {
                    ApplicationArea = All;
                }
                field("Finace Manager Email Cc"; Rec."Finace Manager Email Cc")
                {
                    ApplicationArea = All;
                }
            }
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
    trigger OnInit()
    begin
        if Rec.IsEmpty() then
            Rec.Insert();
    end;

    var
        myInt: Integer;
}