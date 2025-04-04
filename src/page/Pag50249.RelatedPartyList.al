page 50249 "Related Party List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 50248;
    CardPageId = 50280;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(RelatedPName; Rec.RelatedPName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }
                // field(RelatedPSysRefNo; Rec.RelatedPSysRefNo)
                // {
                //     ApplicationArea = All;
                //     Caption = 'System Reference No.';
                // }
                // field(RelatedPCoupaRef; Rec.RelatedPCoupaRef)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Coupa Reference No.';
                // }
                // field(RelatedP_Email; Rec.RelatedP_Email)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Email';
                // }
                field(RelatedP_Mobile; Rec.RelatedP_Mobile)
                {
                    ApplicationArea = All;
                    Caption = 'Mobile';
                }
                field(RelatedP_ContactEmail; Rec.RelatedP_ContactEmail)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Email';
                }
                field(PlacementDate; Rec.PlacementDate)
                {
                    ApplicationArea = All;
                    Caption = 'Placement Date';
                }
                field(MaturityDate; Rec.MaturityDate)
                {
                    ApplicationArea = All;
                    Caption = 'Maturity Date';
                }
                field(DisbursedCurrency; Rec.Currency)
                {
                    ApplicationArea = All;
                    Caption = 'Currency';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                }
                field(PinNo; Rec.PinNo)
                {
                    ApplicationArea = All;
                    Caption = 'Pin No.';
                }
                field(InterestRatePA; Rec.InterestRatePA)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Rate P.A';
                }
                field(InterestRepaymentFreq; Rec.InterestRepaymentFreq)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Repayment Frequency';
                }
                field(PrincipleRepaymentFreq; Rec.PrincipleRepaymentFreq)
                {
                    ApplicationArea = All;
                    Caption = 'Principal Repayment Frequency';
                }
                field(BankAcc; Rec.BankAcc)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Account';
                }
                field(InterestMethod; Rec.InterestMethod)
                {
                    ApplicationArea = All;
                    Caption = 'Interest Method';
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