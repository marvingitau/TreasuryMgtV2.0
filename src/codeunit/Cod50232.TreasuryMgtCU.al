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
        GenSetup: Record "Treasury General Setup";

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
        funderLoan2: Record "Funder Loan";
        totalAccruedInterest: Decimal;
        totalPaidInterest: Decimal;
        differentAccrPaidInterest: Decimal;
        totalOriginalAmount: Decimal;
        totalWithdrawalAmount: Decimal;
        differenceOriginalWithdrawal: Decimal;
        funderEntryCounter: Integer;
        debtorEntryCounter: Integer;
        funderLegderEntry: Record FunderLedgerEntry;
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        looper: Record FunderLedgerEntry;
        venPostingGroup: record "Treasury Posting Group";
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
        generalSetup: Record "Treasury General Setup";
        funderNo: Code[100];
        funderName: Text[100];
        _loanNo: Code[100];
        _loanName: Code[100];
        originalAmount: Decimal;
        _auxAmount: Decimal;

        totalCapitalInterest: Decimal;
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
            funderEntryCounter := looper."Entry No." + 3
        else
            funderEntryCounter := 1;


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
                    JournalEntry."Shortcut Dimension 1 Code" := TrsyJnl."Shortcut Dimension 1 Code";
                    if (TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder) OR (TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"G/L Account") then begin

                        if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                            principleAcc := '';
                            funderLoan.Reset();
                            funderLoan.SetRange("No.", TrsyJnl."Bal. Account No.");
                            if not funderLoan.Find('-') then// Get the Loan Details
                                Error('Funder Loan = %1, dont exist.', TrsyJnl."Bal. Account No.");
                            if funderLoan.Currency <> '' then // @@@@@  CURRENCY VALIDATION
                                JournalEntry."Currency Code" := funderLoan.Currency;
                            if not funder.Get(funderLoan."Funder No.") then begin
                                Error('Funder = %1, dont exist.', funderLoan."Funder No.");
                            end;
                            //Get Posting groups
                            // if not venPostingGroup.Get(funderLoan."Posting Group") then
                            //     Error('Missing Posting Group: %1', funderLoan."Posting Group");
                            // interestAccExpense := venPostingGroup."Interest Expense";
                            // if interestAccExpense = '' then
                            //     Error('Missing Interest A/C: %1', funder."Posting Group");
                            principleAcc := funderLoan."Payables Account";
                            if principleAcc = '' then
                                Error('Missing Principle A/C: %1', funder."No.");


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
                            // if not venPostingGroup.Get(funderLoan."Posting Group") then
                            //     Error('Missing Posting Group: %1', funderLoan."Posting Group");
                            // // interestAccExpense := venPostingGroup."Interest Expense";
                            // // if interestAccExpense = '' then
                            // //     Error('Missing Interest A/C: %1',funder."Posting Group");
                            principleAcc := funderLoan."Payables Account";
                            if principleAcc = '' then
                                Error('Missing Principle A/C: %1', funder."No.");


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
                        if JournalEntry."Currency Code" <> '' then //Populated during posting group validation
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

        end;

        TrsyJnl.Reset();
        TrsyJnl.SetRange("Posting Date", 0D, Today);
        TrsyJnl.SetRange(TrsyJnl."Transaction Nature", TrsyJnl."Transaction Nature"::"Accruing Interest");
        _accruingIntrestNo := TrsyJnl.Count();
        TotalDebit := 0;
        TotalCredit := 0;
        BatchSize := 3; // Set the number of records to process in each loop
        if TrsyJnl.Find('-') then begin
            repeat
                CurrentBatchCount := 0;
                _amount := 0;
                witHldInterest := 0;
                funderNo := '';
                funderName := '';
                _loanNo := '';
                _loanName := '';
                repeat
                    // Accumulate totals for validation 
                    TotalDebit := TotalDebit + TrsyJnl.Amount;
                    // TotalCredit := TotalCredit + TrsyJnl.Amount;

                    if TrsyJnl."Transaction Nature" = TrsyJnl."Transaction Nature"::"Accruing Interest" then begin
                        //**************
                        // FUNDER INTERST EXPENSE (Dr)
                        //**************
                        if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin // is funder
                            funderLoan.Reset();
                            funderLoan.SetRange("No.", TrsyJnl."Account No.");
                            if not funderLoan.Find('-') then// Get the Loan Details
                                Error('Funder Loan = %1, dont exist.', TrsyJnl."Account No.");

                            if funder.Get(funderLoan."Funder No.") then begin  // get funder

                                // **********************************************
                                //          Get Posting groups & Posting Accounts
                                // **********************************************
                                // if not venPostingGroup.Get(funderLoan."Posting Group") then
                                //     Error('Missing Posting Group: %1', funder."No.");
                                interestAccExpense := funderLoan."Interest Expense";
                                if interestAccExpense = '' then
                                    Error('Missing Interest Expense A/C: %1', funder."No.");
                                interestAccPay := funderLoan."Interest Payable";
                                if interestAccPay = '' then
                                    Error('Missing Interest Payable A/C: %1', funder."No.");
                                principleAcc := funderLoan."Payables Account";
                                if principleAcc = '' then
                                    Error('Missing Principle A/C: %1', funder."No.");
                                if not generalSetup.FindFirst() then
                                    Error('Please Define Withholding Tax under General Setup');
                                withholdingAcc := generalSetup.FunderWithholdingAcc;
                                //Get the latest remaining amount
                                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                                if funderLegderEntry.FindLast() then
                                    latestRemainingAmount := funderLegderEntry."Remaining Amount";

                                funderNo := funder."No.";
                                funderName := funder.Name;
                                _loanNo := funderLoan."No.";
                                _loanName := funderLoan."Loan Name";
                                //**********************************************
                                // Posting AMOUNT
                                //**********************************************
                                _amount := Round(TrsyJnl.Amount, 0.01, '=');
                                // *********************
                                // INTEREST EXPENSE (Dr)
                                // *********************
                                JournalEntry.Init();
                                JournalEntry."Journal Template Name" := 'GENERAL';
                                JournalEntry."Journal Batch Name" := 'TREASURY';
                                // JournalEntry."Line No." := NextEntryNo + Counter + CurrentBatchCount;
                                // JournalEntry.Entry_ID := NextEntryNo + (Counter + 1);
                                JournalEntry."Posting Date" := TrsyJnl."Posting Date";
                                JournalEntry.Creation_Date := TrsyJnl."Posting Date";
                                JournalEntry."Document No." := TrsyJnl."Document No.";
                                JournalEntry.Description := TrsyJnl.Description;
                                JournalEntry."Shortcut Dimension 1 Code" := TrsyJnl."Shortcut Dimension 1 Code";
                                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"Bank Account" then begin
                                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"Bank Account"; //@@@@ Debit Bank
                                    JournalEntry."Account No." := TrsyJnl."Account No.";
                                end
                                else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account";
                                    JournalEntry."Account No." := interestAccExpense;
                                end
                                else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Debtor then begin
                                    // JournalEntry."Account Type" := TrsyJnl."Account Type"::Debtor
                                    // JournalEntry."Account No." := principleAcc;
                                    Error('Debtor not suppoted')
                                end
                                else
                                    Error('Unsupported Account Type = %1', TrsyJnl."Account Type");


                                JournalEntry.Amount := _amount;
                                JournalEntry.Validate(JournalEntry.Amount);
                                JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
                                if TrsyJnl."Bal. Account No." <> '' then begin //Opening Balance Entry 
                                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
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
                                    funderLegderEntry."Funder Name" := funderName;
                                    funderLegderEntry."Loan No." := _loanNo;
                                    funderLegderEntry."Loan Name" := _loanName;
                                    // funderLegderEntry."Funder Name" := Name;
                                    if funderLoan.Currency <> '' then
                                        funderLegderEntry."Currency Code" := funderLoan.Currency;
                                    funderLegderEntry."Posting Date" := TrsyJnl."Posting Date";
                                    funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                                    funderLegderEntry."Document No." := TrsyJnl."Document No.";
                                    // funderLegderEntry."Transaction Type" := funderLegderEntry."Transaction Type"::"Original Amount";
                                    funderLegderEntry.Description := 'Interest Amount (Trsy Jnl) ' + Format(Today) + ' ' + TrsyJnl.Description;
                                    funderLegderEntry.Amount := Abs(JournalEntry.Amount); //@hotte req
                                    funderLegderEntry."Amount(LCY)" := Abs(JournalEntry.Amount);//@hotte req
                                    funderLegderEntry."Remaining Amount" := Abs(JournalEntry.Amount);//@hotte req
                                    funderLegderEntry.Insert();

                                end;
                                if funderLoan.Currency <> '' then
                                    JournalEntry."Currency Code" := funderLoan.Currency;
                                // JournalEntry.Insert();
                                GLPost.RunWithCheck(JournalEntry); // Post Dr Transaction

                                // end;
                            end;
                        end;
                        //**************
                        // INTREST PAYABLE ( Cr)  WHOLDING (Cr)
                        //**************
                        if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"G/L Account" then begin
                            // **************
                            // INTREST PAYABLE ( Cr)  WHOLDING (Cr) 
                            // if JournalEntry.FindLast() then
                            //     NextEntryNo := JournalEntry."Line No." + 1;
                            JournalEntry.Init();
                            JournalEntry."Journal Template Name" := 'GENERAL';
                            JournalEntry."Journal Batch Name" := 'TREASURY';
                            // JournalEntry."Line No." := Counter + CurrentBatchCount;
                            // JournalEntry.Entry_ID := NextEntryNo + (Counter + 1);
                            JournalEntry."Posting Date" := TrsyJnl."Posting Date";
                            JournalEntry.Creation_Date := TrsyJnl."Posting Date";
                            JournalEntry."Document No." := TrsyJnl."Document No.";
                            JournalEntry.Description := TrsyJnl.Description;
                            JournalEntry."Shortcut Dimension 1 Code" := TrsyJnl."Shortcut Dimension 1 Code";
                            JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account";
                            JournalEntry."Account No." := interestAccPay;
                            JournalEntry.Amount := TrsyJnl.Amount;//@@@
                            JournalEntry.Validate(JournalEntry.Amount);
                            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
                            if TrsyJnl."Bal. Account No." <> '' then
                                JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                            if TrsyJnl."Currency Code" <> '' then
                                JournalEntry."Currency Code" := TrsyJnl."Currency Code";
                            // JournalEntry.Insert();
                            GLPost.RunWithCheck(JournalEntry); // Post Cr Transaction

                            //********************************
                            //       Funder ledget entries
                            //******************************
                            //Get the latest remaining amount
                            funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                            funderLegderEntry.SetRange("Funder No.", funderNo);
                            if funderLegderEntry.FindLast() then
                                latestRemainingAmount := funderLegderEntry."Remaining Amount";
                            // Get the Original Amount
                            funderLegderEntry.Reset();
                            funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Original Amount");
                            funderLegderEntry.SetRange(funderLegderEntry."Funder No.", funderNo);
                            // funderLegderEntry.CalcSums(Amount);
                            if funderLegderEntry.FindSet() then
                                repeat
                                    originalAmount := originalAmount + funderLegderEntry.Amount;
                                until funderLegderEntry.Next() = 0;

                            //Set condition to run only if the GL in scope is Wholding one.
                            generalSetup.Reset();
                            generalSetup.SetRange(generalSetup.FunderWithholdingAcc, TrsyJnl."Account No.");
                            if generalSetup.Find('-') then begin
                                witHldInterest := TrsyJnl.Amount;

                                funderLegderEntry1.Init();
                                funderLegderEntry1."Entry No." := funderEntryCounter + 1;
                                funderLegderEntry1."Funder No." := funderNo;
                                funderLegderEntry1."Funder Name" := funderName;
                                funderLegderEntry1."Loan No." := _loanNo;
                                funderLegderEntry1."Loan Name" := _loanName;

                                if TrsyJnl."Currency Code" <> '' then
                                    funderLegderEntry1."Currency Code" := TrsyJnl."Currency Code";
                                funderLegderEntry1."Posting Date" := TrsyJnl."Posting Date";
                                funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                                funderLegderEntry1."Document No." := TrsyJnl."Document No.";
                                funderLegderEntry1.Description := 'Withholding calculation' + Format(Today) + TrsyJnl.Description;
                                funderLegderEntry1.Amount := Abs(witHldInterest);
                                funderLegderEntry1."Amount(LCY)" := Abs(witHldInterest);
                                funderLegderEntry1.Insert();

                                //Update Incase Wholding Came Last
                                funderLegderEntry1.Reset();
                                funderLegderEntry1.SetRange(funderLegderEntry1."Document Type", funderLegderEntry1."Document Type"::Interest);
                                funderLegderEntry1.SetRange(funderLegderEntry1."Document No.", TrsyJnl."Document No.");
                                funderLegderEntry1.SetRange(funderLegderEntry1."Posting Date", TrsyJnl."Posting Date");
                                // funderLegderEntry1.SetRange(funderLegderEntry1."Document No.", funderLegderEntry1."Document No.");
                                if funderLegderEntry1.Find('-') then begin
                                    funderLegderEntry1.Amount := Abs(funderLegderEntry1.Amount + witHldInterest);
                                    funderLegderEntry1."Amount(LCY)" := Abs(funderLegderEntry1."Amount(LCY)" + witHldInterest);
                                    funderLegderEntry1."Remaining Amount" := Abs(funderLegderEntry1."Remaining Amount");
                                    funderLegderEntry1.Modify();
                                end;

                                funderLegderEntry1.Reset();
                                funderLegderEntry1.SetRange(funderLegderEntry1."Document Type", funderLegderEntry1."Document Type"::"Remaining Amount");
                                funderLegderEntry1.SetRange(funderLegderEntry1."Document No.", TrsyJnl."Document No.");
                                funderLegderEntry1.SetRange(funderLegderEntry1."Posting Date", TrsyJnl."Posting Date");
                                // funderLegderEntry1.SetRange(funderLegderEntry1."Document No.", funderLegderEntry1."Document No.");
                                if funderLegderEntry1.Find('-') then begin
                                    funderLegderEntry1.Amount := Abs(funderLegderEntry1.Amount) + originalAmount;
                                    funderLegderEntry1."Amount(LCY)" := Abs(funderLegderEntry1."Amount(LCY)") + originalAmount;
                                    if latestRemainingAmount = 0 then
                                        funderLegderEntry1."Remaining Amount" := Abs(funderLegderEntry1."Remaining Amount" + originalAmount)
                                    else
                                        funderLegderEntry1."Remaining Amount" := Abs(funderLegderEntry1."Remaining Amount" + latestRemainingAmount);
                                    funderLegderEntry1.Modify();

                                end;


                            end
                            else begin
                                //Interest Payable Account 
                                // Non - Taxable 
                                //Set condition to run only of the GL in scope is not Wholding one.
                                funder3.Get(funderNo);
                                //funderLoan3.Get(_loanNo, _loanName);
                                funderLoan3.Reset();
                                funderLoan3.SetRange("No.", _loanNo);
                                if not funderLoan3.Find('-') then
                                    Error('Funder Loan %1 not found', _loanNo);

                                funderLegderEntry.Init();
                                funderLegderEntry."Entry No." := funderEntryCounter + 2;
                                funderLegderEntry."Funder No." := funderNo;
                                funderLegderEntry."Funder Name" := funderName;
                                funderLegderEntry."Loan No." := _loanNo;
                                funderLegderEntry."Loan Name" := _loanName;
                                if TrsyJnl."Currency Code" <> '' then
                                    funderLegderEntry."Currency Code" := TrsyJnl."Currency Code";
                                funderLegderEntry."Posting Date" := TrsyJnl."Posting Date";
                                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                                funderLegderEntry.Description := 'Accruing Interest calculation' + Format(Today) + TrsyJnl.Description;
                                funderLegderEntry.Amount := Abs(TrsyJnl.Amount + witHldInterest);
                                funderLegderEntry."Amount(LCY)" := Abs(TrsyJnl.Amount + witHldInterest);
                                funderLegderEntry."Remaining Amount" := Abs(TrsyJnl.Amount);
                                funderLegderEntry.Insert();

                                funderLegderEntry2.Init();
                                funderLegderEntry2."Entry No." := funderEntryCounter + 3;
                                funderLegderEntry2."Funder No." := funderNo;
                                funderLegderEntry2."Funder Name" := funderName;
                                funderLegderEntry2."Loan No." := _loanNo;
                                funderLegderEntry2."Loan Name" := _loanName;
                                if TrsyJnl."Currency Code" <> '' then
                                    funderLegderEntry2."Currency Code" := TrsyJnl."Currency Code";
                                funderLegderEntry2."Posting Date" := TrsyJnl."Posting Date";
                                funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
                                funderLegderEntry2."Document No." := TrsyJnl."Document No.";
                                funderLegderEntry2.Description := 'Remaining Amount' + Format(Today) + TrsyJnl.Description;

                                funderLegderEntry2.Amount := Abs((_amount - witHldInterest) + originalAmount);
                                funderLegderEntry2."Amount(LCY)" := Abs((_amount - witHldInterest) + originalAmount);
                                if latestRemainingAmount = 0 then begin
                                    funderLegderEntry2."Remaining Amount" := Abs((_amount - witHldInterest) + originalAmount);
                                end
                                else begin
                                    funderLegderEntry2."Remaining Amount" := Abs((_amount - witHldInterest) + latestRemainingAmount);
                                end;
                                funderLegderEntry2.Insert();

                            end;


                        end;

                    end;

                    // Increment the current batch count 
                    CurrentBatchCount := CurrentBatchCount + 1;
                until (TrsyJnl.Next() = 0) or (CurrentBatchCount >= BatchSize);
                Counter := Counter + 1;

            until TrsyJnl.Next() = 0;
            TrsyJnl.Reset();
            TrsyJnl.SetFilter("Account No.", '<>%1', '');
            if TrsyJnl.Find('-') then begin
                repeat
                // TrsyJnl.Delete();
                until TrsyJnl.Next() = 0;
            end;

            Message('Journal Accruing Interest Posting Done');
        end;


        TrsyJnl.Reset();
        TrsyJnl.SetRange("Posting Date", 0D, Today);
        TrsyJnl.SetRange(TrsyJnl."Transaction Nature", TrsyJnl."Transaction Nature"::"Interest Paid");
        if TrsyJnl.Find('-') then begin
            repeat
                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Bal. Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Bal. Account No.");
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                    end;
                end;
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Account No.");
                    _loanName := funderLoan.Name;
                    _loanNo := funderLoan."No.";
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                    end;
                end;
                //Get Total Accrued Interest
                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::Interest);
                funderLegderEntry2.CalcSums(Amount);
                totalAccruedInterest := funderLegderEntry2.Amount;

                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::"Interest Paid");
                funderLegderEntry2.CalcSums(Amount);
                totalPaidInterest := Abs(funderLegderEntry2.Amount);

                differentAccrPaidInterest := totalAccruedInterest - totalPaidInterest; // Get the floating value
                //Ensure Interest Paid does not negative Accrued Interest
                if differentAccrPaidInterest > 0 then begin
                    if differentAccrPaidInterest - Round(TrsyJnl.Amount, 0.01, '=') >= Round(TrsyJnl.Amount, 0.01, '=') then
                        _amount := Round(TrsyJnl.Amount, 0.01, '=')
                    else
                        _amount := differentAccrPaidInterest

                end else begin
                    _amount := Round(0, 0.01, '=');
                    Error('Zero Accrued Interest');
                end;

                //Get the latest remaining amount
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                funderLegderEntry.SetAscending(funderLegderEntry."Entry No.", true);
                if funderLegderEntry.FindLast() then
                    latestRemainingAmount := funderLegderEntry."Remaining Amount";
                // Get the Original Amount
                funderLegderEntry.Reset();
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Original Amount");
                funderLegderEntry.SetRange(funderLegderEntry."Funder No.", funderNo);
                // funderLegderEntry.CalcSums(Amount);
                if funderLegderEntry.FindSet() then
                    repeat
                        originalAmount := originalAmount + funderLegderEntry.Amount;
                    until funderLegderEntry.Next() = 0;
                //**********************************************
                // Posting AMOUNT
                //**********************************************

                //**********************************************
                //   Withholding on interest
                //   Depending on Tax Exceptions
                //**********************************************
                witHldInterest := 0;
                // if funder.TaxStatus = funder.TaxStatus::Taxable then begin
                //     funder.TestField(Withldtax);
                //     witHldInterest := (funder.Withldtax / 100) * _amount;
                // end;

                // **************
                // INTEREST PAYABLE (Dr) | BANK (Cr)

                JournalEntry.Init();
                JournalEntry."Journal Template Name" := 'GENERAL';
                JournalEntry."Journal Batch Name" := 'TREASURY';
                // JournalEntry."Line No." := NextEntryNo + (Counter + 1);
                // JournalEntry.Entry_ID := NextEntryNo + (Counter + 1);
                JournalEntry."Posting Date" := TrsyJnl."Posting Date";
                JournalEntry.Creation_Date := TrsyJnl."Posting Date";
                JournalEntry."Document No." := TrsyJnl."Document No.";
                JournalEntry.Description := TrsyJnl.Description;
                JournalEntry."Shortcut Dimension 1 Code" := TrsyJnl."Shortcut Dimension 1 Code";
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := interestAccPay;
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"G/L Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"Bank Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"Bank Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end
                else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Debtor then begin
                end;



                JournalEntry.Amount := _amount;
                JournalEntry.Validate(JournalEntry.Amount);
                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := interestAccPay;
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"G/L Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"Bank Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"Bank Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end
                else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Debtor then begin
                end;
                // JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"; //@@@@@@@ Credit Bank
                // JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                if TrsyJnl."Currency Code" <> '' then
                    JournalEntry."Currency Code" := TrsyJnl."Currency Code";
                GLPost.RunWithCheck(JournalEntry); // Post Dr Transaction



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
                funderLegderEntry."Loan No." := _loanNo;
                funderLegderEntry."Loan Name" := _loanName;

                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry."Posting Date" := Today;
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Interest Paid";
                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                funderLegderEntry.Description := 'Interest Paid calculation' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry.Amount := -(_amount);
                funderLegderEntry."Amount(LCY)" := -(_amount);
                funderLegderEntry."Remaining Amount" := -(_amount);
                funderLegderEntry.Insert();

                funderLegderEntry1.Init();
                funderLegderEntry1."Entry No." := funderEntryCounter + 1;
                funderLegderEntry1."Funder No." := funder."No.";
                funderLegderEntry1."Funder Name" := funder.Name;
                funderLegderEntry1."Loan No." := _loanNo;
                funderLegderEntry1."Loan Name" := _loanName;

                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry1."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry1."Posting Date" := TrsyJnl."Posting Date";
                funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                funderLegderEntry1.Description := 'Withholding calculation' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry1.Amount := witHldInterest;
                funderLegderEntry1."Amount(LCY)" := witHldInterest;
                funderLegderEntry1.Insert();

                funderLegderEntry2.Init();
                funderLegderEntry2."Entry No." := funderEntryCounter + 2;
                funderLegderEntry2."Funder No." := funder."No.";
                funderLegderEntry2."Funder Name" := funder.Name;
                funderLegderEntry2."Loan No." := _loanNo;
                funderLegderEntry2."Loan Name" := _loanName;

                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry2."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry2."Posting Date" := TrsyJnl."Posting Date";
                funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                funderLegderEntry2.Description := 'Remaining Amount' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry2.Amount := ((-_amount + witHldInterest) + originalAmount);
                funderLegderEntry2."Amount(LCY)" := ((-_amount + witHldInterest) + originalAmount);
                if latestRemainingAmount = 0 then begin
                    funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + originalAmount);
                end
                else begin
                    funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + latestRemainingAmount);
                end;
                funderLegderEntry2.Insert();


            until TrsyJnl.Next() = 0;
            TrsyJnl.Reset();
            TrsyJnl.SetFilter("Account No.", '<>%1', '');
            if TrsyJnl.Find('-') then begin
                repeat
                // TrsyJnl.Delete();
                until TrsyJnl.Next() = 0;
            end;
            Message('Journal Interest Payment Posting Done');
        end;

        TrsyJnl.Reset();
        TrsyJnl.SetRange("Posting Date", 0D, Today);
        TrsyJnl.SetRange(TrsyJnl."Transaction Nature", TrsyJnl."Transaction Nature"::Repayment);
        if TrsyJnl.Find('-') then begin
            repeat
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Account No.");
                    _loanName := funderLoan.Name;
                    _loanNo := funderLoan."No.";
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                        funderName := funderLoan.Name;
                    end;
                end;
                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Bal. Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Bal. Account No.");
                    _loanName := funderLoan.Name;
                    _loanNo := funderLoan."No.";
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                        funderName := funderLoan.Name;
                    end;
                end;
                // Get Total of Original Amount (Principal)
                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::"Original Amount");
                funderLegderEntry2.CalcSums(Amount);
                totalOriginalAmount := funderLegderEntry2.Amount;

                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::Repayment);
                funderLegderEntry2.CalcSums(Amount);
                totalWithdrawalAmount := Abs(funderLegderEntry2.Amount);

                differenceOriginalWithdrawal := totalOriginalAmount - totalWithdrawalAmount; // Get the floating value

                if differenceOriginalWithdrawal > 0 then begin
                    if differenceOriginalWithdrawal - Round(TrsyJnl.Amount, 0.01, '=') >= Round(TrsyJnl.Amount, 0.01, '=') then
                        _amount := Round(TrsyJnl.Amount, 0.01, '=')
                    else
                        _amount := differenceOriginalWithdrawal

                end else begin
                    _amount := Round(0, 0.01, '=');
                    Error('Zero Original Amount');
                end;



                //Get the latest remaining amount
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                funderLegderEntry.SetAscending(funderLegderEntry."Entry No.", true);
                if funderLegderEntry.FindLast() then
                    latestRemainingAmount := funderLegderEntry."Remaining Amount";
                // Get the Original Amount
                funderLegderEntry.Reset();
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Original Amount");
                funderLegderEntry.SetRange(funderLegderEntry."Funder No.", funderNo);
                // funderLegderEntry.CalcSums(Amount);
                if funderLegderEntry.FindSet() then
                    repeat
                        originalAmount := originalAmount + funderLegderEntry.Amount;
                    until funderLegderEntry.Next() = 0;
                //**********************************************
                // Posting AMOUNT
                //**********************************************

                //**********************************************
                //   Withholding on interest
                //   Depending on Tax Exceptions
                //**********************************************
                witHldInterest := 0;
                // if funder.TaxStatus = funder.TaxStatus::Taxable then begin
                //     funder.TestField(Withldtax);
                //     witHldInterest := (funder.Withldtax / 100) * _amount;
                // end;

                // **************
                // FUNDER A/C (Dr) | BANK (Cr)

                JournalEntry.Init();
                JournalEntry."Journal Template Name" := 'GENERAL';
                JournalEntry."Journal Batch Name" := 'TREASURY';
                // JournalEntry."Line No." := NextEntryNo + (Counter + 1);
                // JournalEntry.Entry_ID := NextEntryNo + (Counter + 1);
                JournalEntry."Posting Date" := TrsyJnl."Posting Date";
                JournalEntry.Creation_Date := TrsyJnl."Posting Date";
                JournalEntry."Document No." := TrsyJnl."Document No.";
                JournalEntry.Description := TrsyJnl.Description;
                JournalEntry."Shortcut Dimension 1 Code" := TrsyJnl."Shortcut Dimension 1 Code";
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := interestAccPay;
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"G/L Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"Bank Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"Bank Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end
                else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Debtor then begin
                    Error('Debtor not supported');
                end;
                // JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Funder A/c
                // JournalEntry."Account No." := principleAcc;
                JournalEntry.Amount := _amount;
                JournalEntry.Validate(JournalEntry.Amount);
                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := interestAccPay;
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"G/L Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"Bank Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"Bank Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end
                else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Debtor then begin
                end;
                // JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"; //@@@@@@@ Credit Bank
                // JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                if TrsyJnl."Currency Code" <> '' then
                    JournalEntry."Currency Code" := TrsyJnl."Currency Code";
                GLPost.RunWithCheck(JournalEntry); // Post Dr Transaction



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
                funderLegderEntry."Loan No." := _loanNo;
                funderLegderEntry."Loan Name" := _loanName;
                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry."Posting Date" := Today;
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Repayment;
                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                funderLegderEntry.Description := 'Repayment calculation' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry.Amount := -_amount;
                funderLegderEntry."Amount(LCY)" := -_amount;
                funderLegderEntry."Remaining Amount" := -_amount;
                funderLegderEntry.Insert();

                funderLegderEntry2.Init();
                funderLegderEntry2."Entry No." := funderEntryCounter + 1;
                funderLegderEntry2."Funder No." := funder."No.";
                funderLegderEntry2."Funder Name" := funder.Name;
                funderLegderEntry2."Loan No." := _loanNo;
                funderLegderEntry2."Loan Name" := _loanName;
                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry2."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry2."Posting Date" := TrsyJnl."Posting Date";
                funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
                funderLegderEntry2."Document No." := TrsyJnl."Document No.";
                funderLegderEntry2.Description := 'Remaining Amount (Repayment)' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry2.Amount := ((-_amount + witHldInterest) + originalAmount);
                funderLegderEntry2."Amount(LCY)" := ((-_amount + witHldInterest) + originalAmount);
                if latestRemainingAmount = 0 then begin
                    funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + originalAmount);
                end
                else begin
                    funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + latestRemainingAmount);
                end;
                funderLegderEntry2.Insert();
            until TrsyJnl.Next() = 0;
            TrsyJnl.Reset();
            TrsyJnl.SetFilter("Account No.", '<>%1', '');
            if TrsyJnl.Find('-') then begin
                repeat
                // TrsyJnl.Delete();
                until TrsyJnl.Next() = 0;
            end;
            Message('Journal Repayment Posting Done');

        end;

        TrsyJnl.Reset();
        TrsyJnl.SetRange("Posting Date", 0D, Today);
        TrsyJnl.SetRange(TrsyJnl."Transaction Nature", TrsyJnl."Transaction Nature"::"Capitalized Interest");
        if TrsyJnl.Find('-') then begin
            repeat
                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Bal. Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Bal. Account No.");
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                    end;
                end;
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Account No.");
                    _loanName := funderLoan.Name;
                    _loanNo := funderLoan."No.";
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                    end;
                end;
                //Get Total Accrued Interest
                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::Interest);
                funderLegderEntry2.CalcSums(Amount);
                totalAccruedInterest := funderLegderEntry2.Amount;

                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::"Interest Paid");
                funderLegderEntry2.CalcSums(Amount);
                totalPaidInterest := Abs(funderLegderEntry2.Amount);

                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::"Capitalized Interest");
                funderLegderEntry2.CalcSums(Amount);
                totalCapitalInterest := Abs(funderLegderEntry2.Amount);

                differentAccrPaidInterest := totalAccruedInterest + totalPaidInterest + totalCapitalInterest; // Get the floating value
                //Ensure Interest Paid does not negative Accrued Interest
                if differentAccrPaidInterest > 0 then begin
                    if differentAccrPaidInterest - Round(TrsyJnl.Amount, 0.01, '=') >= Round(TrsyJnl.Amount, 0.01, '=') then
                        _amount := Round(TrsyJnl.Amount, 0.01, '=')
                    else
                        _amount := differentAccrPaidInterest

                end else begin
                    _amount := Round(0, 0.01, '=');
                    Error('Zero Accrued Interest');
                end;

                //Get the latest remaining amount
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                funderLegderEntry.SetAscending(funderLegderEntry."Entry No.", true);
                if funderLegderEntry.FindLast() then
                    latestRemainingAmount := funderLegderEntry."Remaining Amount";
                // Get the Original Amount
                funderLegderEntry.Reset();
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Original Amount");
                funderLegderEntry.SetRange(funderLegderEntry."Funder No.", funderNo);
                // funderLegderEntry.CalcSums(Amount);
                if funderLegderEntry.FindSet() then
                    repeat
                        originalAmount := originalAmount + funderLegderEntry.Amount;
                    until funderLegderEntry.Next() = 0;
                //**********************************************
                // Posting AMOUNT
                //**********************************************

                //**********************************************
                //   Withholding on interest
                //   Depending on Tax Exceptions
                //**********************************************
                witHldInterest := 0;
                // if funder.TaxStatus = funder.TaxStatus::Taxable then begin
                //     funder.TestField(Withldtax);
                //     witHldInterest := (funder.Withldtax / 100) * _amount;
                // end;

                // **************
                // INTEREST PAYABLE (Dr) | BANK (Cr)

                JournalEntry.Init();
                JournalEntry."Journal Template Name" := 'GENERAL';
                JournalEntry."Journal Batch Name" := 'TREASURY';
                // JournalEntry."Line No." := NextEntryNo + (Counter + 1);
                // JournalEntry.Entry_ID := NextEntryNo + (Counter + 1);
                JournalEntry."Posting Date" := TrsyJnl."Posting Date";
                JournalEntry.Creation_Date := TrsyJnl."Posting Date";
                JournalEntry."Document No." := TrsyJnl."Document No.";
                JournalEntry.Description := TrsyJnl.Description;
                JournalEntry."Shortcut Dimension 1 Code" := TrsyJnl."Shortcut Dimension 1 Code";
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := interestAccPay;
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"G/L Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"Bank Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"Bank Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end
                else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Debtor then begin
                end;



                JournalEntry.Amount := _amount;
                JournalEntry.Validate(JournalEntry.Amount);
                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := interestAccPay;
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"G/L Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"Bank Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"Bank Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end
                else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Debtor then begin
                end;
                // JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"; //@@@@@@@ Credit Bank
                // JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                if TrsyJnl."Currency Code" <> '' then
                    JournalEntry."Currency Code" := TrsyJnl."Currency Code";
                GLPost.RunWithCheck(JournalEntry); // Post Dr Transaction



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
                funderLegderEntry."Loan No." := _loanNo;
                funderLegderEntry."Loan Name" := _loanName;

                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry."Posting Date" := Today;
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Capitalized Interest";
                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                funderLegderEntry.Description := 'Interest Capitalization' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry.Amount := -(_amount);
                funderLegderEntry."Amount(LCY)" := -(_amount);
                funderLegderEntry."Remaining Amount" := -(_amount);
                funderLegderEntry.Insert();

                funderLegderEntry1.Init();
                funderLegderEntry1."Entry No." := funderEntryCounter + 1;
                funderLegderEntry1."Funder No." := funder."No.";
                funderLegderEntry1."Funder Name" := funder.Name;
                funderLegderEntry1."Loan No." := _loanNo;
                funderLegderEntry1."Loan Name" := _loanName;

                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry1."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry1."Posting Date" := TrsyJnl."Posting Date";
                funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::"Secondary Amount";
                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                funderLegderEntry1.Description := 'Addional Original from Capitalization' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry1.Amount := _amount;
                funderLegderEntry1."Amount(LCY)" := _amount;
                funderLegderEntry1.Insert();

                // funderLegderEntry2.Init();
                // funderLegderEntry2."Entry No." := funderEntryCounter + 2;
                // funderLegderEntry2."Funder No." := funder."No.";
                // funderLegderEntry2."Funder Name" := funder.Name;
                // funderLegderEntry2."Loan No." := _loanNo;
                // funderLegderEntry2."Loan Name" := _loanName;

                // if TrsyJnl."Currency Code" <> '' then
                //     funderLegderEntry2."Currency Code" := TrsyJnl."Currency Code";
                // funderLegderEntry2."Posting Date" := TrsyJnl."Posting Date";
                // funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
                // funderLegderEntry."Document No." := TrsyJnl."Document No.";
                // funderLegderEntry2.Description := 'Remaining Amount' + Format(Today) + TrsyJnl.Description;
                // funderLegderEntry2.Amount := ((-_amount + witHldInterest) + originalAmount);
                // funderLegderEntry2."Amount(LCY)" := ((-_amount + witHldInterest) + originalAmount);
                // if latestRemainingAmount = 0 then begin
                //     funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + originalAmount);
                // end
                // else begin
                //     funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + latestRemainingAmount);
                // end;
                // funderLegderEntry2.Insert();

                //+++++++++++++++++++++ EMAIL THE FUNDER ON THE NEW PRINCIPAL
                EmailingCU.EmailFunderOnNewPrincipalFromCapitalization(_loanNo);
            until TrsyJnl.Next() = 0;
            TrsyJnl.Reset();
            TrsyJnl.SetFilter("Account No.", '<>%1', '');
            if TrsyJnl.Find('-') then begin
                repeat
                // TrsyJnl.Delete();
                until TrsyJnl.Next() = 0;
            end;
            Message('Interest Capitalization Posting Done');
        end;


    end;

    //---------- UNUSED
    procedure PostCapitalization()
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";
        TrsyJnl: Record "Trsy Journal";
        Counter: Integer;
        funder: Record Funders;
        funderLoan: Record "Funder Loan";
        funderLoan2: Record "Funder Loan";
        totalAccruedInterest: Decimal;
        totalPaidInterest: Decimal;
        differentAccrPaidInterest: Decimal;
        totalOriginalAmount: Decimal;
        totalWithdrawalAmount: Decimal;
        differenceOriginalWithdrawal: Decimal;
        funderEntryCounter: Integer;
        debtorEntryCounter: Integer;
        funderLegderEntry: Record FunderLedgerEntry;
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        looper: Record FunderLedgerEntry;
        venPostingGroup: record "Treasury Posting Group";
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
        generalSetup: Record "Treasury General Setup";
        funderNo: Code[100];
        funderName: Text[100];
        _loanNo: Code[100];
        _loanName: Code[100];
        originalAmount: Decimal;
        _auxAmount: Decimal;
    begin
        // TrsyJnl."Account Type":=TrsyJnl."Account Type"::Funder;
        TrsyJnl.Reset();
        // TrsyJnl.SetRange("Posting Date", 0D, Today);
        TrsyJnl.SetRange(TrsyJnl."Transaction Nature", TrsyJnl."Transaction Nature"::"Capitalized Interest");
        if TrsyJnl.Find('-') then begin
            repeat
                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Bal. Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Bal. Account No.");
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                    end;
                end;
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", TrsyJnl."Account No.");
                    if not funderLoan.Find('-') then// Get the Loan Details
                        Error('Funder Loan = %1, dont exist.', TrsyJnl."Account No.");
                    _loanName := funderLoan.Name;
                    _loanNo := funderLoan."No.";
                    if funder.Get(funderLoan."Funder No.") then begin

                        //**********************************************
                        //          Get Posting groups & Posting Accounts
                        //**********************************************
                        // if not venPostingGroup.Get(funderLoan."Posting Group") then
                        //     Error('Missing Posting Group: %1', funder."No.");
                        interestAccExpense := funderLoan."Interest Expense";
                        if interestAccExpense = '' then
                            Error('Missing Interest Expense A/C: %1', funder."No.");
                        interestAccPay := funderLoan."Interest Payable";
                        if interestAccPay = '' then
                            Error('Missing Interest Payable A/C: %1', funder."No.");
                        principleAcc := funderLoan."Payables Account";
                        if principleAcc = '' then
                            Error('Missing Principle A/C: %1', funder."No.");
                        if not generalSetup.FindFirst() then
                            Error('Please Define Withholding Tax under General Setup');
                        withholdingAcc := generalSetup.FunderWithholdingAcc;
                        funderNo := funderLoan."Funder No.";
                    end;
                end;
                //Get Total Accrued Interest
                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::Interest);
                funderLegderEntry2.CalcSums(Amount);
                totalAccruedInterest := funderLegderEntry2.Amount;

                funderLegderEntry2.Reset();
                funderLegderEntry2.SetRange("Funder No.", funderNo);
                funderLegderEntry2.SetRange(funderLegderEntry2."Document Type", funderLegderEntry2."Document Type"::"Capitalized Interest");
                funderLegderEntry2.CalcSums(Amount);
                totalPaidInterest := Abs(funderLegderEntry2.Amount);

                differentAccrPaidInterest := totalAccruedInterest - totalPaidInterest; // Get the floating value
                //Ensure Interest Paid does not negative Accrued Interest
                if differentAccrPaidInterest > 0 then begin
                    if differentAccrPaidInterest - Round(TrsyJnl.Amount, 0.01, '=') >= Round(TrsyJnl.Amount, 0.01, '=') then
                        _amount := Round(TrsyJnl.Amount, 0.01, '=')
                    else
                        _amount := differentAccrPaidInterest

                end else begin
                    _amount := Round(0, 0.01, '=');
                    Error('Zero Accrued Interest');
                end;

                //Get the latest remaining amount
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                funderLegderEntry.SetAscending(funderLegderEntry."Entry No.", true);
                if funderLegderEntry.FindLast() then
                    latestRemainingAmount := funderLegderEntry."Remaining Amount";
                // Get the Original Amount
                funderLegderEntry.Reset();
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Original Amount");
                funderLegderEntry.SetRange(funderLegderEntry."Funder No.", funderNo);
                // funderLegderEntry.CalcSums(Amount);
                if funderLegderEntry.FindSet() then
                    repeat
                        originalAmount := originalAmount + funderLegderEntry.Amount;
                    until funderLegderEntry.Next() = 0;
                //**********************************************
                // Posting AMOUNT
                //**********************************************

                //**********************************************
                //   Withholding on interest
                //   Depending on Tax Exceptions
                //**********************************************
                witHldInterest := 0;
                // if funder.TaxStatus = funder.TaxStatus::Taxable then begin
                //     funder.TestField(Withldtax);
                //     witHldInterest := (funder.Withldtax / 100) * _amount;
                // end;

                // **************
                // INTEREST PAYABLE (Dr) | BANK (Cr)

                JournalEntry.Init();
                JournalEntry."Journal Template Name" := 'GENERAL';
                JournalEntry."Journal Batch Name" := 'TREASURY';
                // JournalEntry."Line No." := NextEntryNo + (Counter + 1);
                // JournalEntry.Entry_ID := NextEntryNo + (Counter + 1);
                JournalEntry."Posting Date" := TrsyJnl."Posting Date";
                JournalEntry.Creation_Date := TrsyJnl."Posting Date";
                JournalEntry."Document No." := TrsyJnl."Document No.";
                JournalEntry.Description := TrsyJnl.Description;
                JournalEntry."Shortcut Dimension 1 Code" := TrsyJnl."Shortcut Dimension 1 Code";
                if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Funder then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := interestAccPay;
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"G/L Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"G/L Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::"Bank Account" then begin
                    JournalEntry."Account Type" := TrsyJnl."Account Type"::"Bank Account"; //@@@@@ Debit Int Payable
                    JournalEntry."Account No." := TrsyJnl."Account No.";
                end
                else if TrsyJnl."Account Type" = TrsyJnl."Account Type"::Debtor then begin
                end;



                JournalEntry.Amount := _amount;
                if JournalEntry."Currency Code" <> '' then
                    JournalEntry.Validate(JournalEntry.Amount);

                if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Funder then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := interestAccPay;
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"G/L Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"G/L Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::"Bank Account" then begin
                    JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"::"Bank Account"; //@@@@@@@ Credit Bank
                    JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                end
                else if TrsyJnl."Bal. Account Type" = TrsyJnl."Bal. Account Type"::Debtor then begin
                end;
                // JournalEntry."Bal. Account Type" := TrsyJnl."Bal. Account Type"; //@@@@@@@ Credit Bank
                // JournalEntry."Bal. Account No." := TrsyJnl."Bal. Account No.";
                if TrsyJnl."Currency Code" <> '' then
                    JournalEntry."Currency Code" := TrsyJnl."Currency Code";
                GLPost.RunWithCheck(JournalEntry); // Post Dr Transaction



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
                funderLegderEntry."Loan No." := _loanNo;
                funderLegderEntry."Loan Name" := _loanName;

                if TrsyJnl."Currency Code" <> '' then
                    funderLegderEntry."Currency Code" := TrsyJnl."Currency Code";
                funderLegderEntry."Posting Date" := Today;
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Capitalized Interest";
                funderLegderEntry."Document No." := TrsyJnl."Document No.";
                funderLegderEntry.Description := 'Interest Capitalization' + Format(Today) + TrsyJnl.Description;
                funderLegderEntry.Amount := -(_amount);
                funderLegderEntry."Amount(LCY)" := -(_amount);
                funderLegderEntry."Remaining Amount" := -(_amount);
                funderLegderEntry.Insert();

            // funderLegderEntry1.Init();
            // funderLegderEntry1."Entry No." := funderEntryCounter + 1;
            // funderLegderEntry1."Funder No." := funder."No.";
            // funderLegderEntry1."Funder Name" := funder.Name;
            // funderLegderEntry1."Loan No." := _loanNo;
            // funderLegderEntry1."Loan Name" := _loanName;

            // if TrsyJnl."Currency Code" <> '' then
            //     funderLegderEntry1."Currency Code" := TrsyJnl."Currency Code";
            // funderLegderEntry1."Posting Date" := TrsyJnl."Posting Date";
            // funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
            // funderLegderEntry."Document No." := TrsyJnl."Document No.";
            // funderLegderEntry1.Description := 'Withholding calculation' + Format(Today) + TrsyJnl.Description;
            // funderLegderEntry1.Amount := witHldInterest;
            // funderLegderEntry1."Amount(LCY)" := witHldInterest;
            // funderLegderEntry1.Insert();

            // funderLegderEntry2.Init();
            // funderLegderEntry2."Entry No." := funderEntryCounter + 2;
            // funderLegderEntry2."Funder No." := funder."No.";
            // funderLegderEntry2."Funder Name" := funder.Name;
            // funderLegderEntry2."Loan No." := _loanNo;
            // funderLegderEntry2."Loan Name" := _loanName;

            // if TrsyJnl."Currency Code" <> '' then
            //     funderLegderEntry2."Currency Code" := TrsyJnl."Currency Code";
            // funderLegderEntry2."Posting Date" := TrsyJnl."Posting Date";
            // funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
            // funderLegderEntry."Document No." := TrsyJnl."Document No.";
            // funderLegderEntry2.Description := 'Remaining Amount' + Format(Today) + TrsyJnl.Description;
            // funderLegderEntry2.Amount := ((-_amount + witHldInterest) + originalAmount);
            // funderLegderEntry2."Amount(LCY)" := ((-_amount + witHldInterest) + originalAmount);
            // if latestRemainingAmount = 0 then begin
            //     funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + originalAmount);
            // end
            // else begin
            //     funderLegderEntry2."Remaining Amount" := ((-_amount + witHldInterest) + latestRemainingAmount);
            // end;
            // funderLegderEntry2.Insert();


            until TrsyJnl.Next() = 0;
            TrsyJnl.Reset();
            TrsyJnl.SetFilter("Account No.", '<>%1', '');
            if TrsyJnl.Find('-') then begin
                repeat
                // TrsyJnl.Delete();
                until TrsyJnl.Next() = 0;
            end;
            Message('Interest Capitalization Posting Done');
        end;

    end;
    //*********** END-UNUSED

    //Validate Email
    // procedure IsValidEmail(EmailAddress: Text): Boolean
    // var
    //     Regex: Codeunit Regex;
    // begin

    //     exit(Regex.IsMatch(
    //         EmailAddress.Trim(),
    //         '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    //     ));
    // end;

    procedure IsValidEmail(EmailAddress: Text): Boolean
    var
        Regex: Codeunit Regex;
        Pattern: Text;
    begin
        if EmailAddress = '' then
            exit(false);

        // Trim whitespace
        EmailAddress := DelChr(EmailAddress.Trim(), '<>');

        // Comprehensive RFC 5322 compliant regex pattern
        Pattern := '^(?:(?:(?:[a-zA-Z0-9_\-\.\+])+|"(?:[\\\x01-\\\x08\\\x0b\\\x0c\\\x0e-\\\x1f\\\x21\\\x23-\\\x5b\\\x5d-\\\x7f]|(?:\\[\\\x00-\\\x7f]))*")@(?:(?:[a-zA-Z0-9\-])+\.)+(?:[a-zA-Z]{2,63})|\[(?:(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\.){3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)|[a-zA-Z0-9\-]*[a-zA-Z0-9]:(?:[\\\x01-\\\x08\\\x0b\\\x0c\\\x0e-\\\x1f\\\x21-\\\x5a\\\x53-\\\x7f]|\\[\\\x00-\\\x7f])+)\]))$';

        if not Regex.IsMatch(EmailAddress, Pattern) then
            exit(false);

        // Additional length validation (RFC 5321)
        if StrLen(EmailAddress) > 254 then
            exit(false);

        // Check for consecutive dots in domain part
        if StrPos(EmailAddress, '..') > 0 then
            exit(false);

        exit(true);
    end;

    procedure ValidateQuarterEndDate(DateToCheck: Date)
    var
        QuarterEndDates: List of [Date];
        IsValid: Boolean;
        Year: Integer;
    begin
        if DateToCheck = 0D then
            exit; // Allow blank dates if needed

        Year := Date2DMY(DateToCheck, 3); // Get year from date

        // Create list of quarter end dates for the year
        QuarterEndDates.Add(DMY2Date(31, 3, Year));
        QuarterEndDates.Add(DMY2Date(30, 6, Year));
        QuarterEndDates.Add(DMY2Date(30, 9, Year));
        QuarterEndDates.Add(DMY2Date(31, 12, Year));

        IsValid := QuarterEndDates.Contains(DateToCheck);

        if not IsValid then
            Error('Date %1 must be a quarter end date (March 31, June 30, September 30, or December 31)', DateToCheck);
    end;

    procedure IsTodayEndOfMonth(): Boolean
    var
        TodayDate: Date;
        EndOfMonthDate: Date;
    begin
        TodayDate := Today;
        EndOfMonthDate := CALCDATE('<CM>', TodayDate);

        exit(TodayDate = EndOfMonthDate);
    end;

    procedure IsTodayEndOfQuarter(): Boolean
    var
        TodayDate: Date;
        EndOfQuarterDate: Date;
    begin
        TodayDate := Today;
        EndOfQuarterDate := CalculateEndOfQuarter(TodayDate);

        exit(TodayDate = EndOfQuarterDate);
    end;

    local procedure CalculateEndOfQuarter(InputDate: Date): Date
    var
        Month: Integer;
        Quarter: Integer;
        Year: Integer;
    begin
        Month := Date2DMY(InputDate, 2); // Get month component
        Year := Date2DMY(InputDate, 3); // Get year component

        // Determine which quarter we're in (1-4)
        Quarter := (Month - 1) div 3 + 1;

        // Calculate last month of the quarter
        Month := Quarter * 3;

        // Return the last day of that month
        exit(DMY2Date(31, Month, Year)); // This automatically adjusts for months with fewer days
    end;

    procedure IsTodayEndOfBiAnnual(): Boolean
    var
        TodayDate: Date;
        EndOfBiAnnualDate: Date;
    begin
        TodayDate := Today;
        EndOfBiAnnualDate := CalculateEndOfBiAnnual(TodayDate);

        exit(TodayDate = EndOfBiAnnualDate);
    end;

    local procedure CalculateEndOfBiAnnual(InputDate: Date): Date
    var
        Month: Integer;
        Year: Integer;
    begin
        Month := Date2DMY(InputDate, 2); // Get month component
        Year := Date2DMY(InputDate, 3);  // Get year component

        // Determine which half-year we're in (1 or 2)
        if Month <= 6 then
            // First half-year ends June 30
            exit(DMY2Date(30, 6, Year))
        else
            // Second half-year ends December 31
            exit(DMY2Date(31, 12, Year));
    end;

    procedure IsTodayEndOfYear(): Boolean
    begin
        // December 31 is always the last day of the year
        exit((Date2DMY(Today, 2) = 12) and (Date2DMY(Today, 1) = 31));
    end;

    procedure GetDaysUntilMonthEnd(): Integer
    var
        TodayDate: Date;
        EndOfMonthDate: Date;
    begin
        TodayDate := Today;
        EndOfMonthDate := CALCDATE('<CM>', TodayDate); // Gets last day of current month
        exit(EndOfMonthDate - TodayDate);
    end;

    procedure GetDaysUntilQuarterEnd(): Integer
    var
        TodayDate: Date;
        Month: Integer;
        Year: Integer;
        QuarterEndDate: Date;
    begin
        TodayDate := Today;
        Month := Date2DMY(TodayDate, 2);
        Year := Date2DMY(TodayDate, 3);

        case true of
            Month in [1 .. 3]: // Q1 ends March 31
                QuarterEndDate := DMY2Date(31, 3, Year);
            Month in [4 .. 6]: // Q2 ends June 30
                QuarterEndDate := DMY2Date(30, 6, Year);
            Month in [7 .. 9]: // Q3 ends September 30
                QuarterEndDate := DMY2Date(30, 9, Year);
            Month in [10 .. 12]: // Q4 ends December 31
                QuarterEndDate := DMY2Date(31, 12, Year);
        end;

        exit(QuarterEndDate - TodayDate);
    end;

    procedure GetDaysUntilBiAnnualEnd(): Integer
    var
        TodayDate: Date;
        Month: Integer;
        Year: Integer;
        BiAnnualEndDate: Date;
    begin
        TodayDate := Today;
        Month := Date2DMY(TodayDate, 2);
        Year := Date2DMY(TodayDate, 3);

        if Month <= 6 then
            // First half ends June 30
            BiAnnualEndDate := DMY2Date(30, 6, Year)
        else
            // Second half ends December 31
            BiAnnualEndDate := DMY2Date(31, 12, Year);

        exit(BiAnnualEndDate - TodayDate);
    end;

    procedure GetDaysUntilYearEnd(): Integer
    var
        TodayDate: Date;
        YearEndDate: Date;
    begin
        TodayDate := Today;
        YearEndDate := DMY2Date(31, 12, Date2DMY(TodayDate, 3)); // December 31 of current year
        exit(YearEndDate - TodayDate);
    end;

    // Check if any interest for this loan has been computed for this month.
    procedure CheckIfAnyInterestWasCalculatedForThisMonth(RedemptionDate: Date; LoanNo: Code[20]; PayingBankCode: Code[50])
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
        TotalInterestAmountLCY: Decimal;
    begin
        monthNo := Date2DMY(RedemptionDate, 2);
        yearNo := Date2DMY(RedemptionDate, 3);
        startMonth := CalcDate('<-CM>', RedemptionDate);
        endMonth := CalcDate('<+CM>', RedemptionDate);

        funderLegderEntry.Reset();
        if funderLegderEntry.FindLast() then
            NextEntryNo := funderLegderEntry."Entry No." + 1;

        funderLegderEntry_1.Reset();
        funderLegderEntry_1.SetRange("Loan No.", LoanNo);
        funderLegderEntry_1.SetRange("Document Type", funderLegderEntry."Document Type"::Interest);
        funderLegderEntry_1.SetRange("Posting Date", startMonth, endMonth);
        if funderLegderEntry_1.Find('-') then begin

            funder.Reset();
            funder.SetRange("No.", funderLegderEntry_1."Funder No.");
            if not funder.Find('-') then
                Error('Funder %1 Not Found', funderLegderEntry_1."Funder No.");

            funderLoan3.Reset();
            funderLoan3.SetRange("No.", funderLegderEntry_1."Loan No.");
            if not funderLoan3.Find('-') then
                Error('Funder Loan %1 Not Found', funderLegderEntry_1."Loan No.");

            funderLegderEntry.Init();
            funderLegderEntry."Entry No." := NextEntryNo;
            funderLegderEntry."Funder No." := funder."No.";
            funderLegderEntry."Funder Name" := funder.Name;
            funderLegderEntry."Loan Name" := funderLegderEntry_1."Loan Name";
            funderLegderEntry."Loan No." := funderLegderEntry_1."Loan No.";
            funderLegderEntry."Posting Date" := RedemptionDate;
            funderLegderEntry."Document No." := funderLegderEntry_1."Document No.";
            funderLegderEntry.Category := funderLegderEntry_1.Category; // Funder Loan Category
            funderLegderEntry."Document Type" := funderLegderEntry_1."Document Type"::"Reversed Interest";
            funderLegderEntry.Description := 'Interest Reversal calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(Today);
            funderLegderEntry.Amount := -funderLegderEntry_1.Amount;
            funderLegderEntry."Amount(LCY)" := -funderLegderEntry_1."Amount(LCY)";
            funderLegderEntry."Remaining Amount" := funderLegderEntry_1."Remaining Amount";
            funderLegderEntry.Insert();
            if (funderLoan3.EnableGLPosting = true) and (funderLegderEntry_1.Amount <> 0) then
                FunderMGTCU.DirectGLPosting('reverse-interest', funderLoan3."Interest Payable", funderLegderEntry_1.Amount, 'Interest', funderLoan3."No.", PayingBankCode, '', '', '', funderLoan3."Bank Ref. No.");//reverse Interest (Db Paying Bank)

            //Create a Correction One.
            FunderMGTCU.CalculateInterest(LoanNo, RedemptionDate, PayingBankCode);
        end else begin
            //Create a new One.
            FunderMGTCU.CalculateInterest(LoanNo, RedemptionDate, PayingBankCode);
        end;
        // recondsCount := funderLegderEntry_1.Count();
        // Clear All our Interests
        TotalInterestAmount := 0;
        TotalInterestAmountLCY := 0;
        funderLegderEntry.Reset();
        funderLegderEntry.SetRange("Loan No.", LoanNo);
        funderLegderEntry.SetFilter("Document Type", '=%1|=%2|=%3|=%4', funderLegderEntry."Document Type"::Interest, funderLegderEntry."Document Type"::"Interest Paid", funderLegderEntry."Document Type"::"Capitalized Interest", funderLegderEntry."Document Type"::"Reversed Interest");
        // funderLegderEntry.SetRange("Document Type", funderLegderEntry."Document Type"::Interest);
        // funderLegderEntry.SetRange("Document Type", funderLegderEntry."Document Type"::"Interest Paid");
        // funderLegderEntry.SetRange("Document Type", funderLegderEntry."Document Type"::"Capitalized Interest");
        // funderLegderEntry.SetRange("Document Type", funderLegderEntry."Document Type"::"Reversed Interest");
        if funderLegderEntry.Find('-') then begin
            repeat
                TotalInterestAmount := TotalInterestAmount + funderLegderEntry.Amount;
                TotalInterestAmountLCY := TotalInterestAmountLCY + funderLegderEntry."Amount(LCY)";
            until funderLegderEntry.Next() = 0;
        end;
        // funderLegderEntry.CalcSums(Amount);
        // TotalInterestAmount := funderLegderEntry.Amount;
        // funderLegderEntry.CalcSums("Amount(LCY)");
        // TotalInterestAmountLCY := funderLegderEntry."Amount(LCY)";

        funderLoan3.Reset();
        funderLoan3.SetRange("No.", LoanNo);
        if not funderLoan3.Find('-') then
            Error('Funder Loan %1 Not Found', LoanNo);

        funderLegderEntry_2.Init();
        funderLegderEntry_2."Entry No." := NextEntryNo + 6;
        funderLegderEntry_2."Funder No." := funder."No.";
        funderLegderEntry_2."Funder Name" := funder.Name;
        funderLegderEntry_2."Loan Name" := funderLoan3."Loan Name";
        funderLegderEntry_2."Loan No." := funderLoan3."No.";
        funderLegderEntry_2."Posting Date" := RedemptionDate;
        funderLegderEntry_2."Document No." := funderLegderEntry_1."Document No.";
        funderLegderEntry_2.Category := funderLoan3.Category; // Funder Loan Category
        funderLegderEntry_2."Document Type" := funderLegderEntry_2."Document Type"::"Interest Paid";
        funderLegderEntry_2.Description := 'Interest Redemption Payment calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(Today);
        funderLegderEntry_2.Amount := -(TotalInterestAmount);
        funderLegderEntry_2."Amount(LCY)" := -(TotalInterestAmountLCY);
        // funderLegderEntry_2."Remaining Amount" := funderLegderEntry_1."Remaining Amount";
        funderLegderEntry_2.Insert();
        if (funderLoan3.EnableGLPosting = true) and (TotalInterestAmount <> 0) then
            FunderMGTCU.DirectGLPosting('interest-payment', funderLoan3."Interest Payable", TotalInterestAmount, 'Interest', LoanNo, PayingBankCode, '', '', '', funderLoan3."Bank Ref. No.");//Clear All the Interest (Db Paying Bank)


    end;

    procedure PartialRedemptionPostings(RedemptionDate: Date; LoanNo: Code[20]; PayingBankCode: Code[50]; FloatingPrinci: Decimal; FloatingInter: Decimal; PartialAmount: Decimal)
    var
        funderLegderEntry: Record FunderLedgerEntry;
        funderLegderEntry_1: Record FunderLedgerEntry;
        funderLegderEntry_2: Record FunderLedgerEntry;
        funderLegderEntry_3: Record FunderLedgerEntry;
        startMonth: Date;
        endMonth: date;
        monthNo: Integer;
        yearNo: Integer;
        recondsCount: Integer;
        funder: Record Funders;

        NextEntryNo: Integer;

        TotalInterestAmount: Decimal;
        TotalInterestAmountLCY: Decimal;
        RedemptionLogs: Record "Redemption Log Tbl";
    begin
        monthNo := Date2DMY(RedemptionDate, 2);
        yearNo := Date2DMY(RedemptionDate, 3);
        startMonth := CalcDate('<-CM>', RedemptionDate);
        endMonth := CalcDate('<+CM>', RedemptionDate);

        funderLegderEntry.Reset();
        if funderLegderEntry.FindLast() then
            NextEntryNo := funderLegderEntry."Entry No." + 1;

        funderLegderEntry_1.Reset();
        funderLegderEntry_1.SetRange("Loan No.", LoanNo);
        funderLegderEntry_1.SetRange("Document Type", funderLegderEntry."Document Type"::Interest);
        funderLegderEntry_1.SetRange("Posting Date", startMonth, endMonth);
        if funderLegderEntry_1.Find('-') then begin

            funder.Reset();
            funder.SetRange("No.", funderLegderEntry_1."Funder No.");
            if not funder.Find('-') then
                Error('Funder %1 Not Found', funderLegderEntry_1."Funder No.");

            funderLoan3.Reset();
            funderLoan3.SetRange("No.", funderLegderEntry_1."Loan No.");
            if not funderLoan3.Find('-') then
                Error('Funder Loan %1 Not Found', funderLegderEntry_1."Loan No.");

            funderLegderEntry.Init();
            funderLegderEntry."Entry No." := NextEntryNo;
            funderLegderEntry."Funder No." := funder."No.";
            funderLegderEntry."Funder Name" := funder.Name;
            funderLegderEntry."Loan Name" := funderLegderEntry_1."Loan Name";
            funderLegderEntry."Loan No." := funderLegderEntry_1."Loan No.";
            funderLegderEntry."Posting Date" := RedemptionDate;
            funderLegderEntry."Document No." := funderLegderEntry_1."Document No.";
            funderLegderEntry.Category := funderLegderEntry_1.Category; // Funder Loan Category
            funderLegderEntry."Document Type" := funderLegderEntry_1."Document Type"::"Reversed Interest";
            funderLegderEntry.Description := 'Interest Reversal calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(Today);
            funderLegderEntry.Amount := -funderLegderEntry_1.Amount;
            funderLegderEntry."Amount(LCY)" := -funderLegderEntry_1."Amount(LCY)";
            funderLegderEntry."Remaining Amount" := funderLegderEntry_1."Remaining Amount";
            funderLegderEntry.Insert();
            if (funderLoan3.EnableGLPosting = true) and (funderLegderEntry_1.Amount <> 0) then
                FunderMGTCU.DirectGLPosting('reverse-interest', funderLoan3."Interest Payable", funderLegderEntry_1.Amount, 'Interest', funderLoan3."No.", PayingBankCode, '', '', '', funderLoan3."Bank Ref. No.");//reverse Interest (Db Paying Bank)

            //Create a Correction One.
            FunderMGTCU.CalculateInterestForPartial(LoanNo, RedemptionDate, PayingBankCode);
        end else begin
            //Create a new One.
            FunderMGTCU.CalculateInterestForPartial(LoanNo, RedemptionDate, PayingBankCode);
        end;
        // recondsCount := funderLegderEntry_1.Count();
        // Clear All our Interests
        TotalInterestAmount := 0;
        TotalInterestAmountLCY := 0;
        funderLegderEntry.Reset();
        funderLegderEntry.SetRange("Loan No.", LoanNo);
        funderLegderEntry.SetFilter("Document Type", '=%1|=%2|=%3|=%4', funderLegderEntry."Document Type"::Interest, funderLegderEntry."Document Type"::"Interest Paid", funderLegderEntry."Document Type"::"Capitalized Interest", funderLegderEntry."Document Type"::"Reversed Interest");

        if funderLegderEntry.Find('-') then begin
            repeat
                TotalInterestAmount := TotalInterestAmount + funderLegderEntry.Amount;
                TotalInterestAmountLCY := TotalInterestAmountLCY + funderLegderEntry."Amount(LCY)";
            until funderLegderEntry.Next() = 0;
        end;
        // funderLegderEntry.CalcSums(Amount);
        // TotalInterestAmount := funderLegderEntry.Amount;
        // funderLegderEntry.CalcSums("Amount(LCY)");
        // TotalInterestAmountLCY := funderLegderEntry."Amount(LCY)";
        if FloatingInter - PartialAmount > 0 then begin
            funderLoan3.Reset();
            funderLoan3.SetRange("No.", LoanNo);
            if not funderLoan3.Find('-') then
                Error('Funder Loan %1 Not Found', LoanNo);

            funderLegderEntry_2.Init();
            funderLegderEntry_2."Entry No." := NextEntryNo + 6;
            funderLegderEntry_2."Funder No." := funder."No.";
            funderLegderEntry_2."Funder Name" := funder.Name;
            funderLegderEntry_2."Loan Name" := funderLoan3."Loan Name";
            funderLegderEntry_2."Loan No." := funderLoan3."No.";
            funderLegderEntry_2."Posting Date" := RedemptionDate;
            funderLegderEntry_2."Document No." := funderLegderEntry_1."Document No.";
            funderLegderEntry_2.Category := funderLoan3.Category; // Funder Loan Category
            funderLegderEntry_2."Document Type" := funderLegderEntry_2."Document Type"::"Interest Paid";
            funderLegderEntry_2.Description := 'Interest Redemption Payment calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(Today);
            funderLegderEntry_2.Amount := -(PartialAmount);
            funderLegderEntry_2."Amount(LCY)" := -(PartialAmount);
            // funderLegderEntry_2."Remaining Amount" := funderLegderEntry_1."Remaining Amount";
            funderLegderEntry_2.Insert();
            if (funderLoan3.EnableGLPosting = true) and (PartialAmount <> 0) then
                FunderMGTCU.DirectGLPosting('interest-payment', funderLoan3."Interest Payable", PartialAmount, 'Interest', LoanNo, PayingBankCode, '', '', '', funderLoan3."Bank Ref. No.");//Clear All the Interest (Db Paying Bank)

            RedemptionLogs.Reset();
            RedemptionLogs.SetRange("Loan No.", LoanNo);
            RedemptionLogs.SetRange(RedemptionLogs.RedemptionType, RedemptionLogs.RedemptionType::"Partial Redemption");
            if RedemptionLogs.Find('-') then begin
                RedemptionLogs.IntrAmountRemoved := PartialAmount;
                RedemptionLogs.PrincAmountRemoved := 0;
                RedemptionLogs.RemainingAmount := (RedemptionLogs.FloatingPrinc + RedemptionLogs.FloatingIntr) - PartialAmount;
                RedemptionLogs.Modify();
            end;

        end;
        if FloatingInter - PartialAmount < 0 then begin
            funderLoan3.Reset();
            funderLoan3.SetRange("No.", LoanNo);
            if not funderLoan3.Find('-') then
                Error('Funder Loan %1 Not Found', LoanNo);

            funderLegderEntry_2.Init();
            funderLegderEntry_2."Entry No." := NextEntryNo + 6;
            funderLegderEntry_2."Funder No." := funder."No.";
            funderLegderEntry_2."Funder Name" := funder.Name;
            funderLegderEntry_2."Loan Name" := funderLoan3."Loan Name";
            funderLegderEntry_2."Loan No." := funderLoan3."No.";
            funderLegderEntry_2."Posting Date" := RedemptionDate;
            funderLegderEntry_2."Document No." := funderLegderEntry_1."Document No.";
            funderLegderEntry_2.Category := funderLoan3.Category; // Funder Loan Category
            funderLegderEntry_2."Document Type" := funderLegderEntry_2."Document Type"::"Interest Paid";
            funderLegderEntry_2.Description := 'Interest Redemption Payment calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(Today);
            funderLegderEntry_2.Amount := -(FloatingInter);
            funderLegderEntry_2."Amount(LCY)" := -(FloatingInter);
            // funderLegderEntry_2."Remaining Amount" := funderLegderEntry_1."Remaining Amount";
            funderLegderEntry_2.Insert();
            if (funderLoan3.EnableGLPosting = true) and (FloatingInter <> 0) then
                FunderMGTCU.DirectGLPosting('interest-payment', funderLoan3."Interest Payable", FloatingInter, 'Interest', LoanNo, PayingBankCode, '', '', '', funderLoan3."Bank Ref. No.");//Clear All the Interest (Db Paying Bank)

            funderLegderEntry_3.Init();
            funderLegderEntry_3."Entry No." := NextEntryNo + 8;
            funderLegderEntry_3."Funder No." := funder."No.";
            funderLegderEntry_3."Funder Name" := funder.Name;
            funderLegderEntry_3."Loan Name" := funderLoan3."Loan Name";
            funderLegderEntry_3."Loan No." := funderLoan3."No.";
            funderLegderEntry_3."Posting Date" := RedemptionDate;
            funderLegderEntry_3."Document No." := funderLegderEntry_1."Document No.";
            funderLegderEntry_3.Category := funderLoan3.Category; // Funder Loan Category
            funderLegderEntry_3."Document Type" := funderLegderEntry_3."Document Type"::Repayment;
            funderLegderEntry_3.Description := 'Interest Redemption Payment calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(Today);
            funderLegderEntry_3.Amount := -(PartialAmount - FloatingInter);
            funderLegderEntry_3."Amount(LCY)" := -(PartialAmount - FloatingInter);
            // funderLegderEntry_3."Remaining Amount" := funderLegderEntry_1."Remaining Amount";
            funderLegderEntry_3.Insert();
            if (funderLoan3.EnableGLPosting = true) and ((PartialAmount - FloatingInter) <> 0) then
                FunderMGTCU.DirectGLPosting('redemption', funderLoan3."Interest Payable", (PartialAmount - FloatingInter), 'Partial Redemption Repayment', LoanNo, PayingBankCode, '', '', '', funderLoan3."Bank Ref. No.");//

            RedemptionLogs.Reset();
            RedemptionLogs.SetRange("Loan No.", LoanNo);
            RedemptionLogs.SetRange(RedemptionLogs.RedemptionType, RedemptionLogs.RedemptionType::"Partial Redemption");
            if RedemptionLogs.Find('-') then begin
                RedemptionLogs.IntrAmountRemoved := FloatingInter;
                RedemptionLogs.PrincAmountRemoved := PartialAmount - FloatingInter;
                RedemptionLogs.RemainingAmount := (RedemptionLogs.FloatingPrinc + RedemptionLogs.FloatingIntr) - PartialAmount;
                RedemptionLogs.Modify();
            end;
        end;




    end;

    procedure GetInterestRate(OriginNo: code[20]; Origin: Code[100]): Decimal
    var
        _interestRate_Active: Decimal;
        _interestRateTbl: Record "Interest Rate Change";
        _setup: Record "Treasury General Setup";
    begin
        _setup.Get(0);
        if _setup."Enable Dynamic Interest" = true then begin
            if Origin = 'FUNDER' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                _interestRateTbl.SetFilter("Effective Dates", '<=%1', Today);
                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", OriginNo);
                    if not funderLoan.Find('-') then
                        Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := funderLoan.InterestRate;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end;

            end;
            if Origin = 'FUNDER_REPORT' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                _interestRateTbl.SetFilter("Effective Dates", '%1..%2', Today);
                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", OriginNo);
                    if not funderLoan.Find('-') then
                        Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := funderLoan.InterestRate;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                    // if _interestRate_Active = 0 then
                    //     Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end;
            end;
            if Origin = 'RELATEDPARTY' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                _interestRateTbl.SetFilter("Effective Dates", '<=%1', Today);
                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    RelatedParty.Reset();
                    RelatedParty.SetRange("No.", OriginNo);
                    if not RelatedParty.Find('-') then
                        Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := RelatedParty.InterestRatePA;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end
            end;

            if Origin = 'RELATEDPARTY_REPORT' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                _interestRateTbl.SetFilter("Effective Dates", '<=%1', Today);
                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    RelatedParty.Reset();
                    RelatedParty.SetRange("No.", OriginNo);
                    if not RelatedParty.Find('-') then
                        Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := RelatedParty.InterestRatePA;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end
            end;

        end else begin
            if Origin = 'FUNDER' then begin

                funderLoan.Reset();
                funderLoan.SetRange("No.", OriginNo);
                if not funderLoan.Find('-') then
                    Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end;
            if Origin = 'FUNDER_REPORT' then begin

                funderLoan.Reset();
                funderLoan.SetRange("No.", OriginNo);
                if not funderLoan.Find('-') then
                    Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                // if _interestRate_Active = 0 then
                //     Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end;
            if Origin = 'RELATEDPARTY' then begin

                RelatedParty.Reset();
                RelatedParty.SetRange("No.", OriginNo);
                if not RelatedParty.Find('-') then
                    Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := RelatedParty.InterestRatePA;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end;

            if Origin = 'RELATEDPARTY_REPORT' then begin

                RelatedParty.Reset();
                RelatedParty.SetRange("No.", OriginNo);
                if not RelatedParty.Find('-') then
                    Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := RelatedParty.InterestRatePA;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end
        end;

    end;

    procedure GetInterestRateSchedule(OriginNo: code[20]; TerminalDate: Date; Origin: Code[100]): Decimal
    var
        _interestRate_Active: Decimal;
        _interestRateTbl: Record "Interest Rate Change";
        _setup: Record "Treasury General Setup";
    begin
        _setup.Get(0);
        if _setup."Enable Dynamic Interest" = true then begin
            if Origin = 'FUNDER' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                _interestRateTbl.SetFilter("Effective Dates", '<=%1', Today);
                _interestRateTbl.SetFilter("Effective Dates", '>=%1', TerminalDate); // This that period(Month,Quarter,..) group end date
                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", OriginNo);
                    if not funderLoan.Find('-') then
                        Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := funderLoan.InterestRate;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end;

            end;

            if Origin = 'FUNDER_REPORT' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                // _interestRateTbl.SetFilter("Effective Dates", '<=%1', Today);
                _interestRateTbl.SetFilter("Effective Dates", '<=%1', TerminalDate); // This that period group end date

                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    funderLoan.Reset();
                    funderLoan.SetRange("No.", OriginNo);
                    if not funderLoan.Find('-') then
                        Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := funderLoan.InterestRate;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                    // if _interestRate_Active = 0 then
                    //     Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end;
            end;

            if Origin = 'RELATEDPARTY' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                _interestRateTbl.SetFilter("Effective Dates", '<=%1', Today);
                _interestRateTbl.SetFilter("Effective Dates", '>=%1', TerminalDate); // This that period group end date

                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    RelatedParty.Reset();
                    RelatedParty.SetRange("No.", OriginNo);
                    if not RelatedParty.Find('-') then
                        Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := RelatedParty.InterestRatePA;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end
            end;

            if Origin = 'RELATEDPARTY_REPORT' then begin
                _interestRateTbl.Reset();
                _interestRateTbl.SetFilter(Active, '=%1', true);
                // _interestRateTbl.SetFilter("Effective Dates", '<=%1', Today);
                _interestRateTbl.SetFilter("Effective Dates", '<=%1', TerminalDate); // This that period group end date

                if _interestRateTbl.Find('-') then begin
                    exit(_interestRateTbl."New Interest Rate")
                end
                else begin
                    RelatedParty.Reset();
                    RelatedParty.SetRange("No.", OriginNo);
                    if not RelatedParty.Find('-') then
                        Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);

                    _interestRate_Active := 0;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := RelatedParty.InterestRatePA;
                    if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');
                    exit(_interestRate_Active)
                end
            end;

        end else begin
            if Origin = 'FUNDER' then begin

                funderLoan.Reset();
                funderLoan.SetRange("No.", OriginNo);
                if not funderLoan.Find('-') then
                    Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end;
            if Origin = 'FUNDER_REPORT' then begin

                funderLoan.Reset();
                funderLoan.SetRange("No.", OriginNo);
                if not funderLoan.Find('-') then
                    Error('Get Interest Funder Loan %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                // if _interestRate_Active = 0 then
                //     Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end;
            if Origin = 'RELATEDPARTY' then begin

                RelatedParty.Reset();
                RelatedParty.SetRange("No.", OriginNo);
                if not RelatedParty.Find('-') then
                    Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := RelatedParty.InterestRatePA;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end;

            if Origin = 'RELATEDPARTY_REPORT' then begin

                RelatedParty.Reset();
                RelatedParty.SetRange("No.", OriginNo);
                if not RelatedParty.Find('-') then
                    Error('Get Interest RelatedParty  %1 Dont Exist', OriginNo);
                _interestRate_Active := 0;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := RelatedParty.InterestRatePA;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');
                exit(_interestRate_Active)

            end
        end;

    end;

    var
        funderLedgerEntries: Page FunderLedgerEntry;
        funder3: Record Funders;
        funderLoan: Record "Funder Loan";
        funderLoan3: Record "Funder Loan";
        EmailingCU: Codeunit "Treasury Emailing";
        FunderMGTCU: Codeunit FunderMgtCU;
        RelatedParty: Record "RelatedParty- Cust";
}