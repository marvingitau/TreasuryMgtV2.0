page 50245 "Funder Ben. Trus."
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 50243;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Funder Loan No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Relation; Rec.Relation)
                {
                    ApplicationArea = All;
                }
                field(DOB; Rec.DOB)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin

                        if Rec.Type <> Rec.Type::Beneficiary then
                            // 18 years = 6570 days (365.25 * 18)
                            if not (Today() - Rec.DOB >= 6570) then
                                Error('DOB is below 18 yrs');
                    end;
                }
                field("Identification Doc."; Rec."Identification Doc.")
                {
                    ApplicationArea = All;
                }
                field("Employer Identification Number"; Rec."Employer Identification Number")
                {
                    ApplicationArea = All;
                    Caption = 'ID No.';
                    Enabled = Rec."Identification Doc." = Rec."Identification Doc."::ID;
                }
                field("Employer Passport Number"; Rec."Employer Passport Number")
                {
                    ApplicationArea = All;
                    Caption = 'Passport No.';
                    Enabled = Rec."Identification Doc." = Rec."Identification Doc."::Passport;
                }
                field("Birth Cert. Number"; Rec."Birth Cert. Number")
                {
                    ApplicationArea = All;
                    Caption = 'Birth certificate No.';
                    Enabled = Rec."Identification Doc." = Rec."Identification Doc."::"Birth Certificate";
                }
                field(PhoneNo; Rec.PhoneNo)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        FunderNo := Rec.GetFilter("Funder No.")
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if FunderNo <> '' then
            Rec."Funder No." := FunderNo;
    end;

    var
        FunderNo: Code[20];
}