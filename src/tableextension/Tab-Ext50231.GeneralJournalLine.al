tableextension 50231 "General Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        modify("Account No.")
        {

            // TableRelation = if ("Account Type" = const("Funder")) Funder else if ("Account Type" = const("Debtor")) Debtor;
            trigger OnBeforeValidate()
            begin

            end;

            trigger OnAfterValidate()
            begin
                // case "Account Type" of
                //     "Account Type"::Funder:
                //         // GetFunderAccountAccount();
                // end;
            end;

        }
        field(51000; "Transaction Nature"; Enum TransactionNature)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Nature';
        }

    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}