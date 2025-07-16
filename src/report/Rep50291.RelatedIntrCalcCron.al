report 50291 "Related Intr. Calc. Cron"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Related Intrest Calculation Cron';

    dataset
    {
        dataitem("RelatedParty Loan"; "RelatedParty Loan")
        {

            trigger OnAfterGetRecord()
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
                RelatedpartyLoanNo: Code[20];
            begin

                RelatedpartyLoanNo := "RelatedParty Loan"."No.";

                latestRemainingAmount := 0;
                relatedpartyLoan.Reset();
                relatedpartyLoan.SetRange(relatedpartyLoan."No.", RelatedpartyLoanNo);
                relatedpartyLoan.SetFilter(Category, '<>%1', 'BANK OVERDRAFT');
                relatedpartyLoan.SetFilter(InterestRate, '<>%1', 0);
                relatedpartyLoan.SetFilter(Status, '=%1', relatedpartyLoan.Status::Approved);
                // relatedpartyLoan.SetFilter(, '<>%1', relatedpartyLoan.Status::Approved);

                _docNo := TrsyMgt.GenerateDocumentNumber();
                if relatedpartyLoan.Find('-') then begin
                    _loanName := relatedpartyLoan."Loan Name";
                    _loanNo := relatedpartyLoan."No.";
                    relatedpartyLoan.CalcFields(OutstandingAmntDisbLCY);
                    _currentPrincipalAmnt := relatedpartyLoan.OutstandingAmntDisbLCY;
                    if not relatedparty.Get(relatedpartyLoan."RelatedParty No.") then
                        Error('Relatedparty %1 not found', relatedpartyLoan."RelatedParty No.");
                    // repeat
                    if relatedpartyLoan.Status <> relatedpartyLoan.Status::Approved then
                        Error('Loan Status is %1', relatedpartyLoan.Status);

                    _relatedParty.Reset();
                    _relatedParty.SetRange("No.", relatedpartyLoan."RelatedParty No.");
                    if not _relatedParty.Find('-') then
                        Error('Relatedparty %1 not found _fl', relatedpartyLoan."RelatedParty No.");

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
                        CurrReport.Skip();


                    //Fixed Interest Type
                    if (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Fixed Rate") OR (relatedpartyLoan.InterestRateType = relatedpartyLoan.InterestRateType::"Floating Rate") then begin
                        relatedpartyLoan.TestField(PlacementDate);

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
                                remainingDays := endMonthDate - relatedpartyLoan.PlacementDate + 0;
                            end else begin
                                endMonthDate := CALCDATE('<+CM>', Today);
                                remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 0
                            end;
                        end else begin
                            endMonthDate := CALCDATE('<+CM>', Today);
                            remainingDays := CALCDATE('<CM>', Today) - CALCDATE('<-CM>', Today) + 0
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
                            RelatepartyMgtCU.DirectGLPosting('interest', interestAccIncome, withholdingAcc, monthlyInterest, witHldInterest, 'Interest', relatedpartyLoan."No.", interestAccReceivable, relatedpartyLoan.Currency, '', '', relatedPartyLegderEntry."External Document No.", _relatedParty."Shortcut Dimension 1 Code");//GROSS Interest
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


                        // Message('Interest Calculated');
                    end else begin
                        Message('Select Interest Rate Type');
                    end;


                end;

            end;
        }
    }

    trigger OnPostReport()
    begin
        Message('Interest Calculated');
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
        RelatepartyMgtCU: Codeunit RelatepartyMgtCU;
}