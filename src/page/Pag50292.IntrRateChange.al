page 50292 "Intr. Rate Change"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Interest Rate Change";
    Caption = 'Interest Rate Change List';
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
                    Enabled = false;
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var

    begin


    end;



    var

}