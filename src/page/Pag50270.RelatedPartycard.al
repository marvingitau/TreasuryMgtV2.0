page 50270 "Related Party card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = 50248;
    Caption = 'Related Party/Customer';
    DataCaptionFields = "No.", RelatedPName;

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
                field(RelatedPName; Rec.RelatedPName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ShowMandatory = true;
                }
                field(CompanyRegNo; Rec.CompanyRegNo)
                {
                    ApplicationArea = All;
                    Caption = 'Company Registration No.';
                    ShowMandatory = true;
                }
                field(RelatedPSysRefNo; Rec.RelatedPSysRefNo)
                {
                    ApplicationArea = All;
                    Caption = 'System Reference No.';
                }
                field(RelatedPCoupaRef; Rec.RelatedPCoupaRef)
                {
                    ApplicationArea = All;
                    Caption = 'Coupa Reference No.';
                }
                field(PinNo; Rec.PinNo)
                {
                    ApplicationArea = All;
                    Caption = 'KRA Pin No.';
                    ShowMandatory = true;
                }
                field(PlacementDate; Rec.PlacementDate)
                {
                    ApplicationArea = All;
                    Caption = 'Placement Date';
                }
                field(MaturityDate; Rec.MaturityDate)
                {
                    ApplicationArea = All;
                    Caption = 'Maturity Date';
                }

                field(DisbursedCurrency; Rec.Currency)
                {
                    ApplicationArea = All;
                    Caption = 'Currency';
                }
                field("Enable GL Posting"; Rec.EnableGLPosting)
                {
                    ApplicationArea = All;
                }
                field(RelatePSourceOfFund; Rec.RelatePSourceOfFund)
                {
                    ApplicationArea = All;
                    Caption = 'Source of Fund';
                }
                field("Principal Account"; Rec."Principal Account")
                {
                    ApplicationArea = All;
                }
                field("Interest Receivable"; Rec."Interest Receivable")
                {
                    ApplicationArea = All;
                }
                field("Interest Expense"; Rec."Interest Expense")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                }
                field(OutstandingAmntDisbLCY; Rec.OutstandingAmntDisbLCY)
                {
                    DrillDown = true;
                    DrillDownPageId = RelatedLedgerEntry;
                    ApplicationArea = All;
                }
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
                field(InterestRateType; Rec.InterestRateType)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Rate Type';
                }
                field(InterestRatePA; Rec.InterestRatePA)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Rate P.A';
                }
                field(TaxStatus; Rec.TaxStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Tax Status';
                }
                field(Withldtax; Rec.Withldtax)
                {
                    ApplicationArea = All;
                    Caption = 'Withholding Tax';
                }

                field("Reference Rate"; Rec."Reference Rate")
                {
                    ApplicationArea = All;
                    Caption = 'Reference Rate';
                }
                field(Margin; Rec.Margin)
                {
                    ApplicationArea = All;
                }

                field(InterestRepaymentFreq; Rec.InterestRepaymentFreq)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Repayment Frequency';
                }
                field(PrincipleRepaymentFreq; Rec.PrincipleRepaymentFreq)
                {
                    ApplicationArea = All;
                    Caption = 'Principal Repayment Frequency';
                }

                field(InterestMethod; Rec.InterestMethod)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Method';
                }
            }
            group(Contact)
            {
                field(RelatedP_Email; Rec.RelatedP_Email)
                {
                    ApplicationArea = All;
                    Caption = 'Email';
                }
                field(RelatedP_Mobile; Rec.RelatedP_Mobile)
                {
                    ApplicationArea = All;
                    Caption = 'Mobile';
                }
                field(ContactPerson; Rec.ContactPerson)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Person';
                    ShowMandatory = true;
                }
                field(RelatedP_ContactEmail; Rec.RelatedP_ContactEmail)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Email';
                }
            }
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
                    Caption = 'Related Ledgers';
                    Image = LedgerEntries;
                    PromotedCategory = Process;
                    Promoted = true;
                    // RunObject = Page "Funder Loans List";
                    //RunPageLink = "Funder No." = FIELD("No.");
                    trigger OnAction()
                    var
                        relatedLedger: Record RelatedLedgerEntry;
                    begin
                        relatedLedger.SETRANGE(relatedLedger."RelatedParty No.", Rec."No.");
                        relatedLedger.SetFilter(relatedLedger."Document Type", '<>%1', relatedLedger."Document Type"::"Remaining Amount");
                        PAGE.RUN(PAGE::RelatedLedgerEntry, relatedLedger);
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
                        relateMgtCU: Codeunit "RelatedCustomer Mgt CU";
                    begin
                        relateMgtCU.CalculateInterest(Rec."No.");
                    end;
                }
                // action("Rollover Record")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Image = Interaction;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     Caption = 'Rollover Record';
                //     ToolTip = 'Rollover Record';
                //     trigger OnAction()
                //     var
                //         funderMgt: Codeunit FunderMgtCU;
                //     begin
                //         funderMgt.DuplicateRecord(Rec."No.");
                //     end;
                // }
            }

        }
        area(Reporting)
        {
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
                    RunObject = report "Interest Amortization Related";

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
                    RunObject = report "Payment Amortization Related";

                }
            }

        }
    }
    trigger OnOpenPage()
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
        ReportFlag.Init();
        ReportFlag."Related Party No" := Rec."No.";
        ReportFlag."Utilizing User" := UserId;
        ReportFlag.Insert();
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

    var
        myInt: Integer;
}