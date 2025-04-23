table 50233 "Treasury General Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Treasury General Setup';
    LookupPageId = 50234;
    DrillDownPageId = 50234;
    fields
    {
        field(1; No; Integer)
        {
            Caption = 'No';
            // AutoIncrement = true;
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
        field(5; RelatedWithholdingAcc; Code[100])
        {
            Caption = 'Related Withholding Tax Account';
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
        field(40; "Treasury Jnl No."; Code[20])
        {
            Caption = 'Treasury Jnl No.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(50; "Loan No."; Code[20])
        {
            Caption = 'Loan Name';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(51; "Portfolio No."; Code[20])
        {
            Caption = 'Portfolio No.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(60; "Trsy Recipient mail"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Trsy Recipient Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(65; "Trsy Recipient mail1"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(66; "Trsy Recipient Name1"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Intr. Pay. Rem. Waiting Time"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Placemnt. Matur Rem. Time"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Related Party"; Code[20])
        {
            Caption = 'Related Party/Customer';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }

        field(100; "Shortcut Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }

        field(110; "Region/Country"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Country_Region."Country Name";
        }
        field(250; "Funder Change No."; Code[20])
        {
            Caption = 'Funder Change No.';
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