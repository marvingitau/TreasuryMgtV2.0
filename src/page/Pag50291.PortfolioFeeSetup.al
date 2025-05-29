page 50291 "Portfolio Fee Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Portfolio Fee Setup";
    Caption = 'Applicable Fee';
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Fee Percentage"; Rec."Fee Percentage")
                {
                    ApplicationArea = All;
                }
                // field("Fee Applicable %"; Rec."Fee Applicable %")
                // {
                //     ApplicationArea = All;
                // }

                field(PortfolioNo; Rec.PortfolioNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = PortfolioView;
                }
                field(FunderNo; Rec.FunderNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FunderView;
                }
                field(Applicable; Rec.Applicable)
                {
                    ApplicationArea = All;
                    Visible = LoanView;
                }
                field(FunderLoanNo; Rec.FunderLoanNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = LoanView;
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

    trigger OnInit()
    begin
        PortfolioNo := GFilter.GetGlobalPortfolioFilter();
        if PortfolioNo <> '' then begin
            PortfolioTbl.Reset();
            PortfolioTbl.SetRange("No.", PortfolioNo);
            if PortfolioTbl.Find('-') then begin
                if PortfolioTbl.Category = PortfolioTbl.Category::" " then begin
                    Error('Select Category First');
                    exit;
                end;
                if PortfolioTbl.Category = PortfolioTbl.Category::"Bank Loan" then
                    Rec.Category := Rec.Category::"Bank Loan";
                if PortfolioTbl.Category = PortfolioTbl.Category::Individual then
                    Rec.Category := Rec.Category::Individual;
                if PortfolioTbl.Category = PortfolioTbl.Category::Institutional then
                    Rec.Category := Rec.Category::Institutional;
                if PortfolioTbl.Category = PortfolioTbl.Category::"Asset Term Manager" then
                    Rec.Category := Rec.Category::"Asset Term Manager";
                if PortfolioTbl.Category = PortfolioTbl.Category::"Medium Term Notes" then
                    Rec.Category := Rec.Category::"Medium Term Notes";
                Rec.PortfolioNo := PortfolioTbl."No.";
            end;
        end;

        LoanNo := GFilter.GetGlobalLoanFilter();
        if LoanNo <> '' then begin
            LoanTbl.Reset();
            LoanTbl.SetRange("No.", LoanNo);
            if LoanTbl.Find('-') then begin
                if LoanTbl.Category = '' then begin
                    Error('Select Category First');
                    exit;
                end;
                if LoanTbl.Category = 'Bank Loan' then
                    Rec.Category := Rec.Category::"Bank Loan";
                if LoanTbl.Category = 'Individual' then
                    Rec.Category := Rec.Category::Individual;
                if LoanTbl.Category = 'Institutional' then
                    Rec.Category := Rec.Category::Institutional;
                if LoanTbl.Category = 'Asset Term Manager' then
                    Rec.Category := Rec.Category::"Asset Term Manager";
                if LoanTbl.Category = 'Medium Term Notes' then
                    Rec.Category := Rec.Category::"Medium Term Notes";
                Rec.FunderLoanNo := LoanTbl."No.";
            end;
        end;

        FunderNo := GFilter.GetGlobalFilter();
        if FunderNo <> '' then begin
            FunderTbl.Reset();
            FunderTbl.SetRange("No.", FunderNo);
            if FunderTbl.Find('-') then begin
                if FunderTbl.Portfolio = '' then begin
                    Error('Select Portfolio First');
                    exit;
                end;
                // if FunderTbl.Category = 'Bank Loan' then
                //     Rec.Category := Rec.Category::"Bank Loan";
                // if FunderTbl.Category = 'Individual' then
                //     Rec.Category := Rec.Category::Individual;
                // if FunderTbl.Category = 'Institutional' then
                //     Rec.Category := Rec.Category::Institutional;
                // if FunderTbl.Category = 'Asset Term Manager' then
                //     Rec.Category := Rec.Category::"Asset Term Manager";
                // if FunderTbl.Category = 'Medium Term Notes' then
                //     Rec.Category := Rec.Category::"Medium Term Notes";
                Rec.FunderNo := FunderTbl."No.";
            end;
        end;
    end;

    trigger OnOpenPage()
    var
        CurrentFilters: Text;
    begin
        // CurrentFilters := Rec.GetFilters();
        PortfolioView := false;
        FunderView := false;
        LoanView := false;

        PortfolioNo := GFilter.GetGlobalPortfolioFilter();
        if PortfolioNo <> '' then begin
            PortfolioTbl.Reset();
            PortfolioTbl.SetRange("No.", PortfolioNo);
            if PortfolioTbl.Find('-') then begin
                Rec.Reset();
                Rec.SetRange(Rec.PortfolioNo, PortfolioNo);
                if PortfolioTbl.Category = PortfolioTbl.Category::"Bank Loan" then
                    Rec.SetRange(Rec.Category, Rec.Category::"Bank Loan");
                if PortfolioTbl.Category = PortfolioTbl.Category::Individual then
                    Rec.SetRange(Rec.Category, Rec.Category::Individual);
                if PortfolioTbl.Category = PortfolioTbl.Category::Institutional then
                    Rec.SetRange(Rec.Category, Rec.Category::Institutional);
                if PortfolioTbl.Category = PortfolioTbl.Category::"Asset Term Manager" then
                    Rec.SetRange(Rec.Category, Rec.Category::"Asset Term Manager");
                if PortfolioTbl.Category = PortfolioTbl.Category::"Medium Term Notes" then
                    Rec.SetRange(Rec.Category, Rec.Category::"Medium Term Notes");
            end;
            PortfolioView := true;
        end;

        LoanNo := GFilter.GetGlobalLoanFilter();
        if LoanNo <> '' then begin
            LoanTbl.Reset();
            LoanTbl.SetRange("No.", LoanNo);
            if LoanTbl.Find('-') then begin
                Rec.Reset();
                // Rec.SetRange(Rec.FunderLoanNo, LoanNo);
                if LoanTbl.Category = 'BANK LOAN' then
                    Rec.SetRange(Rec.Category, Rec.Category::"Bank Loan");
                if LoanTbl.Category = UpperCase('Individual') then
                    Rec.SetRange(Rec.Category, Rec.Category::Individual);
                if LoanTbl.Category = UpperCase('Institutional') then
                    Rec.SetRange(Rec.Category, Rec.Category::Institutional);
                if LoanTbl.Category = UpperCase('Asset Term Manager') then
                    Rec.SetRange(Rec.Category, Rec.Category::"Asset Term Manager");
                if LoanTbl.Category = UpperCase('Medium Term Notes') then
                    Rec.SetRange(Rec.Category, Rec.Category::"Medium Term Notes");
            end;
            LoanView := true;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin
        PortfolioNo := GFilter.GetGlobalPortfolioFilter();
        if PortfolioNo <> '' then begin
            PortfolioTbl.Reset();
            PortfolioTbl.SetRange("No.", PortfolioNo);
            if PortfolioTbl.Find('-') then begin
                if PortfolioTbl.Category = PortfolioTbl.Category::"Bank Loan" then
                    Rec.Category := Rec.Category::"Bank Loan";
                if PortfolioTbl.Category = PortfolioTbl.Category::Individual then
                    Rec.Category := Rec.Category::Individual;
                if PortfolioTbl.Category = PortfolioTbl.Category::Institutional then
                    Rec.Category := Rec.Category::Institutional;
                if PortfolioTbl.Category = PortfolioTbl.Category::"Asset Term Manager" then
                    Rec.Category := Rec.Category::"Asset Term Manager";
                if PortfolioTbl.Category = PortfolioTbl.Category::"Medium Term Notes" then
                    Rec.Category := Rec.Category::"Medium Term Notes";
                Rec.PortfolioNo := PortfolioTbl."No.";

            end
        end;

        LoanNo := GFilter.GetGlobalLoanFilter();
        if LoanNo <> '' then begin
            LoanTbl.Reset();
            LoanTbl.SetRange("No.", LoanNo);
            if LoanTbl.Find('-') then begin
                if LoanTbl.Category = UpperCase('Bank Loan') then
                    Rec.Category := Rec.Category::"Bank Loan";
                if LoanTbl.Category = UpperCase('Individual') then
                    Rec.Category := Rec.Category::Individual;
                if LoanTbl.Category = UpperCase('Institutional') then
                    Rec.Category := Rec.Category::Institutional;
                if LoanTbl.Category = UpperCase('Asset Term Manager') then
                    Rec.Category := Rec.Category::"Asset Term Manager";
                if LoanTbl.Category = UpperCase('Medium Term Notes') then
                    Rec.Category := Rec.Category::"Medium Term Notes";
                Rec.FunderLoanNo := LoanTbl."No.";

            end
        end;
    end;

    var
        GFilter: Codeunit GlobalFilters;
        PortfolioNo: Code[20];
        LoanNo: Code[20];
        FunderNo: Code[20];
        PortfolioTbl: Record Portfolio;
        LoanTbl: Record "Funder Loan";
        FunderTbl: Record Funders;
        PortfolioView, FunderView, LoanView : boolean;

}