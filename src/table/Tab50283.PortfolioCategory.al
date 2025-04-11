table 50283 "Portfolio Category"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Portfolio Categories";
    DrillDownPageId = "Portfolio Categories";

    fields
    {
        field(1; Code; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Value; Text[250])
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