page 50308 "Relatedparty Redemption"
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
                    var
                        funderLegderEntry: Record FunderLedgerEntry;
                        funderLegderEntry_1: Record FunderLedgerEntry;
                        funderLegderEntry_2: Record FunderLedgerEntry;
                        startMonth: Date;
                        endMonth: date;
                        monthNo: Integer;
                        yearNo: Integer;
                        recondsCount: Integer;
                        funder: Record Funders;

                        NextEntryNo: Integer;

                        TotalInterestAmount: Decimal;
                        TotalAdjustedInterestAmount: Decimal;
                        ThisMonthsIntrest: Decimal;
                        ThisMonthsAdjustedInterest: Decimal;
                    begin
                        if (Rec."Redemption Date" <> 0D) and (Rec.RedemptionType = Rec.RedemptionType::"Partial Redemption") then begin
                            // Check if any interest for this loan has been computed for this month.
                            // if so reverse it and use the redemption date as Maturity date.

                            startMonth := CalcDate('<-CM>', Rec."Redemption Date");
                            endMonth := CalcDate('<+CM>', Rec."Redemption Date");

                            funderLegderEntry_1.Reset();
                            funderLegderEntry_1.SetRange("Loan No.", LoanID);
                            funderLegderEntry_1.SetRange("Document Type", funderLegderEntry."Document Type"::Interest);
                            funderLegderEntry_1.SetRange("Posting Date", startMonth, endMonth);
                            if funderLegderEntry_1.Find('-') then begin
                                ThisMonthsIntrest := funderLegderEntry_1.Amount;
                            end;

                            ThisMonthsAdjustedInterest := RelatedPartyMgtCU.CalculateFloatInterest(LoanID, Rec."Redemption Date");

                            //Get the Actual Float available for redemption
                            FunderLoan.Reset();
                            FunderLoan.SetRange("No.", LoanID);
                            if not FunderLoan.Find('-') then
                                Error('Funder Loan No %1 Not found', LoanID);

                            // FunderLoan.CalcFields("Final Float");
                            // TotalInterestAmount := FunderLoan."Final Float";
                            FunderLoan.CalcFields("Outstanding Interest");
                            TotalInterestAmount := FunderLoan."Outstanding Interest";
                            TotalAdjustedInterestAmount := TotalInterestAmount - ThisMonthsIntrest + ThisMonthsAdjustedInterest;

                            FunderLoan.CalcFields(OutstandingAmntDisbLCY);
                            Rec.FloatPrinci := FunderLoan.OutstandingAmntDisbLCY;
                            // FunderLoan.CalcFields("Outstanding Interest");
                            Rec.FloatIntr := TotalAdjustedInterestAmount;
                            Rec.FloatIntrPlusFloatPrinci := Rec.FloatPrinci + Rec.FloatIntr;
                        end;
                    end;

                }
                group("Partial Redemption Values")
                {
                    Visible = Rec.RedemptionType = Rec.RedemptionType::"Partial Redemption";
                    field(FloatIntr; Rec.FloatIntr)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Current Interest';
                    }
                    field(FloatPrinci; Rec.FloatPrinci)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Current Principal ';
                    }
                    field(FloatIntrPlusFloatPrinci; Rec.FloatIntrPlusFloatPrinci)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Amount';
                    }
                }
                field(PayingBank; Rec.PayingBank)
                {
                    ApplicationArea = All;
                    Caption = 'Paying Bank';
                    ShowMandatory = true;
                }
                // field(PrincipalAmount; Rec.PrincipalAmount)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Princical Amount';
                //     Editable = not (Rec.RedemptionType = Rec.RedemptionType::"Full Redemption");
                // }
                // field(InterestAmount; Rec.InterestAmount)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Interest Amount';
                //     Editable = not (Rec.RedemptionType = Rec.RedemptionType::"Full Redemption");

                // }
                field(PartialAmount; Rec.PartialAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Partial Amount';
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
                        if Rec.RedemptionType = Rec.RedemptionType::"Full Redemption" then begin
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

                            RedemptionLog.Reset();
                            RedemptionLog.SetRange("Loan No.", LoanID);
                            RedemptionLog.SetRange(RedemptionLog.RedemptionType, RedemptionLog.RedemptionType::"Partial Redemption");
                            if RedemptionLog.Find('-') then begin
                                RedemptionLog.PrincAmountRemoved := Rec.PrincipalAmount;
                                RedemptionLog.IntrAmountRemoved := Rec.InterestAmount;
                                RedemptionLog.AmountRemoved := Rec.PrincipalAmount + Rec.InterestAmount;
                                RedemptionLog."Redemption Date" := Rec."Redemption Date";
                                RedemptionLog.PayingBank := Rec.PayingBank;
                                RedemptionLog.Modify();
                            end else begin
                                RedemptionLog.Init();
                                RedemptionLog."Loan No." := Rec."Loan No.";
                                if Rec.RedemptionType = Rec.RedemptionType::"Full Redemption" then
                                    RedemptionLog.RedemptionType := RedemptionLog.RedemptionType::"Full Redemption";
                                if Rec.RedemptionType = Rec.RedemptionType::"Partial Redemption" then
                                    RedemptionLog.RedemptionType := RedemptionLog.RedemptionType::"Partial Redemption";
                                RedemptionLog.PrincAmountRemoved := Rec.PrincipalAmount;
                                RedemptionLog.IntrAmountRemoved := Rec.InterestAmount;
                                RedemptionLog.AmountRemoved := Rec.PrincipalAmount + Rec.InterestAmount;
                                RedemptionLog."Redemption Date" := Rec."Redemption Date";
                                RedemptionLog.PayingBank := Rec.PayingBank;
                                RedemptionLog.Insert();
                            end;



                            FunderLoan.State := FunderLoan.State::Terminated;
                            FunderLoan.Modify();
                        end;
                        if Rec.RedemptionType = Rec.RedemptionType::"Partial Redemption" then begin

                            FunderLoan.Reset();
                            FunderLoan.SetRange("No.", LoanID);
                            if not FunderLoan.Find('-') then
                                Error('Funder Loan No %1 Not found', LoanID);

                            RedemptionLog.Reset();
                            RedemptionLog.SetRange("Loan No.", LoanID);
                            RedemptionLog.SetRange(RedemptionLog.RedemptionType, RedemptionLog.RedemptionType::"Partial Redemption");
                            if RedemptionLog.Find('-') then begin
                                RedemptionLog.PrincAmountRemoved := Rec.PrincipalAmount;
                                RedemptionLog.IntrAmountRemoved := Rec.InterestAmount;
                                RedemptionLog.AmountRemoved := Rec.PartialAmount;
                                RedemptionLog."Redemption Date" := Rec."Redemption Date";
                                RedemptionLog.PayingBank := Rec.PayingBank;
                                RedemptionLog.FloatingPrinc := Rec.FloatPrinci;
                                RedemptionLog.FloatingIntr := Rec.FloatIntr;
                                RedemptionLog.Modify();
                            end else begin
                                RedemptionLog.Init();
                                RedemptionLog."Loan No." := Rec."Loan No.";
                                if Rec.RedemptionType = Rec.RedemptionType::"Full Redemption" then
                                    RedemptionLog.RedemptionType := RedemptionLog.RedemptionType::"Full Redemption";
                                if Rec.RedemptionType = Rec.RedemptionType::"Partial Redemption" then
                                    RedemptionLog.RedemptionType := RedemptionLog.RedemptionType::"Partial Redemption";
                                RedemptionLog.PrincAmountRemoved := Rec.PrincipalAmount;
                                RedemptionLog.IntrAmountRemoved := Rec.InterestAmount;
                                RedemptionLog.AmountRemoved := Rec.PartialAmount;
                                RedemptionLog."Redemption Date" := Rec."Redemption Date";
                                RedemptionLog.PayingBank := Rec.PayingBank;
                                RedemptionLog.FloatingPrinc := Rec.FloatPrinci;
                                RedemptionLog.FloatingIntr := Rec.FloatIntr;
                                RedemptionLog.Insert();
                            end;


                            FunderLoan.State := FunderLoan.State::Terminated;
                            FunderLoan.Modify();

                            TrsyMgtCU.PartialRedemptionPostings(Rec."Redemption Date", Rec."Loan No.", Rec.PayingBank, Rec.FloatPrinci, Rec.FloatIntr, Rec.PartialAmount);
                            RelatedPartyMgtCU.PartialRedemptionDuplicateRecord(LoanID);
                            //Email
                            // The funder and Treasury
                            MailingCU.SendPartidalRedemptionEmailWithAttachment(Rec."Loan No.")
                        end;

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
        RelatedPartyMgtCU: Codeunit RelatepartyMgtCU;
        RedemptionLog: Record "Redemption Log Tbl";
        RedemptionIntererst: Record "Redemption Floating Interest";
        MailingCU: Codeunit "Treasury Emailing";

}