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
        interestAccPayable: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry3: Record FunderLedgerEntry;//Calculate every month
        venPostingGroup: Record "Treasury Posting Group";
        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;
        endMonthDate: Date;
        _loanNo: Code[100];
        _loanName: Code[100];
        _totalOriginalAmount: Decimal;
        _totalWithdrawalAmount: Decimal;
        _differenceOriginalWithdrawal: Decimal;

        _interestRate_Active: Decimal;
        _currentPrincipalAmnt: Decimal;

        _interestComputationTimes: Integer;
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

                    funderLegderEntry3.Reset();
                    funderLegderEntry3.SetRange("Funder No.", funder."No.");
                    funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Interest);
                    _interestComputationTimes := funderLegderEntry3.Count();

                    // endYearDate := CALCDATE('CY', Today);
                    if _interestComputationTimes = 0 then begin
                        endMonthDate := CALCDATE('CM', Today);
                        remainingDays := endMonthDate - funderLoan.PlacementDate;
                    end else begin
                        endMonthDate := CALCDATE('CM', Today);
                        remainingDays := Today - endMonthDate;
                    end;


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
                    _interestRate_Active := 0;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := funderLoan.InterestRate;
                    if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');

                    _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                    if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360);
                    end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360);
                    end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364);
                    end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365);
                    end;

                    //withholding on interest
                    //Depending on Tax Exceptions
                    witHldInterest := 0;
                    if funderLoan.TaxStatus = funderLoan.TaxStatus::Taxable then begin
                        funderLoan.TestField(Withldtax);
                        witHldInterest := (funderLoan.Withldtax / 100) * monthlyInterest;
                    end;

                    //Get Posting groups
                    // if not venPostingGroup.Get(funderLoan."Posting Group") then
                    //     Error('Missing Posting Group: %1', funder."No.");


                    interestAccExpense := funderLoan."Interest Expense";

                    if funderLoan."Bank Ref. No." = '' then
                        Error('Missing Bank Reference No for Funder Loan', funderLoan."No.");

                    if interestAccExpense = '' then
                        Error('Missing Expense Interest A/C: %1', funder."No.");
                    principleAcc := funderLoan."Payables Account";
                    if principleAcc = '' then
                        Error('Missing Principle A/C: %1', funder."No.");
                    interestAccPayable := funderLoan."Interest Payable";
                    if interestAccPayable = '' then
                        Error('Missing Payable Interest A/C: %1', funder."No.");

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
                    funderLegderEntry.Category := funderLoan.Category; // Funder Loan Category
                    funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                    funderLegderEntry.Description := 'Interest calculation' + funder.Name + ' ' + funder."No." + ' ' + Format(Today);
                    funderLegderEntry.Amount := monthlyInterest;
                    funderLegderEntry."Amount(LCY)" := monthlyInterest;
                    funderLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                    funderLegderEntry.Insert();
                    if (funderLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                        DirectGLPosting('interest', interestAccExpense, monthlyInterest, 'Interest', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");//GROSS Interest
                                                                                                                                                                                   //Commit();
                    funderLegderEntry1.Init();
                    funderLegderEntry1."Entry No." := NextEntryNo + 1;
                    funderLegderEntry1."Funder No." := funder."No.";
                    funderLegderEntry1."Funder Name" := funder.Name;
                    funderLegderEntry1."Loan Name" := _loanName;
                    funderLegderEntry1."Loan No." := _loanNo;
                    funderLegderEntry1."Posting Date" := Today;
                    funderLegderEntry1."Document No." := _docNo;
                    funderLegderEntry1.Category := funderLoan.Category; // Funder Loan Category
                    funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                    funderLegderEntry1.Description := 'Withholding calculation ' + Format(Today);
                    funderLegderEntry1.Amount := -witHldInterest;
                    funderLegderEntry1."Amount(LCY)" := -witHldInterest;
                    funderLegderEntry1.Insert();
                    if (funderLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                        DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");
                    //Commit();

                    funderLegderEntry2.Init(); //
                    funderLegderEntry2."Entry No." := NextEntryNo + 2;
                    funderLegderEntry2."Funder No." := funder."No.";
                    funderLegderEntry2."Funder Name" := funder.Name;
                    funderLegderEntry2."Loan Name" := _loanName;
                    funderLegderEntry2."Loan No." := _loanNo;
                    funderLegderEntry2."Document No." := _docNo;
                    funderLegderEntry2.Category := funderLoan.Category; // Funder Loan Category
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
            until funderLoan.Next() = 0;
            // Message('Interest Calculated');
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
        venPostingGroup: Record "Treasury Posting Group";
        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;
        endMonthDate: Date;
        _loanNo: Code[100];
        _loanName: Code[100];
        _totalOriginalAmount: Decimal;
        _totalWithdrawalAmount: Decimal;
        _differenceOriginalWithdrawal: Decimal;

        _interestRate_Active: Decimal;
        _currentPrincipalAmnt: Decimal;

        _interestComputationTimes: Integer;
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
            funderLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := funderLoan.OutstandingAmntDisbLCY;
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

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Loan No.", funderLoan."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := funderLegderEntry3.Count();

                // endYearDate := CALCDATE('CY', Today);
                if _interestComputationTimes = 0 then begin
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := endMonthDate - funderLoan.PlacementDate + 1;
                end else begin
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 1
                    // remainingDays := (endMonthDate - Today) + 1;
                end;


                // Get Total of Original Amount (Principal)
                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Original Amount");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Secondary Amount");
                funderLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := funderLegderEntry3.Amount;

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Repayment);
                funderLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(funderLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');

                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if funderLoan.TaxStatus = funderLoan.TaxStatus::Taxable then begin
                    funderLoan.TestField(Withldtax);
                    witHldInterest := (funderLoan.Withldtax / 100) * monthlyInterest;
                end;

                //Get Posting groups
                // if not venPostingGroup.Get(funderLoan."Posting Group") then
                //     Error('Missing Posting Group: %1', funder."No.");

                principleAcc := funderLoan."Payables Account";
                interestAccExpense := funderLoan."Interest Expense";
                interestAccPayable := funderLoan."Interest Payable";
                if funderLoan."Bank Ref. No." = '' then
                    Error('Missing Bank Reference No for Funder Loan', funderLoan."No.");

                if interestAccExpense = '' then
                    Error('Missing Expense Interest A/C: %1', funder."No.");
                if principleAcc = '' then
                    Error('Missing Principle A/C: %1', funder."No.");
                if interestAccPayable = '' then
                    Error('Missing Payable Interest A/C: %1', funder."No.");

                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.FunderWithholdingAcc;
                if withholdingAcc = '' then
                    Error('Withholding Account Missing under General Setup');

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
                funderLegderEntry.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                funderLegderEntry.Description := 'Interest calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(Today);
                funderLegderEntry.Amount := monthlyInterest;
                funderLegderEntry."Amount(LCY)" := monthlyInterest;
                funderLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                funderLegderEntry.Insert();
                if (funderLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestAccExpense, monthlyInterest, 'Interest', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");//GROSS Interest
                                                                                                                                                                               //Commit();
                funderLegderEntry1.Init();
                funderLegderEntry1."Entry No." := NextEntryNo + 1;
                funderLegderEntry1."Funder No." := funder."No.";
                funderLegderEntry1."Funder Name" := funder.Name;
                funderLegderEntry1."Loan Name" := _loanName;
                funderLegderEntry1."Loan No." := _loanNo;
                funderLegderEntry1."Posting Date" := Today;
                funderLegderEntry1.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry1."Document No." := _docNo;
                funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                funderLegderEntry1.Description := 'Withholding calculation' + Format(Today);
                funderLegderEntry1.Amount := -witHldInterest;
                funderLegderEntry1."Amount(LCY)" := -witHldInterest;
                funderLegderEntry1.Insert();
                if (funderLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                    DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");
                //Commit();

                funderLegderEntry2.Init(); //
                funderLegderEntry2."Entry No." := NextEntryNo + 2;
                funderLegderEntry2."Funder No." := funder."No.";
                funderLegderEntry2."Funder Name" := funder.Name;
                funderLegderEntry2."Loan Name" := _loanName;
                funderLegderEntry2."Loan No." := _loanNo;
                funderLegderEntry2."Document No." := _docNo;
                funderLegderEntry2.Category := funderLoan.Category; // Funder Loan Category
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

    procedure CalculateInterest(FunderLoanNo: Code[100]; RedemptionDate: Date; PayingBankCode: Code[50])
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
        funderLegderEntry4: Record FunderLedgerEntry;//Calculate every month
        venPostingGroup: Record "Treasury Posting Group";
        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;
        endMonthDate: Date;
        startMonthDate: Date;
        _loanNo: Code[100];
        _loanName: Code[100];
        _totalOriginalAmount: Decimal;
        _totalWithdrawalAmount: Decimal;
        _differenceOriginalWithdrawal: Decimal;

        _interestRate_Active: Decimal;
        _currentPrincipalAmnt: Decimal;

        _interestComputationTimes: Integer;
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
            funderLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := funderLoan.OutstandingAmntDisbLCY;
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

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Loan No.", funderLoan."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := funderLegderEntry3.Count();

                // endYearDate := CALCDATE('CY', Today);
                if _interestComputationTimes = 0 then begin // Check for first operation
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := endMonthDate - funderLoan.PlacementDate + 1;
                end else begin
                    startMonthDate := CALCDATE('<-CM>', Today);
                    remainingDays := RedemptionDate - startMonthDate + 1;
                    // remainingDays := CALCDATE('<CM>', RedemptionDate) - CALCDATE('<-CM>', RedemptionDate) + 1;// No of Days in that Month
                end;


                // Get Total of Original Amount (Principal)
                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Original Amount");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Secondary Amount");
                funderLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := funderLegderEntry3.Amount;

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Repayment);
                funderLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(funderLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');

                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if funderLoan.TaxStatus = funderLoan.TaxStatus::Taxable then begin
                    funderLoan.TestField(Withldtax);
                    witHldInterest := (funderLoan.Withldtax / 100) * monthlyInterest;
                end;

                //Get Posting groups
                // if not venPostingGroup.Get(funderLoan."Posting Group") then
                //     Error('Missing Posting Group: %1', funder."No.");

                principleAcc := funderLoan."Payables Account";
                interestAccExpense := funderLoan."Interest Expense";
                interestAccPayable := funderLoan."Interest Payable";
                if funderLoan."Bank Ref. No." = '' then
                    Error('Missing Bank Reference No for Funder Loan', funderLoan."No.");

                if interestAccExpense = '' then
                    Error('Missing Expense Interest A/C: %1', funder."No.");
                if principleAcc = '' then
                    Error('Missing Principle A/C: %1', funder."No.");
                if interestAccPayable = '' then
                    Error('Missing Payable Interest A/C: %1', funder."No.");

                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.FunderWithholdingAcc;
                if withholdingAcc = '' then
                    Error('Withholding Account Missing under General Setup');

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
                funderLegderEntry."Posting Date" := RedemptionDate;
                funderLegderEntry."Document No." := _docNo;
                funderLegderEntry.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                funderLegderEntry.Description := 'Interest calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(RedemptionDate);
                funderLegderEntry.Amount := monthlyInterest;
                funderLegderEntry."Amount(LCY)" := monthlyInterest;
                funderLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                funderLegderEntry.Insert();
                if (funderLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestAccExpense, monthlyInterest, 'Interest', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");//GROSS Interest
                                                                                                                                                                               //Commit();
                funderLegderEntry1.Init();
                funderLegderEntry1."Entry No." := NextEntryNo + 1;
                funderLegderEntry1."Funder No." := funder."No.";
                funderLegderEntry1."Funder Name" := funder.Name;
                funderLegderEntry1."Loan Name" := _loanName;
                funderLegderEntry1."Loan No." := _loanNo;
                funderLegderEntry1."Posting Date" := RedemptionDate;
                funderLegderEntry1.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry1."Document No." := _docNo;
                funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                funderLegderEntry1.Description := 'Withholding calculation' + Format(RedemptionDate);
                funderLegderEntry1.Amount := -witHldInterest;
                funderLegderEntry1."Amount(LCY)" := -witHldInterest;
                funderLegderEntry1.Insert();
                if (funderLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                    DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");
                //Commit();

                funderLegderEntry3.Init();
                funderLegderEntry3."Entry No." := NextEntryNo + 2;
                funderLegderEntry3."Funder No." := funder."No.";
                funderLegderEntry3."Funder Name" := funder.Name;
                funderLegderEntry3."Loan Name" := _loanName;
                funderLegderEntry3."Loan No." := _loanNo;
                funderLegderEntry3."Posting Date" := RedemptionDate;
                funderLegderEntry3.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry3."Document No." := _docNo;
                funderLegderEntry3."Document Type" := funderLegderEntry."Document Type"::Repayment;
                funderLegderEntry3.Description := 'Redemption Repayment calculation' + Format(RedemptionDate);
                funderLegderEntry3.Amount := -_differenceOriginalWithdrawal;
                funderLegderEntry3."Amount(LCY)" := -_differenceOriginalWithdrawal;
                funderLegderEntry3.Insert();
                if (funderLoan.EnableGLPosting = true) and (_differenceOriginalWithdrawal <> 0) then
                    DirectGLPosting('redemption', withholdingAcc, witHldInterest, 'Redemption Repayment', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No."); // Debit Paying Bank
                //Commit();


                funderLegderEntry2.Init(); //
                funderLegderEntry2."Entry No." := NextEntryNo + 3;
                funderLegderEntry2."Funder No." := funder."No.";
                funderLegderEntry2."Funder Name" := funder.Name;
                funderLegderEntry2."Loan Name" := _loanName;
                funderLegderEntry2."Loan No." := _loanNo;
                funderLegderEntry2."Document No." := _docNo;
                funderLegderEntry2.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry2."Posting Date" := RedemptionDate;
                funderLegderEntry2."Document Type" := funderLegderEntry."Document Type"::"Remaining Amount";
                funderLegderEntry2.Description := 'Remaining Amount' + Format(RedemptionDate);
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

    procedure CalculateInterestForPartial(FunderLoanNo: Code[100]; RedemptionDate: Date; PayingBankCode: Code[50])
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
        funderLegderEntry4: Record FunderLedgerEntry;//Calculate every month
        venPostingGroup: Record "Treasury Posting Group";
        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;
        endMonthDate: Date;
        startMonthDate: Date;
        _loanNo: Code[100];
        _loanName: Code[100];
        _totalOriginalAmount: Decimal;
        _totalWithdrawalAmount: Decimal;
        _differenceOriginalWithdrawal: Decimal;

        _interestRate_Active: Decimal;
        _currentPrincipalAmnt: Decimal;

        _interestComputationTimes: Integer;
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
            funderLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := funderLoan.OutstandingAmntDisbLCY;
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

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Loan No.", funderLoan."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := funderLegderEntry3.Count();

                // endYearDate := CALCDATE('CY', Today);
                if _interestComputationTimes = 0 then begin // Check for first operation
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := endMonthDate - funderLoan.PlacementDate + 1;
                end else begin
                    startMonthDate := CALCDATE('<-CM>', Today);
                    remainingDays := RedemptionDate - startMonthDate + 1;
                    // remainingDays := CALCDATE('<CM>', RedemptionDate) - CALCDATE('<-CM>', RedemptionDate) + 1;// No of Days in that Month
                end;


                // Get Total of Original Amount (Principal)
                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Original Amount");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Secondary Amount");
                funderLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := funderLegderEntry3.Amount;

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Repayment);
                funderLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(funderLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');

                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if funderLoan.TaxStatus = funderLoan.TaxStatus::Taxable then begin
                    funderLoan.TestField(Withldtax);
                    witHldInterest := (funderLoan.Withldtax / 100) * monthlyInterest;
                end;

                //Get Posting groups
                // if not venPostingGroup.Get(funderLoan."Posting Group") then
                //     Error('Missing Posting Group: %1', funder."No.");

                principleAcc := funderLoan."Payables Account";
                interestAccExpense := funderLoan."Interest Expense";
                interestAccPayable := funderLoan."Interest Payable";
                if funderLoan."Bank Ref. No." = '' then
                    Error('Missing Bank Reference No for Funder Loan', funderLoan."No.");

                if interestAccExpense = '' then
                    Error('Missing Expense Interest A/C: %1', funder."No.");
                if principleAcc = '' then
                    Error('Missing Principle A/C: %1', funder."No.");
                if interestAccPayable = '' then
                    Error('Missing Payable Interest A/C: %1', funder."No.");

                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.FunderWithholdingAcc;
                if withholdingAcc = '' then
                    Error('Withholding Account Missing under General Setup');

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
                funderLegderEntry."Posting Date" := RedemptionDate;
                funderLegderEntry."Document No." := _docNo;
                funderLegderEntry.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                funderLegderEntry.Description := 'Interest calculation' + ' ' + funder.Name + ' ' + funder."No." + Format(RedemptionDate);
                funderLegderEntry.Amount := monthlyInterest;
                funderLegderEntry."Amount(LCY)" := monthlyInterest;
                funderLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                funderLegderEntry.Insert();
                if (funderLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestAccExpense, monthlyInterest, 'Interest', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");//GROSS Interest
                                                                                                                                                                               //Commit();
                funderLegderEntry1.Init();
                funderLegderEntry1."Entry No." := NextEntryNo + 1;
                funderLegderEntry1."Funder No." := funder."No.";
                funderLegderEntry1."Funder Name" := funder.Name;
                funderLegderEntry1."Loan Name" := _loanName;
                funderLegderEntry1."Loan No." := _loanNo;
                funderLegderEntry1."Posting Date" := RedemptionDate;
                funderLegderEntry1.Category := funderLoan.Category; // Funder Loan Category
                funderLegderEntry1."Document No." := _docNo;
                funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                funderLegderEntry1.Description := 'Withholding calculation' + Format(RedemptionDate);
                funderLegderEntry1.Amount := -witHldInterest;
                funderLegderEntry1."Amount(LCY)" := -witHldInterest;
                funderLegderEntry1.Insert();
                if (funderLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                    DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.");
                //Commit();


                Message('Interest Calculated');
            end else begin
                Message('Select Interest Rate Type');
            end;
            // until funderLoan.Next() = 0;

        end;

    end;

    procedure CalculateFloatInterest(FunderLoanNo: Code[100]; RedemptionDate: Date): Decimal
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
        funderLegderEntry4: Record FunderLedgerEntry;//Calculate every month
        venPostingGroup: Record "Treasury Posting Group";
        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;
        endMonthDate: Date;
        startMonthDate: Date;
        _loanNo: Code[100];
        _loanName: Code[100];
        _totalOriginalAmount: Decimal;
        _totalWithdrawalAmount: Decimal;
        _differenceOriginalWithdrawal: Decimal;

        _interestRate_Active: Decimal;
        _currentPrincipalAmnt: Decimal;

        _interestComputationTimes: Integer;
    begin

        latestRemainingAmount := 0;
        funderLoan.Reset();
        funderLoan.SetRange(funderLoan."No.", FunderLoanNo);
        if funderLoan.Find('-') then begin
            _loanName := funderLoan."Loan Name";
            _loanNo := funderLoan."No.";
            funderLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := funderLoan.OutstandingAmntDisbLCY;
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

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Loan No.", funderLoan."No.");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := funderLegderEntry3.Count();

                // endYearDate := CALCDATE('CY', Today);
                if _interestComputationTimes = 0 then begin // Check for first operation
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := endMonthDate - funderLoan.PlacementDate + 1;
                end else begin
                    startMonthDate := CALCDATE('<-CM>', Today);
                    remainingDays := RedemptionDate - startMonthDate + 1;
                    // remainingDays := CALCDATE('<CM>', RedemptionDate) - CALCDATE('<-CM>', RedemptionDate) + 1;// No of Days in that Month
                end;


                // Get Total of Original Amount (Principal)
                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Original Amount");
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::"Secondary Amount");
                funderLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := funderLegderEntry3.Amount;

                funderLegderEntry3.Reset();
                funderLegderEntry3.SetRange("Funder No.", funder."No.");
                funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Repayment);
                funderLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(funderLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := 0;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := funderLoan.InterestRate;
                if (funderLoan.InterestRateType = funderLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (funderLoan."Reference Rate" + funderLoan.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');

                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if funderLoan.TaxStatus = funderLoan.TaxStatus::Taxable then begin
                    funderLoan.TestField(Withldtax);
                    witHldInterest := (funderLoan.Withldtax / 100) * monthlyInterest;
                end;

                exit(monthlyInterest);
            end;

        end;

    end;


    procedure DirectGLPosting(Origin: Text[100]; GLAcc: Code[100]; Amount: Decimal; Desc: Text[100]; FunderLoanNo: Code[20]; BankAc: Code[100]; Currency: Code[20]; PostingGroup: Code[50]; DocNo: Code[20]; ExtDocNo: text[250])
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";

        // principleAcc: Code[100];
        // interestAccExpense: Code[100];
        // interestAccPay: Code[100];
        withholdingAcc: Code[20];
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        venPostingGroup: Record "Treasury Posting Group";
        funderLoan: Record "Funder Loan";

        _ConvertedCurrency: Decimal;
    begin
        JournalEntry.LockTable();
        if JournalEntry.FindLast() then
            NextEntryNo := JournalEntry."Line No." + 1
        else
            NextEntryNo := 1;

        //**********************************************
        //          Get Posting groups & Posting Accounts
        //**********************************************
        // if PostingGroup = '' then begin
        //     funderLoan.Reset();
        //     if not funderLoan.Get(FunderLoanNo) then
        //         Error('Funder %1 not found', FunderLoanNo);
        //     // if not venPostingGroup.Get(funderLoan."Posting Group") then
        //     //     Error('Missing Posting Group: %1', funderLoan."No.");
        //     interestAccExpense := funderLoan."Interest Expense";
        //     if interestAccExpense = '' then
        //         Error('Missing Interest Expense A/C: %1', funderLoan."No.");
        //     interestAccPay := funderLoan."Interest Payable";
        //     if interestAccPay = '' then
        //         Error('Missing Interest Payable A/C: %1', funderLoan."No.");
        //     principleAcc := funderLoan."Payables Account";
        //     if principleAcc = '' then
        //         Error('Missing Principle A/C: %1', funderLoan."No.");
        // end
        // else begin

        // if not venPostingGroup.Get(PostingGroup) then
        //     Error('Missing Posting Group: %1', funderLoan."No.");
        funderLoan.Reset();
        funderLoan.SetRange("No.", FunderLoanNo);
        if not funderLoan.Find('-') then
            Error('Funder Loan %1 not found', FunderLoanNo);
        // interestAccExpense := funderLoan."Interest Expense";
        // if interestAccExpense = '' then
        //     Error('Missing Interest Expense A/C: %1', funderLoan."No.");
        // interestAccPay := funderLoan."Interest Payable";
        // if interestAccPay = '' then
        //     Error('Missing Interest Payable A/C: %1', funderLoan."No.");
        // principleAcc := funderLoan."Payables Account";
        // if principleAcc = '' then
        //     Error('Missing Principle A/C: %1', funderLoan."No.");

        // end;
        if not generalSetup.FindFirst() then
            Error('Please Define Withholding Tax under General Setup');
        withholdingAcc := generalSetup.FunderWithholdingAcc;
        if Currency <> '' then
            _ConvertedCurrency := ConvertCurrencyAmount(Currency, Amount, funderLoan.CustomFX)
        else
            _ConvertedCurrency := Amount;
        JournalEntry.Init();
        JournalEntry."Journal Template Name" := 'GENERAL';
        JournalEntry."Journal Batch Name" := 'TREASURY';
        JournalEntry."Line No." := NextEntryNo;
        JournalEntry.Entry_ID := NextEntryNo;
        JournalEntry."External Document No." := ExtDocNo;

        //JournalEntry.Validate(JournalEntry.Amount);
        JournalEntry."Posting Date" := Today;
        JournalEntry.Creation_Date := Today;
        if DocNo <> '' then
            JournalEntry."Document No." := DocNo
        else
            JournalEntry."Document No." := FunderLoanNo + Format(Today);

        JournalEntry."Currency Code" := Currency;
        if Origin = 'init' then begin  //*
            JournalEntry.Description := funderLoan.Name + ' ' + ExtDocNo;
            JournalEntry."Account Type" := JournalEntry."Account Type"::"Bank Account";
            JournalEntry."Account No." := BankAc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := GLAcc;
        end;
        if Origin = 'interest' then begin
            JournalEntry.Description := funderLoan.Name + ' ' + funderLoan."No." + ' ' + Format(Today);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interestAccPayable
        end;
        if Origin = 'interest-payment' then begin
            JournalEntry.Description := funderLoan.Name + ' ' + funderLoan."No." + ' ' + Format(Today);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := -Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := -Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interestAccPayable
        end;
        if Origin = 'reverse-interest' then begin
            JournalEntry.Description := funderLoan.Name + ' ' + funderLoan."No." + ' ' + Format(Today);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := -Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := -Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interestAccPayable
        end;
        if Origin = 'withholding' then begin
            JournalEntry.Description := Desc;
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interestAccPayable
        end;
        if Origin = 'redemption' then begin
            JournalEntry.Description := Desc;
            JournalEntry."Account Type" := JournalEntry."Account Type"::"Bank Account";
            JournalEntry."Account No." := BankAc; // Paying Bank
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := GLAcc;
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
    // Converts Currency to Local
    procedure ConvertCurrencyAmount(var CurrencyCode: Code[10]; var Amount: Decimal; FXSource: boolean): Decimal
    var
        Currency: Record "Currency";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrencyCustom: Record "Currency";
        CurrencyExchangeRateCustom: Record "Currency Exchange Rate";
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
                    NewAmount := Amount * (1 / ExchangeRate);
                    exit(NewAmount);
                end else
                    Error('Exchange rate is zero for currency %1', CurrencyCode);
            end else
                Error('Currency not found for code %1', CurrencyCode);
        end else
            Error('Currency code is empty');
    end;
    // Converts Curreny the Given Paramenter
    procedure ConvertCurrencyTo(var CurrencyCode: Code[10]; var Amount: Decimal; FXSource: boolean): Decimal
    var
        Currency: Record "Currency";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrencyCustom: Record "Currency";
        CurrencyExchangeRateCustom: Record "Currency Exchange Rate";
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

    procedure SetFunderNoFilter(funderLoanNo: Code[20])
    begin
        ReportFlag.DeleteAll();
        ReportFlag.Init();
        ReportFlag."Funder Loan No." := funderLoanNo;
        ReportFlag."Utilizing User" := UserId;
        ReportFlag.Insert();
        // Commit();
    end;

    /*procedure DuplicateRecord(SourceRecordID: Code[20])
       var
           SourceRecord: Record "Funder Loan";
           NewRecord: Record "Funder Loan";
           NewRecord1: Record "Funder Loan";
           GenSetup: Record "Treasury General Setup";
           NoSer: Codeunit "No. Series";
           funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
           funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
           funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
           funderLegderEntry3: Record FunderLedgerEntry;//Calculate every month
           _interestValue: Decimal;
           _principalValue: Decimal;
           _nextEntryNo: Integer;

       begin
           // Step 1: Retrieve the existing record
           SourceRecord.Reset();
           SourceRecord.SetRange("No.", SourceRecordID);
           if not SourceRecord.Find('-') then
               Error('Funder Loan not found.');

           if SourceRecord.Status <> SourceRecord.Status::Approved then
               Error('Record Not Approved');
           if SourceRecord."Bank Ref. No." = '' then
               Error('Missing Bank Reference No for Funder Loan', funderLoan."No.");


           if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::Interest then begin
               // Step 2: Create a new record and copy fields
               NewRecord.Init();
               NewRecord.TransferFields(SourceRecord); // Copy all fields from the source record

               _docNo := TrsyMgt.GenerateDocumentNumber();
               // Step 3: Modify the new record (e.g., set a new primary key or unique field)
               GenSetup.Get(0);
               GenSetup.TestField("Funder Loan No.");
               NewRecord."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true); // Replace with logic to generate a unique key

               NewRecord."Original Disbursed Amount" := 0;
               NewRecord.Status := NewRecord.Status::Open;

               SourceRecord.CalcFields(NetInterestamount);
               _interestValue := SourceRecord.NetInterestamount;

               //funderLegderEntry.LockTable();
               funderLegderEntry.Reset();
               if funderLegderEntry.FindLast() then
                   _nextEntryNo := funderLegderEntry."Entry No." + 1;


               funderLegderEntry.Init();
               funderLegderEntry."Entry No." := _nextEntryNo;
               funderLegderEntry."Funder No." := SourceRecord."Funder No.";
               funderLegderEntry."Funder Name" := SourceRecord.Name;
               funderLegderEntry."Loan Name" := SourceRecord."Loan Name";
               funderLegderEntry."Loan No." := NewRecord."No.";
               funderLegderEntry."Posting Date" := Today;
               funderLegderEntry."Document No." := _docNo;
               funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
               funderLegderEntry.Description := 'Interest calculation' + Format(Today);
               funderLegderEntry.Amount := _interestValue;
               funderLegderEntry."Amount(LCY)" := _interestValue;
               funderLegderEntry."Remaining Amount" := _interestValue;
               funderLegderEntry.Insert();
               if (funderLoan.EnableGLPosting = true) and (_interestValue <> 0) then
                   DirectGLPosting('interest', SourceRecord."Payables Account", _interestValue, 'Interest', funderLoan."No.", SourceRecord."Interest Payable", '', '', '', funderLoan."Bank Ref. No.");//GROSS Interest

               // Step 4: Insert the new record
               if not NewRecord.Insert() then
                   Error('Failed to Create a Loan record.');
               Message('Loan %1 successfully created', NewRecord."No.");
           end;
           if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::Principal then begin
               // Step 2: Create a new record and copy fields
               NewRecord.Init();
               NewRecord.TransferFields(SourceRecord); // Copy all fields from the source record

               _docNo := TrsyMgt.GenerateDocumentNumber();
               // Step 3: Modify the new record (e.g., set a new primary key or unique field)
               GenSetup.Get(0);
               GenSetup.TestField("Funder Loan No.");
               NewRecord."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true); // Replace with logic to generate a unique key

               // NewRecord.Validate("Original Disbursed Amount"); // Validate to create Funder entries
               NewRecord.Status := NewRecord.Status::Open;
               // Step 4: Insert the new record
               if NewRecord.Insert() then begin
                   NewRecord1.Reset();
                   NewRecord1.SetRange("No.", NewRecord."No.");
                   if NewRecord1.Find('-') then begin
                       NewRecord1.Validate("Original Disbursed Amount");
                       NewRecord1.Modify();
                   end;
               end else begin

                   Error('Failed to Create a Loan record.');
               end;
               Message('Loan %1 successfully created', NewRecord."No.");
           end;
           if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::"Principal + Interest" then begin
               // Step 2: Create a new record and copy fields
               NewRecord.Init();
               NewRecord.TransferFields(SourceRecord); // Copy all fields from the source record

               _docNo := TrsyMgt.GenerateDocumentNumber();
               // Step 3: Modify the new record (e.g., set a new primary key or unique field)
               GenSetup.Get(0);
               GenSetup.TestField("Funder Loan No.");
               NewRecord."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true); // Replace with logic to generate a unique key

               // NewRecord.Validate("Original Disbursed Amount"); // Validate to create Funder entries
               NewRecord.Status := NewRecord.Status::Open;

               SourceRecord.CalcFields(NetInterestamount);
               _interestValue := SourceRecord.NetInterestamount;

               //funderLegderEntry.LockTable();
               funderLegderEntry.Reset();
               if funderLegderEntry.FindLast() then
                   _nextEntryNo := funderLegderEntry."Entry No." + 1;


               funderLegderEntry.Init();
               funderLegderEntry."Entry No." := _nextEntryNo;
               funderLegderEntry."Funder No." := SourceRecord."Funder No.";
               funderLegderEntry."Funder Name" := SourceRecord.Name;
               funderLegderEntry."Loan Name" := SourceRecord."Loan Name";
               funderLegderEntry."Loan No." := NewRecord."No.";
               funderLegderEntry."Posting Date" := Today;
               funderLegderEntry."Document No." := _docNo;
               funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
               funderLegderEntry.Description := 'Interest calculation' + Format(Today);
               funderLegderEntry.Amount := _interestValue;
               funderLegderEntry."Amount(LCY)" := _interestValue;
               funderLegderEntry."Remaining Amount" := _interestValue;
               funderLegderEntry.Insert();
               if (funderLoan.EnableGLPosting = true) and (_interestValue <> 0) then
                   DirectGLPosting('interest', SourceRecord."Payables Account", _interestValue, 'Interest', funderLoan."No.", SourceRecord."Interest Payable", '', '', '', funderLoan."Bank Ref. No.");//GROSS Interest

               // Step 4: Insert the new record
               // if not NewRecord.Insert() then
               //     Error('Failed to Create a Loan record.');
               if NewRecord.Insert() then begin
                   NewRecord1.Reset();
                   NewRecord1.SetRange("No.", NewRecord."No.");
                   if NewRecord1.Find('-') then begin
                       NewRecord1.Validate("Original Disbursed Amount");
                       NewRecord1.Modify();
                   end;
               end else begin

                   Error('Failed to Create a Loan record.');
               end;
               Message('Loan %1 successfully created', NewRecord."No.");
           end;
           if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::Terminate then begin

           end;
       end;*/

    procedure PartialRedemptionDuplicateRecord(SourceRecordID: Code[20]): Code[20]
    var
        SourceRecord: Record "Funder Loan";
        NewRecord: Record "Funder Loan";
        NewRecord1: Record "Funder Loan";
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry3: Record FunderLedgerEntry;//Calculate every month
        _interestValue: Decimal;
        _principalValue: Decimal;
        _nextEntryNo: Integer;

        RedemptionLog: Record "Redemption Log Tbl";

    begin
        RedemptionLog.Reset();
        RedemptionLog.SetRange("Loan No.", SourceRecordID);
        if not RedemptionLog.Find('-') then
            Error('Redemption record %1 dont exist', SourceRecordID);
        // Step 1: Retrieve the existing record
        SourceRecord.Reset();
        SourceRecord.SetRange("No.", SourceRecordID);
        if not SourceRecord.Find('-') then
            Error('Funder Loan not found.');

        if SourceRecord.Status <> SourceRecord.Status::Approved then
            Error('Record Not Approved');
        if SourceRecord."Bank Ref. No." = '' then
            Error('Missing Bank Reference No for Funder Loan', funderLoan."No.");


        // Step 2: Create a new record and copy fields
        NewRecord.Init();
        NewRecord.TransferFields(SourceRecord); // Copy all fields from the source record

        _docNo := TrsyMgt.GenerateDocumentNumber();
        // Step 3: Modify the new record (e.g., set a new primary key or unique field)
        GenSetup.Get(0);
        GenSetup.TestField("Funder Loan No.");
        NewRecord."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true); // Replace with logic to generate a unique key

        NewRecord."Original Disbursed Amount" := RedemptionLog.RemainingAmount;
        NewRecord.Status := NewRecord.Status::Open;
        NewRecord.State := NewRecord.State::Active;
        RedemptionLog."New Loan No." := NewRecord."No.";
        RedemptionLog.Modify();
        // Step 4: Insert the new record
        if not NewRecord.Insert() then
            Error('Failed to Create a Loan record.');

        Message('Loan %1 successfully created', NewRecord."No.");
        exit(NewRecord."No.");


    end;

    procedure DuplicateRecord(RolloverID: Integer)
    var
        SourceRecord: Record "Funder Loan";
        NewRecord: Record "Funder Loan";
        NewRecord1: Record "Funder Loan";
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry1: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry2: Record FunderLedgerEntry;//Calculate every month
        funderLegderEntry3: Record FunderLedgerEntry;//Calculate every month
        _interestValue: Decimal;
        _principalValue: Decimal;
        _nextEntryNo: Integer;

        _rolloverRec: Record "Roll over Tbl";
    begin
        _rolloverRec.Reset();
        _rolloverRec.SetRange(Line, RolloverID);
        if not _rolloverRec.Find('-') then
            Error('No Rollover Record Exist');
        // Step 1: Retrieve the existing record
        SourceRecord.Reset();
        SourceRecord.SetRange("No.", _rolloverRec."Loan No.");
        if not SourceRecord.Find('-') then
            Error('Funder Loan not found.');

        if SourceRecord.Status <> SourceRecord.Status::Approved then
            Error('Record Not Approved');
        if SourceRecord."Bank Ref. No." = '' then
            Error('Missing Bank Reference No for Funder Loan', funderLoan."No.");


        if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::Interest then begin
            // Step 2: Create a new record and copy fields
            NewRecord.Init();
            NewRecord.TransferFields(SourceRecord); // Copy all fields from the source record

            _docNo := TrsyMgt.GenerateDocumentNumber();
            // Step 3: Modify the new record (e.g., set a new primary key or unique field)
            GenSetup.Get(0);
            GenSetup.TestField("Funder Loan No.");
            NewRecord."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true); // Replace with logic to generate a unique key
            SourceRecord.CalcFields(NetInterestamount);
            _interestValue := SourceRecord.NetInterestamount;

            NewRecord."Original Disbursed Amount" := 0;
            NewRecord.Status := NewRecord.Status::Open;
            NewRecord.Rollovered := NewRecord.Rollovered::"Roll overed";
            if _rolloverRec.RollOverType = _rolloverRec.RollOverType::"Full Rollover" then
                NewRecord."Rollovered Interest" := _interestValue
            else
                NewRecord."Rollovered Interest" := _rolloverRec.Amount;
            NewRecord."Original Record No." := SourceRecord."No.";

            // Step 4: Insert the new record
            if not NewRecord.Insert() then
                Error('Failed to Create a Loan record.');
            Message('Loan %1 successfully created', NewRecord."No.");
        end;
        if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::Principal then begin
            // Step 2: Create a new record and copy fields
            NewRecord.Init();
            NewRecord.TransferFields(SourceRecord); // Copy all fields from the source record

            _docNo := TrsyMgt.GenerateDocumentNumber();
            // Step 3: Modify the new record (e.g., set a new primary key or unique field)
            GenSetup.Get(0);
            GenSetup.TestField("Funder Loan No.");
            NewRecord."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true); // Replace with logic to generate a unique key

            NewRecord.Status := NewRecord.Status::Open;
            NewRecord.Rollovered := NewRecord.Rollovered::"Roll overed";
            if not (_rolloverRec.RollOverType = _rolloverRec.RollOverType::"Full Rollover") then
                NewRecord."Original Disbursed Amount" := _rolloverRec.Amount;

            NewRecord."Original Record No." := SourceRecord."No.";
            NewRecord."Rollovered Interest" := 0;

            // Step 4: Insert the new record
            if not NewRecord.Insert() then begin
                Error('Failed to Create a Loan record.');
            end;
            Message('Loan %1 successfully created', NewRecord."No.");
        end;
        if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::"Principal + Interest" then begin
            // Step 2: Create a new record and copy fields
            NewRecord.Init();
            NewRecord.TransferFields(SourceRecord); // Copy all fields from the source record

            _docNo := TrsyMgt.GenerateDocumentNumber();
            // Step 3: Modify the new record (e.g., set a new primary key or unique field)
            GenSetup.Get(0);
            GenSetup.TestField("Funder Loan No.");
            NewRecord."No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true); // Replace with logic to generate a unique key
            SourceRecord.CalcFields(NetInterestamount);
            _interestValue := SourceRecord.NetInterestamount;

            NewRecord.Status := NewRecord.Status::Open;
            NewRecord.Rollovered := NewRecord.Rollovered::"Roll overed";
            if (_rolloverRec.RollOverType = _rolloverRec.RollOverType::"Full Rollover") then begin
                NewRecord."Original Disbursed Amount" := _rolloverRec.Amount; //Amount =  Principal + Interest
            end else begin
                NewRecord."Original Disbursed Amount" := _rolloverRec.Amount;
            end;

            NewRecord."Original Record No." := SourceRecord."No.";
            NewRecord."Rollovered Interest" := 0;

            // Step 4: Insert the new record
            // if not NewRecord.Insert() then
            //     Error('Failed to Create a Loan record.');
            if not NewRecord.Insert() then begin
                Error('Failed to Create a Loan record.');
            end;
            Message('Loan %1 successfully created', NewRecord."No.");
        end;
        if SourceRecord.PlacementMaturity = SourceRecord.PlacementMaturity::Terminate then begin
        end;



    end;

    procedure FXGainLossGLPosting(Origin: Text[100]; Bank: Code[100]; GainLossAccount: Code[100]; Amount: Decimal; Desc: Text[100]; Currency: Code[20]; DocNo: Code[20]; ExtDocNo: text[250])
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";

        withholdingAcc: Code[20];
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        venPostingGroup: Record "Treasury Posting Group";
        funderLoan: Record "Funder Loan";

        _ConvertedCurrency: Decimal;
    begin
        JournalEntry.LockTable();
        if JournalEntry.FindLast() then
            NextEntryNo := JournalEntry."Line No." + 1
        else
            NextEntryNo := 1;


        JournalEntry.Init();
        JournalEntry."Journal Template Name" := 'GENERAL';
        JournalEntry."Journal Batch Name" := 'TREASURY';
        JournalEntry."Line No." := NextEntryNo;
        JournalEntry.Entry_ID := NextEntryNo;
        JournalEntry."External Document No." := ExtDocNo;

        //JournalEntry.Validate(JournalEntry.Amount);
        JournalEntry."Posting Date" := Today;
        JournalEntry.Creation_Date := Today;
        JournalEntry."Document No." := DocNo;
        JournalEntry."Currency Code" := Currency;
        if Origin = 'loss' then begin
            JournalEntry.Description := Desc;
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GainLossAccount;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.0001, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"Bank Account";
            JournalEntry."Bal. Account No." := Bank;
        end;
        if Origin = 'gain' then begin
            JournalEntry.Description := Desc;
            JournalEntry."Account Type" := JournalEntry."Account Type"::"Bank Account";
            JournalEntry."Account No." := Bank;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.0001, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := GainLossAccount;
        end;

        GLPost.RunWithCheck(JournalEntry);


    end;


    var
        myGlobalCounter: Integer;
        // vendor: Record Vendor;
        funderLoan: Record "Funder Loan";
        funder: Record Funders;
        // debtor: Record Debtor;
        // funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderPostingGroup: Record 93;
        generalSetup: Record "Treasury General Setup";
        _docNo: Code[20];
        TrsyMgt: Codeunit "Treasury Mgt CU";
        ReportFlag: Record "Report Flags";
}