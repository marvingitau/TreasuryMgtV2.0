table 50284 "Country_Region"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(5; "Country Name"; Code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Country Prefix"; Code[50])
        {
            DataClassification = ToBeClassified;

        }

        field(10; "Country Currency"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(15; "Phone Code"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(19; "Minimum Phone Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Maximum Phone Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(29; "Minimum Bank Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Maximum Bank Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }



    }

    keys
    {
        key(K1; "Country Name")
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