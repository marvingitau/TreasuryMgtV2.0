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
            TableRelation = Portfolio.Code;
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
        //     TableRelation = "Vendor Posting Group".Code;
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
        field(120; "Primary Contact Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'A key individual for communication purposes.';
        }
        field(130; "Email Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;
        }
        field(140; "Phone Number"; Code[100])
        {
            DataClassification = ToBeClassified;
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
        GenSetup: Record "General Setup";
        DimensionValue: Record "Dimension Value";

    trigger OnInsert()
    begin
        GenSetup.Get(0);
        GenSetup.TestField("Funder No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Funder No.", 0D, true);

        DimensionValue.Reset();
        DimensionValue.SetRange(DimensionValue."Dimension Code", 'BRANCH');
        // DimensionValue.SetRange(DimensionValue.Code, Rec."Shortcut Dimension 1 Code");
        if DimensionValue.FindFirst() then
            "Shortcut Dimension 1 Code" := DimensionValue.Name;
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