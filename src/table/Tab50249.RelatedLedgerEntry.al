table 50249 RelatedLedgerEntry
{
    DataClassification = ToBeClassified;
    Caption = 'Related Party Ledger Entry';
    DrillDownPageId = RelatedLedgerEntry;
    LookupPageId = RelatedLedgerEntry;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            // AutoIncrement = true;
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "RelatedParty No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "RelatedParty- Cust"."No.";
            Caption = 'Related No.';
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Posting Date';
        }
        field(4; "Document Type"; Enum TreasuryTransactionDocType)
        {
            DataClassification = ToBeClassified;
            Caption = 'Document Type';
        }
        // field(16; "Transaction Type"; Enum FunderTransactionDocType)
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Transaction Type';
        // }
        field(5; Description; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(6; "Related  Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Related  Name';
        }

        field(7; "Currency Code"; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Currency Code';
        }

        field(8; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Amount';
        }
        field(9; "Amount(LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Amount(LCY)';
        }
        field(10; "Debit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Debit Amount';
        }
        field(11; "Credit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Debit Amount';
        }
        field(12; "Original Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Original Amount';
        }
        field(13; "Remaining Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Remaining Amount';
        }

        field(14; "Modification Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Modification Date';
        }
        field(15; "Modification User"; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Modification User';
        }
        field(16; "Document No."; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Document No';
        }
        field(20; "Remaining Amount(LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Remaining Amount';
        }
        // field(21; "Loan No."; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Funder Loan";
        // }
        // field(22; "Loan Name"; Text[100])
        // {
        //     DataClassification = ToBeClassified;
        // }

        field(49900; "Shortcut Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(49901; "Shortcut Dimension 2 Code"; Code[50])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(50000; "Shortcut Dimension 3 Code"; Code[50])
        {
            CaptionClass = '1,2,3';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(50001; "Shortcut Dimension 4 Code"; Code[50])
        {
            CaptionClass = '1,2,4';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(50002; "Shortcut Dimension 5 Code"; Code[50])
        {
            CaptionClass = '1,2,5';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(50003; "Shortcut Dimension 6 Code"; Code[50])
        {
            CaptionClass = '1,2,6';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(50004; "Shortcut Dimension 7 Code"; Code[50])
        {
            CaptionClass = '1,2,7';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(50005; "Shortcut Dimension 8 Code"; Code[50])
        {
            CaptionClass = '1,2,8';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }

    }

    keys
    {
        key(PK; "Entry No.")
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
        if "Currency Code" <> '' then begin
            Message("Currency Code");
        end;
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