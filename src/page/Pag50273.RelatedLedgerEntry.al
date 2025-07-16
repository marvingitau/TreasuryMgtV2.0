page 50273 RelatedLedgerEntry
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = RelatedLedgerEntry;
    Caption = 'Related Ledger Entry';
    // Editable = false;
    // DeleteAllowed = false;
    // InsertAllowed = false;

    //DEPRECATED
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                }
                field("Related No."; Rec."RelatedParty No.")
                {
                    ApplicationArea = All;
                    Caption = 'Related No.';
                }
                field("Related Name"; Rec."Related  Name")
                {
                    ApplicationArea = All;
                    Caption = 'Related Name';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
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

                field("Account Type"; Rec."Account Type")
                {
                    Caption = 'Account Type';
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    Caption = 'Account No.';
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    Caption = 'Bal. Account Type';
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    Caption = 'Bal. Account No.';
                    ApplicationArea = All;
                }
                field("Bal. Account Type 2"; Rec."Bal. Account Type 2")
                {
                    Caption = 'Bal. Account Type 2';
                    ApplicationArea = All;
                }
                field("Bal. Account No. 2"; Rec."Bal. Account No. 2")
                {
                    Caption = 'Bal. Account No. 2';
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