table 50294 "Portfolio Fee Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; LineNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(10; Category; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Bank Loan",Institutional,Individual;
            trigger OnValidate()
            begin
                if Category = Category::"Bank Loan" then
                    Code := 'Bank Loan';
                if Category = Category::Individual then
                    Code := 'Individual';
                if Category = Category::Institutional then
                    Code := 'Institutional';

            end;
        }
        field(12; Code; Code[100])
        {
            DataClassification = ToBeClassified;

        }
        field(15; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Fee Percentage"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Fee Applicable %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; LineNo, Code)
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