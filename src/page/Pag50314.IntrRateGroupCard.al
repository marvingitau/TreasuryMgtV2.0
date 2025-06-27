page 50314 "Intr. Rate Group Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "Intr. Rate Change Group";
    Caption = 'Interest Rate Group List';
    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
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
            action("Interest Reference")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reference Interest Rates';
                Image = OverdueEntries;
                PromotedCategory = Process;
                Promoted = true;
                trigger OnAction()
                var
                    _refPage: Page "Intr. Rate Change";
                    _refTble: Record "Interest Rate Change";
                begin
                    _refTble.Reset();
                    if Rec.Category = Rec.Category::"Bank Loan" then
                        _refTble.SetRange(_refTble.Category, _refTble.Category::"Bank Loan");
                    if Rec.Category = Rec.Category::Corporate then
                        _refTble.SetRange(_refTble.Category, _refTble.Category::Corporate);
                    if Rec.Category = Rec.Category::Individual then
                        _refTble.SetRange(_refTble.Category, _refTble.Category::Individual);
                    if Rec.Category = Rec.Category::Institutional then
                        _refTble.SetRange(_refTble.Category, _refTble.Category::Institutional);
                    if Rec.Category = Rec.Category::"Joint Application" then
                        _refTble.SetRange(_refTble.Category, _refTble.Category::"Joint Application");
                    if Rec.Category = Rec.Category::"Bank Overdraft" then
                        _refTble.SetRange(_refTble.Category, _refTble.Category::"Bank Overdraft");
                    _refTble.SetRange("Inter. Rate Group", Rec."No.");
                    _refTble.SetRange("Inter. Rate Group Name", Rec.Description);
                    // if _refTble.Find('-') then begin
                    _refPage.SetTableView(_refTble);
                    _refPage.Run();
                    // end;
                end;
            }

        }
    }

    trigger OnOpenPage()
    var
    begin
        // CategoryFilter := Rec.GetFilter(Category);
        CategoryFilter := Rec.GetFilters;
        // Log all applied filters to the debug console
        // Rec.FilterGroup(4); // Get system filters
        // if Rec.GetFilters <> '' then
        //     Message('Initial filters applied: %1',);
        // Rec.FilterGroup(0); // Reset to default filter group
        // Message('Initial filters applied: %1', Filters);
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

    end;



    var
        CategoryFilter: Text;


}