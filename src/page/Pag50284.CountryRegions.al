page 50284 "Country Regions"
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

                field("Tax Min Length"; Rec."KRA Min Length")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Min Length';
                }
                field("Tax Max Length"; Rec."KRA Max Length")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Max Length';
                }
                field("ID Min Length"; Rec."ID Min Length")
                {
                    ApplicationArea = All;
                }
                field("ID Max Length"; Rec."ID Max Length")
                {
                    ApplicationArea = All;
                }
                field("Birth Cert. Min Length"; Rec."Birth Cert. Min Length")
                {
                    ApplicationArea = All;
                }
                field("Birth Cert. Max Length"; Rec."Birth Cert. Max Length")
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