table 50296 "Repayment Schedule"
{
    DataClassification = ToBeClassified;
    // TableType = Temporary;
    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(10; "Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Installment No"; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(23; "Installment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Installment Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Installment Interest"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(28; "Installment Principal"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Outstanding Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }



    }

    keys
    {
        key(PK; "Line No.", "Loan No.")
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