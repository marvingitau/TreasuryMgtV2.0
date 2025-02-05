table 50238 "BankBranch"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Bank Branch List";
    DrillDownPageId = "Bank Branch List";
    fields
    {
        field(1; BankCode; Code[100])
        {
            DataClassification = ToBeClassified;
            // TableRelation = Banks.BankCode;
        }
        field(2; BranchCode; Code[100])
        {
            DataClassification = ToBeClassified;

        }
        field(3; BranchName; Text[100])
        {
            DataClassification = ToBeClassified;

        }

    }

    keys
    {
        key(PK; BankCode, BranchCode, BranchName)
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