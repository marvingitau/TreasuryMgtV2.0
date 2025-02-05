page 50241 "Bank Branch List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 50238;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(BankCode; Rec.BankCode)
                {
                    ApplicationArea = All;
                }
                field(BranchCode; Rec.BranchCode)
                {
                    ApplicationArea = All;
                }
                field(BranchName; Rec.BranchName)
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
}