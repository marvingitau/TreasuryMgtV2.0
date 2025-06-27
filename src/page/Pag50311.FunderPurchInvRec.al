page 50311 "Funder Purch. Inv Rec."
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Funder Purch. Inv Rec.";
    Caption = 'Funder Purchase Inv';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Line; Rec.Line)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Funder Loan No"; Rec."Funder Loan No")
                {
                    ApplicationArea = All;
                }
                field("Funder Loan Name"; Rec."Funder Loan Name")
                {
                    ApplicationArea = All;
                }
                field(Funder; Rec.Funder)
                {
                    ApplicationArea = All;
                    Caption = 'Our Funder';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Computed Interest"; Rec."Computed Interest")
                {
                    ApplicationArea = All;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    Enabled = false;
                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field(GloabalDimCode1; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,1';

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
            action("Create a Purchase Invoice")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create a Purchase Invoice';
                Image = Invoice;
                PromotedCategory = Process;
                Promoted = true;
                trigger OnAction()
                begin
                    FunderMgtCU.GenerateICPurchaseInvoice();
                end;
            }
        }
    }

    var
        FunderMgtCU: Codeunit FunderMgtCU;
}