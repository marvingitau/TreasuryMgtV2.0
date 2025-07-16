table 50295 "Disbur. Tranched Loan"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Disbur. Tranched";
    DrillDownPageId = "Disbur. Tranched";

    fields
    {
        field(1; LineNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Total Payed"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Disbursed Tranche"; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(33; "Bank Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Bank Account";
        }
        field(20; "Disbursement Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(25; "Maturity Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(15; "Tranche Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(17; "New Repayment Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(18; "Bank Reference No"; Code[200])
        {
            DataClassification = ToBeClassified;

        }
        field(30; "Cumulative Disbursed"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(31; "Remaining Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Interest Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5000; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open,"Pending Approval",Approved,Rejected;
            trigger OnValidate()
            var
                funderLegderEntry: Record FunderLedgerEntry;
                looper: Record FunderLedgerEntry;
                NextEntryNo: Integer;
                _docNo: Code[20];
                _ConvertedCurrency: Decimal;
                _funderLoan: Record "Funder Loan";
                _bankAccount: Code[20];
                _loanAccount: Code[20];
                _trache: Record "Disbur. Tranched Loan";
                _cumulValue: Decimal;
                _funders: Record Funders;

                _disburTrachEntry: Record "Disbur. Tranched Entry";
                _feeChargeAmount: Decimal;
                _portfolioFeeSetup: Record "Portfolio Fee Setup";

                _withHoldingAc: Code[20];
            begin
                if not (Status = Status::Approved) then
                    exit;
                _funderLoan.Reset();
                _funderLoan.SetRange("No.", "Loan No.");
                if not _funderLoan.Find('-') then
                    Error('Loan No %1 is not found', "Loan No.");
                _funders.Reset();
                _funders.SetRange("No.", _funderLoan."Funder No.");
                if not _funders.find('-') then
                    Error('Funder %1 Not Found _tranLoan', _funderLoan."Funder No.");

                if _funderLoan.Currency <> '' then
                    _ConvertedCurrency := FunderMgt.ConvertCurrencyAmount(_funderLoan.Currency, "Tranche Amount", false)

                else
                    _ConvertedCurrency := "Tranche Amount";
                _docNo := TrsyMgt.GenerateDocumentNumber();

                GenSetup.Get();
                _bankAccount := "Bank Account";
                _loanAccount := _funderLoan."Payables Account";
                _withHoldingAc := GenSetup.FunderWithholdingAcc;

                //Update interest Rate if Applicable
                if "Interest Rate" <> 0 then begin
                    _funderLoan.InterestRate := "Interest Rate";
                    _funderLoan.Modify()
                end;

                looper.LockTable();
                looper.Reset();
                if looper.FindLast() then
                    NextEntryNo := looper."Entry No." + 1
                else
                    NextEntryNo := 1;
                funderLegderEntry.Init();
                funderLegderEntry."Entry No." := NextEntryNo;
                funderLegderEntry."Funder No." := _funderLoan."Funder No.";
                funderLegderEntry."Funder Name" := _funderLoan.Name;
                funderLegderEntry."Loan No." := "Loan No.";
                funderLegderEntry."Loan Name" := _funderLoan."Loan Name";
                funderLegderEntry."Posting Date" := Today;
                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Original Amount";
                funderLegderEntry."Document No." := _docNo;
                funderLegderEntry."Bank Ref. No." := "Bank Reference No";
                funderLegderEntry.Category := _funderLoan.Category; // Funder Loan Category
                funderLegderEntry.Description := _funderLoan."No." + ' ' + _funderLoan.Name + '-' + "Bank Reference No" + '-' + Format(_funderLoan.PlacementDate) + Format(_funderLoan.MaturityDate) + ' Tranch_Original Amount ';
                funderLegderEntry."Currency Code" := _funderLoan.Currency;

                funderLegderEntry.Amount := "Tranche Amount";
                funderLegderEntry."Amount(LCY)" := _ConvertedCurrency;
                funderLegderEntry."Remaining Amount" := "Tranche Amount";

                funderLegderEntry."Bal. Account No." := _loanAccount;
                funderLegderEntry."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account";
                funderLegderEntry."Account No." := _bankAccount;
                funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"Bank Account";


                funderLegderEntry.Insert();
                if _funderLoan.EnableGLPosting = true then
                    FunderMgt.DirectGLPosting('init', _loanAccount, _withHoldingAc, Rec."Tranche Amount", 0, 'Tranch Amount', "Loan No.", _bankAccount, _funderLoan.Currency, '', '', "Bank Reference No", _funders."Shortcut Dimension 1 Code");

                _trache.Reset();
                _trache.SetRange(_trache."Loan No.", "Loan No.");
                if not _trache.Find('-') then begin
                    "Cumulative Disbursed" := "Tranche Amount";
                    "Remaining Balance" := "Total Payed" - "Cumulative Disbursed";
                end else begin
                    _trache.Reset();
                    _trache.SetRange(_trache."Loan No.", "Loan No.");
                    _trache.CalcSums("Cumulative Disbursed");

                    _cumulValue := _trache."Cumulative Disbursed";
                    "Cumulative Disbursed" := _cumulValue + "Tranche Amount";
                    "Remaining Balance" := "Total Payed" - "Cumulative Disbursed";
                end;
                //Fee Transactions
                _disburTrachEntry.Reset();
                _disburTrachEntry.SetRange(DisbursedTrachNo, LineNo);
                _disburTrachEntry.SetRange(utilized, false);
                if _disburTrachEntry.Find('-') then begin
                    repeat
                        _feeChargeAmount := (_disburTrachEntry."Fee %" / 100) * "Tranche Amount";
                        if _funderLoan.EnableGLPosting = true then
                            FunderMgt.DirectGLPosting('tranch-fee', _disburTrachEntry.GLAccount, _withHoldingAc, _feeChargeAmount, 0, 'Tranch  Fee Amount', "Loan No.", _disburTrachEntry.BankAccount, _funderLoan.Currency, '', '', "Bank Reference No", _funders."Shortcut Dimension 1 Code");

                        _disburTrachEntry.utilized := true;
                        _disburTrachEntry.Modify();

                        //Reset Porfolio Selected Fees for the next selection
                        _portfolioFeeSetup.Reset();
                        _portfolioFeeSetup.SetRange(LineNo, _disburTrachEntry.PortfolioRecLineNo);
                        if _portfolioFeeSetup.Find('-') then begin
                            _portfolioFeeSetup."G/L" := '';
                            _portfolioFeeSetup."Is G/L Enabled" := false;
                            _portfolioFeeSetup.Modify();
                        end;
                    until _disburTrachEntry.Next() = 0;
                end;

            end;
        }

    }

    keys
    {
        key(PK; LineNo, "Loan No.", "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
        GFilter: Codeunit GlobalFilters;
        LoanNo: Code[20];
        TrsyMgt: Codeunit "Treasury Mgt CU";
        FunderMgt: Codeunit FunderMgtCU;
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";

    trigger OnInsert()
    var
        _funderLoan: Record "Funder Loan";
    begin
        GenSetup.Get(0);
        GenSetup.TestField("Funder Loan No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true);


        LoanNo := GFilter.GetGlobalLoanFilter();
        "Loan No." := LoanNo;
        _funderLoan.Reset();
        _funderLoan.SetRange("No.", LoanNo);
        if _funderLoan.Find('-') then begin
            "Total Payed" := _funderLoan."Total Payed";
            // "Bank Reference No" := _funderLoan."Bank Ref. No.";
            "Maturity Date" := _funderLoan.MaturityDate;
            "Interest Rate" := _funderLoan.InterestRate;
            _funderLoan.CalcFields(OutstandingAmntDisbLCY);
            "Tranche Amount" := _funderLoan."Total Payed" - _funderLoan.OutstandingAmntDisbLCY
        end;

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}