table 50232 "Funder Loan"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Funder Loan List";
    DrillDownPageId = "Funder Loan List";
    DataCaptionFields = "No.", "Loan Name";
    fields
    {
        field(1; "No."; Code[10])
        {
            //NotBlank = true;
            DataClassification = ToBeClassified;
        }
        field(20; "Funder No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Funder No.';
            trigger OnValidate()
            var
                Funder: Record Funders;
                Portfolio: Record Portfolio;
                "Funder Loan Category": Record "Funder Loan Category";
            begin
                Funder.Reset();
                Funder.SetRange("No.", "Funder No.");
                if Funder.Find('-') then begin
                    Name := Funder.Name;

                    if Funder.FunderType <> Funder.FunderType::"Bank Overdraft" then begin
                        if Funder."Payables Account" = '' then begin // Not applicable in  Bank Overdraft.
                            Error('Payable A/c Missing');
                            exit;
                        end;
                    end;

                    if Funder."Interest Expense" = '' then begin
                        Error('Interest Expense A/c Missing');
                        exit;
                    end;
                    if Funder."Interest Payable" = '' then begin
                        Error('Interest Payable A/c Missing');
                        exit;
                    end;
                    "Payables Account" := Funder."Payables Account";
                    Rec.Validate("Payables Account");
                    "Interest Expense" := Funder."Interest Expense";
                    Rec.Validate("Interest Expense");
                    "Interest Payable" := Funder."Interest Payable";
                    Rec.Validate("Interest Payable");

                    Portfolio.Reset();
                    Portfolio.SetRange("No.", Funder.Portfolio);
                    if Portfolio.Find('-') then begin
                        if Portfolio.Category = Portfolio.Category::"Bank Loan" then
                            Category := 'Bank Loan';
                        if Portfolio.Category = Portfolio.Category::Individual then
                            Category := 'Individual';
                        if Portfolio.Category = Portfolio.Category::Institutional then
                            Category := 'Institutional';
                        if Portfolio.Category = Portfolio.Category::"Bank Overdraft" then
                            Category := 'Bank Overdraft';
                        if Portfolio.Category = Portfolio.Category::"Medium Term Notes" then
                            Category := 'Medium Term Notes';
                        if Portfolio.Category = Portfolio.Category::"Asset Term Manager" then
                            Category := 'Asset Term Manager';
                        if Portfolio.Category = Portfolio.Category::Relatedparty then
                            Category := 'Relatedparty';


                        "Portfolio No." := Portfolio."No.";
                        "Portfolio Name" := Portfolio.Code;
                        Category_line_No := Portfolio.Category_Line_No;
                        Rec.Validate(Category);

                        //Update Funder Loan Category Table
                        "Funder Loan Category".Reset();
                        "Funder Loan Category".SetRange(Code, Category);
                        if not "Funder Loan Category".Find('-') then begin
                            "Funder Loan Category".Init();
                            "Funder Loan Category".Code := Category;
                            "Funder Loan Category".Value := Category;
                            "Funder Loan Category".Insert();
                        end;

                    end;

                    InvstPINNo := Funder.KRA;
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
                    if Today - PlacementDate < 0 then
                        Error('Date cannot be in the future');
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
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Original Amount')));
            Caption = 'Original Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(504; "OutstandingAmntDisbLCY"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Original Amount' | Repayment | "Secondary Amount")));
            Caption = 'Outstanding Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;

        }
        field(505; "InterestRate"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 4;
            trigger OnValidate()
            begin
                // if InterestRate <> 0 then
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
            // Caption = 'Withholding tax applied (%)';
            trigger OnValidate()
            begin
                // if InterestRate < 0 then
                //     NetInterestRate := ((100 - Withldtax) / 100) * InterestRate;
                // if NetInterestRate < 0 then
                //     InterestRate := NetInterestRate / ((100 - Withldtax) / 100);

            end;
        }
        field(510; "TaxStatus"; Enum TaxStatus)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tax status (Tax Exempt or Taxable)';
        }
        field(511; "GrossInterestamount"; Decimal)
        {
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Interest')));
            Caption = 'Gross Interest amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(512; "NetInterestamount"; Decimal)
        {
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Interest' | 'Interest Paid' | Withholding | "Capitalized Interest")));
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

        field(611; EnableDynamicPeriod_AmortCap; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable Dynamic Period Reporting';
            InitValue = false;
        }
        field(612; EnableWeekDayRep_AmortCap; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Remove WeekEnd Reporting';
            InitValue = false;
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
                funderLegderEntry: Record FunderLedgerEntry;
                funderLegderEntry1: Record FunderLedgerEntry;
                funderLegderEntry2: Record FunderLedgerEntry;
                funderLegderEntry3: Record FunderLedgerEntry;
                looper: Record FunderLedgerEntry;
                NextEntryNo: Integer;
                FunderMgt: Codeunit FunderMgtCU;
                venPostingGroup: Record "Treasury Posting Group";
                principleAcc: Code[20];
                interestAcc: Code[20];
                interestAccPay: Code[20];
                withHoldingAcc: Code[20];
                ReversalEntry: Record "Reversal Entry";
                _docNo: Code[20];
                TrsyMgt: Codeunit "Treasury Mgt CU";
                _ConvertedCurrency: Decimal; // Principal
                _ConvertedCurrencyInterest: Decimal;
                _funder: Record Funders;
                _portfolio: Record Portfolio;

                _funderLoan: Record "Funder Loan";
                _rolloverTbl: Record "Roll over Tbl";
                _rolloveredInterest: Decimal;
                _rolloveredPrincipal: Decimal;

            begin
                if not (Status = Status::Approved) then
                    exit;

                GenSetup.Get(0);

                _funder.Reset();
                _funder.SetRange("No.", "Funder No.");
                if not _funder.Find('-') then
                    Error('Funder %1 not found _fl', "Funder No.");

                if not (_funder.Status = _funder.Status::Approved) then
                    Error('Funder %1 must be Approved', "Funder No.");

                _portfolio.Reset();
                _portfolio.SetRange("No.", _funder.Portfolio);
                if not _portfolio.Find('-') then
                    Error('Portfolio %1 not found _fl', _funder.Portfolio);

                _docNo := TrsyMgt.GenerateDocumentNumber();
                //Get Posting groups
                /*if not venPostingGroup.Get("Posting Group") then
                    Error('Missing Posting Group: %1', "No.");*/
                if EnableGLPosting = true then begin
                    if Rollovered <> Rollovered::"Roll overed" then begin
                        if FundSource = '' then
                            Error('Funder Entry (Bank) Must have a value', FundSource);
                    end;
                end;

                // principleAcc := venPostingGroup."Payables Account";
                // interestAcc := venPostingGroup."Interest Expense";
                principleAcc := "Payables Account";
                interestAcc := "Interest Expense";
                interestAccPay := "Interest Payable";
                withHoldingAcc := GenSetup.FunderWithholdingAcc;

                if Category <> UpperCase('Bank Overdraft') then begin
                    if principleAcc = '' then
                        Error('Missing G/L - Principle A/C');
                    if interestAcc = '' then
                        Error('Missing G/L - Interest Expense A/C');
                    if interestAccPay = '' then
                        Error('Missing G/L - Interest Payable A/C');
                    if "Bank Ref. No." = '' then
                        Error('Missing Bank Reference No.');
                    if withHoldingAcc = '' then
                        Error('Missing Withholding No.');

                    if "Original Disbursed Amount" = 0 then
                        Error('Original Disbursed Amount Required');
                    // if InterestRate = 0 then
                    //     Error('Gross Interest rate (p.a) Required');


                end;
                if EnableGLPosting = true then
                    if FundSource = '' then
                        Error('Receiving Bank A/c Required');


                if Currency <> '' then begin
                    _ConvertedCurrency := FunderMgt.ConvertCurrencyAmount(Currency, "Original Disbursed Amount", CustomFX);
                    _ConvertedCurrencyInterest := FunderMgt.ConvertCurrencyAmount(Currency, "Rollovered Interest", CustomFX)
                end
                else begin
                    _ConvertedCurrency := "Original Disbursed Amount";
                    _ConvertedCurrencyInterest := "Rollovered Interest";
                end;

                if Rollovered <> Rollovered::"Roll overed" then begin
                    funderLegderEntry.Reset();
                    funderLegderEntry.SetRange(funderLegderEntry."Document Type", funderLegderEntry."Document Type"::"Original Amount");
                    funderLegderEntry.SetRange(funderLegderEntry."Loan No.", "No.");
                    if funderLegderEntry.Find('-') then begin
                        funderLegderEntry."Modification Date" := Today;
                        funderLegderEntry."Modification User" := UserId;
                        funderLegderEntry.Amount := DisbursedCurrency;
                        funderLegderEntry."Amount(LCY)" := _ConvertedCurrency;
                        funderLegderEntry."Remaining Amount" := DisbursedCurrency;
                        funderLegderEntry.Modify();

                        //  Clear(ReversalEntry);
                        //     if Rec.Reversed then
                        //         ReversalEntry.AlreadyReversedEntry(Rec.TableCaption, Rec."Entry No.");
                        //     // CheckEntryPostedFromJournal();
                        //       Rec.TestField("No.");
                        //     ReversalEntry.ReverseTransaction(Rec."No.")


                    end
                    else begin
                        looper.LockTable();
                        looper.Reset();
                        if looper.FindLast() then
                            NextEntryNo := looper."Entry No." + 1
                        else
                            NextEntryNo := 1;
                        funderLegderEntry.Init();
                        funderLegderEntry."Entry No." := NextEntryNo;
                        funderLegderEntry."Funder No." := "Funder No.";
                        funderLegderEntry."Funder Name" := Name;
                        funderLegderEntry."Loan No." := "No.";
                        funderLegderEntry."Loan Name" := "Loan Name";
                        funderLegderEntry."Posting Date" := Today;
                        funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Original Amount";
                        funderLegderEntry."Document No." := _docNo;
                        funderLegderEntry."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                        funderLegderEntry.Category := Category; // Funder Loan Category
                        funderLegderEntry.Category_Line := Category_line_No; // Funder Loan Category
                                                                             // funderLegderEntry."Transaction Type" := funderLegderEntry."Transaction Type"::"Original Amount";
                                                                             //  _funderLoan."No." + ' ' + _funderLoan."No." + '-' + _funderLoan."Bank Ref. No." + '-' + Format(_funderLoan.PlacementDate) + Format(_funderLoan.MaturityDate) +
                        funderLegderEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate);
                        funderLegderEntry."Currency Code" := Currency;
                        funderLegderEntry.Amount := "Original Disbursed Amount";
                        funderLegderEntry."Amount(LCY)" := _ConvertedCurrency;
                        funderLegderEntry."Remaining Amount" := "Original Disbursed Amount";


                        funderLegderEntry."Bal. Account No." := principleAcc;
                        funderLegderEntry."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account";
                        if FundSource = '' then begin
                            funderLegderEntry."Account No." := GenSetup."Opening  Balance Acc";
                            funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"G/L Account";
                        end else begin
                            funderLegderEntry."Account No." := FundSource;
                            funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"Bank Account";
                        end;

                        funderLegderEntry.Insert();
                        // Commit();
                        if (EnableGLPosting = true) then
                            FunderMgt.DirectGLPosting('init', principleAcc, withHoldingAcc, "Original Disbursed Amount", 0, 'Original Amount', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _funder."Shortcut Dimension 1 Code")
                    end;
                end;

                // ++++++++++++++++  CHECK ROLLOVER RECORD AND VALIDATE INTREST.
                if Rollovered = Rollovered::"Roll overed" then begin

                    //Act on the parent loan (Loan that was partially rollovered)
                    _rolloverTbl.Reset();
                    _rolloverTbl.SetRange("Loan No.", "Original Record No.");
                    if not _rolloverTbl.Find('-') then
                        Error('No rollover Log found for Loan %1', "Original Record No.");

                    if false then begin //_rolloverTbl.RollOverType = _rolloverTbl.RollOverType::"Partial Rollover"
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

                                funderLegderEntry.Init();
                                funderLegderEntry."Entry No." := NextEntryNo;
                                funderLegderEntry."Funder No." := _funderLoan."Funder No.";
                                funderLegderEntry."Funder Name" := _funderLoan.Name;
                                funderLegderEntry."Loan No." := _funderLoan."No.";
                                funderLegderEntry."Loan Name" := _funderLoan."Loan Name";
                                funderLegderEntry."Posting Date" := Today;
                                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Original Amount";
                                funderLegderEntry."Document No." := _docNo;
                                funderLegderEntry."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                                funderLegderEntry.Category := Category; // Funder Loan Category
                                funderLegderEntry.Category_Line := Category_line_No; // Funder Loan Category
                                funderLegderEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Patial Principal Offset';
                                funderLegderEntry."Currency Code" := Currency;
                                funderLegderEntry.Amount := -_rolloveredPrincipal;
                                funderLegderEntry."Amount(LCY)" := -_ConvertedCurrency;
                                funderLegderEntry."Remaining Amount" := _rolloveredPrincipal;

                                funderLegderEntry."Bal. Account No." := principleAcc;
                                funderLegderEntry."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account";
                                if FundSource = '' then begin
                                    funderLegderEntry."Account No." := GenSetup."Opening  Balance Acc";
                                    funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"G/L Account";
                                end else begin
                                    funderLegderEntry."Account No." := FundSource;
                                    funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"Bank Account";
                                end;

                                funderLegderEntry.Insert();
                                if (EnableGLPosting = true) and (Round(_rolloveredPrincipal, 1, '=') <> 0) then
                                    FunderMgt.DirectGLPosting('init', principleAcc, withHoldingAcc, -_rolloveredPrincipal, 0, 'Original Amount ::Patial Principal Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _funder."Shortcut Dimension 1 Code")
                            end;
                            // Interest 
                            if _funderLoan.PlacementMaturity = _funderLoan.PlacementMaturity::Interest then begin
                                looper.LockTable();
                                looper.Reset();
                                if looper.FindLast() then
                                    NextEntryNo := looper."Entry No." + 1
                                else
                                    NextEntryNo := 1;

                                funderLegderEntry.Init();
                                funderLegderEntry."Entry No." := NextEntryNo + 2;
                                funderLegderEntry."Funder No." := _funderLoan."Funder No.";
                                funderLegderEntry."Funder Name" := _funderLoan.Name;
                                funderLegderEntry."Loan No." := _funderLoan."No.";
                                funderLegderEntry."Loan Name" := _funderLoan."Loan Name";
                                funderLegderEntry."Posting Date" := Today;
                                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                                funderLegderEntry."Document No." := _docNo;
                                funderLegderEntry."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                                funderLegderEntry.Category := Category; // Funder Loan Category
                                funderLegderEntry.Category_Line := Category_line_No; // Funder Loan Category
                                funderLegderEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Patial Interest Offset';
                                funderLegderEntry."Currency Code" := Currency;
                                funderLegderEntry.Amount := -_rolloveredInterest;
                                funderLegderEntry."Amount(LCY)" := -_ConvertedCurrency;
                                funderLegderEntry."Remaining Amount" := _rolloveredInterest;

                                funderLegderEntry."Account No." := _funderLoan."Interest Expense";
                                funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"G/L Account"; // Exp
                                funderLegderEntry."Bal. Account No." := _funderLoan."Interest Payable";
                                funderLegderEntry."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account"; //Payable
                                funderLegderEntry."Bal. Account No. 2" := withholdingAcc; // Wth
                                funderLegderEntry."Bal. Account Type 2" := funderLegderEntry."Bal. Account Type"::"G/L Account"; //Wth

                                funderLegderEntry.Insert();
                                if (EnableGLPosting = true) and (Round(_rolloveredInterest, 1, '=') <> 0) then
                                    FunderMgt.DirectGLPosting('interest', principleAcc, withHoldingAcc, -_rolloveredInterest, 0, 'Original Amount ::Patial Interest Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _funder."Shortcut Dimension 1 Code")
                            end;
                            // Principal + Interest
                            if _funderLoan.PlacementMaturity = _funderLoan.PlacementMaturity::"Principal + Interest" then begin
                                looper.LockTable();
                                looper.Reset();
                                if looper.FindLast() then
                                    NextEntryNo := looper."Entry No." + 1
                                else
                                    NextEntryNo := 1;

                                funderLegderEntry.Init();
                                funderLegderEntry."Entry No." := NextEntryNo + 3;
                                funderLegderEntry."Funder No." := _funderLoan."Funder No.";
                                funderLegderEntry."Funder Name" := _funderLoan.Name;
                                funderLegderEntry."Loan No." := _funderLoan."No.";
                                funderLegderEntry."Loan Name" := _funderLoan."Loan Name";
                                funderLegderEntry."Posting Date" := Today;
                                funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Original Amount";
                                funderLegderEntry."Document No." := _docNo;
                                funderLegderEntry."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                                funderLegderEntry.Category := Category; // Funder Loan Category
                                funderLegderEntry.Category_Line := Category_line_No; // Funder Loan Category
                                funderLegderEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Patial Principal+Interest Offset';
                                funderLegderEntry."Currency Code" := Currency;
                                funderLegderEntry.Amount := -(_rolloveredInterest + _rolloveredPrincipal);
                                funderLegderEntry."Amount(LCY)" := -(_rolloveredInterest + _rolloveredPrincipal);
                                funderLegderEntry."Remaining Amount" := -(_rolloveredInterest + _rolloveredPrincipal);

                                funderLegderEntry."Bal. Account No." := principleAcc;
                                funderLegderEntry."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account";
                                if FundSource = '' then begin
                                    funderLegderEntry."Account No." := GenSetup."Opening  Balance Acc";
                                    funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"G/L Account";
                                end else begin
                                    funderLegderEntry."Account No." := FundSource;
                                    funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"Bank Account";
                                end;

                                funderLegderEntry.Insert();
                                if (EnableGLPosting = true) and ((_rolloveredInterest + _rolloveredPrincipal) <> 0) then
                                    FunderMgt.DirectGLPosting('init', principleAcc, withHoldingAcc, -(_rolloveredInterest + _rolloveredPrincipal), 0, 'Original Amount ::Patial Principal+Interest Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _funder."Shortcut Dimension 1 Code")
                            end;
                        end;
                    end
                    else begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", "Original Record No.");
                        if _funderLoan.Find('-') then begin
                            _rolloveredInterest := "Rollovered Interest";
                            // _rolloveredPrincipal := "Original Disbursed Amount";
                            _rolloveredPrincipal := "Rollovered Principal";

                            looper.LockTable();
                            looper.Reset();
                            if looper.FindLast() then
                                NextEntryNo := looper."Entry No." + 1
                            else
                                NextEntryNo := 1;
                            //Remove Principal from Original Record
                            funderLegderEntry.Init();
                            funderLegderEntry."Entry No." := NextEntryNo;
                            funderLegderEntry."Funder No." := _funderLoan."Funder No.";
                            funderLegderEntry."Funder Name" := _funderLoan.Name;
                            funderLegderEntry."Loan No." := _funderLoan."No.";
                            funderLegderEntry."Loan Name" := _funderLoan."Loan Name";
                            funderLegderEntry."Posting Date" := Today;
                            funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::"Original Amount";
                            funderLegderEntry."Document No." := _docNo;
                            funderLegderEntry."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                            funderLegderEntry.Category := Category; // Funder Loan Category
                            funderLegderEntry.Category_Line := Category_line_No; // Funder Loan Category
                            funderLegderEntry.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Full Rollover Offset';
                            funderLegderEntry."Currency Code" := Currency;
                            funderLegderEntry.Amount := -(_rolloveredPrincipal);
                            funderLegderEntry."Amount(LCY)" := -(_ConvertedCurrency);
                            funderLegderEntry."Remaining Amount" := (_rolloveredPrincipal);

                            funderLegderEntry."Bal. Account No." := principleAcc;
                            funderLegderEntry."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account";
                            if FundSource = '' then begin
                                funderLegderEntry."Account No." := GenSetup."Opening  Balance Acc";
                                funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"G/L Account";
                            end else begin
                                funderLegderEntry."Account No." := FundSource;
                                funderLegderEntry."Account Type" := funderLegderEntry."Account Type"::"Bank Account";
                            end;

                            funderLegderEntry.Insert();
                            if (EnableGLPosting = true) and (Round(_rolloveredPrincipal, 1, '=') <> 0) then
                                FunderMgt.DirectGLPosting('init-rollover', principleAcc, withHoldingAcc, -_rolloveredPrincipal, 0, 'Original Amount ::Full Rollover Offset', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _funder."Shortcut Dimension 1 Code");


                            looper.LockTable();
                            looper.Reset();
                            if looper.FindLast() then
                                NextEntryNo := looper."Entry No." + 2
                            else
                                NextEntryNo := 1;
                            //Remove Interest from Original Record
                            funderLegderEntry1.Init();
                            funderLegderEntry1."Entry No." := NextEntryNo;
                            funderLegderEntry1."Funder No." := _funderLoan."Funder No.";
                            funderLegderEntry1."Funder Name" := _funderLoan.Name;
                            funderLegderEntry1."Loan No." := _funderLoan."No.";
                            funderLegderEntry1."Loan Name" := _funderLoan."Loan Name";
                            funderLegderEntry1."Posting Date" := Today;
                            funderLegderEntry1."Document Type" := funderLegderEntry1."Document Type"::"Reversed Interest";
                            funderLegderEntry1."Document No." := _docNo;
                            funderLegderEntry1."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                            funderLegderEntry1.Category := Category; // Funder Loan Category
                            funderLegderEntry1.Category_Line := Category_line_No; // Funder Loan Category
                            funderLegderEntry1.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + ' Rollover Intrest Offest';
                            funderLegderEntry1."Currency Code" := Currency;
                            funderLegderEntry1.Amount := -_rolloveredInterest;
                            funderLegderEntry1."Amount(LCY)" := -_ConvertedCurrencyInterest;
                            funderLegderEntry1."Remaining Amount" := _rolloveredInterest;

                            funderLegderEntry1."Account No." := _funderLoan."Interest Expense";
                            funderLegderEntry1."Account Type" := funderLegderEntry."Account Type"::"G/L Account"; // Exp
                            funderLegderEntry1."Bal. Account No." := _funderLoan."Interest Payable";
                            funderLegderEntry1."Bal. Account Type" := funderLegderEntry."Bal. Account Type"::"G/L Account"; //Payable
                            funderLegderEntry1."Bal. Account No. 2" := withholdingAcc; // Wth
                            funderLegderEntry1."Bal. Account Type 2" := funderLegderEntry."Bal. Account Type"::"G/L Account"; //Wth

                            // if FundSource = '' then
                            //     funderLegderEntry."Bal. Account No." := GenSetup."Opening  Balance Acc";
                            funderLegderEntry1.Insert();
                            if (EnableGLPosting = true) and (Round(_rolloveredInterest, 1, '=') <> 0) then
                                FunderMgt.DirectGLPosting('reverse-interest', principleAcc, withHoldingAcc, -_rolloveredInterest, 0, 'Original Amount :: Rollover Interest Offset', "No.", interestAccPay, Currency, "Posting Group", _docNo, "Bank Ref. No.", _funder."Shortcut Dimension 1 Code");


                            looper.LockTable();
                            looper.Reset();
                            if looper.FindLast() then
                                NextEntryNo := looper."Entry No." + 3
                            else
                                NextEntryNo := 1;

                            //Current Record Original Disbursed Amount + Interest auto-resolve
                            funderLegderEntry2.Init();
                            funderLegderEntry2."Entry No." := NextEntryNo;
                            funderLegderEntry2."Funder No." := "Funder No.";
                            funderLegderEntry2."Funder Name" := Name;
                            funderLegderEntry2."Loan No." := "No.";
                            funderLegderEntry2."Loan Name" := "Loan Name";
                            funderLegderEntry2."Posting Date" := Today;
                            funderLegderEntry2."Document Type" := funderLegderEntry2."Document Type"::"Original Amount";
                            funderLegderEntry2."Document No." := _docNo;
                            funderLegderEntry2."Shortcut Dimension 1 Code" := _funder."Shortcut Dimension 1 Code";
                            funderLegderEntry2.Category := Category; // Funder Loan Category
                            funderLegderEntry2.Category_Line := Category_line_No; // Funder Loan Category
                            funderLegderEntry2.Description := "No." + ' ' + Name + '-' + "Bank Ref. No." + '-' + Format(PlacementDate) + ' ' + Format(MaturityDate) + ' ::' + 'Rollover New Value';
                            funderLegderEntry2."Currency Code" := Currency;
                            funderLegderEntry2.Amount := (_rolloveredPrincipal + _rolloveredInterest);
                            funderLegderEntry2."Amount(LCY)" := (_ConvertedCurrency + _ConvertedCurrencyInterest);
                            funderLegderEntry2."Remaining Amount" := (_rolloveredPrincipal + _rolloveredInterest);

                            funderLegderEntry2."Bal. Account No." := principleAcc;
                            funderLegderEntry2."Bal. Account Type" := funderLegderEntry2."Bal. Account Type"::"G/L Account";
                            if FundSource = '' then begin
                                funderLegderEntry2."Account No." := GenSetup."Opening  Balance Acc";
                                funderLegderEntry2."Account Type" := funderLegderEntry2."Account Type"::"G/L Account";
                            end else begin
                                funderLegderEntry2."Account No." := FundSource;
                                funderLegderEntry2."Account Type" := funderLegderEntry2."Account Type"::"Bank Account";
                            end;

                            funderLegderEntry2.Insert();
                            if (EnableGLPosting = true) and (Round((_rolloveredPrincipal + _rolloveredInterest), 1, '=') <> 0) then
                                FunderMgt.DirectGLPosting('init-rollover', principleAcc, withHoldingAcc, (_rolloveredPrincipal + _rolloveredInterest), 0, 'Amount :: Rollover New Values', "No.", FundSource, Currency, "Posting Group", _docNo, "Bank Ref. No.", _funder."Shortcut Dimension 1 Code");


                            _funderLoan.State := _funderLoan.State::Active;
                            _funderLoan.Modify();// Dispose of the Loan Record
                        end;
                    end;


                    funderLegderEntry.Reset();
                    if funderLegderEntry.FindLast() then
                        NextEntryNo := funderLegderEntry."Entry No." + 2;

                    //Accruing Interest from the rollovered interest
                    /*if "Rollovered Interest" <> 0 then begin
                        funderLegderEntry.Init();
                        funderLegderEntry."Entry No." := NextEntryNo;
                        funderLegderEntry."Funder No." := "Funder No.";
                        funderLegderEntry."Funder Name" := Name;
                        funderLegderEntry."Loan Name" := "Loan Name";
                        funderLegderEntry."Loan No." := "No.";
                        funderLegderEntry."Posting Date" := Today;
                        funderLegderEntry.Category := Category; // Funder Loan Category
                        funderLegderEntry."Document No." := _docNo;
                        funderLegderEntry."Document Type" := funderLegderEntry."Document Type"::Interest;
                        funderLegderEntry.Description := "No." + ' ' + Name + ' ' + _portfolio.Code + '-' + "Bank Ref. No." + '-' + Format(Today, 0, '<Month Text> <Year4>');
                        funderLegderEntry.Amount := "Rollovered Interest";
                        funderLegderEntry."Amount(LCY)" := "Rollovered Interest";
                        funderLegderEntry."Remaining Amount" := "Rollovered Interest";
                        funderLegderEntry.Insert();
                        if (EnableGLPosting = true) and (Round("Rollovered Interest", 1, '=') <> 0) then
                            FunderMgt.DirectGLPosting('interest', principleAcc, withHoldingAcc, "Rollovered Interest", 0, 'Interest', "No.", interestAccPay, '', '', '', "Bank Ref. No.", _funder."Shortcut Dimension 1 Code");//GROSS Interest

                    end;*/

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
        field(928; "Group Reference Name"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(929; "Group Reference No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(930; "Reference Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(931; "Reference Rate Name"; Text[50])
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
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Interest | "Capitalized Interest" | "Interest Paid" | "Reversed Interest" | Withholding)));
            Caption = 'Outstanding Interest';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(935; "Withholding Tax Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Withholding)));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }

        field(940; PeriodicPaymentOfInterest; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Monthly","Quarterly","Biannually","Annually";
        }
        field(941; PeriodicPaymentOfPrincipal; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Monthly","Quarterly","Biannually","Annually","Total at Due Date";
            //"Total at Due Date"
        }
        field(942; AmortCapPaymentOfPrincipal; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Monthly","Quarterly","Biannually","Annually";
            //"Total at Due Date"
        }

        field(1000; "OriginalPlusAccrued"; Decimal)
        {
            // DataClassification = ToBeClassified;
            // Caption = 'Original Amount in disbursed';
            AutoFormatType = 1;
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter('Original Amount' | Interest)));
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
                //     TreasuryCU.ValidateQuarterEndDate("FirstDueDate");
            end;
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
        field(2832; ThirdDueDate; Date)
        {
            DataClassification = ToBeClassified;
            // Used by Amoritized Capitalized

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
            DecimalPlaces = 0 : 4;
            trigger OnValidate()
            begin
                // if NetInterestRate <> 0 then begin
                // Formula
                InterestRate := NetInterestRate / ((100 - Withldtax) / 100);
                // end;

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
        field(3003; "Rollovered Principal"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(3009; "Coupa Ref No."; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3010; "Overdraft Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        // ****************** REDEMPTION FIELD ************
        field(3500; "Final Float"; Decimal)
        {
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter("Original Amount" | Repayment | "Secondary Amount" | Interest | "Interest Paid" | Withholding | "Capitalized Interest")));
            // Caption = 'Net Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(3509; AccruedIntr_WthdoldingTax; Decimal)
        {
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Interest | Withholding)));
            // Caption = 'Net Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(3515; WthdoldingTax; Decimal)
        {
            CalcFormula = sum(FunderLedgerEntry.Amount where("Loan No." = field("No."), "Document Type" = filter(Withholding)));
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

        field(40221; "Inclusive Counting Interest"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }
        field(40222; "Inclusive Counting Payment"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }

        field(40223; "Add Day to Start Period"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(40225; "Portfolio No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(40227; "Portfolio Name"; Text[250])
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
        // key(FK; "No.")
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
        Funder: Record Funders;
        TreasuryCU: Codeunit "Treasury Mgt CU";

    trigger OnInsert()
    var
        _loan: Record "Funder Loan";
    begin
        GenSetup.Get(0);
        GenSetup.TestField("Funder Loan No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true);
        if "Loan Name" = '' then
            "Loan Name" := NoSer.GetNextNo(GenSetup."Loan No.", 0D, true);

        _loan.Reset();
        _loan.SetRange(_loan."No.", "No.");
        if _loan.Count() > 1 then begin
            Error('Duplicate Record No. %1', "No.");
        end;
        "Status" := "Status"::Open;
        // vPostingGroup.Reset();
        // vPostingGroup.SetRange(Code, "No.");
        // // vPostingGroup.SetRange(vPostingGroup."Treasury Enabled (Local)", true);
        // if vPostingGroup.Find('-') then
        //     "Posting Group" := vPostingGroup.Code
        // else begin
        //     vPostingGroup.Init();
        //     vPostingGroup.Code := "No.";
        //     vPostingGroup.Insert();

        //     "Posting Group" := vPostingGroup.Code;
        // end;


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