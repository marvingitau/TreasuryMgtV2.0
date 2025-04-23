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

    procedure SetGlobalLoanFilter(NewFilterValue: Text[30])
    begin
        FunderLoanGlobalFilterValue := NewFilterValue;
    end;

    procedure GetGlobalFilter(): Text[30]
    begin
        exit(FunderGlobalFilterValue);
    end;

    procedure GetGlobalLoanFilter(): Text[30]
    begin
        exit(FunderLoanGlobalFilterValue);
    end;

    var
        FunderGlobalFilterValue: Text[30];
        FunderLoanGlobalFilterValue: Text[30];
}