table 50231 Portfolio
{
    DataClassification = ToBeClassified;
    LookupPageId = 50231;
    DrillDownPageId = 50231;

    fields
    {
        field(1; Code; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Name';
        }
        // field(2; Value; Text[200])
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Value';
        // }
        field(3; Abbreviation; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(4; InternalRef; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(10; ProgramSize; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(15; BeginDate; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(16; ProgramTerm; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Program Term(Years)';
            trigger OnValidate()
            var
                _yearExp: Text[10];
            begin
                if ProgramTerm <> 0 then begin
                    _yearExp := StrSubstNo('<%1Y>', ProgramTerm);
                    EndTerm := CalcDate(_yearExp, BeginDate);
                end;
            end;

        }
        field(17; EndTerm; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;

        }
        field(20; ProgramCurrency; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency;

        }
        field(21; "Fee Applicable"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Fee Applicable (%)';

        }
        field(25; "Interest Rate Applicable"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(26; "Physical Address"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        // field(29; "Contact Person Detail"; Text[250])
        // {
        //     DataClassification = ToBeClassified;

        // }
        field(30; "Contact Person Name"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(31; "Contact Person Address"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(32; "Contact Person Phone No."; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(40; "Contact Person Email"; Text[250])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Contact Person Email" = '' then
                    exit;
                MailManagement.CheckValidEmailAddresses("Contact Person Email");
                // if not TrezMgtCU.ValidateEmailAddress("Contact Person Address") then
                //     FieldError("Contact Person Email", 'Must be a valid email address');
            end;

        }
        field(50; "No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Portfolio Type"; Option)
        {
            OptionMembers = Portfolio;
            DataClassification = ToBeClassified;
        }
        field(70; Category; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Portfolio Category".Code;
        }
        field(80; "Actual Program Size"; Decimal)
        {
            // AutoFormatType = 1;
            // CalcFormula = sum("Funder Loan".OutstandingAmntDisbLCY where(Category = field(Category), Status = filter(Approved)));
            // Caption = 'Actual Program Size';
            // DecimalPlaces = 0 : 2;
            // Editable = false;
            // FieldClass = FlowField;
            DataClassification = ToBeClassified;
        }
        field(81; "OutstandingAmountToTarget"; Decimal)
        {

            DataClassification = ToBeClassified;
        }
        field(5000; Status; Enum PortfolioStatus)
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; "No.", Code, Category)
        {
            Clustered = true;
        }
        // key(FK; Value)
        // {
        //     Unique = true;
        // }
    }


    fieldgroups
    {
        // Add changes to field groups here
    }

    // local procedure ValidateEmail()
    // var
    //     MailManagement: Codeunit "Mail Management";
    //     IsHandled: Boolean;
    // begin
    //     IsHandled := false;
    //     OnBeforeValidateEmail(Rec, IsHandled, xRec);
    //     if IsHandled then
    //         exit;

    //     if "Contact Person Email" = '' then
    //         exit;
    //     MailManagement.CheckValidEmailAddresses("Contact Person Email");
    // end;

    var
        TrezMgtCU: Codeunit "Treasury Mgt CU";
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        "Region/Country": Record Country_Region;

    trigger OnInsert()
    begin
        "Region/Country".Reset();
        if "Region/Country".IsEmpty() then begin

            Error('Region/Country must have atleast one entry');
            exit;
        end;

        GenSetup.Get(0);
        GenSetup.TestField("Portfolio No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Portfolio No.", 0D, true);

        if ProgramTerm <> 0 then begin
            EndTerm := CalcDate(StrSubstNo('<%1Y>', ProgramTerm), BeginDate);
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