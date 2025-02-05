codeunit 50231 FunderMgtCU
{
    trigger OnRun()
    begin

    end;

    procedure CalculateInterest()
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestAccExpense: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        venPostingGroup: Record "Vendor Posting Group";
        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;


    begin
        //Interest Rate Type (Fixed/Float)
        //Interest Rate value
        _docNo := TrsyMgt.GenerateDocumentNumber();
        //***Interest Method
        // (Annual Rate / 12) * Principal
        //Funder Ldger Entry
        latestRemainingAmount := 0;
        funderLoan.Reset();
        funderLoan.SetFilter(funderLoan."No.", '<>%1', '');
        funderLoan.SetFilter(funderLoan.Status, '=%1', funderLoan.Status::Approved);
        //funderLoan.SetFilter("Type of Vendor", '=%1', funderLoan."Type of Vendor"::Funder);
        if funderLoan.Find('-') then begin
            repeat
                //Fixed Interest Type
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") OR (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then begin
                    funderLoan.TestField(PlacementDate);
                    // vendor.TestField(InterestMethod);
                    // funderLoan.TestField(TaxStatus);
                    endYearDate := CALCDATE('CY', Today);
                    remainingDays := endYearDate - funderLoan.PlacementDate;

                    //Monthly interest depending on Interest Method
                    monthlyInterest := 0;
                    if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                        monthlyInterest := ((funderLoan.InterestRate / 100) * funderLoan.DisbursedCurrency) * (30 / 360);
                    end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((funderLoan.InterestRate / 100) * funderLoan.DisbursedCurrency) * (remainingDays / 360);
                    end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((funderLoan.InterestRate / 100) * funderLoan.DisbursedCurrency) * (remainingDays / 364);
                    end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((funderLoan.InterestRate / 100) * funderLoan.DisbursedCurrency) * (remainingDays / 365);
                    end;

                    //withholding on interest
                    //Depending on Tax Exceptions
                    witHldInterest := 0;
                    if funderLoan.TaxStatus = funderLoan.TaxStatus::Taxable then begin
                        funderLoan.TestField(Withldtax);
                        witHldInterest := (funderLoan.Withldtax / 100) * monthlyInterest;
                    end;

                    //Get Posting groups
                    if not venPostingGroup.Get(funderLoan."Posting Group") then
                        Error('Missing Posting Group: %1', funderLoan."No.");

                    principleAcc := venPostingGroup."Payables Account";
                    interestAccExpense := venPostingGroup."Interest Expense";
                    if interestAccExpense = '' then
                        Error('Missing Posting Group - Interest A/C: %1', funderLoan."No.");
                    if principleAcc = '' then
                        Error('Missing Posting Group - Principle A/C: %1', funderLoan."No.");

                    if not generalSetup.FindFirst() then
                        Error('Please Define Withholding Tax under General Setup');
                    withholdingAcc := generalSetup.FunderWithholdingAcc;
                    //Get the latest remaining amount
                    funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                    if funderLegderEntry.FindLast() then
                        latestRemainingAmount := funderLegderEntry."Remaining Amount";

                    //funderLegderEntry.LockTable();
                    funderLegderEntry.Reset();
                    if funderLegderEntry.FindLast() then
                        NextEntryNo := funderLegderEntry."Entry No." + 1;
                    // else
                    //     NextEntryNo := 2;

                    funderLegderEntry.Init();
                    funderLegderEntry."Entry No." := NextEntryNo;
                    funderLegderEntry."Funder No." := funderLoan."No.";
                    funderLegderEntry."Document No." := _docNo;
                    funderLegderEntry."Posting Date" := Today;
                    funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                    funderLegderEntry.Description := 'Interest calculation' + Format(Today);
                    funderLegderEntry.Amount := monthlyInterest;
                    funderLegderEntry."Amount(LCY)" := monthlyInterest;
                    funderLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                    funderLegderEntry.Insert();
                    if (funderLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                        DirectGLPosting('interest', interestAccExpense, monthlyInterest, 'Interest', funderLoan."No.", '', '', '', '');//GROSS Interest
                    //Commit();
                    funderLegderEntry1.Init();
                    funderLegderEntry1."Entry No." := NextEntryNo + 1;
                    funderLegderEntry1."Funder No." := funderLoan."No.";
                    funderLegderEntry1."Document No." := _docNo;
                    funderLegderEntry1."Posting Date" := Today;
                    funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                    funderLegderEntry1.Description := 'Withholding calculation' + Format(Today);
                    funderLegderEntry1.Amount := -witHldInterest;
                    funderLegderEntry1."Amount(LCY)" := -witHldInterest;
                    funderLegderEntry1.Insert();
                    if (funderLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                        DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', funderLoan."No.", '', '', '', '');
                    //Commit();

                    funderLegderEntry2.Init();
                    funderLegderEntry2."Entry No." := NextEntryNo + 2;
                    funderLegderEntry2."Funder No." := funderLoan."No.";
                    funderLegderEntry2."Document No." := _docNo;
                    funderLegderEntry2."Posting Date" := Today;
                    funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
                    funderLegderEntry2.Description := 'Remaining Amount' + Format(Today);
                    funderLegderEntry2.Amount := ((monthlyInterest - witHldInterest) + funderLoan.DisbursedCurrency);
                    funderLegderEntry2."Amount(LCY)" := ((monthlyInterest - witHldInterest) + funderLoan.DisbursedCurrency);
                    if latestRemainingAmount = 0 then begin
                        funderLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + funderLoan.DisbursedCurrency);
                    end
                    else begin
                        funderLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + latestRemainingAmount);
                    end;

                    funderLegderEntry2.Insert();
                end else begin
                    Message('Select Interest Rate Type');
                end;
            until funderLoan.Next() = 0;
            Message('Interest Calculated');
        end;

    end;


    procedure CalculateInterest(FunderLoanNo: Code[100])
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestAccExpense: Code[20];
        interestAccPayable: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry3: Record FunderLedgerEntry;//Calculate every month
        venPostingGroup: Record "Vendor Posting Group";
        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;
        _loanNo: Code[100];
        _loanName: Code[100];
        _totalOriginalAmount: Decimal;
        _totalWithdrawalAmount: Decimal;
        _differenceOriginalWithdrawal: Decimal;

    begin
        //Interest Rate Type (Fixed/Float)
        //Interest Rate value
        //***Interest Method
        // (Annual Rate / 12) * Principal
        //Funder Ldger Entry
        latestRemainingAmount := 0;
        funderLoan.Reset();
        funderLoan.SetRange(funderLoan."No.", FunderLoanNo);
        //funderLoan.SetFilter("Type of Vendor", '=%1', funderLoan."Type of Vendor"::Funder);
        _docNo := TrsyMgt.GenerateDocumentNumber();
        if funderLoan.Find('-') then begin
            _loanName := funderLoan."Loan Name";
            _loanNo := funderLoan."No.";
            if not funder.Get(funderLoan."Funder No.") then
                Error('Funder %1 not found', funderLoan."Funder No.");
            // repeat
            if funderLoan.Status <> funderLoan.Status::Approved then
                Error('Loan Status is %1', funderLoan.Status);

            //Fixed Interest Type
            if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") OR (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then begin
                funderLoan.TestField(PlacementDate);
                // vendor.TestField(InterestMethod);
                // funderLoan.TestField(TaxStatus);
                endYearDate := CALCDATE('CY', Today);
                remainingDays := endYearDate - funderLoan.PlacementDate;

                // Get Total of Original Amount (Principal)
                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Original Amount");
                funderLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := funderLegderEntry3.Amount;

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Repayment);
                funderLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(funderLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := ((funderLoan.InterestRate / 100) * _differenceOriginalWithdrawal) * (30 / 360);
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := ((funderLoan.InterestRate / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360);
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := ((funderLoan.InterestRate / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364);
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := ((funderLoan.InterestRate / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365);
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if funderLoan.TaxStatus = funderLoan.TaxStatus::Taxable then begin
                    funderLoan.TestField(Withldtax);
                    witHldInterest := (funderLoan.Withldtax / 100) * monthlyInterest;
                end;

                //Get Posting groups
                if not venPostingGroup.Get(funderLoan."Posting Group") then
                    Error('Missing Posting Group: %1', funder."No.");

                principleAcc := venPostingGroup."Payables Account";
                interestAccExpense := venPostingGroup."Interest Expense";
                interestAccPayable := venPostingGroup."Interest Payable";
                if interestAccExpense = '' then
                    Error('Missing Posting Group - Expense Interest A/C: %1', funder."No.");
                if principleAcc = '' then
                    Error('Missing Posting Group - Principle A/C: %1', funder."No.");
                if interestAccPayable = '' then
                    Error('Missing Posting Group - Payable Interest A/C: %1', funder."No.");

                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.FunderWithholdingAcc;
                //Get the latest remaining amount
                funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Remaining Amount");
                if funderLegderEntry.FindLast() then
                    latestRemainingAmount := funderLegderEntry."Remaining Amount";

                //funderLegderEntry.LockTable();
                funderLegderEntry.Reset();
                if funderLegderEntry.FindLast() then
                    NextEntryNo := funderLegderEntry."Entry No." + 1;
                // else
                //     NextEntryNo := 2;

                funderLegderEntry.Init();
                funderLegderEntry."Entry No." := NextEntryNo;
                funderLegderEntry."Funder No." := funder."No.";
                funderLegderEntry."Funder Name" := funder.Name;
                funderLegderEntry."Loan Name" := _loanName;
                funderLegderEntry."Loan No." := _loanNo;
                funderLegderEntry."Posting Date" := Today;
                funderLegderEntry."Document No." := _docNo;
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                funderLegderEntry.Description := 'Interest calculation' + Format(Today);
                funderLegderEntry.Amount := monthlyInterest;
                funderLegderEntry."Amount(LCY)" := monthlyInterest;
                funderLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                funderLegderEntry.Insert();
                if (funderLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestAccExpense, monthlyInterest, 'Interest', funderLoan."No.", interestAccPayable, '', '', '');//GROSS Interest
                                                                                                                                                   //Commit();
                funderLegderEntry1.Init();
                funderLegderEntry1."Entry No." := NextEntryNo + 1;
                funderLegderEntry1."Funder No." := funder."No.";
                funderLegderEntry1."Funder Name" := funder.Name;
                funderLegderEntry1."Loan Name" := _loanName;
                funderLegderEntry1."Loan No." := _loanNo;
                funderLegderEntry1."Posting Date" := Today;
                funderLegderEntry1."Document No." := _docNo;
                funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                funderLegderEntry1.Description := 'Withholding calculation' + Format(Today);
                funderLegderEntry1.Amount := -witHldInterest;
                funderLegderEntry1."Amount(LCY)" := -witHldInterest;
                funderLegderEntry1.Insert();
                if (funderLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                    DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', funderLoan."No.", interestAccPayable, '', '', '');
                //Commit();

                funderLegderEntry2.Init(); //
                funderLegderEntry2."Entry No." := NextEntryNo + 2;
                funderLegderEntry2."Funder No." := funder."No.";
                funderLegderEntry2."Funder Name" := funder.Name;
                funderLegderEntry2."Loan Name" := _loanName;
                funderLegderEntry2."Loan No." := _loanNo;
                funderLegderEntry2."Document No." := _docNo;
                funderLegderEntry2."Posting Date" := Today;
                funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
                funderLegderEntry2.Description := 'Remaining Amount' + Format(Today);
                funderLegderEntry2.Amount := ((monthlyInterest - witHldInterest) + funderLoan.DisbursedCurrency);
                funderLegderEntry2."Amount(LCY)" := ((monthlyInterest - witHldInterest) + funderLoan.DisbursedCurrency);
                if latestRemainingAmount = 0 then begin
                    funderLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + funderLoan.DisbursedCurrency);
                end
                else begin
                    funderLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + latestRemainingAmount);
                end;
                funderLegderEntry2.Insert();

                Message('Interest Calculated');
            end else begin
                Message('Select Interest Rate Type');
            end;
            // until funderLoan.Next() = 0;

        end;

    end;



    procedure DirectGLPosting(Origin: Text[100]; GLAcc: Code[100]; Amount: Decimal; Desc: Text[100]; FunderLoanNo: Code[20]; BankAc: Code[100]; Currency: Code[20]; PostingGroup: Code[20]; DocNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";

        principleAcc: Code[100];
        interestAccExpense: Code[100];
        interestAccPay: Code[100];
        withholdingAcc: Code[20];
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        venPostingGroup: Record "Vendor Posting Group";
        funderLoan: Record "Funder Loan";
    begin
        JournalEntry.LockTable();
        if JournalEntry.FindLast() then
            NextEntryNo := JournalEntry."Line No." + 1
        else
            NextEntryNo := 1;

        //**********************************************
        //          Get Posting groups & Posting Accounts
        //**********************************************
        if PostingGroup = '' then begin
            funderLoan.Reset();
            if not funderLoan.Get(FunderLoanNo) then
                Error('Funder %1 not found', FunderLoanNo);
            if not venPostingGroup.Get(funderLoan."Posting Group") then
                Error('Missing Posting Group: %1', funderLoan."No.");
            interestAccExpense := venPostingGroup."Interest Expense";
            if interestAccExpense = '' then
                Error('Missing Posting Group - Interest Expense A/C: %1', funderLoan."No.");
            interestAccPay := venPostingGroup."Interest Payable";
            if interestAccPay = '' then
                Error('Missing Posting Group - Interest Payable A/C: %1', funderLoan."No.");
            principleAcc := venPostingGroup."Payables Account";
            if principleAcc = '' then
                Error('Missing Posting Group - Principle A/C: %1', funderLoan."No.");
        end
        else begin

            if not venPostingGroup.Get(PostingGroup) then
                Error('Missing Posting Group: %1', funderLoan."No.");
            interestAccExpense := venPostingGroup."Interest Expense";
            if interestAccExpense = '' then
                Error('Missing Posting Group - Interest Expense A/C: %1', funderLoan."No.");
            interestAccPay := venPostingGroup."Interest Payable";
            if interestAccPay = '' then
                Error('Missing Posting Group - Interest Payable A/C: %1', funderLoan."No.");
            principleAcc := venPostingGroup."Payables Account";
            if principleAcc = '' then
                Error('Missing Posting Group - Principle A/C: %1', funderLoan."No.");
        end;
        if not generalSetup.FindFirst() then
            Error('Please Define Withholding Tax under General Setup');
        withholdingAcc := generalSetup.FunderWithholdingAcc;

        JournalEntry.Init();
        JournalEntry."Journal Template Name" := 'GENERAL';
        JournalEntry."Journal Batch Name" := 'TREASURY';
        JournalEntry."Line No." := NextEntryNo;
        JournalEntry.Entry_ID := NextEntryNo;

        //JournalEntry.Validate(JournalEntry.Amount);
        JournalEntry."Posting Date" := Today;
        JournalEntry.Creation_Date := Today;
        if DocNo <> '' then
            JournalEntry."Document No." := DocNo
        else
            JournalEntry."Document No." := FunderLoanNo + Format(Today);
        JournalEntry.Description := Desc;
        JournalEntry."Currency Code" := Currency;
        if Origin = 'init' then begin  //*
            JournalEntry."Account Type" := JournalEntry."Account Type"::"Bank Account";
            JournalEntry."Account No." := BankAc;
            JournalEntry.amount := Round(Amount, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := GLAcc;
        end;
        if Origin = 'interest' then begin
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.amount := Round(Amount, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interestAccPayable
        end;
        if Origin = 'withholding' then begin
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.amount := Round(Amount, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interestAccPayable
        end;
        // else begin
        //     JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
        //     JournalEntry."Account No." := GLAcc;
        //     JournalEntry.amount := Round(Amount, 0.01, '=');
        //     JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
        //     JournalEntry."Bal. Account No." := '50102006';
        // end;
        GLPost.RunWithCheck(JournalEntry);
        //JournalEntry.Insert();

        // Get the next entry number
        // GLEntry.LockTable();
        // if GLEntry.FindLast() then
        //     NextEntryNo := GLEntry."Entry No." + 1
        // else
        //     NextEntryNo := 1;

        // // Initialize the G/L Entry
        // GLEntry.Init();
        // GLEntry."Entry No." := NextEntryNo;
        // GLEntry."Posting Date" := Today();
        // GLEntry."Document No." := DocNo + '_Trans';
        // GLEntry."G/L Account No." := GLAcc;
        // GLEntry.Amount := Amount;
        // GLEntry.Description := 'Automatic Posting';
        // // Insert the G/L Entry
        // GLEntry.Insert();
    end;

    var
        myGlobalCounter: Integer;
        // vendor: Record Vendor;
        funderLoan: Record "Funder Loan";
        funder: Record Funders;
        // debtor: Record Debtor;
        // funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderPostingGroup: Record 93;
        generalSetup: Record "General Setup";
        _docNo: Code[20];
        TrsyMgt: Codeunit "Treasury Mgt CU";

}