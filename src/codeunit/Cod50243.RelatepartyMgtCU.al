codeunit 50243 RelatepartyMgtCU
{
    trigger OnRun()
    begin

    end;

    //DEPRECATED
    procedure CalculateInterest()
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestAccIncome: Code[20];
        interestAccReceivable: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry3: Record RelatedLedgerEntry;//Calculate every month
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
        _relatedParty: Record RelatedParty;
        _portfolio: Record "Portfolio RelatedParty";
    begin
        //Interest Rate Type (Fixed/Float)
        //Interest Rate value
        _docNo := TrsyMgt.GenerateDocumentNumber();
        //***Interest Method
        // (Annual Rate / 12) * Principal
        //Funder Ldger Entry
        latestRemainingAmount := 0;
        relatedpartyLoan.Reset();
        relatedpartyLoan.SetFilter(relatedpartyLoan."No.", '<>%1', '');
        relatedpartyLoan.SetFilter(relatedpartyLoan.Status, '=%1', relatedpartyLoan.Status::Approved);
        //relatedpartyLoan.SetFilter("Type of Vendor", '=%1', relatedpartyLoan."Type of Vendor"::Funder);
        if relatedpartyLoan.Find('-') then begin
            repeat
                //Fixed Interest Type
                if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") OR (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then begin
                    relatedpartyLoan.TestField(PlacementDate);
                    // vendor.TestField(InterestMethod);
                    // relatedpartyLoan.TestField(TaxStatus);

                    relatedPartyLegderEntry3.Reset();
                    relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                    relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Interest);
                    _interestComputationTimes := relatedPartyLegderEntry3.Count();

                    // endYearDate := CALCDATE('CY', Today);
                    if _interestComputationTimes = 0 then begin
                        endMonthDate := CALCDATE('CM', Today);
                        remainingDays := endMonthDate - relatedpartyLoan.PlacementDate;
                    end else begin
                        endMonthDate := CALCDATE('CM', Today);
                        remainingDays := Today - endMonthDate;
                    end;


                    // Get Total of Original Amount (Principal)
                    relatedPartyLegderEntry3.Reset();
                    relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                    relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::"Original Amount");
                    relatedPartyLegderEntry3.CalcSums(Amount);
                    _totalOriginalAmount := relatedPartyLegderEntry3.Amount;

                    relatedPartyLegderEntry3.Reset();
                    relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                    relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Repayment);
                    relatedPartyLegderEntry3.CalcSums(Amount);
                    _totalWithdrawalAmount := Abs(relatedPartyLegderEntry3.Amount);

                    _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                    //Monthly interest depending on Interest Method
                    monthlyInterest := 0;
                    _interestRate_Active := TrsyMgt.GetInterestRate(relatedpartyLoan."No.", 'RELATEDPARTY');
                    /*if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") then
                        _interestRate_Active := relatedpartyLoan.InterestRate;
                    if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then
                        _interestRate_Active := (relatedpartyLoan."Reference Rate" + relatedpartyLoan.Margin);
                    if _interestRate_Active = 0 then
                        Error('Interest Rate is Zero');*/

                    _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                    if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"30/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360);
                    end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/360" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360);
                    end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/364" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364);
                    end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/365" then begin
                        monthlyInterest := ((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365);
                    end;

                    //withholding on interest
                    //Depending on Tax Exceptions
                    witHldInterest := 0;
                    if relatedpartyLoan.TaxStatus = relatedpartyLoan.TaxStatus::Taxable then begin
                        relatedpartyLoan.TestField(Withldtax);
                        witHldInterest := (relatedpartyLoan.Withldtax / 100) * monthlyInterest;
                    end;

                    //Get Posting groups
                    // if not venPostingGroup.Get(relatedpartyLoan."Posting Group") then
                    //     Error('Missing Posting Group: %1', relatedparty."No.");


                    interestAccIncome := relatedpartyLoan."Interest Expense";

                    if relatedpartyLoan."Bank Ref. No." = '' then
                        Error('Missing Bank Reference No for Funder Loan', relatedpartyLoan."No.");

                    if interestAccIncome = '' then
                        Error('Missing Expense Interest A/C: %1', relatedparty."No.");
                    principleAcc := relatedpartyLoan."Payables Account";
                    if principleAcc = '' then
                        Error('Missing Principle A/C: %1', relatedparty."No.");
                    interestAccReceivable := relatedpartyLoan."Interest Payable";
                    if interestAccReceivable = '' then
                        Error('Missing Payable Interest A/C: %1', relatedparty."No.");

                    _relatedParty.Reset();
                    _relatedParty.SetRange("No.", relatedpartyLoan."RelatedParty No.");
                    if not _relatedParty.Find('-') then
                        Error('Funder %1 not found _fl', relatedpartyLoan."RelatedParty No.");

                    _portfolio.Reset();
                    _portfolio.SetRange("No.", _relatedParty.Portfolio);
                    if not _portfolio.Find('-') then
                        Error('Portfolio %1 not found _fl', _relatedParty.Portfolio);

                    if not generalSetup.FindFirst() then
                        Error('Please Define Withholding Tax under General Setup');
                    withholdingAcc := generalSetup.FunderWithholdingAcc;
                    //Get the latest remaining amount
                    relatedPartyLegderEntry.SetRange(relatedPartyLegderEntry."Document Type", relatedPartyLegderEntry."Document Type"::"Remaining Amount");
                    if relatedPartyLegderEntry.FindLast() then
                        latestRemainingAmount := relatedPartyLegderEntry."Remaining Amount";

                    //relatedPartyLegderEntry.LockTable();
                    relatedPartyLegderEntry.Reset();
                    if relatedPartyLegderEntry.FindLast() then
                        NextEntryNo := relatedPartyLegderEntry."Entry No." + 1;
                    // else
                    //     NextEntryNo := 2;

                    relatedPartyLegderEntry.Init();
                    relatedPartyLegderEntry."Entry No." := NextEntryNo;
                    relatedPartyLegderEntry."RelatedParty No." := relatedparty."No.";
                    relatedPartyLegderEntry."Related  Name" := relatedparty.Name;
                    relatedPartyLegderEntry."Loan Name" := _loanName;
                    relatedPartyLegderEntry."Loan No." := _loanNo;
                    relatedPartyLegderEntry."Posting Date" := Today;
                    relatedPartyLegderEntry."Document No." := _docNo;
                    relatedPartyLegderEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                    relatedPartyLegderEntry.Category := relatedpartyLoan.Category; // Funder Loan Category
                    relatedPartyLegderEntry."Document Type" := relatedPartyLegderEntry."Document Type"::Interest;
                    relatedPartyLegderEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>'), 1, 100);

                    relatedPartyLegderEntry.Amount := monthlyInterest;
                    relatedPartyLegderEntry."Amount(LCY)" := monthlyInterest;
                    relatedPartyLegderEntry."Interest Payable Amount" := (monthlyInterest - witHldInterest);
                    relatedPartyLegderEntry."Interest Payable Amount (LCY)" := (monthlyInterest - witHldInterest);
                    relatedPartyLegderEntry."Witholding Amount" := (-witHldInterest);
                    relatedPartyLegderEntry."Witholding Amount (LCY)" := (-witHldInterest);

                    relatedPartyLegderEntry."Account No." := interestAccIncome;
                    relatedPartyLegderEntry."Account Type" := relatedPartyLegderEntry."Account Type"::"G/L Account";
                    relatedPartyLegderEntry."Bal. Account No." := interestAccReceivable;
                    relatedPartyLegderEntry."Bal. Account Type" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account";
                    relatedPartyLegderEntry."Bal. Account No. 2" := withholdingAcc; // Wth
                    relatedPartyLegderEntry."Bal. Account Type 2" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account"; //Wth

                    relatedPartyLegderEntry.Insert();
                    if (relatedpartyLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                        DirectGLPosting('interest', interestAccIncome, withholdingAcc, monthlyInterest, witHldInterest, 'Interest', relatedpartyLoan."No.", interestAccReceivable, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");//GROSS Interest
                                                                                                                                                                                                                                                                            //Commit();
                    relatedPartyLegderEntry1.Init();
                    relatedPartyLegderEntry1."Entry No." := NextEntryNo + 1;
                    relatedPartyLegderEntry1."RelatedParty No." := relatedparty."No.";
                    relatedPartyLegderEntry1."Related  Name" := relatedparty.Name;
                    relatedPartyLegderEntry1."Loan Name" := _loanName;
                    relatedPartyLegderEntry1."Loan No." := _loanNo;
                    relatedPartyLegderEntry1."Posting Date" := Today;
                    relatedPartyLegderEntry1."Document No." := _docNo;
                    relatedPartyLegderEntry1."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                    relatedPartyLegderEntry1.Category := relatedpartyLoan.Category; // Funder Loan Category
                    relatedPartyLegderEntry1."Document Type" := relatedPartyLegderEntry."Document Type"::Withholding;
                    relatedPartyLegderEntry1.Description := CopyStr('Withholding calculation ' + Format(Today), 1, 100);
                    relatedPartyLegderEntry1.Amount := -witHldInterest;
                    relatedPartyLegderEntry1."Amount(LCY)" := -witHldInterest;
                    relatedPartyLegderEntry1.Insert();

                    // if (relatedpartyLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                    // DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', relatedpartyLoan."No.", interestAccReceivable, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");
                    //Commit();

                    /*
                    relatedPartyLegderEntry2.Init(); //
                    relatedPartyLegderEntry2."Entry No." := NextEntryNo + 2;
                    relatedPartyLegderEntry2."RelatedParty No." := relatedparty."No.";
                    relatedPartyLegderEntry2."Related  Name" := relatedparty.Name;
                    relatedPartyLegderEntry2."Loan Name" := _loanName;
                    relatedPartyLegderEntry2."Loan No." := _loanNo;
                    relatedPartyLegderEntry2."Document No." := _docNo;
                    relatedPartyLegderEntry2."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                    relatedPartyLegderEntry2.Category := relatedpartyLoan.Category; // Funder Loan Category
                    relatedPartyLegderEntry2."Posting Date" := Today;
                    relatedPartyLegderEntry2."Document Type" := relatedPartyLegderEntry."Document Type"::"Remaining Amount";
                    relatedPartyLegderEntry2.Description := 'Remaining Amount' + Format(Today);
                    relatedPartyLegderEntry2.Amount := ((monthlyInterest - witHldInterest) + relatedpartyLoan.DisbursedCurrency);
                    relatedPartyLegderEntry2."Amount(LCY)" := ((monthlyInterest - witHldInterest) + relatedpartyLoan.DisbursedCurrency);
                    if latestRemainingAmount = 0 then begin
                        relatedPartyLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + relatedpartyLoan.DisbursedCurrency);
                    end
                    else begin
                        relatedPartyLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + latestRemainingAmount);
                    end;
                    relatedPartyLegderEntry2.Insert();
                    */

                    Message('Interest Calculated');
                end else begin
                    Message('Select Interest Rate Type');
                end;
            until relatedpartyLoan.Next() = 0;
            // Message('Interest Calculated');
        end;

    end;


    procedure CalculateInterest(RelatedpartyLoanNo: Code[100])
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestAccIncome: Code[20];
        interestAccReceivable: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry3: Record RelatedLedgerEntry;//Calculate every month
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

        _relatedParty: Record RelatedParty;
        _portfolio: Record "Portfolio RelatedParty";
    begin



        latestRemainingAmount := 0;
        relatedpartyLoan.Reset();
        relatedpartyLoan.SetRange(relatedpartyLoan."No.", RelatedpartyLoanNo);
        //relatedpartyLoan.SetFilter("Type of Vendor", '=%1', relatedpartyLoan."Type of Vendor"::Funder);
        _docNo := TrsyMgt.GenerateDocumentNumber();
        if relatedpartyLoan.Find('-') then begin
            _loanName := relatedpartyLoan."Loan Name";
            _loanNo := relatedpartyLoan."No.";
            relatedpartyLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := relatedpartyLoan.OutstandingAmntDisbLCY;
            if not relatedparty.Get(relatedpartyLoan."RelatedParty No.") then
                Error('Funder %1 not found', relatedpartyLoan."RelatedParty No.");
            // repeat
            if relatedpartyLoan.Status <> relatedpartyLoan.Status::Approved then
                Error('Loan Status is %1', relatedpartyLoan.Status);

            _relatedParty.Reset();
            _relatedParty.SetRange("No.", relatedpartyLoan."RelatedParty No.");
            if not _relatedParty.Find('-') then
                Error('Funder %1 not found _fl', relatedpartyLoan."RelatedParty No.");

            _portfolio.Reset();
            _portfolio.SetRange("No.", _relatedParty.Portfolio);
            if not _portfolio.Find('-') then
                Error('Portfolio %1 not found _fl', _relatedParty.Portfolio);


            relatedPartyLegderEntry3.Reset();
            relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
            relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Loan No.", relatedpartyLoan."No.");
            relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Interest);
            relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Posting Date", CALCDATE('<CM>', Today));
            if relatedPartyLegderEntry3.Find('-') then
                exit;

            //Fixed Interest Type
            if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") OR (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then begin
                relatedpartyLoan.TestField(PlacementDate);
                // vendor.TestField(InterestMethod);
                // relatedpartyLoan.TestField(TaxStatus);

                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Loan No.", relatedpartyLoan."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := relatedPartyLegderEntry3.Count();


                if _interestComputationTimes = 0 then begin
                    // endMonthDate := CALCDATE('<+CM>', Today);
                    // remainingDays := endMonthDate - relatedpartyLoan.PlacementDate + 0;
                    if CALCDATE('<+CM>', Today) = CALCDATE('<+CM>', relatedpartyLoan.PlacementDate) then begin
                        endMonthDate := CALCDATE('<+CM>', Today);
                        remainingDays := endMonthDate - relatedpartyLoan.PlacementDate + 1;
                    end else begin
                        endMonthDate := CALCDATE('<+CM>', Today);
                        remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 1
                    end;
                end else begin
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 1
                    // remainingDays := (endMonthDate - Today) + 1;
                end;


                // Get Total of Original Amount (Principal)
                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetFilter(relatedPartyLegderEntry3."Document Type", '=%1|=%2', relatedPartyLegderEntry2."Document Type"::"Original Amount", relatedPartyLegderEntry2."Document Type"::"Secondary Amount");

                //relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", );
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := relatedPartyLegderEntry3.Amount;

                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Repayment);
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(relatedPartyLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := TrsyMgt.GetInterestRate(relatedpartyLoan."No.", 'RELATEDPARTY');

                if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end
                else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"30/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 365), 0.0001, '=');
                end;


                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if relatedpartyLoan.TaxStatus = relatedpartyLoan.TaxStatus::Taxable then begin
                    relatedpartyLoan.TestField(Withldtax);
                    witHldInterest := (relatedpartyLoan.Withldtax / 100) * monthlyInterest;
                end;

                //Get Posting groups
                // if not venPostingGroup.Get(relatedpartyLoan."Posting Group") then
                //     Error('Missing Posting Group: %1', relatedparty."No.");

                principleAcc := relatedpartyLoan."Payables Account";
                interestAccIncome := relatedpartyLoan."Interest Expense";
                interestAccReceivable := relatedpartyLoan."Interest Payable";
                if relatedpartyLoan."Bank Ref. No." = '' then
                    Error('Missing Bank Reference No for Funder Loan', relatedpartyLoan."No.");

                if interestAccIncome = '' then
                    Error('Missing  Income Interest A/C: %1', relatedparty."No.");
                if principleAcc = '' then
                    Error('Missing Principle A/C: %1', relatedparty."No.");
                if interestAccReceivable = '' then
                    Error('Missing Receivable Interest A/C: %1', relatedparty."No.");

                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.FunderWithholdingAcc;
                if withholdingAcc = '' then
                    Error('Withholding Account Missing under General Setup');

                //Get the latest remaining amount
                relatedPartyLegderEntry.SetRange(relatedPartyLegderEntry."Document Type", relatedPartyLegderEntry."Document Type"::"Remaining Amount");
                if relatedPartyLegderEntry.FindLast() then
                    latestRemainingAmount := relatedPartyLegderEntry."Remaining Amount";

                //relatedPartyLegderEntry.LockTable();
                relatedPartyLegderEntry.Reset();
                if relatedPartyLegderEntry.FindLast() then
                    NextEntryNo := relatedPartyLegderEntry."Entry No." + 1;
                // else
                //     NextEntryNo := 2;

                relatedPartyLegderEntry.Init();
                relatedPartyLegderEntry."Entry No." := NextEntryNo;
                relatedPartyLegderEntry."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry."Loan Name" := _loanName;
                relatedPartyLegderEntry."Loan No." := _loanNo;
                relatedPartyLegderEntry."Posting Date" := CALCDATE('<CM>', Today);
                relatedPartyLegderEntry."Document Date" := Today;
                relatedPartyLegderEntry."Document No." := _docNo;
                relatedPartyLegderEntry."External Document No." := _docNo + ' Interest ' + Format(Today, 0, '<Month Text> <Year4>');
                relatedPartyLegderEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                relatedPartyLegderEntry.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry."Document Type" := relatedPartyLegderEntry."Document Type"::Interest;
                relatedPartyLegderEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + ' - ' + Format(Today, 0, '<Month Text> <Year4>'), 1, 100);

                relatedPartyLegderEntry.Amount := monthlyInterest;
                relatedPartyLegderEntry."Amount(LCY)" := monthlyInterest;
                relatedPartyLegderEntry."Interest Payable Amount" := (monthlyInterest - witHldInterest);
                relatedPartyLegderEntry."Interest Payable Amount (LCY)" := (monthlyInterest - witHldInterest);
                relatedPartyLegderEntry."Witholding Amount" := (-witHldInterest);
                relatedPartyLegderEntry."Witholding Amount (LCY)" := (-witHldInterest);

                relatedPartyLegderEntry."Account No." := interestAccIncome;
                relatedPartyLegderEntry."Account Type" := relatedPartyLegderEntry."Account Type"::"G/L Account";
                relatedPartyLegderEntry."Bal. Account No." := interestAccReceivable;
                relatedPartyLegderEntry."Bal. Account Type" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account";
                relatedPartyLegderEntry."Bal. Account No. 2" := withholdingAcc; // Wth
                relatedPartyLegderEntry."Bal. Account Type 2" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account"; //Wth


                relatedPartyLegderEntry.Insert();
                if (relatedpartyLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestAccIncome, withholdingAcc, monthlyInterest, witHldInterest, 'Interest', relatedpartyLoan."No.", interestAccReceivable, relatedpartyLoan.Currency, '', '', relatedPartyLegderEntry."External Document No.", _relatedParty."Shortcut Dimension 1 Code");//GROSS Interest
                                                                                                                                                                                                                                                                                                              //Commit();
                relatedPartyLegderEntry1.Init();
                relatedPartyLegderEntry1."Entry No." := NextEntryNo + 1;
                relatedPartyLegderEntry1."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry1."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry1."Loan Name" := _loanName;
                relatedPartyLegderEntry1."Loan No." := _loanNo;
                relatedPartyLegderEntry1."Document Type" := relatedPartyLegderEntry."Document Type"::Withholding;
                relatedPartyLegderEntry1."Posting Date" := CALCDATE('<CM>', Today);
                relatedPartyLegderEntry1."Document Date" := Today;
                relatedPartyLegderEntry1.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry1."Document No." := _docNo;
                relatedPartyLegderEntry1."External Document No." := _docNo + ' Withhlding ' + Format(Today, 0, '<Month Text> <Year4>');
                relatedPartyLegderEntry1."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                relatedPartyLegderEntry1.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + ' - ' + relatedpartyLoan."Bank Ref. No." + ' - ' + Format(Today, 0, '<Month Text> <Year4>') + ' Withholding Calculation', 1, 100);
                relatedPartyLegderEntry1.Amount := -witHldInterest;
                relatedPartyLegderEntry1."Amount(LCY)" := -witHldInterest;

                relatedPartyLegderEntry1."Bal. Account No." := withholdingAcc;
                relatedPartyLegderEntry1."Bal. Account Type" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account";
                relatedPartyLegderEntry1."Account No." := interestAccReceivable;
                relatedPartyLegderEntry1."Account Type" := relatedPartyLegderEntry."Account Type"::"G/L Account";

                relatedPartyLegderEntry1.Insert();

                // if (relatedpartyLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                // DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', relatedpartyLoan."No.", interestAccReceivable, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");

                /*
                relatedPartyLegderEntry2.Init(); //
                relatedPartyLegderEntry2."Entry No." := NextEntryNo + 2;
                relatedPartyLegderEntry2."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry2."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry2."Loan Name" := _loanName;
                relatedPartyLegderEntry2."Loan No." := _loanNo;
                relatedPartyLegderEntry2."Document No." := _docNo;
                relatedPartyLegderEntry2.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry2."Posting Date" := Today;
                relatedPartyLegderEntry2."Document Type" := relatedPartyLegderEntry."Document Type"::"Remaining Amount";
                relatedPartyLegderEntry2.Description := 'Remaining Amount' + Format(Today);
                relatedPartyLegderEntry2.Amount := ((monthlyInterest - witHldInterest) + relatedpartyLoan.DisbursedCurrency);
                relatedPartyLegderEntry2."Amount(LCY)" := ((monthlyInterest - witHldInterest) + relatedpartyLoan.DisbursedCurrency);
                if latestRemainingAmount = 0 then begin
                    relatedPartyLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + relatedpartyLoan.DisbursedCurrency);
                end
                else begin
                    relatedPartyLegderEntry2."Remaining Amount" := ((monthlyInterest - witHldInterest) + latestRemainingAmount);
                end;
                relatedPartyLegderEntry2.Insert();*/


                Message('Interest Calculated');
            end else begin
                Message('Select Interest Rate Type');
            end;
            // until relatedpartyLoan.Next() = 0;

        end;

    end;

    procedure CalculateInterest(RelatedpartyLoanNo: Code[100]; RedemptionDate: Date; PayingBankCode: Code[50])
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestAccIncome: Code[20];
        interestAccReceivable: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry3: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry4: Record RelatedLedgerEntry;//Calculate every month
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

        _relatedParty: Record RelatedParty;
        _portfolio: Record "Portfolio RelatedParty";
        GenSetup: Record "Treasury General Setup";
    begin
        //Interest Rate Type (Fixed/Float)
        //Interest Rate value
        //***Interest Method
        // (Annual Rate / 12) * Principal
        //Funder Ldger Entry
        GenSetup.get();
        latestRemainingAmount := 0;
        relatedpartyLoan.Reset();
        relatedpartyLoan.SetRange(relatedpartyLoan."No.", RelatedpartyLoanNo);
        //relatedpartyLoan.SetFilter("Type of Vendor", '=%1', relatedpartyLoan."Type of Vendor"::Funder);
        _docNo := TrsyMgt.GenerateDocumentNumber();
        if relatedpartyLoan.Find('-') then begin
            _loanName := relatedpartyLoan."Loan Name";
            _loanNo := relatedpartyLoan."No.";
            relatedpartyLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := relatedpartyLoan.OutstandingAmntDisbLCY;
            if not relatedparty.Get(relatedpartyLoan."RelatedParty No.") then
                Error('Funder %1 not found', relatedpartyLoan."RelatedParty No.");
            // repeat
            if relatedpartyLoan.Status <> relatedpartyLoan.Status::Approved then
                Error('Loan Status is %1', relatedpartyLoan.Status);

            _relatedParty.Reset();
            _relatedParty.SetRange("No.", relatedpartyLoan."RelatedParty No.");
            if not _relatedParty.Find('-') then
                Error('Funder %1 not found _fl', relatedpartyLoan."RelatedParty No.");

            _portfolio.Reset();
            _portfolio.SetRange("No.", _relatedParty.Portfolio);
            if not _portfolio.Find('-') then
                Error('Portfolio %1 not found _fl', _relatedParty.Portfolio);

            //Fixed Interest Type
            if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") OR (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then begin
                relatedpartyLoan.TestField(PlacementDate);


                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Loan No.", relatedpartyLoan."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := relatedPartyLegderEntry3.Count();


                if _interestComputationTimes = 0 then begin // Check for first operation
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := endMonthDate - relatedpartyLoan.PlacementDate + 0;
                end else begin
                    startMonthDate := CALCDATE('<-CM>', Today);
                    remainingDays := RedemptionDate - startMonthDate + 0;
                    // remainingDays := CALCDATE('<CM>', RedemptionDate) - CALCDATE('<-CM>', RedemptionDate) + 1;// No of Days in that Month
                end;


                // Get Total of Original Amount (Principal)
                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetFilter(relatedPartyLegderEntry3."Document Type", '=%1|=%2', relatedPartyLegderEntry2."Document Type"::"Original Amount", relatedPartyLegderEntry2."Document Type"::"Secondary Amount");
                //relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::"Secondary Amount");
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := relatedPartyLegderEntry3.Amount;

                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Repayment);
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(relatedPartyLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := TrsyMgt.GetInterestRate(relatedpartyLoan."No.", 'RELATEDPARTY');


                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if relatedpartyLoan.TaxStatus = relatedpartyLoan.TaxStatus::Taxable then begin
                    relatedpartyLoan.TestField(Withldtax);
                    witHldInterest := (relatedpartyLoan.Withldtax / 100) * monthlyInterest;
                end;

                //Get Posting groups
                // if not venPostingGroup.Get(relatedpartyLoan."Posting Group") then
                //     Error('Missing Posting Group: %1', relatedparty."No.");

                principleAcc := relatedpartyLoan."Payables Account";
                interestAccIncome := relatedpartyLoan."Interest Expense";
                interestAccReceivable := relatedpartyLoan."Interest Payable";
                if relatedpartyLoan."Bank Ref. No." = '' then
                    Error('Missing Bank Reference No for Funder Loan', relatedpartyLoan."No.");

                if interestAccIncome = '' then
                    Error('Missing Expense Interest A/C: %1', relatedparty."No.");
                if principleAcc = '' then
                    Error('Missing Principle A/C: %1', relatedparty."No.");
                if interestAccReceivable = '' then
                    Error('Missing Payable Interest A/C: %1', relatedparty."No.");

                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.FunderWithholdingAcc;
                if withholdingAcc = '' then
                    Error('Withholding Account Missing under General Setup');

                //Get the latest remaining amount
                relatedPartyLegderEntry.SetRange(relatedPartyLegderEntry."Document Type", relatedPartyLegderEntry."Document Type"::"Remaining Amount");
                if relatedPartyLegderEntry.FindLast() then
                    latestRemainingAmount := relatedPartyLegderEntry."Remaining Amount";

                relatedPartyLegderEntry.LockTable();
                relatedPartyLegderEntry.Reset();
                if relatedPartyLegderEntry.FindLast() then
                    NextEntryNo := relatedPartyLegderEntry."Entry No." + 1;
                // else
                //     NextEntryNo := 2;

                relatedPartyLegderEntry.Init();
                relatedPartyLegderEntry."Entry No." := NextEntryNo;
                relatedPartyLegderEntry."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry."Loan Name" := _loanName;
                relatedPartyLegderEntry."Loan No." := _loanNo;
                relatedPartyLegderEntry."Posting Date" := RedemptionDate;
                relatedPartyLegderEntry."Document No." := _docNo;
                relatedPartyLegderEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                relatedPartyLegderEntry.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry."Document Type" := relatedPartyLegderEntry."Document Type"::Interest;
                relatedPartyLegderEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>'), 1, 100);

                relatedPartyLegderEntry.Amount := monthlyInterest;
                relatedPartyLegderEntry."Amount(LCY)" := monthlyInterest;
                // relatedPartyLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                relatedPartyLegderEntry."Interest Payable Amount" := (monthlyInterest - witHldInterest);
                relatedPartyLegderEntry."Interest Payable Amount (LCY)" := (monthlyInterest - witHldInterest);
                relatedPartyLegderEntry."Witholding Amount" := (-witHldInterest);
                relatedPartyLegderEntry."Witholding Amount (LCY)" := (-witHldInterest);

                relatedPartyLegderEntry."Account No." := interestAccIncome;
                relatedPartyLegderEntry."Account Type" := relatedPartyLegderEntry."Account Type"::"G/L Account";
                relatedPartyLegderEntry."Bal. Account No." := interestAccReceivable;
                relatedPartyLegderEntry."Bal. Account Type" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account";
                relatedPartyLegderEntry."Bal. Account No. 2" := withholdingAcc; // Wth
                relatedPartyLegderEntry."Bal. Account Type 2" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account"; //Wth

                relatedPartyLegderEntry.Insert();
                if (relatedpartyLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestAccIncome, withholdingAcc, monthlyInterest, witHldInterest, 'Interest', relatedpartyLoan."No.", interestAccReceivable, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");//GROSS Interest
                                                                                                                                                                                                                                                                        //Commit();
                relatedPartyLegderEntry1.Init();
                relatedPartyLegderEntry1."Entry No." := NextEntryNo + 1;
                relatedPartyLegderEntry1."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry1."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry1."Loan Name" := _loanName;
                relatedPartyLegderEntry1."Loan No." := _loanNo;
                relatedPartyLegderEntry1."Document Type" := relatedPartyLegderEntry."Document Type"::Withholding;
                relatedPartyLegderEntry1."Posting Date" := RedemptionDate;
                relatedPartyLegderEntry1.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry1."Document No." := _docNo;
                relatedPartyLegderEntry1."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                relatedPartyLegderEntry1.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + 'Withholding calculation Redemption' + Format(RedemptionDate), 1, 100);
                relatedPartyLegderEntry1.Amount := -witHldInterest;
                relatedPartyLegderEntry1."Amount(LCY)" := -witHldInterest;
                relatedPartyLegderEntry1."Bal. Account No. 2" := withholdingAcc; // Wth
                relatedPartyLegderEntry1."Bal. Account Type 2" := relatedPartyLegderEntry1."Bal. Account Type"::"G/L Account"; //Wth

                relatedPartyLegderEntry1.Insert();
                // if (relatedpartyLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                // DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', relatedpartyLoan."No.", interestAccReceivable, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");
                //Commit();

                //Remove/Deduct from the Principal Amount
                relatedPartyLegderEntry3.Init();
                relatedPartyLegderEntry3."Entry No." := NextEntryNo + 2;
                relatedPartyLegderEntry3."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry3."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry3."Loan Name" := _loanName;
                relatedPartyLegderEntry3."Loan No." := _loanNo;
                relatedPartyLegderEntry3."Document Type" := relatedPartyLegderEntry."Document Type"::Repayment;
                relatedPartyLegderEntry3."Posting Date" := RedemptionDate;
                relatedPartyLegderEntry3.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry3."Document No." := _docNo;
                relatedPartyLegderEntry3."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                relatedPartyLegderEntry3.Description := CopyStr('Redemption Repayment calculation' + Format(RedemptionDate), 1, 100);
                relatedPartyLegderEntry3.Amount := -_differenceOriginalWithdrawal;
                relatedPartyLegderEntry3."Amount(LCY)" := -_differenceOriginalWithdrawal;

                relatedPartyLegderEntry3."Account No." := principleAcc;
                relatedPartyLegderEntry3."Account Type" := relatedPartyLegderEntry3."Account Type"::"G/L Account";
                relatedPartyLegderEntry3."Bal. Account No." := PayingBankCode;
                relatedPartyLegderEntry3."Bal. Account Type" := relatedPartyLegderEntry3."Bal. Account Type"::"Bank Account";


                relatedPartyLegderEntry3.Insert();
                if (relatedpartyLoan.EnableGLPosting = true) and (_differenceOriginalWithdrawal <> 0) then
                    DirectGLPosting('redemption', principleAcc, withholdingAcc, _differenceOriginalWithdrawal, 0, 'Redemption Repayment', relatedpartyLoan."No.", PayingBankCode, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code"); // Debit Paying Bank

                Message('Interest Calculated (non-partial)');
            end else begin
                Message('Select Interest Rate Type');
            end;
            // until relatedpartyLoan.Next() = 0;

        end;

    end;

    procedure CalculateInterestForPartial(RelatedpartyLoanNo: Code[100]; RedemptionDate: Date; PayingBankCode: Code[50])
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestAccIncome: Code[20];
        interestAccReceivable: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry3: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry4: Record RelatedLedgerEntry;//Calculate every month
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

        _relatedParty: Record RelatedParty;
        _portfolio: Record "Portfolio RelatedParty";
        GenSetup: Record "Treasury General Setup";
    begin
        //Interest Rate Type (Fixed/Float)
        //Interest Rate value
        //***Interest Method
        // (Annual Rate / 12) * Principal
        //Funder Ldger Entry
        GenSetup.Get();
        latestRemainingAmount := 0;
        relatedpartyLoan.Reset();
        relatedpartyLoan.SetRange(relatedpartyLoan."No.", RelatedpartyLoanNo);
        //relatedpartyLoan.SetFilter("Type of Vendor", '=%1', relatedpartyLoan."Type of Vendor"::Funder);
        _docNo := TrsyMgt.GenerateDocumentNumber();
        if relatedpartyLoan.Find('-') then begin
            _loanName := relatedpartyLoan."Loan Name";
            _loanNo := relatedpartyLoan."No.";
            relatedpartyLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := relatedpartyLoan.OutstandingAmntDisbLCY;
            if not relatedparty.Get(relatedpartyLoan."RelatedParty No.") then
                Error('Funder %1 not found', relatedpartyLoan."RelatedParty No.");
            // repeat
            if relatedpartyLoan.Status <> relatedpartyLoan.Status::Approved then
                Error('Loan Status is %1', relatedpartyLoan.Status);


            _relatedParty.Reset();
            _relatedParty.SetRange("No.", relatedpartyLoan."RelatedParty No.");
            if not _relatedParty.Find('-') then
                Error('Funder %1 not found _fl', relatedpartyLoan."RelatedParty No.");

            _portfolio.Reset();
            _portfolio.SetRange("No.", _relatedParty.Portfolio);
            if not _portfolio.Find('-') then
                Error('Portfolio %1 not found _fl', _relatedParty.Portfolio);

            //Fixed Interest Type
            if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") OR (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then begin
                relatedpartyLoan.TestField(PlacementDate);
                // vendor.TestField(InterestMethod);
                // relatedpartyLoan.TestField(TaxStatus);

                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Loan No.", relatedpartyLoan."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := relatedPartyLegderEntry3.Count();

                // endYearDate := CALCDATE('CY', Today);
                if _interestComputationTimes = 0 then begin // Check for first operation
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := endMonthDate - relatedpartyLoan.PlacementDate + 1;
                end else begin
                    startMonthDate := CALCDATE('<-CM>', Today);
                    remainingDays := RedemptionDate - startMonthDate + 1;
                    // remainingDays := CALCDATE('<CM>', RedemptionDate) - CALCDATE('<-CM>', RedemptionDate) + 1;// No of Days in that Month
                end;


                // Get Total of Original Amount (Principal)
                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::"Original Amount");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::"Secondary Amount");
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := relatedPartyLegderEntry3.Amount;

                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Repayment);
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(relatedPartyLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := TrsyMgt.GetInterestRate(relatedpartyLoan."No.", 'RELATEDPARTY');
                /*if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := relatedpartyLoan.InterestRate;
                if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (relatedpartyLoan."Reference Rate" + relatedpartyLoan.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');*/

                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if relatedpartyLoan.TaxStatus = relatedpartyLoan.TaxStatus::Taxable then begin
                    relatedpartyLoan.TestField(Withldtax);
                    witHldInterest := (relatedpartyLoan.Withldtax / 100) * monthlyInterest;
                end;

                //Get Posting groups
                // if not venPostingGroup.Get(relatedpartyLoan."Posting Group") then
                //     Error('Missing Posting Group: %1', relatedparty."No.");

                principleAcc := relatedpartyLoan."Payables Account";
                interestAccIncome := relatedpartyLoan."Interest Expense";
                interestAccReceivable := relatedpartyLoan."Interest Payable";
                if relatedpartyLoan."Bank Ref. No." = '' then
                    Error('Missing Bank Reference No for Funder Loan', relatedpartyLoan."No.");

                if interestAccIncome = '' then
                    Error('Missing Expense Interest A/C: %1', relatedparty."No.");
                if principleAcc = '' then
                    Error('Missing Principle A/C: %1', relatedparty."No.");
                if interestAccReceivable = '' then
                    Error('Missing Payable Interest A/C: %1', relatedparty."No.");

                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.FunderWithholdingAcc;
                if withholdingAcc = '' then
                    Error('Withholding Account Missing under General Setup');

                //Get the latest remaining amount
                relatedPartyLegderEntry.SetRange(relatedPartyLegderEntry."Document Type", relatedPartyLegderEntry."Document Type"::"Remaining Amount");
                if relatedPartyLegderEntry.FindLast() then
                    latestRemainingAmount := relatedPartyLegderEntry."Remaining Amount";

                //relatedPartyLegderEntry.LockTable();
                relatedPartyLegderEntry.Reset();
                if relatedPartyLegderEntry.FindLast() then
                    NextEntryNo := relatedPartyLegderEntry."Entry No." + 1;
                // else
                //     NextEntryNo := 2;

                relatedPartyLegderEntry.Init();
                relatedPartyLegderEntry."Entry No." := NextEntryNo;
                relatedPartyLegderEntry."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry."Loan Name" := _loanName;
                relatedPartyLegderEntry."Loan No." := _loanNo;
                relatedPartyLegderEntry."Posting Date" := RedemptionDate;
                relatedPartyLegderEntry."Document Type" := relatedPartyLegderEntry."Document Type"::Interest;
                relatedPartyLegderEntry."Document No." := _docNo;
                relatedPartyLegderEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                relatedPartyLegderEntry.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4> Partial Redemtion Intre. Calc'), 1, 100);


                relatedPartyLegderEntry.Amount := monthlyInterest;
                relatedPartyLegderEntry."Amount(LCY)" := monthlyInterest;
                relatedPartyLegderEntry."Interest Payable Amount" := (monthlyInterest - witHldInterest);
                relatedPartyLegderEntry."Interest Payable Amount (LCY)" := (monthlyInterest - witHldInterest);
                relatedPartyLegderEntry."Witholding Amount" := (-witHldInterest);
                relatedPartyLegderEntry."Witholding Amount (LCY)" := (-witHldInterest);

                relatedPartyLegderEntry."Account No." := interestAccIncome;
                relatedPartyLegderEntry."Account Type" := relatedPartyLegderEntry."Account Type"::"G/L Account";
                relatedPartyLegderEntry."Bal. Account No." := interestAccReceivable;
                relatedPartyLegderEntry."Bal. Account Type" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account";
                relatedPartyLegderEntry."Bal. Account No. 2" := withholdingAcc; // Wth
                relatedPartyLegderEntry."Bal. Account Type 2" := relatedPartyLegderEntry."Bal. Account Type"::"G/L Account"; //Wth


                relatedPartyLegderEntry.Insert();
                if (relatedpartyLoan.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestAccIncome, withholdingAcc, monthlyInterest, witHldInterest, 'Interest', relatedpartyLoan."No.", interestAccReceivable, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");

                relatedPartyLegderEntry1.Init();
                relatedPartyLegderEntry1."Entry No." := NextEntryNo + 1;
                relatedPartyLegderEntry1."RelatedParty No." := relatedparty."No.";
                relatedPartyLegderEntry1."Related  Name" := relatedparty.Name;
                relatedPartyLegderEntry1."Loan Name" := _loanName;
                relatedPartyLegderEntry1."Loan No." := _loanNo;
                relatedPartyLegderEntry1."Posting Date" := RedemptionDate;
                relatedPartyLegderEntry1.Category := relatedpartyLoan.Category; // Funder Loan Category
                relatedPartyLegderEntry1."Document Type" := relatedPartyLegderEntry."Document Type"::Withholding;
                relatedPartyLegderEntry1."Document No." := _docNo;
                relatedPartyLegderEntry1."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                relatedPartyLegderEntry1.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4> Partial Redemtion Withholding Calc'), 1, 100);
                relatedPartyLegderEntry1.Amount := -witHldInterest;
                relatedPartyLegderEntry1."Amount(LCY)" := -witHldInterest;
                relatedPartyLegderEntry1.Insert();
                // if (relatedpartyLoan.EnableGLPosting = true) and (witHldInterest <> 0) then
                //     DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', relatedpartyLoan."No.", interestAccReceivable, '', '', '', relatedpartyLoan."Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");



                Message('Interest  Calculated (partial)');
            end else begin
                Message('Select Interest Rate Type');
            end;
            // until relatedpartyLoan.Next() = 0;

        end;

    end;

    procedure CalculateFloatInterest(RelatedpartyLoanNo: Code[100]; RedemptionDate: Date): Decimal
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestAccIncome: Code[20];
        interestAccReceivable: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry3: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry4: Record RelatedLedgerEntry;//Calculate every month
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

        _relatedParty: Record RelatedParty;
        _portfolio: Record "Portfolio RelatedParty";
    begin

        latestRemainingAmount := 0;
        relatedpartyLoan.Reset();
        relatedpartyLoan.SetRange(relatedpartyLoan."No.", RelatedpartyLoanNo);
        if relatedpartyLoan.Find('-') then begin
            _loanName := relatedpartyLoan."Loan Name";
            _loanNo := relatedpartyLoan."No.";
            relatedpartyLoan.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := relatedpartyLoan.OutstandingAmntDisbLCY;
            if not relatedparty.Get(relatedpartyLoan."RelatedParty No.") then
                Error('Funder %1 not found', relatedpartyLoan."RelatedParty No.");
            // repeat
            if relatedpartyLoan.Status <> relatedpartyLoan.Status::Approved then
                Error('Loan Status is %1', relatedpartyLoan.Status);

            _relatedParty.Reset();
            _relatedParty.SetRange("No.", relatedpartyLoan."RelatedParty No.");
            if not _relatedParty.Find('-') then
                Error('Funder %1 not found _fl', relatedpartyLoan."RelatedParty No.");

            _portfolio.Reset();
            _portfolio.SetRange("No.", _relatedParty.Portfolio);
            if not _portfolio.Find('-') then
                Error('Portfolio %1 not found _fl', _relatedParty.Portfolio);

            //Fixed Interest Type
            if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") OR (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then begin
                relatedpartyLoan.TestField(PlacementDate);

                //Check whether intrest has been calculated for this loan
                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Loan No.", relatedpartyLoan."No.");
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Interest);
                _interestComputationTimes := relatedPartyLegderEntry3.Count();

                // If its the first interest accrual, calculate to, the redemption date.
                if _interestComputationTimes = 0 then begin // Check for first operation
                    endMonthDate := CALCDATE('<+CM>', Today);
                    remainingDays := RedemptionDate - relatedpartyLoan.PlacementDate + 0;
                end else begin
                    startMonthDate := CALCDATE('<-CM>', Today);
                    remainingDays := RedemptionDate - startMonthDate + 0;
                    // remainingDays := CALCDATE('<CM>', RedemptionDate) - CALCDATE('<-CM>', RedemptionDate) + 1;// No of Days in that Month
                end;


                // Get Total of Original Amount (Principal)
                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetFilter(relatedPartyLegderEntry3."Document Type", '=%1|=%2', relatedPartyLegderEntry2."Document Type"::"Original Amount", relatedPartyLegderEntry2."Document Type"::"Secondary Amount");
                // relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::"Secondary Amount");
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := relatedPartyLegderEntry3.Amount;

                relatedPartyLegderEntry3.Reset();
                relatedPartyLegderEntry3.SetRange("RelatedParty No.", relatedparty."No.");
                relatedPartyLegderEntry3.SetRange("Loan No.", RelatedpartyLoanNo);
                relatedPartyLegderEntry3.SetRange(relatedPartyLegderEntry3."Document Type", relatedPartyLegderEntry2."Document Type"::Repayment);
                relatedPartyLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(relatedPartyLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := TrsyMgt.GetInterestRate(relatedpartyLoan."No.", 'RELATEDPARTY');


                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if relatedpartyLoan.InterestMethod = relatedpartyLoan.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if relatedpartyLoan.TaxStatus = relatedpartyLoan.TaxStatus::Taxable then begin
                    relatedpartyLoan.TestField(Withldtax);
                    witHldInterest := (relatedpartyLoan.Withldtax / 100) * monthlyInterest;
                end;

                exit(monthlyInterest - witHldInterest);
            end;

        end;

    end;


    procedure DirectGLPosting(Origin: Text[100]; GLAcc: Code[100]; WthholdingAc: Code[20]; Amount: Decimal; WthholdingAmount: Decimal; Desc: Text[100]; RelatedpartyLoanNo: Code[20]; BankAc: Code[100]; Currency: Code[20]; PostingGroup: Code[50]; DocNo: Code[20]; ExtDocNo: text[250]; ShortcutDim1: Code[20])
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";

        withholdingAcc: Code[20];
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        venPostingGroup: Record "Treasury Posting Group";
        relatedpartyLoan: Record "RelatedParty Loan";

        _ConvertedCurrency: Decimal;

        _relatedParty: Record RelatedParty;
        _portfolio: Record "Portfolio RelatedParty";
    begin
        JournalEntry.LockTable();
        if JournalEntry.FindLast() then
            NextEntryNo := JournalEntry."Line No." + 1
        else
            NextEntryNo := 1;

        relatedpartyLoan.Reset();
        relatedpartyLoan.SetRange("No.", RelatedpartyLoanNo);
        if not relatedpartyLoan.Find('-') then
            Error('Funder Loan %1 not found', RelatedpartyLoanNo);

        _relatedParty.Reset();
        _relatedParty.SetRange("No.", relatedpartyLoan."RelatedParty No.");
        if not _relatedParty.Find('-') then
            Error('Funder %1 not found _fl', relatedpartyLoan."RelatedParty No.");

        _portfolio.Reset();
        _portfolio.SetRange("No.", _relatedParty.Portfolio);
        if not _portfolio.Find('-') then
            Error('Portfolio %1 not found _fl', _relatedParty.Portfolio);

        if not generalSetup.FindFirst() then
            Error('Please Define Withholding Tax under General Setup');
        withholdingAcc := generalSetup.FunderWithholdingAcc;
        if Currency <> '' then
            _ConvertedCurrency := ConvertCurrencyAmount(Currency, Amount, relatedpartyLoan.CustomFX)
        else
            _ConvertedCurrency := Amount;

        if (Origin = 'init') then begin
            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo;
            JournalEntry.Entry_ID := NextEntryNo;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Original Principal', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := (Round(Amount, 0.01, '='));
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"Bank Account";
            JournalEntry."Bal. Account No." := BankAc;
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);

        end;
        if (Origin = 'interest') then begin

            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo;
            JournalEntry.Entry_ID := NextEntryNo;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Interest Accrual _Intr. Expens', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := BankAc; // Inter. Receivable Acc
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);

            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo + 1;
            JournalEntry.Entry_ID := NextEntryNo + 1;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Interest Accrual _Intr. Payable', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc; // Interest Income.
            JournalEntry.Amount := -(Round(Amount, 0.01, '=') - Round(WthholdingAmount, 0.01, '='));
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);

            if WthholdingAmount > 0 then begin
                JournalEntry.Init();
                JournalEntry."Journal Template Name" := 'GENERAL';
                JournalEntry."Journal Batch Name" := 'TREASURY';
                JournalEntry."Line No." := NextEntryNo + 2;
                JournalEntry.Entry_ID := NextEntryNo + 2;
                JournalEntry."External Document No." := ExtDocNo;
                JournalEntry."Posting Date" := Today;
                JournalEntry.Creation_Date := Today;
                JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
                JournalEntry.Validate("Shortcut Dimension 1 Code");
                if DocNo <> '' then
                    JournalEntry."Document No." := DocNo
                else
                    JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
                JournalEntry."Currency Code" := Currency;
                JournalEntry.Validate("Currency Code");

                JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Interest Accrual _Wtholding', 1, 100);
                JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
                JournalEntry."Account No." := withholdingAcc;
                JournalEntry.Amount := -Round(WthholdingAmount, 0.01, '=');
                JournalEntry.Validate(Amount);
                if JournalEntry.Amount <> 0 then
                    GLPost.RunWithCheck(JournalEntry);
            end;

        end;
        if (Origin = 'reverse-interest') then begin

            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo;
            JournalEntry.Entry_ID := NextEntryNo;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Interest Reversal _Intr. Expens', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc; // Intr. Expen Ac
            JournalEntry.Amount := -Round(Amount, 0.01, '=');
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);

            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo + 1;
            JournalEntry.Entry_ID := NextEntryNo + 1;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Reverse Intr _Intr. Payab', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := BankAc; // Interest Payable.
            JournalEntry.Amount := (Round(Amount, 0.01, '=') - Round(WthholdingAmount, 0.01, '='));
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);

            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo + 2;
            JournalEntry.Entry_ID := NextEntryNo + 2;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Reverse Intr. Witholding', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := withholdingAcc;
            JournalEntry.Amount := Round(WthholdingAmount, 0.01, '=');
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);
        end;

        if (Origin = 'interest-payment') then begin
            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo;
            JournalEntry.Entry_ID := NextEntryNo;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Interest Payment', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"Bank Account";
            JournalEntry."Bal. Account No." := BankAc;
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);

        end;
        if Origin = 'redemption' then begin
            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo;
            JournalEntry.Entry_ID := NextEntryNo;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Full Principal Redemption', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"Bank Account";
            JournalEntry."Bal. Account No." := BankAc;
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);
        end;
        if Origin = 'partial-redemption' then begin
            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo;
            JournalEntry.Entry_ID := NextEntryNo;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Partial Principal Redemption', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"Bank Account";
            JournalEntry."Bal. Account No." := BankAc;
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);
        end;
        if Origin = 'tranch-fee' then begin
            JournalEntry.Init();
            JournalEntry."Journal Template Name" := 'GENERAL';
            JournalEntry."Journal Batch Name" := 'TREASURY';
            JournalEntry."Line No." := NextEntryNo;
            JournalEntry.Entry_ID := NextEntryNo;
            JournalEntry."External Document No." := ExtDocNo;
            JournalEntry."Posting Date" := Today;
            JournalEntry.Creation_Date := Today;
            JournalEntry."Shortcut Dimension 1 Code" := ShortcutDim1;
            JournalEntry.Validate("Shortcut Dimension 1 Code");
            if DocNo <> '' then
                JournalEntry."Document No." := DocNo
            else
                JournalEntry."Document No." := RelatedpartyLoanNo + Format(Today);
            JournalEntry."Currency Code" := Currency;
            JournalEntry.Validate("Currency Code");

            JournalEntry.Description := CopyStr(relatedpartyLoan."No." + ' ' + relatedpartyLoan.Name + ' ' + _portfolio.Code + '-' + relatedpartyLoan."Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>') + ' :Tranch fee', 1, 100);
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Bal. Account Type"::"Bank Account";
            JournalEntry."Bal. Account No." := BankAc;
            JournalEntry.Validate(Amount);
            if JournalEntry.Amount <> 0 then
                GLPost.RunWithCheck(JournalEntry);
        end;



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

    procedure PartialRedemptionDuplicateRecord(SourceRecordID: Code[20]): Code[20]
    var
        SourceRecord: Record "RelatedParty Loan";
        NewRecord: Record "RelatedParty Loan";
        NewRecord1: Record "RelatedParty Loan";
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry3: Record RelatedLedgerEntry;//Calculate every month
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
            Error('Relatedparty Loan not found.');

        if SourceRecord.Status <> SourceRecord.Status::Approved then
            Error('Record Not Approved');
        if SourceRecord."Bank Ref. No." = '' then
            Error('Missing Bank Reference No for Funder Loan', relatedpartyLoan."No.");


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
        SourceRecord: Record "RelatedParty Loan";
        NewRecord: Record "RelatedParty Loan";
        NewRecord1: Record "RelatedParty Loan";
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedPartyLegderEntry3: Record RelatedLedgerEntry;//Calculate every month
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
            Error('Relatedparty Loan not found.');

        if SourceRecord.Status <> SourceRecord.Status::Approved then
            Error('Record Not Approved');
        if SourceRecord."Bank Ref. No." = '' then
            Error('Missing Bank Reference No for Relatedparty Loan', relatedpartyLoan."No.");


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
        relatedpartyLoan: Record "RelatedParty Loan";

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


    //IC Operations
    procedure GenerateICSalesInvoice()
    var
        RelatedSelectedLoans: Record "Relatedparty Sales Inv Rec.";
        RelatedLoansTbl: Record "RelatedParty Loan";
        SalesInvoiceHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Line";
        AccruedInterestAmount: Decimal;
        Looper: Integer;
        Customer: Record Customer;
        SalesPost: Codeunit "Sales-Post";
        IsHandled: Boolean;
        GLAccount: Record "G/L Account";
    begin
        Looper := 1000;
        RelatedSelectedLoans.Reset();
        RelatedSelectedLoans.SetRange(Processed, false);
        if RelatedSelectedLoans.Find('-') then begin
            repeat
                //Skip if relatedparty is missing
                if RelatedSelectedLoans.Funder = '' then
                    continue;
                // Find a customer
                if not Customer.get(RelatedSelectedLoans."Customer No.") then
                    Error('Customer %1 found in the system.', RelatedSelectedLoans."Customer No.");

                RelatedLoansTbl.Reset();
                RelatedLoansTbl.SetRange("No.", RelatedSelectedLoans."Related Loan No");
                if RelatedLoansTbl.Find('-') then begin
                    RelatedLoansTbl.CalcFields(GrossInterestamount);
                    AccruedInterestAmount := RelatedLoansTbl.GrossInterestamount;

                    //Sales Invoice Document
                    SalesInvoiceHeader.Init();
                    SalesInvoiceHeader."No." := ''; // Let system assign number
                    SalesInvoiceHeader."Document Type" := SalesInvoiceHeader."Document Type"::Invoice;
                    SalesInvoiceHeader."Sell-to Customer No." := Customer."No.";
                    SalesInvoiceHeader."Posting Date" := WorkDate();
                    SalesInvoiceHeader."Document Date" := WorkDate();
                    SalesInvoiceHeader."Due Date" := CalcDate('<30D>', WorkDate());
                    SalesInvoiceHeader."Shortcut Dimension 1 Code" := RelatedSelectedLoans."Shortcut Dimension 1 Code";

                    if SalesInvoiceHeader.Insert(true) then begin
                        SalesInvoiceHeader.Validate("Sell-to Customer No.", Customer."No.");
                        SalesInvoiceHeader.Validate("Posting Date", WorkDate());
                        SalesInvoiceHeader.Validate("Document Date", WorkDate());
                        SalesInvoiceHeader.Validate("Due Date", CalcDate('<30D>', WorkDate()));
                        SalesInvoiceHeader.Validate("Shortcut Dimension 1 Code", RelatedSelectedLoans."Shortcut Dimension 1 Code");
                        SalesInvoiceHeader.Modify(true);

                        // Sales Invoice Lines
                        SalesInvoiceLine.Init();
                        SalesInvoiceLine."Document Type" := SalesInvoiceLine."Document Type"::Invoice;
                        SalesInvoiceLine.Validate("Sell-to Customer No.", Customer."No.");
                        SalesInvoiceLine."Document No." := SalesInvoiceHeader."No.";
                        SalesInvoiceLine."Line No." := Looper;

                        SalesInvoiceLine.Type := SalesInvoiceLine.Type::"G/L Account";
                        SalesInvoiceLine.Validate("No.", RelatedLoansTbl."Interest Payable");
                        SalesInvoiceLine.Validate("Unit Price", AccruedInterestAmount);
                        SalesInvoiceLine.Validate(Quantity, 1);
                        if SalesInvoiceLine.Insert(true) then begin
                            // SalesInvoiceLine.Validate("Gen. Prod. Posting Group", 'WITHHOLDING');
                            // SalesInvoiceLine.Validate("VAT Bus. Posting Group", 'DOMESTIC');
                            SalesInvoiceLine.Modify()
                        end;
                    end;
                    //Flag Interest as Sales Invoiced.
                    RelatedSelectedLoans."Computed Interest" := AccruedInterestAmount;
                    RelatedSelectedLoans."Posting Date" := Today;
                    RelatedSelectedLoans.Processed := true;
                    RelatedSelectedLoans.Modify();

                    // // Allow modification before posting
                    // OnBeforePostSalesInvoiceWithGLLines(SalesInvoiceHeader);

                    // // Post the invoice
                    // Commit();
                    // if not SalesPost.Run(SalesInvoiceHeader) then
                    //     Error('Error posting sales invoice: %1', GetLastErrorText());

                    // // Raise event after posting
                    // OnAfterSalesInvoiceWithGLLinesPosted(SalesInvoiceHeader);

                    // Message('Sales Invoice %1 has been created and posted successfully.', SalesInvoiceHeader."No.");

                end;
                Looper += 1;
            until RelatedSelectedLoans.Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesInvoiceWithGLLines(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostSalesInvoiceWithGLLines(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesInvoiceWithGLLinesPosted(SalesHeader: Record "Sales Header")
    begin
    end;

    var
        myGlobalCounter: Integer;
        relatedpartyLoan: Record "RelatedParty Loan";
        relatedparty: Record RelatedParty;
        // debtor: Record Debtor;
        // relatedPartyLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        funderPostingGroup: Record 93;
        generalSetup: Record "Treasury General Setup";
        _docNo: Code[20];
        TrsyMgt: Codeunit "Treasury Mgt CU";
        ReportFlag: Record "Report Flags";
}