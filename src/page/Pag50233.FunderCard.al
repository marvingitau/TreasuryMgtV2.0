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
                field("Funder Type"; Rec."Funder Type")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;

                }
                field("Branch Name"; BranchName)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                // field("Counterparty Type"; Rec."Counterparty Type")
                // {
                //     ApplicationArea = All;
                // }
                field("Tax Identification Number"; Rec."Tax Identification Number")
                {
                    ApplicationArea = All;
                    Caption = 'KRA PIN';
                }
                field("Employer Identification Number"; Rec."Employer Identification Number")
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                }
                field("VAT Number"; Rec."VAT Number")
                {
                    ApplicationArea = All;
                    Caption = 'Business Registration Number';
                }
                field("Legal Entity Identifier"; Rec."Legal Entity Identifier")
                {
                    ApplicationArea = All;
                }
                field("Country/Region"; Rec."Country/Region")
                {
                    ApplicationArea = All;
                }

            }
            group(Address)
            {
                field("Primary Contact Name"; Rec."Primary Contact Name")
                {
                    ApplicationArea = All;
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = PhoneNo;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = EMail;
                    Caption = 'Contact Persons Email';
                }
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
                    Caption = 'Email';
                }
            }
            // group(Contacts)
            // {
            //     field("Primary Contact Name"; Rec."Primary Contact Name")
            //     {
            //         ApplicationArea = All;
            //     }

            //     field("Fax Number"; Rec."Fax Number")
            //     {
            //         ApplicationArea = All;
            //     }

            // }
            group("Bank Details")
            {

                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        // CurrPage.Banks.
                        CurrPage.Update(true);

                    end;
                }
                field("Bank Name"; BankName)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bank Branch"; Rec."Bank Branch")
                {
                    ApplicationArea = All;
                    // TableRelation= BankBranch.BankCode where FILTER('');
                    // trigger OnLookup(var Text: Text): Boolean
                    // begin
                    //     // Message('lookup');
                    // end;
                    Editable = true;
                    DrillDownPageId = "Bank Branch List";
                    trigger OnDrillDown()
                    var
                        _bbranch: Record BankBranch;
                    begin
                        _bbranch.SetRange(BankCode, Rec."Bank Code");
                        if Page.RunModal(Page::"Bank Branch List", _bbranch) = Action::LookupOK then begin
                            // Branch selected, set the branch record to the selected branch
                            Rec."Bank Branch" := _bbranch.BranchCode;
                            BBranchName := _bbranch.BranchName;
                            CurrPage.Update();
                        end;

                    end;

                }
                field("Bank Branch Name"; BBranchName)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bank Account Number"; Rec."Bank Account Number")
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
                // field("Payment Terms"; Rec."Payment Terms")
                // {
                //     ApplicationArea = All;
                // }

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

        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50230),
                              "No." = FIELD("No.");
            }
            // systempart(FunderLinks; Links)
            // {
            //     ApplicationArea = RecordLinks;
            // }
            // systempart(FunderNotes; Notes)
            // {
            //     ApplicationArea = Notes;
            // }
        }
    }

    actions
    {

        area(Processing)
        {

            action("Funder Ledger Entry")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Ledger';
                Image = LedgerEntries;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");
                trigger OnAction()
                var
                    funderLedgerEntry: Record FunderLedgerEntry;
                begin
                    funderLedgerEntry.SETRANGE(funderLedgerEntry."Funder No.", Rec."No.");
                    funderLedgerEntry.SetFilter(funderLedgerEntry."Document Type", '<>%1', funderLedgerEntry."Document Type"::"Remaining Amount");
                    PAGE.RUN(PAGE::FunderLedgerEntry, funderLedgerEntry);

                end;
            }
            action("Funder Loan Open")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Loan (Open)';
                Image = CashReceiptJournal;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");

                trigger OnAction()
                var
                    funderLoan: Record "Funder Loan";
                begin
                    funderLoan.SETRANGE(funderLoan."Funder No.", Rec."No.");
                    funderLoan.SETRANGE(funderLoan.Status, funderLoan.Status::Open);
                    PAGE.RUN(PAGE::"Funder Loans List", funderLoan);

                end;
            }
            action("Funder Loan Pending")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Loan (Pending)';
                Image = CashReceiptJournal;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");
                trigger OnAction()
                var
                    funderLoan: Record "Funder Loan";
                begin
                    funderLoan.SETRANGE(funderLoan."Funder No.", Rec."No.");
                    funderLoan.SETRANGE(funderLoan.Status, funderLoan.Status::"Pending Approval");
                    PAGE.RUN(PAGE::"Funder Loans List", funderLoan);

                end;
            }

            action("Funder Loan Approved")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Loan (Approved)';
                Image = CashReceiptJournal;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");
                trigger OnAction()
                var
                    funderLoan: Record "Funder Loan";
                begin
                    funderLoan.SETRANGE(funderLoan."Funder No.", Rec."No.");
                    funderLoan.SETRANGE(funderLoan.Status, funderLoan.Status::Approved);
                    PAGE.RUN(PAGE::"Funder Loans List", funderLoan);

                end;
            }
        }
        area(Reporting)
        {
            group("Analysis and Docs")
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
                action("Capitalize Interest")
                {
                    ApplicationArea = All;
                    Caption = 'Capitalize Interest';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    RunObject = report "Capitalize Interest";

                }
                action("attachment")
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    // Promoted = true;
                    // PromotedCategory = Report;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                }
            }

        }

    }

    trigger OnAfterGetRecord()
    begin
        DimensionValue.Reset();
        DimensionValue.SetRange(DimensionValue."Dimension Code", 'BRANCH');
        DimensionValue.SetRange(DimensionValue.Code, Rec."Shortcut Dimension 1 Code");
        if DimensionValue.Find('-') then
            BranchName := DimensionValue.Name;

        Banks.Reset();
        Banks.SetRange(Banks.BankCode, Rec."Bank Code");
        if Banks.Find('-') then
            BankName := Banks.Name;

        BankBranch.Reset();
        BankBranch.SetRange(BranchCode, Rec."Bank Branch");
        if BankBranch.Find('-') then
            BBranchName := BankBranch.BranchName;
    end;

    var
        myInt: Integer;
        BranchName: Code[20];
        BankName: Text[50];
        BBranchName: Text[50];
        DimensionValue: Record "Dimension Value";
        Banks: Record Banks;
        BankBranch: Record BankBranch;
}