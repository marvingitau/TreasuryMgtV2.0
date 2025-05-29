page 50294 "Disbur. Tranched"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Disbur. Tranched Loan";
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Payed"; Rec."Total Payed")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Bank Account"; Rec."Bank Account")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Tranche Amount"; Rec."Tranche Amount")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                }
                field("New Repayment Amount"; Rec."New Repayment Amount")
                {
                    ApplicationArea = All;


                }
                field("Bank Reference No"; Rec."Bank Reference No")
                {
                    ApplicationArea = All;


                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = All;

                }

                field("Disbursement Date"; Rec."Disbursement Date")
                {
                    ApplicationArea = All;
                }
                field("Maturity Date"; Rec."Maturity Date")
                {
                    ApplicationArea = All;
                }
                field("Cumulative Disbursed"; Rec."Cumulative Disbursed")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Remaining Balance"; Rec."Remaining Balance")
                {
                    ApplicationArea = All;
                    Editable = false;

                }

                field(Status; Rec.Status)
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
            action("Disburse Tranch")
            {
                Image = TransferToLines;
                Visible = false;
                trigger OnAction()
                var
                    _funderMgt: Codeunit FunderMgtCU;
                    _funderLoan: Record "Funder Loan";
                    _bankAccount: Code[20];
                    _loanAccount: Code[20];
                begin
                    LoanNo := GFilter.GetGlobalLoanFilter();
                    if Confirm('Are you sure?', false) then
                        exit
                    else begin

                        // _funderLoan.Reset();
                        // _funderLoan.SetRange("No.", LoanNo);
                        // if not _funderLoan.Find('-') then begin
                        //     Error('Funder Loan %1 Not Found', LoanNo);
                        // end;
                        // _funderMgt.DirectGLPosting('init', _loanAccount, Rec."Tranche Amount", 'Trach Amount', LoanNo, _bankAccount, _funderLoan.Currency, '', '', '')
                    end;
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
                        CustomWorkflowMgmt: Codeunit "Tranch Loan Approval Mgt";
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
                        CustomWorkflowMgmt: Codeunit "Tranch Loan Approval Mgt";
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

        }
    }

    // trigger OnAfterGetRecord()
    // begin
    //     if Rec."Loan No." = '' then
    //         Rec."Loan No." := LoanNo;
    // end;
    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        // OpenApprovalEntriesExist := ApprovalsMgmt.HasApprovedApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
    end;

    var

        GFilter: Codeunit GlobalFilters;
        trache: Record 50293;
        LoanNo: Code[20];

        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
}