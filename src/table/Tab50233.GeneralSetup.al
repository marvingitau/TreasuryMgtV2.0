table 50233 "General Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'General Setup';

    fields
    {
        field(1; No; Integer)
        {
            Caption = 'No';
            AutoIncrement = true;
        }
        field(2; FunderWithholdingAcc; Code[100])
        {
            Caption = 'Funder Withholding Tax Account';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";

        }
        field(4; DebtorWithholdingAcc; Code[100])
        {
            Caption = 'Debtor Withholding Tax Account';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";

        }
        field(20; "Funder No."; Code[20])
        {
            Caption = 'Funder No';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(30; "Funder Loan No."; Code[20])
        {
            Caption = 'Funder Loan No';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }

    }

    keys
    {
        key(PK; No)
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