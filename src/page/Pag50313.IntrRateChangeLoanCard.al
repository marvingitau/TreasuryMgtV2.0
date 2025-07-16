page 50313 "Intr. Rate Change Loan Card"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Interest Rate Change";
    Caption = 'Interest Rate Change List';
    // Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                }
                field("Inter. Rate Group Name"; Rec."Inter. Rate Group Name")
                {
                    ApplicationArea = All;
                    Caption = 'Group Name';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Effective Dates"; Rec."Effective Dates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Effective Date (from when the new rate applies)';
                }
                field("New Interest Rate"; Rec."New Interest Rate")
                {
                    ApplicationArea = All;
                    Caption = 'New Interest Rate (%)';
                }
                field(Active; Rec.Active)
                {
                    Caption = 'Current Interest';
                    ApplicationArea = All;
                    Visible = false;

                }
                field(Enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                    ApplicationArea = All;
                    Enabled = false;
                    Visible = false;
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
            action(SelecteCurrent)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Pick Current as Current';
                Image = Process;
                PromotedCategory = Process;
                Promoted = true;
                trigger OnAction()
                var
                    _funderLoan: Record "Funder Loan";
                    _loanNo: Code[20];
                begin
                    _loanNo := DelStr(LoanNoFilter, 1, 2);
                    CurrPage.SetSelectionFilter(Rec);
                    _funderLoan.Reset();
                    _funderLoan.SetRange("No.", _loanNo);
                    if not _funderLoan.Find('-') then
                        Error('Funder Loan %1 not found', _loanNo);
                    _funderLoan."Reference Rate" := Rec."New Interest Rate";
                    // _funderLoan."Reference Rate Name" := Rec.Description;
                    _funderLoan.InterestRate := _funderLoan."Reference Rate" + _funderLoan.Margin;
                    _funderLoan.Validate(InterestRate);
                    if _funderLoan.Modify() then
                        Message('New Interest Selected');
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
    begin
        CategoryFilter := Rec.GetFilter(Category);
        GroupIDFilter := Rec.GetFilter("Inter. Rate Group");
        GroupNameFilter := Rec.GetFilter("Inter. Rate Group Name");
        LoanNoFilter := Rec.GetFilter("Loan No.");

        // CategoryFilter := Rec.GetFilter(Category);
        // Log all applied filters to the debug console
        // Rec.FilterGroup(4); // Get system filters
        // if Rec.GetFilters <> '' then
        //     Message('Initial filters applied: %1',);
        // Rec.FilterGroup(0); // Reset to default filter group
        // Message('Initial filters applied: %1');
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean

    begin

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if CategoryFilter = 'Individual' then
            Rec.Category := Rec.Category::Individual;
        if CategoryFilter = 'Bank Loan' then
            Rec.Category := Rec.Category::"Bank Loan";
        if CategoryFilter = 'Corporate' then
            Rec.Category := Rec.Category::Corporate;
        if CategoryFilter = 'Institutional' then
            Rec.Category := Rec.Category::Institutional;
        if CategoryFilter = 'Joint Application' then
            Rec.Category := Rec.Category::"Joint Application";
        if CategoryFilter = 'Bank Overdraft' then
            Rec.Category := Rec.Category::"Bank Overdraft";
        // if CategoryFilter = 'Individual' then
        //     Rec.Category := Rec.Category::Individual
        Rec."Inter. Rate Group" := GroupIDFilter;
        Rec."Inter. Rate Group Name" := GroupNameFilter;
    end;



    var
        CategoryFilter: Text;
        GroupIDFilter: Code[20];
        LoanNoFilter: Code[20];
        GroupNameFilter: Code[50];


}