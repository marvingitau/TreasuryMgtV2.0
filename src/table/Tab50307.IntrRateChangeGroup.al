table 50307 "Intr. Rate Change Group"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; LineNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(3; Category; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Bank Loan",Institutional,Individual,"Asset Term Manager","Medium Term Notes","Bank Overdraft","Joint Application",Corporate;

        }
        field(4; Description; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }


        // field(25; Active; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        //     InitValue = false;
        // }
        // field(30; Enabled; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        //     InitValue = false;
        // }




    }

    keys
    {
        key(PK; LineNo, Description)
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
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";

    trigger OnInsert()
    var

    begin
        GenSetup.Get(0);
        GenSetup.TestField("Treasury Jnl No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Treasury Jnl No.", 0D, true);

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