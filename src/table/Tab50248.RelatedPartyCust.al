table 50248 "RelatedParty- Cust"
{
    DataClassification = ToBeClassified;
    Caption = 'Customer/Related Party';
    LookupPageId = 50249;
    DrillDownPageId = 50249;
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; RelatedPName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(15; RelatedPSysRefNo; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; RelatedPCoupaRef; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(17; RelatedP_Email; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(18; RelatedP_Mobile; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(19; RelatedP_ContactPerson; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(20; RelatedP_ContactEmail; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(21; PlacementDate; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(25; MaturityDate; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(35; Currency; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(70; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                relatedLegderEntry: Record RelatedLedgerEntry;
                looper: Record RelatedLedgerEntry;
                NextEntryNo: Integer;
                RelatedMGTCU: Codeunit "RelatedCustomer Mgt CU";
                FunderMgt: Codeunit FunderMgtCU;
                principleAcc: Code[20];
                interestReceivable: Code[20];
                ReversalEntry: Record "Reversal Entry";
                _docNo: Code[20];
                TrsyMgt: Codeunit "Treasury Mgt CU";
                _ConvertedCurrency: Decimal;
            begin
                _docNo := TrsyMgt.GenerateDocumentNumber();
                principleAcc := "Principal Account";
                interestReceivable := "Interest Receivable";
                if principleAcc = '' then
                    Error('Missing G/L - Principle A/C');
                if interestReceivable = '' then
                    Error('Missing G/L - Interest Receivable A/C');
                if BankAcc = '' then
                    Error('Missing Bank Account');

                if Currency <> '' then
                    _ConvertedCurrency := FunderMgt.ConvertCurrencyAmount(Currency, Amount, false)
                else
                    _ConvertedCurrency := Amount;

                relatedLegderEntry.Reset();
                relatedLegderEntry.SetRange(relatedLegderEntry."Document Type", relatedLegderEntry."Document Type"::"Original Amount");
                relatedLegderEntry.SetRange(relatedLegderEntry."RelatedParty No.", "No.");
                if relatedLegderEntry.Find('-') then begin
                    relatedLegderEntry."Modification Date" := Today;
                    relatedLegderEntry."Modification User" := UserId;
                    relatedLegderEntry.Amount := Amount;
                    relatedLegderEntry."Amount(LCY)" := _ConvertedCurrency;
                    relatedLegderEntry."Remaining Amount" := Amount;
                    relatedLegderEntry.Modify();

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
                    relatedLegderEntry.Init();
                    relatedLegderEntry."Entry No." := NextEntryNo;
                    relatedLegderEntry."RelatedParty No." := "No.";
                    relatedLegderEntry."Related  Name" := RelatedPName;
                    relatedLegderEntry."Posting Date" := Today;
                    relatedLegderEntry."Document Type" := relatedLegderEntry."Document Type"::"Original Amount";
                    relatedLegderEntry."Document No." := _docNo;
                    // relatedLegderEntry."Transaction Type" := relatedLegderEntry."Transaction Type"::"Original Amount";
                    relatedLegderEntry.Description := 'Original Amount' + Format(Today);
                    relatedLegderEntry."Currency Code" := Currency;
                    relatedLegderEntry.Amount := Amount;
                    relatedLegderEntry."Amount(LCY)" := _ConvertedCurrency;
                    relatedLegderEntry."Remaining Amount" := Amount;
                    relatedLegderEntry.Insert();
                    Commit();
                    RelatedMGTCU.DirectGLPosting('init-relatedcust', principleAcc, Amount, 'Original Amount', "No.", BankAcc, Currency, '', _docNo)
                end;
            end;
        }
        field(36; PinNo; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(37; InterestRatePA; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(38; Withldtax; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(40; InterestRepaymentFreq; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Monthly","Quarterly","Biannually","Annually";
        }
        field(41; PrincipleRepaymentFreq; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Monthly","Quarterly","Biannually","Annually","Total at Due Date";

        }

        // field(42; RepaymentSchedule; Integer)
        // {
        //     DataClassification = ToBeClassified;
        // }
        // field(50; RelatePStatement; Text[250])
        // {
        //     DataClassification = ToBeClassified;
        // }
        // field(51; RelatePInvoice; Text[250])
        // {
        //     DataClassification = ToBeClassified;
        // }
        // field(52; RelatePCreationForm; Text[1050])
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(54; SourceOfFund; Option)
        {
            OptionMembers = Business,Salary,Pension,Dividends;
            DataClassification = ToBeClassified;

        }
        field(55; BankAcc; Text[250])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Bank Account"."No.";
        }
        field(57; InterestMethod; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Actual/365","Actual/360","30/360","Actual/364";
        }
        field(65; ContactPerson; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(66; CompanyRegNo; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(504; "OutstandingAmntDisbLCY"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum(RelatedLedgerEntry.Amount where("RelatedParty No." = field("No."), "Document Type" = filter('Original Amount' | Repayment | "Secondary Amount")));
            Caption = 'Outstanding Amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;

        }
        field(511; "GrossInterestamount"; Decimal)
        {
            CalcFormula = sum(RelatedLedgerEntry.Amount where("RelatedParty No." = field("No."), "Document Type" = filter('Interest')));
            Caption = 'Gross Interest amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(512; "NetInterestamount"; Decimal)
        {
            CalcFormula = sum(RelatedLedgerEntry.Amount where("RelatedParty No." = field("No."), "Document Type" = filter('Interest' | 'Interest Paid' | Withholding | "Capitalized Interest")));
            Caption = 'Net Interest amount';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(506; "InterestRateType"; Enum InterestRateType)
        {
            DataClassification = ToBeClassified;
            Caption = 'Interest Rate Type';
        }
        field(510; "TaxStatus"; Enum TaxStatus)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tax status (Tax Exempt or Taxable)';
        }
        field(522; EnableGLPosting; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable GL Posting';
            InitValue = true;
        }
        field(930; "Reference Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(932; Margin; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(2800; "Principal Account"; Code[20])
        {
            Caption = 'Principal Account';
            TableRelation = "G/L Account";

        }
        field(2801; "Interest Receivable"; Code[20])
        {
            Caption = 'Interest Receivable';
            TableRelation = "G/L Account";

        }
        field(2802; "Interest Income"; Code[20])
        {
            Caption = 'Interest Income';
            TableRelation = "G/L Account";
        }




    }

    keys
    {
        key(Key1; "No.", RelatedPName)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        NoSer: Codeunit "No. Series";
        GenSetup: Record "General Setup";
        DimensionValue: Record "Dimension Value";

    trigger OnInsert()
    begin
        GenSetup.Get();
        GenSetup.TestField("Related Party");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Related Party", 0D, true);

        // DimensionValue.Reset();
        // DimensionValue.SetRange(DimensionValue."Dimension Code", 'BRANCH');
        // // DimensionValue.SetRange(DimensionValue.Code, Rec."Shortcut Dimension 1 Code");
        // if DimensionValue.FindFirst() then
        //     "Shortcut Dimension 1 Code" := DimensionValue.Name;
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