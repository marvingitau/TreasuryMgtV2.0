table 50244 "Treasury Document Setup"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Treasury Document Setup";
    LookupPageId = "Treasury Document Setup";
    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(10; "Document No."; Code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(20; Ownership; Option)
        {
            OptionMembers = Portfolio,"Funder Loan",Funders,"Related Party/Customer";
            DataClassification = ToBeClassified;

        }
        field(30; "Document Description"; Text[250])
        {
            DataClassification = ToBeClassified;

        }

        field(40; "Must Attached"; Boolean)
        {
            DataClassification = ToBeClassified;

        }


    }

    keys
    {
        key(Key1; Line, "Document No.")
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