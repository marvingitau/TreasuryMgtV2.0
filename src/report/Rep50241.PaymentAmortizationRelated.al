report 50241 "Payment Amortization Related"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("RelatedParty Loan"; "RelatedParty Loan") { }
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
            column(NumberofDays; NumberofDays)
            {

            }

        }
    }

    // requestpage
    // {
    //     AboutTitle = 'Teaching tip title';
    //     AboutText = 'Teaching tip content';
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(GroupName)
    //             {
    //                 field(No; RelatedNo)
    //                 {
    //                     TableRelation = "RelatedParty- Cust"."No.";
    //                     ApplicationArea = All;

    //                 }
    //             }
    //         }
    //     }


    // }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = './reports/PaymentAmortizationR.rdlc';
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
        QuarterCounterRem: Integer;

        NoOfBiann: Integer;
        BiannCounter: Integer;
        _currentBiannInLoop: Date;
        _previousBiannInLoop: Date;
        DaysInBiann: Integer;
        StatingBiannEndDate: date;
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
        dueDate, StatingQuarterStartDate, StatingBiannStartDate : Date;

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
    begin

        RelatedNo := "RelatedParty Loan".GetFilter("No.");

        RelatedPartyTbl.Reset();
        RelatedPartyTbl.SetRange("No.", RelatedNo);
        if not RelatedPartyTbl.Find('-') then
            Error('Related Rec not %1 found', RelatedNo);
        _fNo := RelatedPartyTbl."No.";

        placementDate := RelatedPartyTbl.PlacementDate;
        maturityDate := RelatedPartyTbl.MaturityDate;
        dateDiff := (maturityDate - placementDate);
        endYearDate := CALCDATE('CY', Today);
        remainingDays := endYearDate - RelatedPartyTbl.PlacementDate;

        _principle := 0;
        _amortization := 0;
        _totalPayment := 0;
        _outstandingAmount := 0;
        _interestRate_Active := 0;

        _withHoldingTax_Percent := RelatedPartyTbl.Withldtax;
        _withHoldingTax_Amnt := 0;

        _dueDateInfluence := RelatedPartyTbl.EnableDynamicPeriod_Payment;
        _skipWeekendInfluence := RelatedPartyTbl.EnableWeekDayReporting_Payment;

        dueDate := RelatedPartyTbl.SecondDueDate;

        RelatedPartyTbl.CalcFields(OutstandingAmntDisbLCY);
        _principle := RelatedPartyTbl.OutstandingAmntDisbLCY;
        if (_principle = 0) then begin
            _principle := RelatedPartyTbl."Original Disbursed Amount";
        end;


        Loan.Reset();
        Loan.DeleteAll();
        FirstDueAccumulator.Reset();
        FirstDueAccumulator.DeleteAll();


        if RelatedPartyTbl.PeriodicPaymentOfPrincipal = RelatedPartyTbl.PeriodicPaymentOfPrincipal::Monthly then begin
            /*
            **
            **      ENSURE RIGHT SQEW IS TAKEN CARE IF
            */

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin
                //No of days in that month
                NoOfMonths := MonthsBetween(dueDate, maturityDate) + 0;
                if NoOfMonths = 0 then
                    NoOfMonths := 1; //ENSURE RIGHT SQEW IS TAKEN CARE 0Fs

                _dailyPrincipal := _principle / (NoOfMonths + 1);

                for monthCounter := 0 to NoOfMonths do begin
                    _currentMonthInLoop := 0D;
                    if (monthCounter = 0) and (monthCounter <> NoOfMonths) then begin
                        _currentMonthInLoop := dueDate;
                        DaysInMonth := dueDate - placementDate;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (monthCounter = 1) and (monthCounter <> NoOfMonths) then begin
                        _currentMonthInLoop := AdjustWeekendDate(CalcDate('<+1M>', dueDate));
                        _previousMonthInLoop := dueDate;
                        // DaysInMonth := _currentMonthInLoop - _previousMonthInLoop + 0;
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop;
                        _outstandingAmount := _principle - (_dailyPrincipal * 2);

                    end
                    else if (monthCounter = NoOfMonths) then begin
                        _currentMonthInLoop := maturityDate;
                        _previousMonthInLoop := AdjustWeekendDate(CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));
                        DaysInMonth := maturityDate - _previousMonthInLoop;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                    end
                    else begin
                        _currentMonthInLoop := AdjustWeekendDate(CalcDate('<+' + Format((monthCounter)) + 'M>', dueDate));
                        _previousMonthInLoop := AdjustWeekendDate(CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));

                        _outstandingAmount := _principle - (_dailyPrincipal * (monthCounter + 1));
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop;
                    end;


                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentMonthInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;


                    if (dueDate <> 0D) and (dueDate = _currentMonthInLoop) then begin
                        _secondStep := true;
                        FirstDueAccumulator.Line := monthCounter + 1;
                        FirstDueAccumulator.DueDate := _currentMonthInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentMonthInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := monthCounter + 1;
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInMonth;
                        FirstDueAccumulator.Insert();
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(Amortization);
                        FirstDueAccumulator.CalcSums(NumberofDays);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumNumberOfDays := 0;
                            _sumAmortization := 0;
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                        end;


                        if (monthCounter = 1) and (_sumNumberOfDays <> 0) then begin

                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _sumAmortization;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := monthCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.OutStandingAmt := _outstandingAmount;
                        Loan.NumberofDays := DaysInMonth;
                        Loan.DueDate := _currentMonthInLoop;
                        Loan.CalculationDate := _currentMonthInLoop;
                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;

            end;

            /*
            **
            **      ENSURE RIGHT SQEW IS TAKEN CARE IF
            */
            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin
                //No of days in that month
                NoOfMonths := MonthsBetween(dueDate, maturityDate) + 0;
                if NoOfMonths = 0 then
                    NoOfMonths := 1; //ENSURE RIGHT SQEW IS TAKEN CARE 0Fs

                _dailyPrincipal := _principle / (NoOfMonths + 1);

                for monthCounter := 0 to NoOfMonths do begin
                    _currentMonthInLoop := 0D;
                    if (monthCounter = 0) and (monthCounter <> NoOfMonths) then begin
                        _currentMonthInLoop := dueDate;
                        DaysInMonth := dueDate - placementDate;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (monthCounter = 1) and (monthCounter <> NoOfMonths) then begin
                        _currentMonthInLoop := (CalcDate('<+1M>', dueDate));
                        _previousMonthInLoop := dueDate;
                        // DaysInMonth := _currentMonthInLoop - _previousMonthInLoop + 0;
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop;
                        _outstandingAmount := _principle - (_dailyPrincipal * 2);

                    end
                    else if (monthCounter = NoOfMonths) then begin
                        _currentMonthInLoop := maturityDate;
                        _previousMonthInLoop := (CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));
                        DaysInMonth := maturityDate - _previousMonthInLoop;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                    end
                    else begin
                        _currentMonthInLoop := (CalcDate('<+' + Format((monthCounter)) + 'M>', dueDate));
                        _previousMonthInLoop := (CalcDate('<+' + Format((monthCounter - 1)) + 'M>', dueDate));

                        _outstandingAmount := _principle - (_dailyPrincipal * (monthCounter + 1));
                        DaysInMonth := _currentMonthInLoop - _previousMonthInLoop;
                    end;


                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentMonthInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;


                    if (dueDate <> 0D) and (dueDate = _currentMonthInLoop) then begin
                        _secondStep := true;
                        FirstDueAccumulator.Line := monthCounter + 1;
                        FirstDueAccumulator.DueDate := _currentMonthInLoop;
                        FirstDueAccumulator.Interest := monthlyInterest;
                        FirstDueAccumulator.CalculationDate := _currentMonthInLoop;
                        FirstDueAccumulator.LoanNo := _fNo;
                        FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                        FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                        FirstDueAccumulator.LoopCount := monthCounter + 1;
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInMonth;
                        FirstDueAccumulator.Insert();
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(Amortization);
                        FirstDueAccumulator.CalcSums(NumberofDays);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumNumberOfDays := 0;
                            _sumAmortization := 0;
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                        end;


                        if (monthCounter = 1) and (_sumNumberOfDays <> 0) then begin

                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _sumAmortization;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := monthCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.OutStandingAmt := _outstandingAmount;
                        Loan.NumberofDays := DaysInMonth;
                        Loan.DueDate := _currentMonthInLoop;
                        Loan.CalculationDate := _currentMonthInLoop;
                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;

            end;

            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin
                //No of days in that month
                NoOfMonths := MonthsBetween(placementDate, maturityDate);
                _dailyPrincipal := _principle / (NoOfMonths + 1);

                for monthCounter := 0 to NoOfMonths do begin
                    _currentMonthInLoop := 0D;
                    if (monthCounter = 0) then begin
                        _currentMonthInLoop := CalcDate('<CM>', placementDate);
                    end
                    else if (monthCounter = NoOfMonths) then begin
                        _currentMonthInLoop := CalcDate('<CM>', maturityDate);
                        // _currentMonthInLoop := maturityDate;
                    end
                    else begin
                        _currentMonthInLoop := CalcDate('<CM>', CalcDate('<' + Format(monthCounter) + 'M>', placementDate));
                        _outstandingAmount := _principle - (_dailyPrincipal * (monthCounter + 1));
                    end;

                    DaysInMonth := DATE2DMY(_currentMonthInLoop, 1);

                    if (monthCounter = 0) then begin
                        //Start Date
                        if CalcDate('<CM>', placementDate) <> placementDate then // Is placement End of Month, if not, on the diff add 1
                            DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 1
                        else
                            DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 0;

                        // DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 0; //Remaining to End month
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end;
                    if (monthCounter = NoOfMonths) then begin
                        //End Date
                        DaysInMonth := maturityDate - CalcDate('<-CM>', maturityDate);
                        _amortization := _principle;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentMonthInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInMonth / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;


                    if (dueDate <> 0D) and (dueDate > _currentMonthInLoop) and (dueDate <> _currentMonthInLoop) then begin
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
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
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
                        FirstDueAccumulator.CalcSums(Amortization);
                        FirstDueAccumulator.CalcSums(NumberofDays);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumNumberOfDays := 0;
                            _sumAmortization := 0;
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                        end;
                        // if (dueDate <> 0D) then begin
                        //     _dueDateNoOfMonths := MonthsBetween(dueDate, maturityDate);
                        //     if _outstandingAmount <> 0 then
                        //         _dueDateAmortizedValue := _outstandingAmount / _dueDateNoOfMonths
                        //     else
                        //         _dueDateAmortizedValue := _principle / _dueDateNoOfMonths;
                        // end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                        Loan.LoopCount := monthCounter;
                        // if _dueDateAmortizedValue <> 0 then
                        //     Loan.Amortization := _dueDateAmortizedValue
                        // else
                        Loan.Amortization := _dailyPrincipal + _sumAmortization;
                        Loan.InterestRate := _interestRate_Active;

                        if _dueDateAmortizedValue <> 0 then
                            Loan.TotalPayment := ((_totalPayment + monthlyInterest) + _sumTotalPayment) + _dueDateAmortizedValue
                        else
                            Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                        Loan.OutStandingAmt := _outstandingAmount;

                        if _secondStep = true then begin
                            // Loan.NumberofDays := dueDate - RelatedPartyTbl.PlacementDate;
                            // Loan.DueDate := dueDate;
                            // Loan.CalculationDate := dueDate;
                            Loan.NumberofDays := DaysInMonth + _sumNumberOfDays;
                            Loan.DueDate := _currentMonthInLoop;
                            Loan.CalculationDate := _currentMonthInLoop;
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
        end;

        if RelatedPartyTbl.PeriodicPaymentOfPrincipal = RelatedPartyTbl.PeriodicPaymentOfPrincipal::Quarterly then begin
            /*
            **
            **      ENSURE RIGHT SQEW IS TAKEN CARE IF
            */

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin

                NoOfQuarter := QuartersBetween(dueDate, maturityDate) + 0; // No of Quarters
                if NoOfQuarter = 0 then
                    NoOfQuarter := 1; //ENSURE RIGHT SQEW IS TAKEN CARE 0F

                StatingQuarterEndDate := placementDate;                                                       // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                _dailyPrincipal := _principle / (NoOfQuarter + 1);

                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    if (QuarterCounter = 0) and (QuarterCounter <> NoOfQuarter) then begin
                        _currentQuarterInLoop := dueDate;

                        DaysInQuarter := dueDate - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (QuarterCounter = 1) and (QuarterCounter <> NoOfQuarter) then begin
                        _currentQuarterInLoop := AdjustWeekendDate(CALCDATE('<+3M>', dueDate));
                        _previousQuarterInLoop := dueDate;

                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop + 0;
                        _outstandingAmount := _principle - (_dailyPrincipal * 2);
                    end
                    else if QuarterCounter = NoOfQuarter then begin
                        // _currentQuarterInLoop := GetstartOfQuarter(maturityDate);
                        _currentQuarterInLoop := maturityDate;
                        _previousQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));

                        DaysInQuarter := maturityDate - _previousQuarterInLoop + 0;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentQuarterInLoop := maturityDate;
                        // _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                    end
                    else begin
                        // _currentQuarterInLoop := CALCDATE('<+' + Format(QuarterCounter) + 'Q>', StatingQuarterEndDate);
                        _currentQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter) * 3) + 'M>', dueDate));
                        _previousQuarterInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));

                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop;

                        _outstandingAmount := _principle - (_dailyPrincipal * (QuarterCounter + 1));

                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentQuarterInLoop, 'RELATEDPARTY_REPORT');

                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentQuarterInLoop) then begin // QuarterCounter = 0 and (dueDate > _currentQuarterInLoop)
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
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                            _sumNumberOfDays := 0;
                        end;

                        if (QuarterCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _dailyPrincipal;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.TotalPayment := _sumTotalPayment;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := QuarterCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest);
                        Loan.OutStandingAmt := _outstandingAmount;

                        Loan.NumberofDays := DaysInQuarter;
                        Loan.DueDate := _currentQuarterInLoop;
                        Loan.CalculationDate := _currentQuarterInLoop;


                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;

            /*
              **
              **      ENSURE RIGHT SQEW IS TAKEN CARE IF
            */

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin

                NoOfQuarter := QuartersBetween(dueDate, maturityDate) + 0;
                if NoOfQuarter = 0 then
                    NoOfQuarter := 1; //ENSURE RIGHT SQEW IS TAKEN CARE IF

                StatingQuarterEndDate := placementDate;                                                       // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                _dailyPrincipal := _principle / (NoOfQuarter + 1);

                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    if (QuarterCounter = 0) and (QuarterCounter <> NoOfQuarter) then begin
                        _currentQuarterInLoop := dueDate;
                        DaysInQuarter := dueDate - placementDate + 0;

                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (QuarterCounter = 1) and (QuarterCounter <> NoOfQuarter) then begin
                        _currentQuarterInLoop := (CALCDATE('<+3M>', dueDate));
                        _previousQuarterInLoop := dueDate;

                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop + 0;
                        _outstandingAmount := _principle - (_dailyPrincipal * 2);
                    end
                    else if QuarterCounter = NoOfQuarter then begin
                        // _currentQuarterInLoop := GetstartOfQuarter(maturityDate);
                        _currentQuarterInLoop := maturityDate;
                        _previousQuarterInLoop := (CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));

                        DaysInQuarter := maturityDate - _previousQuarterInLoop + 0;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentQuarterInLoop := maturityDate;
                        // _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                    end
                    else begin
                        _currentQuarterInLoop := (CALCDATE('<+' + Format((QuarterCounter) * 3) + 'M>', dueDate));
                        _previousQuarterInLoop := (CALCDATE('<+' + Format((QuarterCounter - 1) * 3) + 'M>', dueDate));
                        DaysInQuarter := _currentQuarterInLoop - _previousQuarterInLoop;

                        _outstandingAmount := _principle - (_dailyPrincipal * (QuarterCounter + 1));
                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentQuarterInLoop, 'RELATEDPARTY_REPORT');

                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;


                    if (dueDate <> 0D) and (dueDate = _currentQuarterInLoop) then begin // QuarterCounter = 0 and (dueDate > _currentQuarterInLoop)
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
                        FirstDueAccumulator.CalcSums(NumberofDays);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                            _sumNumberOfDays := 0;
                        end;

                        if (QuarterCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _dailyPrincipal;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.TotalPayment := _sumTotalPayment;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := QuarterCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest);
                        Loan.OutStandingAmt := _outstandingAmount;

                        Loan.NumberofDays := DaysInQuarter;
                        Loan.DueDate := _currentQuarterInLoop;
                        Loan.CalculationDate := _currentQuarterInLoop;


                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;
                end;

            end;


            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin

                NoOfQuarter := QuartersBetween(placementDate, maturityDate) + 0; // No of Quarters
                                                                                 // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
                StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
                StatingQuarterEndDate := GetEndOfQuarter(placementDate);
                _dailyPrincipal := _principle / (NoOfQuarter + 1);

                for QuarterCounter := 0 to NoOfQuarter do begin
                    _currentQuarterInLoop := 0D;
                    DaysInQuarter := 0;
                    if QuarterCounter = 0 then begin
                        _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                        if _currentQuarterInLoop <> placementDate then
                            DaysInQuarter := (_currentQuarterInLoop - placementDate) + 1
                        else
                            DaysInQuarter := (_currentQuarterInLoop - placementDate) + 0;
                        // DaysInQuarter := _currentQuarterInLoop - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    // else if QuarterCounter = 1 then begin
                    //     _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                    //     DaysInQuarter := _currentQuarterInLoop - placementDate + 0;
                    //     _outstandingAmount := _principle - (_dailyPrincipal * 2);
                    // end
                    else if QuarterCounter = NoOfQuarter then begin
                        _currentQuarterInLoop := GetstartOfQuarter(maturityDate);
                        DaysInQuarter := maturityDate - _currentQuarterInLoop + 0;
                        _amortization := _principle;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        // _currentQuarterInLoop := maturityDate;
                        _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                        if maturityDate < _currentQuarterInLoop then
                            _currentQuarterInLoop := maturityDate
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
                        _outstandingAmount := _principle - (_dailyPrincipal * (QuarterCounter + 1));
                    end;

                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter
                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentQuarterInLoop, 'RELATEDPARTY_REPORT');

                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInQuarter / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
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
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        // FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(Amortization);

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

                        if _secondStep = true then begin
                            //If the Quarter upper limit exceeds the maturity date. meaning the last/final iteration.
                            if _currentQuarterInLoop > maturityDate then
                                Loan.OutStandingAmt := 0
                            else
                                Loan.OutStandingAmt := _principle - Loan.Amortization;

                            Loan.NumberofDays := DaysInQuarter + _sumNumberOfDays;
                            Loan.DueDate := _currentQuarterInLoop;
                            Loan.CalculationDate := _currentQuarterInLoop;
                            _secondStep := false;
                        end else begin
                            Loan.OutStandingAmt := _outstandingAmount;
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

        if RelatedPartyTbl.PeriodicPaymentOfPrincipal = RelatedPartyTbl.PeriodicPaymentOfPrincipal::Biannually then begin
            /*
             **
             **      ENSURE RIGHT SQEW IS TAKEN CARE IF
             */
            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin

                NoOfBiann := Count6MonthPeriods(dueDate, maturityDate) + 0;
                if NoOfBiann = 0 then
                    NoOfBiann := 1; //ENSURE RIGHT SQEW IS TAKEN CARE 0F

                StatingBiannEndDate := placementDate;
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                _dailyPrincipal := _principle / (NoOfBiann + 1);

                for BiannCounter := 0 to NoOfBiann do begin
                    _currentBiannInLoop := 0D;
                    DaysInBiann := 0;

                    if (BiannCounter = 0) and (BiannCounter <> NoOfBiann) then begin
                        _currentBiannInLoop := dueDate;
                        DaysInBiann := dueDate - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (BiannCounter = 1) and (BiannCounter <> NoOfBiann) then begin
                        _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+6M>', dueDate));
                        _previousBiannInLoop := dueDate;
                        DaysInBiann := _currentBiannInLoop - _previousBiannInLoop + 0;

                        _outstandingAmount := _principle - (_dailyPrincipal * 2);
                    end
                    else if BiannCounter = NoOfBiann then begin
                        // _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                        _currentBiannInLoop := maturityDate;
                        _previousBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));

                        DaysInBiann := maturityDate - _previousBiannInLoop;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentBiannInLoop := maturityDate;
                    end
                    else begin
                        _outstandingAmount := _principle - (_dailyPrincipal * (BiannCounter + 1));
                        _currentBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter) * 6) + 'M>', dueDate));
                        _previousBiannInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        DaysInBiann := _currentBiannInLoop - _previousBiannInLoop;
                    end;


                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentBiannInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentBiannInLoop) then begin

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
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                            _sumNumberOfDays := 0;
                        end;


                        if (BiannCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _dailyPrincipal;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.TotalPayment := _sumTotalPayment;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;
                        Loan.Init();

                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := BiannCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest);
                        Loan.OutStandingAmt := _outstandingAmount;
                        Loan.NumberofDays := DaysInBiann;
                        Loan.DueDate := _currentBiannInLoop;
                        Loan.CalculationDate := _currentBiannInLoop;
                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;
            end;
            //BiannualPeriodsBetweenDueDateEffect
            /*
            **
            **      ENSURE RIGHT SQEW IS TAKEN CARE IF
            */
            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin
                NoOfBiann := Count6MonthPeriods(dueDate, maturityDate) + 0;
                if NoOfBiann = 0 then
                    NoOfBiann := 1; //ENSURE RIGHT SQEW IS TAKEN CARE IF

                StatingBiannEndDate := placementDate;
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                _dailyPrincipal := _principle / (NoOfBiann + 1);

                for BiannCounter := 0 to NoOfBiann do begin
                    _currentBiannInLoop := 0D;
                    DaysInBiann := 0;

                    if (BiannCounter = 0) and (BiannCounter <> NoOfBiann) then begin //If starting doesnt have zero period
                        _currentBiannInLoop := dueDate;
                        DaysInBiann := dueDate - placementDate + 0;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (BiannCounter = 1) and (BiannCounter <> NoOfBiann) then begin
                        _currentBiannInLoop := (CALCDATE('<+6M>', dueDate));
                        _previousBiannInLoop := dueDate;
                        DaysInBiann := _currentBiannInLoop - _previousBiannInLoop + 0;
                        _outstandingAmount := _principle - (_dailyPrincipal * 2);
                    end
                    else if BiannCounter = NoOfBiann then begin
                        // _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                        _currentBiannInLoop := maturityDate;
                        _previousBiannInLoop := (CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));

                        DaysInBiann := maturityDate - _previousBiannInLoop;
                        _amortization := _dailyPrincipal;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentBiannInLoop := maturityDate;
                    end
                    else begin
                        _outstandingAmount := _principle - (_dailyPrincipal * (BiannCounter + 1));
                        _currentBiannInLoop := (CALCDATE('<+' + Format((BiannCounter) * 6) + 'M>', dueDate));
                        _previousBiannInLoop := (CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', dueDate));
                        DaysInBiann := _currentBiannInLoop - _previousBiannInLoop;
                    end;


                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentBiannInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;


                    if (dueDate <> 0D) and (dueDate = _currentBiannInLoop) then begin

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
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
                            FirstDueAccumulator.Reviewed := true;
                            FirstDueAccumulator.Modify();
                        end else begin
                            _sumInterest := 0;
                            _sumNetInterest := 0;
                            _sumWtholding := 0;
                            _sumTotalPayment := 0;
                            _sumOutstanding := 0;
                            _sumNumberOfDays := 0;
                        end;


                        if (BiannCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _dailyPrincipal;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.TotalPayment := _sumTotalPayment;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := BiannCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest);
                        Loan.OutStandingAmt := _outstandingAmount;
                        Loan.NumberofDays := DaysInBiann;
                        Loan.DueDate := _currentBiannInLoop;
                        Loan.CalculationDate := _currentBiannInLoop;
                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;
            end;

            /*
            **
            **      ??
            */
            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin
                NoOfBiann := CountBiannualPeriodsCrossed(placementDate, maturityDate) + 0; // No of Bianuals
                StatingBiannEndDate := GetBiannualEndDate(placementDate);
                StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
                _dailyPrincipal := _principle / (NoOfBiann + 1);
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
                    // Normal Std Calender Period

                    if BiannCounter = 0 then begin
                        _currentBiannInLoop := GetEndOfBiannual(placementDate);
                        if GetEndOfBiannual(placementDate) <> placementDate then
                            DaysInBiann := _currentBiannInLoop - placementDate + 1
                        else
                            DaysInBiann := _currentBiannInLoop - placementDate;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    // else if BiannCounter = 1 then begin
                    //     _currentBiannInLoop := GetEndOfBiannual(placementDate);
                    //     DaysInBiann := _currentBiannInLoop - placementDate + 0;
                    //     // _outstandingAmount := _principle;
                    //     _outstandingAmount := _principle - _dailyPrincipal;
                    // end
                    else if BiannCounter = NoOfBiann then begin
                        _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                        DaysInBiann := maturityDate - _currentBiannInLoop + 0;

                        _amortization := _principle;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;
                        _currentBiannInLoop := maturityDate;
                        // _currentBiannInLoop := GetEndOfBiannual(maturityDate);
                    end
                    else begin
                        // if (dueDate <> 0D) then begin
                        //     _currentBiannInLoop := CALCDATE('<+' + Format((BiannCounter - 1) * 6) + 'M>', StatingBiannEndDate);
                        //     BiannCounterRem := (BiannCounter) mod 2;
                        // end
                        // else begin
                        //     _currentBiannInLoop := CALCDATE('<+' + Format(BiannCounter * 6) + 'M>', StatingBiannEndDate);
                        //     BiannCounterRem := BiannCounter mod 2;
                        // end;
                        _currentBiannInLoop := GetBiannualEndDate(CALCDATE('<+' + Format((BiannCounter + 0) * 6) + 'M>', StatingBiannEndDate));
                        // if (DueDateCalcPeriodEq) then
                        //     _currentBiannInLoop := CALCDATE('<+' + Format((BiannCounter + 1) * 6) + 'M>', StatingBiannEndDate);


                        /*BiannCounterRem := BiannCounter mod 2;
                        if BiannCounterRem = 0 then
                            BiannCounterRem := 2;
                        if BiannCounterRem = 2 then
                            DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3))
                        else
                            DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3));
                        */
                        DaysInBiann := GetDaysInCurrentBiannual(_currentBiannInLoop);

                        _outstandingAmount := _principle - (_dailyPrincipal * (BiannCounter + 1));
                    end;

                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentBiannInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInBiann / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;




                    if (dueDate <> 0D) and (dueDate > _currentBiannInLoop) and (dueDate <> _currentBiannInLoop) then begin
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
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(Amortization);

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
                            Loan.DueDate := _currentBiannInLoop;
                            Loan.CalculationDate := _currentBiannInLoop;
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

        if RelatedPartyTbl.PeriodicPaymentOfPrincipal = RelatedPartyTbl.PeriodicPaymentOfPrincipal::Annually then begin

            /*
            **
            **      ENSURE RIGHT SQEW IS TAKEN CARE IF
            */
            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = true)) then begin
                NoOfAnnual := CountExact12MonthPeriods(dueDate, maturityDate) + 1;
                if NoOfAnnual = 0 then
                    NoOfAnnual := 1;//ENSURE RIGHT SQEW IS TAKEN CARE 0Fs

                StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
                _dailyPrincipal := _principle / (NoOfAnnual + 1);
                for AnnualCounter := 0 to NoOfAnnual do begin
                    _currentAnnualInLoop := 0D;
                    DaysInAnnual := 0;
                    if (AnnualCounter = 0) and (AnnualCounter <> NoOfAnnual) then begin
                        _currentAnnualInLoop := dueDate;
                        DaysInAnnual := dueDate - placementDate;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (AnnualCounter = 1) and (AnnualCounter <> NoOfAnnual) then begin
                        _currentAnnualInLoop := AdjustWeekendDate(CALCDATE('<+12M>', dueDate));
                        _previousAnnualInLoop := dueDate;
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop;
                        _outstandingAmount := _principle - (_dailyPrincipal * 2);
                    end
                    else if AnnualCounter = NoOfAnnual then begin
                        _currentAnnualInLoop := maturityDate;
                        _previousAnnualInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));
                        DaysInAnnual := maturityDate - _previousAnnualInLoop;
                        _amortization := _principle;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;

                    end
                    else begin
                        _currentAnnualInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((AnnualCounter) * 12) + 'M>', dueDate));
                        _previousAnnualInLoop := AdjustWeekendDate(CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));

                        _outstandingAmount := _principle - (_dailyPrincipal * (AnnualCounter + 1));
                        // DaysInAnnual := GetDaysInYear(DATE2DMY(_currentAnnualInLoop, 3))
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop;
                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentAnnualInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentAnnualInLoop) then begin
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
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInAnnual;
                        FirstDueAccumulator.Insert();
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(Amortization);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
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

                        if (AnnualCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := monthlyInterest + _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _sumAmortization;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.TotalPayment := _sumTotalPayment;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := AnnualCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest);
                        Loan.OutStandingAmt := _outstandingAmount;
                        Loan.NumberofDays := DaysInAnnual;
                        Loan.DueDate := _currentAnnualInLoop;
                        Loan.CalculationDate := _currentAnnualInLoop;
                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;

            end;

            /*
            **
            **      ENSURE RIGHT SQEW IS TAKEN CARE IF
            */

            if ((_dueDateInfluence = true) and (_skipWeekendInfluence = false)) then begin
                NoOfAnnual := CountExact12MonthPeriods(dueDate, maturityDate) + 1;
                if NoOfAnnual = 0 then
                    NoOfAnnual := 1;//ENSURE RIGHT SQEW IS TAKEN CARE 0Fs

                StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
                _dailyPrincipal := _principle / (NoOfAnnual + 1);
                for AnnualCounter := 0 to NoOfAnnual do begin
                    _currentAnnualInLoop := 0D;
                    DaysInAnnual := 0;
                    if (AnnualCounter = 0) and (AnnualCounter <> NoOfAnnual) then begin
                        _currentAnnualInLoop := dueDate;
                        DaysInAnnual := dueDate - placementDate;
                        _outstandingAmount := _principle - _dailyPrincipal;
                    end
                    else if (AnnualCounter = 1) and (AnnualCounter <> NoOfAnnual) then begin
                        _currentAnnualInLoop := (CALCDATE('<+12M>', dueDate));
                        _previousAnnualInLoop := dueDate;
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop;
                        _outstandingAmount := _principle - (_dailyPrincipal * 2);
                    end
                    else if (AnnualCounter = NoOfAnnual) then begin
                        _currentAnnualInLoop := maturityDate;
                        _previousAnnualInLoop := (CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));
                        DaysInAnnual := maturityDate - _previousAnnualInLoop;
                        _amortization := _principle;
                        _outstandingAmount := 0;
                        _totalPayment := _principle;

                    end
                    else begin
                        _currentAnnualInLoop := (CALCDATE('<+' + Format((AnnualCounter) * 12) + 'M>', dueDate));
                        _previousAnnualInLoop := (CALCDATE('<+' + Format((AnnualCounter - 1) * 12) + 'M>', dueDate));

                        _outstandingAmount := _principle - (_dailyPrincipal * (AnnualCounter + 1));
                        // DaysInAnnual := GetDaysInYear(DATE2DMY(_currentAnnualInLoop, 3))
                        DaysInAnnual := _currentAnnualInLoop - _previousAnnualInLoop;
                    end;

                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentAnnualInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 365);
                    end
                    else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
                    end;

                    if (dueDate <> 0D) and (dueDate = _currentAnnualInLoop) then begin
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
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
                        FirstDueAccumulator.InterestRate := _interestRate_Active;
                        FirstDueAccumulator.TotalPayment := _totalPayment + monthlyInterest;
                        FirstDueAccumulator.OutStandingAmt := _outstandingAmount;
                        FirstDueAccumulator.NumberofDays := DaysInAnnual;
                        FirstDueAccumulator.Insert();
                    end
                    else begin
                        FirstDueAccumulator.Reset();
                        FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                        FirstDueAccumulator.SetRange(Reviewed, false);
                        FirstDueAccumulator.CalcSums(Interest);
                        FirstDueAccumulator.CalcSums(NetInterest);
                        FirstDueAccumulator.CalcSums(WithHldTaxAmt);
                        FirstDueAccumulator.CalcSums(TotalPayment);
                        FirstDueAccumulator.CalcSums(OutStandingAmt);
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(Amortization);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
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

                        if (AnnualCounter = 1) and (_sumNumberOfDays <> 0) then begin
                            Loan.Init();
                            Loan.Interest := monthlyInterest + _sumInterest;
                            Loan.LoanNo := _fNo;
                            Loan.WithHldTaxAmt := _sumWtholding;
                            Loan.NetInterest := _sumNetInterest;
                            Loan.LoopCount := -1;
                            Loan.Amortization := _sumAmortization;
                            Loan.InterestRate := _interestRate_Active;
                            Loan.TotalPayment := _sumTotalPayment;
                            Loan.OutStandingAmt := _sumOutstanding;
                            Loan.NumberofDays := _sumNumberOfDays;
                            Loan.DueDate := dueDate;
                            Loan.CalculationDate := dueDate;
                            Loan.Insert();
                        end;

                        Loan.Init();
                        Loan.Interest := monthlyInterest + _sumInterest;
                        Loan.LoanNo := _fNo;
                        Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                        Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt);
                        Loan.LoopCount := AnnualCounter;
                        Loan.Amortization := _dailyPrincipal;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest);
                        Loan.OutStandingAmt := _outstandingAmount;
                        Loan.NumberofDays := DaysInAnnual;
                        Loan.DueDate := _currentAnnualInLoop;
                        Loan.CalculationDate := _currentAnnualInLoop;
                        Loan.Insert();

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;

            end;

            /*
            **
            **     ??
            */
            if ((_dueDateInfluence = false) and (_skipWeekendInfluence = false)) then begin
                NoOfAnnual := AnnualPeriodsBetween(placementDate, maturityDate) + 1;
                StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
                _dailyPrincipal := _principle / NoOfAnnual;
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
                        _outstandingAmount := _principle - _dailyPrincipal;
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
                        _outstandingAmount := _principle - (_dailyPrincipal * AnnualCounter);
                        _currentAnnualInLoop := CALCDATE('<+' + Format(AnnualCounter) + 'Y>', StatingAnnualEndDate);
                        DaysInAnnual := GetDaysInYear(DATE2DMY(_currentAnnualInLoop, 3))
                    end;
                    //Get quarter date. - sub the current date for days.
                    //Add to the next quarter
                    _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentAnnualInLoop, 'RELATEDPARTY_REPORT');


                    if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 360);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 364);
                    end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _principle) * (DaysInAnnual / 365);
                    end;



                    if (dueDate <> 0D) and (dueDate > _currentAnnualInLoop) and (dueDate <> _currentAnnualInLoop) then begin
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
                        FirstDueAccumulator.Amortization := _dailyPrincipal;
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
                        FirstDueAccumulator.CalcSums(NumberofDays);
                        FirstDueAccumulator.CalcSums(Amortization);

                        if FirstDueAccumulator.Count > 0 then begin
                            _sumInterest := FirstDueAccumulator.Interest;
                            _sumNetInterest := FirstDueAccumulator.NetInterest;
                            _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                            _sumTotalPayment := FirstDueAccumulator.TotalPayment;
                            _sumOutstanding := FirstDueAccumulator.OutStandingAmt;
                            _sumAmortization := FirstDueAccumulator.Amortization;
                            _sumNumberOfDays := FirstDueAccumulator.NumberofDays;
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
                        Loan.LoopCount := AnnualCounter;
                        Loan.Amortization := _dailyPrincipal + _sumAmortization;
                        Loan.InterestRate := _interestRate_Active;
                        Loan.TotalPayment := (_totalPayment + monthlyInterest) + _sumTotalPayment;
                        Loan.OutStandingAmt := _outstandingAmount;
                        // Loan.NumberofDays := DaysInQuarter;
                        if _secondStep = true then begin
                            // Loan.NumberofDays := dueDate - RelatedPartyTbl.PlacementDate;
                            //  Loan.DueDate := dueDate;
                            // Loan.CalculationDate := dueDate;
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

                        FirstDueAccumulator.Reset();
                        if FirstDueAccumulator.Count > 0 then
                            FirstDueAccumulator.DeleteAll();
                    end;

                end;

            end;
        end;


        if RelatedPartyTbl.PeriodicPaymentOfPrincipal = RelatedPartyTbl.PeriodicPaymentOfPrincipal::"Total at Due Date" then begin
            _outstandingAmount := _principle;
            _amortization := _principle;
            _totalPayment := _principle;
            _currentAnnualInLoop := maturityDate;

            _interestRate_Active := TrsyMgt.GetInterestRateSchedule(RelatedPartyTbl."No.", _currentAnnualInLoop, 'RELATEDPARTY_REPORT');

            if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/360" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 360);
            end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/360" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (dateDiff / 360);
            end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/364" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (dateDiff / 364);
            end else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"Actual/365" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (dateDiff / 365);
            end
            else if RelatedPartyTbl.InterestMethod = RelatedPartyTbl.InterestMethod::"30/365" then begin
                monthlyInterest := ((_interestRate_Active / 100) * _principle) * (30 / 365);
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

    /// <summary>
    /// Returns the number of days in a specified biannual period (1 or 2) for a given year.
    /// </summary>
    /// <param name="BiannualNumber">1 (Jan-Jun) or 2 (Jul-Dec)</param>
    /// <param name="Year">The year to check</param>
    /// <returns>Number of days in the biannual period</returns>
    procedure GetDaysInBiannual(BiannualNumber: Integer; Year: Integer): Integer
    var
        DaysInFirstHalf: Integer;
        DaysInSecondHalf: Integer;
        IsLeapYear: Boolean;
    begin
        // Validate input
        if not (BiannualNumber in [1, 2]) then
            Error('BiannualNumber must be 1 (Jan-Jun) or 2 (Jul-Dec)');

        // Check if leap year (February has 29 days)
        IsLeapYear := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));

        // Calculate days in each half
        case BiannualNumber of
            1: // January - June
                begin
                    DaysInFirstHalf := 31  // January
                                           // February
                                + 31  // March
                                + 30  // April
                                + 31  // May
                                + 30; // June
                    if IsLeapYear then
                        DaysInFirstHalf := DaysInFirstHalf + 29
                    else
                        DaysInFirstHalf := DaysInFirstHalf + 28;

                    exit(DaysInFirstHalf);
                end;
            2: // July - December
                begin
                    DaysInSecondHalf := 31  // July
                                     + 31  // August
                                     + 30  // September
                                     + 31  // October
                                     + 30  // November
                                     + 31; // December
                    exit(DaysInSecondHalf);
                end;
        end;
    end;

    // procedure GetDaysInBiannual(Biannual: Integer; Year: Integer): Integer
    // var
    //     StartOfBiannual: Date;
    //     EndOfBiannual: Date;
    //     NumDays: Integer;
    // begin
    //     case Biannual of
    //         1:
    //             begin
    //                 StartOfBiannual := DMY2Date(1, 1, Year);   // January 1
    //                 EndOfBiannual := DMY2Date(30, 6, Year);   // June 30
    //             end;
    //         2:
    //             begin
    //                 StartOfBiannual := DMY2Date(1, 7, Year);   // July 1
    //                 EndOfBiannual := DMY2Date(31, 12, Year);  // December 31
    //             end;
    //         else
    //             Error('Invalid biannual value. Please enter 1 or 2.');
    //     end;

    //     // Calculate the number of days
    //     NumDays := EndOfBiannual - StartOfBiannual + 1;

    //     exit(NumDays);
    // end;

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
        RelatedNo: Code[20];
        RelatedPartyTbl: Record "RelatedParty Loan";
        ReportFlag: Record "Report Flags";
        TrsyMgt: Codeunit "Treasury Mgt CU";
        FirstDueAccumulator: Record "Intr- Amort Partial";

}