codeunit 50232 "Treasury Mgt CU"
{
    trigger OnRun()
    begin

    end;

    procedure GenerateDocumentNumber() No: Code[20]
    var
        NoSeries: Codeunit "No. Series";
        NoSeriesCode: Code[20];
        DocumentNo: Code[20];
        NoSer: Codeunit "No. Series";
        GenSetup: Record "General Setup";

    begin
        GenSetup.Get(0);
        GenSetup.TestField("Funder No.");
        if GenSetup."Treasury Jnl No." <> '' then
            No := NoSeries.GetNextNo(GenSetup."Treasury Jnl No.", 0D, true);

    end;



    procedure PostTrsyJnl()
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";
        TrsyJnl: Record "Trsy Journal";
        Counter: Integer;
        funder: Record Funders;
        funderLoan: Record "Funder Loan";
        funderEntryCounter: Integer;
        debtorEntryCounter: Integer;
        funderLegderEntry: Record FunderLedgerEntry;
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        looper: Record FunderLedgerEntry;
        venPostingGroup: record "Vendor Posting Group";
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
        JournalEntry.LockTable();
        if JournalEntry.FindLast() then
            NextEntryNo := JournalEntry."Line No." + 1000
        else
            NextEntryNo := 1000;

        // Funder Ledger Entry 
        looper.LockTable();
        looper.Reset();
        if looper.FindLast() then
            funderEntryCounter := looper."Entry No." + 1
        else
            funderEntryCounter := 1;

        // if TrsyJnl."Transaction Nature" = TrsyJnl."Transaction Nature"::" " then
        //     Error('Transaction Type Required');

        TrsyJnl.Reset();
        TrsyJnl.SetRange("Posting Date", 0D, Today);
        TrsyJnl.SetRange(TrsyJnl."Transaction Nature", TrsyJnl."Transaction Nature"::"Original Principle");
        if TrsyJnl.Find('-') then begin
            repeat
                //Post To Trsy Tble and Post to G/L

                if TrsyJnl."Transaction Nature" = TrsyJnl."Transaction Nature"::"Original Principle" then begin
                    JournalEntry.Init();
                    JournalEntry."Journal Template Name" := 'GENERAL';
                    JournalEntry."Journal Batch Name" := 'TREASURY';
                    // JournalEntry."Line No." := NextEntryNo + (Counter + 1);
                    // JournalEntry.Entry_ID := NextEntryNo + (Counter + 1);

                    JournalEntry."Posting Date" := TrsyJnl."Posting Date";
                    JournalEntry.Creation_Date := TrsyJnl."Posting Date";
                    JournalEntry."Document No." := TrsyJnl."Document No.";
                    JournalEntry.Description := TrsyJnl.Description;
                    if (TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder) OR (TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"G/L Account") then begin

                        if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                            principleAcc := '';
                            funderLoan.Reset();
                            funderLoan.SetRange("No.", TrsyJnl."Bal. Account No.");
                            if not funderLoan.Find('-') then// Get the Loan Details
                                Error('Funder Loan = %1, dont exist.', TrsyJnl."Bal. Account No.");
                            if funderLoan.Currency <> '' then
                                JournalEntry."Currency Code" := funderLoan.Currency;
                            if not funder.Get(funderLoan."Funder No.") then begin
                                Error('Funder = %1, dont exist.', funderLoan."Funder No.");
                            end;
                            //Get Posting groups
                            if not venPostingGroup.Get(funder."Posting Group") then
                                Error('Missing Posting Group: %1', funder."Posting Group");
                            // interestAccExpense := venPostingGroup."Interest Expense";
                            // if interestAccExpense = '' then
                            //     Error('Missing Posting Group - Interest A/C: %1', funder."Posting Group");
                            principleAcc := venPostingGroup."Payables Account";
                            if principleAcc = '' then
                                Error('Missing Posting Group - Principle A/C: %1', funder."No.");


                        end;
                        if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                            principleAcc := '';
                            funderLoan.Reset();
                            funderLoan.SetRange("No.", TrsyJnl."Account No.");
                            if not funderLoan.Find('-') then// Get the Loan Details
                                Error('Funder Loan = %1, dont exist.', TrsyJnl."Account No.");
                            if funderLoan.Currency <> '' then
                                JournalEntry."Currency Code" := funderLoan.Currency;
                            if not funder.Get(funderLoan."Funder No.") then begin
                                Error('Funder = %1, dont exist.', funderLoan."Funder No.")
                            end;
                            //Get Posting groups
                            if not venPostingGroup.Get(funder."Posting Group") then
                                Error('Missing Posting Group: %1', funder."Posting Group");
                            // interestAccExpense := venPostingGroup."Interest Expense";
                            // if interestAccExpense = '' then
                            //     Error('Missing Posting Group - Interest A/C: %1',funder."Posting Group");
                            principleAcc := venPostingGroup."Payables Account";
                            if principleAcc = '' then
                                Error('Missing Posting Group - Principle A/C: %1', funder."No.");


                        end;

                        JournalEntry.Amount := Round(TrsyJnl.Amount, 0.01, '=');
                        JournalEntry.Validate(JournalEntry.Amount);
                        //@@ Account Type
                        if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"Bank Account" then begin//@@@@ Debit Bank

                            JournalEntry."Account Type" := TrsyJnl."Account Type"::"Bank Account";
                            JournalEntry."Account No." := TrsyJnl."Account No.";
                        end
                        else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                            JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account";
                            JournalEntry."Account No." := principleAcc;
                        end
                        else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Debtor then
                            Error('Debtor not suppoted')//JournalEntry."Account Type" := TrsyJnl."Account Type"::Debtor
                        else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"G/L Account" then begin
                            JournalEntry."Account No." := TrsyJnl."Account No.";
                            JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account";
                        end;

                        // @@ Bal Account Type
                        if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"Bank Account" then begin//@@@@ Credit Principal Account
                            JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"Bank Account";
                            JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                        end
                        else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                            JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account";
                            JournalEntry."Bal. Account No." := principleAcc;
                        end
                        else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Debtor then
                            Error('Debtor not suppoted')//JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::Debtor
                        else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"G/L Account" then begin
                            JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account";
                            JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                        end;

                        GLPost.RunWithCheck(JournalEntry);
                        //*****************************
                        //Funder Ledger Entries
                        //*****************************
                        looper.LockTable();
                        looper.Reset();
                        if looper.FindLast() then
                            funderEntryCounter := looper."Entry No." + 1
                        else
                            funderEntryCounter := 1;
                        funderLegderEntry.Init();
                        funderLegderEntry."Entry No." := funderEntryCounter;
                        funderLegderEntry."Funder No." := funder."No.";
                        funderLegderEntry."Funder Name" := funder.Name;
                        funderLegderEntry."Loan No." := funderLoan."No.";
                        funderLegderEntry."Loan Name" := funderLoan."Loan Name";
                        if JournalEntry."Currency Code" <> '' then
                            funderLegderEntry."Currency Code" := JournalEntry."Currency Code";
                        funderLegderEntry."Posting Date" := TrsyJnl."Posting Date";
                        funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Original Amount";
                        funderLegderEntry."Document No." := TrsyJnl."Document No.";
                        // funderLegderEntry."Transaction Type" := funderLegderEntry."Transaction Type"::"Original Amount";
                        funderLegderEntry.Description := 'Original Amount (Trsy Jnl)' + Format(Today) + TrsyJnl.Description;
                        // if JournalEntry."Currency Code" <> '' then begin
                        //     funderLegderEntry."Amount(LCY)" := Round(ConvertCurrencyAmount(JournalEntry."Currency Code", TrsyJnl.Amount), 0.01, '=');
                        // end
                        // else
                        funderLegderEntry."Amount(LCY)" := Round(TrsyJnl.Amount, 0.01, '=');
                        funderLegderEntry.Amount := Round(TrsyJnl.Amount, 0.01, '=');
                        funderLegderEntry."Remaining Amount(LCY)" := Round(TrsyJnl.Amount, 0.01, '=');
                        funderLegderEntry."Remaining Amount" := Round(TrsyJnl.Amount, 0.01, '=');
                        funderLegderEntry.Insert();
                    end;
                end;


            until TrsyJnl.Next() = 0;
            TrsyJnl.Reset();
            TrsyJnl.SetFilter("Account No.", '<>%1', '');
            if TrsyJnl.Find('-') then begin
                repeat
                    TrsyJnl.Delete();
                until TrsyJnl.Next() = 0;
            end;

            Message('Journal Original Principle Posting Done');

        end

    end;

    procedure ConvertCurrencyAmount(var CurrencyCode: Code[10]; var Amount: Decimal): Decimal
    var
        Currency: Record "Currency";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ExchangeRate: Decimal;
        NewAmount: Decimal;
        MaxDate: Date;
    begin
        if CurrencyCode <> '' then begin
            if Currency.Get(CurrencyCode) then begin
                // Try to get today's exchange rate
                if CurrencyExchangeRate.Get(CurrencyCode, Today) then begin
                    ExchangeRate := CurrencyExchangeRate."Exchange Rate Amount" / CurrencyExchangeRate."Relational Exch. Rate Amount";
                end else begin
                    // Find the latest available exchange rate
                    CurrencyExchangeRate.SetCurrentKey("Currency Code", "Starting Date");
                    CurrencyExchangeRate.SetRange("Currency Code", CurrencyCode);
                    if CurrencyExchangeRate.FindLast then begin
                        MaxDate := CurrencyExchangeRate."Starting Date";
                        if CurrencyExchangeRate.Get(CurrencyCode, MaxDate) then begin
                            ExchangeRate := CurrencyExchangeRate."Exchange Rate Amount" / CurrencyExchangeRate."Relational Exch. Rate Amount";
                        end else
                            Error('Exchange rate not found for currency %1 on the latest date', CurrencyCode);
                    end else
                        Error('Exchange rate not found for currency %1', CurrencyCode);
                end;

                if ExchangeRate <> 0 then begin
                    // Convert the amount to the new currency
                    NewAmount := Amount * ExchangeRate;
                    exit(NewAmount);
                end else
                    Error('Exchange rate is zero for currency %1', CurrencyCode);
            end else
                Error('Currency not found for code %1', CurrencyCode);
        end else
            Error('Currency code is empty');
    end;



    var
        funderLedgerEntries: Page FunderLedgerEntry;
}