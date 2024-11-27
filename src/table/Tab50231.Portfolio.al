table 50231 Portfolio
{
    DataClassification = ToBeClassified;
    LookupPageId = "Portfolio List";
    DrillDownPageId = "Portfolio List";
    fields
    {
        field(1; Code; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';
        }
        field(2; Value; Text[200])
        {
            DataClassification = ToBeClassified;
            Caption = 'Value';
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