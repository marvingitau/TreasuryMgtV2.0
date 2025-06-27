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
            column(Related_Name; RelatedPName) { }

            dataitem(RelatedLedgerEntry; RelatedLedgerEntry)
            {
                DataItemLink = "RelatedParty No." = field("No.");
                DataItemLinkReference = "RelatedParty- Cust";
                column(Posting_Date; "Posting Date") { }
                column(Document_No_; "Document No.") { }
                column(Document_Type; "Document Type") { }
                column(Description; Description) { }
                column(Amount; Amount) { }
                column(Amount_LCY_; "Amount(LCY)") { }
            }
            trigger OnAfterGetRecord()
            begin
                // RelatedLedgerEntry.SetRange("RelatedParty No.", "No.");
            end;
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


    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'reports/relatedstatement.rdlc';
        }
    }
    trigger OnPreReport()
    var
    begin
        /*ReportFlag.Reset();
        ReportFlag.SetFilter("Line No.", '<>%1', 0);
        ReportFlag.SetFilter("Utilizing User", '=%1', UserId);
        if not ReportFlag.FindFirst() then
            Error('No Report Flag Added');
        RelatedNo := ReportFlag."Related Party No";*/
    end;

    var
        RelatedNo: Code[20];

        RelatedPartyTbl: Record "RelatedParty- Cust";
        ReportFlag: Record "Report Flags";
}