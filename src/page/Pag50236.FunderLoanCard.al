page 50236 "Funder Loan Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Funder Loan";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Funder Name';
                }
                field("Loan Name"; Rec."Loan Name")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(PlacementDate; Rec.PlacementDate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(MaturityDate; Rec.MaturityDate)
                {
                    ApplicationArea = All;
                }
                // field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                // {
                //     ApplicationArea = All;
                //     ShowMandatory = true;
                // }
                field(FundSource; Rec.FundSource)
                {

                    ApplicationArea = All;
                    Caption = 'Bank';
                    ShowMandatory = true;
                }
                field(Currency; Rec.Currency)
                {
                    Caption = 'Currency';
                    // Visible = false;
                    ApplicationArea = All;
                    // Editable = false;
                    // Visible = isCurrencyVisible;
                    // ShowMandatory = isCurrencyVisible;
                    ShowMandatory = true;
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = All;
                }
                field(OrigAmntDisbLCY; Rec.OrigAmntDisbLCY)
                {
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Original Amount Disbursed';
                }

                field(OutstandingAmntDisbLCY; Rec.OutstandingAmntDisbLCY)
                {
                    // ApplicationArea = Basic, Suite;
                    // Importance = Promoted;
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Outstanding Amount';
                }
                field(InterestRate; Rec.InterestRate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(InterestMethod; Rec.InterestMethod)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(InterestRateType; Rec.InterestRateType)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                // field(InterestRepaymentHz; Rec.InterestRepaymentHz)
                // {
                //     ApplicationArea = All;
                // }
                field(GrossInterestamount; Rec.GrossInterestamount)
                {
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ToolTip = '';
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Interest';
                }

                field(NetInterestamount; Rec.NetInterestamount)
                {
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ToolTip = '';
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Interest';
                }
                // field(PortfolioFund; Rec.PortfolioFund)
                // {
                //     ApplicationArea = All;
                // }

                field(TaxStatus; Rec.TaxStatus)
                {
                    ApplicationArea = All;
                }

                field(Withldtax; Rec.Withldtax)
                {
                    ApplicationArea = All;
                }
                field(InvstPINNo; Rec.InvstPINNo)
                {
                    ApplicationArea = All;
                }
                // field(Portfolio; Rec.Portfolio)
                // {
                //     ApplicationArea = All;
                // }

                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                }

                field(sTenor; Rec.StartTenor)
                {
                    ApplicationArea = All;
                }
                field(eTenor; Rec.EndTenor)
                {
                    ApplicationArea = All;
                }
                field(SecurityType; Rec.SecurityType)
                {
                    ApplicationArea = All;
                }

                field(FormofSec; Rec.FormofSec)
                {
                    ApplicationArea = All;
                }
                // field(EnableGLPosting; Rec.EnableGLPosting)
                // {
                //     ApplicationArea = All;
                // }
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
            action("Compute Interest")
            {
                ApplicationArea = Basic, Suite;
                Image = Interaction;
                //RunObject = codeunit FunderMgtCU::CalculateInterest();
                Caption = 'Compute Interest';
                ToolTip = 'Compute Interest ';
                trigger OnAction()
                var
                    funderMgt: Codeunit FunderMgtCU;
                begin
                    funderMgt.CalculateInterest(Rec."No.");
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
                        CustomWorkflowMgmt: Codeunit "Treasury Approval Mgt";
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
                        CustomWorkflowMgmt: Codeunit "Treasury Approval Mgt";
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


    trigger OnInit()
    begin
        isCurrencyVisible := true;
    end;

    trigger OnOpenPage()
    var
    begin
        _funderNo := GlobalFilters.GetGlobalFilter();
        if _funderNo <> '' then begin
            if FunderTbl.Get(_funderNo) then begin
                if FunderTbl."Funder Type" = FunderTbl."Funder Type"::Local then
                    isCurrencyVisible := false;
            end;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FilterVal: Text[30];
    begin

        if _funderNo <> '' then begin
            // GenSetup.Get(1);
            // GenSetup.TestField("Funder Loan No.");
            // if Rec."No." = '' then
            //     Rec."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true);
            Rec."Funder No." := _funderNo;
            Rec.Validate("Funder No.");
            // Rec.Insert();
        end;

    end;

    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
    end;

    var
        myInt: Integer;
        GenSetup: Record "General Setup";
        NoSer: Codeunit "No. Series";
        GlobalFilters: Codeunit GlobalFilters;
        isCurrencyVisible: Boolean;
        _funderNo: Text[30];
        FunderTbl: Record Funders;

        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";

}