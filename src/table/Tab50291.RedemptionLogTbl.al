table 50291 "Redemption Log Tbl"
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
        field(5; RedemptionType; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Full Redemption","Partial Redemption";
        }
        field(10; PayingBank; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Bank Account"."No.";
        }
        field(20; TotalFloat; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; PrincAmountRemoved; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(23; AmountRemoved; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(29; IntrAmountRemoved; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "New Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Redemption Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(30; RemainingAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; FloatingPrinc; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(36; FloatingIntr; Decimal)
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