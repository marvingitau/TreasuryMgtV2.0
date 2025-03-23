table 50246 "Report Flags"
{
    DataClassification = ToBeClassified;
    //This will store all the flags needed by reports to init run.
    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(10; "Funder Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
            // InvestmentConfirmFlag;
        }
        field(20; "Related Party No"; Code[20])
        {
            DataClassification = ToBeClassified;
            // InvestmentConfirmFlag;
        }
        field(30; "Utilizing User"; Code[20])
        {
            DataClassification = ToBeClassified;
            // InvestmentConfirmFlag;
        }
    }

    keys
    {
        key(Key1; "Line No.")
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