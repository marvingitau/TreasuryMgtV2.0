codeunit 50236 "Treasury Amortization"
{
    trigger OnRun()
    begin

    end;

    procedure AmortizeInterest(FunderLoan: Code[20])
    var
        _funderLoan: Record "Funder Loan";
    begin
        // _funderLoan.Reset();
        // _funderLoan.SetRange("No.", Rec."No.");

        // Report.Run(50230, true, false, _funderLoan);
    end;

    var
        InterestTempTbl: Record "Intr- Amort";
}