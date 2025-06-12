page 50301 "Portfolio Card RelatedParty"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Portfolio RelatedParty";
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
                    Editable = IsEditable;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = IsEditable;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(); // Triggers the visibility calculations
                    end;

                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ProgramSize; Rec.ProgramSize)
                {
                    ApplicationArea = All;
                    Caption = 'Program Size';
                    Editable = IsEditable;
                    Enabled = (not ShowOtherFields);
                }
                // field(Value;Rec.Value)
                // {
                //     ApplicationArea = All;
                // }
                // field("Actual Program Size"; Rec."Actual Program Size")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Actual Program Size';
                //     // DrillDown = true;
                //     // DrillDownPageId = 50235;
                //     Editable = false;
                //     trigger OnDrillDown()
                //     var
                //         loans: Record "Funder Loan";
                //     begin
                //         if Rec.Category = Rec.Category::"Bank Loan" then
                //             loans.SetRange(Category, UpperCase('Bank Loan'));
                //         if Rec.Category = Rec.Category::Individual then
                //             loans.SetRange(Category, UpperCase('Individual'));
                //         if Rec.Category = Rec.Category::Institutional then
                //             loans.SetRange(Category, UpperCase('Institutional'));
                //         if Rec.Category = Rec.Category::"Asset Term Manager" then
                //             loans.SetRange(Category, UpperCase('Asset Term Manager'));
                //         if Rec.Category = Rec.Category::"Medium Term Notes" then
                //             loans.SetRange(Category, UpperCase('Medium Term Notes'));

                //         // loans.SetRange(Category_Line_No, Rec.Category_Line_No);
                //         loans.SetRange(loans.Status, loans.Status::Approved);
                //         Page.Run(Page::"Funder Loans List", loans);
                //     end;

                // }
                field("Actual Program Size"; ActualProgramSize)
                {
                    ApplicationArea = All;
                    Caption = 'Actual Program Size';
                    Editable = false;
                }
                field(OutstandingAmountToTarget; Rec.OutstandingAmountToTarget)
                {
                    ApplicationArea = All;
                    Caption = 'Outstanding Amount To Target';
                    Editable = IsEditable;
                    Enabled = (not ShowOtherFields);
                }
                field(BeginDate; Rec.BeginDate)
                {
                    ApplicationArea = All;
                    Caption = 'Begin Date';
                    Editable = IsEditable;
                    Enabled = (not ShowOtherFields);
                }
                field(ProgramTerm; Rec.ProgramTerm)
                {
                    ApplicationArea = All;
                    Caption = 'Program Term(Years)';
                    Editable = IsEditable;
                    Enabled = (not ShowOtherFields);
                }
                field(EndTerm; Rec.EndTerm)
                {
                    ApplicationArea = All;
                    Caption = 'End Term';
                    Editable = false;
                    Enabled = IsEditable;

                }
                // field(ProgramCurrency; Rec.ProgramCurrency)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Program Currency';
                //     Editable = ShowOtherFields;
                // }
                // field("Fee Applicable"; Rec."Fee Applicable")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Fee Applicable (%)';
                //     Editable = false;
                // }
                // field("Interest Rate Applicable"; Rec."Interest Rate Applicable")
                // {
                //     ApplicationArea = All;
                // }
                field("Physical Address"; Rec."Physical Address")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                    Enabled = (not ShowOtherFields);
                }


                // field(Abbreviation; Rec.Abbreviation)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Abbreviation';
                // }

                // field("Category Fee"; Rec."Category Fee")
                // {
                //     ApplicationArea = All;
                //     // ShowMandatory = true;
                //     DrillDownPageId = "Portfolio Fee Setup";
                //     trigger OnDrillDown()
                //     var
                //         FeePage: Page "Portfolio Fee Setup";
                //         PortfolioFeeSetup: Record "Portfolio Fee Setup";
                //     begin
                //         PortfolioFeeSetup.Reset();
                //         if Rec.Category = Rec.Category::"Bank Loan" then
                //             PortfolioFeeSetup.SetRange(Code, 'Bank Loan');
                //         if Rec.Category = Rec.Category::Individual then
                //             PortfolioFeeSetup.SetRange(Code, 'Individual');
                //         if Rec.Category = Rec.Category::Institutional then
                //             PortfolioFeeSetup.SetRange(Code, 'Institutional');

                //         if Page.RunModal(Page::"Portfolio Fee Setup", PortfolioFeeSetup) = Action::LookupOK then begin
                //             // Rec."Fee Applicable" := PortfolioFeeSetup."Fee Applicable %";
                //             Rec.Category_Line_No := PortfolioFeeSetup.LineNo;
                //             CurrPage.Update();
                //         end;
                //     end;
                // }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Editable = IsEditable;
                }

            }
            group("Contact Person Details")
            {
                // field("Contact Person Detail"; Rec."Contact Person Detail")
                // {
                //     ApplicationArea = All;
                // }
                Visible = not ShowOtherFields;
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Contact Person Address"; Rec."Contact Person Address")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Contact Person Phone No."; Rec."Contact Person Phone No.")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Contact Person Email"; Rec."Contact Person Email")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = EMail;
                    Editable = IsEditable;
                }
            }
        }
        area(Factboxes)
        {
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50231),
                              "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Portfolio Fee Setup")
            {
                Caption = 'Applicable Fee';
                Image = InsertStartingFee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                // RunObject = page "Portfolio Fee Setup";
                trigger OnAction()
                var
                    _portfolio: page "Portfolio Fee Setup";
                    GFilter: Codeunit GlobalFilters;
                    _portfolioFeeTbl: Record "Portfolio Fee Setup";
                begin
                    // Page.Run(Page::"Portfolio Fee Setup", Rec, Rec."No.");
                    // GFilter.SetGlobalPortfolioFilter(Rec."No.");
                    // _portfolio.Run();
                    _portfolioFeeTbl.Reset();
                    _portfolioFeeTbl.SetRange(_portfolioFeeTbl.RelatedPartyPortfolioNo, Rec."No.");
                    Page.Run(Page::"Portfolio Fee Setup", _portfolioFeeTbl);

                    // _portfolio.SetTableView(Rec);
                    // _portfolio.run()
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
                        CustomWorkflowMgmt: Codeunit "Related Portfolio Approval Mgt";
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
                        CustomWorkflowMgmt: Codeunit "Related Portfolio Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        CustomWorkflowMgmt.OnCancelWorkflowForApproval(RecRef);
                    end;
                }
                action(SendReopenApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send Reopen A&pproval Request';
                    Enabled = Rec.Status = Rec.Status::Approved;
                    Image = UnApply;
                    ToolTip = 'Request Reopen approval to change the record.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()

                    var
                        CustomWorkflowMgmt: Codeunit "Related Portfolio Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
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

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // if Rec.Category = '' then
        //     Error('Category field is mandatory');

    end;

    trigger OnInit()
    var
        _funderLoans: Record "Funder Loan";
        _acculOutstanding: Decimal;
    begin

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
        IsEditable := not (Rec.Status = Rec.Status::Approved);


        // if Rec."Actual Program Size" = 0 then begin
        //     _funderLoans.Reset();
        //     // _funderLoans.SetRange(Category, Rec.Category);
        //     _funderLoans.SetRange(_funderLoans.Status, _funderLoans.Status::Approved);
        //     if _funderLoans.Find('-') then begin
        //         repeat
        //             _funderLoans.CalcFields(OutstandingAmntDisbLCY);
        //             _acculOutstanding := _acculOutstanding + _funderLoans.OutstandingAmntDisbLCY;
        //         until _funderLoans.Next() = 0;
        //     end;

        //     if Rec."No." <> '' then begin
        //         Rec."Actual Program Size" := _acculOutstanding;
        //         Rec.OutstandingAmountToTarget := Rec.ProgramSize - _acculOutstanding;
        //         Rec.Modify()
        //     end;
        // end;


    end;


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Origin Entry" := Rec."Origin Entry"::RelatedParty;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

    end;


    trigger OnAfterGetRecord()
    begin
        UpdateFieldVisibility();
        // IsEditable := not (Rec.Status = Rec.Status::Approved)
    end;

    trigger OnAfterGetCurrRecord()
    var
        _relatedParty: Record RelatedParty;
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
        HasApprovedApprovalEntries := ApprovalsMgmt.HasApprovedApprovalEntries(Rec.RecordId);


        // if Rec.Category = Rec.Category::"Bank Loan" then
        //     FunderLoan.SetRange(Category, UpperCase('Bank Loan'));
        // if Rec.Category = Rec.Category::Individual then
        //     FunderLoan.SetRange(Category, UpperCase('Individual'));
        // if Rec.Category = Rec.Category::Institutional then
        //     FunderLoan.SetRange(Category, UpperCase('Institutional'));
        // if Rec.Category = Rec.Category::"Asset Term Manager" then
        //     FunderLoan.SetRange(Category, UpperCase('Asset Term Manager'));
        // if Rec.Category = Rec.Category::"Medium Term Notes" then
        //     FunderLoan.SetRange(Category, UpperCase('Medium Term Notes'));


        ActualProgramSize := 0;

        _relatedParty.Reset();
        _relatedParty.SetRange(_relatedParty.Portfolio, Rec."No.");
        _relatedParty.SetRange(_relatedParty.Status, _relatedParty.Status::Approved);
        if _relatedParty.Find('-') then begin
            repeat
                FunderLoan.SetRange(FunderLoan."Funder No.", _relatedParty."No.");
                FunderLoan.SetRange(FunderLoan.Status, FunderLoan.Status::Approved);
                if FunderLoan.Find('-') then begin
                    repeat
                        FunderLoan.CalcFields(OutstandingAmntDisbLCY);
                        ActualProgramSize := ActualProgramSize + FunderLoan.OutstandingAmntDisbLCY;

                    until FunderLoan.Next() = 0;
                end;

            until _relatedParty.Next() = 0;
        end;




        if Rec."No." <> '' then begin
            Rec."Actual Program Size" := ActualProgramSize;
            Rec.OutstandingAmountToTarget := Rec.ProgramSize - ActualProgramSize;
            Rec.Modify()
        end;
    end;


    local procedure UpdateFieldVisibility()
    begin
        ShowOtherFields := (Rec.Category = Rec.Category::"Bank Loan") or (Rec.Category = Rec.Category::Institutional);
        // CurrPage.Editable := ShowOtherFields; // Optional: disable entire page
    end;

    var
        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries, HasApprovedApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        "Region/Country": Record Country_Region;
        ShowOtherFields: Boolean;
        ActualProgramSize: Decimal;
        FunderLoan: Record "RelatedParty Loan";
        IsEditable: Boolean;

}