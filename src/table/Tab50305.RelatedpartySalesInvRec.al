table 50305 "Relatedparty Sales Inv Rec."
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Line; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(3; "Related Loan No"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "RelatedParty Loan"."No.";
            trigger OnValidate()
            var
                _relatedLoan: Record "RelatedParty Loan";
                _relatedParty: Record RelatedParty;
            begin
                _relatedLoan.Reset();
                _relatedLoan.SetRange("No.", "Related Loan No");
                if _relatedLoan.Find('-') then
                    "Related Loan Name" := _relatedLoan.Name;

                _relatedParty.Reset();
                _relatedParty.SetRange("No.", _relatedLoan."Funder No.");
                if _relatedParty.Find('-') then
                    "Shortcut Dimension 1 Code" := _relatedParty."Shortcut Dimension 1 Code";
            end;
        }
        field(5; "Related Loan Name"; Text[200])
        {
            DataClassification = ToBeClassified;
        }

        field(10; "Computed Interest"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Processed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Sales Invoice"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Posted Sales Invoice"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(50; "Funder"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "IC Partner".Code;
            trigger OnValidate()
            var
                _icPartner: Record "IC Partner";
            begin
                _icPartner.Get(Funder);
                "Customer No." := _icPartner."Customer No.";
            end;
        }
        field(55; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
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