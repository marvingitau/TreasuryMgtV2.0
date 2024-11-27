page 50233 "Funder Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Funders;


    // DataCaptionExpression = '';
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Portfolio; Rec.Portfolio)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Funder Type"; Rec."Funder Type")
                {
                    ApplicationArea = all;
                }
                field("Counterparty Type"; Rec."Counterparty Type")
                {
                    ApplicationArea = All;
                }
                field("Tax Identification Number"; Rec."Tax Identification Number")
                {
                    ApplicationArea = All;
                }
                field("Employer Identification Number"; Rec."Employer Identification Number")
                {
                    ApplicationArea = All;
                }
                field("VAT Number"; Rec."VAT Number")
                {
                    ApplicationArea = All;
                }
                field("Legal Entity Identifier"; Rec."Legal Entity Identifier")
                {
                    ApplicationArea = All;
                }

            }
            group(Address)
            {
                field("Physical Address"; Rec."Physical Address")
                {
                    ApplicationArea = All;
                }
                field("Billing Address"; Rec."Billing Address")
                {
                    ApplicationArea = All;
                }
                field("Mailing Address"; Rec."Mailing Address")
                {
                    ApplicationArea = All;
                }

            }
            group(Contacts)
            {
                field("Primary Contact Name"; Rec."Primary Contact Name")
                {
                    ApplicationArea = All;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = EMail;
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = PhoneNo;
                }
                field("Fax Number"; Rec."Fax Number")
                {
                    ApplicationArea = All;
                }

            }
            group("Bank Details")
            {
                field("Bank Account Number"; Rec."Bank Account Number")
                {
                    ApplicationArea = All;
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = All;
                }
                field("Bank Address"; Rec."Bank Address")
                {
                    ApplicationArea = All;
                }
                field("SWIFT/BIC Code"; Rec."SWIFT/BIC Code")
                {
                    ApplicationArea = All;
                }
                field("IBAN (Int Bank Acc No)"; Rec."IBAN (Int Bank Acc No)")
                {
                    ApplicationArea = All;
                }
                field("Payment Terms"; Rec."Payment Terms")
                {
                    ApplicationArea = All;
                }

            }
            group("Other Details")
            {
                field("KYC Details"; Rec."KYC Details")
                {
                    ApplicationArea = All;
                }
                field("Sanctions Check"; Rec."Sanctions Check")
                {
                    ApplicationArea = All;
                }
                field("AML Compliance Details"; Rec."AML Compliance Details")
                {
                    ApplicationArea = All;
                }

                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                }
                field("Additional Notes"; Rec."Additional Notes")
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
            action("Funder Loan")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Loan';
                Image = CashReceiptJournal;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");
                trigger OnAction()
                var
                    funderLoan: Record "Funder Loan";
                begin
                    funderLoan.SETRANGE(funderLoan."Funder No.", Rec."No.");
                    PAGE.RUN(PAGE::"Funder Loans List", funderLoan);

                end;
            }
        }
    }

    var
        myInt: Integer;
}