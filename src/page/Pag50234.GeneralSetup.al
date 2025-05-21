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

                field("Region/Country"; Rec."Region/Country")
                {
                    Caption = 'Region/Country';
                    ApplicationArea = All;
                }
                field("Enable Dynamic Interest"; Rec."Enable Dynamic Interest")
                {

                    ApplicationArea = All;
                }


            }
            group(Dimension)
            {
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    CaptionClass = '1,2,1';
                    ApplicationArea = All;
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
                    ShowMandatory = true;
                }
                field("Portfolio No."; Rec."Portfolio No.")
                {

                    ApplicationArea = All;
                }
                field("Funder Change No."; Rec."Funder Change No.")
                {

                    ApplicationArea = All;
                }
            }
            group("GL Accounts")
            {
                field("Total Asset G/L"; Rec."Total Asset G/L")
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
            action("Delete All Loans")
            {
                Image = DeleteRow;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Delete All Loans';
                Visible = false;
                // RunObject = page "Treasury Documents Setup";
                trigger OnAction()
                var
                    loans: Record "Funder Loan";
                begin
                    loans.Reset();
                    loans.SetFilter("No.", '<>%1', '');
                    loans.DeleteAll();
                end;
            }
            action("Treasury Document Setup")
            {
                Image = DocumentsMaturity;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Treasury Document Setup';
                RunObject = page "Treasury Documents Setup";
                trigger OnAction()
                begin

                end;
            }
            action("Country Region")
            {
                Caption = 'Country Region';
                Image = CountryRegion;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page 50284;
            }
            action("Portfolio Fee Setup")
            {
                Caption = 'Portfolio Fee Setup';
                Image = InsertStartingFee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Portfolio Fee Setup";
            }
            action("Dynamic Interest Rate")
            {
                Caption = 'Dynamic Interest Rate';
                Image = InsertTravelFee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Intr. Rate Change";
            }
        }
    }

    trigger OnInit()
    begin
        if Rec.IsEmpty() then
            Rec.Insert();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if Rec."Loan No." = '' then begin
            Error('Loan Name Needed');
            exit(false);
        end;
    end;

    var
        myInt: Integer;
}