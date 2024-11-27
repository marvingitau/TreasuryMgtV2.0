codeunit 50232 "Treasury Mgt CU"
{
    trigger OnRun()
    begin

    end;

    procedure PostTrsyJnl()
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";
        TrsyJnl: Record "Trsy Journal";
        Counter: Integer;
        funderEntryCounter: Integer;
        debtorEntryCounter: Integer;
        funderLegderEntry: Record FunderLedgerEntry;
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        looper: Record FunderLedgerEntry;
        principleAcc: Code[100];
        interestAccExpense: Code[100];
        interestAccPay: Code[100];
        withholdingAcc: Code[20];
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        _amount: Decimal;
        latestRemainingAmount: Decimal;
        _accruingIntrestNo: Integer;
        TotalProcessed: Integer;
        BatchSize: Integer;
        CurrentBatchCount: Integer;
        TotalDebit: Decimal;
        TotalCredit: Decimal;
        generalSetup: Record "General Setup";
        funderNo: Code[100];
        originalAmount: Decimal;
        _auxAmount: Decimal;
    begin

    end;

    var
}