page 50234 "General Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "General Setup";
    Caption = 'General Setup';
    DeleteAllowed = true;
    InsertAllowed = false;
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                // Caption = 'General Setup';
                // field(No; Rec.No)
                // {
                //     ApplicationArea = all;
                // }
                field(WithholdingAcc; Rec.FunderWithholdingAcc)
                {
                    Caption = 'Funder Withholding Tax A/c';
                    ApplicationArea = All;
                }
                field(DebtorWithholdingAcc; Rec.DebtorWithholdingAcc)
                {
                    Caption = 'Debtor Withholding Tax A/c';
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
            }
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

    trigger OnInit()
    begin
        if Rec.IsEmpty() then
            Rec.Insert();
    end;

    var
        myInt: Integer;
}