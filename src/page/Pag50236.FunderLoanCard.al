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
                field(FundSource; Rec.FundSource)
                {

                    ApplicationArea = All;
                    Caption = 'Bank';
                }
                field(Currency; Rec.Currency)
                {
                    Caption = 'Currency';
                    // Visible = false;
                    ApplicationArea = All;
                    // Editable = false;
                    Visible = isCurrencyVisible;
                    ShowMandatory = isCurrencyVisible;
                }
                field(OrigAmntDisbLCY; Rec.OrigAmntDisbLCY)
                {
                    // DrillDown = true;
                    // DrillDownPageId = FunderLedgerEntry;
                    // ToolTip = 'Original Amount';
                    ApplicationArea = All;
                    Caption = 'Original Amount Disbursed';
                }

                field(OutstandingAmntDisbLCY; Rec.OutstandingAmntDisbLCY)
                {
                    // // ApplicationArea = Basic, Suite;
                    // // Importance = Promoted;
                    // DrillDown = true;
                    // DrillDownPageId = FunderLedgerEntry;
                    // ToolTip = '';

                    ApplicationArea = All;
                    Caption = 'Outstanding Amount';
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
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Interest';
                }

                field(NetInterestamount; Rec.NetInterestamount)
                {
                    // DrillDown = true;
                    // DrillDownPageId = FunderLedgerEntry;
                    // ToolTip = '';
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

    var
        myInt: Integer;
        GenSetup: Record "General Setup";
        NoSer: Codeunit "No. Series";
        GlobalFilters: Codeunit GlobalFilters;
        isCurrencyVisible: Boolean;
        _funderNo: Text[30];
        FunderTbl: Record Funders;
}