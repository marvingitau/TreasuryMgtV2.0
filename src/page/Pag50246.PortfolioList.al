page 50246 "Portfolio List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Portfolio;
    CardPageId = 50231;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(ProgramSize; Rec.ProgramSize)
                {
                    ApplicationArea = All;
                }
                field(BeginDate; Rec.BeginDate)
                {
                    ApplicationArea = All;
                }
                field(ProgramTerm; Rec.ProgramTerm)
                {
                    ApplicationArea = All;
                }
                field(ProgramCurrency; Rec.ProgramCurrency)
                {
                    ApplicationArea = All;
                }
                field("Fee Applicable"; Rec."Fee Applicable")
                {
                    ApplicationArea = All;
                }
                field("Interest Rate Applicable"; Rec."Interest Rate Applicable")
                {
                    ApplicationArea = All;
                }
                field("Physical Address"; Rec."Physical Address")
                {
                    ApplicationArea = All;
                }
                // field(Value; Rec.Value)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Title';
                // }
                // field(Abbreviation; Rec.Abbreviation)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Abbreviation';
                // }
                // field(InternalRef; Rec.InternalRef)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Internal Reference';
                // }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
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