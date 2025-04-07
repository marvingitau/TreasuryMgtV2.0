codeunit 50239 "RelatedCustomer Mgt CU"
{
    trigger OnRun()
    begin

    end;

    procedure CalculateInterest(RelatedPartyNo: Code[100])
    var
        myLocalCounter: Integer;
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        principleAcc: Code[20];
        interestReceivedAc: Code[20];
        interestAccPayable: Code[20];
        interestIncomeAc: Code[20];
        withholdingAcc: Code[20];
        NextEntryNo: Integer;
        relatedLegderEntry: Record RelatedLedgerEntry;//Calculate every month
        relatedLegderEntry1: Record RelatedLedgerEntry;//Calculate every month
        relatedLegderEntry2: Record RelatedLedgerEntry;//Calculate every month
        relatedLegderEntry3: Record RelatedLedgerEntry;//Calculate every month

        latestRemainingAmount: Decimal;
        remainingDays: Integer;
        endYearDate: Date;
        endMonthDate: Date;
        _relatedNo: Code[100];
        _relatedName: Code[100];
        _totalOriginalAmount: Decimal;
        _totalWithdrawalAmount: Decimal;
        _differenceOriginalWithdrawal: Decimal;

        _interestRate_Active: Decimal;
        _currentPrincipalAmnt: Decimal;

        _interestComputationTimes: Integer;
        _docNo: Code[20];
        _ConvertedCurrency: Decimal;
        _ConvertedWthdoldCurrency: Decimal;
        FunderMgt: Codeunit FunderMgtCU;
    begin
        //Interest Rate Type (Fixed/Float)
        //Interest Rate value
        //***Interest Method
        // (Annual Rate / 12) * Principal

        latestRemainingAmount := 0;
        RelatedParty.Reset();
        RelatedParty.SetRange(RelatedParty."No.", RelatedPartyNo);
        _docNo := TrsyMgt.GenerateDocumentNumber();
        if RelatedParty.Find('-') then begin
            _relatedName := RelatedParty.RelatedPName;
            _relatedNo := RelatedParty."No.";
            RelatedParty.CalcFields(OutstandingAmntDisbLCY);
            _currentPrincipalAmnt := RelatedParty.OutstandingAmntDisbLCY;

            //Fixed Interest Type
            if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") OR (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then begin
                RelatedParty.TestField(PlacementDate);

                relatedLegderEntry3.Reset();
                relatedLegderEntry3.SetRange("RelatedParty No.", RelatedParty."No.");
                relatedLegderEntry3.SetRange(relatedLegderEntry3."Document Type", relatedLegderEntry3."Document Type"::Interest);
                _interestComputationTimes := relatedLegderEntry3.Count();

                // endYearDate := CALCDATE('CY', Today);
                if _interestComputationTimes = 0 then begin
                    endMonthDate := CALCDATE('CM', Today);
                    remainingDays := endMonthDate - RelatedParty.PlacementDate + 1;
                end else begin
                    endMonthDate := CALCDATE('CM', Today);
                    remainingDays := (endMonthDate - Today) + 1;
                end;


                // Get Total of Original Amount (Principal)
                relatedLegderEntry3.Reset();
                relatedLegderEntry3.SetRange("RelatedParty No.", RelatedParty."No.");
                relatedLegderEntry3.SetRange(relatedLegderEntry3."Document Type", relatedLegderEntry3."Document Type"::"Original Amount");
                relatedLegderEntry3.CalcSums(Amount);
                _totalOriginalAmount := relatedLegderEntry3.Amount;

                relatedLegderEntry3.Reset();
                relatedLegderEntry3.SetRange("RelatedParty No.", RelatedParty."No.");
                relatedLegderEntry3.SetRange(relatedLegderEntry3."Document Type", relatedLegderEntry3."Document Type"::Repayment);
                relatedLegderEntry3.CalcSums(Amount);
                _totalWithdrawalAmount := Abs(relatedLegderEntry3.Amount);

                _differenceOriginalWithdrawal := _totalOriginalAmount - _totalWithdrawalAmount; // Get the floating value


                //Monthly interest depending on Interest Method
                monthlyInterest := 0;
                _interestRate_Active := 0;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Fixed Rate") then
                    _interestRate_Active := RelatedParty.InterestRatePA;
                if (RelatedParty.InterestRateType = RelatedParty.InterestRateType::"Floating Rate") then
                    _interestRate_Active := (RelatedParty."Reference Rate" + RelatedParty.Margin);
                if _interestRate_Active = 0 then
                    Error('Interest Rate is Zero');

                _differenceOriginalWithdrawal := _currentPrincipalAmnt;
                if RelatedParty.InterestMethod = RelatedParty.InterestMethod::"30/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (30 / 360), 0.0001, '=');
                end else if RelatedParty.InterestMethod = RelatedParty.InterestMethod::"Actual/360" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 360), 0.0001, '=');
                end else if RelatedParty.InterestMethod = RelatedParty.InterestMethod::"Actual/364" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 364), 0.0001, '=');
                end else if RelatedParty.InterestMethod = RelatedParty.InterestMethod::"Actual/365" then begin
                    monthlyInterest := Round(((_interestRate_Active / 100) * _differenceOriginalWithdrawal) * (remainingDays / 365), 0.0001, '=');
                end;

                //withholding on interest
                //Depending on Tax Exceptions
                witHldInterest := 0;
                if RelatedParty.TaxStatus = RelatedParty.TaxStatus::Taxable then begin
                    RelatedParty.TestField(Withldtax);
                    witHldInterest := (RelatedParty.Withldtax / 100) * monthlyInterest;
                end;


                //Get Posting groups
                // if not venPostingGroup.Get(funderLoan."Posting Group") then
                //     Error('Missing Posting Group: %1', funder."No.");

                principleAcc := RelatedParty."Principal Account";
                interestReceivedAc := RelatedParty."Interest Receivable";
                interestIncomeAc := RelatedParty."Interest Income";

                if interestReceivedAc = '' then
                    Error('Missing Receivable Interest A/C: %1', RelatedParty."No.");
                if interestIncomeAc = '' then
                    Error('Missing Income Interest A/C: %1', RelatedParty."No.");
                if principleAcc = '' then
                    Error('Missing Principle A/C: %1', RelatedParty."No.");


                if not generalSetup.FindFirst() then
                    Error('Please Define Withholding Tax under General Setup');
                withholdingAcc := generalSetup.RelatedWithholdingAcc;
                //Get the latest remaining amount
                relatedLegderEntry.SetRange(relatedLegderEntry."Document Type", relatedLegderEntry."Document Type"::"Remaining Amount");
                if relatedLegderEntry.FindLast() then
                    latestRemainingAmount := relatedLegderEntry."Remaining Amount";



                if RelatedParty.Currency <> '' then begin
                    _ConvertedCurrency := FunderMgt.ConvertCurrencyAmount(RelatedParty.Currency, monthlyInterest, false);
                    _ConvertedWthdoldCurrency := FunderMgt.ConvertCurrencyAmount(RelatedParty.Currency, witHldInterest, false);
                end else begin

                    _ConvertedCurrency := monthlyInterest;
                    _ConvertedWthdoldCurrency := witHldInterest;
                end;


                //relatedLegderEntry.LockTable();
                relatedLegderEntry.Reset();
                if relatedLegderEntry.FindLast() then
                    NextEntryNo := relatedLegderEntry."Entry No." + 1;


                relatedLegderEntry.Init();
                relatedLegderEntry."Entry No." := NextEntryNo;
                relatedLegderEntry."Related  Name" := _relatedName;
                relatedLegderEntry."RelatedParty No." := _relatedNo;
                relatedLegderEntry."Posting Date" := Today;
                relatedLegderEntry."Document No." := _docNo;
                relatedLegderEntry."Document Type" := relatedLegderEntry."Document Type"::Interest;
                relatedLegderEntry.Description := 'Interest calculation ' + Format(Today);
                relatedLegderEntry."Currency Code" := RelatedParty.Currency;
                relatedLegderEntry.Amount := monthlyInterest;
                relatedLegderEntry."Amount(LCY)" := _ConvertedCurrency;
                relatedLegderEntry."Remaining Amount" := (monthlyInterest - witHldInterest);
                relatedLegderEntry.Insert();
                if (RelatedParty.EnableGLPosting = true) and (monthlyInterest <> 0) then
                    DirectGLPosting('interest', interestReceivedAc, monthlyInterest, 'Interest', RelatedParty."No.", interestIncomeAc, RelatedParty.Currency, '', '');//GROSS Interest
                                                                                                                                                                      //Commit();
                relatedLegderEntry1.Init();
                relatedLegderEntry1."Entry No." := NextEntryNo + 1;
                relatedLegderEntry1."Related  Name" := _relatedName;
                relatedLegderEntry1."RelatedParty No." := _relatedNo;
                relatedLegderEntry1."Posting Date" := Today;
                relatedLegderEntry1."Document No." := _docNo;
                relatedLegderEntry1."Document Type" := relatedLegderEntry."Document Type"::Withholding;
                relatedLegderEntry1.Description := 'Withholding calculation ' + Format(Today);
                relatedLegderEntry."Currency Code" := RelatedParty.Currency;
                relatedLegderEntry1.Amount := -witHldInterest;
                relatedLegderEntry1."Amount(LCY)" := -_ConvertedWthdoldCurrency;
                relatedLegderEntry1.Insert();
                if (RelatedParty.EnableGLPosting = true) and (witHldInterest <> 0) then
                    // DirectGLPosting('withholding', withholdingAcc, witHldInterest, 'Withholding Tax', RelatedParty."No.", interestAccPayable, '', '', '');




                    Message('Interest Calculated');
            end else begin
                Message('Select Interest Rate Type');
            end;


        end;

    end;

    procedure DirectGLPosting(Origin: Text[100]; GLAcc: Code[100]; Amount: Decimal; Desc: Text[100]; RelatedNo: Code[20]; BankAc: Code[100]; Currency: Code[20]; PostingGroup: Code[50]; DocNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        JournalEntry: Record "Gen. Journal Line";
        GLPost: Codeunit "Gen. Jnl.-Post Line";
        FunderMgt: Codeunit FunderMgtCU;
        // principleAcc: Code[100];
        // interestReceivedAc: Code[100];
        // interestAccPay: Code[100];
        withholdingAcc: Code[20];
        monthlyInterest: Decimal;
        witHldInterest: Decimal;
        _relatedParty: Record "RelatedParty- Cust";

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

        _relatedParty.Reset();
        _relatedParty.SetRange("No.", RelatedNo);
        if not _relatedParty.Find('-') then
            Error('Related Party %1 not found', RelatedNo);

        if not generalSetup.FindFirst() then
            Error('Please Define Withholding Tax under General Setup');
        withholdingAcc := generalSetup.FunderWithholdingAcc;

        if Currency <> '' then
            _ConvertedCurrency := FunderMgt.ConvertCurrencyAmount(Currency, Amount, false)
        else
            _ConvertedCurrency := Amount;
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
            JournalEntry."Document No." := RelatedNo + Format(Today);
        JournalEntry.Description := Desc;
        JournalEntry."Currency Code" := Currency;
        if Origin = 'init' then begin  //*
            JournalEntry."Account Type" := JournalEntry."Account Type"::"Bank Account";
            JournalEntry."Account No." := BankAc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := GLAcc;
        end;
        if Origin = 'init-relatedcust' then begin  //*
            JournalEntry."Account Type" := JournalEntry."Account Type"::"Bank Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;
        end;
        if Origin = 'interest' then begin
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interest receivable
        end;
        if Origin = 'withholding' then begin
            JournalEntry."Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Account No." := GLAcc;
            JournalEntry.Amount := Round(Amount, 0.01, '=');
            JournalEntry."Amount (LCY)" := Round(_ConvertedCurrency, 0.01, '=');
            JournalEntry."Bal. Account Type" := JournalEntry."Account Type"::"G/L Account";
            JournalEntry."Bal. Account No." := BankAc;//interestAccPayable
        end;

        GLPost.RunWithCheck(JournalEntry);

    end;

    var
        generalSetup: Record "Treasury General Setup";
        RelatedParty: Record "RelatedParty- Cust";
        TrsyMgt: Codeunit "Treasury Mgt CU";
}