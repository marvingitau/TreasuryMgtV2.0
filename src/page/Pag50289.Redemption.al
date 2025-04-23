page 50289 Redemption
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = 50290;

    Caption = 'Redemption Operation';

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
                field("Redemption Type"; Rec.RedemptionType)
                {
                    ApplicationArea = All;
                }
                field("Redemption Date"; Rec."Redemption Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        // if Rec."Redemption Date" <> 0D then begin
                        //     // Check if any interest for this loan has been computed for this month.
                        //     // if so reverse it and use the redemption date as Maturity date.
                        //     TrsyMgtCU.CheckIfAnyInterestWasCalculatedForThisMonth(Rec."Redemption Date", Rec."Loan No.");

                        //     //Get the Actual Float available for redemption
                        //     FunderLoan.Reset();
                        //     FunderLoan.SetRange("No.", LoanID);
                        //     if not FunderLoan.Find('-') then
                        //         Error('Funder Loan No %1 Not found', LoanID);

                        //     FunderLoan.CalcFields("Final Float");
                        //     Rec.Amount := FunderLoan."Final Float";
                        // end;
                    end;

                }
                field(PayingBank; Rec.PayingBank)
                {
                    ApplicationArea = All;
                    Caption = 'Paying Bank';
                    ShowMandatory = true;
                }
                field(PrincipalAmount; Rec.PrincipalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Princical Amount';
                    Editable = not (Rec.RedemptionType = Rec.RedemptionType::"Full Redemption");
                }
                field(InterestAmount; Rec.InterestAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Amount';
                    Editable = not (Rec.RedemptionType = Rec.RedemptionType::"Full Redemption");

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Redemption Process")
            {
                ApplicationArea = Basic, Suite;
                Image = GeneralLedger;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Redemption Process';
                ToolTip = 'Redemption Process';
                trigger OnAction()
                var
                    funderMgt: Codeunit FunderMgtCU;
                    RD: Page Redemption;
                    GFilter: Codeunit GlobalFilters;
                    RDTbl: Record "Redemption Tbl";
                begin
                    if not Confirm('Are you sure, this process is permanent', false) then
                        exit;

                    if (Rec."Redemption Date" <> 0D) and (Rec.PayingBank <> '') then begin
                        // Check if any interest for this loan has been computed for this month.
                        // if so reverse it and use the redemption date as Maturity date.
                        TrsyMgtCU.CheckIfAnyInterestWasCalculatedForThisMonth(Rec."Redemption Date", Rec."Loan No.", Rec.PayingBank);

                        //Get the Actual Float available for redemption
                        FunderLoan.Reset();
                        FunderLoan.SetRange("No.", LoanID);
                        if not FunderLoan.Find('-') then
                            Error('Funder Loan No %1 Not found', LoanID);

                        FunderLoan.CalcFields(OutstandingAmntDisbLCY);
                        Rec.PrincipalAmount := FunderLoan.OutstandingAmntDisbLCY;
                        FunderLoan.CalcFields("Outstanding Interest");
                        Rec.InterestAmount := FunderLoan."Outstanding Interest";

                        RedemptionLog.Init();
                        RedemptionLog."Loan No." := Rec."Loan No.";
                        if Rec.RedemptionType = Rec.RedemptionType::"Full Redemption" then
                            RedemptionLog.RedemptionType := RedemptionLog.RedemptionType::"Full Redemption";
                        if Rec.RedemptionType = Rec.RedemptionType::"Partial Redemption" then
                            RedemptionLog.RedemptionType := RedemptionLog.RedemptionType::"Partial Redemption";
                        RedemptionLog.PrincAmountRemoved := Rec.PrincipalAmount;
                        RedemptionLog.IntrAmountRemoved := Rec.InterestAmount;
                        RedemptionLog."Redemption Date" := Rec."Redemption Date";
                        RedemptionLog.PayingBank := Rec.PayingBank;
                        RedemptionLog.Insert();

                    end else
                        Error('Redemption Date/Bank missing');
                end;
            }
            // action("Redemption Process")
            // {
            //     ApplicationArea = Basic, Suite;
            //     Image = Interaction;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     Caption = 'Redemption Process';
            //     ToolTip = 'Redemption Process';
            //     trigger OnAction()
            //     var
            //         funderMgt: Codeunit FunderMgtCU;
            //         RD: Page Redemption;
            //         GFilter: Codeunit GlobalFilters;
            //         RDTbl: Record "Redemption Tbl";
            //     begin
            //         // funderMgt.DuplicateRecord(Rec.Line);
            //     end;
            // }
        }
    }

    trigger OnInit()
    begin
        if Rec.IsEmpty() then begin
            LoanID := GFilter.GetGlobalLoanFilter();
            FunderLoan.Reset();
            FunderLoan.SetRange("No.", LoanID);
            if not FunderLoan.Find('-') then
                Error('Funder Loan No %1 Not found', LoanID);

            // FunderLoan.CalcFields("Final Float");
            // Rec.Amount := FunderLoan."Final Float";
            Rec."Loan No." := LoanID;

            Rec.Insert();
        end;

    end;

    trigger OnOpenPage()
    begin


    end;

    var
        LoanID: Code[20];
        GFilter: Codeunit GlobalFilters;
        FunderLoan: Record "Funder Loan";
        AmountEnabled: Boolean;
        TrsyMgtCU: Codeunit "Treasury Mgt CU";
        RedemptionLog: Record "Redemption Log Tbl";

}