report 50248 "Intre. Accru & Cap"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    Caption = 'Interest accrual & capitalization report';

    dataset
    {
        dataitem(FunderLoan; "Funder Loan")
        {
            column(No_; "No.") { }
            column(Loan_Name; "Loan Name") { }
            column(Funder_No_; "Funder No.") { }
            column(Name; Name) { }
            column(PlacementDate; PlacementDate) { }
            column(MaturityDate; MaturityDate) { }
            column(InterestRate; InterestRate) { }
            column(AccrualValue; AccrualValue) { }
            column(AccrualValueLCY; AccrualValueLCY) { }
            column(CapitalizedValue; CapitalizedValue) { }
            column(CapitalizedValueLCY; CapitalizedValueLCY) { }
            trigger OnPreDataItem()
            begin
                if LoanID <> '' then
                    FunderLoan.SetRange("No.", LoanID);

            end;

            trigger OnAfterGetRecord()
            begin
                FunderLedgerEntry.Reset();
                FunderLedgerEntry.SetRange("Loan No.", FunderLoan."No.");
                FunderLedgerEntry.SetRange("Document Type", FunderLedgerEntry."Document Type"::Interest);
                FunderLedgerEntry.CalcSums(Amount);
                AccrualValue := FunderLedgerEntry.Amount;
                FunderLedgerEntry.CalcSums("Amount(LCY)");
                AccrualValueLCY := FunderLedgerEntry."Amount(LCY)";

                FunderLedgerEntry.Reset();
                FunderLedgerEntry.SetRange("Loan No.", FunderLoan."No.");
                FunderLedgerEntry.SetRange("Document Type", FunderLedgerEntry."Document Type"::"Capitalized Interest");
                FunderLedgerEntry.CalcSums(Amount);
                CapitalizedValue := FunderLedgerEntry.Amount;
                FunderLedgerEntry.CalcSums("Amount(LCY)");
                CapitalizedValueLCY := FunderLedgerEntry."Amount(LCY)";


            end;
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                group(Gen)
                {
                    field(No; LoanID)
                    {
                        TableRelation = "Funder Loan"."No.";
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'reports/accrual&capitalization.rdlc';
        }
    }

    var
        LoanID: Code[20];
        FunderLedgerEntry: Record FunderLedgerEntry;
        AccrualValue: Decimal;
        AccrualValueLCY: Decimal;
        CapitalizedValue: Decimal;
        CapitalizedValueLCY: Decimal;

}