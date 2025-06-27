table 50304 "Overdraft Ledger Entries"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Overdraft Ledger Entries";
    DrillDownPageId = "Overdraft Ledger Entries";
    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(4; "Funder No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Loan No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Opening Bal."; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                "Balance Difference" := "Closing Bal." - "Opening Bal.";
            end;
        }
        field(23; "Closing Bal."; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ODLedger: Record "Overdraft Ledger Entries";
            begin
                ODLedger.Reset();
                ODLedger.SetRange("Twin Record ID", "Loan No.");
                if ODLedger.Find('-') then begin
                    ODLedger."Opening Bal." := "Closing Bal.";
                    ODLedger.Modify();
                end;
                "Balance Difference" := "Closing Bal." - "Opening Bal.";
            end;
        }
        field(25; "Calculated Interest"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Calculated Witholding Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; Processed; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }
        field(32; Closed; Boolean) // This indicate if the opening and closing bal are inserted
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }
        field(36; "Balance Difference"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(39; "Bank Account"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Bank Account"."No.";
        }
        field(50; "Twin Record ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; "Line No.", "Funder No.", "Loan No.")
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