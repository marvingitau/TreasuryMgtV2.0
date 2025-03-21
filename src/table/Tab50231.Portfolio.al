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
        field(2; Value; Text[200])
        {
            DataClassification = ToBeClassified;
            Caption = 'Value';
        }
        field(3; Abbreviation; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(4; InternalRef; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(10; ProgramSize; Text[200])
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

        }
        field(20; ProgramCurrency; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency;

        }
        field(21; "Fee Applicable"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(25; "Interest Rate Applicable"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(26; "Physical Address"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(29; "Contact Person Detail"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
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
        field(5000; Status; Enum PortfolioStatus)
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; Code, Value)
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

    var
        myInt: Integer;

    trigger OnInsert()
    begin

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