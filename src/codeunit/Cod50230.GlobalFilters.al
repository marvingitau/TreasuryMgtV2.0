codeunit 50230 GlobalFilters
{
    SingleInstance = true;
    trigger OnRun()
    begin

    end;

    procedure SetGlobalFilter(NewFilterValue: Text[30])
    begin
        FunderGlobalFilterValue := NewFilterValue;
    end;

    procedure GetGlobalFilter(): Text[30]
    begin
        exit(FunderGlobalFilterValue);
    end;

    var
        FunderGlobalFilterValue: Text[30];
}