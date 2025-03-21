table 50242 "Treasury Currency Exch Rate"
{
    DataClassification = ToBeClassified;
    Caption = 'Currency Exchange Rate';
    DataCaptionFields = "Currency Code";
    DrillDownPageID = "Treasury Exchange Rates";
    LookupPageID = "Treasury Exchange Rates";
    fields
    {
        field(1; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            NotBlank = true;
            TableRelation = "Treasury Currency";

            trigger OnValidate()
            begin
                if "Currency Code" = "Relational Currency Code" then
                    Error(
                      Text000, FieldCaption("Currency Code"), FieldCaption("Relational Currency Code"));
            end;
        }
        field(2; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            NotBlank = true;
        }
        field(3; "Exchange Rate Amount"; Decimal)
        {
            Caption = 'Exchange Rate Amount';
            DecimalPlaces = 1 : 6;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Exchange Rate Amount");
            end;
        }
        field(4; "Adjustment Exch. Rate Amount"; Decimal)
        {
            // AccessByPermission = TableData Currency = R;
            Caption = 'Adjustment Exch. Rate Amount';
            DecimalPlaces = 1 : 6;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Adjustment Exch. Rate Amount");
            end;
        }
        field(5; "Relational Currency Code"; Code[10])
        {
            Caption = 'Relational Currency Code';
            TableRelation = "Treasury Currency";

            trigger OnValidate()
            begin
                if "Currency Code" = "Relational Currency Code" then
                    Error(
                      Text000, FieldCaption("Currency Code"), FieldCaption("Relational Currency Code"));
            end;
        }
        field(6; "Relational Exch. Rate Amount"; Decimal)
        {
            // AccessByPermission = TableData Currency = R;
            Caption = 'Relational Exch. Rate Amount';
            DecimalPlaces = 1 : 6;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Relational Exch. Rate Amount");
            end;
        }
        field(7; "Fix Exchange Rate Amount"; Option)
        {
            Caption = 'Fix Exchange Rate Amount';
            OptionCaption = 'Currency,Relational Currency,Both';
            OptionMembers = Currency,"Relational Currency",Both;
        }
        field(8; "Relational Adjmt Exch Rate Amt"; Decimal)
        {
            // AccessByPermission = TableData Currency = R;
            Caption = 'Relational Adjmt Exch Rate Amt';
            DecimalPlaces = 1 : 6;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Relational Adjmt Exch Rate Amt");
            end;
        }
    }

    keys
    {
        key(Key1; "Currency Code", "Starting Date")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    procedure GetCurrentCurrencyFactor(CurrencyCode: Code[10]): Decimal
    begin
        SetRange("Currency Code", CurrencyCode);
        if FindLast() then
            if "Relational Exch. Rate Amount" <> 0 then
                exit("Exchange Rate Amount" / "Relational Exch. Rate Amount");
    end;

    procedure GetLastestExchangeRate(CurrencyCode: Code[10]; var Date: Date; var Amt: Decimal)
    begin
        Date := 0D;
        Amt := 0;
        SetRange("Currency Code", CurrencyCode);
        if FindLast() then begin
            Date := "Starting Date";
            if "Exchange Rate Amount" <> 0 then
                Amt := "Relational Exch. Rate Amount" / "Exchange Rate Amount";
        end;
    end;

    var
        CurrencyExchRate2: array[2] of Record "Currency Exchange Rate";
        CurrencyExchRate3: array[3] of Record "Currency Exchange Rate";
        RelExchangeRateAmt: Decimal;
        ExchangeRateAmt: Decimal;
        RelCurrencyCode: Code[10];
        FixExchangeRateAmt: Option;
        CurrencyFactor: Decimal;
        UseAdjmtAmounts: Boolean;
        CurrencyCode2: array[2] of Code[10];
        Date2: array[2] of Date;

        Text000: Label 'The currency code in the %1 field and the %2 field cannot be the same.';


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