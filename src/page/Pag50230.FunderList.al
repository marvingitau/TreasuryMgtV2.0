page 50230 "Funder List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Funders;
    CardPageId = "Funder Card";
    Caption = 'Funder/Supplier List';

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
                field(Portfolio; Rec.Portfolio)
                {
                    ApplicationArea = All;
                }
                // field("Funder Type"; Rec."Funder Type")
                // {
                //     ApplicationArea = All;
                // }
                field("Counterparty Name"; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(FunderType; Rec.FunderType)
                {
                    ApplicationArea = All;
                    Caption = 'Funder Type';
                }
                field(KRA; Rec.KRA)
                {
                    ApplicationArea = All;
                }
                field(PersonalDetIDPassport; Rec.PersonalDetIDPassport)
                {
                    ApplicationArea = All;
                    Caption = 'ID/Passport';
                }
                field(IndOccupation; Rec.IndOccupation)
                {
                    ApplicationArea = All;
                    Caption = 'Occupation';
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = All;
                }
                field("Mailing Address"; Rec."Mailing Address")
                {
                    ApplicationArea = All;
                    Caption = 'Email';
                }
                field("Payables Account"; Rec."Payables Account")
                {
                    ApplicationArea = All;
                    Caption = 'Principal';
                }
                field("Interest Expense"; Rec."Interest Expense")
                {
                    ApplicationArea = All;
                }
                field("Interest Payable"; Rec."Interest Payable")
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
            action("Open Records")
            {
                Promoted = true;
                PromotedIsBig = true;
                Image = OpenJournal;
                PromotedCategory = Process;
                Caption = 'Open Funders';
                trigger OnAction()
                begin
                    // if Rec.Status = Rec.Status::"Pending Approval" then
                    Rec.SetRange(Status, Rec.Status::Open);
                    CurrPage.Update(false); // Refresh the page
                end;
            }

            action("Approved Approval")
            {
                Promoted = true;
                PromotedIsBig = true;
                Image = Approval;
                PromotedCategory = Process;
                Caption = 'Approved Funders';
                trigger OnAction()
                begin
                    // if Rec.Status = Rec.Status::Approved then
                    Rec.SetRange(Status, Rec.Status::Approved);
                    CurrPage.Update(false); // Refresh the page
                end;
            }
            // action(ActionName)
            // {

            //     trigger OnAction()
            //     begin

            //     end;
            // }
            action("Reminder On Placement Maturity")
            {
                Image = Reminder;
                Promoted = true;
                PromotedCategory = Process;
                // PromotedIsBig = true;
                trigger OnAction()
                var
                    PlacementReminder: Report "Reminder on Placement Mature";
                    _funderLoan: Record "Funder Loan";
                begin
                    PlacementReminder.Run();
                    // _funderLoan.SetRange("No.", Rec."No.");
                    // Report.Run(50237, true, false, _funderLoan);
                    // EmailingCU.SendReminderOnPlacementMaturity(Rec."No.")
                end;
            }

        }
        area(Reporting)
        {
            action("ReEvaluateFX")
            {
                ApplicationArea = All;
                Caption = 'ReEvaluateFX';
                Image = Report;
                // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                RunObject = report ReEvaluateFX;

            }
            // action("Capitalize Interest")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Capitalize Interest';
            //     Image = Report;
            //     // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
            //     Promoted = true;
            //     PromotedCategory = Report;
            //     PromotedIsBig = true;
            //     RunObject = report "Capitalize Interest";

            // }
            action("Redemption Report")
            {
                ApplicationArea = All;
                Caption = 'Redemption Report';
                Image = Report;
                // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                RunObject = report "Redemption Report";

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange(Status, Rec.Status::Open);
    end;
}