page 50310 "Relatedparty Sales Inv Rec."
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Relatedparty Sales Inv Rec.";
    Caption = 'Relatedparty Sales Inv';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Line; Rec.Line)
                {
                    ApplicationArea = All;
                }
                field("Related Loan No"; Rec."Related Loan No")
                {
                    ApplicationArea = All;
                }
                field("Related Loan Name"; Rec."Related Loan Name")
                {
                    ApplicationArea = All;
                }
                field(Funder; Rec.Funder)
                {
                    ApplicationArea = All;
                    Caption = 'Our Funder';
                }
                field("Customer No."; Rec."Customer No.")
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
            action("Create a Sales Invoice")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create a Sales Invoice';
                Image = Invoice;
                PromotedCategory = Process;
                Promoted = true;
                trigger OnAction()
                begin
                    RelatepartyMgtCU.GenerateICSalesInvoice();
                end;
            }
        }
    }

    var
        RelatepartyMgtCU: Codeunit RelatepartyMgtCU;
}