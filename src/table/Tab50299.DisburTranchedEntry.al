table 50299 "Disbur. Tranched Entry"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; PortfolioRecLineNo; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(10; DisbursedTrachNo; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(15; GLAccount; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(16; BankAccount; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(17; BankRefNo; Code[200])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Fee %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; utilized; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }
        field(30; LoanNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(40; TranchedAmount; Decimal)
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