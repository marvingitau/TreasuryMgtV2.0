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
            OptionMembers = " ","Bank Loan",Institutional,Individual,"Asset Term Manager","Medium Term Notes";
            trigger OnValidate()
            begin
                if Category = Category::"Bank Loan" then
                    Code := 'Bank Loan';
                if Category = Category::Individual then
                    Code := 'Individual';
                if Category = Category::Institutional then
                    Code := 'Institutional';
                if Category = Category::"Asset Term Manager" then
                    Code := 'Asset Term Manager';
                if Category = Category::"Medium Term Notes" then
                    Code := 'Medium Term Notes';

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
        // field(25; "Fee Applicable %"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }

        field(50; PortfolioNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(150; FunderNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(250; FunderLoanNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(251; RelatedPartyNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(252; RelatedPartyPortfolioNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(253; RelatedPartyLoanNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(350; Applicable; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = true;
        }

        field(550; "G/L"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }

        field(650; "Is G/L Enabled"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }

        field(700; "Disbur. Tranched No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(5000; "Origin Entry"; Option)
        {

            DataClassification = ToBeClassified;
            OptionMembers = Funder,RelatedParty;
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
        "Disbur Tranched Entry": Record "Disbur. Tranched Entry";

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