table 50309 TreasuryLogs
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;

        }
    }

    keys
    {
        key(PK; Line)
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