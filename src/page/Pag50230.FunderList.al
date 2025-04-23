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
                field("Funder Type"; Rec."Funder Type")
                {
                    ApplicationArea = All;
                }
                field("Counterparty Name"; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
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
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
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
    }
}