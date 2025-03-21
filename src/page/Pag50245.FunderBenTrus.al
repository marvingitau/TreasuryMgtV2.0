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
                }
                field("ID/Passport No."; Rec."ID/Passport No.")
                {
                    ApplicationArea = All;
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