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
            group(GroupName)
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
                }
                field(SupplierSysRefNo; Rec.SupplierSysRefNo)
                {
                    ApplicationArea = All;
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
                field(FundSource; Rec.FundSource)
                {

                    ApplicationArea = All;
                }
                // field(DisbursedCurrency; Rec.DisbursedCurrency)
                // {
                //     Caption = 'Original Amount';
                //     // Visible = false;
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                field(OrigAmntDisbLCY; Rec.OrigAmntDisbLCY)
                {
                    // DrillDown = true;
                    // DrillDownPageId = FunderLedgerEntry;
                    // ToolTip = 'Original Amount';
                    // ApplicationArea = All;
                }

                field(OutstandingAmntDisbLCY; Rec.OutstandingAmntDisbLCY)
                {
                    // // ApplicationArea = Basic, Suite;
                    // // Importance = Promoted;
                    // DrillDown = true;
                    // DrillDownPageId = FunderLedgerEntry;
                    // ToolTip = '';

                    ApplicationArea = All;
                }
                field(InterestRate; Rec.InterestRate)
                {
                    ApplicationArea = All;
                }
                field(InterestMethod; Rec.InterestMethod)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(InterestRateType; Rec.InterestRateType)
                {
                    ApplicationArea = All;
                }
                // field(InterestRepaymentHz; Rec.InterestRepaymentHz)
                // {
                //     ApplicationArea = All;
                // }
                field(GrossInterestamount; Rec.GrossInterestamount)
                {
                    // DrillDown = true;
                    // DrillDownPageId = FunderLedgerEntry;
                    // ToolTip = '';
                    // ApplicationArea = Basic, Suite;
                }

                field(NetInterestamount; Rec.NetInterestamount)
                {
                    // DrillDown = true;
                    // DrillDownPageId = FunderLedgerEntry;
                    // ToolTip = '';
                    // ApplicationArea = Basic, Suite;
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
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FilterVal: Text[30];
    begin
        // SelectedFilterValue := xRec.GETFILTER("Funder No.");
        //Message(SelectedFilterValue);
        FilterVal := GlobalFilters.GetGlobalFilter();
        if FilterVal <> '' then begin
            Rec."Funder No." := FilterVal;
            Rec.Validate("Funder No.");
            rec.Modify();
        end;

    end;

    var
        myInt: Integer;

        GlobalFilters: Codeunit GlobalFilters;
}