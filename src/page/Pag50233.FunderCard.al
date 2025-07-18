page 50233 "Funder Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = Funders;
    Caption = 'Funder/Supplier Card';

    // DataCaptionExpression = '';
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Portfolio; Rec.Portfolio)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    trigger OnValidate()
                    var
                        _portfolio: Record Portfolio;
                    begin
                        _portfolio.Reset();
                        _portfolio.SetRange("No.", Rec.Portfolio);
                        if not _portfolio.Find('-') then
                            Error('Portfolio %1 not found.', Rec.Portfolio);

                        if _portfolio.Category = _portfolio.Category::"Bank Overdraft" then
                            Rec.FunderType := Rec.FunderType::"Bank Overdraft";

                        if _portfolio.Category = _portfolio.Category::"Bank Loan" then
                            Rec.FunderType := Rec.FunderType::"Bank Loan";
                        if _portfolio.Category = _portfolio.Category::Individual then
                            Rec.FunderType := Rec.FunderType::Individual;
                        if _portfolio.Category = _portfolio.Category::Institutional then
                            Rec.FunderType := Rec.FunderType::Institutional;
                        if _portfolio.Category = _portfolio.Category::Relatedparty then
                            Rec.FunderType := Rec.FunderType::Relatedparty;
                        CurrPage.Update();
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field(FunderType; Rec.FunderType)
                {
                    ApplicationArea = all;
                    Caption = 'Funder Type';
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        UpdateFastTabVisibility();
                    end;
                }


                // field("Funder Type"; Rec."Funder Type")
                // {
                //     ApplicationArea = all;
                // }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                    // Editable = (Rec.Status = Rec.Status::Open);
                }
            }
            group("G/L Mapping")
            {
                field("Payables Account"; Rec."Payables Account")
                {

                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                    Caption = 'Principal Account';
                }
                field("Interest Expense"; Rec."Interest Expense")
                {

                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field("Interest Payable"; Rec."Interest Payable")
                {

                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field(FundSource; Rec.FundSource)
                {
                    Caption = 'Receiving Bank Account';
                    Editable = EditStatus;
                    ApplicationArea = all;

                    Enabled = Rec.FunderType = Rec.FunderType::"Bank Overdraft";
                }
            }

            group("Personal Detail (Individual)")
            {
                Visible = ShowIndividualFastTab;
                group("Personal Detail General")
                {

                    field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                        Editable = EditStatus;
                        Visible = false;
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("Branch Name"; BranchName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                    }

                    // field("Counterparty Type"; Rec."Counterparty Type")
                    // {
                    //     ApplicationArea = All;
                    // }
                    field("Tax Identification Number"; Rec.KRA)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax PIN';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Identification Doc."; Rec."Identification Doc.")
                    {
                        ApplicationArea = All;
                        Editable = EditStatus;
                    }
                    field("Employer Identification Number"; Rec."Employer Identification Number")
                    {
                        ApplicationArea = All;
                        Caption = 'ID  No.';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                        Enabled = Rec."Identification Doc." = Rec."Identification Doc."::ID;
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("Employer Passport Number"; Rec."Employer Passport Number")
                    {
                        ApplicationArea = All;
                        Caption = 'Passport No.';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                        Enabled = (Rec."Identification Doc." = Rec."Identification Doc."::Passport);
                    }

                    field(IndNatureOfBusiness; Rec.IndNatureOfBusiness)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Employment Status';
                        Editable = EditStatus;
                    }
                    field(IndOccupation; Rec.IndOccupation)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Occupation';
                        Editable = (Rec.IndNatureOfBusiness = Rec.IndNatureOfBusiness::"Self Employed") and EditStatus;

                    }
                    field(IndEmployer; Rec.IndEmployer)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Employer';
                        Editable = (Rec.IndNatureOfBusiness = Rec.IndNatureOfBusiness::Employed) and EditStatus;

                    }
                    field(IndEmployerPosition; Rec.IndEmployerPosition)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Position';
                        Editable = (Rec.IndNatureOfBusiness = Rec.IndNatureOfBusiness::Employed) and EditStatus;

                    }
                    field(IndEmployementOther; Rec.IndEmployementOther)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Other';
                        Editable = (Rec.IndNatureOfBusiness = Rec.IndNatureOfBusiness::Other) and EditStatus;

                    }
                    // field("VAT Number"; Rec."VAT Number")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Business Registration Number';
                    // }
                    // field("Legal Entity Identifier"; Rec."Legal Entity Identifier")
                    // {
                    //     ApplicationArea = All;
                    // }
                    // field("Country/Region"; Rec."Country/Region")
                    // {
                    //     ApplicationArea = All;
                    // }
                }

                group(Address)
                {
                    field("Physical Address"; Rec."Physical Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Phone Number"; Rec."Phone Number")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Postal Address"; Rec."Postal Address")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Postal Code"; Rec."Postal Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Mailing Address"; Rec."Mailing Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    // field("Pri Contact Name"; Rec."Primary Contact Name")
                    // {
                    //     ApplicationArea = All;
                    //     ShowMandatory = false;
                    // }

                    // field("Email Address"; Rec."Email Address")
                    // {
                    //     ApplicationArea = All;
                    //     ExtendedDatatype = EMail;
                    //     Caption = 'Contact Persons Email';
                    // }

                    // field("Billing Address"; Rec."Billing Address")
                    // {
                    //     ApplicationArea = All;
                    // }

                }
                /*group(Contacts)
                {
                    field("Primary Contact Name"; Rec."Primary Contact Name")
                    {
                        ApplicationArea = All;
                    }

                    field("Fax Number"; Rec."Fax Number")
                    {
                        ApplicationArea = All;
                    }

                }*/
                group("Contact Details")
                {
                    field(ContactDetailName; Rec.ContactDetailName)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailRelation; Rec.ContactDetailRelation)
                    {
                        Caption = 'Relation';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Contact Det. Id Doc."; Rec."Contact Det. Id Doc.")
                    {
                        Caption = 'dentification Doc.';
                        ApplicationArea = All;
                        Editable = EditStatus;
                    }
                    field("Contact Detail Id"; Rec."Contact Detail Id")
                    {
                        Caption = 'ID No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                        Enabled = Rec."Identification Doc." = Rec."Identification Doc."::ID;

                    }
                    field("Contact Detail Passport"; Rec."Contact Detail Passport")
                    {
                        Caption = 'Passport No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                        Enabled = Rec."Identification Doc." = Rec."Identification Doc."::Passport;

                    }
                    field(ContactDetailPhone; Rec.ContactDetailPhone)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailPhone_PersonalDet; Rec.ContactDetailPhone2)
                    {
                        Caption = 'Phone 2';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                }

            }
            group("Personal Detail (Joint Applications 1)")
            {
                Visible = ShowJointFastTab;
                group("Joint General")
                {
                    field(JointOneName; Rec.JointOneName)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = EditStatus;
                    }
                    field("JointShortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = all;
                        // ShowMandatory = true;
                        Visible = false;
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("JointBranch Name"; BranchName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                    }
                    field(PersonalDetIDPassport; Rec.PersonalDetIDPassport)
                    {
                        ApplicationArea = All;
                        Caption = 'ID/Passport';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(PersonalDetKRA; Rec.KRA)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Pin No.';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointNatureOfBusiness; Rec.JointNatureOfBusiness)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Employment Status';
                        Editable = EditStatus;
                    }
                    field(JointOccupation; Rec.JointOccupation)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Occupation';
                        Editable = (Rec.JointNatureOfBusiness = Rec.JointNatureOfBusiness::"Self Employed") and EditStatus;

                    }
                    field(JointEmployer; Rec.JointEmployer)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Employer';
                        Editable = (Rec.JointNatureOfBusiness = Rec.JointNatureOfBusiness::Employed) and EditStatus;

                    }
                    field(JointEmployerPosition; Rec.JointEmployerPosition)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Position';
                        Editable = (Rec.JointNatureOfBusiness = Rec.JointNatureOfBusiness::Employed) and EditStatus;

                    }
                    field(JointEmployementOther; Rec.JointEmployementOther)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Other';
                        Editable = (Rec.JointNatureOfBusiness = Rec.JointNatureOfBusiness::Other) and EditStatus;

                    }
                    // field(PersonalDetOccupation; Rec.PersonalDetOccupation)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Occupation';
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    // field(PersonalDetNatOfBus; Rec.PersonalDetNatOfBus)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Nature of Business';
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    // field(PersonalDetEmployer; Rec.PersonalDetEmployer)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Employer';
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                }
                group("Joint Contact")
                {
                    field("Joint Physical Address"; Rec."Physical Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Phone Number"; Rec."Phone Number")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Phone Number B"; Rec."Phone Number B")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                        Editable = EditStatus;
                        Caption = 'Phone Number 2';
                    }
                    field("Joint Postal Address"; Rec."Postal Address")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Postal Code"; Rec."Postal Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Mailing Address"; Rec."Mailing Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }

                }
                group("Joint Contact Details")
                {
                    field(JointContactDetailName; Rec.ContactDetailName)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointContactDetailRelation; Rec.ContactDetailRelation)
                    {
                        Caption = 'Relation';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Cont Det. Id Doc. Joint"; Rec."Contact Det. Id Doc.")
                    {
                        Caption = 'Identification Doc.';
                        ApplicationArea = All;
                        Editable = EditStatus;

                    }
                    field("Cont. Detail Id Joit"; Rec."Contact Detail Id")
                    {
                        Caption = 'ID No.';
                        ApplicationArea = All;
                        Enabled = Rec."Identification Doc." = Rec."Identification Doc."::ID;
                        Editable = EditStatus;
                    }
                    field("Cont. Detail Passport Joint"; Rec."Contact Detail Passport")
                    {
                        Caption = 'Passport No.';
                        ApplicationArea = All;
                        Enabled = Rec."Identification Doc." = Rec."Identification Doc."::Passport;
                        Editable = EditStatus;
                    }
                    field(JointContactDetailPhone; Rec.ContactDetailPhone)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailPhone_Joint1; Rec.ContactDetailPhone2)
                    {
                        Caption = 'Phone 2';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                }
            }

            group("Personal Detail (Joint Applications 2)")
            {
                Visible = ShowJointFastTab;
                group("Joint General 2")
                {
                    field(JointTwoName; Rec.JointTwoName)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = EditStatus;
                    }

                    field("JointShortcut Dimension 1 Joint_2"; Rec."Short. Dim 1 Code_Joint 2")
                    {
                        ApplicationArea = all;
                        Visible = false;
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("JointBranch Name_2"; BranchName)
                    {
                        ApplicationArea = All;
                        Visible = false;
                        Caption = 'Branch Name';
                    }
                    field(PersonalDetIDPassport_Joint2; Rec.PersonalDetIDPassport_Joint2)
                    {
                        ApplicationArea = All;
                        Caption = 'ID/Passport';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(PersonalDetKRA_Joint2; Rec.KRA_Joint2)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Pin No.';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointNatureOfBusiness_J2; Rec.JointNatureOfBusiness_J2)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Employment Status';
                        Editable = EditStatus;
                    }
                    field(JointOccupation_J2; Rec.JointOccupation_J2)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Occupation';
                        Editable = (Rec.JointNatureOfBusiness_J2 = Rec.JointNatureOfBusiness_J2::"Self Employed") and EditStatus;

                    }
                    field(JointEmployer_J2; Rec.JointEmployer_J2)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Employer';
                        Editable = (Rec.JointNatureOfBusiness_J2 = Rec.JointNatureOfBusiness_J2::Employed) and EditStatus;

                    }
                    field(JointEmployerPosition_J2; Rec.JointEmployerPosition_J2)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Position';
                        Editable = (Rec.JointNatureOfBusiness_J2 = Rec.JointNatureOfBusiness_J2::Employed) and EditStatus;

                    }
                    field(JointEmployementOther_J2; Rec.JointEmployementOther_J2)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Other';
                        Editable = (Rec.JointNatureOfBusiness_J2 = Rec.JointNatureOfBusiness_J2::Other) and EditStatus;

                    }
                    // field(PersonalDetOccupation_Joint2; Rec.PersonalDetOccupation_Joint2)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Occupation';
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    // field(PersonalDetNatOfBus_Joint2; Rec.PersonalDetNatOfBus_Joint2)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Nature of Business';
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    // field(PersonalDetEmployer_Joint2; Rec.PersonalDetEmployer_Joint2)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Employer';
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                }
                group("Joint Contact 2")
                {
                    field("Joint Physical Address Joint2"; Rec."Physical Address Joint2")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Phone Number Joint2"; Rec."Phone Number Joint2")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Phone Number Joint2 B"; Rec."Phone Number Joint2 B")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        Caption = 'Phone 2';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Postal Address joint2"; Rec."Postal Address Joint2")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Postal Code J2"; Rec."Postal Code Joint2")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Mailing Address J2"; Rec."Mailing Address Joint2")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }

                }
                group("Joint Contact Details 2")
                {
                    field(JointContactDetailName_J2; Rec.ContactDetailName_Joint2)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointContactDetailRelation_J2; Rec.ContactDetailRelation_Joint2)
                    {
                        Caption = 'Relation';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointContactDetailIdPassport_J2; Rec.ContactDetailIdPassport_Joint2)
                    {
                        Caption = 'Passport/ID No.';
                        ApplicationArea = All;
                        Editable = EditStatus;
                        ShowMandatory = true;
                    }
                    field(JointContactDetailPhone_J2; Rec.ContactDetailPhone_Joint2)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailPhone_Joint2; Rec.ContactDetailPhone2_j2)
                    {
                        Caption = 'Phone 2';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                }
            }

            group("Personal Detail (Joint Applications 3)")
            {
                Visible = ShowJointFastTab;
                group("Joint General 3")
                {
                    field(JointThreeName; Rec.JointThreeName)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = EditStatus;
                    }

                    field("JointShortcut Dimension 1 Joint_3"; Rec."Short. Dim 1 Code_Joint 3")
                    {
                        ApplicationArea = all;
                        Visible = false;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("JointBranch Name_3"; BranchName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        Caption = 'Branch Name';
                    }
                    field(PersonalDetIDPassport_Joint3; Rec.PersonalDetIDPassport_Joint3)
                    {
                        ApplicationArea = All;
                        Caption = 'ID/Passport';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(PersonalDetKRA_Joint3; Rec.KRA_Joint3)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Pin No.';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    // field(PersonalDetOccupation_Joint3; Rec.PersonalDetOccupation_Joint3)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Occupation';
                    //     // ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    // field(PersonalDetNatOfBus_Joint3; Rec.PersonalDetNatOfBus_Joint3)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Nature of Business';
                    //     // ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    // field(PersonalDetEmployer_Joint3; Rec.PersonalDetEmployer_Joint3)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Employer';
                    //     // ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }

                    field(JointNatureOfBusiness_J3; Rec.JointNatureOfBusiness_J3)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Employment Status';
                        Editable = EditStatus;
                    }
                    field(JointOccupation_J3; Rec.JointOccupation_J3)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Occupation';
                        Editable = (Rec.JointNatureOfBusiness_J3 = Rec.JointNatureOfBusiness_J3::"Self Employed") and EditStatus;

                    }
                    field(JointEmployer_J3; Rec.JointEmployer_J3)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Employer';
                        Editable = (Rec.JointNatureOfBusiness_J3 = Rec.JointNatureOfBusiness_J3::Employed) and EditStatus;

                    }
                    field(JointEmployerPosition_J3; Rec.JointEmployerPosition_J3)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Position';
                        Editable = (Rec.JointNatureOfBusiness_J3 = Rec.JointNatureOfBusiness_J3::Employed) and EditStatus;

                    }
                    field(JointEmployementOther_J3; Rec.JointEmployementOther_J3)
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Other';
                        Editable = (Rec.JointNatureOfBusiness_J3 = Rec.JointNatureOfBusiness_J3::Other) and EditStatus;

                    }
                }
                group("Joint Contact 3")
                {
                    field("Joint Physical Address Joint3"; Rec."Physical Address Joint3")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Phone Number Joint3"; Rec."Phone Number Joint3")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        Caption = 'Phone Number';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Phone Number J3 B"; Rec."Phone Number Joint3 B")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        Caption = 'Phone Number 2';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Postal Address joint3"; Rec."Postal Address Joint3")
                    {
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Caption = 'Postal Address';
                        Editable = EditStatus;
                    }
                    field("Joint Postal Code J3"; Rec."Postal Code Joint3")
                    {
                        ApplicationArea = All;
                        Caption = 'Postal Code ';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Joint Mailing Address J3"; Rec."Mailing Address Joint3")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }

                }
                group("Joint Contact Details 3")
                {
                    field(JointContactDetailName_J3; Rec.ContactDetailName_Joint3)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointContactDetailRelation_J3; Rec.ContactDetailRelation_Joint3)
                    {
                        Caption = 'Relation';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointContactDetailIdPassport_J3; Rec.ContactDetailIdPassport_Joint3)
                    {
                        Caption = 'Passport/ID No.';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(JointContactDetailPhone_J3; Rec.ContactDetailPhone_Joint3)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailPhone_Joint3; Rec.ContactDetailPhone2_j3)
                    {
                        Caption = 'Phone 2';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                }
            }

            group("Bank Loan Info")
            {
                Visible = Rec.FunderType = Rec.FunderType::"Bank Loan";

                field("Shortcut Dimension 1 Code BankLoan"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                    Visible = false;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;

                }
                field("Branch Name BankLoan"; BranchName)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                group("Contact 1")
                {
                    field(BankContactDetailName; Rec.ContactDetailName)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailDesignation; Rec.ContactDetailDesignation)
                    {
                        Caption = 'Designation';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    // field(ContactDetailEmail; Rec.ContactDetailEmail)
                    // {
                    //     Caption = 'Email';
                    //     ApplicationArea = All;
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    field(ContactDetailEmailBankInfo; Rec."Mailing Address")
                    {
                        Caption = 'Email';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }

                    field(BankContactDetailPhone; Rec.ContactDetailPhone)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(BankContactDetailPhone2; Rec.ContactDetailPhone2)
                    {
                        Caption = 'Phone 2';
                        ApplicationArea = All;
                        Editable = EditStatus;
                    }
                }
                group("Contact 2")
                {
                    field(BankContactDetailName_2; Rec.ContactDetailName_2)
                    {
                        Caption = 'Name';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailDesignation_2; Rec.ContactDetailDesignation_2)
                    {
                        Caption = 'Designation';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    // field(ContactDetailEmail; Rec.ContactDetailEmail)
                    // {
                    //     Caption = 'Email';
                    //     ApplicationArea = All;
                    //     ShowMandatory = true;
                    //     Editable = EditStatus;
                    // }
                    field(ContactDetailEmailBankInfo_2; Rec."Mailing Address 2")
                    {
                        Caption = 'Email 2';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }

                    field(BankContactDetailPhone_2; Rec.ContactDetailPhone_2)
                    {
                        Caption = 'Phone';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(BankContactDetailPhone_3; Rec.ContactDetailPhone3)
                    {
                        Caption = 'Phone 2';
                        ApplicationArea = All;
                        Editable = EditStatus;
                    }
                }

            }





            group("Institutional Details")
            {
                Visible = ShowInstitutionalFastTab;

                field("Short Dimension 1 Code Insti"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                    // ShowMandatory = true;
                    Editable = EditStatus;
                    Visible = false;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;

                }
                field("Branch Name Insti"; BranchName)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Tax Id No. Insti."; Rec.KRA)
                {
                    ApplicationArea = All;
                    Caption = 'Tax PIN';
                    // ShowMandatory = true;
                    Editable = EditStatus;
                }
                group("Institutional Contact Details")
                {
                    group("Institutional Contact 1")
                    {
                        field(ContactDetailNameInsti; Rec.ContactDetailName)
                        {
                            Caption = 'Name';
                            ApplicationArea = All;
                            // ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstDesignation; Rec.ContactDetailDesignation)
                        {
                            Caption = 'Designation';
                            ApplicationArea = All;
                            // ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstiEmail; Rec."Mailing Address")
                        {
                            Caption = 'Email';
                            ApplicationArea = All;
                            ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstiPhone; Rec.ContactDetailPhone)
                        {
                            Caption = 'Phone';
                            ApplicationArea = All;
                            ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstiPhone2; Rec.ContactDetailPhone3)
                        {
                            Caption = 'Phone 2';
                            ApplicationArea = All;
                            ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstiPhysicalAddr; Rec."Physical Address")
                        {
                            Caption = 'Physical Address';
                            ApplicationArea = All;
                            Editable = EditStatus;

                        }
                    }
                    group("Institutional Contact 2")
                    {
                        field(ContactDetailNameInsti_2; Rec.ContactDetailName_2)
                        {
                            Caption = 'Name';
                            ApplicationArea = All;
                            // ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstDesignation_2; Rec.ContactDetailDesignation_2)
                        {
                            Caption = 'Designation';
                            ApplicationArea = All;
                            // ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstiEmail_2; Rec."Mailing Address 2")
                        {
                            Caption = 'Email';
                            ApplicationArea = All;
                            // ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(InstiPhysicalAddr_2; Rec."Physical Address 2")
                        {
                            Caption = 'Physical Address';
                            ApplicationArea = All;
                            Editable = EditStatus;

                        }
                        field(InstiPhone_2; Rec.ContactDetailPhone_2)
                        {
                            Caption = 'Phone';
                            ApplicationArea = All;
                            // ShowMandatory = true;
                            Editable = EditStatus;
                        }
                        field(ContactDetailPhone_Insti; Rec.ContactDetailPhone2)
                        {
                            Caption = 'Phone 2';
                            ApplicationArea = All;
                            // ShowMandatory = true;
                            Editable = EditStatus;
                        }

                    }

                }
                group("Additional Details")
                {

                    field(InstitutionalAdditionalDet; Rec.InstitutionalAdditionalDet)
                    {
                        Caption = 'Institutional Additional Details';
                        ApplicationArea = All;
                        Editable = EditStatus;
                    }
                }

            }

            group("Corporate Details (Corporates)")
            {
                Visible = ShowCorporateFastTab;
                group("Corporate General")
                {
                    field("CorpShortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                        Editable = EditStatus;
                        Visible = false;
                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;

                    }
                    field("CorpBranch Name"; BranchName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                    }

                    field(CompanyNo; Rec.CompanyNo)
                    {
                        Caption = 'Company No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Company KRA"; Rec.KRA)
                    {
                        Caption = 'Tax Pin No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Corporate Contact Name"; Rec."Primary Contact Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact Person';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                }
                group("Corporate Contact")
                {
                    field("Corporate Physical Address"; Rec."Physical Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Residential Address/Registered Office';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }

                    field("Corporate Phone Number"; Rec."Phone Number")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = PhoneNo;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field(ContactDetailPhone_Corporate; Rec.ContactDetailPhone2)
                    {
                        Caption = 'Phone 2';
                        ApplicationArea = All;
                        // ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Corporate Postal Address"; Rec."Postal Address")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Corporate Postal Code"; Rec."Postal Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }
                    field("Corporate Mailing Address"; Rec."Mailing Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        ShowMandatory = true;
                        Editable = EditStatus;
                    }




                }

            }
            group("Bank Details")
            {

                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        // CurrPage.Banks.
                        CurrPage.Update(true);

                    end;
                }
                field("Bank Name"; BankName)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Bank Branch"; Rec."Bank Branch")
                {
                    ApplicationArea = All;

                    // TableRelation= BankBranch.BankCode where FILTER('');
                    // trigger OnLookup(var Text: Text): Boolean
                    // begin
                    //     // Message('lookup');
                    // end;
                    Editable = EditStatus;
                    DrillDownPageId = "Bank Branch List";
                    trigger OnDrillDown()
                    var
                        _bbranch: Record BankBranch;
                    begin
                        _bbranch.SetRange(BankCode, Rec."Bank Code");
                        if Page.RunModal(Page::"Bank Branch List", _bbranch) = Action::LookupOK then begin
                            // Branch selected, set the branch record to the selected branch
                            Rec."Bank Branch" := _bbranch.BranchCode;
                            BBranchName := _bbranch.BranchName;
                            CurrPage.Update();
                        end;

                    end;

                }
                field("Bank Branch Name"; BBranchName)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bank Account Number"; Rec."Bank Account Number")
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }

                field("Bank Address"; Rec."Bank Address")
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field("SWIFT/BIC Code"; Rec."SWIFT/BIC Code")
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field("IBAN (Int Bank Acc No)"; Rec."IBAN (Int Bank Acc No)")
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field("Bank Payee"; Rec."Bank Payee")
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                // field("Payment Terms"; Rec."Payment Terms")
                // {
                //     ApplicationArea = All;
                // }

            }
            /*group("Other Details")
            {
                field("KYC Details"; Rec."KYC Details")
                {
                    ApplicationArea = All;
                }
                field("Sanctions Check"; Rec."Sanctions Check")
                {
                    ApplicationArea = All;
                }
                field("AML Compliance Details"; Rec."AML Compliance Details")
                {
                    ApplicationArea = All;
                }

                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                }
                field("Additional Notes"; Rec."Additional Notes")
                {
                    ApplicationArea = All;
                }

            }*/

        }

        area(FactBoxes)
        {
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50230),
                              "No." = FIELD("No.");
            }
            //  part("Attached Documents"; "Document Attachment Factbox")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Attachments';
            //     SubPageLink = "Table ID" = CONST(50230),
            //                   "No." = FIELD("No.");
            // }
            // systempart(FunderLinks; Links)
            // {
            //     ApplicationArea = RecordLinks;
            // }
            // systempart(FunderNotes; Notes)
            // {
            //     ApplicationArea = Notes;
            // }
        }
    }

    actions
    {

        area(Processing)
        {

            action("Funder Ledger Entry")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Ledger';
                Image = LedgerEntries;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");
                trigger OnAction()
                var
                    funderLedgerEntry: Record FunderLedgerEntry;
                begin
                    funderLedgerEntry.SETRANGE(funderLedgerEntry."Funder No.", Rec."No.");
                    funderLedgerEntry.SetFilter(funderLedgerEntry."Document Type", '<>%1', funderLedgerEntry."Document Type"::"Remaining Amount");
                    PAGE.RUN(PAGE::FunderLedgerEntry, funderLedgerEntry);

                end;
            }
            action(BeneficiaryTrustee)
            {
                ApplicationArea = Basic, Suite;
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Beneficiary & Trustees';
                ToolTip = 'Beneficiary & Trustees ';
                // RunObject = page "Funder Loan Ben. Trus.";
                trigger OnAction()
                var
                    btTbl: Record "Funder Ben/Trus";

                begin
                    btTbl.Reset();
                    btTbl.SetRange("Funder No.", Rec."No.");
                    PAGE.Run(Page::"Funder Ben. Trus.", btTbl);
                end;

            }


            action("Funder Loan Open")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Loan (Open)';
                Image = CashReceiptJournal;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");

                trigger OnAction()
                var
                    funderLoan: Record "Funder Loan";
                begin
                    funderLoan.SETRANGE(funderLoan."Funder No.", Rec."No.");
                    funderLoan.SETRANGE(funderLoan.Status, funderLoan.Status::Open);
                    PAGE.RUN(PAGE::"Funder Loans List", funderLoan);

                end;
            }
            action("Funder Loan Pending")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Loan (Pending)';
                Image = CashReceiptJournal;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");
                trigger OnAction()
                var
                    funderLoan: Record "Funder Loan";
                begin
                    funderLoan.SETRANGE(funderLoan."Funder No.", Rec."No.");
                    funderLoan.SETRANGE(funderLoan.Status, funderLoan.Status::"Pending Approval");
                    PAGE.RUN(PAGE::"Funder Loans List", funderLoan);

                end;
            }
            action("Funder Loan Approved")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Funder Loan (Approved)';
                Image = CashReceiptJournal;
                PromotedCategory = Process;
                Promoted = true;
                // RunObject = Page "Funder Loans List";
                //RunPageLink = "Funder No." = FIELD("No.");
                trigger OnAction()
                var
                    funderLoan: Record "Funder Loan";
                begin
                    funderLoan.SETRANGE(funderLoan."Funder No.", Rec."No.");
                    funderLoan.SETRANGE(funderLoan.Status, funderLoan.Status::Approved);
                    PAGE.RUN(PAGE::"Funder Loans List", funderLoan);

                end;
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval to change the record.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()

                    var
                        CustomWorkflowMgmt: Codeunit "Funders Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        if Rec.FunderType <> Rec.FunderType::"Bank Overdraft" then
                            if Rec."Payables Account" = '' then
                                Error('Principal Account Required');
                        if Rec."Interest Expense" = '' then
                            Error('Interest Expense Account Required');
                        if Rec."Interest Payable" = '' then
                            Error('Interest Payable Account Required');
                        if Rec.Portfolio = '' then
                            Error('Portfolio Required');
                        if Rec.FunderType = Rec.FunderType::"Bank Overdraft" then
                            if Rec.FundSource = '' then
                                Error('Receiving Bank Account Required');

                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Funders Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        CustomWorkflowMgmt.OnCancelWorkflowForApproval(RecRef);
                    end;
                }

                action(SendReopenApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send Reopen A&pproval Request';
                    Enabled = Rec.Status = Rec.Status::Approved;
                    Image = UnApply;
                    ToolTip = 'Request Reopen approval to change the record.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()

                    var
                        CustomWorkflowMgmt: Codeunit "Funders Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
                    end;
                }
            }

            action("Portfolio Fee Setup")
            {
                Caption = 'Applicable Fee';
                Image = InsertStartingFee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                // RunObject = page "Portfolio Fee Setup";
                trigger OnAction()
                var
                    _portfolio: page "Portfolio Fee Setup";
                    GFilter: Codeunit GlobalFilters;
                    _portfolioFeeTbl: Record "Portfolio Fee Setup";
                begin
                    // Page.Run(Page::"Portfolio Fee Setup", Rec, Rec."No.");
                    // GFilter.SetGlobalFilter(Rec."No.");
                    // _portfolio.Run();
                    // _portfolio.SetTableView(Rec);
                    // _portfolio.run()

                    _portfolioFeeTbl.Reset();
                    _portfolioFeeTbl.SetRange(_portfolioFeeTbl.FunderNo, Rec."No.");
                    Page.Run(Page::"Portfolio Fee Setup", _portfolioFeeTbl);
                end;
            }
            action("attachment")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }
        area(Reporting)
        {
            group("Analysis and Docs")
            {
                action("ReEvaluateFX")
                {
                    ApplicationArea = All;
                    Caption = 'ReEvaluateFX';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    RunObject = report ReEvaluateFX;
                    Visible = false;

                }
                action("Capitalize Interest")
                {
                    ApplicationArea = All;
                    Caption = 'Capitalize Interest';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    RunObject = report "Capitalize Interest";
                    Visible = false;

                }

            }
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()

                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;

                    PromotedCategory = New;


                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View approval requests.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = HasApprovalEntries;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
            }


        }

    }

    // Trigger to update FastTab visibility when the page is opened
    trigger OnOpenPage()
    begin
        UpdateFastTabVisibility();
        FieldEditProp();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        Rec."Origin Entry" := Rec."Origin Entry"::Funder;
    end;

    trigger OnAfterGetRecord()
    begin
        DimensionValue.Reset();
        DimensionValue.SetRange(DimensionValue."Dimension Code", 'BRANCH');
        DimensionValue.SetRange(DimensionValue.Code, Rec."Shortcut Dimension 1 Code");
        if DimensionValue.Find('-') then
            BranchName := DimensionValue.Name;

        Banks.Reset();
        Banks.SetRange(Banks.BankCode, Rec."Bank Code");
        if Banks.Find('-') then
            BankName := Banks.Name;

        BankBranch.Reset();
        BankBranch.SetRange(BranchCode, Rec."Bank Branch");
        if BankBranch.Find('-') then
            BBranchName := BankBranch.BranchName;

        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
        FieldEditProp();
    end;
    // Trigger to update FastTab visibility when the record is loaded
    trigger OnAfterGetCurrRecord()
    begin
        UpdateFastTabVisibility();
        FieldEditProp()
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // if Rec.Portfolio = '' then
        //     Error('Portfolio Mandatory');
        // if Rec.FunderType = Rec.FunderType::Individual then begin
        //     if Rec."Mailing Address" = '' then
        //         Error('Email Required');
        // end;

    end;
    // Local procedure to update FastTab visibility
    local procedure UpdateFastTabVisibility()
    begin
        // Show the Shipping FastTab only if the Country/Region Code is "US"
        ShowIndividualFastTab := Rec.FunderType = Rec.FunderType::Individual;
        ShowInstitutionalFastTab := Rec.FunderType = Rec.FunderType::Institutional;
        ShowJointFastTab := Rec.FunderType = Rec.FunderType::"Joint Application";
        ShowCorporateFastTab := Rec.FunderType = Rec.FunderType::Corporate;
        ShowCorporateFastTab := Rec.FunderType = Rec.FunderType::Relatedparty;
    end;

    local procedure FieldEditProp()
    var
    begin
        EditStatus := (Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Rejected);

    end;

    var
        myInt: Integer;
        BranchName: Code[250];
        BankName: Text[50];
        BBranchName: Text[50];
        DimensionValue: Record "Dimension Value";
        Banks: Record Banks;
        BankBranch: Record BankBranch;
        ShowIndividualFastTab, ShowInstitutionalFastTab : Boolean;
        ShowJointFastTab: Boolean;
        ShowCorporateFastTab: Boolean;

        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        EditStatus: Boolean;
}