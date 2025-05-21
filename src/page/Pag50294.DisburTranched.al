page 50294 "Disbur. Tranched"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Disbur. Tranched Loan";
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Payed"; Rec."Total Payed")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Bank Account"; Rec."Bank Account")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Tranche Amount"; Rec."Tranche Amount")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                }
                field("Disbursement Date"; Rec."Disbursement Date")
                {
                    ApplicationArea = All;
                }
                field("Maturity Date"; Rec."Maturity Date")
                {
                    ApplicationArea = All;
                }
                field("Cumulative Disbursed"; Rec."Cumulative Disbursed")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Remaining Balance"; Rec."Remaining Balance")
                {
                    ApplicationArea = All;
                    Editable = false;

                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Disburse Tranch")
            {
                Image = TransferToLines;
                Visible = false;
                trigger OnAction()
                var
                    _funderMgt: Codeunit FunderMgtCU;
                    _funderLoan: Record "Funder Loan";
                    _bankAccount: Code[20];
                    _loanAccount: Code[20];
                begin
                    LoanNo := GFilter.GetGlobalLoanFilter();
                    if Confirm('Are you sure?', false) then
                        exit
                    else begin

                        // _funderLoan.Reset();
                        // _funderLoan.SetRange("No.", LoanNo);
                        // if not _funderLoan.Find('-') then begin
                        //     Error('Funder Loan %1 Not Found', LoanNo);
                        // end;
                        // _funderMgt.DirectGLPosting('init', _loanAccount, Rec."Tranche Amount", 'Trach Amount', LoanNo, _bankAccount, _funderLoan.Currency, '', '', '')
                    end;
                end;
            }
        }
    }

    // trigger OnAfterGetRecord()
    // begin
    //     if Rec."Loan No." = '' then
    //         Rec."Loan No." := LoanNo;
    // end;

    var

        GFilter: Codeunit GlobalFilters;
        trache: Record 50293;
        LoanNo: Code[20];
}