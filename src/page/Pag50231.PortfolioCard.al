page 50231 "Portfolio Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = Portfolio;
    DataCaptionFields = "No.", Code;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(ProgramSize; Rec.ProgramSize)
                {
                    ApplicationArea = All;
                    Caption = 'Program Size';
                }
                // field(Value;Rec.Value)
                // {
                //     ApplicationArea = All;
                // }
                field("Actual Program Size"; Rec."Actual Program Size")
                {
                    ApplicationArea = All;
                    Caption = 'Actual Program Size';
                    // DrillDown = true;
                    // DrillDownPageId = 50235;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        loans: Record "Funder Loan";
                    begin
                        loans.SetRange(Category, Rec.Category);
                        loans.SetRange(loans.Status, loans.Status::Approved);
                        Page.Run(Page::"Funder Loans List", loans);
                    end;

                }
                field(OutstandingAmountToTarget; Rec.OutstandingAmountToTarget)
                {
                    ApplicationArea = All;
                    Caption = 'Outstanding Amount To Target';
                }
                field(BeginDate; Rec.BeginDate)
                {
                    ApplicationArea = All;
                    Caption = 'Begin Date';
                }
                field(ProgramTerm; Rec.ProgramTerm)
                {
                    ApplicationArea = All;
                    Caption = 'Program Term(Years)';
                }
                field(EndTerm; Rec.EndTerm)
                {
                    ApplicationArea = All;
                    Caption = 'End Term';
                    Editable = false;
                }
                field(ProgramCurrency; Rec.ProgramCurrency)
                {
                    ApplicationArea = All;
                    Caption = 'Program Currency';
                }
                field("Fee Applicable"; Rec."Fee Applicable")
                {
                    ApplicationArea = All;
                    Caption = 'Fee Applicable (%)';
                }
                // field("Interest Rate Applicable"; Rec."Interest Rate Applicable")
                // {
                //     ApplicationArea = All;
                // }
                field("Physical Address"; Rec."Physical Address")
                {
                    ApplicationArea = All;
                }


                // field(Abbreviation; Rec.Abbreviation)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Abbreviation';
                // }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    // Editable = false;
                }

            }
            group("Contact Person Details")
            {
                // field("Contact Person Detail"; Rec."Contact Person Detail")
                // {
                //     ApplicationArea = All;
                // }
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                    ApplicationArea = All;
                }
                field("Contact Person Address"; Rec."Contact Person Address")
                {
                    ApplicationArea = All;
                }
                field("Contact Person Phone No."; Rec."Contact Person Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Contact Person Email"; Rec."Contact Person Email")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = EMail;
                }
            }
        }
        area(Factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50231),
                              "No." = FIELD(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
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

            group("Analysis & Documents")
            {
                action("attachment")
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
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
    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if Rec.Category = '' then
            Error('Category field is mandatory');

    end;

    trigger OnOpenPage()
    var
        _funderLoans: Record "Funder Loan";
        _acculOutstanding: Decimal;
    begin
        "Region/Country".Reset();
        if "Region/Country".IsEmpty() then begin
            Error('Region/Country must have atleast one entry');
            exit;
        end;
        // if Rec."Actual Program Size" = 0 then begin
        _funderLoans.Reset();
        _funderLoans.SetRange(Category, Rec.Category);
        _funderLoans.SetRange(_funderLoans.Status, _funderLoans.Status::Approved);
        if _funderLoans.Find('-') then begin
            repeat
                _funderLoans.CalcFields(OutstandingAmntDisbLCY);
                _acculOutstanding := _acculOutstanding + _funderLoans.OutstandingAmntDisbLCY;
            until _funderLoans.Next() = 0;
        end;

        if Rec."No." <> '' then begin
            Rec."Actual Program Size" := _acculOutstanding;
            Rec.OutstandingAmountToTarget := Rec.ProgramSize - _acculOutstanding;
            Rec.Modify()
        end;

        // end;
    end;

    trigger OnInit()
    var
        _funderLoans: Record "Funder Loan";
        _acculOutstanding: Decimal;
    begin
        // if Rec."Actual Program Size" = 0 then begin
        //     _funderLoans.Reset();
        //     _funderLoans.SetRange(Category, Rec.Category);
        //     _funderLoans.SetRange(_funderLoans.Status, _funderLoans.Status::Approved);
        //     if _funderLoans.Find('-') then begin
        //         repeat
        //             _funderLoans.CalcFields(OutstandingAmntDisbLCY);
        //             _acculOutstanding := _acculOutstanding + _funderLoans.OutstandingAmntDisbLCY;
        //         until _funderLoans.Next() = 0;
        //     end;
        //     Rec."Actual Program Size" := _acculOutstanding;
        //     //  Rec.Modify()
        // end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

    end;

    var
        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        "Region/Country": Record Country_Region;
}