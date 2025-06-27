page 50238 "Trsy Journal"
{
    // PageType = List;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    SourceTable = "Trsy Journal";
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;
    AutoSplitKey = true;
    Caption = 'Treasury Journals';
    // DataCaptionExpression = Rec.DataCaption();
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;

    layout
    {
        area(Content)
        {
            group(Control120)
            {
                ShowCaption = false;
                field(CurrentJnlBatchName; CurrentJnlBatchName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Batch Name';
                    Lookup = true;
                    ToolTip = 'Specifies the name of the journal batch.';
                    Enabled = false;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin

                    end;
                }


            }
            repeater(GroupName)
            {
                // field("Entry No."; Rec."Entry No.")
                // {
                //     ApplicationArea = All;
                // }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number for the journal line.';
                    ShowMandatory = true;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Currency"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Amount"; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                }
                field("Transaction Nature"; Rec."Transaction Nature")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Enable GL Posting"; Rec."Enable GL Posting")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post';
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        TrsyCU: Codeunit "Treasury Mgt CU";
                    begin
                        TrsyCU.PostTrsyJnl();
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
    begin
        _docNo := TrsyMgt.GenerateDocumentNumber();

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Posting Date" := WorkDate();
        Rec."Document No." := _docNo;
    end;

    var
        GenJnlManagement: Codeunit GenJnlManagement;
        TrsyMgt: Codeunit "Treasury Mgt CU";

    protected var
        CurrentJnlBatchName: Code[10];
        _docNo: Code[20];
}