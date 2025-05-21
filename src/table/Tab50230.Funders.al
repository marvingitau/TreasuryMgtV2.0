table 50230 Funders
{
    DataClassification = ToBeClassified;
    Caption = 'Funders';
    LookupPageId = "Funder Card";
    DrillDownPageId = "Funder Card";
    DataCaptionFields = "No.", Name;
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(20; Portfolio; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Portfolio;
            //where(Status = const(Approved));
        }
        field(30; Name; Text[100])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'Full legal name of the counterparty (e.g., the business or individual with whom you are entering into an agreement).';
        }
        // field(31; "Posting Group"; Text[200])
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Posting Group';
        //     TableRelation = "Treasury Posting Group".Code;
        // }
        // field(40; "Counterparty Type"; Enum "Counterpart Types")
        // {
        //     DataClassification = ToBeClassified;
        //     ToolTip = 'This could specify whether the counterparty is a customer, supplier, financial institution, or any other classification based on your systems design.';
        // }
        field(45; "Funder Type"; Enum "Funder Type")
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Tax Identification Number"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Employer Identification Number"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(70; "VAT Number"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Legal Entity Identifier"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Physical Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'Full address of the counterparty’s registered office or place of business.';
        }
        field(100; "Billing Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'If different from the physical address.';
        }
        field(110; "Mailing Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(111; "Postal Address"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(112; "Postal Code"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(120; "Primary Contact Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'A key individual for communication purposes.';
        }
        // field(130; "Email Address"; Text[50])
        // {
        //     DataClassification = ToBeClassified;
        //     ExtendedDatatype = EMail;
        // }
        field(140; "Phone Number"; Code[100])
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
                    noLength := StrLen("Phone Number");
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }
        field(150; "Fax Number"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(160; "Bank Account Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(170; "Bank Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(180; "Bank Address"; Text[250])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'Full address of the bank branch.';
        }
        field(190; "SWIFT/BIC Code"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(200; "IBAN (Int Bank Acc No)"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(210; "Payment Terms"; Enum "Payment Terms")
        {
            DataClassification = ToBeClassified;
        }
        field(220; "Credit Limit"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(230; "KYC Details"; Text[250])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'KYC (Know Your Customer) Details:Any necessary compliance information depending on the jurisdiction.';
        }
        field(240; "Sanctions Check"; Boolean)
        {
            DataClassification = ToBeClassified;
            ToolTip = 'If the counterparty is on any restricted list (e.g., OFAC, EU Sanctions)';
        }
        field(250; "AML Compliance Details"; Text[250])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'AML (Anti-Money Laundering) Compliance Details';
        }
        field(260; "Payment Method"; Enum "Funder Payment Method")
        {
            DataClassification = ToBeClassified;
        }
        field(270; "Additional Notes"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(280; "Country/Region"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        //Personal Detail Individual
        field(290; "IndOccupation"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(291; "IndNatureOfBusiness"; Option)
        {
            OptionMembers = Employed,"Self Employed";
            DataClassification = ToBeClassified;
        }
        field(292; IndEmployer; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(600; "Shortcut Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }

        field(700; "Bank Code"; Code[200])
        {
            DataClassification = ToBeClassified;
            TableRelation = Banks.BankCode;
        }
        field(701; "Bank Branch"; Code[200])
        {
            DataClassification = ToBeClassified;
            // TableRelation = BankBranch.BankCode;
        }

        // Neext of Kin -> Contact Details

        field(2500; ContactDetailName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2501; ContactDetailPhone; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2502; ContactDetailIdPassport; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2503; ContactDetailRelation; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        // Joint Application
        // field(2504; PersonalDetName; Text[250])
        // {
        //     DataClassification = ToBeClassified;
        // }
        //utilize same name for all
        field(2505; PersonalDetIDPassport; Text[250])
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
                    noLength := StrLen(PersonalDetIDPassport);
                    if (noLength < "Region/Country"."ID Min Length") or (noLength > "Region/Country"."ID Max Length") then begin
                        Error('ID/Passport No. size must be between %1 and %2', "Region/Country"."ID Min Length", "Region/Country"."ID Max Length");
                    end;
                end;
            end;
        }
        field(2506; PersonalDetOccupation; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2507; PersonalDetNatOfBus; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2509; KRA; Text[250])
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
                    noLength := StrLen(KRA);
                    if (noLength < "Region/Country"."KRA Min Length") or (noLength > "Region/Country"."KRA Max Length") then begin
                        Error('KRA No. size must be between %1 and %2', "Region/Country"."KRA Min Length", "Region/Country"."KRA Max Length");
                    end;
                end;
            end;
        }
        field(2510; PersonalDetEmployer; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3000; FunderType; Option)
        {
            OptionMembers = Individual,"Joint Application",Corporate;
            DataClassification = ToBeClassified;
        }
        field(3010; CompanyNo; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3020; Status; Enum PortfolioStatus)
        {
            DataClassification = ToBeClassified;
        }

        field(4000; "Payables Account"; Code[20])
        {
            Caption = 'Payables Account';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Payables Account" := "Payables Account";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }
        field(4001; "Interest Expense"; Code[20])
        {
            Caption = 'Interest Expense';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Interest Expense" := "Interest Expense";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }
        field(4002; "Interest Payable"; Code[20])
        {
            Caption = 'Interest Payable';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Interest Payable" := "Interest Payable";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }

    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        NoSer: Codeunit "No. Series";
        GenSetup: Record "Treasury General Setup";
        DimensionValue: Record "Dimension Value";
        "Region/Country": Record Country_Region;

    trigger OnInsert()
    begin
        "Region/Country".Reset();
        if "Region/Country".IsEmpty() then begin
            Error('Region/Country must have atleast one entry');
            exit
        end;

        GenSetup.Get(0);
        GenSetup.TestField("Funder No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Funder No.", 0D, true);

        "Region/Country".Reset();
        "Region/Country".SetRange("Country Name", GenSetup."Region/Country");
        if "Region/Country".Find('-') then begin
            Rec."Phone Number" := "Region/Country"."Phone Code";
            Rec.ContactDetailPhone := "Region/Country"."Phone Code";
        end;

        DimensionValue.Reset();
        DimensionValue.SetRange(DimensionValue."Dimension Code", 'BRANCH');
        DimensionValue.SetRange(DimensionValue.Code, GenSetup."Shortcut Dimension 1 Code");
        if DimensionValue.FindFirst() then begin
            Rec."Shortcut Dimension 1 Code" := GenSetup."Shortcut Dimension 1 Code";
            // "Shortcut Dimension 1 Code" := DimensionValue.Name;
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