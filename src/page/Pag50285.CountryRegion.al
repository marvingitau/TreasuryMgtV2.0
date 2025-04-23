page 50285 "Country Region"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = 50284;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Country Name"; Rec."Country Name")
                {
                    ApplicationArea = All;
                }
                field("Country Prefix"; Rec."Country Prefix")
                {
                    ApplicationArea = All;
                }
                field("Country Currency"; Rec."Country Currency")
                {
                    ApplicationArea = All;
                }
                field("Phone Code"; Rec."Phone Code")
                {
                    ApplicationArea = All;
                }
                field("Minimum Phone Length"; Rec."Minimum Phone Length")
                {
                    ApplicationArea = All;
                }
                field("Maximum Phone Length"; Rec."Maximum Phone Length")
                {
                    ApplicationArea = All;
                }
                field("Minimum Bank Length"; Rec."Minimum Bank Length")
                {
                    ApplicationArea = All;
                }
                field("Maximum Bank Length"; Rec."Maximum Bank Length")
                {
                    ApplicationArea = All;
                }
                field("KRA Min Length"; Rec."KRA Min Length")
                {
                    ApplicationArea = All;
                }
                field("KRA Max Length"; Rec."KRA Max Length")
                {
                    ApplicationArea = All;
                }
                field("ID Min Length"; Rec."ID Min Length")
                {
                    ApplicationArea = All;
                }
                field("ID Max Length"; Rec."ID Max Length")
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

    var
        myInt: Integer;
}