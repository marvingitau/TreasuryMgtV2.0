table 50232 "Funder Loan"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Funder Loan Card";
    DrillDownPageId = "Funder Loan Card";
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
            begin
                Funder.Reset();
                Funder.SetRange("No.", "Funder No.");
                if Funder.Find('-') then begin
                    Name := Funder.Name;
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
            TableRelation = "Vendor Posting Group".Code;
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
        }
        field(502; "MaturityDate"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Maturity Date';
        }
        field(503; "OrigAmntDisbLCY"; Decimal)
        {
            // DataClassification = ToBeClassified;
            // Caption = 'Original Amount in disbursed';
            // AutoFormatType = 1;
            // CalcFormula = sum(FunderLedgerEntry."Remaining Amount" where("Funder No." = field("No."), "Document Type" = filter('Original Amount' | Repayment)));
            // Caption = 'Original Amount';
            // DecimalPlaces = 0 : 2;
            // Editable = false;
            // FieldClass = FlowField;
        }
        field(504; "OutstandingAmntDisbLCY"; Decimal)
        {
            // AutoFormatType = 1;
            // CalcFormula = sum(FunderLedgerEntry."Remaining Amount" where("Funder No." = field("No."), "Document Type" = filter(Interest | 'Original Amount' | Repayment | 'Interest Paid')));
            // Caption = 'Outstanding Amount';
            // DecimalPlaces = 0 : 2;
            // Editable = false;
            // FieldClass = FlowField;

        }
        field(505; "InterestRate"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Interest rate (p.a)';
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
            Caption = 'Withholding tax applied (%)';
        }
        field(510; "TaxStatus"; Enum TaxStatus)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tax status (Tax Exempt or Taxable)';
        }
        field(511; "GrossInterestamount"; Decimal)
        {
            // CalcFormula = sum(FunderLedgerEntry.Amount where("Funder No." = field("No."), "Document Type" = filter('Interest')));
            // Caption = 'Gross Interest amount';
            // DecimalPlaces = 0 : 2;
            // Editable = false;
            // FieldClass = FlowField;
        }
        field(512; "NetInterestamount"; Decimal)
        {
            // CalcFormula = sum(FunderLedgerEntry."Remaining Amount" where("Funder No." = field("No."), "Document Type" = filter('Interest')));
            // Caption = 'Net Interest amount';
            // DecimalPlaces = 0 : 2;
            // Editable = false;
            // FieldClass = FlowField;
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
        field(515; StartTenor; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Start Tenor';
        }

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
            Caption = 'Form of security';
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
        field(521; EndTenor; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'End Tenor';
        }
        field(522; EnableGLPosting; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable GL Posting';
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
            // TableRelation = Category.Code;
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
        }
        field(535; Currency; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Currency';
            TableRelation = Currency;

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
        GenSetup: Record "General Setup";
        NoSer: Codeunit "No. Series";

    trigger OnInsert()
    begin
        GenSetup.Get(0);
        GenSetup.TestField("Funder Loan No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Funder Loan No.", 0D, true);
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