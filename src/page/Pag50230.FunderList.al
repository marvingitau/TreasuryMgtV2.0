page 50230 "Funder List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Funders;
    Caption = 'Funder/Supplier List';
    CardPageId = "Funder Card";

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
                field("Portfolio Name"; Rec."Portfolio Name")
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
            // action("Open Records")
            // {
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     Image = OpenJournal;
            //     PromotedCategory = Process;
            //     Caption = 'Open Funders';
            //     trigger OnAction()
            //     begin
            //         // if Rec.Status = Rec.Status::"Pending Approval" then
            //         Rec.SetRange(Status, Rec.Status::Open);
            //         CurrPage.Update(false); // Refresh the page
            //     end;
            // }

            // action("Approved Approval")
            // {
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     Image = Approval;
            //     PromotedCategory = Process;
            //     Caption = 'Approved Funders';
            //     trigger OnAction()
            //     begin
            //         // if Rec.Status = Rec.Status::Approved then
            //         Rec.SetRange(Status, Rec.Status::Approved);
            //         CurrPage.Update(false); // Refresh the page
            //     end;
            // }

            action("Reminder On Placement Maturity")
            {
                Image = Reminder;
                Promoted = true;
                PromotedCategory = Process;
                // PromotedIsBig = true;
                Visible = false;
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

            action("Purchase Invoices")
            {
                ApplicationArea = All;
                Caption = 'Purchase Invoices';
                Image = OverdueEntries;
                PromotedCategory = Category4;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Funder Purch. Inv Rec.";


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
                Visible = false;

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
                Visible = false;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Rec.SetRange(Status, Rec.Status::Open);
        Rec.SetRange(Rec."Origin Entry", Rec."Origin Entry"::Funder);
    end;
}