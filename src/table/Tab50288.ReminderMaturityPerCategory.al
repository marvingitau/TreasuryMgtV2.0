table 50288 ReminderMaturityPerCategory
{
    DataClassification = ToBeClassified;

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
        field(7; Amortization; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; TotalPayment; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; InterestRate; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; OutStandingAmt; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; WithHldTaxAmt; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; NetInterest; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(20; Category; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Portfolio Category".Code;
        }
    }

    keys
    {
        key(Key1; Line)
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