page 50247 "Treasury Document Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Treasury Document Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    DataCaptionExpression = '';
    layout
    {
        area(Content)
        {
            group(General)
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
    }

    actions
    {
        area(Processing)
        {
            action("Country/Region Setup")
            {
                Image = CountryRegion;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Country/Region Setup';
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