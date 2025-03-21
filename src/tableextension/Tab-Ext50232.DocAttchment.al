tableextension 50232 "Doc. Attchment _" extends 1173
{
    fields
    {
        // Add changes to table fields here
        field(50000; DocType; Option)
        {
            OptionMembers = " ","National ID/Passport","KRA Pin Cert.","Tax Exception Cert.","Cert. of Incorporation","Memo. & Article of Assoc","KRA Pin Cert","Tax Except. Cert.";
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