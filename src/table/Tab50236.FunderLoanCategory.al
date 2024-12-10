table 50236 "Funder Loan Category"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Funder Loan Categories";
    DrillDownPageId = "Funder Loan Categories";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; Value; Code[20])
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(K1; Code)
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