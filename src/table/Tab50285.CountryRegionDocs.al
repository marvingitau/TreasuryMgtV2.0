table 50285 "Country_Region_Docs"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(10; "Country_Region"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Country_Region."Country Name";
        }
        field(20; "Document Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Minimum Length"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Maximum Length"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(K1; Line, Country_Region)
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