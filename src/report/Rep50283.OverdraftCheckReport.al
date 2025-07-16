report 50283 "Overdraft Check Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Funder Loan"; "Funder Loan")
        {
            trigger OnPreDataItem()
            begin
                "Funder Loan".SetRange(Category, 'BANK OVERDRAFT');
                "Funder Loan".SetRange(Status, Status::Approved);
                if LoanNo <> '' then
                    "Funder Loan".SetRange("No.", LoanNo);
            end;

            trigger OnAfterGetRecord()
            var
                _lcyBalanceAmount: Decimal;
                _BalanceAmount: Decimal;
            begin
                OverdraftLedgerEntryTbl.Reset();
                OverdraftLedgerEntryTbl.SetFilter("Posting Date", '=%1', Today);
                OverdraftLedgerEntryTbl.SetRange("Loan No.", "Funder Loan"."No.");
                if OverdraftLedgerEntryTbl.Find('-') then
                    CurrReport.Skip();

                BankAccount.Reset();
                BankAccount.SetRange("No.", "Funder Loan".FundSource);
                if not BankAccount.Find('-') then
                    Error('Bank Account %1 not found', "Funder Loan".FundSource);
                BankAccount.CalcFields("Balance (LCY)");
                _lcyBalanceAmount := BankAccount."Balance (LCY)";
                if _lcyBalanceAmount < 0 then begin
                    //Check if Closing Data is posted.
                    OverdraftLedgerEntryTbl.Reset();
                    OverdraftLedgerEntryTbl.SetRange("Funder No.", "Funder Loan"."Funder No.");
                    OverdraftLedgerEntryTbl.SetRange("Loan No.", "Funder Loan"."No.");
                    OverdraftLedgerEntryTbl.SetRange("Posting Date", Today);
                    OverdraftLedgerEntryTbl.SetRange(Closed, false);
                    if OverdraftLedgerEntryTbl.Find('-') then begin
                        OverdraftLedgerEntryTbl."Closing Bal." := Abs(_lcyBalanceAmount);
                        OverdraftLedgerEntryTbl."Balance Difference" := Abs(Abs(_lcyBalanceAmount) - OverdraftLedgerEntryTbl."Opening Bal.");
                        OverdraftLedgerEntryTbl.Closed := true;
                        OverdraftLedgerEntryTbl.Modify();

                        //Next days Opening  record
                        OverdraftLedgerEntryTbl1.Init();
                        OverdraftLedgerEntryTbl1."Line No." := OverdraftLedgerEntryTbl."Line No." + 1;
                        OverdraftLedgerEntryTbl1."Funder No." := "Funder Loan"."Funder No.";
                        OverdraftLedgerEntryTbl1."Loan No." := "Funder Loan"."No.";
                        OverdraftLedgerEntryTbl1."Posting Date" := CalcDate('<+1D>', Today());
                        OverdraftLedgerEntryTbl1."Opening Bal." := Abs(_lcyBalanceAmount);
                        OverdraftLedgerEntryTbl1."Bank Account" := "Funder Loan".FundSource;
                        OverdraftLedgerEntryTbl1."Twin Record ID" := OverdraftLedgerEntryTbl."Loan No.";
                        OverdraftLedgerEntryTbl1.Insert();
                    end else begin
                        //Closing Open entries that did not close due to missing negative bal
                        //********** During Interest Calculations zerorize missing closing

                        //*New/Initial Closing record
                        OverdraftLedgerEntryTbl.Init();
                        OverdraftLedgerEntryTbl."Funder No." := "Funder Loan"."Funder No.";
                        OverdraftLedgerEntryTbl."Loan No." := "Funder Loan"."No.";
                        OverdraftLedgerEntryTbl."Posting Date" := Today;
                        OverdraftLedgerEntryTbl."Closing Bal." := Abs(_lcyBalanceAmount);
                        OverdraftLedgerEntryTbl."Bank Account" := "Funder Loan".FundSource;
                        OverdraftLedgerEntryTbl."Balance Difference" := Abs(_lcyBalanceAmount);
                        OverdraftLedgerEntryTbl.Closed := true;
                        if OverdraftLedgerEntryTbl.Insert() then begin
                            //Next days Opening record
                            OverdraftLedgerEntryTbl2.Init();
                            OverdraftLedgerEntryTbl2."Line No." := OverdraftLedgerEntryTbl."Line No." + 1;
                            OverdraftLedgerEntryTbl2."Funder No." := "Funder Loan"."Funder No.";
                            OverdraftLedgerEntryTbl2."Loan No." := "Funder Loan"."No.";
                            OverdraftLedgerEntryTbl2."Posting Date" := CalcDate('<+1D>', Today());
                            OverdraftLedgerEntryTbl2."Opening Bal." := Abs(_lcyBalanceAmount);
                            OverdraftLedgerEntryTbl2."Bank Account" := "Funder Loan".FundSource;
                            OverdraftLedgerEntryTbl2."Twin Record ID" := OverdraftLedgerEntryTbl."Loan No.";
                            OverdraftLedgerEntryTbl2.Closed := false;
                            OverdraftLedgerEntryTbl2.Insert();
                        end;
                    end;

                end;
            end;
        }


    }
    requestpage
    {
        // AboutTitle = 'Teaching tip title';
        // AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(FunderLoanNumber; LoanNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Loan No.';
                        TableRelation = "Funder Loan"."No.";
                    }
                }
            }
        }


    }

    trigger OnInitReport()
    var
    begin

    end;

    var
        OverdraftLedgerEntryTbl: Record "Overdraft Ledger Entries";
        OverdraftLedgerEntryTbl1: Record "Overdraft Ledger Entries";
        OverdraftLedgerEntryTbl2: Record "Overdraft Ledger Entries";
        BankAccount: Record "Bank Account";
        LoanNo: Code[20];
}