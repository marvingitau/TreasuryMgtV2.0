tableextension 50230 "Vendor Posting Group" extends 93
{
    fields
    {
        field(50000; "Interest Expense"; Code[20])
        {
            Caption = 'Interest Expense';
            TableRelation = "G/L Account";

            // trigger OnLookup()
            // begin
            //     // if "View All Accounts on Lookup" then
            //     //     GLAccountCategoryMgt.LookupGLAccountWithoutCategory("Payables Account")
            //     // else
            //     //     LookupGLAccount(
            //     //       "Payables Account", GLAccountCategory."Account Category"::Liabilities, GLAccountCategoryMgt.GetCurrentLiabilities());

            //     // Validate("Payables Account");
            // end;

            // trigger OnValidate()
            // begin
            //     // if "View All Accounts on Lookup" then
            //     //     GLAccountCategoryMgt.CheckGLAccountWithoutCategory("Payables Account", false, false)
            //     // else
            //     //     CheckGLAccount(
            //     //       FieldNo("Payables Account"), "Payables Account", false, false, GLAccountCategory."Account Category"::Liabilities, GLAccountCategoryMgt.GetCurrentLiabilities());
            // end;
        }
        field(50001; "Interest Payable"; Code[20])
        {
            Caption = 'Interest Payable';
            TableRelation = "G/L Account";

        }
        field(50010; "Treasury Enabled (Local)"; Boolean)
        {
            // Caption = 'Interest Payable';
            DataClassification = ToBeClassified;

        }
        field(50020; "Treasury Enabled (Foreign)"; Boolean)
        {
            // Caption = 'Interest Payable';
            DataClassification = ToBeClassified;

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