report 50284 "Overdraft Interest Posting"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    // DefaultRenderingLayout = LayoutName;
    ProcessingOnly = true;

    //Process Closed Tranactions
    dataset
    {
        dataitem("Overdraft Ledger Entries"; "Overdraft Ledger Entries")
        {
            trigger OnPreDataItem()
            begin
                "Overdraft Ledger Entries".SetRange(Closed, true);
                if (PostingStartDate <> 0D) and (PostingEndDate <> 0D) then begin
                    "Overdraft Ledger Entries".SetRange("Posting Date", PostingStartDate, PostingEndDate);
                end;
                if FunderNo <> '' then
                    "Overdraft Ledger Entries".SetRange("Funder No.", FunderNo);
            end;

            trigger OnAfterGetRecord()
            var
                _docNo: Code[20];
            begin
                LoanTbl.Reset();
                LoanTbl.SetRange("No.", "Overdraft Ledger Entries"."Loan No.");
                if not LoanTbl.Find('-') then
                    Error('Missing Loan %1 during Overdraft interest posting', "Overdraft Ledger Entries"."Loan No.");
                _docNo := TrsyMgt.GenerateDocumentNumber();
                FunderTbl.Reset();
                FunderTbl.SetRange("No.", "Funder No.");
                if not FunderTbl.Find('-') then
                    Error('Missing Funder %1 during Overdraft interest posting', "Funder No.");

                // ***************** Create interest

                if (true) then //LoanTbl.EnableGLPosting = true
                    FunderMgt.DirectGLPosting('interest', LoanTbl."Interest Expense", "Balance Difference", 'Overdraft Interest Amount', "Loan No.", LoanTbl."Interest Payable", LoanTbl.Currency, '', _docNo, 'Bank Ref. No.', FunderTbl."Shortcut Dimension 1 Code");

                "Overdraft Ledger Entries".Processed := true;
                "Overdraft Ledger Entries".Modify();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(PostingStartDate; PostingStartDate)
                    {
                        Caption = 'Posting Start Date';
                        ShowMandatory = true;
                    }
                    field(PostingEndDate; PostingEndDate)
                    {
                        Caption = 'Posting End Date';
                        ShowMandatory = true;
                    }
                    field(FunderNo; FunderNo)
                    {
                        Caption = 'Funder No.';
                        TableRelation = Funders."No.";
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

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = Excel;
    //         LayoutFile = 'mySpreadsheet.xlsx';
    //     }
    // }

    trigger OnPreReport()
    begin
        // LoanNo := "Overdraft Ledger Entries".GetFilter("Loan No.");
        if (PostingStartDate = 0D) then
            Error('Posting Start Date Missing');
        if (PostingEndDate = 0D) then
            Error('Posting End Date Missing');

    end;

    trigger OnPostReport()
    begin
        Message(' Overdraft interest Posting Done');
    end;

    var
        PostingStartDate: Date;
        PostingEndDate: Date;
        LoanNo: Code[20];
        FunderNo: Code[20];
        OverdraftLedgerEntryTbl: Record "Overdraft Ledger Entries";
        BankAccount: Record "Bank Account";
        FunderTbl: Record Funders;
        LoanTbl: Record "Funder Loan";
        FunderMgt: Codeunit FunderMgtCU;
        TrsyMgt: Codeunit "Treasury Mgt CU";
}