report 50290 "Funder Interest Calc. Cron"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Funder Intrest Calculation Cron';



    dataset
    {
        dataitem("Funder Loan"; "Funder Loan")
        {
            trigger OnAfterGetRecord()
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

                _funder: Record Funders;
                _portfolio: Record Portfolio;

                FunderLoanNo: Code[20];
            begin

                FunderLoanNo := "Funder Loan"."No.";

                latestRemainingAmount := 0;
                funderLoan.Reset();
                funderLoan.SetRange(funderLoan."No.", FunderLoanNo);
                funderLoan.SetFilter(InterestRate, '<>%1', 0);
                funderLoan.SetFilter(Category, '<>%1', 'BANK OVERDRAFT');
                funderLoan.SetFilter(Status, '=%1', funderLoan.Status::Approved);

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

                    _funder.Reset();
                    _funder.SetRange("No.", funderLoan."Funder No.");
                    if not _funder.Find('-') then
                        Error('Funder %1 not found _fl', funderLoan."Funder No.");

                    _portfolio.Reset();
                    _portfolio.SetRange("No.", _funder.Portfolio);
                    if not _portfolio.Find('-') then
                        Error('Portfolio %1 not found _fl', _funder.Portfolio);

                    funderLegderEntry3.Reset();
                    funderLegderEntry3.SetRange("Funder No.", funder."No.");
                    funderLegderEntry3.SetRange(funderLegderEntry3."Loan No.", funderLoan."No.");
                    funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", funderLegderEntry2."Document Type"::Interest);
                    funderLegderEntry3.SetRange(funderLegderEntry3."Posting Date", CALCDATE('<CM>', Today));
                    if funderLegderEntry3.Find('-') then
                        CurrReport.Skip();

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


                        // if _interestComputationTimes = 0 then begin
                        //     // endMonthDate := CALCDATE('<+CM>', Today);
                        //     // remainingDays := endMonthDate - funderLoan.PlacementDate + 0;
                        //     if CALCDATE('<+CM>', Today) = CALCDATE('<+CM>', funderLoan.PlacementDate) then begin
                        //         endMonthDate := CALCDATE('<+CM>', Today);
                        //         remainingDays := endMonthDate - funderLoan.PlacementDate + 0;
                        //     end else begin
                        //         endMonthDate := CALCDATE('<+CM>', Today);
                        //         remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 0
                        //     end;
                        // end else begin
                        //     endMonthDate := CALCDATE('<+CM>', Today);
                        //     remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 0
                        //     // remainingDays := (endMonthDate - Today) + 1;
                        // end;
                        if _interestComputationTimes = 0 then begin

                            if CALCDATE('<+CM>', Today) = CALCDATE('<+CM>', funderLoan.PlacementDate) then begin
                                endMonthDate := CALCDATE('<+CM>', Today);
                                remainingDays := endMonthDate - funderLoan.PlacementDate + 1;
                            end;
                            if CALCDATE('<+CM>', Today) <> CALCDATE('<+CM>', funderLoan.PlacementDate) then begin
                                endMonthDate := CALCDATE('<+CM>', Today);
                                remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 1
                            end;
                            if CALCDATE('<+CM>', funderLoan.MaturityDate) = CALCDATE('<+CM>', Today) then begin
                                endMonthDate := funderLoan.MaturityDate;
                                remainingDays := funderLoan.MaturityDate - CALCDATE('<-CM>', funderLoan.MaturityDate) + 1
                            end;

                        end
                        else begin
                            endMonthDate := CALCDATE('<+CM>', Today);
                            remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 1;
                            if CALCDATE('<+CM>', funderLoan.MaturityDate) = CALCDATE('<+CM>', Today) then begin
                                endMonthDate := funderLoan.MaturityDate;
                                remainingDays := funderLoan.MaturityDate - CALCDATE('<-CM>', funderLoan.MaturityDate) + 1
                            end;
                            // remainingDays := (endMonthDate - Today) + 1;
                        end;


                        // Get Total of Original Amount (Principal)
                        funderLegderEntry3.Reset();
                        funderLegderEntry3.SetRange("Funder No.", funder."No.");
                        funderLegderEntry3.SetRange("Loan No.", FunderLoanNo);
                        funderLegderEntry3.SetFilter(funderLegderEntry3."Document Type", '=%1|=%2', funderLegderEntry2."Document Type"::"Original Amount", funderLegderEntry2."Document Type"::"Secondary Amount");

                        //funderLegderEntry3.SetRange(funderLegderEntry3."Document Type", );
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
                        _interestRate_Active := TrsyMgt.GetInterestRate(funderLoan."No.", 'FUNDER');

                        if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/360" then begin
                            monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                        end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/360" then begin
                            monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                        end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/364" then begin
                            monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                        end else if funderLoan.InterestMethod = funderLoan.InterestMethod::"Actual/365" then begin
                            monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                        end
                        else if funderLoan.InterestMethod = funderLoan.InterestMethod::"30/365" then begin
                            monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 365), 0.0001, '=');
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
                        funderLegderEntry."Posting Date" := CALCDATE('<CM>', Today);
                        funderLegderEntry."Document Date" := Today;
                        funderLegderEntry."Document No." := _docNo;
                        funderLegderEntry."External Document No." := _docNo + ' Interest ' + Format(Today, 0, '<Month Text> <Year4>');
                        funderLegderEntry."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                        funderLegderEntry.Category := funderLoan.Category; // Funder Loan Category
                        funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                        funderLegderEntry.Description := funderLoan."No." + ' ' + funderLoan.Name + ' ' + _portfolio.Code + '-' + funderLoan."Bank Ref. No." + ' - ' + Format(Today, 0, '<Month Text> <Year4>');

                        funderLegderEntry.Amount := monthlyInterest;
                        funderLegderEntry."Amount(LCY)" := monthlyInterest;
                        funderLegderEntry."Interest Payable Amount" := (monthlyInterest - witHldInterest);
                        funderLegderEntry."Interest Payable Amount (LCY)" := (monthlyInterest - witHldInterest);
                        funderLegderEntry."Witholding Amount" := (-witHldInterest);
                        funderLegderEntry."Witholding Amount (LCY)" := (-witHldInterest);

                        funderLegderEntry."Account No." := interestAccExpense;
                        funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"G/L Account";
                        funderLegderEntry."Bal. Account No." := interestAccPayable;
                        funderLegderEntry."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account";
                        funderLegderEntry."Bal. Account No. 2" := withholdingAcc; // Wth
                        funderLegderEntry."Bal. Account Type 2" := funderLegderEntry."Bal. Account Type"::"G/L Account"; //Wth


                        funderLegderEntry.Insert();
                        if (funderLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                            FunderMgtCU.DirectGLPosting('interest', interestAccExpense, withholdingAcc, monthlyInterest, witHldInterest, 'Interest', funderLoan."No.", interestAccPayable, funderLoan.Currency, '', '', funderLegderEntry."External Document No.", _funder."Shortcut Dimension 1 Code");//GROSS Interest
                                                                                                                                                                                                                                                                                                        //Commit();
                        funderLegderEntry1.Init();
                        funderLegderEntry1."Entry No." := NextEntryNo + 1;
                        funderLegderEntry1."Funder No." := funder."No.";
                        funderLegderEntry1."Funder Name" := funder.Name;
                        funderLegderEntry1."Loan Name" := _loanName;
                        funderLegderEntry1."Loan No." := _loanNo;
                        funderLegderEntry1."Document Type" := funderLegderEntry."Document Type"::Withholding;
                        funderLegderEntry1."Posting Date" := CALCDATE('<CM>', Today);
                        funderLegderEntry1."Document Date" := Today;
                        funderLegderEntry1.Category := funderLoan.Category; // Funder Loan Category
                        funderLegderEntry1."Document No." := _docNo;
                        funderLegderEntry1."External Document No." := _docNo + ' Withhlding ' + Format(Today, 0, '<Month Text> <Year4>');
                        funderLegderEntry1."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                        funderLegderEntry1.Description := funderLoan."No." + ' ' + funderLoan.Name + ' ' + _portfolio.Code + ' - ' + funderLoan."Bank Ref. No." + ' - ' + Format(Today, 0, '<Month Text> <Year4>') + ' Withholding Calculation';
                        funderLegderEntry1.Amount := -witHldInterest;
                        funderLegderEntry1."Amount(LCY)" := -witHldInterest;

                        funderLegderEntry1."Bal. Account No." := withholdingAcc;
                        funderLegderEntry1."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account";
                        funderLegderEntry1."Account No." := interestAccPayable;
                        funderLegderEntry1."Account Type" := funderLegderEntry."Account Type"::"G/L Account";

                        funderLegderEntry1.Insert();

                        // if (funderLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                        // DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', funderLoan."No.", interestAccPayable, '', '', '', funderLoan."Bank Ref. No.", _funder."Shortcut Dimension 1 Code");

                    end else begin
                        Message('Select Interest Rate Type');
                    end;
                    // until funderLoan.Next() = 0;

                end;

            end;
        }

    }

    trigger OnPreReport()
    var
        _fNo: Code[20];
        placementDate: Date;
        maturityDate: Date;
        dateDiff: Integer;
        _freq: Integer;
        StartDate: Date;
        EndDate: Date;
        YearNumDays: Integer;
        DateRange: Date;
        FirstMonthDays: Integer;
        LastMonthDays: Integer;

        NoOfMonths: Integer;
        monthCounter: Integer;
        DaysInMonth: Integer;

        _interestRate_Active: Decimal;
        _principle: Decimal;
        remainingDays: Integer;
        monthlyInterest: Decimal;
        endYearDate: Date;
        _currentMonthInLoop: Date;
        _previousMonthInLoop: Date;

        NoOfQuarter: Integer;
        QuarterCounter: Integer;
        _currentQuarterInLoop: Date;
        _previousQuarterInLoop: Date;
        DaysInQuarter: Integer;
        StatingQuarterEndDate: date;
        StatingQuarterStartDate: date;
        QuarterCounterRem: Integer;

        NoOfBiann: Integer;
        BiannCounter: Integer;
        _currentBiannInLoop: Date;
        _previousBiannInLoop: Date;
        DaysInBiann: Integer;
        StatingBiannEndDate: date;
        StatingBiannStartDate: Date;
        BiannCounterRem: Integer;

        NoOfAnnual: Integer;
        AnnualCounter: Integer;
        _currentAnnualInLoop: Date;
        _previousAnnualInLoop: Date;
        DaysInAnnual: Integer;
        StatingAnnualEndDate: date;

        _amortization: Decimal;
        _totalPayment: Decimal;
        _outstandingAmount: Decimal;

        _withHoldingTax_Percent: Decimal;
        _withHoldingTax_Amnt: Decimal;
        dueDate: Date;

        _sumInterest: Decimal;
        _sumWtholding: Decimal;
        _sumNetInterest: Decimal;
        _sumTotalPayment: Decimal;
        _sumOutstanding: Decimal;
        _sumAmortization: Decimal;
        _sumNumberOfDays: Decimal;

        _secondStep: Boolean;

        _dueDateNoOfMonths: Integer;
        _dueDateNoOfQuarter: Integer;
        _dueDateNoOfBiannual: Integer;
        _dueDateNoOfAnnual: Integer;

        _dueDateAmortizedValue: Decimal;

        _dueDateInfluence, _skipWeekendInfluence : Boolean; //This indicates if calculation will follow due date as the starting and subsequent period date will be seeded by it.

        _dailyPrincipal: Decimal;
        DueDateCalcPeriodEq: Boolean;
        LoopNetInterest: Decimal;
        _sumPrincipalValue: Decimal;
        _floatingOutstandingValue: Decimal;
    begin
    end;

    trigger OnPostReport()
    begin
        Message('Interest Calculated');
    end;



    var
        funderLoan: Record "Funder Loan";
        funder: Record Funders;
        // debtor: Record Debtor;
        // funderLegderEntry: Record FunderLedgerEntry;//Calculate every month
        funderPostingGroup: Record 93;
        generalSetup: Record "Treasury General Setup";
        _docNo: Code[20];
        TrsyMgt: Codeunit "Treasury Mgt CU";
        ReportFlag: Record "Report Flags";
        FunderMgtCU: Codeunit FunderMgtCU;
}