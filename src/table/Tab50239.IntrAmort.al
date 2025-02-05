table 50239 "Intr- Amort"
{
    DataClassification = ToBeClassified;
    Caption = 'Interest & Payment Amortization';
    TableType = Temporary;
    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; DueDate; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; CalculationDate; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Interest; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; LoanNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; LoopCount; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Line, LoanNo, LoopCount)
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