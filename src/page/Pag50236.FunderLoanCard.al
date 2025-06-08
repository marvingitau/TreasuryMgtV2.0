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
                    // Editable = false;
                }
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    Caption = 'Funder Name';
                }
                // field("Loan Name"; Rec."Loan Name")
                // {
                //     ApplicationArea = All;
                //     // ShowMandatory = true;
                //     Visible = false;
                // }
                field(PlacementDate; Rec.PlacementDate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        if (Rec.PlacementDate <> 0D) and (Rec.MaturityDate <> 0D) then begin
                            PlacementAndMaturityDifference := (Rec.MaturityDate - Rec.PlacementDate);
                            Message('Loan Duration is %1', Format(PlacementAndMaturityDifference));
                        end;
                    end;
                }
                field(MaturityDate; Rec.MaturityDate)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        if (Rec.PlacementDate <> 0D) and (Rec.MaturityDate <> 0D) then begin

                            PlacementAndMaturityDifference := (Rec.MaturityDate - Rec.PlacementDate);
                            Message('Loan Duration is %1', Format(PlacementAndMaturityDifference));
                        end;
                    end;
                }
                field(LoanDurationDays; Rec.LoanDurationDays)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Loan Duration (Days)';
                }
                field(FundSource; Rec.FundSource)
                {

                    ApplicationArea = All;
                    Caption = 'Receiving Bank Account';
                    ShowMandatory = true;
                }
                field(Currency; Rec.Currency)
                {
                    Caption = 'Currency';
                    // Visible = false;
                    ApplicationArea = All;
                    Editable = false;
                    // Visible = isCurrencyVisible;
                    // ShowMandatory = isCurrencyVisible;
                    // ShowMandatory = true;
                }
                // field(CustomFX; Rec.CustomFX)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Custom Foreign Exchage';
                //     ToolTip = 'This field indicate a negotiated Foreign Exchange Amount under Treasury Currencies';
                //     // Editable = false;
                // }
                // field("Posting Group"; Rec."Posting Group")
                // {
                //     ApplicationArea = All;
                //     // Editable = false;
                // }
                field("Bank Ref. No."; Rec."Bank Ref. No.")
                {
                    ApplicationArea = All;
                    Caption = 'Bank Reference No.';
                    ShowMandatory = true;
                }
                group("G/L Mapping")
                {
                    field("Payables Account"; Rec."Payables Account")
                    {

                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Principal Account';
                    }
                    field("Interest Expense"; Rec."Interest Expense")
                    {

                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Interest Payable"; Rec."Interest Payable")
                    {

                        ApplicationArea = All;
                        Editable = false;
                    }
                }
                field("Total Payed"; Rec."Total Payed")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Tranche Loan";
                    Editable = not (Rec.Status = Rec.Status::Approved);
                    ToolTip = 'This indicates the Total to Be Payed under Tranches Loan';
                    Caption = 'Total Expected Amount';

                }
                field("Original Disbursed Amount"; Rec."Original Disbursed Amount")
                {
                    ApplicationArea = All;
                    Editable = not (Rec.Status = Rec.Status::Approved);
                }
                // field(OrigAmntDisbLCY; Rec.OrigAmntDisbLCY)
                // {
                //     DrillDown = true;
                //     DrillDownPageId = FunderLedgerEntry;
                //     ApplicationArea = All;
                //     Caption = 'Original Amount Disbursed';
                // }

                field(OutstandingAmntDisbLCY; Rec.OutstandingAmntDisbLCY)
                {
                    // ApplicationArea = Basic, Suite;
                    // Importance = Promoted;
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Outstanding Amount';
                }
                field("Outstanding Interest"; Rec."Outstanding Interest")
                {
                    // ApplicationArea = Basic, Suite;
                    // Importance = Promoted;
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Outstanding Interest';
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
                    trigger OnValidate()
                    begin
                        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then
                            isFloatRate := true
                        else
                            isFloatRate := false;
                        CurrPage.Update();
                    end;
                }
                field(InterestRate; Rec.InterestRate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = not isFloatRate;
                    Caption = 'Gross Interest rate (p.a)';
                }
                field(NetInterestRate; Rec.NetInterestRate)
                {
                    ApplicationArea = All;
                    Caption = 'Net Interest Rate';
                }
                group(FloatInterestFields)
                {
                    Caption = 'Float Rate Related Fields';
                    ShowCaption = true;
                    field("Reference Rate"; Rec."Reference Rate")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = isFloatRate;
                        trigger OnValidate()
                        begin
                            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                            Rec.Modify();
                            CurrPage.Update();
                        end;
                    }
                    field(Margin; Rec.Margin)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = isFloatRate;
                        trigger OnValidate()
                        begin
                            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                            Rec.Modify();
                            CurrPage.Update();
                        end;
                    }
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
                field(PeriodicPaymentOfInterest; Rec.PeriodicPaymentOfInterest)
                {
                    Caption = '*Payment Period (Interest) ';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateInterestPaymentVisibility();

                        // CurrPage.Update();
                    end;

                }

                field(PeriodicPaymentOfPrincipal; Rec.PeriodicPaymentOfPrincipal)
                {
                    Caption = '*Payment Period (Principal) ';
                    ApplicationArea = All;

                }

                field(TaxStatus; Rec.TaxStatus)
                {
                    ApplicationArea = All;
                }

                field(Withldtax; Rec.Withldtax)
                {
                    ApplicationArea = All;
                }
                // field(InvestmentTenor; Rec.InvestmentTenor)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Investment Tenor (Months)';
                // }
                field(InvstPINNo; Rec.InvstPINNo)
                {
                    ApplicationArea = All;
                }
                field("Enable GL Posting"; Rec.EnableGLPosting)
                {
                    ApplicationArea = All;
                }
                field("Tranche Loan"; Rec."Tranche Loan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Is this loan a Tranched Loan';
                    Editable = TranchesView;
                }

                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                // field(sTenor; Rec.StartTenor)
                // {
                //     ApplicationArea = All;
                // }
                // field(eTenor; Rec.EndTenor)
                // {
                //     ApplicationArea = All;
                // }
                field(SecurityType; Rec.SecurityType)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        if Rec.SecurityType = Rec.SecurityType::"Senior secured" then begin
                            isSecureLoanActive := true;
                            isUnsecureLoanActive := false;
                        end
                        else begin
                            isUnsecureLoanActive := true;
                            isSecureLoanActive := false;
                        end;
                        CurrPage.Update();
                    end;
                }
                field("Secured Loan"; Rec."Secured Loan")
                {
                    ApplicationArea = All;
                    Editable = isSecureLoanActive;

                }
                field("Secured Loan Other"; Rec."Secured Loan Other")
                {
                    ApplicationArea = All;
                    Editable = isSecureLoanActive;
                    Caption = 'Secure Loan Other Option';

                }
                field("UnSecured Loan"; Rec."UnSecured Loan")
                {
                    ApplicationArea = All;
                    Editable = isUnsecureLoanActive;

                }

                field(FormofSec; Rec.FormofSec)
                {
                    ApplicationArea = All;
                }
                field(PlacementMaturity; Rec.PlacementMaturity)
                {
                    Caption = 'Placement Maturity Term';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                    Caption = 'Operational State';
                    Editable = false;
                    // Visible = Rec.Status = Rec.Status::Approved;
                    ToolTip = 'This shows the Loan is in Operation';
                }
                group("Rollover Details")
                {
                    Visible = IsRollovered;
                    field(Rollovered; Rec.Rollovered)
                    {
                        ApplicationArea = All;
                        Caption = 'Record Origin';
                        Editable = false;
                    }
                    field("Original Record No."; Rec."Original Record No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Rollovered Interest"; Rec."Rollovered Interest")
                    {
                        ApplicationArea = All;
                        Caption = '* Rollovered Interest';
                        ToolTip = 'Applicable only for the case of Rollovered Interest';
                        Editable = false;
                    }
                }


            }
            group("Amortized Interest Advanced Settings")
            {
                //     // Visible = EnableInterestPaymentVisibility;
                field(FirstDueDate; Rec.FirstDueDate)
                {
                    Caption = 'Interest Due Date';
                    ApplicationArea = All;

                }
                field(SecondDueDate; Rec.SecondDueDate)
                {
                    Caption = 'Payment Due Date';
                    ApplicationArea = All;

                }
            }
            group(Encumbrance)
            {
                Visible = EncumberanceView;

                field("Encumbrance Input"; Rec."Encumbrance Input")
                {
                    ApplicationArea = All;
                }
                field("Total Asset Value"; Rec."Total Asset Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Encumbrance Percentage"; Rec."Encumbrance Percentage")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group("Loan Repayment")
            {
                Visible = LoanRepaymentView;

                field("Repayment Frequency"; Rec."Repayment Frequency")
                {
                    ApplicationArea = All;
                }
                field("Repayment Amount"; Rec."Repayment Amount")
                {
                    ApplicationArea = All;
                }
                // field("Repayment interest"; Rec."Repayment interest")
                // {
                //     ApplicationArea = All;
                // }
            }

        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50232),
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
            group("Process Funder Loan")
            {
                Caption = 'Process Funder Loan';
                Image = Interaction;
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
                        funderLedgerEntry.SETRANGE(funderLedgerEntry."Loan No.", Rec."No.");
                        funderLedgerEntry.SetFilter(funderLedgerEntry."Document Type", '<>%1', funderLedgerEntry."Document Type"::"Remaining Amount");
                        PAGE.RUN(PAGE::FunderLedgerEntry, funderLedgerEntry);

                    end;
                }
                action("Compute Interest")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Interaction;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Compute Interest';
                    ToolTip = 'Compute Interest ';
                    trigger OnAction()
                    var
                        funderMgt: Codeunit FunderMgtCU;
                    begin
                        funderMgt.CalculateInterest(Rec."No.");
                    end;
                }
                action("Rollover Record")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Interaction;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Rollover Record';
                    ToolTip = 'Rollover Record';
                    trigger OnAction()
                    var
                        funderMgt: Codeunit FunderMgtCU;
                        RO: Page "Roll over";
                        GFilter: Codeunit GlobalFilters;
                        ROTbl: Record "Roll over Tbl";
                    begin
                        // funderMgt.DuplicateRecord(Rec."No.");
                        //Page.Run(Page::"Roll over", Rec);
                        ROTbl.Reset();
                        ROTbl.DeleteAll();
                        GFilter.SetGlobalLoanFilter(Rec."No.");
                        RO.Run();
                    end;
                }
                action("Redemption Record")
                {
                    ApplicationArea = Basic, Suite;
                    Image = RefreshDiscount;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Redemption Record';
                    ToolTip = 'Redemption Record';
                    trigger OnAction()
                    var
                        funderMgt: Codeunit FunderMgtCU;
                        RD: Page Redemption;
                        GFilter: Codeunit GlobalFilters;
                        RDTbl: Record "Redemption Tbl";
                    begin
                        // funderMgt.DuplicateRecord(Rec."No.");
                        //Page.Run(Page::"Roll over", Rec);
                        RDTbl.Reset();
                        RDTbl.DeleteAll();

                        GFilter.SetGlobalLoanFilter(Rec."No.");
                        RD.Run();
                    end;
                }

                action("Loan Tranche")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Trace;
                    PromotedIsBig = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Loan Tranche';
                    ToolTip = 'Loan Tranche';
                    Enabled = Rec."Tranche Loan" = true;
                    Visible = TranchesView;

                    trigger OnAction()
                    var
                        tranchLoan: Record "Disbur. Tranched Loan";
                        GFilter: Codeunit GlobalFilters;
                    begin
                        GFilter.SetGlobalLoanFilter(Rec."No.");
                        tranchLoan.SETRANGE(tranchLoan."Loan No.", Rec."No.");
                        // tranchLoan.SetFilter(tranchLoan."Document Type", '<>%1', tranchLoan."Document Type"::"Remaining Amount");
                        PAGE.RUN(PAGE::"Disbur. Tranched Loan", tranchLoan);

                    end;
                }

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
                        // // Page.Run(Page::"Portfolio Fee Setup", Rec, Rec."No.");
                        // GFilter.SetGlobalLoanFilter(Rec."No.");
                        // _portfolio.Run();
                        // // _portfolio.SetTableView(Rec);
                        // // _portfolio.run()

                        _portfolioFeeTbl.Reset();
                        _portfolioFeeTbl.SetRange(_portfolioFeeTbl.FunderLoanNo, Rec."No.");
                        Page.Run(Page::"Portfolio Fee Setup", _portfolioFeeTbl);
                    end;
                }
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
                        //Validate Key Fields
                        // Interest Value, Method and Principal
                        if Rec."Original Disbursed Amount" = 0 then
                            Error('Original Disbursed Amount Required');
                        if Rec.InterestRate = 0 then
                            Error('Gross Interest rate (p.a) Required');

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

            group(Communication)
            {
                Caption = 'Communications';
                Image = MapSetup;
                action("Email Send Confirmation")
                {
                    Image = Confirm;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        EmailingCU.SendConfirmationEmailWithAttachment(Rec."No.")
                    end;
                }
                action("Reminder On Placement Maturity")
                {
                    Image = Reminder;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        PlacementReminder: Report "Reminder on Placement Mature";
                        _funderLoan: Record "Funder Loan";
                        EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        //PlacementReminder.Run();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Reminder on Placement Mature", true, false, _funderLoan);
                        // EmailingCU.SendReminderOnPlacementMaturity(Rec."No.")
                    end;
                }
                action("Reminder On Instrest Due")
                {
                    Image = Intercompany;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        EmailingCU.SendReminderOnInterestDue(Rec."No.")
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

            group(Reports)
            {
                action("Amortized Interest")
                {
                    ApplicationArea = All;
                    Caption = 'Amortized Interest';
                    Image = Report2;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    // RunObject = report "Interest Amortization";
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Interest Amortization", true, false, _funderLoan);
                    end;



                }
                action("Amortized Payment")
                {
                    ApplicationArea = All;
                    Caption = 'Amortized Payment';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    RunObject = report "Payment Amortization";
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        // Report.Run(50230, true, false, _funderLoan);
                    end;
                }
                action("Loan Repayment Schedule")
                {
                    ApplicationArea = All;
                    Caption = 'Loan Repayment';
                    Image = Replan;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    RunObject = report "Loan Repayment Schedule";
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        // Report.Run(50230, true, false, _funderLoan);
                    end;
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
                    // RunObject = report "Capitalize Interest";
                    trigger OnAction()
                    var
                        LoanRec: Record "Funder Loan";
                        Capitalizarp: Report "Capitalize Interest";
                    begin
                        LoanRec.SetRange("No.", Rec."No.");
                        Capitalizarp.SetTableView(LoanRec);
                        Capitalizarp.Run();
                    end;
                }
                action("ReEvaluateFX")
                {
                    ApplicationArea = All;
                    Caption = 'ReEvaluateFX';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    // RunObject = report ReEvaluateFX;
                    trigger OnAction()
                    var
                        // Report:Report ReEvaluateFX;
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::ReEvaluateFX, true, false, _funderLoan);

                    end;
                }
            }
            group(Documents)
            {
                action("attachment")
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
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
                action(Confirmation)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Confirmation Document';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Report;
                    // RunObject = report "Investment Confirmation";
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        InvestConfRp: Report "Investment Confirmation";
                        ReportFlag: Record "Report Flags";
                    begin
                        // InvestConfRp.SetFunderNoFilter(Rec."No.");


                        Report.Run(Report::"Investment Confirmation");
                    end;

                }
                action(Redemption)
                {
                    ApplicationArea = All;
                    Caption = 'Redemption Document';
                    Image = MoveNegativeLines;
                    Promoted = true;
                    PromotedCategory = Report;
                    // RunObject = report "Investment Confirmation";
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        RedemptionDoc: Report "Redemption Document";
                        LoanRec: Record "Funder Loan";
                    // ReportFlag: Record "Report Flags";
                    begin
                        LoanRec.SetRange("No.", Rec."No.");
                        RedemptionDoc.SetTableView(LoanRec);
                        RedemptionDoc.Run();
                        // Report.Run(Report::"Investment Confirmation");
                    end;

                }
            }
        }

    }


    trigger OnInit()
    begin
        isCurrencyVisible := true;
        isSecureLoanActive := false;
        isUnsecureLoanActive := true;
        isFloatRate := false;

        _funderNo := GlobalFilters.GetGlobalFilter();
        if _funderNo <> '' then begin
            if FunderTbl.Get(_funderNo) then begin
                if FunderTbl.FunderType = FunderTbl.FunderType::Individual then begin
                    if FunderTbl."Mailing Address" = '' then begin
                        Error('Email Required');
                        exit;
                    end;
                end;
            end;
        end;
    end;

    trigger OnOpenPage()
    var
        ReportFlag: Record "Report Flags";
    begin
        "Region/Country".Reset();
        if "Region/Country".IsEmpty() then begin
            Error('Region/Country must have atleast one entry');
            exit;
        end;
        _funderNo := GlobalFilters.GetGlobalFilter();
        // if _funderNo <> '' then begin
        //     if FunderTbl.Get(_funderNo) then begin
        //         if FunderTbl."Funder Type" = FunderTbl."Funder Type"::Local then
        //             isCurrencyVisible := false;
        //     end;
        // end;
        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then begin
            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
            Rec.Modify();
            isFloatRate := true
        end
        else
            isFloatRate := false;
        //  Rec."Document Number" := TrsyMgt.GenerateDocumentNumber();
        if Rec.SecurityType = Rec.SecurityType::"Senior secured" then begin
            isSecureLoanActive := true;
            isUnsecureLoanActive := false;

        end;

        if Rec.SecurityType = Rec.SecurityType::"Senior Unsecured" then begin
            isUnsecureLoanActive := true;
            isSecureLoanActive := false;
        end;

        ReportFlag.Reset();
        ReportFlag.SetFilter("Line No.", '<>%1', 0);
        ReportFlag.SetFilter("Utilizing User", '=%1', UserId);
        if ReportFlag.Find('-') then begin
            repeat
                ReportFlag.Delete();
            until ReportFlag.Next() = 0;
        end;
        ReportFlag.Init();
        ReportFlag."Funder Loan No." := Rec."No.";
        ReportFlag."Utilizing User" := UserId;
        ReportFlag.Insert();

        if Rec."Payables Account" = '' then
            Rec."Payables Account" := FunderTbl."Payables Account";
        if Rec."Interest Expense" = '' then
            Rec."Interest Expense" := FunderTbl."Interest Expense";
        if Rec."Interest Payable" = '' then
            Rec."Interest Payable" := FunderTbl."Interest Payable";

        UpdateInterestPaymentVisibility();
        FieldEditProp();
        RolloveredChecker();

        EncumberanceView := false;
        LoanRepaymentView := false;
        TranchesView := false;
    end;


    trigger OnNextRecord(Steps: Integer): Integer
    begin
        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then begin
            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
            Rec.Modify();
            isFloatRate := true
        end
        else
            isFloatRate := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        _pportfolio: Record Portfolio;
    begin
        _pportfolio.Reset();
        _pportfolio.SetRange("No.", FunderTbl.Portfolio);
        if not _pportfolio.FindFirst() then
            Error('Portfolio not found %1', FunderTbl.Portfolio);

        if _pportfolio.Category = _pportfolio.Category::"Bank Loan" then
            Rec.Category := UpperCase('Bank Loan');
        if _pportfolio.Category = _pportfolio.Category::Individual then
            Rec.Category := UpperCase('Individual');
        if _pportfolio.Category = _pportfolio.Category::Institutional then
            Rec.Category := UpperCase('Institutional');
        if _pportfolio.Category = _pportfolio.Category::"Asset Term Manager" then
            Rec.Category := UpperCase('Asset Term Manager');
        if _pportfolio.Category = _pportfolio.Category::"Medium Term Notes" then
            Rec.Category := UpperCase('Medium Term Notes');

        Rec."Origin Entry" := Rec."Origin Entry"::Funder;

        // if Rec."Payables Account" = '' then
        //     Rec."Payables Account" := FunderTbl."Payables Account";
        // if Rec."Interest Expense" = '' then
        //     Rec."Interest Expense" := FunderTbl."Interest Expense";
        // if Rec."Interest Payable" = '' then
        //     Rec."Interest Payable" := FunderTbl."Interest Payable";




    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FilterVal: Text[30];
    begin

        if _funderNo <> '' then begin
            Rec."Funder No." := _funderNo;
            Rec.Validate("Funder No.");
            // Rec.Insert();
        end;

    end;

    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        // OpenApprovalEntriesExist := ApprovalsMgmt.HasApprovedApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
        UpdateInterestPaymentVisibility();
        FieldEditProp();
        RolloveredChecker();

        EncumberanceView := Rec.Category = UpperCase('Bank Loan');
        LoanRepaymentView := Rec.Category = UpperCase('Bank Loan');
        TranchesView := (Rec.Category = UpperCase('Institutional')) or (Rec.Category = UpperCase('Bank Loan'));

    end;

    trigger OnAfterGetRecord()
    begin

    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ReportFlag: Record "Report Flags";
    begin
        ReportFlag.Reset();
        ReportFlag.SetFilter("Line No.", '<>%1', 0);
        ReportFlag.SetFilter("Utilizing User", '=%1', UserId);
        if ReportFlag.Find('-') then begin
            repeat
                ReportFlag.Delete();
            until ReportFlag.Next() = 0;
        end;
    end;

    local procedure UpdateInterestPaymentVisibility()
    begin
        EnableInterestPaymentVisibility := Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Quarterly;

    end;

    local procedure FieldEditProp()
    var
    begin
        EditStatus := not (Rec.Status = Rec.Status::Approved);
    end;

    local procedure RolloveredChecker()
    var
    begin
        IsRollovered := (Rec.Rollovered = Rec.Rollovered::"Roll overed");
    end;

    var
        myInt: Integer;
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        GlobalFilters: Codeunit GlobalFilters;
        isCurrencyVisible, isSecureLoanActive, isUnsecureLoanActive, isFloatRate : Boolean;
        _funderNo: Text[30];
        FunderTbl: Record Funders;

        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        PlacementAndMaturityDifference: Integer;
        EnableInterestPaymentVisibility, EncumberanceView, LoanRepaymentView, TranchesView : Boolean;
        "Region/Country": Record Country_Region;
        EditStatus: Boolean;
        IsRollovered: Boolean;

    protected var

    // _docNo: Code[20];
    // TrsyMgt: Codeunit "Treasury Mgt CU";
}