page 50309 "Overdraft Ledger Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Overdraft Ledger Entries";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Opening Bal."; Rec."Opening Bal.")
                {
                    ApplicationArea = All;
                }
                field("Closing Bal."; Rec."Closing Bal.")
                {
                    ApplicationArea = All;
                }
                field("Balance Difference"; Rec."Balance Difference")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bank Account"; Rec."Bank Account")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Calculated Interest"; Rec."Calculated Interest")
                {
                    ApplicationArea = All;
                }
                field("Calculated Witholding Amount"; Rec."Calculated Witholding Amount")
                {
                    ApplicationArea = All;
                }
                field("Twin Record ID"; Rec."Twin Record ID")
                {
                    ApplicationArea = All;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                }
                field(Processed; Rec.Processed)
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
            action("Calculate Interest")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = InteractionTemplate;
                RunObject = report "OD Interest Calculation";

                trigger OnAction()
                begin

                end;
            }
            action("Post Interest")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Post;
                RunObject = report "OD Interest Posting";

                trigger OnAction()
                begin

                end;
            }
            action("Calculate & Post Overdraft Interest")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Process;
                RunObject = report "Overdraft Interest Posting";

                trigger OnAction()
                begin

                end;
            }
        }
    }
}