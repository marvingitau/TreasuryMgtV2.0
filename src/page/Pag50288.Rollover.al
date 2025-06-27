page 50288 "Roll over"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = 50289;

    Caption = 'Rollover Operation';

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
                field(RollOverType; Rec.RollOverType)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Rollover Date"; Rec."Rollover Date")
                {
                    ApplicationArea = All;
                    // Enabled = Rec.RollOverType = Rec.RollOverType::"Full Rollover";
                }

                field(PlacementMaturity; Rec.PlacementMaturity)
                {
                    ApplicationArea = All;
                    // Visible = false;
                    trigger OnValidate()
                    begin
                        FunderLoan.Reset();
                        FunderLoan.SetRange("No.", Rec."Loan No.");
                        if FunderLoan.Find('-') then begin
                            // if Rec.PlacementMaturity = Rec.PlacementMaturity::
                            FunderLoan.PlacementMaturity := Rec.PlacementMaturity;
                            FunderLoan.Modify()
                        end;

                    end;
                }
                field(Principal; Rec.Principal)
                {
                    ApplicationArea = All;
                    Editable = (Rec.PlacementMaturity = Rec.PlacementMaturity::Principal) or (Rec.PlacementMaturity = Rec.PlacementMaturity::"Principal + Interest");
                    trigger OnValidate()
                    begin
                        Rec.Amount := Rec.Principal + Rec.AccruedInterest;
                    end;
                }
                field(AccruedInterest; Rec.AccruedInterest)
                {
                    ApplicationArea = All;
                    Caption = 'Interest';
                    Editable = (Rec.PlacementMaturity = Rec.PlacementMaturity::Interest) or (Rec.PlacementMaturity = Rec.PlacementMaturity::"Principal + Interest");

                    trigger OnValidate()
                    begin
                        Rec.Amount := Rec.Principal + Rec.AccruedInterest;
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount To Rollover';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Rollover Process")
            {
                ApplicationArea = Basic, Suite;
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Rollover Process';
                ToolTip = 'Rollover Process';
                trigger OnAction()
                var
                    funderMgt: Codeunit FunderMgtCU;
                    RO: Page "Roll over";
                    GFilter: Codeunit GlobalFilters;
                    ROTbl: Record "Roll over Tbl";
                begin
                    funderMgt.DuplicateRecordB(Rec.Line);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        // if Rec.IsEmpty() then begin
        LoanID := GFilter.GetGlobalLoanFilter();
        FunderLoan.Reset();
        FunderLoan.SetRange("No.", LoanID);
        if not FunderLoan.Find('-') then
            Error('Funder Loan No %1 Not found', LoanID);
        /*if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::Interest then begin
            Rec.PlacementMaturity := FunderLoan.PlacementMaturity::Interest;
            FunderLoan.CalcFields("Outstanding Interest");
            Rec.Amount := FunderLoan."Outstanding Interest";
        end;
        if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::Principal then begin
            Rec.PlacementMaturity := FunderLoan.PlacementMaturity::Principal;
            FunderLoan.CalcFields(OutstandingAmntDisbLCY);
            Rec.Amount := FunderLoan.OutstandingAmntDisbLCY;
        end;
        if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::"Principal + Interest" then begin
            Rec.PlacementMaturity := FunderLoan.PlacementMaturity::"Principal + Interest";
            FunderLoan.CalcFields(OutstandingAmntDisbLCY);
            Rec.Amount := FunderLoan.OutstandingAmntDisbLCY;
            FunderLoan.CalcFields("Outstanding Interest");
            Rec.Amount := Rec.Amount + FunderLoan."Outstanding Interest";
        end;
        if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::Terminate then
            Rec.PlacementMaturity := FunderLoan.PlacementMaturity::Terminate;
        */
        FunderLoan.CalcFields(OutstandingAmntDisbLCY);
        Rec.Principal := FunderLoan.OutstandingAmntDisbLCY;
        FunderLoan.CalcFields("Outstanding Interest");
        Rec.AccruedInterest := Rec.Amount + FunderLoan."Outstanding Interest";
        Rec.Amount := FunderLoan.OutstandingAmntDisbLCY + FunderLoan."Outstanding Interest";
        Rec."Loan No." := LoanID;
        Rec."Rollover Date" := Today();
        Rec.Insert();
        // end else begin
        //     LoanID := GFilter.GetGlobalLoanFilter();
        //     FunderLoan.Reset();
        //     FunderLoan.SetRange("No.", LoanID);
        //     if not FunderLoan.Find('-') then
        //         Error('Loan No registered');
        //     /*if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::Interest then begin
        //         Rec.PlacementMaturity := FunderLoan.PlacementMaturity::Interest;
        //         FunderLoan.CalcFields("Outstanding Interest");
        //         Rec.Amount := FunderLoan."Outstanding Interest";
        //     end;
        //     if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::Principal then begin
        //         Rec.PlacementMaturity := FunderLoan.PlacementMaturity::Principal;
        //         FunderLoan.CalcFields(OutstandingAmntDisbLCY);
        //         Rec.Amount := FunderLoan.OutstandingAmntDisbLCY;
        //     end;
        //     if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::"Principal + Interest" then begin
        //         Rec.PlacementMaturity := FunderLoan.PlacementMaturity::"Principal + Interest";
        //         FunderLoan.CalcFields(OutstandingAmntDisbLCY);
        //         Rec.Amount := FunderLoan.OutstandingAmntDisbLCY;
        //         FunderLoan.CalcFields("Outstanding Interest");
        //         Rec.Amount := Rec.Amount + FunderLoan."Outstanding Interest";
        //     end;
        //     if FunderLoan.PlacementMaturity = FunderLoan.PlacementMaturity::Terminate then
        //         Rec.PlacementMaturity := FunderLoan.PlacementMaturity::Terminate;
        //     */
        //     FunderLoan.CalcFields(OutstandingAmntDisbLCY);
        //     Rec.Principal := FunderLoan.OutstandingAmntDisbLCY;
        //     FunderLoan.CalcFields("Outstanding Interest");
        //     Rec.AccruedInterest := Rec.Amount + FunderLoan."Outstanding Interest";
        //     Rec.Amount := FunderLoan.OutstandingAmntDisbLCY + FunderLoan."Outstanding Interest";
        //     Rec."Loan No." := LoanID;
        //     Rec."Rollover Date" := Today();
        //     Rec.Modify();
        // end;

    end;

    trigger OnOpenPage()
    begin
        // AmountEnabled := not (Rec.PlacementMaturity = Rec.PlacementMaturity::"Principal + Interest");
        // if AmountEnabled then
        //     Rec.Amount := 0;

    end;

    var
        LoanID: Code[20];
        GFilter: Codeunit GlobalFilters;
        FunderLoan: Record "Funder Loan";
        AmountEnabled: Boolean;

}