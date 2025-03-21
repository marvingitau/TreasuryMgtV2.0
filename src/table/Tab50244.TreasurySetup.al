table 50244 "Treasury Setup"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Treasury Setup";
    LookupPageId = "Treasury Setup";
    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(10; "Finace Manager Email"; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(20; "Finace Manager Email Cc"; Text[200])
        {
            DataClassification = ToBeClassified;

        }

    }

    keys
    {
        key(Key1; Line)
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