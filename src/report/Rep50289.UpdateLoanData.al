report 50289 "Update Loan Data"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;



    dataset
    {
        dataitem("Funder Loan"; "Funder Loan")
        {
            trigger OnAfterGetRecord()
            var
                _loans: Record "Funder Loan";
            begin
                _loans.Reset();
                _loans.SetRange("No.", "Funder Loan"."No.");
                if _loans.Find('-') then begin
                    if _loans."Portfolio No." = '' then begin
                        Funder.Reset();
                        Funder.SetRange("No.", "Funder No.");
                        if Funder.Find('-') then begin
                            Portfolio.Reset();
                            Portfolio.SetRange("No.", Funder.Portfolio);
                            if Portfolio.Find('-') then begin
                                _loans."Portfolio Name" := Portfolio.Code;
                                _loans."Portfolio No." := Portfolio."No.";
                                if Portfolio.Category = Portfolio.Category::"Bank Loan" then
                                    _loans.Category := 'Bank Loan';
                                if Portfolio.Category = Portfolio.Category::Individual then
                                    _loans.Category := 'Individual';
                                if Portfolio.Category = Portfolio.Category::Institutional then
                                    _loans.Category := 'Institutional';
                                if Portfolio.Category = Portfolio.Category::"Bank Overdraft" then
                                    _loans.Category := 'Bank Overdraft';
                                if Portfolio.Category = Portfolio.Category::"Medium Term Notes" then
                                    _loans.Category := 'Medium Term Notes';
                                if Portfolio.Category = Portfolio.Category::"Asset Term Manager" then
                                    _loans.Category := 'Asset Term Manager';
                                if Portfolio.Category = Portfolio.Category::Relatedparty then
                                    _loans.Category := 'Relatedparty';
                            end;
                        end;
                    end;
                    Funder.Reset();
                    Funder.SetRange("No.", "Funder No.");
                    if Funder.Find('-') then begin
                        _loans.Name := Funder.Name;
                        _loans."Payables Account" := Funder."Payables Account";
                        _loans."Interest Expense" := Funder."Interest Expense";
                        _loans."Interest Payable" := Funder."Interest Payable";

                    end;
                    _loans.Validate(InterestRate);
                    _loans.Modify();
                end

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

    procedure GetEndOfQuarterDueDate(PassedDate: Date): Date
    var
        Month: Integer;
        EndOfQuarter: Date;
    begin
        EndOfQuarter := CalcDate('<+3M>', PassedDate);
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

    /// <summary>
    /// Simplified version that counts each standard biannual period (June 30/Dec 31) between dates
    /// </summary>
    procedure CountBiannualPeriodsSimple(StartDate: Date; EndDate: Date): Integer
    var
        StartYear, EndYear : Integer;
        TotalPeriods: Integer;
    begin
        if (StartDate = 0D) or (EndDate = 0D) then
            exit(0);

        StartYear := Date2DMY(StartDate, 3);
        EndYear := Date2DMY(EndDate, 3);
        /*
                // Calculate base number of periods (2 per year)
                TotalPeriods := (EndYear - StartYear) * 2;

                // Adjust for start/end periods
                if Date2DMY(StartDate, 2) <= 6 then
                    TotalPeriods += 1; // Starts in first half
                if Date2DMY(EndDate, 2) >= 7 then
                    TotalPeriods += 1; // Ends in second half
        */
        TotalPeriods := (EndDate - StartDate) div 6;
        exit(TotalPeriods);
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
    /// Calculates the number of biannual periods between two dates.
    /// </summary>
    /// <param name="StartDate">The starting date</param>
    /// <param name="EndDate">The ending date</param>
    /// <param name="CountPartialPeriods">Set to true to count partial half-years as periods</param>
    /// <returns>The number of biannual periods between the dates</returns>
    procedure GetNumberOfBiannualPeriods(StartDate: Date; EndDate: Date; CountPartialPeriods: Boolean) Result: Integer
    var
        CurrentDate: Date;
        BiannualEndDate1: Date;
        BiannualEndDate2: Date;
        Year: Integer;
    begin
        if (StartDate = 0D) or (EndDate = 0D) or (StartDate > EndDate) then
            exit(0);

        Result := 0;
        CurrentDate := StartDate;

        while CurrentDate <= EndDate do begin
            Year := Date2DMY(CurrentDate, 3);

            // Calculate standard biannual end dates for the current year
            BiannualEndDate1 := DMY2Date(30, 6, Year);  // First half-year end
            BiannualEndDate2 := DMY2Date(31, 12, Year); // Second half-year end

            // Check which biannual period we're in
            if CurrentDate <= BiannualEndDate1 then begin
                // First half of year
                if CountPartialPeriods or (CurrentDate = DMY2Date(1, 1, Year)) then begin
                    Result += 1;
                    CurrentDate := BiannualEndDate1 + 1;
                end else begin
                    if EndDate <= BiannualEndDate1 then
                        exit(Result + 1);
                    CurrentDate := BiannualEndDate1 + 1;
                end;
            end else begin
                // Second half of year
                if CountPartialPeriods or (CurrentDate = BiannualEndDate1 + 1) then begin
                    Result += 1;
                    CurrentDate := BiannualEndDate2 + 1;
                end else begin
                    if EndDate <= BiannualEndDate2 then
                        exit(Result + 1);
                    CurrentDate := BiannualEndDate2 + 1;
                end;
            end;
        end;
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
        FunderNo: Code[20];
        FunderLoanTbl: Record "Funder Loan";
        ReportFlag: Record "Report Flags";
        FirstDueAccumulator: Record "Intr- Amort Partial";
        TrsyMgt: Codeunit "Treasury Mgt CU";
        _GlobaloutstandingAmount: Decimal;
        Funder: Record Funders;
        Portfolio: Record Portfolio;
}