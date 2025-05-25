table 50284 "Country_Region"
{
    DataClassification = ToBeClassified;
    LookupPageId = 50285;
    DrillDownPageId = 50285;

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

        field(50; "KRA Min Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(51; "KRA Max Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60; "ID Min Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(61; "ID Max Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(65; "Passport Min Length"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(66; "Passport Max Length"; Integer)
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