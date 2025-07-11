table 50290 "Redemption Tbl"
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
        field(20; PrincipalAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; InterestAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Redemption Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(35; FloatPrinci; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(40; ActualInterest; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(41; ActualPrincipal; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(45; FloatIntr; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(46; FloatIntrPlusFloatPrinci; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(50; PartialAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(150; ReferenceNo; Code[1000])
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