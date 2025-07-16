table 50293 "Interest Rate Change"
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

        field(4; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Inter. Rate Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Intr. Rate Change Group"."No.";
        }
        field(6; "Inter. Rate Group Name"; Code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(10; "Effective Dates"; Date) // Opening Date
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Closed Effective Dates"; Date) // Closing Date
        {
            DataClassification = ToBeClassified;
        }
        field(20; "New Interest Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _interestRates: Record "Interest Rate Change";
                _recordCount: Integer;
                _loop: Integer;
            begin

                _loop := 0;
                Active := true;
                _interestRates.Reset();
                _interestRates.SetFilter(LineNo, '<>%1', 0);
                _interestRates.SetFilter("Inter. Rate Group Name", '=%1', "Inter. Rate Group Name");

                _recordCount := _interestRates.Count();
                if _interestRates.find('-') then begin
                    repeat
                        _loop := _loop + 1;

                        if not (_loop = _recordCount) then
                            _interestRates.Active := false;
                        _interestRates.Modify();
                    until _interestRates.Next() = 0;
                end;

            end;
        }

        field(23; "Loan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(25; Active; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }
        field(30; Enabled; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }




    }

    keys
    {
        key(PK; LineNo, Description, "Inter. Rate Group")
        {
            Clustered = true;
        }
        key(FK; "New Interest Rate")
        {
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    var
    // _interestRates: Record "Interest Rate Change";
    // _recordCount: Integer;
    // _loop: Integer;
    begin
        // _loop := 0;

        // _interestRates.Reset();
        // _interestRates.SetFilter(LineNo, '<>%1', 0);
        // _recordCount := _interestRates.Count();

        // if _interestRates.find('-') then begin
        //     repeat
        //         _loop := _loop + 1;
        //         _interestRates.Active := false;
        //         if _loop = _recordCount then
        //             _interestRates.Active := false;
        //         _interestRates.Modify();
        //     until _interestRates.Next() = 0;
        // end;
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