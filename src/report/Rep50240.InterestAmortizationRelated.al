report 50240 "Interest Amortization Related"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        // dataitem("Funder Loan"; "Funder Loan")
        // {
        //     // column(No_; "No.")
        //     // {

        //     // }
        // }
        dataitem(Loan; "Intr- Amort")
        {
            // RequestFilterFields = "No.";
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

        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(No; RelatedNo)
                    {
                        TableRelation = "RelatedParty- Cust"."No.";
                        ApplicationArea = All;

                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = './reports/interestamortizationR.rdlc';
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

        NoOfQuarter: Integer;
        QuarterCounter: Integer;
        _currentQuarterInLoop: Date;
        DaysInQuarter: Integer;
        StatingQuarterEndDate: date;
        QuarterCounterRem: Integer;

        NoOfBiann: Integer;
        BiannCounter: Integer;
        _currentBiannInLoop: Date;
        DaysInBiann: Integer;
        StatingBiannEndDate: date;
        BiannCounterRem: Integer;

        NoOfAnnual: Integer;
        AnnualCounter: Integer;
        _currentAnnualInLoop: Date;
        DaysInAnnual: Integer;
        StatingAnnualEndDate: date;

        _withHoldingTax_Percent: Decimal;
        _withHoldingTax_Amnt: Decimal;
    begin
        // Filters := RelatedPartyTbl.GetFilter("No.");
        ReportFlag.Reset();
        ReportFlag.SetFilter("Line No.", '<>%1', 0);
        ReportFlag.SetFilter("Utilizing User", '=%1', UserId);
        if not ReportFlag.FindFirst() then
            Error('No Report Flag Added');
        RelatedNo := ReportFlag."Related Party No";

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
        _interestRate_Active := 0;
        //TrsyMgt.GetInterestRate(RelatedPartyTbl."No.", 'RELATEDPARTY_REPORT');
        /* if (RelatedPartyTbl.InterestRateType = RelatedPartyTbl.InterestRateType::"Fixed Rate") then
             _interestRate_Active := RelatedPartyTbl.InterestRatePA;
         if (RelatedPartyTbl.InterestRateType = RelatedPartyTbl.InterestRateType::"Floating Rate") then
             _interestRate_Active := (RelatedPartyTbl."Reference Rate" + RelatedPartyTbl.Margin);

         if _interestRate_Active = 0 then
             Error('Interest Rate is Zero');*/


        _withHoldingTax_Percent := RelatedPartyTbl.Withldtax;
        _withHoldingTax_Amnt := 0;

        RelatedPartyTbl.CalcFields(OutstandingAmntDisbLCY);
        _principle := RelatedPartyTbl.OutstandingAmntDisbLCY;


        Loan.Reset();
        Loan.DeleteAll();
        if RelatedPartyTbl.InterestRepaymentFreq = RelatedPartyTbl.InterestRepaymentFreq::Monthly then begin
            //12
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
                end;

                DaysInMonth := DATE2DMY(_currentMonthInLoop, 1);
                if (monthCounter = 0) then begin
                    //Start Date
                    DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 1; //Remaining to End month
                end;
                if (monthCounter = NoOfMonths) then begin
                    //End Date
                    DaysInMonth := maturityDate - CalcDate('<-CM>', maturityDate);
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
                end;

                // withholding calc
                if _withHoldingTax_Percent <> 0 then begin
                    _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                end;

                Loan.Init();
                Loan.DueDate := _currentMonthInLoop;
                Loan.Interest := monthlyInterest;
                Loan.CalculationDate := _currentMonthInLoop;
                Loan.LoanNo := _fNo;
                Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                Loan.LoopCount := monthCounter;
                Loan.Insert();

                // monthCounter := monthCounter + 1;
            end;
        end;
        // DateRange := CalcDate('<1M>', StartDate);
        if RelatedPartyTbl.InterestRepaymentFreq = RelatedPartyTbl.InterestRepaymentFreq::Quarterly then begin
            //12
            //No of days in that month
            NoOfQuarter := QuartersBetween(placementDate, maturityDate); // No of Quarters
            StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
            for QuarterCounter := 0 to NoOfQuarter do begin
                _currentQuarterInLoop := 0D;
                DaysInQuarter := 0;
                if QuarterCounter = 0 then begin
                    _currentQuarterInLoop := GetStartOfQuarter(placementDate);
                    DaysInQuarter := placementDate - _currentQuarterInLoop;
                end
                else if QuarterCounter = 1 then begin
                    _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                    DaysInQuarter := _currentQuarterInLoop - placementDate;
                end
                else if QuarterCounter = NoOfQuarter then begin
                    _currentQuarterInLoop := GetStartOfQuarter(maturityDate);
                    DaysInQuarter := maturityDate - _currentQuarterInLoop + 1;
                    _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                end
                else begin
                    _currentQuarterInLoop := CALCDATE('<+' + Format(QuarterCounter) + 'Q>', StatingQuarterEndDate);
                    QuarterCounterRem := QuarterCounter mod 4;
                    if QuarterCounterRem = 0 then
                        QuarterCounterRem := 4;
                    DaysInQuarter := GetDaysInQuarter(QuarterCounterRem, DATE2DMY(_currentQuarterInLoop, 3))
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
                end;

                if _withHoldingTax_Percent <> 0 then begin
                    _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                end;

                Loan.Init();
                Loan.DueDate := _currentQuarterInLoop;
                Loan.Interest := monthlyInterest;
                Loan.CalculationDate := _currentQuarterInLoop;
                Loan.LoanNo := _fNo;
                Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                Loan.LoopCount := QuarterCounter;
                Loan.Insert();

            end;
        end;

        if RelatedPartyTbl.InterestRepaymentFreq = RelatedPartyTbl.InterestRepaymentFreq::Biannually then begin
            //12
            //No of days in that month
            NoOfBiann := BiannualPeriodsBetween(placementDate, maturityDate) + 1; // No of Quarters
            StatingBiannEndDate := GetClosestBiannualEndDate(placementDate);
            for BiannCounter := 0 to NoOfBiann do begin
                _currentBiannInLoop := 0D;
                DaysInBiann := 0;
                if BiannCounter = 0 then begin
                    _currentBiannInLoop := GetStartOfBiannual(placementDate);
                    DaysInBiann := _currentBiannInLoop - placementDate;
                end
                else if BiannCounter = 1 then begin
                    _currentBiannInLoop := GetEndOfBiannual(placementDate);
                    DaysInBiann := _currentBiannInLoop - placementDate;
                end
                else if BiannCounter = NoOfBiann then begin
                    _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                    DaysInBiann := maturityDate - _currentBiannInLoop + 1;
                    _currentBiannInLoop := maturityDate;

                end
                else begin
                    _currentBiannInLoop := CALCDATE('<+' + Format(BiannCounter * 6) + 'M>', StatingBiannEndDate);
                    BiannCounterRem := BiannCounter mod 2;
                    if BiannCounterRem = 0 then
                        BiannCounterRem := 2;
                    DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3))
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
                end;

                if _withHoldingTax_Percent <> 0 then begin
                    _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                end;

                Loan.Init();
                Loan.DueDate := _currentBiannInLoop;
                Loan.Interest := monthlyInterest;
                Loan.CalculationDate := _currentBiannInLoop;
                Loan.LoanNo := _fNo;
                Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                Loan.LoopCount := BiannCounter;
                Loan.Insert();

            end;
        end;

        if RelatedPartyTbl.InterestRepaymentFreq = RelatedPartyTbl.InterestRepaymentFreq::Annually then begin
            //12
            //No of days in that month
            NoOfAnnual := AnnualPeriodsBetween(placementDate, maturityDate) + 1; // No of Quarters
            StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
            for BiannCounter := 0 to NoOfAnnual do begin
                _currentAnnualInLoop := 0D;
                DaysInAnnual := 0;
                if BiannCounter = 0 then begin
                    _currentAnnualInLoop := GetStartOfYear(placementDate);
                    DaysInAnnual := _currentAnnualInLoop - placementDate + 1;
                end
                else if BiannCounter = 1 then begin
                    _currentAnnualInLoop := GetEndOfYear(placementDate);
                    DaysInAnnual := _currentAnnualInLoop - placementDate + 1;
                end
                else if BiannCounter = NoOfAnnual then begin
                    _currentAnnualInLoop := GetStartOfYear(maturityDate);
                    DaysInAnnual := maturityDate - _currentAnnualInLoop;
                    _currentAnnualInLoop := maturityDate;
                end
                else begin
                    _currentAnnualInLoop := CALCDATE('<+' + Format(BiannCounter) + 'Y>', StatingAnnualEndDate);
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

                if _withHoldingTax_Percent <> 0 then begin
                    _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                end;

                Loan.Init();
                Loan.DueDate := _currentAnnualInLoop;
                Loan.Interest := monthlyInterest;
                Loan.CalculationDate := _currentAnnualInLoop;
                Loan.LoanNo := _fNo;
                Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                Loan.LoopCount := BiannCounter;
                Loan.Insert();

            end;
        end;




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
        RelatedNo: Code[20];
        RelatedPartyTbl: Record "RelatedParty- Cust";
        ReportFlag: Record "Report Flags";
        TrsyMgt: Codeunit "Treasury Mgt CU";
}