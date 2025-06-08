page 50307 "RelatedParty Roll over"
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

                }
                field("Rollover Date"; Rec."Rollover Date")
                {
                    ApplicationArea = All;
                    Enabled = Rec.RollOverType = Rec.RollOverType::"Full Rollover";
                }

                field(PlacementMaturity; Rec.PlacementMaturity)
                {
                    ApplicationArea = All;
                    // Editable = false;
                    trigger OnValidate()
                    begin
                        RelatedPartyLoan.Reset();
                        RelatedPartyLoan.SetRange("No.", Rec."Loan No.");
                        if RelatedPartyLoan.Find('-') then begin
                            // if Rec.PlacementMaturity = Rec.PlacementMaturity::
                            RelatedPartyLoan.PlacementMaturity := Rec.PlacementMaturity;
                            RelatedPartyLoan.Modify()
                        end;

                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount To Rollover';
                    // Editable = AmountEnabled;
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
                    relatedPartyMgt: Codeunit RelatepartyMgtCU;
                    RO: Page "Roll over";
                    GFilter: Codeunit GlobalFilters;
                    ROTbl: Record "Roll over Tbl";
                begin
                    relatedPartyMgt.DuplicateRecord(Rec.Line);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        if Rec.IsEmpty() then begin
            LoanID := GFilter.GetGlobalLoanFilter();
            RelatedPartyLoan.Reset();
            RelatedPartyLoan.SetRange("No.", LoanID);
            if not RelatedPartyLoan.Find('-') then
                Error('RelatedParty Loan No %1 Not found', LoanID);
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::Interest then begin
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::Interest;
                RelatedPartyLoan.CalcFields("Outstanding Interest");
                Rec.Amount := RelatedPartyLoan."Outstanding Interest";
            end;
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::Principal then begin
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::Principal;
                RelatedPartyLoan.CalcFields(OutstandingAmntDisbLCY);
                Rec.Amount := RelatedPartyLoan.OutstandingAmntDisbLCY;
            end;
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::"Principal + Interest" then begin
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::"Principal + Interest";
                RelatedPartyLoan.CalcFields(OutstandingAmntDisbLCY);
                Rec.Amount := RelatedPartyLoan.OutstandingAmntDisbLCY;
                RelatedPartyLoan.CalcFields("Outstanding Interest");
                Rec.Amount := Rec.Amount + RelatedPartyLoan."Outstanding Interest";
            end;
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::Terminate then
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::Terminate;

            Rec."Loan No." := LoanID;

            Rec.Insert();
        end else begin
            LoanID := GFilter.GetGlobalLoanFilter();
            RelatedPartyLoan.Reset();
            RelatedPartyLoan.SetRange("No.", LoanID);
            if not RelatedPartyLoan.Find('-') then
                Error('Loan No registered');
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::Interest then begin
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::Interest;
                RelatedPartyLoan.CalcFields("Outstanding Interest");
                Rec.Amount := RelatedPartyLoan."Outstanding Interest";
            end;
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::Principal then begin
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::Principal;
                RelatedPartyLoan.CalcFields(OutstandingAmntDisbLCY);
                Rec.Amount := RelatedPartyLoan.OutstandingAmntDisbLCY;
            end;
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::"Principal + Interest" then begin
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::"Principal + Interest";
                RelatedPartyLoan.CalcFields(OutstandingAmntDisbLCY);
                Rec.Amount := RelatedPartyLoan.OutstandingAmntDisbLCY;
                RelatedPartyLoan.CalcFields("Outstanding Interest");
                Rec.Amount := Rec.Amount + RelatedPartyLoan."Outstanding Interest";
            end;
            if RelatedPartyLoan.PlacementMaturity = RelatedPartyLoan.PlacementMaturity::Terminate then
                Rec.PlacementMaturity := RelatedPartyLoan.PlacementMaturity::Terminate;

            Rec."Loan No." := LoanID;
            Rec.Modify();
        end;

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
        RelatedPartyLoan: Record "RelatedParty Loan";
        AmountEnabled: Boolean;

}