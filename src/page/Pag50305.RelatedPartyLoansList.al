page 50305 "RelatedParty Loans List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "RelatedParty Loan Card";
    SourceTable = "RelatedParty Loan";
    Editable = false;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                // field("Loan Name"; Rec."Loan Name")
                // {
                //     ApplicationArea = All;
                //     Visible = false;
                // }
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                    Caption = 'Record No';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Record Name';
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
                    Caption = 'Original / First disbursement Amount';
                }
                field(Category; Rec.Category)
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
        NewRec: Record "RelatedParty Loan";

    trigger OnOpenPage()
    var
        SelectedFilterValue: Text;
        GlobalFilters: Codeunit GlobalFilters;
    begin
        SelectedFilterValue := Rec.GETFILTER("Funder No.");
        GlobalFilters.SetGlobalFilter(SelectedFilterValue);
        Rec.SetRange(Rec."Origin Entry", Rec."Origin Entry"::RelatedParty);
    end;

}