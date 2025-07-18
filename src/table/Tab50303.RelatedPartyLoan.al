table 50303 "RelatedParty Loan"
{
    DataClassification = ToBeClassified;
    // LookupPageId = "Funder Loans List";
    // DrillDownPageId = "Funder Loans List";
    DataCaptionFields = "No.", "Loan Name";
    fields
    {
        field(1; "No."; Code[10])
        {
            //NotBlank = true;
            DataClassification = ToBeClassified;
        }
        field(15; "Funder No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "RelatedParty No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Record No.';
            trigger OnValidate()
            var
                RelatedParty: Record RelatedParty;
                Portfolio: Record "Portfolio RelatedParty";
            begin
                RelatedParty.Reset();
                RelatedParty.SetRange("No.", "RelatedParty No.");
                if RelatedParty.Find('-') then begin
                    Name := RelatedParty.Name;
                    if RelatedParty."Payables Account" = '' then begin
                        Error('Payable A/c Missing');
                        exit;
                    end;
                    if RelatedParty."Interest Expense" = '' then begin
                        Error('Interest Expense A/c Missing');
                        exit;
                    end;
                    if RelatedParty."Interest Payable" = '' then begin
                        Error('Interest Payable A/c Missing');
                        exit;
                    end;
                    "Payables Account" := RelatedParty."Payables Account";
                    Rec.Validate("Payables Account");
                    "Interest Expense" := RelatedParty."Interest Expense";
                    Rec.Validate("Interest Expense");
                    "Interest Payable" := RelatedParty."Interest Payable";
                    Rec.Validate("Interest Payable");

                    Portfolio.Reset();
                    Portfolio.SetRange("No.", RelatedParty.Portfolio);
                    if Portfolio.Find('-') then begin
                        if Portfolio.Category = Portfolio.Category::"Bank Loan" then
                            Category := 'Bank Loan';
                        if Portfolio.Category = Portfolio.Category::Individual then
                            Category := 'Individual';
                        if Portfolio.Category = Portfolio.Category::Institutional then
                            Category := 'Institutional';
                        // if Portfolio.Category = Portfolio.Category::"Bank Overdraft" then
                        //     Category := 'Bank Overdraft';
                        if Portfolio.Category = Portfolio.Category::"Medium Term Notes" then
                            Category := 'Medium Term Notes';
                        if Portfolio.Category = Portfolio.Category::Relatedparty then
                            Category := 'Relatedparty';


                        // Category := Portfolio.Category;
                        Category_line_No := Portfolio.Category_Line_No;
                        Rec.Validate(Category);
                    end;

                    InvstPINNo := RelatedParty.KRA;
                end;
            end;
        }
        field(30; Name; Text[200])
        {
            DataClassification = ToBeClassified;
            // Caption = 'Funder Name';
        }
        field(40; "Posting Group"; Text[200])
        {
            DataClassification = ToBeClassified;
            Caption = 'Posting Group';
            TableRelation = "Treasury Posting Group".Code;

        }
        field(400; "Loan Name"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(500; "SupplierSysRefNo"; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Supplier System reference Number';
        }
        field(501; "PlacementDate"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Placement Date';
            NotBlank = true;
            trigger OnValidate()
            begin
                if (PlacementDate <> 0D) and (MaturityDate <> 0D) then begin
                    LoanDurationDays := (MaturityDate - PlacementDate);
                end

            end;
        }
        field(502; "MaturityDate"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Maturity Date';
            trigger OnValidate()
            begin
                if (PlacementDate <> 0D) and (MaturityDate <> 0D) then begin
                    LoanDurationDays := (MaturityDate - PlacementDate);
                end

            end;
        }

        field(503; "OrigAmntDisbLCY"; Decimal)
        {
            // DataClassification = ToBeClassified;
            // Caption = 'Original Amount in disbursed';
            AutoFormatType = 1;
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Original Amount')));
            Caption = 'Original Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(504; "OutstandingAmntDisbLCY"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Original Amount' | Repayment | "Secondary Amount")));
            Caption = 'Outstanding Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;

        }
        field(505; "InterestRate"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if InterestRate <> 0 then
                    NetInterestRate := ((100 - Withldtax) / 100) * InterestRate;
            end;

        }
        field(506; "InterestRateType"; Enum InterestRateType)
        {
            DataClassification = ToBeClassified;
            Caption = 'Interest Rate Type';
        }
        field(507; "InterestRepaymentHz"; DateFormula)
        {
            DataClassification = ToBeClassified;
            Caption = 'Interest repayment frequency';
        }

        // field(508; "PortfolioFund"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Portfolio -Based on the source of the funds';
        // }
        field(509; "Withldtax"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                // Validate();
            end;

        }
        field(510; "TaxStatus"; Enum TaxStatus)
        {
            DataClassification = ToBeClassified;

        }
        field(511; "GrossInterestamount"; Decimal)
        {
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Interest')));
            Caption = 'Gross Interest amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(512; "NetInterestamount"; Decimal)
        {
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Interest' | 'Interest Paid' | Withholding | "Capitalized Interest")));
            Caption = 'Net Interest amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(513; "WithgTaxAmtAppld"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Withholding tax amount applied';
        }
        field(514; "InvstPINNo"; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Investor PIN No (Revenue authority)';
        }
        // field(515; StartTenor; Date)
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Start Tenor';
        // }

        field(516; SecurityType; Enum SecurityType)
        {
            DataClassification = ToBeClassified;
            Caption = 'Security type';
        }

        field(517; InterestMethod; Enum InterestMethod)
        {
            DataClassification = ToBeClassified;
            Caption = 'Interest Method Applied';
            //NotBlank = true;
        }
        field(518; "FormofSec"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Other Form of security';
        }
        field(519; "DisbursedCurrency"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Disbursed Currency';
            trigger OnValidate()
            var
            begin

            end;


        }
        // field(520; "Type of Vendor"; Enum VendorType)
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Treasury Vendor Type';
        // }
        // field(521; EndTenor; Date)
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'End Tenor';
        // }
        field(522; EnableGLPosting; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable GL Posting';
            InitValue = true;
        }
        // field(523; Portfolio; Code[100])
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Portfolio';
        //     TableRelation = Portfolio.Code;
        // }
        field(524; Category; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Category';
            // TableRelation = "Portfolio Category".Code;
        }
        field(523; Category_line_No; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(525; Type; Enum FundingType)
        {
            DataClassification = ToBeClassified;
            Caption = 'Funding Type';
        }

        field(526; FundSource; Code[100])
        {
            DataClassification = ToBeClassified;

            TableRelation = "Bank Account"."No.";
            trigger OnValidate()
            var
                _bankAccs: Record "Bank Account";
            begin
                _bankAccs.Reset();
                _bankAccs.SetRange("No.", FundSource);
                if _bankAccs.Find('-') then begin
                    Currency := _bankAccs."Currency Code";
                end;
            end;
        }
        field(535; Currency; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Currency';
            TableRelation = Currency;
            /*trigger OnValidate()
            begin
                if Currency <> '' then begin
                    vPostingGroup.Reset();
                    vPostingGroup.SetRange(vPostingGroup."Treasury Enabled (Foreign)", true);
                    if vPostingGroup.Find('-') then begin
                        "Posting Group" := vPostingGroup.Code;
                    end else begin
                        Error('Please set the default Foreign Posting Group');
                    end;
                end else begin
                    vPostingGroup.Reset();
                    vPostingGroup.SetRange(vPostingGroup."Treasury Enabled (Local)", true);
                    if vPostingGroup.Find('-') then begin
                        "Posting Group" := vPostingGroup.Code;
                    end else begin
                        Error('Please set the default Local Posting Group');
                    end;
                end;

            end;*/

        }

        // field(600; "Shortcut Dimension 1 Code"; Code[50])
        // {
        //     CaptionClass = '1,1,1';
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        // }
        field(610; Status; Enum "Loan Approval Status")
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                relatedpartyLedgerEntry: Record RelatedLedgerEntry;
                looper: Record RelatedLedgerEntry;
                NextEntryNo: Integer;
                RelatedpartyMgt: Codeunit RelatepartyMgtCU;
                venPostingGroup: Record "Treasury Posting Group";
                principleAcc: Code[20];
                interestAcc: Code[20];
                interestAccPay: Code[20];
                ReversalEntry: Record "Reversal Entry";
                _docNo: Code[20];
                TrsyMgt: Codeunit "Treasury Mgt CU";
                _ConvertedCurrency: Decimal;
                _relatedParty: Record RelatedParty;
                _portfolio: Record "Portfolio RelatedParty";

                _funderLoan: Record "RelatedParty Loan";
                _rolloverTbl: Record "Roll over Tbl";
                _rolloveredInterest: Decimal;
                _rolloveredPrincipal: Decimal;

                withHoldingAcc: Code[20];
            begin
                if not (Status = Status::Approved) then
                    exit;

                GenSetup.Get(0);

                _relatedParty.Reset();
                _relatedParty.SetRange("No.", "RelatedParty No.");
                if not _relatedParty.Find('-') then
                    Error('Relatedparty %1 not found _rl', "RelatedParty No.");
                _portfolio.Reset();
                _portfolio.SetRange("No.", _relatedParty.Portfolio);
                if not _portfolio.Find('-') then
                    Error('Portfolio %1 not found _rl', _relatedParty.Portfolio);

                _docNo := TrsyMgt.GenerateDocumentNumber();
                //Get Posting groups
                /*if not venPostingGroup.Get("Posting Group") then
                    Error('Missing Posting Group: %1', "No.");*/
                if FundSource = '' then
                    Error('RelatedParty Entry (Bank) Must have a value', FundSource);
                // principleAcc := venPostingGroup."Payables Account";
                // interestAcc := venPostingGroup."Interest Expense";
                principleAcc := "Payables Account";
                interestAcc := "Interest Expense";
                interestAccPay := "Interest Payable";
                withHoldingAcc := GenSetup.RelatedWithholdingAcc;

                if principleAcc = '' then
                    Error('Missing G/L - Principle A/C');
                if interestAcc = '' then
                    Error('Missing G/L - Interest Expense A/C');
                if interestAccPay = '' then
                    Error('Missing G/L - Interest Payable A/C');
                if "Bank Ref. No." = '' then
                    Error('Missing Bank Reference No.');

                if "Original Disbursed Amount" = 0 then
                    Error('Original Disbursed Amount Required');
                // if InterestRate = 0 then
                //     Error('Gross Interest rate (p.a) Required');

                if Currency <> '' then
                    _ConvertedCurrency := RelatedpartyMgt.ConvertCurrencyAmount(Currency, "Original Disbursed Amount", CustomFX)
                else
                    _ConvertedCurrency := "Original Disbursed Amount";

                relatedpartyLedgerEntry.Reset();
                relatedpartyLedgerEntry.SetRange(relatedpartyLedgerEntry."Document Type", relatedpartyLedgerEntry."Document Type"::"Original Amount");
                relatedpartyLedgerEntry.SetRange(relatedpartyLedgerEntry."Loan No.", "No.");
                if relatedpartyLedgerEntry.Find('-') then begin
                    relatedpartyLedgerEntry."Modification Date" := Today;
                    relatedpartyLedgerEntry."Modification User" := UserId;
                    relatedpartyLedgerEntry.Amount := DisbursedCurrency;
                    relatedpartyLedgerEntry."Amount(LCY)" := _ConvertedCurrency;
                    relatedpartyLedgerEntry."Remaining Amount" := DisbursedCurrency;
                    relatedpartyLedgerEntry.Modify();

                    //  Clear(ReversalEntry);
                    //     if Rec.Reversed then
                    //         ReversalEntry.AlreadyReversedEntry(Rec.TableCaption, Rec."Entry No.");
                    //     // CheckEntryPostedFromJournal();
                    //       Rec.TestField("No.");
                    //     ReversalEntry.ReverseTransaction(Rec."No.")


                end else begin
                    looper.LockTable();
                    looper.Reset();
                    if looper.FindLast() then
                        NextEntryNo := looper."Entry No." + 1
                    else
                        NextEntryNo := 1;
                    relatedpartyLedgerEntry.Init();
                    relatedpartyLedgerEntry."Entry No." := NextEntryNo;
                    relatedpartyLedgerEntry."RelatedParty No." := "RelatedParty No.";
                    relatedpartyLedgerEntry."Related  Name" := Name;
                    relatedpartyLedgerEntry."Loan No." := "No.";
                    relatedpartyLedgerEntry."Loan Name" := "Loan Name";
                    relatedpartyLedgerEntry."Posting Date" := Today;
                    relatedpartyLedgerEntry."Document Type" := relatedpartyLedgerEntry."Document Type"::"Original Amount";
                    relatedpartyLedgerEntry."Document No." := _docNo;
                    relatedpartyLedgerEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                    relatedpartyLedgerEntry."Origin Entry" := relatedpartyLedgerEntry."Origin Entry"::RelatedParty;
                    relatedpartyLedgerEntry.Category := Category; // Funder Loan Category
                    relatedpartyLedgerEntry.Category_Line := Category_line_No; // Funder Loan Category
                    // relatedpartyLedgerEntry."Transaction Type" := relatedpartyLedgerEntry."Transaction Type"::"Original Amount";
                    //  _funderLoan."No." + ' ' + _funderLoan."No." + '-' + _funderLoan."Bank Ref. No." + '-' + Format(_funderLoan.PlacementDate) + Format(_funderLoan.MaturityDate) +
                    relatedpartyLedgerEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate);
                    relatedpartyLedgerEntry."Currency Code" := Currency;
                    relatedpartyLedgerEntry.Amount := "Original Disbursed Amount";
                    relatedpartyLedgerEntry."Amount(LCY)" := _ConvertedCurrency;
                    relatedpartyLedgerEntry."Remaining Amount" := "Original Disbursed Amount";

                    relatedpartyLedgerEntry."Bal. Account No." := principleAcc;
                    relatedpartyLedgerEntry."Bal. Account Type" := relatedpartyLedgerEntry."Bal. Account Type"::"G/L Account";
                    if FundSource = '' then begin
                        relatedpartyLedgerEntry."Account No." := GenSetup."Opening  Balance Acc";
                        relatedpartyLedgerEntry."Account Type" := relatedpartyLedgerEntry."Account Type"::"G/L Account";
                    end else begin
                        relatedpartyLedgerEntry."Account No." := FundSource;
                        relatedpartyLedgerEntry."Account Type" := relatedpartyLedgerEntry."Account Type"::"Bank Account";
                    end;

                    relatedpartyLedgerEntry.Insert();

                    if (EnableGLPosting = true) then
                        RelatedpartyMgt.DirectGLPosting('init', principleAcc, withHoldingAcc, "Original Disbursed Amount", 0, 'Original Amount', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code")
                end;


                // ++++++++++++++++  CHECK ROLLOVER RECORD AND VALIDATE INTREST.
                if Rollovered = Rollovered::"Roll overed" then begin

                    //Act on the parent loan (Loan that was partially rollovered)
                    _rolloverTbl.Reset();
                    _rolloverTbl.SetRange("Loan No.", "Original Record No.");
                    if not _rolloverTbl.Find('-') then
                        Error('No rollover Log found for Loan %1', "Original Record No.");

                    if _rolloverTbl.RollOverType = _rolloverTbl.RollOverType::"Partial Rollover" then begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", "Original Record No.");
                        if _funderLoan.Find('-') then begin
                            _rolloveredInterest := "Rollovered Interest";
                            _rolloveredPrincipal := "Original Disbursed Amount";

                            // For Principal
                            if _funderLoan.PlacementMaturity = _funderLoan.PlacementMaturity::Principal then begin
                                looper.LockTable();
                                looper.Reset();
                                if looper.FindLast() then
                                    NextEntryNo := looper."Entry No." + 1
                                else
                                    NextEntryNo := 1;

                                relatedpartyLedgerEntry.Init();
                                relatedpartyLedgerEntry."Entry No." := NextEntryNo;
                                relatedpartyLedgerEntry."RelatedParty No." := _funderLoan."RelatedParty No.";
                                relatedpartyLedgerEntry."Related  Name" := _funderLoan.Name;
                                relatedpartyLedgerEntry."Loan No." := _funderLoan."No.";
                                relatedpartyLedgerEntry."Loan Name" := _funderLoan."Loan Name";
                                relatedpartyLedgerEntry."Posting Date" := Today;
                                relatedpartyLedgerEntry."Document Type" := relatedpartyLedgerEntry."Document Type"::"Original Amount";
                                relatedpartyLedgerEntry."Document No." := _docNo;
                                relatedpartyLedgerEntry."Origin Entry" := relatedpartyLedgerEntry."Origin Entry"::RelatedParty;
                                relatedpartyLedgerEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                                relatedpartyLedgerEntry.Category := Category; // Funder Loan Category
                                relatedpartyLedgerEntry.Category_Line := Category_line_No; // Funder Loan Category
                                relatedpartyLedgerEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Patial Principal Offset';
                                relatedpartyLedgerEntry."Currency Code" := Currency;
                                relatedpartyLedgerEntry.Amount := -_rolloveredPrincipal;
                                relatedpartyLedgerEntry."Amount(LCY)" := -_ConvertedCurrency;
                                relatedpartyLedgerEntry."Remaining Amount" := _rolloveredPrincipal;
                                if FundSource = '' then
                                    relatedpartyLedgerEntry."Bal. Account No." := GenSetup."Opening  Balance Acc";
                                relatedpartyLedgerEntry.Insert();
                                if (EnableGLPosting = true) then
                                    RelatedpartyMgt.DirectGLPosting('init', principleAcc, withHoldingAcc, -_rolloveredPrincipal, 0, 'Original Amount ::Patial Principal Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code")
                            end;
                            // Interest 
                            if _funderLoan.PlacementMaturity = _funderLoan.PlacementMaturity::Interest then begin
                                looper.LockTable();
                                looper.Reset();
                                if looper.FindLast() then
                                    NextEntryNo := looper."Entry No." + 1
                                else
                                    NextEntryNo := 1;

                                relatedpartyLedgerEntry.Init();
                                relatedpartyLedgerEntry."Entry No." := NextEntryNo + 2;
                                relatedpartyLedgerEntry."RelatedParty No." := _funderLoan."RelatedParty No.";
                                relatedpartyLedgerEntry."Related  Name" := _funderLoan.Name;
                                relatedpartyLedgerEntry."Loan No." := _funderLoan."No.";
                                relatedpartyLedgerEntry."Loan Name" := _funderLoan."Loan Name";
                                relatedpartyLedgerEntry."Posting Date" := Today;
                                relatedpartyLedgerEntry."Document Type" := relatedpartyLedgerEntry."Document Type"::Interest;
                                relatedpartyLedgerEntry."Document No." := _docNo;
                                relatedpartyLedgerEntry."Origin Entry" := relatedpartyLedgerEntry."Origin Entry"::RelatedParty;
                                relatedpartyLedgerEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                                relatedpartyLedgerEntry.Category := Category; // Funder Loan Category
                                relatedpartyLedgerEntry.Category_Line := Category_line_No; // Funder Loan Category
                                relatedpartyLedgerEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Patial Interest Offset';
                                relatedpartyLedgerEntry."Currency Code" := Currency;
                                relatedpartyLedgerEntry.Amount := -_rolloveredInterest;
                                relatedpartyLedgerEntry."Amount(LCY)" := -_ConvertedCurrency;
                                relatedpartyLedgerEntry."Remaining Amount" := _rolloveredInterest;
                                relatedpartyLedgerEntry.Insert();
                                if (EnableGLPosting = true) then
                                    RelatedpartyMgt.DirectGLPosting('interest', principleAcc, withHoldingAcc, -_rolloveredInterest, 0, 'Original Amount ::Patial Interest Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code")
                            end;
                            // Principal + Interest
                            if _funderLoan.PlacementMaturity = _funderLoan.PlacementMaturity::"Principal + Interest" then begin
                                looper.LockTable();
                                looper.Reset();
                                if looper.FindLast() then
                                    NextEntryNo := looper."Entry No." + 1
                                else
                                    NextEntryNo := 1;

                                relatedpartyLedgerEntry.Init();
                                relatedpartyLedgerEntry."Entry No." := NextEntryNo + 3;
                                relatedpartyLedgerEntry."RelatedParty No." := _funderLoan."RelatedParty No.";
                                relatedpartyLedgerEntry."Related  Name" := _funderLoan.Name;
                                relatedpartyLedgerEntry."Loan No." := _funderLoan."No.";
                                relatedpartyLedgerEntry."Loan Name" := _funderLoan."Loan Name";
                                relatedpartyLedgerEntry."Posting Date" := Today;
                                relatedpartyLedgerEntry."Document Type" := relatedpartyLedgerEntry."Document Type"::"Original Amount";
                                relatedpartyLedgerEntry."Document No." := _docNo;
                                relatedpartyLedgerEntry."Origin Entry" := relatedpartyLedgerEntry."Origin Entry"::RelatedParty;
                                relatedpartyLedgerEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                                relatedpartyLedgerEntry.Category := Category; // Funder Loan Category
                                relatedpartyLedgerEntry.Category_Line := Category_line_No; // Funder Loan Category
                                relatedpartyLedgerEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Patial Principal+Interest Offset';
                                relatedpartyLedgerEntry."Currency Code" := Currency;
                                relatedpartyLedgerEntry.Amount := -(_rolloveredInterest + _rolloveredPrincipal);
                                relatedpartyLedgerEntry."Amount(LCY)" := -(_rolloveredInterest + _rolloveredPrincipal);
                                relatedpartyLedgerEntry."Remaining Amount" := -(_rolloveredInterest + _rolloveredPrincipal);
                                if FundSource = '' then
                                    relatedpartyLedgerEntry."Bal. Account No." := GenSetup."Opening  Balance Acc";
                                relatedpartyLedgerEntry.Insert();
                                if (EnableGLPosting = true) then
                                    RelatedpartyMgt.DirectGLPosting('init', principleAcc, withHoldingAcc, -(_rolloveredInterest + _rolloveredPrincipal), 0, 'Original Amount ::Patial Principal+Interest Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code")
                            end;
                        end;
                    end else begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", "Original Record No.");
                        if _funderLoan.Find('-') then begin
                            _rolloveredInterest := "Rollovered Interest";
                            _rolloveredPrincipal := "Original Disbursed Amount";

                            looper.LockTable();
                            looper.Reset();
                            if looper.FindLast() then
                                NextEntryNo := looper."Entry No." + 1
                            else
                                NextEntryNo := 1;

                            relatedpartyLedgerEntry.Init();
                            relatedpartyLedgerEntry."Entry No." := NextEntryNo;
                            relatedpartyLedgerEntry."RelatedParty No." := _funderLoan."RelatedParty No.";
                            relatedpartyLedgerEntry."Related  Name" := _funderLoan.Name;
                            relatedpartyLedgerEntry."Loan No." := _funderLoan."No.";
                            relatedpartyLedgerEntry."Loan Name" := _funderLoan."Loan Name";
                            relatedpartyLedgerEntry."Posting Date" := Today;
                            relatedpartyLedgerEntry."Document Type" := relatedpartyLedgerEntry."Document Type"::"Original Amount";
                            relatedpartyLedgerEntry."Document No." := _docNo;
                            relatedpartyLedgerEntry."Origin Entry" := relatedpartyLedgerEntry."Origin Entry"::RelatedParty;
                            relatedpartyLedgerEntry."Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
                            relatedpartyLedgerEntry.Category := Category; // Funder Loan Category
                            relatedpartyLedgerEntry.Category_Line := Category_line_No; // Funder Loan Category
                            relatedpartyLedgerEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Full Rollover Offset';
                            relatedpartyLedgerEntry."Currency Code" := Currency;
                            relatedpartyLedgerEntry.Amount := -_rolloveredPrincipal;
                            relatedpartyLedgerEntry."Amount(LCY)" := -_ConvertedCurrency;
                            relatedpartyLedgerEntry."Remaining Amount" := _rolloveredPrincipal;
                            if FundSource = '' then
                                relatedpartyLedgerEntry."Bal. Account No." := GenSetup."Opening  Balance Acc";
                            relatedpartyLedgerEntry.Insert();
                            if (EnableGLPosting = true) then
                                RelatedpartyMgt.DirectGLPosting('reverse-interest', principleAcc, withHoldingAcc, -_rolloveredInterest, 0, 'Original Amount :: Rollover Interest Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");

                            _funderLoan.State := _funderLoan.State::Terminated;
                            _funderLoan.Modify();// Dispose of the Loan Record
                        end;
                    end;


                    relatedpartyLedgerEntry.Reset();
                    if relatedpartyLedgerEntry.FindLast() then
                        NextEntryNo := relatedpartyLedgerEntry."Entry No." + 2;


                    relatedpartyLedgerEntry.Init();
                    relatedpartyLedgerEntry."Entry No." := NextEntryNo;
                    relatedpartyLedgerEntry."RelatedParty No." := "RelatedParty No.";
                    relatedpartyLedgerEntry."Related  Name" := Name;
                    relatedpartyLedgerEntry."Loan Name" := "Loan Name";
                    relatedpartyLedgerEntry."Loan No." := "No.";
                    relatedpartyLedgerEntry."Posting Date" := Today;
                    relatedpartyLedgerEntry.Category := Category; // Funder Loan Category
                    relatedpartyLedgerEntry."Document No." := _docNo;
                    relatedpartyLedgerEntry."Origin Entry" := relatedpartyLedgerEntry."Origin Entry"::RelatedParty;
                    relatedpartyLedgerEntry."Document Type" := relatedpartyLedgerEntry."Document Type"::Interest;
                    relatedpartyLedgerEntry.Description := "No." + ' ' + Name + ' ' + _portfolio.Code + '-' + "Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>');
                    relatedpartyLedgerEntry.Amount := "Rollovered Interest";
                    relatedpartyLedgerEntry."Amount(LCY)" := "Rollovered Interest";
                    relatedpartyLedgerEntry."Remaining Amount" := "Rollovered Interest";
                    relatedpartyLedgerEntry.Insert();
                    if (EnableGLPosting = true) and ("Rollovered Interest" <> 0) then
                        RelatedpartyMgt.DirectGLPosting('interest', principleAcc, withHoldingAcc, "Rollovered Interest", 0, 'Interest', "No.", interestAccPay, '', '', '', "Bank Ref. No.", _relatedParty."Shortcut Dimension 1 Code");//GROSS Interest

                    Rollovered := Rollovered::Normal;
                    // "Rollovered Interest" := 0;
                end;


            end;
        }

        field(620; "Original Disbursed Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            //Original Value shifted to Status
        }
        // field(630; "Original Disbursed Amount(LCY)"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(630; "Document Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(730; "Secured Loan"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Debenture","Parent Guarantee","Personal/Director Guarantee";
        }
        field(731; "Secured Loan Other"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Debenture","Parent Guarantee","Personal/Director Guarantee";

        }
        field(830; "UnSecured Loan"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Parent Guarantee","Unsecured";
        }
        //FLOATS
        field(930; "Reference Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(932; Margin; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(934; "Outstanding Interest"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Interest | "Capitalized Interest" | "Interest Paid" | "Reversed Interest")));
            Caption = 'Outstanding Interest';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(935; "Withholding Tax Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Withholding)));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }

        field(940; PeriodicPaymentOfInterest; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "","Monthly","Quarterly","Biannually","Annually";
        }
        field(941; PeriodicPaymentOfPrincipal; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "","Monthly","Quarterly","Biannually","Annually","Total at Due Date";
            //"Total at Due Date"
        }

        field(1000; "OriginalPlusAccrued"; Decimal)
        {
            // DataClassification = ToBeClassified;
            // Caption = 'Original Amount in disbursed';
            AutoFormatType = 1;
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Original Amount' | Interest)));
            Caption = 'Original Amount + Accrued Intrest';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(2000; CustomFX; Boolean)
        {
            DataClassification = ToBeClassified;
        }


        // field(2609; InvestmentTenor; Integer)
        // {
        //     // OptionMembers = "12","15","18","24";
        //     DataClassification = ToBeClassified;
        // }
        field(2610; PoliticalExposure; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(2700; "Extension Paradign"; Text[50])
        {
            ToolTip = 'Indicates operations related to this extension';
            InitValue = 'FunderLoan';
            DataClassification = ToBeClassified;
            //Used by the attachment Document
        }

        //Funder Posting G/L Accounts
        field(2800; "Payables Account"; Code[20])
        {
            Caption = 'Payables Account';
            TableRelation = "G/L Account";
        }
        field(2801; "Interest Expense"; Code[20])
        {
            Caption = 'Interest Expense';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Interest Expense" := "Interest Expense";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }
        field(2802; "Interest Payable"; Code[20])
        {
            Caption = 'Interest Payable';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Interest Payable" := "Interest Payable";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }

        field(2810; PlacementMaturity; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Principal,Interest,"Principal + Interest",Terminate;
        }
        field(2820; "Confirmation Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(2920; "Bank Ref. No."; Code[100])
        {
            DataClassification = ToBeClassified;

        }
        field(2830; "FirstDueDate"; Date)
        {
            DataClassification = ToBeClassified;
            // Caption = 'Interest Due Date';
            trigger OnValidate()
            begin
                // if PeriodicPaymentOfInterest = PeriodicPaymentOfInterest::Quarterly then
                // TreasuryCU.ValidateQuarterEndDate("FirstDueDate");
            end;
        }

        field(606; EnableDynamicPeriod; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable Dynamic Period Reporting';
            InitValue = false;
        }
        field(607; EnableWeekDayReporting; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Remove WeekEnd Reporting';
            InitValue = false;
        }

        field(608; EnableDynamicPeriod_Payment; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable Dynamic Period Reporting';
            InitValue = false;
        }
        field(609; EnableWeekDayReporting_Payment; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Remove WeekEnd Reporting';
            InitValue = false;
        }
        field(2831; SecondDueDate; Date)
        {
            DataClassification = ToBeClassified;
            // Caption = 'Payment Due Date';
            trigger OnValidate()
            begin
                // if PeriodicPaymentOfInterest = PeriodicPaymentOfInterest::Quarterly then
                //     TreasuryCU.ValidateQuarterEndDate(SecondDueDate);
            end;
        }
        field(2835; LoanDurationDays; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Loan Duration Days';
            // NotBlank = true;
        }

        field(2836; NetInterestRate; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if NetInterestRate <> 0 then begin
                    // Formula
                    InterestRate := NetInterestRate / ((100 - Withldtax) / 100);
                end;

            end;

        }
        //Rollovered Record related
        field(3000; Rollovered; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Roll overed",Normal;
        }
        field(3001; "Original Record No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3002; "Rollovered Interest"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        // ****************** REDEMPTION FIELD ************
        field(3500; "Final Float"; Decimal)
        {
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter("Original Amount" | Repayment | "Secondary Amount" | Interest | "Interest Paid" | Withholding | "Capitalized Interest")));
            // Caption = 'Net Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(3509; AccruedIntr_WthdoldingTax; Decimal)
        {
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Interest | Withholding)));
            // Caption = 'Net Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(3515; WthdoldingTax; Decimal)
        {
            CalcFormula = sum(RelatedLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Withholding)));
            // Caption = 'Net Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(3501; State; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Active,Terminated;
        }

        // Encumbrance Fields
        field(4000; "Encumbrance Input"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                "G/L Account": Record "G/L Account";
            begin
                GenSetup.Get(0);
                "G/L Account".Reset();
                "G/L Account".SetRange("No.", GenSetup."Total Asset G/L");
                if "G/L Account".Find('-') then begin
                    "G/L Account".CalcFields(Balance);
                    "Total Asset Value" := "G/L Account".Balance;

                    "Encumbrance Percentage" := ("Encumbrance Input" / "Total Asset Value") * 100;
                end;
            end;
        }

        field(4005; "Total Asset Value"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(4010; "Encumbrance Percentage"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if "Encumbrance Percentage" <> 0 then
                    "Encumbrance Input" := ("Encumbrance Percentage" / 100) * "Original Disbursed Amount";
            end;
        }

        // Tranche Fields

        field(4015; "Tranche Loan"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }
        field(4017; "Total Payed"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        // Loan Repayment under Bank Loan Category
        field(5000; "Origin Entry"; Option)
        {

            DataClassification = ToBeClassified;
            OptionMembers = Funder,RelatedParty;
        }

        field(40200; "Repayment Frequency"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        // field(40210; "Repayment interest"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }

        field(40220; "Repayment Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }



    }

    keys
    {
        key(PK; "No.", "Loan Name")
        {
            Clustered = true;
        }
        // key(FK; "Loan Name")
        // {
        //     Unique = true;
        // }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        vPostingGroup: Record "Treasury Posting Group";
        TreasuryCU: Codeunit "Treasury Mgt CU";

    trigger OnInsert()
    begin
        GenSetup.Get(0);
        GenSetup.TestField("Funder Loan No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true);
        if "Loan Name" = '' then
            "Loan Name" := NoSer.GetNextNo(GenSetup."Loan No.", 0D, true);

        "Status" := "Status"::Open;
        vPostingGroup.Reset();
        vPostingGroup.SetRange(Code, "No.");
        // vPostingGroup.SetRange(vPostingGroup."Treasury Enabled (Local)", true);
        if vPostingGroup.Find('-') then
            "Posting Group" := vPostingGroup.Code
        else begin
            vPostingGroup.Init();
            vPostingGroup.Code := "No.";
            vPostingGroup.Insert();

            "Posting Group" := vPostingGroup.Code;
        end;


        // Error('Please set the default Local Posting Group');

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