table 50234 FunderLedgerEntry
{
    DataClassification = ToBeClassified;
    Caption = 'Treasury Ledger Entry';
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            // AutoIncrement = true;
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Funder No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Funders."No.";
            Caption = 'Funder No.';
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
        field(5; Description; Text[1000])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(6; "Funder Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Funder Name';
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
        field(21; "Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Funder Loan";
        }
        field(22; "Loan Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Balancing Acc"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";

        }
        field(25; "Origin Entry"; Option)
        {

            DataClassification = ToBeClassified;
            OptionMembers = Funder,RelatedParty;
        }
        field(30; "External Document No."; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(35; Category; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(38; Category_Line; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(39; "Bank Ref. No."; Code[200])
        {
            DataClassification = ToBeClassified;
        }
        field(43; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = ToBeClassified;

        }
        field(45; "Account No."; Code[20]) //Debit A/C
        {
            TableRelation =
            if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                               Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Account Type" = const(Employee)) Employee;
            // else
            // if ("Account Type" = const("Funder")) "Funder Loan";


            DataClassification = ToBeClassified;
        }

        field(47; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = ToBeClassified;

        }
        field(50; "Bal. Account No."; Code[100])//Account No.    Balancing Acc
        {
            DataClassification = ToBeClassified;
            TableRelation =
            if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                               Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Account Type" = const(Employee)) Employee;
        }

        field(51; "Bal. Account Type 2"; Enum "Gen. Journal Account Type")
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Bal. Account No. 2"; Code[100])//Account No.    Balancing Acc
        {
            DataClassification = ToBeClassified;
            TableRelation =
            if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                               Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Account Type" = const(Employee)) Employee;
        }

        field(53; "Interest Payable Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Interest Payable Amount (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Witholding Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Witholding Amount (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Document Date';
        }

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