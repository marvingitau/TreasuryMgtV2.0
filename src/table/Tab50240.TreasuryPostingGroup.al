table 50240 "Treasury Posting Group"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = 50242;
    LookupPageId = 50242;
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Funder No';
            NotBlank = true;
        }
        field(2; "Principal Account"; Code[20])
        {
            Caption = 'Principal Account';
            TableRelation = "G/L Account";
        }
        field(7; "Service Charge Acc."; Code[20])
        {
            Caption = 'Service Charge Acc.';
            TableRelation = "G/L Account";

        }
        field(8; "Payment Disc. Debit Acc."; Code[20])
        {
            Caption = 'Payment Disc. Debit Acc.';
            TableRelation = "G/L Account";

        }
        field(9; "Invoice Rounding Account"; Code[20])
        {
            Caption = 'Invoice Rounding Account';
            TableRelation = "G/L Account";

        }
        field(10; "Debit Curr. Appln. Rndg. Acc."; Code[20])
        {
            Caption = 'Debit Curr. Appln. Rndg. Acc.';
            TableRelation = "G/L Account";

        }
        field(11; "Credit Curr. Appln. Rndg. Acc."; Code[20])
        {
            Caption = 'Credit Curr. Appln. Rndg. Acc.';
            TableRelation = "G/L Account";


        }
        field(12; "Debit Rounding Account"; Code[20])
        {
            Caption = 'Debit Rounding Account';
            TableRelation = "G/L Account";

        }
        field(13; "Credit Rounding Account"; Code[20])
        {
            Caption = 'Credit Rounding Account';
            TableRelation = "G/L Account";

        }
        field(16; "Payment Disc. Credit Acc."; Code[20])
        {
            Caption = 'Payment Disc. Credit Acc.';
            TableRelation = "G/L Account";

        }
        field(17; "Payment Tolerance Debit Acc."; Code[20])
        {
            Caption = 'Payment Tolerance Debit Acc.';
            TableRelation = "G/L Account";

        }
        field(18; "Payment Tolerance Credit Acc."; Code[20])
        {
            Caption = 'Payment Tolerance Credit Acc.';
            TableRelation = "G/L Account";
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(21; "View All Accounts on Lookup"; Boolean)
        {
            Caption = 'View All Accounts on Lookup';
        }
        field(50000; "Interest Expense"; Code[20])
        {
            Caption = 'Interest Expense';
            TableRelation = "G/L Account";
        }
        field(50001; "Interest Payable"; Code[20])
        {
            Caption = 'Interest Payable';
            TableRelation = "G/L Account";

        }
        field(50010; "Treasury Enabled (Local)"; Boolean)
        {
            // Caption = 'Interest Payable';
            DataClassification = ToBeClassified;

        }
        field(50020; "Treasury Enabled (Foreign)"; Boolean)
        {
            // Caption = 'Interest Payable';
            DataClassification = ToBeClassified;

        }
        field(50021; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
    }

    keys
    {
        key(PK; "Line No.")
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