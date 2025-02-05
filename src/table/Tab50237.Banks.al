table 50237 "Banks"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Bank List";
    LookupPageId = "Bank List";
    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; BankCode; Code[100])
        {
            DataClassification = ToBeClassified;
        }

        field(3; Name; Text[100])
        {
            DataClassification = ToBeClassified;

        }

    }

    keys
    {
        key(PK; Line, BankCode, Name)
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