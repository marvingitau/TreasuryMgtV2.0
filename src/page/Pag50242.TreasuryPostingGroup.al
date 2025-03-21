page 50242 "Treasury Posting Group"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 50240;
    Caption = 'Treasury G/L Mapping';
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Payables Account"; Rec."Payables Account")
                {
                    ApplicationArea = All;
                }
                field("Interest Expense"; Rec."Interest Expense")
                {
                    ApplicationArea = All;
                }
                field("Interest Payable"; Rec."Interest Payable")
                {
                    ApplicationArea = All;
                }
                field("Treasury Enabled (Local)"; Rec."Treasury Enabled (Local)")
                {
                    ApplicationArea = All;
                }
                field("Treasury Enabled (Foreign)"; Rec."Treasury Enabled (Foreign)")
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