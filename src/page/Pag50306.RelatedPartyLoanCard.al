page 50306 "RelatedParty Loan Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "RelatedParty Loan";

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
                field("Funder No."; Rec."RelatedParty No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'RelatedParty No.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'RelatedParty Name';
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
                    Editable = EditStatus;
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
                    Editable = EditStatus;
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
                    Caption = 'Paying Bank Account';
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field(Currency; Rec.Currency)
                {
                    Caption = 'Currency';
                    // Visible = false;
                    ApplicationArea = All;
                    Editable = EditStatus;
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
                    Editable = EditStatus;
                }
                group("G/L Mapping")
                {
                    Editable = EditStatus;
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
                        Caption = 'Interest Income';
                    }
                    field("Interest Payable"; Rec."Interest Payable")
                    {

                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Interest Receivable';
                    }
                }
                field("Total Payed"; Rec."Total Payed")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Tranche Loan";
                    Editable = EditStatus;
                    // Editable = not (Rec.Status = Rec.Status::Approved);
                    ToolTip = 'This indicates the Total to Be Payed under Tranches Loan';
                    Caption = 'Total facility amount on Tranche loans';

                }
                field("Original Disbursed Amount"; Rec."Original Disbursed Amount")
                {
                    ApplicationArea = All;
                    // Editable = not (Rec.Status = Rec.Status::Approved);
                    Editable = EditStatus;
                    Caption = 'Original / First disbursement Amount';
                }
                // field(OrigAmntDisbLCY; Rec.OrigAmntDisbLCY)
                // {
                //     DrillDown = true;
                //     DrillDownPageId = RelatedLedgerEntry;
                //     ApplicationArea = All;
                //     Caption = 'Original Amount Disbursed';
                // }

                field(OutstandingAmntDisbLCY; Rec.OutstandingAmntDisbLCY)
                {
                    // ApplicationArea = Basic, Suite;
                    // Importance = Promoted;
                    DrillDown = true;
                    DrillDownPageId = RelatedLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Outstanding Amount';
                }
                field("Outstanding Interest"; Rec."Outstanding Interest")
                {
                    // ApplicationArea = Basic, Suite;
                    // Importance = Promoted;
                    DrillDown = true;
                    DrillDownPageId = RelatedLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Outstanding Interest';
                }
                field("Withholding Tax Amount"; Rec."Withholding Tax Amount")
                {
                    DrillDown = true;
                    DrillDownPageId = RelatedLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Withholding Amount';
                }
                field(InterestMethod; Rec.InterestMethod)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field(TaxStatus; Rec.TaxStatus)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    Caption = 'Tax status (Tax Exempt or Taxable)';
                }

                field(Withldtax; Rec.Withldtax)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    Caption = 'Withholding tax applied (%)';
                }
                field(InterestRateType; Rec.InterestRateType)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
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
                    // Editable = not isFloatRate;
                    Editable = EditStatus and (not isFloatRate);
                    Caption = 'Gross Interest rate (p.a)';
                }
                field(NetInterestRate; Rec.NetInterestRate)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    Caption = 'Net Interest Rate';
                }
                group(FloatInterestFields)
                {
                    Caption = 'Float Rate Related Fields';
                    ShowCaption = true;
                    Editable = EditStatus;
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
                    DrillDownPageId = RelatedLedgerEntry;
                    ToolTip = '';
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Interest';

                }

                field(NetInterestamount; Rec.NetInterestamount)
                {
                    DrillDown = true;
                    DrillDownPageId = RelatedLedgerEntry;
                    ToolTip = '';
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Interest';
                }
                field(PeriodicPaymentOfInterest; Rec.PeriodicPaymentOfInterest)
                {
                    Editable = EditStatus;
                    Caption = '*Payment Period (Interest) ';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        //Check placement date for the interest amortization
                        if Rec.PlacementDate = 0D then
                            Error('Please populate Placement Date first.');
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Monthly then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                            // Rec."Inclusive Counting Interest" := false;
                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Quarterly then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetQuarterClosingDate(Rec.PlacementDate);
                            // Rec."Inclusive Counting Interest" := false;
                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Biannually then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetBiannualClosingDate(Rec.PlacementDate);
                            // Rec."Inclusive Counting Interest" := false;
                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Annually then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetYearEndClosingDate(Rec.PlacementDate);
                            // Rec."Inclusive Counting Interest" := false;
                        end;

                        UpdateInterestPaymentVisibility();

                        // CurrPage.Update();
                    end;


                }

                field(PeriodicPaymentOfPrincipal; Rec.PeriodicPaymentOfPrincipal)
                {
                    Editable = EditStatus;
                    Caption = '*Payment Period (Principal) ';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        //Check placement date for the interest amortization
                        if Rec.PlacementDate = 0D then
                            Error('Please populate Placement Date first.');
                        if Rec.MaturityDate = 0D then
                            Error('Please populate Maturity Date first.');

                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Monthly then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Quarterly then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetQuarterClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Biannually then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetBiannualClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Annually then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetYearEndClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::"Total at Due Date" then begin
                            Rec.SecondDueDate := Rec.MaturityDate;
                        end;

                    end;

                }


                // field(InvestmentTenor; Rec.InvestmentTenor)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Investment Tenor (Months)';
                // }
                field(InvstPINNo; Rec.InvstPINNo)
                {
                    Editable = EditStatus;
                    ApplicationArea = All;
                }
                field("Enable GL Posting"; Rec.EnableGLPosting)
                {
                    Editable = EditStatus;
                    ApplicationArea = All;
                }
                // field("Tranche Loan"; Rec."Tranche Loan")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Is this loan a Tranched Loan';
                //     Editable = TranchesView;
                // }

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
                    Editable = EditStatus;
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
                    Editable = EditStatus and isSecureLoanActive;
                    // Editable = isSecureLoanActive;

                }
                field("Secured Loan Other"; Rec."Secured Loan Other")
                {
                    ApplicationArea = All;
                    // Editable = isSecureLoanActive;
                    Editable = EditStatus and isSecureLoanActive;
                    Caption = 'Secure Loan Other Option';

                }
                field("UnSecured Loan"; Rec."UnSecured Loan")
                {
                    ApplicationArea = All;
                    // Editable = isUnsecureLoanActive;
                    Editable = EditStatus and isUnsecureLoanActive;

                }

                field(FormofSec; Rec.FormofSec)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field(PlacementMaturity; Rec.PlacementMaturity)
                {
                    Caption = 'Placement Maturity Term';
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    Editable = EditStatus;
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
                    Editable = EditStatus;
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
            // group("Amortized Interest Advanced Settings")
            // {
            //     //     // Visible = EnableInterestPaymentVisibility;
            //     field(FirstDueDate; Rec.FirstDueDate)
            //     {
            //         Caption = 'Interest Due Date';
            //         ApplicationArea = All;

            //     }
            //     field(SecondDueDate; Rec.SecondDueDate)
            //     {
            //         Caption = 'Payment Due Date';
            //         ApplicationArea = All;

            //     }
            // }
            group("Intrest Amortization Settings") //Amortized Interest Advanced
            {
                Editable = EditStatus;
                Visible = not isOverdraftLoan;
                //     // Visible = EnableInterestPaymentVisibility;
                field(FirstDueDate; Rec.FirstDueDate)
                {
                    Caption = 'Interest Due Date';
                    ApplicationArea = All;
                    // Editable = EditStatus;
                    ShowMandatory = true;

                }

                field("Enable Dynamic Period"; Rec.EnableDynamicPeriod)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }
                field("Enable WeekDay Reporting"; Rec.EnableWeekDayReporting)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }

                // field("Inclusive Counting Interest"; Rec."Inclusive Counting Interest")
                // {
                //     Caption = 'Inclusive counting';
                //     ToolTip = 'Including both start and end dates';
                //     ApplicationArea = All;
                //     Visible = false;


                // }
            }

            group("Payment Amortization Settings") //Amortized Interest Advanced
            {
                Editable = EditStatus;
                Visible = not isOverdraftLoan;
                //     // Visible = EnableInterestPaymentVisibility;
                // field(FirstDueDate; Rec.FirstDueDate)
                // {
                //     Caption = 'Interest Due Date';
                //     ApplicationArea = All;
                //     Editable = EditStatus;
                //     ShowMandatory = true;

                // }
                field(SecondDueDate; Rec.SecondDueDate)
                {
                    Caption = 'Principal Payment Due Date';
                    ApplicationArea = All;
                    // Editable = EditStatus;
                    ShowMandatory = true;

                }

                field("Enable Dynamic Period P"; Rec.EnableDynamicPeriod_Payment)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }
                field("Enable WeekDay Reporting P"; Rec.EnableWeekDayReporting_Payment)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }
                // field("Add Day to End Period"; Rec."Add Day to Start Period")
                // {
                //     Caption = 'Add One (1) day to Start Date';
                //     ApplicationArea = All;
                //     // Editable = EditStatus;


                // }

            }


            group(Encumbrance)
            {
                Editable = EditStatus;
                Visible = EncumberanceView;

                field("Encumbrance Percentage"; Rec."Encumbrance Percentage")
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field("Encumbrance Input"; Rec."Encumbrance Input")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                // field("Total Asset Value"; Rec."Total Asset Value")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }

            }
            group("Loan Repayment")
            {
                Editable = EditStatus;
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
                action("Related Ledger Entry")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Relatedparty Ledger';
                    Image = LedgerEntries;
                    PromotedCategory = Process;
                    Promoted = true;
                    // RunObject = Page "Funder Loans List";
                    //RunPageLink = "Funder No." = FIELD("No.");
                    trigger OnAction()
                    var
                        RelatedLedgerEntry: Record RelatedLedgerEntry;
                    begin
                        RelatedLedgerEntry.SETRANGE(RelatedLedgerEntry."Loan No.", Rec."No.");
                        RelatedLedgerEntry.SetFilter(RelatedLedgerEntry."Document Type", '<>%1', RelatedLedgerEntry."Document Type"::"Remaining Amount");
                        PAGE.RUN(PAGE::RelatedLedgerEntry, RelatedLedgerEntry);

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
                        relatedMgt: Codeunit RelatepartyMgtCU;
                    begin
                        relatedMgt.CalculateInterest(Rec."No.");
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
                    Visible = false;
                    trigger OnAction()
                    var
                        funderMgt: Codeunit FunderMgtCU;
                        RO: Page "RelatedParty Roll over";
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
                    Visible = false;
                    trigger OnAction()
                    var
                        RD: Page "Relatedparty Redemption";
                        GFilter: Codeunit GlobalFilters;
                        RDTbl: Record "Redemption Tbl";
                    begin
                        RDTbl.Reset();
                        RDTbl.DeleteAll();

                        GFilter.SetGlobalLoanFilter(Rec."No.");
                        RD.Run();
                    end;
                }

                // action("Loan Tranche")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Image = Trace;
                //     PromotedIsBig = true;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     Caption = 'Loan Tranche';
                //     ToolTip = 'Loan Tranche';
                //     Enabled = Rec."Tranche Loan" = true;
                //     Visible = TranchesView;

                //     trigger OnAction()
                //     var
                //         tranchLoan: Record "Disbur. Tranched Loan";
                //         GFilter: Codeunit GlobalFilters;
                //     begin
                //         GFilter.SetGlobalLoanFilter(Rec."No.");
                //         tranchLoan.SETRANGE(tranchLoan."Loan No.", Rec."No.");
                //         // tranchLoan.SetFilter(tranchLoan."Document Type", '<>%1', tranchLoan."Document Type"::"Remaining Amount");
                //         PAGE.RUN(PAGE::"Disbur. Tranched Loan", tranchLoan);

                //     end;
                // }

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
                        _portfolioFeeTbl.Reset();
                        _portfolioFeeTbl.SetRange(_portfolioFeeTbl.RelatedPartyLoanNo, Rec."No.");
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
                        CustomWorkflowMgmt: Codeunit "Relatedparty Loan Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        //Validate Key Fields
                        // Interest Value, Method and Principal
                        if Rec."Original Disbursed Amount" = 0 then
                            Error('Original Disbursed Amount Required');
                        // if Rec.InterestRate = 0 then
                        //     Error('Gross Interest rate (p.a) Required');

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
                        CustomWorkflowMgmt: Codeunit "Relatedparty Loan Approval Mgt";
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
                        CustomWorkflowMgmt: Codeunit "Relatedparty Loan Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
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
                    Visible = false;
                    trigger OnAction()
                    var
                        EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        EmailingCU.SendConfirmationEmailWithAttachmentRelatedParty(Rec."No.")
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
                        PlacementReminder: Report "Related Rem. on Plac. Mature";
                        _relatedPartyLoan: Record "RelatedParty Loan";
                    // EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        CurrPage.SetSelectionFilter(Rec);
                        Report.Run(Report::"Related Rem. on Plac. Mature", true, false, Rec);
                        // PlacementReminder.SetTableView(Rec);
                        // PlacementReminder.Run();
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
                        EmailingCU.SendReminderOnInterestDueRelatedParty(Rec."No.")
                    end;
                }
                action("Reminder On Instrest Due Doc")
                {
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        EmailingCU: Codeunit "Treasury Emailing";
                        PlacementReminder: Report "Related Rem. On Intr. Due";
                    begin
                        // CurrPage.SetSelectionFilter(Rec);
                        // Report.Run(Report::"Related Rem. On Intr. Due", true, false, Rec);
                        PlacementReminder.SetTableView(Rec);
                        PlacementReminder.Run();
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
                        _relatedLoan: Record "RelatedParty Loan";
                    begin
                        _relatedLoan.Reset();
                        _relatedLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Interest Amortization Related", true, false, _relatedLoan);
                    end;

                }
                action("Amortized Payment")
                {
                    ApplicationArea = All;
                    Caption = 'Amortized Payment';
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        _relatedLoan: Record "RelatedParty Loan";
                    begin
                        _relatedLoan.Reset();
                        _relatedLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Payment Amortization Related", true, false, _relatedLoan);
                    end;
                }
                action("Loan Repayment Schedule")
                {
                    ApplicationArea = All;
                    Caption = 'Loan Repayment';
                    Image = Replan;
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var

                    begin
                        CurrPage.SetSelectionFilter(Rec);
                        Report.Run(Report::"Related Loan Rep. Sch.", true, false, Rec);
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
                        LoanRec: Record "RelatedParty Loan";
                        Capitalizarp: Report "Related Capitalize Interest";
                    begin
                        LoanRec.SetRange("No.", Rec."No.");
                        Capitalizarp.SetTableView(LoanRec);
                        Capitalizarp.Run();
                    end;
                }
                // action("ReEvaluateFX")
                // {
                //     ApplicationArea = All;
                //     Caption = 'ReEvaluateFX';
                //     Image = Report;
                //     // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                //     Promoted = true;
                //     PromotedCategory = Report;
                //     PromotedIsBig = true;
                //     // RunObject = report ReEvaluateFX;
                //     trigger OnAction()
                //     var
                //         // Report:Report ReEvaluateFX;
                //         _relatedLoan: Record "Funder Loan";
                //     begin
                //         _relatedLoan.Reset();
                //         _relatedLoan.SetRange("No.", Rec."No.");
                //         Report.Run(Report::ReEvaluateFX, true, false, _relatedLoan);

                //     end;
                // }
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
                    PromotedIsBig = true;
                    Visible = false;
                    trigger OnAction()
                    var
                        InvestConfRp: Report "Investment Confirmation";
                        ReportFlag: Record "Report Flags";
                    begin
                        // Get the current record
                        CurrPage.SetSelectionFilter(Rec);
                        // Pass the record directly to the report
                        Report.Run(Report::"RelatedParty Invest. Conf.", true, false, Rec);
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
                    Visible = false;
                    trigger OnAction()
                    var
                        RedemptionDoc: Report "Redemption Document";
                        LoanRec: Record "RelatedParty Loan";
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

        _relatedPartyNo := GlobalFilters.GetGlobalFilter();
        if _relatedPartyNo <> '' then begin
            if RelatedPartyTbl.Get(_relatedPartyNo) then begin
                if RelatedPartyTbl.FunderType = RelatedPartyTbl.FunderType::Individual then begin
                    if RelatedPartyTbl."Mailing Address" = '' then begin
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
        _relatedPartyNo := GlobalFilters.GetGlobalFilter();
        if not RelatedPartyTbl.Get(_relatedPartyNo) then
            exit;
        // Error('Relatedparty not found');
        // if _relatedPartyNo <> '' then begin
        //     if RelatedPartyTbl.Get(_relatedPartyNo) then begin
        //         if RelatedPartyTbl.FunderType = RelatedPartyTbl.FunderType::Local then
        //             isCurrencyVisible := false;
        //     end;
        // end;

        /*
        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then begin
            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
            Rec.Modify();
            isFloatRate := true
        end
        else
            isFloatRate := false;
        */

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

        // if Rec."Payables Account" = '' then
        //     Rec."Payables Account" := RelatedPartyTbl."Payables Account";
        // if Rec."Interest Expense" = '' then
        //     Rec."Interest Expense" := RelatedPartyTbl."Interest Expense";
        // if Rec."Interest Payable" = '' then
        //     Rec."Interest Payable" := RelatedPartyTbl."Interest Payable";

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
        Relatedportfolio: Record "Portfolio RelatedParty";
    begin
        Relatedportfolio.Reset();
        Relatedportfolio.SetRange("No.", RelatedPartyTbl.Portfolio);
        if not Relatedportfolio.FindFirst() then
            Error('Relatedportfolio not found %1', RelatedPartyTbl.Portfolio);

        if Relatedportfolio.Category = Relatedportfolio.Category::"Bank Loan" then
            Rec.Category := UpperCase('Bank Loan');
        if Relatedportfolio.Category = Relatedportfolio.Category::Individual then
            Rec.Category := UpperCase('Individual');
        if Relatedportfolio.Category = Relatedportfolio.Category::Institutional then
            Rec.Category := UpperCase('Institutional');
        if Relatedportfolio.Category = Relatedportfolio.Category::"Asset Term Manager" then
            Rec.Category := UpperCase('Asset Term Manager');
        if Relatedportfolio.Category = Relatedportfolio.Category::"Medium Term Notes" then
            Rec.Category := UpperCase('Medium Term Notes');

        Rec."Origin Entry" := Rec."Origin Entry"::RelatedParty;

        if RelatedPartyTbl."Payables Account" = '' then begin
            Error('Principal Account missing');
            exit;
        end;
        if RelatedPartyTbl."Interest Expense" = '' then begin
            Error('Interest Expense Account missing');
            exit;
        end;
        if RelatedPartyTbl."Interest Payable" = '' then begin
            Error('Interest Payable Account missing');
            exit;
        end;

        if Rec."Payables Account" = '' then
            Rec."Payables Account" := RelatedPartyTbl."Payables Account";
        if Rec."Interest Expense" = '' then
            Rec."Interest Expense" := RelatedPartyTbl."Interest Expense";
        if Rec."Interest Payable" = '' then
            Rec."Interest Payable" := RelatedPartyTbl."Interest Payable";




    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FilterVal: Text[30];
    begin

        if _relatedPartyNo <> '' then begin
            // GenSetup.Get(1);
            // GenSetup.TestField("Funder Loan No.");
            // if Rec."No." = '' then
            //     Rec."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true);
            Rec."RelatedParty No." := _relatedPartyNo;
            Rec.Validate("RelatedParty No.");
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
        isOverdraftLoan := Rec.Category = UpperCase('Bank Overdraft')
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
        EditStatus := (Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Rejected);
    end;

    local procedure RolloveredChecker()
    var
    begin
        IsRollovered := (Rec.Rollovered = Rec.Rollovered::"Roll overed");
    end;

    var
        myInt: Integer;
        GenSetup: Record "Treasury General Setup";
        TreasuryMgtCU: Codeunit "Treasury Mgt CU";
        NoSer: Codeunit "No. Series";
        GlobalFilters: Codeunit GlobalFilters;
        isCurrencyVisible, isSecureLoanActive, isUnsecureLoanActive, isFloatRate, isOverdraftLoan : Boolean;
        _relatedPartyNo: Text[30];
        RelatedPartyTbl: Record RelatedParty;

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