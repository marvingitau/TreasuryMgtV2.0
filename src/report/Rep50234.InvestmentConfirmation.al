report 50234 "Investment Confirmation"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("Funder Loan"; "Funder Loan")
        {
            column(No_; "No.")
            {

            }
        }
        dataitem(Loan; "Schedule Total")
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
            column(Logo; Company.Picture)
            {

            }
            column(Insuer; Company.Name)
            {

            }
            column(Address; Company.Address)
            {

            }
            column(City; Company.City)
            {

            }
            column(SignatoryName; TrsySetup."Signatory Name") { }
            column(SignatoryPosition; TrsySetup."Signatory Position") { }
            column(Phone; Company."Phone No.")
            {

            }
            column(Security; FunderLoanTbl.SecurityType)
            {

            }

            column(ConfirmationNo; FunderLoanTbl."No.")
            {

            }
            column(ClientName; FunderLoanTbl.Name)
            {

            }
            column(ValueDate; FunderLoanTbl.PlacementDate)
            {

            }
            column(NoOFDays; NoOFDays)
            {

            }
            column(MaturityDate; FunderLoanTbl.MaturityDate)
            {

            }

            column(FaceValue; FunderLoanTbl."Original Disbursed Amount")
            {

            }
            column(Interst; FunderLoanTbl.InterestRate)
            {

            }
            // column(NetIntrest; NetIntrest)
            // {

            // }
            column(InterestFrequecy; FunderLoanTbl.PeriodicPaymentOfInterest)
            {

            }
            column(RepaymentCapital; FunderLoanTbl.MaturityDate)
            {

            }
            column(NumberofDays; NumberofDays) { }



            trigger OnPreDataItem()
            begin
                Company.GET;
                Company.CALCFIELDS(Picture);
                // if Loan.FindLast() then begin
                //     Loan.SetRange(Line, Loan.Line);
                //     // NetIntrest := Loan.Interest - Loan.WithHldTaxAmt;
                // end;
                TrsySetup.Get(0);


            end;

            trigger OnAfterGetRecord()
            begin
                SumInterest := SumInterest + Interest;
                SumWthTax := SumWthTax + WithHldTaxAmt;
                SumNetInterest := SumNetInterest + NetInterest;
            end;

            trigger OnPostDataItem()
            begin
                // Message('Total Amount: %1', SumWthTax);
            end;



        }
        dataitem(Integer; Integer)
        {
            // Set the number of iterations
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            column(SumInterest; SumInterest)
            {

            }
            column(SumNetInterest; SumNetInterest)
            {

            }
            column(SumWthTax; SumWthTax)
            {

            }
            column(ConfirmationDate; ConfirmationDate)
            {

            }
        }
    }

    requestpage
    {
        // AboutTitle = 'Teaching tip title';
        // AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(FunderNumber; FunderNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Funder No.';
                        TableRelation = "Funder Loan"."No.";
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
            Type = Word;
            LayoutFile = './reports/investmentconfirm.docx';
        }
    }
    trigger OnInitReport()
    begin

    end;

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
        StatingQuarterStartDate: date;
        QuarterCounterRem: Integer;

        NoOfBiann: Integer;
        BiannCounter: Integer;
        _currentBiannInLoop: Date;
        DaysInBiann: Integer;
        StatingBiannEndDate: date;
        StatingBiannStartDate: Date;
        BiannCounterRem: Integer;

        NoOfAnnual: Integer;
        AnnualCounter: Integer;
        _currentAnnualInLoop: Date;
        DaysInAnnual: Integer;
        StatingAnnualEndDate: date;

        _withHoldingTax_Percent: Decimal;
        _withHoldingTax_Amnt: Decimal;
        dueDate: Date;

        _sumInterest: Decimal;
        _sumWtholding: Decimal;
        _sumNetInterest: Decimal;
    begin
        // Filters := FunderLoanTbl.GetFilter("No.");
        ReportFlag.Reset();
        ReportFlag.SetFilter("Line No.", '<>%1', 0);
        ReportFlag.SetFilter("Utilizing User", '=%1', UserId);
        if not ReportFlag.FindFirst() then
            Error('No Report Flag Added');
        FunderNo := ReportFlag."Funder Loan No.";

        FunderLoanTbl.Reset();
        FunderLoanTbl.SetRange("No.", FunderNo);
        if not FunderLoanTbl.Find('-') then
            Error('Funder Loan not %1 found', FunderNo);
        _fNo := FunderLoanTbl."No.";
        // if FunderLoanTbl.FirstDueDate <> 0D then
        dueDate := FunderLoanTbl.FirstDueDate;
        // else
        placementDate := FunderLoanTbl.PlacementDate;

        maturityDate := FunderLoanTbl.MaturityDate;
        dateDiff := (maturityDate - placementDate);

        endYearDate := CALCDATE('CY', Today);
        remainingDays := endYearDate - FunderLoanTbl.PlacementDate;

        _principle := 0;
        _interestRate_Active := 0;
        //TrsyMgt.GetInterestRate(FunderLoanTbl."No.", 'FUNDER_REPORT');
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

        FunderLoanTbl.CalcFields(OrigAmntDisbLCY);
        _principle := FunderLoanTbl.OrigAmntDisbLCY;
        if (_principle = 0) then begin
            _principle := FunderLoanTbl."Original Disbursed Amount";
        end;

        NoOFDays := FunderLoanTbl.MaturityDate - FunderLoanTbl.PlacementDate + 1;
        ConfirmationDate := FunderLoanTbl.PlacementDate;
        // // StartDate := DMY2Date(1, 1, DATE2DMY(TODAY, 3)); // January 1 of the current year
        // // EndDate := DMY2Date(31, 12, DATE2DMY(TODAY, 3)); // December 31 of the current year
        // // // Calculate the number of days
        // // YearNumDays := EndDate - StartDate + 1;
        // FirstMonthDays := CalcDate('<CM>', placementDate) - placementDate;

        Loan.Reset();
        Loan.DeleteAll();
        FirstDueAccumulator.Reset();
        FirstDueAccumulator.DeleteAll();

        if FunderLoanTbl.PeriodicPaymentOfInterest = FunderLoanTbl.PeriodicPaymentOfInterest::Monthly then begin
            //12
            //No of days in that month
            NoOfMonths := MonthsBetween(placementDate, maturityDate) + 0;
            for monthCounter := 0 to NoOfMonths do begin
                _currentMonthInLoop := 0D;
                // if (monthCounter = 0) then begin
                //     _currentMonthInLoop := CalcDate('<CM>', placementDate);
                // end
                if (monthCounter = 0) then begin
                    _currentMonthInLoop := CalcDate('<CM>', placementDate);
                end
                else if (monthCounter = NoOfMonths) then begin
                    _currentMonthInLoop := CalcDate('<CM>', maturityDate);
                end
                else begin
                    QuarterCounterRem := monthCounter mod 12;
                    if QuarterCounterRem = 0 then
                        QuarterCounterRem := 12;
                    _currentMonthInLoop := CalcDate('<CM>', CalcDate('<' + Format(monthCounter) + 'M>', placementDate));
                end;

                // if IsDecember(_currentMonthInLoop) = true then
                //     DaysInMonth := DATE2DMY(_currentMonthInLoop, 1) - 1
                // else


                DaysInMonth := DATE2DMY(_currentMonthInLoop, 1);

                if (monthCounter = 0) then begin
                    //Start Date
                    if IsJanuaryFirst(placementDate) = true then
                        DaysInMonth := CalcDate('<CM>', placementDate) - placementDate + 1 //Remaining to End month
                    else
                        DaysInMonth := CalcDate('<CM>', placementDate) - placementDate;
                end;
                if (monthCounter = NoOfMonths) then begin
                    //End Date
                    DaysInMonth := maturityDate - CalcDate('<-CM>', maturityDate) + 1;
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

                // withholding calc
                if _withHoldingTax_Percent <> 0 then begin
                    _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                end;

                // Loan.Init();
                // Loan.DueDate := _currentMonthInLoop;
                // Loan.Interest := monthlyInterest;
                // Loan.CalculationDate := _currentMonthInLoop;
                // Loan.LoanNo := _fNo;
                // Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                // Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                // Loan.LoopCount := monthCounter;
                // Loan.NumberofDays := DaysInMonth;
                // Loan.Insert();

                // monthCounter := monthCounter + 1;

                if (dueDate <> 0D) and (dueDate > _currentMonthInLoop) then begin
                    //FirstDueAccumulator.Init();
                    FirstDueAccumulator.Line := QuarterCounter + 1;
                    FirstDueAccumulator.DueDate := _currentMonthInLoop;
                    FirstDueAccumulator.Interest := monthlyInterest;
                    FirstDueAccumulator.CalculationDate := _currentMonthInLoop;
                    FirstDueAccumulator.LoanNo := _fNo;
                    FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                    FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                    FirstDueAccumulator.LoopCount := monthCounter;
                    FirstDueAccumulator.NumberofDays := _currentMonthInLoop - FunderLoanTbl.PlacementDate;
                    FirstDueAccumulator.Insert();
                end else begin
                    FirstDueAccumulator.Reset();
                    FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                    FirstDueAccumulator.SetRange(Reviewed, false);
                    FirstDueAccumulator.CalcSums(Interest);
                    FirstDueAccumulator.CalcSums(NetInterest);
                    FirstDueAccumulator.CalcSums(WithHldTaxAmt);

                    if FirstDueAccumulator.Count > 0 then begin
                        _sumInterest := FirstDueAccumulator.Interest;
                        _sumNetInterest := FirstDueAccumulator.NetInterest;
                        _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                        FirstDueAccumulator.Reviewed := true;
                        FirstDueAccumulator.Modify();
                    end else begin
                        _sumInterest := 0;
                        _sumNetInterest := 0;
                        _sumWtholding := 0;
                    end;

                    Loan.Init();
                    Loan.DueDate := _currentMonthInLoop;
                    Loan.Interest := monthlyInterest;
                    Loan.CalculationDate := _currentMonthInLoop;
                    Loan.LoanNo := _fNo;
                    Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                    Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                    Loan.LoopCount := monthCounter;
                    // Loan.NumberofDays := DaysInMonth;
                    if (dueDate <> 0D) and (dueDate > _currentMonthInLoop) then begin
                        Loan.NumberofDays := _currentMonthInLoop - FunderLoanTbl.PlacementDate;
                    end else begin
                        Loan.NumberofDays := DaysInQuarter;
                    end;
                    Loan.Insert();

                    FirstDueAccumulator.Reset();
                    if FirstDueAccumulator.Count > 0 then
                        FirstDueAccumulator.DeleteAll();
                end;
            end;
        end;
        // DateRange := CalcDate('<1M>', StartDate);
        if FunderLoanTbl.PeriodicPaymentOfInterest = FunderLoanTbl.PeriodicPaymentOfInterest::Quarterly then begin
            //12
            //No of days in that month
            NoOfQuarter := QuartersBetween(placementDate, maturityDate); // No of Quarters
                                                                         // StatingQuarterEndDate := GetClosestQuarterEndDate(placementDate);
            StatingQuarterStartDate := GetClosestQuarterStartDate(placementDate);
            StatingQuarterEndDate := GetEndOfQuarter(placementDate);
            for QuarterCounter := 0 to NoOfQuarter do begin
                _currentQuarterInLoop := 0D;
                DaysInQuarter := 0;
                if QuarterCounter = 0 then begin
                    // _currentQuarterInLoop := GetStartOfQuarter(placementDate);
                    _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                    DaysInQuarter := (_currentQuarterInLoop - placementDate) + 1;

                end

                // else if QuarterCounter = 1 then begin
                //     _currentQuarterInLoop := GetEndOfQuarter(placementDate);
                //     DaysInQuarter := _currentQuarterInLoop - placementDate + 1;
                // end
                else if QuarterCounter = NoOfQuarter then begin
                    _currentQuarterInLoop := GetStartOfQuarter(maturityDate);
                    DaysInQuarter := maturityDate - _currentQuarterInLoop + 1;
                    _currentQuarterInLoop := GetEndOfQuarter(maturityDate);
                end
                else begin
                    // _currentQuarterInLoop := CALCDATE('<+' + Format(QuarterCounter) + 'Q>', StatingQuarterEndDate);
                    // // QuarterCounterRem := QuarterCounter mod 4;
                    // QuarterCounterRem := GetQuarter(_currentQuarterInLoop);
                    // // // DaysInQuarter := GetDaysInQuarter(QuarterCounter, DATE2DMY(_currentQuarterInLoop, 3)) + 1;
                    // // if QuarterCounterRem = 4 then
                    // //     DaysInQuarter := GetDaysInQuarter(_currentQuarterInLoop) - 1
                    // // else
                    // DaysInQuarter := GetDaysInQuarter(_currentQuarterInLoop);

                    // if QuarterCounterRem = 0 then
                    //     QuarterCounterRem := 4;
                    // _currentQuarterInLoop := CALCDATE('<+' + Format(QuarterCounter) + 'Q>', StatingQuarterEndDate);
                    _currentQuarterInLoop := AddQuartersToQuarterEnd(QuarterCounter, StatingQuarterEndDate);

                    QuarterCounterRem := QuarterCounter mod 4;
                    if QuarterCounterRem = 0 then
                        QuarterCounterRem := 4;
                    DaysInQuarter := GetDaysInQuarter(QuarterCounterRem, DATE2DMY(_currentQuarterInLoop, 3))
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

                if _withHoldingTax_Percent <> 0 then begin
                    _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                end;

                if (dueDate <> 0D) and (dueDate > _currentQuarterInLoop) then begin
                    //FirstDueAccumulator.Init();
                    FirstDueAccumulator.Line := QuarterCounter + 1;
                    FirstDueAccumulator.DueDate := _currentQuarterInLoop;
                    FirstDueAccumulator.Interest := monthlyInterest;
                    FirstDueAccumulator.CalculationDate := _currentQuarterInLoop;
                    FirstDueAccumulator.LoanNo := _fNo;
                    FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                    FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                    FirstDueAccumulator.LoopCount := monthCounter;
                    FirstDueAccumulator.NumberofDays := DaysInQuarter;
                    FirstDueAccumulator.Insert();
                end else begin
                    FirstDueAccumulator.Reset();
                    FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                    FirstDueAccumulator.SetRange(Reviewed, false);
                    FirstDueAccumulator.CalcSums(Interest);
                    FirstDueAccumulator.CalcSums(NetInterest);
                    FirstDueAccumulator.CalcSums(WithHldTaxAmt);

                    if FirstDueAccumulator.Count > 0 then begin
                        _sumInterest := FirstDueAccumulator.Interest;
                        _sumNetInterest := FirstDueAccumulator.NetInterest;
                        _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                        FirstDueAccumulator.Reviewed := true;
                        FirstDueAccumulator.Modify();
                    end else begin
                        _sumInterest := 0;
                        _sumNetInterest := 0;
                        _sumWtholding := 0;
                    end;


                    Loan.Init();
                    Loan.DueDate := _currentQuarterInLoop;
                    Loan.Interest := monthlyInterest + _sumInterest;
                    Loan.CalculationDate := _currentQuarterInLoop;
                    Loan.LoanNo := _fNo;
                    Loan.WithHldTaxAmt := _withHoldingTax_Amnt + _sumWtholding;
                    Loan.NetInterest := (monthlyInterest - _withHoldingTax_Amnt) + _sumNetInterest;
                    Loan.LoopCount := QuarterCounter;
                    Loan.NumberofDays := DaysInQuarter;
                    Loan.Insert();

                    FirstDueAccumulator.Reset();
                    if FirstDueAccumulator.Count > 0 then
                        FirstDueAccumulator.DeleteAll();
                end;



            end;
        end;

        if FunderLoanTbl.PeriodicPaymentOfInterest = FunderLoanTbl.PeriodicPaymentOfInterest::Biannually then begin
            //12
            //No of days in that month
            NoOfBiann := BiannualPeriodsBetween(placementDate, maturityDate) + 1; // No of Annual
            StatingBiannEndDate := GetClosestBiannualEndDate(placementDate);
            StatingBiannStartDate := GetClosestBiannualStartDate(placementDate);
            for BiannCounter := 1 to NoOfBiann do begin
                _currentBiannInLoop := 0D;
                DaysInBiann := 0;
                // if BiannCounter = 0 then begin
                //     _currentBiannInLoop := GetStartOfBiannual(placementDate);
                //     DaysInBiann := _currentBiannInLoop - placementDate;
                // end
                // else 
                if BiannCounter = 1 then begin
                    _currentBiannInLoop := GetEndOfBiannual(placementDate);
                    DaysInBiann := _currentBiannInLoop - placementDate + 1;
                end
                else if BiannCounter = NoOfBiann then begin
                    _currentBiannInLoop := GetStartOfBiannual(maturityDate);
                    DaysInBiann := maturityDate - _currentBiannInLoop + 1;
                    // _currentBiannInLoop := maturityDate;
                    _currentBiannInLoop := GetEndOfBiannual(maturityDate);


                end
                else begin
                    _currentBiannInLoop := CALCDATE('<+' + Format(BiannCounter * 6) + 'M>', StatingBiannStartDate);
                    BiannCounterRem := BiannCounter mod 2;
                    if BiannCounterRem = 0 then
                        BiannCounterRem := 2;
                    if BiannCounterRem = 2 then
                        DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3)) - 1
                    else
                        DaysInBiann := GetDaysInBiannual(BiannCounterRem, DATE2DMY(_currentBiannInLoop, 3));
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

                if _withHoldingTax_Percent <> 0 then begin
                    _withHoldingTax_Amnt := (monthlyInterest * _withHoldingTax_Percent / 100)
                end;

                // Loan.Init();
                // Loan.DueDate := _currentBiannInLoop;
                // Loan.Interest := monthlyInterest;
                // Loan.CalculationDate := _currentBiannInLoop;
                // Loan.LoanNo := _fNo;
                // Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                // Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                // Loan.LoopCount := BiannCounter;
                // Loan.NumberofDays := DaysInBiann;
                // Loan.Insert();

                if (dueDate <> 0D) and (dueDate > _currentBiannInLoop) then begin
                    //FirstDueAccumulator.Init();
                    FirstDueAccumulator.Line := QuarterCounter + 1;
                    FirstDueAccumulator.DueDate := _currentBiannInLoop;
                    FirstDueAccumulator.Interest := monthlyInterest;
                    FirstDueAccumulator.CalculationDate := _currentBiannInLoop;
                    FirstDueAccumulator.LoanNo := _fNo;
                    FirstDueAccumulator.WithHldTaxAmt := _withHoldingTax_Amnt;
                    FirstDueAccumulator.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                    FirstDueAccumulator.LoopCount := monthCounter;
                    FirstDueAccumulator.NumberofDays := _currentBiannInLoop - FunderLoanTbl.PlacementDate;
                    FirstDueAccumulator.Insert();
                end else begin
                    FirstDueAccumulator.Reset();
                    FirstDueAccumulator.SetFilter(Line, '<>%1', 0);
                    FirstDueAccumulator.SetRange(Reviewed, false);
                    FirstDueAccumulator.CalcSums(Interest);
                    FirstDueAccumulator.CalcSums(NetInterest);
                    FirstDueAccumulator.CalcSums(WithHldTaxAmt);

                    if FirstDueAccumulator.Count > 0 then begin
                        _sumInterest := FirstDueAccumulator.Interest;
                        _sumNetInterest := FirstDueAccumulator.NetInterest;
                        _sumWtholding := FirstDueAccumulator.WithHldTaxAmt;
                        FirstDueAccumulator.Reviewed := true;
                        FirstDueAccumulator.Modify();
                    end else begin
                        _sumInterest := 0;
                        _sumNetInterest := 0;
                        _sumWtholding := 0;
                    end;

                    Loan.Init();
                    Loan.DueDate := _currentBiannInLoop;
                    Loan.Interest := monthlyInterest;
                    Loan.CalculationDate := _currentBiannInLoop;
                    Loan.LoanNo := _fNo;
                    Loan.WithHldTaxAmt := _withHoldingTax_Amnt;
                    Loan.NetInterest := monthlyInterest - _withHoldingTax_Amnt;
                    Loan.LoopCount := BiannCounter;
                    // Loan.NumberofDays := DaysInBiann;
                    if (dueDate <> 0D) and (dueDate > _currentBiannInLoop) then begin
                        Loan.NumberofDays := _currentBiannInLoop - FunderLoanTbl.PlacementDate;

                    end else begin
                        Loan.NumberofDays := DaysInBiann;
                    end;
                    Loan.Insert();
                    FirstDueAccumulator.Reset();
                    if FirstDueAccumulator.Count > 0 then
                        FirstDueAccumulator.DeleteAll();
                end;

            end;
        end;

        if FunderLoanTbl.PeriodicPaymentOfInterest = FunderLoanTbl.PeriodicPaymentOfInterest::Annually then begin
            //12
            //No of days in that month
            NoOfAnnual := AnnualPeriodsBetween(placementDate, maturityDate) + 1; // No of Quarters
            StatingAnnualEndDate := GetClosestAnnualEndDate(placementDate);
            for BiannCounter := 1 to NoOfAnnual do begin
                _currentAnnualInLoop := 0D;
                DaysInAnnual := 0;
                // if BiannCounter = 0 then begin
                //     _currentAnnualInLoop := GetStartOfYear(placementDate);
                //     DaysInAnnual := _currentAnnualInLoop - placementDate + 1;
                // end
                // else
                if BiannCounter = 1 then begin
                    _currentAnnualInLoop := GetEndOfYear(placementDate);
                    DaysInAnnual := _currentAnnualInLoop - placementDate;
                end
                else if BiannCounter = NoOfAnnual then begin
                    _currentAnnualInLoop := GetStartOfYear(maturityDate);
                    DaysInAnnual := maturityDate - _currentAnnualInLoop + 1;
                    _currentAnnualInLoop := GetEndOfYear(maturityDate);
                    // _currentAnnualInLoop := maturityDate;
                end
                else begin
                    _currentAnnualInLoop := CALCDATE('<+' + Format(BiannCounter) + 'Y>', StatingAnnualEndDate);
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
                Loan.NumberofDays := DaysInAnnual;
                Loan.Insert();

            end;
        end;




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

    // Procedure to set the Customer No. filter

    // Procedure to run the report
    // procedure RunReport()
    // begin
    //     if FunderNo = '' then
    //         Error('Please specify a Funder No.');

    //     Report.Run(Report::"Investment Confirmation");
    // end;

    var
        FunderNo: Code[20];
        FunderLoanTbl: Record "Funder Loan";
        Company: Record "Company Information";
        TrsySetup: Record "Treasury General Setup";
        ReportFlag: Record "Report Flags";
        NoOFDays: Integer;
        // NetIntrest: Decimal;
        SumInterest: Decimal;
        SumWthTax: Decimal;
        SumNetInterest: Decimal;
        ConfirmationDate: Date;
        FirstDueAccumulator: Record "Intr- Amort Partial";
        TrsyMgt: Codeunit "Treasury Mgt CU";
}