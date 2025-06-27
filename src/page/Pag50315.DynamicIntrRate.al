page 50315 "Dynamic Intr. Rate"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Dynamic Interest Rate";
    Caption = 'Dynamic Interest Rate List';
    // This will calculate interest depending on the effective date. 
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Effective Dates"; Rec."Effective Dates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Effective Date (from when the new rate applies)';
                }
                field("New Interest Rate"; Rec."New Interest Rate")
                {
                    ApplicationArea = All;
                    Caption = 'New Interest Rate (%)';
                }
                field(Active; Rec.Active)
                {
                    Caption = 'Current Interest';
                    ApplicationArea = All;

                }
                field(Enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                    ApplicationArea = All;
                    Enabled = false;
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

    trigger OnOpenPage()
    var
    begin

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean

    begin

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

    end;



    var
        CategoryFilter: Text;
        GroupIDFilter: Code[20];
        GroupNameFilter: Code[50];


}