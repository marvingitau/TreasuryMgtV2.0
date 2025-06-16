report 50231 "Payment Amortization"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("Funder Loan"; "Funder Loan")
        {
        }
        dataitem(Loan; "Intr- Amort")
        {
            // RequestFilterFields = "No.";
            column(DueDate; DueDate)
            {

            }
            column(Interest; Interest)
            {

            }
            column(CalculationDate; CalculationDate)
            {

            }
            column(Amortization; Amortization)
            {

            }
            column(InterestRate; InterestRate)
            {

            }
            column(TotalPayment; TotalPayment)
            {

            }
            column(OutStandingAmt; OutStandingAmt)
            {

            }
            column(NumberofDays; NumberofDays) { }

        }
    }

    // requestpage
    // {
    //     // AboutTitle = 'Teaching tip title';
    //     // AboutText = 'Teaching tip content';
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(GroupName)
    //             {
    //                 field(No; FunderNo)
    //                 {
    //                     TableRelation = "Funder Loan"."No.";
    //                     ApplicationArea = All;

    //                 }
    //             }
    //         }
    //     }

    //     actions
    //     {
    //         area(processing)
    //         {
    //             action(LayoutName)
    //             {

    //             }
    //         }
    //     }
    // }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = './reports/PaymentAmortization.rdlc';
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

        _dueDateInfluence: Boolean; //This indicates if calculation will follow due date as the starting and subsequent period date will be seeded by it.
        _dailyPrincipal: Decimal;
    begin

        FunderNo := "Funder Loan".GetFilter("No.");

        FunderLoanTbl.Reset();
        FunderLoanTbl.SetRange("No.", FunderNo);
        if not FunderLoanTbl.Find('-') then
            Error('Funder Loan not %1 found', FunderNo);
        _fNo := FunderLoanTbl."No.";

        dueDate := FunderLoanTbl.SecondDueDate;

        placementDate := FunderLoanTbl.PlacementDate;
        maturityDate := FunderLoanTbl.MaturityDate;
        dateDiff := (maturityDate - placementDate);
        endYearDate := CALCDATE('CY', Today);
        remainingDays := endYearDate - FunderLoanTbl.PlacementDate;

        _dueDateInfluence := FunderLoanTbl.EnableWeekDayReporting;
        // _dueDateInfluence := true;
        _principle := 0;
        _amortization := 0;
        _totalPayment := 0;
        _outstandingAmount := 0;
        _interestRate_Active := 0;
        // _interestRate_Active := TrsyMgt.GetInterestRate(FunderLoanTbl."No.", 'FUNDER_REPORT');
        /* 
        if (FunderLoanTbl.InterestRateType = FunderLoanTbl.InterestRateType::"Fixed Rate") then
            _interestRate_Active := FunderLoanTbl.InterestRate;
        if (FunderLoanTbl.InterestRateType = FunderLoanTbl.InterestRateType::"Floating Rate") then
            _interestRate_Active := (FunderLoanTbl."Reference Rate" + FunderLoanTbl.Margin);
        // if _interestRate_Active = 0 then
        //     Error('Interest Rate is Zero');
        */

        _withHoldingTax_Percent := FunderLoanTbl.Withldtax;
        _withHoldingTax_Amnt := 0;

        FunderLoanTbl.CalcFields(OutstandingAmntDisbLCY);
        _principle := FunderLoanTbl.OutstandingAmntDisbLCY;
        if (_principle = 0) then begin
            _principle := FunderLoanTbl."Original Disbursed Amount";
        end;



        // // StartDate := DMY2Date(1, 1, DATE2DMY(TODAY, 3)); // January 1 of the current year
        // // EndDate := DMY2Date(31, 12, DATE2DMY(TODAY, 3)); // December 31 of the current year
        // // // Calculate the number of days
        // // YearNumDays := EndDate - StartDate + 1;
        // FirstMonthDays := CalcDate('<CM>', placementDate) - placementDate;

        Loan.Reset();
        Loan.DeleteAll();
        FirstDueAccumulator.Reset();
        FirstDueAccumulator.DeleteAll();

        if FunderLoanTbl.PeriodicPaymentOfPrincipal = FunderLoanTbl.PeriodicPaymentOfPrincipal::Monthly then begin

            //No of days in that month
            NoOfMonths := MonthsBetween(placementDate, maturityDate);
            for monthCounter := 0 to NoOfMonths do begin
                _currentMonthInLoop := 0D;
                if (monthCounter = 0) then begin
                    _currentMonthInLoop := CalcDate('<CM>', placementDate);
                end
                else if (monthCounter = NoOfMonths) then begin
                    _currentMonthInLoop := CalcDate('<CM>', maturityDate);
                end
                else begin
                    _currentMonthInLoop := CalcDate('<CM>', CalcDate('<' + Format(monthCounter) + 'M>', placementDate));
                    _outstandingAmount := _principle;
                end;

                DaysInMonth := DATE2DMY(_currentMonthInLoop, 1);
                if (monthCounter = 0) then begin
                    //Start Date
                    DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 0; //Remaining to End month
                    _outstandingAmount := _principle;
                end;
                if (monthCounter = NoOfMonths) then begin
                    //End Date
                    DaysInMonth := maturityDate - CalcDate('<-CM>', maturityDate) + 1;
                    _amortization := _principle;
                    _outstandingAmount := 0;
                    _totalPayment := _principle;
                end;

                _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentMonthInLoop, 'FUNDER_REPORT');


                if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 360);
                end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 364);
                end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 365);
                end;

                // Loan.Init();
                // Loan.DueDate := _currentMonthInLoop;
                // Loan.Interest := monthlyInterest;
                // Loan.CalculationDate := _currentMonthInLoop;
                // Loan.LoanNo := _fNo;
                // Loan.LoopCount := monthCounter;
                // Loan.Amortization := _amortization;
                // Loan.InterestRate := _interestRate_Active;
                // Loan.TotalPayment := _totalPayment + monthlyInterest;
                // Loan.OutStandingAmt := _outstandingAmount;
                // Loan.NumberofDays := DaysInMonth;
                // Loan.Insert();

                if (dueDate <> 0D) and (dueDate > _currentMonthInLoop) then begin
                    //FirstDueAccumulator.Init();

                    _secondStep := true;
                    FirstDueAccumulator.Line := monthCounter + 1;
                    FirstDueAccumulator.DueDate := _currentMonthInLoop;
                    FirstDueAccumulator.Interest := monthlyInterest;
                    FirstDueAccumulator.CalculationDate := _currentMonthInLoop;
                    FirstDueAccumulator.LoanNo := _fNo;
                    FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                    FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                    FirstDueAccumulator.LoopCount := monthCounter + 1;
                    FirstDueAccumulator.Amortization := _amortization;
                    FirstDueAccumulator.InterestRate := _interestRate_Active;
                    FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                    FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                    FirstDueAccumulator.NumberofDays := DaysInMonth;
                    FirstDueAccumulator.Insert();
                end else begin
                    FirstDueAccumulator.Reset();
                    FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                    FirstDueAccumulator.SetRange(Reviewed, false);
                    FirstDueAccumulator.CalcSums(Interest);
                    FirstDueAccumulator.CalcSums(NetInterest);
                    FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                    FirstDueAccumulator.CalcSums(TotalPayment);
                    FirstDueAccumulator.CalcSums(OutStandingAmt);

                    if FirstDueAccumulator.Count > 0 then begin
                        _sumInterest := FirstDueAccumulator.Interest;
                        _sumNetInterest := FirstDueAccumulator.NetInterest;
                        _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                        _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                        _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                        FirstDueAccumulator.Reviewed := true;
                        FirstDueAccumulator.Modify();
                    end else begin
                        _sumInterest := 0;
                        _sumNetInterest := 0;
                        _sumWtholding := 0;
                        _sumTotalPayment := 0;
                        _sumOutstanding := 0;
                    end;
                    if (dueDate <> 0D) then begin
                        _dueDateNoOfMonths := MonthsBetween(dueDate, maturityDate);
                        if _outstandingAmount <> 0 then
                            _dueDateAmortizedValue := _outstandingAmount / _dueDateNoOfMonths
                        else
                            _dueDateAmortizedValue := _principle / _dueDateNoOfMonths;
                    end;

                    Loan.Init();
                    Loan.Interest := monthlyInterest + _sumInterest;
                    Loan.LoanNo := _fNo;
                    Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                    Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                    Loan.LoopCount := monthCounter;
                    if _dueDateAmortizedValue <> 0 then
                        Loan.Amortization := _dueDateAmortizedValue
                    else
                        Loan.Amortization := _amortization;
                    Loan.InterestRate := _interestRate_Active;

                    if _dueDateAmortizedValue <> 0 then
                        Loan.TotalPayment := ((_totalPayment + monthlyInterest) + _sumTotalPayment) + _dueDateAmortizedValue
                    else
                        Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                    Loan.OutStandingAmt := _outstandingAmount;

                    if _secondStep = true then begin
                        Loan.NumberofDays := dueDate - FunderLoanTbl.PlacementDate;
                        Loan.DueDate := dueDate;
                        Loan.CalculationDate := dueDate;
                        _secondStep := false;
                    end else begin
                        Loan.NumberofDays := DaysInMonth;
                        Loan.DueDate := _currentMonthInLoop;
                        Loan.CalculationDate := _currentMonthInLoop;
                    end;
                    Loan.Insert();

                    FirstDueAccumulator.Reset();
                    if FirstDueAccumulator.Count > 0 then
                        FirstDueAccumulator.DeleteAll();
                end;


                // monthCounter := monthCounter + 1;
            end;
        end;
        // DateRange := CalcDate('<1M>', StartDate);
        if FunderLoanTbl.PeriodicPaymentOfPrincipal = FunderLoanTbl.PeriodicPaymentOfPrincipal::Quarterly then begin
            if _dueDateInfluence then begin
                //12
                //No of days in that month
                NoOfQuarter := QuartersBetween(dueDate, maturityDate) + 1; // No of Quarters
                StatingQuarterEndDate := placementDate;                                                       // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                _dailyPrincipal := _principle / NoOfQuarter;

                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    if QuarterCounter = 0 then begin
                        _currentQuarterInLoop := AdjustWeekendDate(GetEndOfQuarter(placementDate));

                        DaysInQuarter := dueDate - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if QuarterCounter = 1 then begin
                        _currentQuarterInLoop := AdjustWeekendDate(GetEndOfQuarter(placementDate));

                        DaysInQuarter := _currentQuarterInLoop - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if QuarterCounter = NoOfQuarter then begin
                        // _currentQuarterInLoop := GetstartOfQuarter(maturityDate);
                        _currentQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));
                        _previousQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 2) * 3) + 'M>', dueDate));

                        DaysInQuarter := maturityDate - _previousQuarterInLoop;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentQuarterInLoop := maturityDate;
                        // _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                    end
                    else begin
                        // _currentQuarterInLoop := CALCDATE('<+' + Format(QuarterCounter) + 'Q>', StatingQuarterEndDate);
                        _currentQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));
                        _previousQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 2) * 3) + 'M>', dueDate));

                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop;

                        _outstandingAmount := _principle - (_dailyPrincipal * QuarterCounter);

                    end;
                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter
                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentQuarterInLoop, 'FUNDER_REPORT');

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end;

                    if (dueDate <> 0D) and (QuarterCounter = 0) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := QuarterCounter + 1;
                        FirstDueAccumulator.DueDate := _currentQuarterInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentQuarterInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := QuarterCounter + 1;
                        FirstDueAccumulator.Amortization := _amortization;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInQuarter;
                        FirstDueAccumulator.Insert();
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                        end;


                        Loan.Init();
                        // Loan.DueDate := _currentQuarterInLoop;
                        Loan.Interest := monthlyInterest + _sumInterest;
                        // Loan.CalculationDate := _currentQuarterInLoop;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := QuarterCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                        Loan.OutStandingAmt := _outstandingAmount;
                        // Loan.NumberofDays := DaysInQuarter;
                        if _secondStep = true then begin
                            StatingQuarterEndDate := dueDate;
                            Loan.NumberofDays := dueDate - FunderLoanTbl.PlacementDate;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInQuarter;
                            Loan.DueDate := _currentQuarterInLoop;
                            Loan.CalculationDate := _currentQuarterInLoop;
                        end;

                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end
            else begin
                //12
                //No of days in that month
                NoOfQuarter := QuartersBetween(placementDate, maturityDate) + 1; // No of Quarters
                                                                                 // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                StatingQuarterEndDate := GetEndOfQuarter(placementDate);
                _dailyPrincipal := _principle / NoOfQuarter;

                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    // if QuarterCounter = 0 then begin
                    //     _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                    //     DaysInQuarter := _currentQuarterInLoop - placementDate + 0;
                    //     _outstandingAmount := _principle - _dailyPrincipal;
                    // end
                    if QuarterCounter = 1 then begin
                        _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                        DaysInQuarter := _currentQuarterInLoop - placementDate + 1;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if QuarterCounter = NoOfQuarter then begin
                        _currentQuarterInLoop := GetstartOfQuarter(maturityDate);
                        DaysInQuarter := maturityDate - _currentQuarterInLoop + 1;
                        _amortization := _principle;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentQuarterInLoop := maturityDate;
                        // _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                    end
                    else begin
                        // _currentQuarterInLoop := CALCDATE('<+' + Format(QuarterCounter) + 'Q>', StatingQuarterEndDate);
                        _currentQuarterInLoop := AddQuartersToQuarterEnd(QuarterCounter, StatingQuarterEndDate);

                        // QuarterCounterRem := QuarterCounter mod 4;
                        QuarterCounterRem := GetQuarter(_currentQuarterInLoop);
                        // if QuarterCounterRem = 4 then
                        //     DaysInQuarter := GetDaysInQuarter(_currentQuarterInLoop) - 1
                        // else
                        DaysInQuarter := GetDaysInQuarter(_currentQuarterInLoop);

                        // if QuarterCounterRem = 0 then
                        //     QuarterCounterRem := 4;
                        // DaysInQuarter := GetDaysInQuarter(QuarterCounterRem, DATE2DMY(_currentQuarterInLoop, 3));
                        _outstandingAmount := _principle - (_dailyPrincipal * QuarterCounter);
                    end;
                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter
                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentQuarterInLoop, 'FUNDER_REPORT');

                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end;

                    // Loan.Init();
                    // Loan.DueDate := _currentQuarterInLoop;
                    // Loan.Interest := monthlyInterest;
                    // Loan.CalculationDate := _currentQuarterInLoop;
                    // Loan.LoanNo := _fNo;
                    // Loan.LoopCount := QuarterCounter;
                    // Loan.Amortization := _amortization;
                    // Loan.InterestRate := _interestRate_Active;
                    // Loan.TotalPayment := _totalPayment + monthlyInterest;
                    // Loan.OutStandingAmt := _outstandingAmount;
                    // Loan.Insert();

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
                        FirstDueAccumulator.LoopCount := QuarterCounter + 1;
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInQuarter;
                        FirstDueAccumulator.Insert();
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                            _sumAmortization := 0;
                            _sumNumberOfDays := 0;
                        end;


                        Loan.Init();
                        // Loan.DueDate := _currentQuarterInLoop;
                        Loan.Interest := monthlyInterest + _sumInterest;
                        // Loan.CalculationDate := _currentQuarterInLoop;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := QuarterCounter;
                        Loan.Amortization := _dailyPrincipal + _sumAmortization;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                        Loan.OutStandingAmt := _outstandingAmount;
                        // Loan.NumberofDays := DaysInQuarter;
                        if _secondStep = true then begin
                            Loan.NumberofDays := DaysInQuarter + _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInQuarter;
                            Loan.DueDate := _currentQuarterInLoop;
                            Loan.CalculationDate := _currentQuarterInLoop;
                        end;

                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;
        end;

        if FunderLoanTbl.PeriodicPaymentOfPrincipal = FunderLoanTbl.PeriodicPaymentOfPrincipal::Biannually then begin
            //12
            //No of days in that month
            if _dueDateInfluence then begin
                NoOfBiann := BiannualPeriodsBetweenDueDateEffect(dueDate, maturityDate) + 1; // Due Date Influenced.
                StatingBiannEndDate := placementDate;
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                _dailyPrincipal := _principle / NoOfBiann;

                for BiannCounter := 0 to NoOfBiann do begin
                    _currentBiannInLoop := 0D;
                    DaysInBiann := 0;

                    // Due Date influence Calender Period.

                    if BiannCounter = 0 then begin // Placement to Due date
                        _currentBiannInLoop := AdjustWeekendDate(GetEndOfBiannual(placementDate));

                        DaysInBiann := dueDate - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if BiannCounter = 1 then begin // Due date
                        _currentBiannInLoop := AdjustWeekendDate(GetEndOfBiannual(placementDate));
                        // _currentBiannInLoop := dueDate;
                        DaysInBiann := _currentBiannInLoop - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if BiannCounter = NoOfBiann then begin
                        // _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                        _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        _previousBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 2) * 6) + 'M>', dueDate));

                        DaysInBiann := maturityDate - _previousBiannInLoop;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentBiannInLoop := maturityDate;
                        // _currentBiannInLoop := GetEndOfBiannual(maturityDate);

                    end
                    else begin
                        _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        _previousBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 2) * 6) + 'M>', dueDate));

                        DaysInBiann := _currentBiannInLoop - _previousBiannInLoop;
                        _outstandingAmount := _principle - (_dailyPrincipal * BiannCounter);
                    end;

                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentBiannInLoop, 'FUNDER_REPORT');


                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end;

                    if (dueDate <> 0D) and (BiannCounter = 0) then begin

                        _secondStep := true;
                        FirstDueAccumulator.Line := BiannCounter + 1;
                        FirstDueAccumulator.DueDate := _currentBiannInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentBiannInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := BiannCounter + 1;
                        FirstDueAccumulator.Amortization := _amortization;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInBiann;
                        FirstDueAccumulator.Insert();
                    end else begin


                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                        end;


                        Loan.Init();
                        // Loan.DueDate := _currentQuarterInLoop;
                        Loan.Interest := monthlyInterest + _sumInterest;
                        // Loan.CalculationDate := _currentQuarterInLoop;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := BiannCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                        Loan.OutStandingAmt := _outstandingAmount;
                        // Loan.NumberofDays := DaysInQuarter;
                        if _secondStep = true then begin
                            StatingBiannEndDate := dueDate;// Set startgin point is due date after grace period
                            Loan.NumberofDays := dueDate - FunderLoanTbl.PlacementDate;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInBiann;
                            Loan.DueDate := _currentBiannInLoop;
                            Loan.CalculationDate := _currentBiannInLoop;
                        end;

                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;
            end else begin
                NoOfBiann := BiannualPeriodsBetween(placementDate, maturityDate) + 1; // No of Bianuals
                // NoOfBiann := BiannualPeriodsBetween(dueDate, maturityDate) + 1; // No of Bianuals
                StatingBiannEndDate := GetClosestBiannualEndDate(placementDate);
                // StatingBiannEndDate := placementDate;
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                _dailyPrincipal := _principle / NoOfBiann;

                for BiannCounter := 1 to NoOfBiann do begin
                    _currentBiannInLoop := 0D;
                    DaysInBiann := 0;
                    // Normal Std Calender Period

                    // if BiannCounter = 0 then begin
                    //     _currentBiannInLoop := GetStartOfBiannual(placementDate);
                    //     DaysInBiann := _currentBiannInLoop - placementDate;
                    //     _outstandingAmount := _principle;
                    // end else
                    if BiannCounter = 1 then begin
                        _currentBiannInLoop := GetEndOfBiannual(placementDate);
                        DaysInBiann := _currentBiannInLoop - placementDate + 0;
                        // _outstandingAmount := _principle;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if BiannCounter = NoOfBiann then begin
                        _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                        DaysInBiann := maturityDate - _currentBiannInLoop + 1;
                        _amortization := _principle;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentBiannInLoop := maturityDate;
                        // _currentBiannInLoop := GetEndOfBiannual(maturityDate);
                    end
                    else begin
                        if (dueDate <> 0D) then begin
                            _currentBiannInLoop := CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', StatingBiannEndDate);
                            BiannCounterRem := (BiannCounter) mod 2;
                        end
                        else begin
                            _currentBiannInLoop := CALCDATE('<+' + Format(BiannCounter * 6) + 'M>', StatingBiannEndDate);
                            BiannCounterRem := BiannCounter mod 2;
                        end;
                        if BiannCounterRem = 0 then
                            BiannCounterRem := 2;
                        if BiannCounterRem = 2 then
                            DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3))
                        else
                            DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3));
                        _outstandingAmount := _principle - (_dailyPrincipal * BiannCounter);
                    end;

                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentBiannInLoop, 'FUNDER_REPORT');


                    if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end;




                    if (dueDate <> 0D) and (dueDate > _currentBiannInLoop) then begin
                        //FirstDueAccumulator.Init();
                        _secondStep := true;
                        FirstDueAccumulator.Line := BiannCounter + 1;
                        FirstDueAccumulator.DueDate := _currentBiannInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentBiannInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := BiannCounter + 1;
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInBiann;
                        FirstDueAccumulator.Insert();
                    end else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                            _sumAmortization := 0;
                            _sumNumberOfDays := 0;
                        end;


                        Loan.Init();
                        // Loan.DueDate := _currentQuarterInLoop;
                        Loan.Interest := monthlyInterest + _sumInterest;
                        // Loan.CalculationDate := _currentQuarterInLoop;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := BiannCounter;
                        Loan.Amortization := _dailyPrincipal + _sumAmortization;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                        Loan.OutStandingAmt := _outstandingAmount;
                        // Loan.NumberofDays := DaysInQuarter;
                        if _secondStep = true then begin
                            Loan.NumberofDays := DaysInBiann + _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            _secondStep := false;
                        end else begin
                            Loan.NumberofDays := DaysInBiann;
                            Loan.DueDate := _currentBiannInLoop;
                            Loan.CalculationDate := _currentBiannInLoop;
                        end;

                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;


                end;
            end;




        end;

        if FunderLoanTbl.PeriodicPaymentOfPrincipal = FunderLoanTbl.PeriodicPaymentOfPrincipal::Annually then begin
            //12
            //No of days in that month
            NoOfAnnual := AnnualPeriodsBetween(placementDate, maturityDate) + 1; // No of Quarters
            StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
            for AnnualCounter := 1 to NoOfAnnual do begin
                _currentAnnualInLoop := 0D;
                DaysInAnnual := 0;
                // if AnnualCounter = 0 then begin
                //     _currentAnnualInLoop := GetStartOfYear(placementDate);
                //     DaysInAnnual := _currentAnnualInLoop - placementDate + 1;
                //     _outstandingAmount := _principle;
                // end
                // else
                if AnnualCounter = 1 then begin
                    _currentAnnualInLoop := GetEndOfYear(placementDate);
                    DaysInAnnual := _currentAnnualInLoop - placementDate;
                    _outstandingAmount := _principle;
                end
                else if AnnualCounter = NoOfAnnual then begin
                    _currentAnnualInLoop := GetStartOfYear(maturityDate);
                    DaysInAnnual := maturityDate - _currentAnnualInLoop + 1;
                    _amortization := _principle;
                    _outstandingAmount := 0;
                    _totalPayment := _principle;
                    // _currentAnnualInLoop := maturityDate;
                    _currentAnnualInLoop := GetEndOfYear(maturityDate);

                end
                else begin
                    _currentAnnualInLoop := CALCDATE('<+' + Format(AnnualCounter) + 'Y>', StatingAnnualEndDate);
                    DaysInAnnual := GetDaysInYear(DATE2DMY(_currentAnnualInLoop, 3))
                end;
                //Get quarter date. - sub the current date for days.
                //Add to the next quarter
                _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentAnnualInLoop, 'FUNDER_REPORT');


                if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 360);
                end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 364);
                end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                    monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 365);
                end;

                // Loan.Init();
                // Loan.DueDate := _currentAnnualInLoop;
                // Loan.Interest := monthlyInterest;
                // Loan.CalculationDate := _currentAnnualInLoop;
                // Loan.LoanNo := _fNo;
                // Loan.LoopCount := AnnualCounter;
                // Loan.Amortization := _amortization;
                // Loan.InterestRate := _interestRate_Active;
                // Loan.TotalPayment := _totalPayment + monthlyInterest;
                // Loan.OutStandingAmt := _outstandingAmount;
                // Loan.NumberofDays := DaysInAnnual;
                // Loan.Insert();

                if (dueDate <> 0D) and (dueDate > _currentAnnualInLoop) then begin
                    //FirstDueAccumulator.Init();
                    _secondStep := true;
                    FirstDueAccumulator.Line := AnnualCounter + 1;
                    FirstDueAccumulator.DueDate := _currentAnnualInLoop;
                    FirstDueAccumulator.Interest := monthlyInterest;
                    FirstDueAccumulator.CalculationDate := _currentAnnualInLoop;
                    FirstDueAccumulator.LoanNo := _fNo;
                    FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                    FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                    FirstDueAccumulator.LoopCount := AnnualCounter + 1;
                    FirstDueAccumulator.Amortization := _amortization;
                    FirstDueAccumulator.InterestRate := _interestRate_Active;
                    FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                    FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                    FirstDueAccumulator.NumberofDays := DaysInAnnual;
                    FirstDueAccumulator.Insert();
                end else begin
                    FirstDueAccumulator.Reset();
                    FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                    FirstDueAccumulator.SetRange(Reviewed, false);
                    FirstDueAccumulator.CalcSums(Interest);
                    FirstDueAccumulator.CalcSums(NetInterest);
                    FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                    FirstDueAccumulator.CalcSums(TotalPayment);
                    FirstDueAccumulator.CalcSums(OutStandingAmt);

                    if FirstDueAccumulator.Count > 0 then begin
                        _sumInterest := FirstDueAccumulator.Interest;
                        _sumNetInterest := FirstDueAccumulator.NetInterest;
                        _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                        _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                        _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                        FirstDueAccumulator.Reviewed := true;
                        FirstDueAccumulator.Modify();
                    end else begin
                        _sumInterest := 0;
                        _sumNetInterest := 0;
                        _sumWtholding := 0;
                        _sumTotalPayment := 0;
                        _sumOutstanding := 0;
                    end;


                    Loan.Init();
                    // Loan.DueDate := _currentQuarterInLoop;
                    Loan.Interest := monthlyInterest + _sumInterest;
                    // Loan.CalculationDate := _currentQuarterInLoop;
                    Loan.LoanNo := _fNo;
                    Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                    Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                    Loan.LoopCount := AnnualCounter;
                    Loan.Amortization := _amortization;
                    Loan.InterestRate := _interestRate_Active;
                    Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                    Loan.OutStandingAmt := _outstandingAmount;
                    // Loan.NumberofDays := DaysInQuarter;
                    if _secondStep = true then begin
                        Loan.NumberofDays := dueDate - FunderLoanTbl.PlacementDate;
                        Loan.DueDate := dueDate;
                        Loan.CalculationDate := dueDate;
                        _secondStep := false;
                    end else begin
                        Loan.NumberofDays := DaysInAnnual;
                        Loan.DueDate := _currentAnnualInLoop;
                        Loan.CalculationDate := _currentAnnualInLoop;
                    end;

                    Loan.Insert();

                    FirstDueAccumulator.Reset();
                    if FirstDueAccumulator.Count > 0 then
                        FirstDueAccumulator.DeleteAll();
                end;

            end;
        end;

        if FunderLoanTbl.PeriodicPaymentOfPrincipal = FunderLoanTbl.PeriodicPaymentOfPrincipal::"Total at Due Date" then begin
            _outstandingAmount := _principle;
            _amortization := _principle;
            _totalPayment := _principle;
            _currentAnnualInLoop := maturityDate;

            _interestRate_Active := TrsyMgt.GetInterestRateSchedule(FunderLoanTbl."No.", _currentAnnualInLoop, 'FUNDER_REPORT');

            if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"30/360" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
            end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/360" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (dateDiff / 360);
            end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/364" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (dateDiff / 364);
            end else if FunderLoanTbl.InterestMethod = FunderLoanTbl.InterestMethod::"Actual/365" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (dateDiff / 365);
            end;

            Loan.Init();
            Loan.DueDate := _currentAnnualInLoop;
            Loan.Interest := monthlyInterest;
            Loan.CalculationDate := _currentAnnualInLoop;
            Loan.LoanNo := _fNo;
            Loan.LoopCount := AnnualCounter;
            Loan.Amortization := _amortization;
            Loan.InterestRate := _interestRate_Active;
            Loan.TotalPayment := _totalPayment + monthlyInterest;
            Loan.OutStandingAmt := _outstandingAmount;
            Loan.NumberofDays := dateDiff;
            Loan.Insert();


        end;




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

    procedure BiannualPeriodsBetweenDueDateEffect(StartDate: Date; EndDate: Date): Integer
    var
        StartYear: Integer;
        StartMonth: Integer;
        EndYear: Integer;
        EndMonth: Integer;
        StartBiannual: Integer;
        EndBiannual: Integer;
        TotalBiannualPeriods: Integer;
    begin
        // TotalBiannualPeriods := (EndDate - StartDate) DIV 182;
        // exit(TotalBiannualPeriods);
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
}