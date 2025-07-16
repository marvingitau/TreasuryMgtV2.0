report 50287 "Funder Capitalization Schedule"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("Funder Loan"; "Funder Loan")
        {
            column(SecurityType; SecurityType) { }
            column(Name; Name) { }
            column(No_; "No.") { }
            column(PlacementDate; PlacementDate) { }
            column(PlacementMaturity; MaturityDate) { }
            column(DateDiff; DateDiff) { }
            column(Original_Disbursed_Amount; "Original Disbursed Amount") { }
            column(NetInterestamount; InterestRate) { }
            column(MaturityValue; MaturityValue) { }
            column(ContactPerson; ContactPerson) { }
            column(Telephone; Telephone) { }
        }
        dataitem(Loan; "Intr- Amort")
        {
            column(DueDate; DueDate)
            {

            }
            column(Interest; Interest)
            {

            }
            column(NetInterest; NetInterest)
            {

            }
            column(WithHldTaxAmt; WithHldTaxAmt)
            {

            }
            column(CalculationDate; CalculationDate)
            {

            }
            column(NumberofDays; NumberofDays) { }
            column(PrincipalValue; PrincipalValue) { }

        }
    }


    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = './reports/capitalizationamortization.rdlc';
        }
    }
    trigger OnPreReport()
    var
        _fNo: Code[20];
        placementDate: Date;
        maturityDate: Date;

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
        _previousAnnualInLoop: date;
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
        _sumNumberOfDays: Integer;

        _secondStep: Boolean;

        _dueDateNoOfMonths: Integer;
        _dueDateNoOfQuarter: Integer;
        _dueDateNoOfBiannual: Integer;
        _dueDateNoOfAnnual: Integer;

        _dueDateAmortizedValue: Decimal;

        _dueDateInfluence: Boolean; //This indicates if calculation will follow due date as the starting and subsequent period date will be seeded by it.
        _skipWeekendInfluence: Boolean;
        _dailyPrincipal: Decimal;
        DueDateCalcPeriodEq: Boolean;

        LoopNetInterest: Decimal;
        _sumPrincipalValue: Decimal;
    begin


        FunderNo := "Funder Loan".GetFilter("No.");

        FunderLoanTbl.Reset();
        FunderLoanTbl.SetRange("No.", FunderNo);
        if not FunderLoanTbl.Find('-') then
            Error('Funder Loan not %1 found', FunderNo);

        Funder.Reset();
        Funder.SetRange("No.", FunderLoanTbl."Funder No.");
        if not Funder.Find('-') then
            Error('Funder  not %1 found', FunderLoanTbl."Funder No.");

        ContactPerson := Funder.ContactDetailName;
        Telephone := Funder."Phone Number";

        _fNo := FunderLoanTbl."No.";
        // if FunderLoanTbl.FirstDueDate <> 0D then
        dueDate := FunderLoanTbl.ThirdDueDate;
        // else
        placementDate := FunderLoanTbl.PlacementDate;

        maturityDate := FunderLoanTbl.MaturityDate;
        DateDiff := (maturityDate - placementDate);
        endYearDate := CALCDATE('CY', Today);
        remainingDays := endYearDate - FunderLoanTbl.PlacementDate;

        _principle := 0;
        _interestRate_Active := 0;
        DueDateCalcPeriodEq := false;

        _dueDateInfluence := FunderLoanTbl.EnableDynamicPeriod_AmortCap;
        _skipWeekendInfluence := FunderLoanTbl.EnableWeekDayRep_AmortCap;



        _withHoldingTax_Percent := FunderLoanTbl.Withldtax;
        _withHoldingTax_Amnt := 0;

        LoopNetInterest := 0;

        FunderLoanTbl.CalcFields(OrigAmntDisbLCY);
        _principle := FunderLoanTbl.OrigAmntDisbLCY;
        if (_principle = 0) then begin
            _principle := FunderLoanTbl."Original Disbursed Amount";
        end;



        Loan.Reset();
        Loan.DeleteAll();
        FirstDueAccumulator.Reset();
        FirstDueAccumulator.DeleteAll();

        if FunderLoanTbl.AmortCapPaymentOfPrincipal = FunderLoanTbl.AmortCapPaymentOfPrincipal::Monthly then begin

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin

                NoOfMonths := MonthsBetween(dueDate, maturityDate) + 0;
                if NoOfMonths = 0 then
                    NoOfMonths := 1; //ENSURE RIGHT SQEW IS TAKEN CARE 0Fs

                _dailyPrincipal := _principle / (NoOfMonths + 1);

                for monthCounter := 0 to NoOfMonths do begin
                    _currentMonthInLoop := 0D;
                    if (monthCounter = 0) and (monthCounter <> NoOfMonths) then begin
                        if dueDate = placementDate then
                            continue;
                        _currentMonthInLoop := dueDate; // Placebo
                        DaysInMonth := _currentMonthInLoop - placementDate + 0;
                    end
                    else if (monthCounter = 1) and (monthCounter <> NoOfMonths) then begin
                        _currentMonthInLoop := AdjustWeekendDate(CalcDate('<+1M>', dueDate));
                        _previousMonthInLoop := dueDate;
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop + 0;

                    end
                    else if (monthCounter = NoOfMonths) then begin
                        // _currentMonthInLoop := CalcDate('<CM>', maturityDate);
                        _currentMonthInLoop := AdjustWeekendDate(CalcDate('<+' + Format((monthCounter)) + 'M>', dueDate));
                        _previousMonthInLoop := AdjustWeekendDate(CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));
                        DaysInMonth := maturityDate - _previousMonthInLoop + 0;
                        // if _currentMonthInLoop > maturityDate then
                        _currentMonthInLoop := maturityDate;
                    end
                    else begin

                        _currentMonthInLoop := AdjustWeekendDate(CalcDate('<+' + Format((monthCounter)) + 'M>', dueDate));
                        _previousMonthInLoop := AdjustWeekendDate(CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));

                        _outstandingAmount := _principle - (_dailyPrincipal * (monthCounter + 1));
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop;
                    end;



                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentMonthInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    // withholding calc
                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentMonthInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentMonthInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentMonthInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := monthCounter;
                        FirstDueAccumulator.NumberofDays := DaysInMonth;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;


                        if (monthCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := monthCounter;
                        Loan.PrincipalValue := _principle;

                        Loan.NumberofDays := DaysInMonth;
                        Loan.DueDate := _currentMonthInLoop;
                        Loan.CalculationDate := _currentMonthInLoop;
                        Loan.Insert();

                        if monthCounter = NoOfMonths then
                            MaturityValue := _principle + Loan.NetInterest;


                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                    // monthCounter := monthCounter + 1;
                end;

            end;

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin

                NoOfMonths := MonthsBetween(dueDate, maturityDate) + 0;
                if NoOfMonths = 0 then
                    NoOfMonths := 1; //ENSURE RIGHT SQEW IS TAKEN CARE 0Fs
                _dailyPrincipal := _principle / (NoOfMonths + 1);

                for monthCounter := 0 to NoOfMonths do begin
                    _currentMonthInLoop := 0D;
                    if (monthCounter = 0) and (monthCounter <> NoOfMonths) then begin
                        if dueDate = placementDate then
                            continue;
                        _currentMonthInLoop := dueDate; // Placebo
                        DaysInMonth := _currentMonthInLoop - placementDate + 0;
                    end
                    else if (monthCounter = 1) and (monthCounter <> NoOfMonths) then begin
                        _currentMonthInLoop := (CalcDate('<+1M>', dueDate));
                        _previousMonthInLoop := dueDate;
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop + 0;

                    end
                    else if (monthCounter = NoOfMonths) then begin
                        // _currentMonthInLoop := CalcDate('<CM>', maturityDate);
                        _currentMonthInLoop := (CalcDate('<+' + Format((monthCounter)) + 'M>', dueDate));
                        _previousMonthInLoop := (CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));
                        DaysInMonth := maturityDate - _previousMonthInLoop + 0;
                        // if _currentMonthInLoop > maturityDate then
                        _currentMonthInLoop := maturityDate;
                    end
                    else begin

                        _currentMonthInLoop := (CalcDate('<+' + Format((monthCounter)) + 'M>', dueDate));
                        _previousMonthInLoop := (CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));

                        _outstandingAmount := _principle - (_dailyPrincipal * (monthCounter + 1));
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop;
                    end;



                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentMonthInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    // withholding calc
                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentMonthInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentMonthInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentMonthInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := monthCounter;
                        FirstDueAccumulator.NumberofDays := DaysInMonth;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;


                        if (monthCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := monthCounter;
                        Loan.PrincipalValue := _principle;

                        Loan.NumberofDays := DaysInMonth;
                        Loan.DueDate := _currentMonthInLoop;
                        Loan.CalculationDate := _currentMonthInLoop;
                        Loan.Insert();

                        if monthCounter = NoOfMonths then
                            MaturityValue := _principle + Loan.NetInterest;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                    // monthCounter := monthCounter + 1;
                end;

            end;

            /*
            **
            **      ENSURE BALANCE OF DAYS IS TAKEN CARE 0F
            */
            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin
                NoOfMonths := MonthsBetween(placementDate, maturityDate) + 0;
                for monthCounter := 0 to NoOfMonths do begin
                    _currentMonthInLoop := 0D;
                    if (monthCounter = 0) then begin
                        _currentMonthInLoop := CalcDate('<CM>', placementDate);
                    end
                    else if (monthCounter = NoOfMonths) then begin

                        _currentMonthInLoop := maturityDate;
                    end
                    else begin
                        QuarterCounterRem := monthCounter mod 12;
                        if QuarterCounterRem = 0 then
                            QuarterCounterRem := 12;
                        _currentMonthInLoop := CalcDate('<CM>', CalcDate('<' + Format(monthCounter) + 'M>', placementDate));
                    end;

                    DaysInMonth := DATE2DMY(_currentMonthInLoop, 1);

                    if (monthCounter = 0) then begin
                        //Start Date
                        if CalcDate('<CM>', placementDate) <> placementDate then // Is placement End of Month, if not, on the diff add 1
                            DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 1
                        else
                            DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 0;

                        //If Placement is equal to duedate <<< If this condition future me add it :) >>>

                        // if dueDate = placementDate then
                        //     DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 1
                        // else
                        //     DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 0;

                    end;
                    if (monthCounter = NoOfMonths) then begin
                        //End Date
                        DaysInMonth := maturityDate - CalcDate('<-CM>', maturityDate);
                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentMonthInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    // withholding calc
                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate > _currentMonthInLoop) and (dueDate <> _currentMonthInLoop) then begin

                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentMonthInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentMonthInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := monthCounter;
                        FirstDueAccumulator.NumberofDays := DaysInMonth;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;

                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.PrincipalValue := _principle + _sumPrincipalValue;
                        Loan.LoopCount := monthCounter;
                        if _secondStep = true then begin
                            // Loan.NumberofDays := dueDate - FunderLoanTbl.PlacementDate;
                            // Loan.DueDate := dueDate;
                            // Loan.CalculationDate := dueDate;
                            Loan.NumberofDays := _sumNumberOfDays + DaysInMonth;
                            Loan.DueDate := _currentMonthInLoop;
                            Loan.CalculationDate := _currentMonthInLoop;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInMonth;
                            Loan.DueDate := _currentMonthInLoop;
                            Loan.CalculationDate := _currentMonthInLoop;
                        end;
                        Loan.Insert();

                        if monthCounter = NoOfMonths then
                            MaturityValue := _principle + Loan.NetInterest;


                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                    // monthCounter := monthCounter + 1;
                end;

            end;

        end;

        if FunderLoanTbl.AmortCapPaymentOfPrincipal = FunderLoanTbl.AmortCapPaymentOfPrincipal::Quarterly then begin

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin

                NoOfQuarter := QuartersBetween(dueDate, maturityDate) + 0; // No of Quarters
                if NoOfQuarter = 0 then
                    NoOfQuarter := 1; //ENSURE RIGHT SQEW IS TAKEN CARE IF

                _dailyPrincipal := _principle / (NoOfQuarter + 1);

                // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                StatingQuarterEndDate := GetEndOfQuarter(placementDate);

                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    if (QuarterCounter = 0) and (QuarterCounter <> NoOfQuarter) then begin
                        if dueDate = placementDate then
                            Continue;
                        _currentQuarterInLoop := dueDate;
                        DaysInQuarter := dueDate - placementDate + 0;
                    end
                    else if (QuarterCounter = 1) and (QuarterCounter <> NoOfQuarter) then begin
                        _currentQuarterInLoop := AdjustWeekendDate(CALCDATE('<+3M>', dueDate));
                        DaysInQuarter := _currentQuarterInLoop - dueDate + 0;
                    end
                    else if QuarterCounter = NoOfQuarter then begin

                        _currentQuarterInLoop := maturityDate;
                        _previousQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));
                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop + 0;

                    end
                    else begin

                        _currentQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter) * 3) + 'M>', dueDate));
                        _previousQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));

                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop;

                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentQuarterInLoop, 'FUNDER_REPORT');
                    _principle := _principle + LoopNetInterest;


                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentQuarterInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentQuarterInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentQuarterInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := QuarterCounter;
                        FirstDueAccumulator.NumberofDays := DaysInQuarter;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;



                        if (QuarterCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := QuarterCounter;
                        Loan.PrincipalValue := _principle;
                        Loan.NumberofDays := DaysInQuarter;
                        Loan.DueDate := _currentQuarterInLoop;
                        Loan.CalculationDate := _currentQuarterInLoop;
                        Loan.Insert();

                        if QuarterCounter = NoOfQuarter then begin
                            MaturityValue := _principle + Loan.NetInterest;
                        end;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;



                end;

            end;

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin
                NoOfQuarter := QuartersBetween(dueDate, maturityDate) + 0; // No of Quarters
                if NoOfQuarter = 0 then
                    NoOfQuarter := 1; //ENSURE RIGHT SQEW IS TAKEN CARE IF

                // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                StatingQuarterEndDate := GetEndOfQuarter(placementDate);

                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    if (QuarterCounter = 0) and (QuarterCounter <> NoOfQuarter) then begin
                        if dueDate = placementDate then
                            Continue;
                        _currentQuarterInLoop := dueDate;
                        DaysInQuarter := dueDate - placementDate + 0;
                    end
                    else if (QuarterCounter = 1) and (QuarterCounter <> NoOfQuarter) then begin
                        _currentQuarterInLoop := (CALCDATE('<+3M>', dueDate));
                        DaysInQuarter := _currentQuarterInLoop - dueDate + 0;
                    end
                    else if QuarterCounter = NoOfQuarter then begin

                        _currentQuarterInLoop := maturityDate;
                        _previousQuarterInLoop := (CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));
                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop + 0;

                    end
                    else begin

                        _currentQuarterInLoop := (CALCDATE('<+' + Format((QuarterCounter) * 3) + 'M>', dueDate));
                        _previousQuarterInLoop := (CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));

                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop;

                    end;
                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentQuarterInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentQuarterInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentQuarterInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentQuarterInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := QuarterCounter;
                        FirstDueAccumulator.NumberofDays := DaysInQuarter;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;
                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;


                        if (QuarterCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := QuarterCounter;
                        Loan.NumberofDays := DaysInQuarter;
                        Loan.DueDate := _currentQuarterInLoop;
                        Loan.CalculationDate := _currentQuarterInLoop;
                        Loan.PrincipalValue := _principle;
                        Loan.Insert();

                        if QuarterCounter = NoOfQuarter then begin
                            MaturityValue := _principle + Loan.NetInterest;
                        end;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;



                end;

            end;

            /*
            **
            **      ENSURE BALANCE OF DAYS IS TAKEN CARE 0F
            */
            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin

                NoOfQuarter := QuartersBetween(placementDate, maturityDate) + 0; // No of Quarters

                // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                StatingQuarterEndDate := GetEndOfQuarter(placementDate);
                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    if QuarterCounter = 0 then begin
                        // _currentQuarterInLoop := GetStartOfQuarter(placementDate);
                        _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                        if _currentQuarterInLoop <> placementDate then
                            DaysInQuarter := (_currentQuarterInLoop - placementDate) + 1
                        else
                            DaysInQuarter := (_currentQuarterInLoop - placementDate) + 0;

                    end

                    // else if QuarterCounter = 1 then begin
                    //     _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                    //     DaysInQuarter := _currentQuarterInLoop - placementDate + 1;
                    // end
                    else if QuarterCounter = NoOfQuarter then begin
                        _currentQuarterInLoop := GetStartOfQuarter(maturityDate);
                        DaysInQuarter := maturityDate - _currentQuarterInLoop;
                        _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                        if maturityDate < _currentQuarterInLoop then
                            _currentQuarterInLoop := maturityDate

                    end
                    else begin
                        // _currentQuarterInLoop := CALCDATE('<+' + Format(QuarterCounter) + 'Q>', StatingQuarterEndDate);
                        _currentQuarterInLoop := AddQuartersToQuarterEnd(QuarterCounter, StatingQuarterEndDate);
                        // QuarterCounterRem := QuarterCounter mod 4;
                        QuarterCounterRem := GetQuarter(_currentQuarterInLoop);
                        // // DaysInQuarter := GetDaysInQuarter(QuarterCounter, DATE2DMY(_currentQuarterInLoop, 3)) + 1;
                        // if QuarterCounterRem = 4 then
                        //     DaysInQuarter := GetDaysInQuarter(_currentQuarterInLoop) - 1
                        // else
                        DaysInQuarter := GetDaysInQuarter(_currentQuarterInLoop);


                    end;


                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentQuarterInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate > _currentQuarterInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentQuarterInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentQuarterInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := QuarterCounter;
                        FirstDueAccumulator.NumberofDays := DaysInQuarter;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;


                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := QuarterCounter;
                        Loan.PrincipalValue := _principle + _sumPrincipalValue;

                        if _secondStep = true then begin
                            Loan.NumberofDays := _sumNumberOfDays + DaysInQuarter;
                            Loan.DueDate := _currentQuarterInLoop;
                            Loan.CalculationDate := _currentQuarterInLoop;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInQuarter;
                            Loan.DueDate := _currentQuarterInLoop;
                            Loan.CalculationDate := _currentQuarterInLoop;
                        end;
                        Loan.Insert();

                        if QuarterCounter = NoOfQuarter then begin
                            MaturityValue := _principle + Loan.NetInterest;
                        end;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;



                end;

            end;
        end;

        if FunderLoanTbl.AmortCapPaymentOfPrincipal = FunderLoanTbl.AmortCapPaymentOfPrincipal::Biannually then begin

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin
                NoOfBiann := Count6MonthPeriods(dueDate, maturityDate) + 0; // No of Annual
                if NoOfBiann = 0 then
                    NoOfBiann := 1; //ENSURE RIGHT SQEW IS TAKEN CARE 0F

                StatingBiannEndDate := GetClosestBiannualEndDate(placementDate);
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                for BiannCounter := 0 to NoOfBiann do begin
                    _currentBiannInLoop := 0D;
                    DaysInBiann := 0;

                    if (BiannCounter = 0) and (BiannCounter <> NoOfBiann) then begin
                        if dueDate = placementDate then
                            continue;
                        _currentBiannInLoop := dueDate;
                        DaysInBiann := _currentBiannInLoop - placementDate + 0;
                    end
                    else if (BiannCounter = 1) and (BiannCounter <> NoOfBiann) then begin
                        _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+6M>', dueDate));
                        DaysInBiann := _currentBiannInLoop - dueDate + 0;
                    end
                    else if BiannCounter = NoOfBiann then begin
                        // _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter) * 6) + 'M>', dueDate));
                        _currentBiannInLoop := maturityDate;
                        _previousBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        DaysInBiann := maturityDate - _previousBiannInLoop + 0;

                    end
                    else begin
                        _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter) * 6) + 'M>', dueDate));
                        _previousBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        DaysInBiann := _currentBiannInLoop - _previousBiannInLoop + 0;
                    end;

                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter
                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentBiannInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentBiannInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentBiannInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentBiannInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := BiannCounter;
                        FirstDueAccumulator.NumberofDays := DaysInBiann;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;
                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;

                        if (BiannCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := BiannCounter;
                        Loan.NumberofDays := DaysInBiann;
                        Loan.DueDate := _currentBiannInLoop;
                        Loan.CalculationDate := _currentBiannInLoop;
                        Loan.CalculationDate := _currentMonthInLoop;
                        Loan.PrincipalValue := _principle;

                        Loan.Insert();

                        if BiannCounter = NoOfBiann then
                            MaturityValue := _principle + Loan.NetInterest;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin
                NoOfBiann := BiannualPeriodsBetween(dueDate, maturityDate) + 0; // No of Annual
                if NoOfBiann = 0 then
                    NoOfBiann := 1; //ENSURE RIGHT SQEW IS TAKEN CARE IF

                StatingBiannEndDate := GetClosestBiannualEndDate(placementDate);
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                for BiannCounter := 0 to NoOfBiann do begin
                    _currentBiannInLoop := 0D;
                    DaysInBiann := 0;

                    if (BiannCounter = 0) and (BiannCounter <> NoOfBiann) then begin
                        if dueDate = placementDate then
                            continue;

                        _currentBiannInLoop := dueDate;
                        DaysInBiann := _currentBiannInLoop - placementDate + 0;
                    end
                    else if (BiannCounter = 1) and (BiannCounter <> NoOfBiann) then begin
                        _currentBiannInLoop := (CALCDATE('<+6M>', dueDate));
                        DaysInBiann := _currentBiannInLoop - dueDate + 0;
                    end
                    else if BiannCounter = NoOfBiann then begin
                        // _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter) * 6) + 'M>', dueDate));
                        _currentBiannInLoop := maturityDate;
                        _previousBiannInLoop := (CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        DaysInBiann := maturityDate - _previousBiannInLoop + 0;

                    end
                    else begin
                        _currentBiannInLoop := (CALCDATE('<+' + Format((BiannCounter) * 6) + 'M>', dueDate));
                        _previousBiannInLoop := (CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        DaysInBiann := _currentBiannInLoop - _previousBiannInLoop + 0;
                    end;

                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter
                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentBiannInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;


                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentBiannInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentBiannInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentBiannInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := BiannCounter;
                        FirstDueAccumulator.NumberofDays := DaysInBiann;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;
                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;

                        if (BiannCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := BiannCounter;
                        Loan.NumberofDays := DaysInBiann;
                        Loan.DueDate := _currentBiannInLoop;
                        Loan.CalculationDate := _currentBiannInLoop;
                        Loan.PrincipalValue := _principle;

                        if BiannCounter = NoOfBiann then
                            MaturityValue := _principle + Loan.NetInterest;


                        Loan.Insert();
                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;

            /*
            **
            **      ENSURE BALANCE OF DAYS IS TAKEN CARE 0F
            */
            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin
                NoOfBiann := CountBiannualPeriodsCrossed(placementDate, maturityDate) + 0; // No of biannual
                StatingBiannEndDate := GetBiannualEndDate(placementDate);
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                //What happens if Due date is equal to calculated end of period
                for BiannCounter := 0 to NoOfBiann do begin
                    if dueDate = CALCDATE('<+' + Format((BiannCounter) * 6) + 'M>', StatingBiannEndDate) then begin
                        NoOfBiann := NoOfBiann + 0;
                        DueDateCalcPeriodEq := true;
                    end;
                end;

                for BiannCounter := 0 to NoOfBiann do begin
                    _currentBiannInLoop := 0D;
                    DaysInBiann := 0;
                    if BiannCounter = 0 then begin
                        // _currentBiannInLoop := GetStartOfBiannual(placementDate);
                        _currentBiannInLoop := GetEndOfBiannual(placementDate);
                        if GetEndOfBiannual(placementDate) <> placementDate then
                            DaysInBiann := _currentBiannInLoop - placementDate + 1
                        else
                            DaysInBiann := _currentBiannInLoop - placementDate;


                    end
                    // else 
                    // if BiannCounter = 1 then begin
                    //     _currentBiannInLoop := GetEndOfBiannual(placementDate);
                    //     DaysInBiann := _currentBiannInLoop - placementDate + 0;
                    // end 
                    else if BiannCounter = NoOfBiann then begin
                        _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                        DaysInBiann := maturityDate - _currentBiannInLoop;
                        // _currentBiannInLoop := GetEndOfBiannual(maturityDate);
                        _currentBiannInLoop := (maturityDate);
                    end
                    else begin
                        // _currentBiannInLoop := CALCDATE('<+' + Format((BiannCounter + 0) * 6) + 'M>', StatingBiannEndDate);
                        // if (DueDateCalcPeriodEq) then
                        //     _currentBiannInLoop := CALCDATE('<+' + Format((BiannCounter + 1) * 6) + 'M>', StatingBiannEndDate);
                        _currentBiannInLoop := GetBiannualEndDate(CALCDATE('<+' + Format((BiannCounter + 0) * 6) + 'M>', StatingBiannEndDate));


                        /*BiannCounterRem := BiannCounter mod 2;
                        if BiannCounterRem = 0 then
                            BiannCounterRem := 2;
                        if BiannCounterRem = 2 then
                            DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3))
                        else
                            DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3));
                            */
                        DaysInBiann := GetDaysInCurrentBiannual(_currentBiannInLoop);

                    end;


                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentBiannInLoop, 'FUNDER_REPORT');
                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate > _currentBiannInLoop) and (dueDate <> _currentBiannInLoop) then begin

                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentBiannInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentBiannInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := BiannCounter;
                        FirstDueAccumulator.NumberofDays := DaysInBiann;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumNumberOfDays := 0;
                            _sumWtholding := 0;
                            _sumPrincipalValue := 0;
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;


                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumNetInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := BiannCounter;
                        Loan.PrincipalValue := _principle + _sumPrincipalValue;
                        if _secondStep = true then begin
                            Loan.NumberofDays := _sumNumberOfDays + DaysInBiann;
                            Loan.DueDate := _currentBiannInLoop;
                            Loan.CalculationDate := _currentBiannInLoop;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInBiann;
                            Loan.DueDate := _currentBiannInLoop;
                            Loan.CalculationDate := _currentBiannInLoop;
                        end;
                        Loan.Insert();

                        if BiannCounter = NoOfBiann then
                            MaturityValue := _principle + Loan.NetInterest;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;


            end;
        end;

        if FunderLoanTbl.AmortCapPaymentOfPrincipal = FunderLoanTbl.AmortCapPaymentOfPrincipal::Annually then begin

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin
                NoOfAnnual := CountExact12MonthPeriods(dueDate, maturityDate) + 1;
                if NoOfAnnual = 0 then
                    NoOfAnnual := 1;//ENSURE RIGHT SQEW IS TAKEN CARE 0Fs

                StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
                for AnnualCounter := 0 to NoOfAnnual do begin
                    _currentAnnualInLoop := 0D;
                    DaysInAnnual := 0;
                    if (AnnualCounter = 0) and (AnnualCounter <> NoOfAnnual) then begin
                        if dueDate = placementDate then
                            continue;
                        _currentAnnualInLoop := dueDate;
                        DaysInAnnual := dueDate - placementDate + 0;
                    end
                    else if (AnnualCounter = 1) and (AnnualCounter <> NoOfAnnual) then begin
                        _currentAnnualInLoop := AdjustWeekendDate(CALCDATE('<+12M>', dueDate));
                        DaysInAnnual := _currentAnnualInLoop - dueDate + 0;
                    end
                    else if AnnualCounter = NoOfAnnual then begin
                        _currentAnnualInLoop := maturityDate;
                        _previousAnnualInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop + 0;

                    end
                    else begin
                        _currentAnnualInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((AnnualCounter) * 12) + 'M>', dueDate));
                        _previousAnnualInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop;
                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentAnnualInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;


                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentAnnualInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentAnnualInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentAnnualInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := AnnualCounter;
                        FirstDueAccumulator.NumberofDays := DaysInAnnual;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;

                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;

                        if (AnnualCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;


                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := AnnualCounter;
                        Loan.NumberofDays := DaysInAnnual;
                        Loan.DueDate := _currentAnnualInLoop;
                        Loan.CalculationDate := _currentAnnualInLoop;
                        Loan.PrincipalValue := _principle;
                        Loan.Insert();

                        if AnnualCounter = NoOfAnnual then
                            MaturityValue := _principle + Loan.NetInterest;


                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin
                NoOfAnnual := CountExact12MonthPeriods(dueDate, maturityDate) + 1;
                if NoOfAnnual = 0 then
                    NoOfAnnual := 1;//ENSURE RIGHT SQEW IS TAKEN CARE 0Fs

                StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
                for AnnualCounter := 0 to NoOfAnnual do begin
                    _currentAnnualInLoop := 0D;
                    DaysInAnnual := 0;
                    if (AnnualCounter = 0) and (AnnualCounter <> NoOfAnnual) then begin
                        if dueDate = placementDate then
                            continue;
                        _currentAnnualInLoop := dueDate;
                        DaysInAnnual := dueDate - placementDate + 0;
                    end
                    else if (AnnualCounter = 1) and (AnnualCounter <> NoOfAnnual) then begin
                        _currentAnnualInLoop := (CALCDATE('<+12M>', dueDate));
                        DaysInAnnual := _currentAnnualInLoop - dueDate + 0;
                    end
                    else if AnnualCounter = NoOfAnnual then begin
                        _currentAnnualInLoop := maturityDate;
                        _previousAnnualInLoop := (CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop + 0;

                    end
                    else begin
                        _currentAnnualInLoop := (CALCDATE('<+' + Format((AnnualCounter) * 12) + 'M>', dueDate));
                        _previousAnnualInLoop := (CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop;
                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentAnnualInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentAnnualInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentAnnualInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentAnnualInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := AnnualCounter;
                        FirstDueAccumulator.NumberofDays := DaysInAnnual;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;

                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;

                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;

                        if (AnnualCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.PrincipalValue := _sumPrincipalValue;
                            Loan.Insert();
                        end;


                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := AnnualCounter;
                        Loan.NumberofDays := DaysInAnnual;
                        Loan.DueDate := _currentAnnualInLoop;
                        Loan.CalculationDate := _currentAnnualInLoop;
                        Loan.PrincipalValue := _principle;
                        Loan.Insert();

                        if AnnualCounter = NoOfAnnual then
                            MaturityValue := _principle + Loan.NetInterest;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;
            /*
            **
            **      ENSURE BALANCE OF DAYS IS TAKEN CARE 0F
            */
            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin
                NoOfAnnual := CountAnnualPeriodsCrossed(placementDate, maturityDate) + 0;
                StatingAnnualEndDate := GetAnnualEndDate(placementDate);
                for AnnualCounter := 0 to NoOfAnnual do begin
                    if dueDate = CALCDATE('<+' + Format(AnnualCounter) + 'Y>', StatingAnnualEndDate) then begin
                        DueDateCalcPeriodEq := true;
                        // if AnnualCounter = 0 then
                        //     NoOfAnnual := NoOfAnnual - 1;
                    end;
                end;
                for AnnualCounter := 0 to NoOfAnnual do begin
                    _currentAnnualInLoop := 0D;
                    DaysInAnnual := 0;
                    if AnnualCounter = 0 then begin
                        _currentAnnualInLoop := GetEndOfYear(placementDate);

                        if _currentAnnualInLoop <> placementDate then // Is placement End of Year, if not, on the diff add 1
                            DaysInAnnual := _currentAnnualInLoop - placementDate + 1
                        else
                            DaysInAnnual := _currentAnnualInLoop - placementDate
                    end
                    // else
                    // if AnnualCounter = 1 then begin
                    //     _currentAnnualInLoop := GetEndOfYear(placementDate);
                    //     if FunderLoanTbl."Inclusive Counting Interest" = true then
                    //         DaysInAnnual := _currentAnnualInLoop - placementDate + 1
                    //     else
                    //         DaysInAnnual := _currentAnnualInLoop - placementDate
                    // end
                    else if AnnualCounter = NoOfAnnual then begin
                        _currentAnnualInLoop := GetStartOfYear(maturityDate);
                        DaysInAnnual := maturityDate - _currentAnnualInLoop;
                        // _currentAnnualInLoop := GetEndOfYear(maturityDate);
                        _currentAnnualInLoop := (maturityDate);

                    end
                    else begin
                        if DueDateCalcPeriodEq then begin
                            _currentAnnualInLoop := CALCDATE('<+' + Format((AnnualCounter + 0)) + 'Y>', StatingAnnualEndDate);
                        end else
                            _currentAnnualInLoop := CALCDATE('<+' + Format(AnnualCounter) + 'Y>', StatingAnnualEndDate);
                        DaysInAnnual := GetDaysInYear(DATE2DMY(_currentAnnualInLoop, 3))
                    end;


                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentAnnualInLoop, 'FUNDER_REPORT');

                    _principle := _principle + LoopNetInterest;

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 365);
                    end
                    else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if _withHoldingTax_Percent <> 0 then begin
                        _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                    end;

                    if (dueDate <> 0D) and (dueDate > _currentAnnualInLoop) and (dueDate <> _currentAnnualInLoop) then begin

                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentAnnualInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentAnnualInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := AnnualCounter;
                        FirstDueAccumulator.NumberofDays := DaysInAnnual;
                        FirstDueAccumulator.PrincipalValue := _principle;
                        FirstDueAccumulator.Insert();
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(PrincipalValue);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumPrincipalValue := FirstDueAccumulator.PrincipalValue;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumNumberOfDays := 0;
                            _sumPrincipalValue := 0;
                        end;
                        LoopNetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;


                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := AnnualCounter;
                        Loan.PrincipalValue := _principle + _sumPrincipalValue;
                        // Loan.NumberofDays := DaysInAnnual;
                        // if (dueDate <> 0D) and (dueDate > _currentAnnualInLoop) then begin
                        if _secondStep = true then begin
                            Loan.NumberofDays := DaysInAnnual + _sumNumberOfDays;
                            Loan.DueDate := _currentAnnualInLoop;
                            Loan.CalculationDate := _currentAnnualInLoop;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInAnnual;
                            Loan.DueDate := _currentAnnualInLoop;
                            Loan.CalculationDate := _currentAnnualInLoop;
                        end;
                        Loan.Insert();

                        if AnnualCounter = NoOfAnnual then
                            MaturityValue := _principle + Loan.NetInterest;

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;

        end;




    end;

    procedure IsJanuaryFirst(CheckDate: Date): Boolean
    begin
        exit(
            (DATE2DMY(CheckDate, 1) = 1) and  // Day = 1
            (DATE2DMY(CheckDate, 2) = 1)       // Month = 1 (January)
        );
    end;

    procedure IsDecember(CheckDate: Date): Boolean
    var
        Month: Integer;
    begin
        Month := DATE2DMY(CheckDate, 2);  // Extract month
        exit(Month = 12);
    end;

    /// <summary>
    /// Adjusts weekend dates to the nearest weekday.
    /// Saturday returns Friday, Sunday returns Monday.
    /// Weekdays return unchanged.
    /// </summary>
    /// <param name="InputDate">The date to check</param>
    /// <returns>Adjusted date if weekend, original date if weekday</returns>
    procedure AdjustWeekendDate(InputDate: Date): Date
    var
        DayOfWeek: Integer;
        AdjustedDate: Date;
    begin
        if InputDate = 0D then
            exit(InputDate);

        DayOfWeek := Date2DWY(InputDate, 1); // 1=Monday, 7=Sunday

        case DayOfWeek of
            6: // Saturday
                AdjustedDate := CalcDate('<-1D>', InputDate);
            7: // Sunday
                AdjustedDate := CalcDate('<+1D>', InputDate);
            else
                AdjustedDate := InputDate; // Weekday - no change
        end;

        exit(AdjustedDate);
    end;

    procedure AddQuartersToQuarterEnd(QuarterNumber: Integer; QuarterEndDate: Date): Date
    var
        CurrentMonth, CurrentYear : Integer;
        TargetQuarter, TargetYear : Integer;
        NewQuarterEndDate: Date;
    begin
        // 1. Extract current quarter and year from the input date
        CurrentMonth := DATE2DMY(QuarterEndDate, 2);
        CurrentYear := DATE2DMY(QuarterEndDate, 3);

        // 2. Calculate current quarter (1-4)
        case CurrentMonth of
            1 .. 3:
                TargetQuarter := 1;   // Q1 (Jan-Mar)
            4 .. 6:
                TargetQuarter := 2;   // Q2 (Apr-Jun)
            7 .. 9:
                TargetQuarter := 3;   // Q3 (Jul-Sep)
            else
                TargetQuarter := 4;    // Q4 (Oct-Dec)
        end;

        // 3. Add the requested quarters (handling year overflow)
        TargetQuarter := TargetQuarter + QuarterNumber;
        TargetYear := CurrentYear + ((TargetQuarter - 1) div 4);
        TargetQuarter := ((TargetQuarter - 1) mod 4) + 1;

        // 4. Return the correct quarter-end date
        case TargetQuarter of
            1:
                NewQuarterEndDate := DMY2Date(31, 3, TargetYear);   // Q1: Mar 31
            2:
                NewQuarterEndDate := DMY2Date(30, 6, TargetYear);   // Q2: Jun 30
            3:
                NewQuarterEndDate := DMY2Date(30, 9, TargetYear);   // Q3: Sep 30
            4:
                NewQuarterEndDate := DMY2Date(31, 12, TargetYear);  // Q4: Dec 31
        end;

        exit(NewQuarterEndDate);
    end;

    procedure GetDaysInQuarter(InputDate: Date): Integer
    var
        Month, Year : Integer;
        QuarterStart, QuarterEnd : Date;
    begin
        Month := DATE2DMY(InputDate, 2);  // Get month (1-12)
        Year := DATE2DMY(InputDate, 3);   // Get year

        // Determine quarter start/end dates
        case true of
            Month in [1 .. 3]:  // Q1
                begin
                    QuarterStart := DMY2Date(1, 1, Year);
                    QuarterEnd := DMY2Date(31, 3, Year);
                end;
            Month in [4 .. 6]:  // Q2
                begin
                    QuarterStart := DMY2Date(1, 4, Year);
                    QuarterEnd := DMY2Date(30, 6, Year);
                end;
            Month in [7 .. 9]:  // Q3
                begin
                    QuarterStart := DMY2Date(1, 7, Year);
                    QuarterEnd := DMY2Date(30, 9, Year);
                end;
            else  // Q4 (Months 10-12)
                begin
                QuarterStart := DMY2Date(1, 10, Year);
                QuarterEnd := DMY2Date(31, 12, Year);
            end;
        end;

        // Calculate days in quarter (inclusive)
        exit(QuarterEnd - QuarterStart + 1);
    end;

    procedure GetClosestQuarterStartDate(PassedDate: Date): Date
    var
        Month: Integer;
        Year: Integer;
        ClosestStartOfQuarter: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date
        Year := DATE2DMY(PassedDate, 3);  // Extract the year from the passed date

        if Month in [1 .. 3] then begin
            if PassedDate > DMY2Date(31, 3, Year) then
                ClosestStartOfQuarter := DMY2Date(1, 4, Year) // April 1
            else
                ClosestStartOfQuarter := DMY2Date(1, 1, Year); // January 1
        end
        else if Month in [4 .. 6] then begin
            if PassedDate > DMY2Date(30, 6, Year) then
                ClosestStartOfQuarter := DMY2Date(1, 7, Year) // July 1
            else
                ClosestStartOfQuarter := DMY2Date(1, 4, Year); // April 1
        end
        else if Month in [7 .. 9] then begin
            if PassedDate > DMY2Date(30, 9, Year) then
                ClosestStartOfQuarter := DMY2Date(1, 10, Year) // October 1
            else
                ClosestStartOfQuarter := DMY2Date(1, 7, Year); // July 1
        end
        else begin // Months 10-12
            if PassedDate > DMY2Date(31, 12, Year) then
                ClosestStartOfQuarter := DMY2Date(1, 1, Year + 1) // January 1 next year
            else
                ClosestStartOfQuarter := DMY2Date(1, 10, Year); // October 1
        end;

        exit(ClosestStartOfQuarter);
    end;

    procedure GetClosestBiannualStartDate(PassedDate: Date): Date
    var
        Month: Integer;
        Year: Integer;
        ClosestStartOfBiannual: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date
        Year := DATE2DMY(PassedDate, 3);  // Extract the year from the passed date

        if Month <= 6 then begin
            if PassedDate > DMY2Date(30, 6, Year) then
                ClosestStartOfBiannual := DMY2Date(1, 7, Year) // July 1
            else
                ClosestStartOfBiannual := DMY2Date(1, 1, Year); // January 1
        end else begin
            if PassedDate > DMY2Date(31, 12, Year) then
                ClosestStartOfBiannual := DMY2Date(1, 1, Year + 1) // January 1 of next year
            else
                ClosestStartOfBiannual := DMY2Date(1, 7, Year); // July 1
        end;

        exit(ClosestStartOfBiannual);
    end;

    procedure IsFirstOfMonth(): Boolean
    var
        TodayDate: Date;
    begin
        TodayDate := Today;
        exit(DATE2DMY(TodayDate, 2) = 1);
    end;

    procedure MonthsBetween(StartDate: Date; EndDate: Date): Integer
    var
        StartYear: Integer;
        StartMonth: Integer;
        EndYear: Integer;
        EndMonth: Integer;
        TotalMonths: Integer;
    begin
        StartYear := DATE2DMY(StartDate, 3);  // Extract the year from StartDate
        StartMonth := DATE2DMY(StartDate, 2); // Extract the month from StartDate
        EndYear := DATE2DMY(EndDate, 3);      // Extract the year from EndDate
        EndMonth := DATE2DMY(EndDate, 2);     // Extract the month from EndDate

        TotalMonths := (EndYear - StartYear) * 12 + (EndMonth - StartMonth);
        exit(TotalMonths);
    end;

    procedure QuartersBetween(StartDate: Date; EndDate: Date): Integer
    var
        StartYear: Integer;
        StartQuarter: Integer;
        EndYear: Integer;
        EndQuarter: Integer;
        TotalQuarters: Integer;
    begin
        StartYear := DATE2DMY(StartDate, 3);  // Extract the year from StartDate
        StartQuarter := (DATE2DMY(StartDate, 2) - 1) DIV 3 + 1; // Calculate the quarter of StartDate

        EndYear := DATE2DMY(EndDate, 3);      // Extract the year from EndDate
        EndQuarter := (DATE2DMY(EndDate, 2) - 1) DIV 3 + 1;     // Calculate the quarter of EndDate

        TotalQuarters := (EndYear - StartYear) * 4 + (EndQuarter - StartQuarter);
        exit(TotalQuarters);
    end;

    procedure GetQuarter(PassedDate: Date): Integer
    var
        Month: Integer;
        Quarter: Integer;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date

        // Determine the quarter based on the month
        if Month in [1 .. 3] then
            Quarter := 1
        else if Month in [4 .. 6] then
            Quarter := 2
        else if Month in [7 .. 9] then
            Quarter := 3
        else
            Quarter := 4;

        exit(Quarter);
    end;

    procedure GetClosestQuarter(PassedDate: Date): Integer
    var
        Month: Integer;
        Quarter: Integer;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date

        // Determine the closest quarter based on the month
        if Month in [1 .. 3] then
            Quarter := 1
        else if Month in [4 .. 6] then
            Quarter := 2
        else if Month in [7 .. 9] then
            Quarter := 3
        else
            Quarter := 4;

        // Adjust to find the nearest quarter
        if Month mod 3 >= 2 then
            Quarter := Quarter + 1;
        if Quarter > 4 then
            Quarter := 1;

        exit(Quarter);
    end;

    procedure GetDaysInQuarter(Quarter: Integer; Year: Integer): Integer
    var
        StartDate: Date;
        EndDate: Date;
        NumDays: Integer;
    begin
        case Quarter of
            1:
                begin
                    StartDate := DMY2Date(1, 1, Year);    // January 1st
                    EndDate := DMY2Date(31, 3, Year);    // March 31st
                end;
            2:
                begin
                    StartDate := DMY2Date(1, 4, Year);    // April 1st
                    EndDate := DMY2Date(30, 6, Year);    // June 30th
                end;
            3:
                begin
                    StartDate := DMY2Date(1, 7, Year);    // July 1st
                    EndDate := DMY2Date(30, 9, Year);    // September 30th
                end;
            4:
                begin
                    StartDate := DMY2Date(1, 10, Year);   // October 1st
                    EndDate := DMY2Date(31, 12, Year);   // December 31st
                end;
            else
                Error('Invalid quarter value. Please enter a value between 1 and 4.');
        end;

        // Calculate the number of days
        NumDays := EndDate - StartDate + 1;

        exit(NumDays);
    end;

    procedure GetYearFromDate(dateValue: Date): Integer;
    var
        yearValue: Integer;
    begin
        yearValue := DATE2DMY(dateValue, 3); // Extracts the year from the date
        exit(yearValue);
    end;

    procedure GetStartOfQuarter(PassedDate: Date): Date
    var
        Month: Integer;
        StartOfQuarter: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date

        case Month of
            1 .. 3:
                StartOfQuarter := DMY2Date(1, 1, DATE2DMY(PassedDate, 3));  // January 1
            4 .. 6:
                StartOfQuarter := DMY2Date(1, 4, DATE2DMY(PassedDate, 3));  // April 1
            7 .. 9:
                StartOfQuarter := DMY2Date(1, 7, DATE2DMY(PassedDate, 3));  // July 1
            10 .. 12:
                StartOfQuarter := DMY2Date(1, 10, DATE2DMY(PassedDate, 3)); // October 1
            else
                Error('Invalid month value. Please enter a valid date.');
        end;

        exit(StartOfQuarter);
    end;

    procedure GetEndOfQuarter(PassedDate: Date): Date
    var
        Month: Integer;
        EndOfQuarter: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date

        case Month of
            1 .. 3:
                EndOfQuarter := DMY2Date(31, 3, DATE2DMY(PassedDate, 3)); // March 31
            4 .. 6:
                EndOfQuarter := DMY2Date(30, 6, DATE2DMY(PassedDate, 3)); // June 30
            7 .. 9:
                EndOfQuarter := DMY2Date(30, 9, DATE2DMY(PassedDate, 3)); // September 30
            10 .. 12:
                EndOfQuarter := DMY2Date(31, 12, DATE2DMY(PassedDate, 3)); // December 31
            else
                Error('Invalid month value. Please enter a valid date.');
        end;

        exit(EndOfQuarter);
    end;

    procedure GetClosestQuarterEndDate(PassedDate: Date): Date
    var
        Month: Integer;
        ClosestEndOfQuarter: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date

        if Month in [1 .. 3] then begin
            if PassedDate > DMY2Date(31, 1, DATE2DMY(PassedDate, 3)) then
                ClosestEndOfQuarter := DMY2Date(31, 3, DATE2DMY(PassedDate, 3)) // March 31
            else
                ClosestEndOfQuarter := DMY2Date(31, 12, DATE2DMY(PassedDate, 3) - 1); // December 31 of previous year
        end
        else if Month in [4 .. 6] then begin
            if PassedDate > DMY2Date(30, 4, DATE2DMY(PassedDate, 3)) then
                ClosestEndOfQuarter := DMY2Date(30, 6, DATE2DMY(PassedDate, 3)) // June 30
            else
                ClosestEndOfQuarter := DMY2Date(31, 3, DATE2DMY(PassedDate, 3)); // March 31
        end
        else if Month in [7 .. 9] then begin
            if PassedDate > DMY2Date(31, 7, DATE2DMY(PassedDate, 3)) then
                ClosestEndOfQuarter := DMY2Date(30, 9, DATE2DMY(PassedDate, 3)) // September 30
            else
                ClosestEndOfQuarter := DMY2Date(30, 6, DATE2DMY(PassedDate, 3)); // June 30
        end
        else begin
            if PassedDate > DMY2Date(31, 10, DATE2DMY(PassedDate, 3)) then
                ClosestEndOfQuarter := DMY2Date(31, 12, DATE2DMY(PassedDate, 3)) // December 31
            else
                ClosestEndOfQuarter := DMY2Date(30, 9, DATE2DMY(PassedDate, 3)); // September 30
        end;

        exit(ClosestEndOfQuarter);
    end;

    /// <summary>
    /// Counts how many standard biannual periods (June 30 and December 31) are passed between two dates.
    /// </summary>
    /// <param name="StartDate">The starting date</param>
    /// <param name="EndDate">The ending date</param>
    /// <returns>Number of biannual periods crossed</returns>
    procedure CountBiannualPeriodsCrossed(StartDate: Date; EndDate: Date): Integer
    var
        CurrentYear, EndYear : Integer;
        BiannualDates: List of [Date];
        PeriodCount: Integer;
        CurrentDate: Date;
    begin
        if (StartDate = 0D) or (EndDate = 0D) or (StartDate > EndDate) then
            exit(0);

        PeriodCount := 0;
        CurrentYear := Date2DMY(StartDate, 3);
        EndYear := Date2DMY(EndDate, 3);

        // Generate all biannual dates in the range
        for CurrentYear := CurrentYear to EndYear do begin
            BiannualDates.Add(DMY2Date(30, 6, CurrentYear));  // June 30
            BiannualDates.Add(DMY2Date(31, 12, CurrentYear)); // December 31
        end;

        // Count how many biannual dates fall between StartDate and EndDate
        foreach CurrentDate in BiannualDates do begin
            if (CurrentDate > StartDate) and (CurrentDate < EndDate) then
                PeriodCount += 1;
        end;

        exit(PeriodCount);
    end;

    /// <summary>
    /// Counts how many complete or partial 6-month periods fit between two dates.
    /// </summary>
    /// <param name="StartDate">The starting date</param>
    /// <param name="EndDate">The ending date</param>
    /// <returns>Number of 6-month periods between dates</returns>
    procedure Count6MonthPeriods(StartDate: Date; EndDate: Date): Integer
    var
        CurrentDate: Date;
        PeriodsCounted: Integer;
    begin
        if (StartDate = 0D) or (EndDate = 0D) or (StartDate > EndDate) then
            exit(0);

        PeriodsCounted := 0;
        CurrentDate := StartDate;

        while CurrentDate <= EndDate do begin
            PeriodsCounted += 1;

            // Exit if adding another 6 months would exceed end date
            if CalcDate('<6M>', CurrentDate) > EndDate then
                break;

            CurrentDate := CalcDate('<6M>', CurrentDate);
        end;

        exit(PeriodsCounted);
    end;


    procedure BiannualPeriodsBetween(StartDate: Date; EndDate: Date): Integer
    var
        StartYear: Integer;
        StartMonth: Integer;
        EndYear: Integer;
        EndMonth: Integer;
        StartBiannual: Integer;
        EndBiannual: Integer;
        TotalBiannualPeriods: Integer;
    begin
        // Extract year and month from the start and end dates
        StartYear := DATE2DMY(StartDate, 3);
        StartMonth := DATE2DMY(StartDate, 2);
        EndYear := DATE2DMY(EndDate, 3);
        EndMonth := DATE2DMY(EndDate, 2);

        // Calculate the biannual period for the start and end dates
        StartBiannual := (StartMonth - 1) DIV 6 + 1;
        EndBiannual := (EndMonth - 1) DIV 6 + 1;

        // Calculate the total number of biannual periods
        TotalBiannualPeriods := (EndYear - StartYear) * 2 + (EndBiannual - StartBiannual);

        exit(TotalBiannualPeriods);
    end;

    /// <summary>
    /// Returns the next biannual end date (June 30 or December 31) for a given date.
    /// </summary>
    /// <param name="InputDate">Any date</param>
    /// <returns>The next June 30 or December 31 after the input date</returns>
    procedure GetBiannualEndDate(InputDate: Date): Date
    var
        Day, Month, Year : Integer;
        June30: Date;
        Dec31: Date;
    begin
        if InputDate = 0D then
            exit(0D); // Return blank date if input is blank

        Day := Date2DMY(InputDate, 1);
        Month := Date2DMY(InputDate, 2);
        Year := Date2DMY(InputDate, 3);

        June30 := DMY2Date(30, 6, Year);
        Dec31 := DMY2Date(31, 12, Year);

        if InputDate <= June30 then
            exit(June30)
        else if InputDate <= Dec31 then
            exit(Dec31)
        else
            exit(DMY2Date(30, 6, Year + 1)); // If after Dec 31, return next June 30
    end;

    /// <summary>
    /// Returns the number of days in the current biannual period (Jan-Jun or Jul-Dec) for the given date.
    /// </summary>
    /// <param name="InputDate">The date to evaluate</param>
    /// <returns>Number of days in the current biannual period</returns>
    procedure GetDaysInCurrentBiannual(InputDate: Date): Integer
    var
        Month: Integer;
        Year: Integer;
        IsLeapYear: Boolean;
        dd: Integer;
    begin
        if InputDate = 0D then
            exit(0);

        Month := Date2DMY(InputDate, 2);
        Year := Date2DMY(InputDate, 3);
        IsLeapYear := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));

        if Month <= 6 then begin
            // January - June period
            dd := 31 + 31 + 30 + 31 + 30;
            if IsLeapYear then dd := dd + 29 else dd := dd + 28;
            exit(dd)
        end
        else
            // July - December period
            exit(31 + 31 + 30 + 31 + 30 + 31);
    end;

    procedure GetClosestBiannualEndDate(PassedDate: Date): Date
    var
        Month: Integer;
        Year: Integer;
        ClosestEndOfBiannual: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date
        Year := DATE2DMY(PassedDate, 3);  // Extract the year from the passed date

        if Month <= 6 then begin
            if PassedDate > DMY2Date(31, 3, Year) then
                ClosestEndOfBiannual := DMY2Date(30, 6, Year) // June 30
            else
                ClosestEndOfBiannual := DMY2Date(31, 12, Year - 1); // December 31 of previous year
        end else begin
            if PassedDate > DMY2Date(30, 9, Year) then
                ClosestEndOfBiannual := DMY2Date(31, 12, Year) // December 31
            else
                ClosestEndOfBiannual := DMY2Date(30, 6, Year); // June 30
        end;

        exit(ClosestEndOfBiannual);
    end;

    procedure GetEndOfBiannual(PassedDate: Date): Date
    var
        Month: Integer;
        Year: Integer;
        EndOfBiannual: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date
        Year := DATE2DMY(PassedDate, 3);  // Extract the year from the passed date

        if Month <= 6 then
            EndOfBiannual := DMY2Date(30, 6, Year)  // June 30 of the same year
        else
            EndOfBiannual := DMY2Date(31, 12, Year); // December 31 of the same year

        exit(EndOfBiannual);
    end;

    procedure GetStartOfBiannual(PassedDate: Date): Date
    var
        Month: Integer;
        Year: Integer;
        StartOfBiannual: Date;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date
        Year := DATE2DMY(PassedDate, 3);  // Extract the year from the passed date

        if Month <= 6 then
            StartOfBiannual := DMY2Date(1, 1, Year)  // January 1 of the same year
        else
            StartOfBiannual := DMY2Date(1, 7, Year); // July 1 of the same year

        exit(StartOfBiannual);
    end;

    procedure GetDaysInBiannual(Biannual: Integer; Year: Integer): Integer
    var
        StartOfBiannual: Date;
        EndOfBiannual: Date;
        NumDays: Integer;
    begin
        case Biannual of
            1:
                begin
                    StartOfBiannual := DMY2Date(1, 1, Year);   // January 1
                    EndOfBiannual := DMY2Date(30, 6, Year);   // June 30
                end;
            2:
                begin
                    StartOfBiannual := DMY2Date(1, 7, Year);   // July 1
                    EndOfBiannual := DMY2Date(31, 12, Year);  // December 31
                end;
            else
                Error('Invalid biannual value. Please enter 1 or 2.');
        end;

        // Calculate the number of days
        NumDays := EndOfBiannual - StartOfBiannual + 1;

        exit(NumDays);
    end;

    /// <summary>
    /// Counts how many December 31 year-end dates occur between two dates.
    /// </summary>
    /// <param name="StartDate">The starting date</param>
    /// <param name="EndDate">The ending date</param>
    /// <returns>Number of December 31 dates crossed</returns>
    procedure CountAnnualPeriodsCrossed(StartDate: Date; EndDate: Date): Integer
    var
        CurrentYear, EndYear : Integer;
        YearEndDate: Date;
        PeriodCount: Integer;
    begin
        if (StartDate = 0D) or (EndDate = 0D) or (StartDate > EndDate) then
            exit(0);

        PeriodCount := 0;
        CurrentYear := Date2DMY(StartDate, 3);
        EndYear := Date2DMY(EndDate, 3);

        // Check each year in the range
        for CurrentYear := CurrentYear to EndYear do begin
            YearEndDate := DMY2Date(31, 12, CurrentYear);

            // Count if December 31 is between StartDate and EndDate (**inclusive of EndDate if it's Dec 31)
            if (YearEndDate > StartDate) and (YearEndDate < EndDate) then
                PeriodCount += 1;
        end;

        exit(PeriodCount);
    end;

    /// <summary>
    /// Simplified version that counts each calendar year touched by the date range
    /// </summary>
    procedure CountAnnualPeriodsSimple(StartDate: Date; EndDate: Date): Integer
    begin
        if (StartDate = 0D) or (EndDate = 0D) or (StartDate > EndDate) then
            exit(0);

        exit(Date2DMY(EndDate, 3) - Date2DMY(StartDate, 3) + 0);
    end;

    /// <summary>
    /// Counts how many full 12-month periods fit between StartDate and EndDate without exceeding EndDate.
    /// </summary>
    /// <param name="StartDate">Initial date</param>
    /// <param name="EndDate">Cutoff date</param>
    /// <returns>Number of complete 12-month periods</returns>
    procedure CountExact12MonthPeriods(StartDate: Date; EndDate: Date): Integer
    var
        CurrentDate: Date;
        PeriodCount: Integer;
        NextDate: Date;
    begin
        if (StartDate = 0D) or (EndDate = 0D) or (StartDate > EndDate) then
            exit(0);

        PeriodCount := 0;
        CurrentDate := StartDate;

        while true do begin
            NextDate := CalcDate('<12M>', CurrentDate); // Add 12 months

            // Stop if the next period exceeds EndDate
            if NextDate > EndDate then
                exit(PeriodCount);

            PeriodCount += 1;
            CurrentDate := NextDate;
        end;
    end;

    procedure AnnualPeriodsBetween(StartDate: Date; EndDate: Date): Integer
    var
        StartYear: Integer;
        EndYear: Integer;
        TotalAnnualPeriods: Integer;
    begin
        // Extract the year from the start and end dates
        StartYear := DATE2DMY(StartDate, 3);
        EndYear := DATE2DMY(EndDate, 3);

        // Calculate the total number of annual periods
        TotalAnnualPeriods := EndYear - StartYear;

        // Adjust if the end date is before the start date in the year
        if DATE2DMY(EndDate, 2) < DATE2DMY(StartDate, 2) then
            TotalAnnualPeriods := TotalAnnualPeriods - 1;

        exit(TotalAnnualPeriods);
    end;

    /// <summary>
    /// Returns the December 31 year-end date for a given date.
    /// </summary>
    /// <param name="InputDate">Any date</param>
    /// <returns>December 31 of the input date's year</returns>
    procedure GetAnnualEndDate(InputDate: Date): Date
    var
        Year: Integer;
    begin
        if InputDate = 0D then
            exit(0D); // Return blank date if input is blank

        Year := Date2DMY(InputDate, 3); // Extract year
        exit(DMY2Date(31, 12, Year));   // Return Dec 31 of that year
    end;

    procedure GetClosestAnnualEndDate(PassedDate: Date): Date
    var
        Year: Integer;
        ClosestEndOfAnnual: Date;
    begin
        Year := DATE2DMY(PassedDate, 3);  // Extract the year from the passed date

        // Check if the passed date is in the first half or second half of the year
        if PassedDate <= DMY2Date(30, 6, Year) then
            ClosestEndOfAnnual := DMY2Date(31, 12, Year - 1) // December 31 of the previous year
        else
            ClosestEndOfAnnual := DMY2Date(31, 12, Year);    // December 31 of the same year

        exit(ClosestEndOfAnnual);
    end;

    procedure GetEndOfYear(PassedDate: Date): Date
    var
        Year: Integer;
        EndOfYear: Date;
    begin
        Year := DATE2DMY(PassedDate, 3);  // Extract the year from the passed date
        EndOfYear := DMY2Date(31, 12, Year); // December 31 of the same year

        exit(EndOfYear);
    end;

    procedure GetStartOfYear(PassedDate: Date): Date
    var
        Year: Integer;
        StartOfYear: Date;
    begin
        Year := DATE2DMY(PassedDate, 3);   // Extract the year from the passed date
        StartOfYear := DMY2Date(1, 1, Year); // January 1 of the same year

        exit(StartOfYear);
    end;

    procedure GetDaysInYear(Year: Integer): Integer
    var
        StartDate: Date;
        EndDate: Date;
        NumDays: Integer;
    begin
        StartDate := DMY2Date(1, 1, Year);   // January 1 of the given year
        EndDate := DMY2Date(31, 12, Year);   // December 31 of the given year

        // Calculate the number of days
        NumDays := EndDate - StartDate + 1;

        exit(NumDays);
    end;

    var
        FunderNo: Code[20];
        FunderLoanTbl: Record "Funder Loan";
        ReportFlag: Record "Report Flags";
        FirstDueAccumulator: Record "Intr- Amort Partial";
        TrsyMgt: Codeunit "Treasury Mgt CU";
        Funder: Record Funders;
        MaturityValue: Decimal;
        ContactPerson: Text[250];
        Telephone: Text[250];

        DateDiff: Integer;

}