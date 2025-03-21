table 50248 "RelatedParty- Cust"
{
    DataClassification = ToBeClassified;
    Caption = 'Customer/Related Party';
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; RelatedPName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(15; RelatedPSysRefNo; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; RelatedPCoupaRef; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(17; RelatedP_Email; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(18; RelatedP_Mobile; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(19; RelatedP_ContactPerson; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(20; RelatedP_ContactEmail; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(21; PlacementDate; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(25; MaturityDate; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(35; DisbursedCurrency; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(36; PinNo; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(37; InterestRatePA; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(40; InterestRepaymentFreq; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(41; PrincipleRepaymentFreq; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(42; RepaymentSchedule; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50; RelatePStatement; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(51; RelatePInvoice; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52; RelatePCreationForm; Text[1050])
        {
            DataClassification = ToBeClassified;
        }
        field(55; RelatePSourceOfFund; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(57; InterestMethod; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Actual/365","Actual/360","30/360","Actual/364";
        }


    }

    keys
    {
        key(Key1; "No.")
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
        GenSetup.Get();
        GenSetup.TestField("Related Party");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Related Party", 0D, true);

        // DimensionValue.Reset();
        // DimensionValue.SetRange(DimensionValue."Dimension Code", 'BRANCH');
        // // DimensionValue.SetRange(DimensionValue.Code, Rec."Shortcut Dimension 1 Code");
        // if DimensionValue.FindFirst() then
        //     "Shortcut Dimension 1 Code" := DimensionValue.Name;
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