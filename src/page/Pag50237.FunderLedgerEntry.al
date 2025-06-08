page 50237 FunderLedgerEntry
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = FunderLedgerEntry;
    Caption = 'Treasury Ledger Entry';
    // Editable = false;
    // DeleteAllowed = false;
    // InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                }
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                    Caption = 'Record No.';
                }
                field("Funder Name"; Rec."Funder Name")
                {
                    ApplicationArea = All;
                    Caption = 'Record Name';
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    Caption = 'Loan No.';
                }
                field("Loan Name"; Rec."Loan Name")
                {
                    ApplicationArea = All;
                    Caption = 'Loan Name';
                }

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Caption = 'Currency Code';
                }
                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                }
                field("Amount(LCY)"; Rec."Amount(LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Amount(LCY)';
                }
                // field("Remain Amount"; Rec."Remaining Amount")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Remain Amount';
                // }
                // field("Remaining Amount(LCY)"; Rec."Remaining Amount(LCY)")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Remain Amount(LCY)';
                // }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Opening  Balance Acc"; Rec."Opening  Balance Acc")
                {
                    ApplicationArea = All;
                }
                field(GloabalDimCode1; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,1';

                }
                field(GloabalDimCode2; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,2';

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