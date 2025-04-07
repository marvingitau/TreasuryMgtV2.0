page 50234 "General Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Treasury General Setup";
    Caption = 'Treasury General Setup';
    DeleteAllowed = true;
    InsertAllowed = false;
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(Treasury)
            {

                field("Trsy Recipient mail"; Rec."Trsy Recipient mail")
                {
                    ApplicationArea = all;
                    ToolTip = 'Email Send Alerts too';
                }
                field("Trsy Recipient Name"; Rec."Trsy Recipient Name")
                {
                    ApplicationArea = all;
                    ToolTip = 'Name to Send Alerts too';
                }
                field("Trsy Recipient mail1"; Rec."Trsy Recipient mail1")
                {
                    ApplicationArea = all;
                    ToolTip = 'Email 1 Send Alerts too';
                }
                field("Trsy Recipient Name1"; Rec."Trsy Recipient Name1")
                {
                    ApplicationArea = all;
                    ToolTip = 'Name 1 to Send Alerts too';
                }
                field(WithholdingAcc; Rec.FunderWithholdingAcc)
                {
                    Caption = 'Funder Withholding Tax A/c';
                    ApplicationArea = All;
                }
                // field(DebtorWithholdingAcc; Rec.DebtorWithholdingAcc)
                // {
                //     Caption = 'Debtor Withholding Tax A/c';
                //     ApplicationArea = All;
                // }
                field("Intr. Pay. Rem. Waiting Time"; Rec."Intr. Pay. Rem. Waiting Time")
                {
                    Caption = 'Time to Interest Reminder Alert(Days)';
                    ToolTip = 'Time (Days) before Interest Payment Reminder alert is sent ';
                    ApplicationArea = all;
                }
                field("Placement Rem. Waiting Time"; Rec."Placemnt. Matur Rem. Time")
                {
                    Caption = 'Time to Placement Maturity Reminder Alert(Days)';
                    ToolTip = 'Time (Days) before Placement Maturity Payment Reminder alert is sent ';
                    ApplicationArea = all;
                }
            }
            group(Numbering)
            {
                field("Funder No."; Rec."Funder No.")
                {
                    Caption = 'Funder No.';
                    ApplicationArea = All;
                }
                field("Funder Loan No."; Rec."Funder Loan No.")
                {
                    Caption = 'Funder Loan No';
                    ApplicationArea = All;
                }
                field("Treasury Jnl No."; Rec."Treasury Jnl No.")
                {
                    Caption = 'Treasury Jnl No.';
                    ApplicationArea = All;
                }
                field("Related Party"; Rec."Related Party")
                {
                    // Caption = 'Treasury Jnl No.';
                    ApplicationArea = All;
                }
                field("Loan No."; Rec."Loan No.")
                {

                    ApplicationArea = All;
                }
                field("Portfolio No."; Rec."Portfolio No.")
                {

                    ApplicationArea = All;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action("Treasury Document Setup")
            {
                Image = DocumentsMaturity;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Treasury Document Setup';
                RunObject = page "Treasury Document Setup";
                trigger OnAction()
                begin

                end;
            }
        }
    }

    trigger OnInit()
    begin
        if Rec.IsEmpty() then
            Rec.Insert();
    end;

    var
        myInt: Integer;
}