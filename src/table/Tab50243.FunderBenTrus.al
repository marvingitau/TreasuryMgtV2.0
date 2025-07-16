table 50243 "Funder Ben/Trus"
{
    DataClassification = ToBeClassified;
    Caption = 'Funder Beneficiary/Trustee';
    LookupPageId = 50245;
    DrillDownPageId = 50245;
    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Funder No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Funders."No.";
        }
        field(3; Name; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Relation; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(5; DOB; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(59; "Identification Doc."; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ID,Passport,"Birth Certificate";
        }
        field(60; "Employer Identification Number"; Text[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Employer Identification Number");
                    if (noLength < "Region/Country"."ID Min Length") or (noLength > "Region/Country"."ID Max Length") then begin
                        Error('ID No. size must be between %1 and %2', "Region/Country"."ID Min Length", "Region/Country"."ID Max Length");
                    end;
                end;
                if not TrsyMgtCU.ValidateNumeric("Employer Identification Number") then
                    Error('Invalid Character(s)');
            end;

        }
        field(61; "Employer Passport Number"; Text[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Employer Passport Number");
                    if (noLength < "Region/Country"."Passport Min Length") or (noLength > "Region/Country"."Passport Max Length") then begin
                        Error('Passport No. size must be between %1 and %2', "Region/Country"."Passport Min Length", "Region/Country"."Passport Max Length");
                    end;
                end;
                if TrsyMgtCU.ValidateAlphanumeric("Employer Passport Number") then
                    Error('Invalid Character(s)');
            end;


        }
        field(6; "ID/Passport No."; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; PhoneNo; Text[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(PhoneNo);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }

        field(8; Type; Option)
        {
            OptionMembers = Beneficiary,Trustee,"Next of Kin";
            DataClassification = ToBeClassified;
        }
        field(100; "RelatedParty No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = RelatedParty."No.";
        }

        field(200; "Birth Cert. Number"; Text[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Birth Cert. Number");
                    if (noLength < "Region/Country"."Birth Cert. Min Length") or (noLength > "Region/Country"."Birth Cert. Max Length") then begin
                        Error('Birth Certificate No. size must be between %1 and %2', "Region/Country"."Birth Cert. Min Length", "Region/Country"."Birth Cert. Max Length");
                    end;
                end;
                // if TrsyMgtCU.ValidateAlphanumeric("Birth Cert. Number") then
                //     Error('Invalid Character(s)');
            end;


        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        GenSetup: Record "Treasury General Setup";
        DimensionValue: Record "Dimension Value";
        "Region/Country": Record Country_Region;
        TrsyMgtCU: Codeunit 50232;

    trigger OnInsert()
    begin
        GenSetup.Get(0);

        "Region/Country".Reset();
        "Region/Country".SetRange("Country Name", GenSetup."Region/Country");
        if "Region/Country".Find('-') then begin
            Rec.PhoneNo := "Region/Country"."Phone Code";
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