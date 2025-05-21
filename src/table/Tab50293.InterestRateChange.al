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
        key(PK; LineNo)
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