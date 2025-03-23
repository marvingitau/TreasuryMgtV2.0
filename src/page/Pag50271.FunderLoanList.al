page 50271 "Funder Loan List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Funder Loan";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    CardPageId = 50272;
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
                field("Loan Name"; Rec."Loan Name")
                {
                    ApplicationArea = All;
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
                field("Original Disbursed Amount"; Rec."Original Disbursed Amount")
                {
                    ApplicationArea = All;
                }
                field(InterestRate; Rec.InterestRate)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Rate';
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
            action("Open Records")
            {
                Promoted = true;
                PromotedIsBig = true;
                Image = OpenJournal;
                PromotedCategory = Process;
                Caption = 'Open Records';
                trigger OnAction()
                begin
                    // if Rec.Status = Rec.Status::"Pending Approval" then
                    Rec.SetRange(Status, Rec.Status::Open);
                    CurrPage.Update(false); // Refresh the page
                end;
            }
            action("Pending Approval")
            {
                Promoted = true;
                PromotedIsBig = true;
                Image = PeriodEntries;
                PromotedCategory = Process;
                Caption = 'Pending Approval';
                trigger OnAction()
                begin
                    // if Rec.Status = Rec.Status::"Pending Approval" then
                    Rec.SetRange(Status, Rec.Status::"Pending Approval");
                    CurrPage.Update(false); // Refresh the page
                end;
            }
            action("Approved Approval")
            {
                Promoted = true;
                PromotedIsBig = true;
                Image = Approval;
                PromotedCategory = Process;
                Caption = 'Approved Approval';
                trigger OnAction()
                begin
                    // if Rec.Status = Rec.Status::Approved then
                    Rec.SetRange(Status, Rec.Status::Approved);
                    CurrPage.Update(false); // Refresh the page
                end;
            }
            action("Rejected Approval")
            {
                Promoted = true;
                PromotedIsBig = true;
                Image = Reject;
                PromotedCategory = Process;
                Caption = 'Rejected Approval';
                trigger OnAction()
                begin
                    // if Rec.Status = Rec.Status::Rejected then
                    Rec.SetRange(Status, Rec.Status::Rejected);
                    CurrPage.Update(false); // Refresh the page
                end;
            }

        }
    }
}