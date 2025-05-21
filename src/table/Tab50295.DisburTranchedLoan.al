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
        field(30; "Cumulative Disbursed"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(31; "Remaining Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5000; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open,"Pending Approval",Approved;
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
            begin
                if not (Status = Status::Approved) then
                    exit;
                _funderLoan.Reset();
                _funderLoan.SetRange("No.", "Loan No.");
                if not _funderLoan.Find('-') then
                    Error('Loan No %1 is not found', "Loan No.");
                if _funderLoan.Currency <> '' then
                    _ConvertedCurrency := FunderMgt.ConvertCurrencyAmount(_funderLoan.Currency, "Tranche Amount", false)

                else
                    _ConvertedCurrency := "Tranche Amount";
                _docNo := TrsyMgt.GenerateDocumentNumber();

                _bankAccount := "Bank Account";
                _loanAccount := _funderLoan."Payables Account";

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
                funderLegderEntry.Category := _funderLoan.Category; // Funder Loan Category
                                                                    // funderLegderEntry."Transaction Type" := funderLegderEntry."Transaction Type"::"Original Amount";
                funderLegderEntry.Description := _funderLoan.Name + ' ' + _funderLoan."Bank Ref. No." + ' Tranch_Original Amount ' + Format(Today);
                funderLegderEntry."Currency Code" := _funderLoan.Currency;
                funderLegderEntry.Amount := "Tranche Amount";
                funderLegderEntry."Amount(LCY)" := _ConvertedCurrency;
                funderLegderEntry."Remaining Amount" := "Tranche Amount";
                funderLegderEntry.Insert();
                if _funderLoan.EnableGLPosting = true then
                    FunderMgt.DirectGLPosting('init', _loanAccount, Rec."Tranche Amount", 'Tranch Amount', "Loan No.", _bankAccount, _funderLoan.Currency, '', '', '');

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
            end;
        }

    }

    keys
    {
        key(PK; LineNo, "Loan No.")
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

    trigger OnInsert()
    var
        _funderLoan: Record "Funder Loan";
    begin
        LoanNo := GFilter.GetGlobalLoanFilter();
        "Loan No." := LoanNo;
        _funderLoan.Reset();
        _funderLoan.SetRange("No.", LoanNo);
        if _funderLoan.Find('-') then begin
            "Total Payed" := _funderLoan."Total Payed";
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