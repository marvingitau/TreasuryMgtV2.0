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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                }
                field("Actual Program Size"; Rec."Actual Program Size")
                {
                    ApplicationArea = All;
                    Caption = 'Actual Program Size';
                }
                // field("Actual Program Size"; Rec."Actual Program Size")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Actual Program Size';
                //     // DrillDown = true;
                //     // DrillDownPageId = 50235;
                //     Editable = false;
                //     trigger OnDrillDown()
                //     var
                //         loans: Record "Funder Loan";
                //     begin
                //         // loans.SetRange(Category, Rec.Category);
                //         loans.SetRange(loans.Status, loans.Status::Approved);
                //         Page.Run(Page::"Funder Loans List", loans);
                //     end;

                // }
                // field(BeginDate; Rec.BeginDate)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Begin Date';
                // }
                // field(ProgramTerm; Rec.ProgramTerm)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Program Term (Year)';
                // }
                // field(EndTerm; Rec.EndTerm)
                // {
                //     ApplicationArea = All;
                //     Caption = 'End Term';
                // }
                // field("Fee Applicable"; Rec."Fee Applicable")
                // {
                //     ApplicationArea = All;
                // }
                // field("Interest Rate Applicable"; Rec."Interest Rate Applicable")
                // {
                //     ApplicationArea = All;
                // }
                // field("Physical Address"; Rec."Physical Address")
                // {
                //     ApplicationArea = All;
                // }
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


    trigger OnOpenPage()
    begin
        Rec.SetRange(Rec."Origin Entry", Rec."Origin Entry"::Funder);
    end;

    trigger OnAfterGetRecord()
    var
        _funder: Record Funders;
    begin
        IsUpdating := false;
        if not IsUpdating then begin // Prevent recursion
            IsUpdating := true;

            // _funder.Reset();
            // _funder.SetRange(_funder.Portfolio, Rec."No.");
            // _funder.SetRange(_funder.Status, _funder.Status::Approved);
            // if _funder.Find('-') then begin
            //     repeat
            //         FunderLoan.SetRange(FunderLoan."Funder No.", _funder."No.");
            //         FunderLoan.SetRange(FunderLoan.Status, FunderLoan.Status::Approved);
            //         if FunderLoan.Find('-') then begin
            //             repeat
            //                 FunderLoan.CalcFields(OutstandingAmntDisbLCY);
            //                 ActualProgramSize := ActualProgramSize + FunderLoan.OutstandingAmntDisbLCY;

            //             until FunderLoan.Next() = 0;
            //         end;

            //     until _funder.Next() = 0;
            // end;

            // Rec."Actual Program Size" := ActualProgramSize;
            // Rec.OutstandingAmountToTarget := Rec.ProgramSize - ActualProgramSize;
            // Rec.Modify();

            IsUpdating := false;
        end;
    end;



    var
        IsUpdating: Boolean;
        FunderLoan: Record "Funder Loan";
        ActualProgramSize: Decimal;
}