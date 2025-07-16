page 50292 "Intr. Rate Change"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Interest Rate Change";
    Caption = 'Interest Rate Change List';
    // This will calculate interest depending on the effective date. 
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
            action(ActionName)
            {

                trigger OnAction()
                begin

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
        GroupNameFilter: Code[50];


}