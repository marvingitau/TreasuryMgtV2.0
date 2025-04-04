page 50235 "Funder Loans List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Funder Loan Card";
    SourceTable = "Funder Loan";
    Editable = false;
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
                field("Loan Name"; Rec."Loan Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Funder Name';
                }

                field("PlacementDate"; Rec."PlacementDate")
                {
                    ApplicationArea = All;
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                }
                field("Original Disbursed Amount"; Rec."Original Disbursed Amount")
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
            // action(NewCardAction)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Create New Card';
            //     trigger OnAction()
            //     var

            //     begin
            //         SelectedFilterValue := Rec.GETFILTER("Funder No.");
            //         Message(SelectedFilterValue);
            //         // Create a new record
            //         // NewRec.Init();
            //         // NewRec."Funder No." := SelectedFilterValue;
            //         // NewRec.Insert(true);
            //         // PAGE.RunModal(PAGE::"Funder Loan Card", NewRec);
            //         //PAGE::"Funder Loan Card".SetFilterValue(SelectedFilterValue);
            //     end;
            // }


        }
    }
    var
        SelectedFilterValue: Text;
        NewRec: Record "Funder Loan";

    trigger OnOpenPage()
    var
        SelectedFilterValue: Text;
        GlobalFilters: Codeunit GlobalFilters;
    begin
        SelectedFilterValue := Rec.GETFILTER("Funder No.");
        GlobalFilters.SetGlobalFilter(SelectedFilterValue);
    end;

    // trigger OnNewRecord(BelowxRec: Boolean)
    // begin
    //     Error('f');
    // end;
}