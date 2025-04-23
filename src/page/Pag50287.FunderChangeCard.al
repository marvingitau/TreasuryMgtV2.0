page 50287 "Funder Change Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Funder Change";
    Caption = 'Funder Change Card';

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
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Funder No. To Change';
                }
                field(Portfolio; Rec.Portfolio)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ShowMandatory = true;
                }
                field(FunderType; Rec.FunderType)
                {
                    ApplicationArea = all;
                    Caption = 'Funder Type';
                    trigger OnValidate()
                    begin
                        UpdateFastTabVisibility();
                    end;
                }
                // field("Funder Type"; Rec."Funder Type")
                // {
                //     ApplicationArea = all;
                // }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
            }
            group("Personal Detail (Individual)")
            {
                Visible = ShowIndividualFastTab;
                group("Personal Detail General")
                {

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
                    field("Tax Identification Number"; Rec.KRA)
                    {
                        ApplicationArea = All;
                        Caption = 'KRA PIN';
                        ShowMandatory = true;
                    }
                    field("Employer Identification Number"; Rec."Employer Identification Number")
                    {
                        ApplicationArea = All;
                        Caption = 'ID/Passport No.';
                        ShowMandatory = true;
                    }
                    field(IndOccupation; Rec.IndOccupation)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Occupation';
                    }
                    field(IndNatureOfBusiness; Rec.IndNatureOfBusiness)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Nature of Business';
                    }
                    field(IndEmployer; Rec.IndEmployer)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Employer';
                    }
                    // field("VAT Number"; Rec."VAT Number")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Business Registration Number';
                    // }
                    // field("Legal Entity Identifier"; Rec."Legal Entity Identifier")
                    // {
                    //     ApplicationArea = All;
                    // }
                    // field("Country/Region"; Rec."Country/Region")
                    // {
                    //     ApplicationArea = All;
                    // }
                }

                group(Address)
                {
                    field("Physical Address"; Rec."Physical Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        ShowMandatory = true;
                    }
                    field("Phone Number"; Rec."Phone Number")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                    }
                    field("Postal Address"; Rec."Postal Address")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Postal Code"; Rec."Postal Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Mailing Address"; Rec."Mailing Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        ShowMandatory = true;
                    }
                    // field("Pri Contact Name"; Rec."Primary Contact Name")
                    // {
                    //     ApplicationArea = All;
                    //     ShowMandatory = false;
                    // }

                    // field("Email Address"; Rec."Email Address")
                    // {
                    //     ApplicationArea = All;
                    //     ExtendedDatatype = EMail;
                    //     Caption = 'Contact Persons Email';
                    // }

                    // field("Billing Address"; Rec."Billing Address")
                    // {
                    //     ApplicationArea = All;
                    // }

                }
                /*group(Contacts)
                {
                    field("Primary Contact Name"; Rec."Primary Contact Name")
                    {
                        ApplicationArea = All;
                    }

                    field("Fax Number"; Rec."Fax Number")
                    {
                        ApplicationArea = All;
                    }

                }*/
                group("Contact Details")
                {
                    field(ContactDetailName; Rec.ContactDetailName)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(ContactDetailRelation; Rec.ContactDetailRelation)
                    {
                        Caption = 'Relation';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(ContactDetailIdPassport; Rec.ContactDetailIdPassport)
                    {
                        Caption = 'Passport/ID No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(ContactDetailPhone; Rec.ContactDetailPhone)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                }

            }
            group("Personal Detail (Joint Applications)")
            {
                Visible = ShowJointFastTab;
                group("Joint General")
                {
                    field("JointShortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("JointBranch Name"; BranchName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(PersonalDetIDPassport; Rec.PersonalDetIDPassport)
                    {
                        ApplicationArea = All;
                        Caption = 'ID/Passport';
                        ShowMandatory = true;

                    }
                    field(PersonalDetKRA; Rec.KRA)
                    {
                        ApplicationArea = All;
                        Caption = 'KRA Pin No.';
                        ShowMandatory = true;
                    }
                    field(PersonalDetOccupation; Rec.PersonalDetOccupation)
                    {
                        ApplicationArea = All;
                        Caption = 'Occupation';
                        ShowMandatory = true;
                    }
                    field(PersonalDetNatOfBus; Rec.PersonalDetNatOfBus)
                    {
                        ApplicationArea = All;
                        Caption = 'Nature of Business';
                        ShowMandatory = true;
                    }
                    field(PersonalDetEmployer; Rec.PersonalDetEmployer)
                    {
                        ApplicationArea = All;
                        Caption = 'Employer';
                        ShowMandatory = true;
                    }
                }
                group("Joint Contact")
                {
                    field("Joint Physical Address"; Rec."Physical Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        ShowMandatory = true;
                    }
                    field("Joint Phone Number"; Rec."Phone Number")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                    }
                    field("Joint Postal Address"; Rec."Postal Address")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Joint Postal Code"; Rec."Postal Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Joint Mailing Address"; Rec."Mailing Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        ShowMandatory = true;
                    }

                }
                group("Joint Contact Details")
                {
                    field(JointContactDetailName; Rec.ContactDetailName)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(JointContactDetailRelation; Rec.ContactDetailRelation)
                    {
                        Caption = 'Relation';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(JointContactDetailIdPassport; Rec.ContactDetailIdPassport)
                    {
                        Caption = 'Passport/ID No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(JointContactDetailPhone; Rec.ContactDetailPhone)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                }
            }
            group("Corporate Details (Corporates)")
            {
                Visible = ShowCorporateFastTab;
                group("Corporate General")
                {
                    field("CorpShortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("CorpBranch Name"; BranchName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }

                    field(CompanyNo; Rec.CompanyNo)
                    {
                        Caption = 'Company No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Company KRA"; Rec.KRA)
                    {
                        Caption = 'KRA Pin No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Corporate Contact Name"; Rec."Primary Contact Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact Person';
                        ShowMandatory = true;
                    }
                }
                group("Corporate Contact")
                {
                    field("Corporate Physical Address"; Rec."Physical Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        ShowMandatory = true;
                    }
                    field("Corporate Phone Number"; Rec."Phone Number")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                    }
                    field("Corporate Postal Address"; Rec."Postal Address")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Corporate Postal Code"; Rec."Postal Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Corporate Mailing Address"; Rec."Mailing Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        ShowMandatory = true;
                    }




                }

            }
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
            group("Change Reason")
            {
                field(ChangeReason; Rec.ChangeReason)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Caption = 'Change Reason';
                }
            }

        }

        area(FactBoxes)
        {
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50230),
                              "No." = FIELD("No.");
            }
            //  part("Attached Documents"; "Document Attachment Factbox")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Attachments';
            //     SubPageLink = "Table ID" = CONST(50230),
            //                   "No." = FIELD("No.");
            // }
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
            action(BeneficiaryTrustee)
            {
                ApplicationArea = Basic, Suite;
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Beneficiary & Trustees';
                ToolTip = 'Beneficiary & Trustees ';
                // RunObject = page "Funder Loan Ben. Trus.";
                trigger OnAction()
                var
                    btTbl: Record "Funder Ben/Trus";

                begin
                    btTbl.Reset();
                    btTbl.SetRange("Funder No.", Rec."No.");
                    PAGE.Run(Page::"Funder Ben. Trus.", btTbl);
                end;

            }

            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval to change the record.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()

                    var
                        CustomWorkflowMgmt: Codeunit "Portfolio Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Portfolio Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        CustomWorkflowMgmt.OnCancelWorkflowForApproval(RecRef);
                    end;
                }
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
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()

                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;

                    PromotedCategory = New;


                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View approval requests.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = HasApprovalEntries;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
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

        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
    end;
    // Trigger to update FastTab visibility when the record is loaded
    trigger OnAfterGetCurrRecord()
    begin
        UpdateFastTabVisibility();
    end;
    // Trigger to update FastTab visibility when the page is opened
    trigger OnOpenPage()
    begin
        UpdateFastTabVisibility();
    end;
    // Local procedure to update FastTab visibility
    local procedure UpdateFastTabVisibility()
    begin
        // Show the Shipping FastTab only if the Country/Region Code is "US"
        ShowIndividualFastTab := Rec.FunderType = Rec.FunderType::Individual;
        ShowJointFastTab := Rec.FunderType = Rec.FunderType::"Joint Application";
        ShowCorporateFastTab := Rec.FunderType = Rec.FunderType::Corporate;
    end;

    var
        myInt: Integer;
        BranchName: Code[250];
        BankName: Text[50];
        BBranchName: Text[50];
        DimensionValue: Record "Dimension Value";
        Banks: Record Banks;
        BankBranch: Record BankBranch;
        ShowIndividualFastTab: Boolean;
        ShowJointFastTab: Boolean;
        ShowCorporateFastTab: Boolean;

        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
}