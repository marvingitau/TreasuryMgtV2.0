report 50242 "Related Party Statement"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("RelatedParty- Cust"; "RelatedParty- Cust")
        {
            column(No_; "No.")
            {

            }
            dataitem(RelatedLedgerEntry; RelatedLedgerEntry)
            {
                DataItemLink = "RelatedParty No." = field("No.");
                DataItemLinkReference = "RelatedParty- Cust";

            }
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(No; RelatedNo)
                    {
                        TableRelation = "RelatedParty- Cust"."No.";
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'reports/relatedstatement.rdlc';
        }
    }

    var
        RelatedNo: Code[20];
}