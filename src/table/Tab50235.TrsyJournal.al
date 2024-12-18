table 50235 "Trsy Journal"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Journal Template Name"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Journal Batch Name"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Account Type"; Enum "Trsy Jnl Account Type")
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Account No."; Code[20]) //Debit A/C
        {
            TableRelation =
            if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                               Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Account Type" = const(Employee)) Employee
            else
            if ("Account Type" = const("Funder")) "Funder Loan";


            DataClassification = ToBeClassified;
        }
        field(7; "Posting Date"; Date)
        {
            ClosingDates = true;
            DataClassification = ToBeClassified;

        }
        field(8; "Document Type"; Enum "Gen. Journal Document Type")
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(10; "Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Bal. Account Type"; Enum "Trsy Jnl Account Type")
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Bal. Account No."; Code[20]) //Credit Account
        {
            Caption = 'Bal. Account No.';
            TableRelation =
            if ("Bal. Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                               Blocked = const(false))
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Bal. Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Bal. Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Bal. Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Bal. Account Type" = const(Employee)) Employee
            else
            if ("Bal. Account Type" = const("Funder")) "Funder Loan";

            DataClassification = ToBeClassified;
        }
        field(14; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            var
                BankAcc: Record "Bank Account";
                AccCurrencyCode: Code[10];
                IsHandled: Boolean;
            begin
                // IsHandled := false;
                // OnValidateCurrencyCodeOnBeforeCheckBankAccountCurrencyCode(Rec, IsHandled);
                // if not IsHandled then begin
                //     if "Bal. Account Type" = "Bal. Account Type"::"Bank Account" then
                //         if BankAcc.Get("Bal. Account No.") and (BankAcc."Currency Code" <> '') then
                //             BankAcc.TestField("Currency Code", "Currency Code");

                //     if "Account Type" = "Account Type"::"Bank Account" then
                //         if BankAcc.Get("Account No.") and (BankAcc."Currency Code" <> '') then
                //             BankAcc.TestField("Currency Code", "Currency Code");
                // end;

                // if ("Recurring Method" in
                //     ["Recurring Method"::"B  Balance", "Recurring Method"::"RB Reversing Balance"]) and
                //    ("Currency Code" <> '')
                // then
                //     Error(
                //       Text001,
                //       FieldCaption("Currency Code"), FieldCaption("Recurring Method"), "Recurring Method");

                // if "Currency Code" <> '' then begin
                //     GetCurrency();
                //     AccCurrencyCode := GetAccCurrencyCode();
                //     if ("Currency Code" <> xRec."Currency Code") or
                //        ("Posting Date" <> xRec."Posting Date") or
                //        (CurrFieldNo = FieldNo("Currency Code")) or
                //        ("Currency Factor" = 0) or
                //        (("Currency Code" <> AccCurrencyCode) and (AccCurrencyCode <> ''))
                //     then begin
                //         OnValidateCurrencyCodeOnBeforeUpdateCurrencyFactor(Rec, CurrExchRate);
                //         "Currency Factor" := CurrExchRate.ExchangeRate("Posting Date", "Currency Code");
                //     end;
                // end else
                //     "Currency Factor" := 0;
                // Validate("Currency Factor");

                // if not CustVendAccountNosModified() then
                //     if ("Currency Code" <> xRec."Currency Code") and (Amount <> 0) then
                //         PaymentToleranceMgt.PmtTolGenJnl(Rec);
            end;
        }
        field(16; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                // IsHandled := false;
                // OnBeforeValidateAmountLCY(Rec, xRec, CurrFieldNo, IsHandled);
                // if IsHandled then
                //     exit;

                // if "Currency Code" = '' then begin
                //     Amount := "Amount (LCY)";
                //     Validate(Amount);
                // end else begin
                //     if CheckFixedCurrency() then begin
                //         GetCurrency();
                //         Amount := Round(
                //             CurrExchRate.ExchangeAmtLCYToFCY(
                //               "Posting Date", "Currency Code",
                //               "Amount (LCY)", "Currency Factor"),
                //             Currency."Amount Rounding Precision")
                //     end else begin
                //         TestField("Amount (LCY)");
                //         TestField(Amount);
                //         "Currency Factor" := Amount / "Amount (LCY)";
                //     end;

                //     Validate("VAT %");
                //     Validate("Bal. VAT %");
                //     UpdateLineBalance();
                // end;

                // if JobTaskIsSet() then begin
                //     CreateTempJobJnlLine();
                //     UpdatePricesFromJobJnlLine();
                // end;
            end;
        }
        field(500; "Transaction Nature"; Enum TransactionNature)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Type';
            // NotBlank = true;

        }
        field(600; "Shortcut Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var


    trigger OnInsert()
    begin
        // "Posting Date" := Today;
    end;

    trigger OnModify()
    begin
        // "Posting Date" := Today;
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}