table 50282 "Currecy Computation"
{
    DataClassification = ToBeClassified;
    // TableType = Temporary;
    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; Category; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Q1Cy; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Q2Cy; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Q3Cy; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Q4Cy; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; Q1Ny; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Q2Ny; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Counter; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(10; SumRow; Integer)
        {
            DataClassification = ToBeClassified;
        }
        //DebtMaturity By Currency
        field(20; Currecy; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(30; Kategory; Text[250])
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(Key1; Line, Counter)
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