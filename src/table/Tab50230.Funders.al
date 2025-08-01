table 50230 Funders
{
    DataClassification = ToBeClassified;
    Caption = 'Funders';
    LookupPageId = "Funder List";
    DrillDownPageId = "Funder List";
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
            TableRelation = Portfolio where(Status = const(Approved));
            trigger OnValidate()
            var
                _portfolio: Record Portfolio;
            begin
                _portfolio.Reset();
                _portfolio.SetRange("No.", Portfolio);
                if _portfolio.Find('-') then begin
                    "Portfolio Name" := _portfolio.Code;
                end;
            end;

        }
        field(21; "Portfolio Name"; Code[100])
        {
            DataClassification = ToBeClassified;

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
        //     TableRelation = "Treasury Posting Group".Code;
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
        field(59; "Identification Doc."; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ID,Passport;
        }
        field(60; "Employer Identification Number"; Text[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
                _funders: Record Funders;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Employer Identification Number");
                    if (noLength < "Region/Country"."ID Min Length") or (noLength > "Region/Country"."ID Max Length") then begin
                        Error('ID No. size must be between %1 and %2', "Region/Country"."ID Min Length", "Region/Country"."ID Max Length");
                    end;
                end;
                if not TrsyMgtCU.ValidateNumeric("Employer Identification Number") then
                    Error('Invalid Character(s)');

                //If Individual Replicate the values
                if FunderType = FunderType::Individual then begin
                    _funders.Reset();
                    _funders.SetRange(_funders."Employer Identification Number", "Employer Identification Number");
                    if _funders.Find('-') then begin
                        // Error('ID No. %1 not unique', "Employer Identification Number");
                        // exit;
                        Portfolio := _funders.Portfolio;
                        Name := _funders.Name;
                        FunderType := _funders.FunderType;
                        // "Payables Account" := _funders."Payables Account";
                        // "Interest Expense" := _funders."Interest Expense";
                        // "Interest Payable" := _funders."Interest Payable";
                        "Shortcut Dimension 1 Code" := _funders."Shortcut Dimension 1 Code";
                        KRA := _funders.KRA;
                        "Identification Doc." := _funders."Identification Doc.";
                        "Employer Passport Number" := _funders."Employer Passport Number";
                        IndNatureOfBusiness := _funders.IndNatureOfBusiness;
                        IndOccupation := _funders.IndOccupation;
                        IndEmployer := _funders.IndEmployer;
                        IndEmployerPosition := _funders.IndEmployerPosition;
                        IndEmployementOther := _funders.IndEmployementOther;
                        "Physical Address" := _funders."Physical Address";
                        "Phone Number" := _funders."Phone Number";
                        "Postal Address" := _funders."Postal Address";
                        "Postal Code" := _funders."Postal Code";
                        "Mailing Address" := _funders."Mailing Address";
                        ContactDetailName := _funders.ContactDetailName;
                        ContactDetailRelation := _funders.ContactDetailRelation;
                        "Contact Detail Id" := _funders."Contact Detail Id";
                        "Contact Detail Passport" := _funders."Contact Detail Passport";
                        ContactDetailPhone := _funders.ContactDetailPhone;

                        "Bank Code" := _funders."Bank Code";
                        "Bank Name" := _funders."Bank Name";
                        "Bank Branch" := _funders."Bank Branch";
                        "Bank Account Number" := _funders."Bank Account Number";
                        "Bank Address" := _funders."Bank Address";
                        "SWIFT/BIC Code" := _funders."SWIFT/BIC Code";
                        "IBAN (Int Bank Acc No)" := _funders."IBAN (Int Bank Acc No)";

                    end;

                end;
            end;

        }
        field(61; "Employer Passport Number"; Text[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Employer Passport Number");
                    if (noLength < "Region/Country"."Passport Min Length") or (noLength > "Region/Country"."Passport Max Length") then begin
                        Error('Passport No. size must be between %1 and %2', "Region/Country"."Passport Min Length", "Region/Country"."Passport Max Length");
                    end;
                end;
                if TrsyMgtCU.ValidateAlphanumeric("Employer Passport Number") then
                    Error('Invalid Character(s)');
            end;


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
            ToolTip = 'Full address of the registered office or place of business.';
        }
        field(100; "Billing Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'If different from the physical address.';
        }
        field(110; "Mailing Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Mailing Address" = '' then
                    exit;
                // MailManagement.CheckValidEmailAddresses("Mailing Address");
                if not TrsyMgtCU.ValidateEmail("Mailing Address") then
                    FieldError("Mailing Address", 'Must be a valid email address');
            end;
        }

        field(111; "Postal Address"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(112; "Postal Code"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(120; "Primary Contact Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'A key individual for communication purposes.';
        }
        // field(130; "Email Address"; Text[50])
        // {
        //     DataClassification = ToBeClassified;
        //     ExtendedDatatype = EMail;
        // }
        field(140; "Phone Number"; Code[100])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Phone Number");
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }
        field(141; "Phone Number B"; Code[100])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Phone Number");
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }

        field(142; "Phone Number Joint2 B"; Code[100])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Phone Number");
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }

        field(143; "Phone Number Joint3 B"; Code[100])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Phone Number");
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
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
        field(212; "Bank Payee"; Text[100])
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
        //Personal Detail Individual
        field(290; "IndOccupation"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(291; "IndNatureOfBusiness"; Option)
        {
            OptionMembers = Employed,"Self Employed",Other;
            DataClassification = ToBeClassified;
        }
        field(292; IndEmployer; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(294; IndEmployerPosition; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(296; IndEmployementOther; Text[1000])
        {
            DataClassification = ToBeClassified;
        }

        field(526; FundSource; Code[100])
        {
            DataClassification = ToBeClassified;

            TableRelation = "Bank Account"."No.";
            trigger OnValidate()
            var
                _bankAccs: Record "Bank Account";
            begin

            end;
        }

        field(600; "Shortcut Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }

        field(601; "Short. Dim 1 Code_Joint 2"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), "Dimension Value Type" = CONST(Standard), Blocked = CONST(false));

        }
        field(603; "Short. Dim 1 Code_Joint 3"; Code[50])
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


        field(702; "JointNatureOfBusiness"; Option)
        {
            OptionMembers = Employed,"Self Employed",Other;
            DataClassification = ToBeClassified;
        }
        field(703; "JointOccupation"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(704; JointEmployer; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(705; JointEmployerPosition; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(706; JointEmployementOther; Text[1000])
        {
            DataClassification = ToBeClassified;
        }


        field(707; "JointNatureOfBusiness_J2"; Option)
        {
            OptionMembers = Employed,"Self Employed",Other;
            DataClassification = ToBeClassified;
        }
        field(708; "JointOccupation_J2"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(709; JointEmployer_J2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(710; JointEmployerPosition_J2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(711; JointEmployementOther_J2; Text[1000])
        {
            DataClassification = ToBeClassified;
        }


        field(712; "JointNatureOfBusiness_J3"; Option)
        {
            OptionMembers = Employed,"Self Employed",Other;
            DataClassification = ToBeClassified;
        }
        field(713; "JointOccupation_J3"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(714; JointEmployer_J3; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(715; JointEmployerPosition_J3; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(716; JointEmployementOther_J3; Text[1000])
        {
            DataClassification = ToBeClassified;
        }


        //Joint 2 and 3
        field(1000; PersonalDetIDPassport_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(PersonalDetIDPassport);
                    if (noLength < "Region/Country"."ID Min Length") or (noLength > "Region/Country"."ID Max Length") then begin
                        Error('ID/Passport No. size must be between %1 and %2', "Region/Country"."ID Min Length", "Region/Country"."ID Max Length");
                    end;
                end;
            end;
        }
        field(1002; PersonalDetIDPassport_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(PersonalDetIDPassport);
                    if (noLength < "Region/Country"."ID Min Length") or (noLength > "Region/Country"."ID Max Length") then begin
                        Error('ID/Passport No. size must be between %1 and %2', "Region/Country"."ID Min Length", "Region/Country"."ID Max Length");
                    end;
                end;
            end;
        }

        field(1020; KRA_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(KRA);
                    if (noLength < "Region/Country"."KRA Min Length") or (noLength > "Region/Country"."KRA Max Length") then begin
                        Error('KRA No. size must be between %1 and %2', "Region/Country"."KRA Min Length", "Region/Country"."KRA Max Length");
                    end;
                end;
            end;
        }
        field(1022; KRA_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(KRA);
                    if (noLength < "Region/Country"."KRA Min Length") or (noLength > "Region/Country"."KRA Max Length") then begin
                        Error('KRA No. size must be between %1 and %2', "Region/Country"."KRA Min Length", "Region/Country"."KRA Max Length");
                    end;
                end;
            end;
        }

        field(1030; PersonalDetOccupation_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1032; PersonalDetOccupation_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1040; PersonalDetNatOfBus_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(1042; PersonalDetNatOfBus_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1043; PersonalDetEmployer_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(1045; PersonalDetEmployer_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1056; "Physical Address Joint2"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'Full address of the counterparty’s registered office or place of business.';
        }

        field(1057; "Physical Address Joint3"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'Full address of the counterparty’s registered office or place of business.';
        }

        field(1058; "Phone Number Joint2"; Code[100])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Phone Number");
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }

        field(1059; "Phone Number Joint3"; Code[100])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Phone Number");
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }

        field(1061; "Postal Address Joint2"; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1063; "Postal Address Joint3"; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1065; "Postal Code Joint2"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(1067; "Postal Code Joint3"; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1068; "Mailing Address Joint2"; Text[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Mailing Address" = '' then
                    exit;
                MailManagement.CheckValidEmailAddresses("Mailing Address");
                // if not TrezMgtCU.ValidateEmailAddress("Contact Person Address") then
                //     FieldError("Mailing Address", 'Must be a valid email address');
            end;
        }

        field(1069; "Mailing Address Joint3"; Text[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Mailing Address" = '' then
                    exit;
                MailManagement.CheckValidEmailAddresses("Mailing Address");
                // if not TrezMgtCU.ValidateEmailAddress("Contact Person Address") then
                //     FieldError("Mailing Address", 'Must be a valid email address');
            end;
        }

        field(1072; ContactDetailName_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(1074; ContactDetailName_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1076; ContactDetailRelation_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(1078; ContactDetailRelation_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1079; ContactDetailIdPassport_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(1080; ContactDetailIdPassport_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(1090; ContactDetailPhone_Joint2; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone_Joint3);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }
        field(1091; ContactDetailPhone_Joint3; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone_Joint3);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
            end;
        }







        // Neext of Kin -> Contact Details
        field(2400; "Contact Det. Id Doc."; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ID,Passport;
        }
        field(2410; InstitutionalAdditionalDet; Text[2000])
        {
            DataClassification = ToBeClassified;
        }
        field(2500; ContactDetailName; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(2501; ContactDetailPhone; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
                // if not TrsyMgtCU.ValidateNumeric(ContactDetailPhone) then
                //     Error('Invalid Phone Character(s)');
            end;
        }
        field(2502; "Contact Detail Id"; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
                _funders: Record Funders;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Contact Detail Id");
                    if (noLength < "Region/Country"."ID Min Length") or (noLength > "Region/Country"."ID Max Length") then begin
                        Error('ID No. size must be between %1 and %2', "Region/Country"."ID Min Length", "Region/Country"."ID Max Length");
                    end;
                end;
                if not TrsyMgtCU.ValidateNumeric("Contact Detail Id") then
                    Error('Invalid Character(s)');

            end;

        }
        field(2504; ContactDetailPhone2; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone2);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
                // if not TrsyMgtCU.ValidateNumeric(ContactDetailPhone) then
                //     Error('Invalid Phone Character(s)');
            end;
        }

        field(2515; ContactDetailPhone2_j2; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone2_j2);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
                // if not TrsyMgtCU.ValidateNumeric(ContactDetailPhone) then
                //     Error('Invalid Phone Character(s)');
            end;
        }
        field(2516; ContactDetailPhone2_j3; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone2_j3);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
                // if not TrsyMgtCU.ValidateNumeric(ContactDetailPhone) then
                //     Error('Invalid Phone Character(s)');
            end;
        }

        field(2514; ContactDetailPhone3; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone3);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
                // if not TrsyMgtCU.ValidateNumeric(ContactDetailPhone) then
                //     Error('Invalid Phone Character(s)');
            end;
        }

        field(2508; "Contact Detail Passport"; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen("Contact Detail Passport");
                    if (noLength < "Region/Country"."Passport Min Length") or (noLength > "Region/Country"."Passport Max Length") then begin
                        Error('Passport No. size must be between %1 and %2', "Region/Country"."Passport Min Length", "Region/Country"."Passport Max Length");
                    end;
                end;
                if TrsyMgtCU.ValidateAlphanumeric("Contact Detail Passport") then
                    Error('Invalid Character(s)');
            end;

        }
        field(2503; ContactDetailRelation; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(1505; ContactDetailEmail; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Mailing Address" = '' then
                    exit;
                // MailManagement.CheckValidEmailAddresses("Mailing Address");
                if not TrsyMgtCU.ValidateEmail(ContactDetailEmail) then
                    FieldError("Mailing Address", 'Must be a valid email address');
            end;

        }
        field(1507; ContactDetailDesignation; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(2499; ContactDetailName_2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2498; ContactDetailDesignation_2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2497; "Mailing Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Mailing Address 2" = '' then
                    exit;
                // MailManagement.CheckValidEmailAddresses("Mailing Address 2");
                if not TrsyMgtCU.ValidateEmail("Mailing Address 2") then
                    FieldError("Mailing Address 2", 'Must be a valid email address');
            end;
        }
        field(2496; ContactDetailPhone_2; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(ContactDetailPhone_2);
                    if (noLength < "Region/Country"."Minimum Phone Length") or (noLength > "Region/Country"."Maximum Phone Length") then begin
                        Error('Phone No. size must be between %1 and %2', "Region/Country"."Minimum Phone Length", "Region/Country"."Maximum Phone Length");
                    end;
                end;
                // if not TrsyMgtCU.ValidateNumeric(ContactDetailPhone) then
                //     Error('Invalid Phone Character(s)');
            end;
        }

        field(2495; "Physical Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
            ToolTip = 'Full address of the registered office or place of business.';
        }


        // Joint Application
        // field(2504; PersonalDetName; Text[250])
        // {
        //     DataClassification = ToBeClassified;
        // }
        //utilize same name for all
        field(2511; JointOneName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2512; JointTwoName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2513; JointThreeName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2505; PersonalDetIDPassport; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;
            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(PersonalDetIDPassport);
                    if (noLength < "Region/Country"."ID Min Length") or (noLength > "Region/Country"."ID Max Length") then begin
                        Error('ID/Passport No. size must be between %1 and %2', "Region/Country"."ID Min Length", "Region/Country"."ID Max Length");
                    end;
                end;
            end;
        }
        field(2506; PersonalDetOccupation; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2507; PersonalDetNatOfBus; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2509; KRA; Text[250])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                _region: Code[20];
                noLength: Integer;

            begin
                GenSetup.Get(0);
                _region := GenSetup."Region/Country";
                "Region/Country".Reset();
                "Region/Country".SetRange("Country Name", _region);
                if "Region/Country".Find('-') then begin
                    noLength := StrLen(KRA);
                    if (noLength < "Region/Country"."KRA Min Length") or (noLength > "Region/Country"."KRA Max Length") then begin
                        Error('KRA No. size must be between %1 and %2', "Region/Country"."KRA Min Length", "Region/Country"."KRA Max Length");
                    end;
                end;

                if not TrsyMgtCU.ValidateAlphanumeric(KRA) then
                    Error('Invalid Character(s)');
            end;
        }
        field(2510; PersonalDetEmployer; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3000; FunderType; Option)
        {
            OptionMembers = Individual,"Joint Application",Corporate,Institutional,"Bank Loan","Bank Overdraft",Relatedparty;
            DataClassification = ToBeClassified;
        }
        field(3010; CompanyNo; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3020; Status; Enum PortfolioStatus)
        {
            DataClassification = ToBeClassified;
        }

        field(4000; "Payables Account"; Code[20])
        {
            Caption = 'Payables Account';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Payables Account" := "Payables Account";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }
        field(4001; "Interest Expense"; Code[20])
        {
            Caption = 'Interest Expense';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Interest Expense" := "Interest Expense";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }
        field(4002; "Interest Payable"; Code[20])
        {
            Caption = 'Interest Payable';
            TableRelation = "G/L Account";
            // trigger OnValidate()
            // begin
            //     vPostingGroup.Reset();
            //     vPostingGroup.SetRange(vPostingGroup.Code, "No.");
            //     if vPostingGroup.Find('-') then begin
            //         vPostingGroup."Interest Payable" := "Interest Payable";
            //         vPostingGroup.Modify();
            //     end;
            // end;
        }

        field(5000; "Origin Entry"; Option)
        {

            DataClassification = ToBeClassified;
            OptionMembers = Funder,RelatedParty;
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
        GenSetup: Record "Treasury General Setup";
        DimensionValue: Record "Dimension Value";
        "Region/Country": Record Country_Region;
        TrsyMgtCU: Codeunit 50232;

    trigger OnInsert()
    begin
        "Region/Country".Reset();
        if "Region/Country".IsEmpty() then begin
            Error('Region/Country must have atleast one entry');
            exit
        end;

        GenSetup.Get(0);
        GenSetup.TestField("Funder No.");
        if "No." = '' then
            "No." := NoSer.GetNextNo(GenSetup."Funder No.", 0D, true);

        "Region/Country".Reset();
        "Region/Country".SetRange("Country Name", GenSetup."Region/Country");
        if "Region/Country".Find('-') then begin
            Rec."Phone Number" := "Region/Country"."Phone Code";
            Rec.ContactDetailPhone := "Region/Country"."Phone Code";
            Rec.ContactDetailPhone2 := "Region/Country"."Phone Code";
            Rec.ContactDetailPhone_2 := "Region/Country"."Phone Code";
            Rec.ContactDetailPhone_Joint3 := "Region/Country"."Phone Code";
            Rec.ContactDetailPhone_Joint2 := "Region/Country"."Phone Code";
            Rec.ContactDetailPhone3 := "Region/Country"."Phone Code";
            Rec."Phone Number B" := "Region/Country"."Phone Code";
            Rec."Phone Number Joint2" := "Region/Country"."Phone Code";
            Rec."Phone Number Joint2 B" := "Region/Country"."Phone Code";
            Rec."Phone Number Joint3" := "Region/Country"."Phone Code";
            Rec."Phone Number Joint3 B" := "Region/Country"."Phone Code";

        end;

        DimensionValue.Reset();
        DimensionValue.SetRange(DimensionValue."Dimension Code", 'BRANCH');
        DimensionValue.SetRange(DimensionValue.Code, GenSetup."Shortcut Dimension 1 Code");
        if DimensionValue.FindFirst() then begin
            Rec."Shortcut Dimension 1 Code" := GenSetup."Shortcut Dimension 1 Code";
            Rec."Short. Dim 1 Code_Joint 2" := GenSetup."Shortcut Dimension 1 Code";
            Rec."Short. Dim 1 Code_Joint 3" := GenSetup."Shortcut Dimension 1 Code";
            // "Shortcut Dimension 1 Code" := DimensionValue.Name;
        end;
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