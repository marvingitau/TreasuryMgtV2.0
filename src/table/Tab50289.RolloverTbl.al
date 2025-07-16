table 50289 "Roll over Tbl"
{
    DataClassification = ToBeClassified;
    DataCaptionFields = "Loan No.";
    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(5; RollOverType; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "","Full Rollover","Partial Rollover";
        }
        field(10; PlacementMaturity; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Principal,Interest,"Principal + Interest";
        }
        field(15; Principal; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; AccruedInterest; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Rollover Date"; Date)
        {
            DataClassification = ToBeClassified;
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