table 50243 "Funder Ben/Trus"
{
    DataClassification = ToBeClassified;
    Caption = 'Funder Beneficiary/Trustee';
    LookupPageId = 50245;
    DrillDownPageId = 50245;
    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Funder No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Funders."No.";
        }
        field(3; Name; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Relation; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(5; DOB; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "ID/Passport No."; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; PhoneNo; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(8; Type; Option)
        {
            OptionMembers = Beneficiary,Trustee;
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Line No.")
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