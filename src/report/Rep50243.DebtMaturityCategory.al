report 50243 "Debt Maturity Category"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("Debt Computation"; "Debt Computation")
        {
            column(Category; Category)
            {

            }
            column(Q1Cy; Q1Cy)
            {

            }
            column(Q2Cy; Q2Cy)
            {

            }
            column(Q3Cy; Q3Cy)
            {

            }
            column(Q4Cy; Q4Cy)
            {

            }
            column(Q1Ny; Q1Ny)
            {

            }
            column(Q2Ny; Q2Ny)
            {

            }
            column(TotalRow; SumRow)
            {

            }



            dataitem(Integer; Integer)
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(CurrentYear; CurrentYear) { }
                column(NextYear; NextYear) { }
            }
            // dataitem("Funder Loan"; "Funder Loan")
            // {
            //     DataItemLinkReference = "Funder Loan Category";
            //     DataItemLink = Category = field(Code);

            // }
            trigger OnPreDataItem()
            begin
            end;

            trigger OnAfterGetRecord()
            var

            begin

            end;

        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {

                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'reports/debtmaturity.rdlc';
        }
    }

    trigger OnPreReport()
    var
        CurrentYearStartDate: Date;
        CurrentYearEndDate: Date;
        NextYearStartDate: Date;
        NextYearEndDate: Date;

        _J: Integer;
    begin
        CurrentStartYear := CalcDate('-CY', Today);
        EndNextYearQuarter := CalcDate('18M', CurrentStartYear) - 1;

        "Debt Computation".Reset();
        "Debt Computation".DeleteAll();
        _J := 1;
        "Funder Loan Category".Reset();
        "Funder Loan Category".SetFilter(Code, '<>%1', '');
        if "Funder Loan Category".Find('-') then begin
            repeat
                "Funder Loan".Reset();
                "Funder Loan".SetRange(Category, "Funder Loan Category".Code);
                "Funder Loan".SetRange(MaturityDate, CurrentStartYear, EndNextYearQuarter);
                if "Funder Loan".Find('-') then begin
                    repeat
                        // Get the current year
                        CurrentYear := DATE2DMY(TODAY, 3); // Extract the year from TODAY

                        // Calculate the start and end dates of the current year
                        CurrentYearStartDate := DMY2DATE(1, 1, CurrentYear); // Start of the current year
                        CurrentYearEndDate := DMY2DATE(31, 12, CurrentYear); // End of the current year

                        // Calculate the start and end dates of the next year
                        NextYear := CurrentYear + 1;
                        NextYearStartDate := DMY2DATE(1, 1, NextYear); // Start of the next year
                        NextYearEndDate := DMY2DATE(31, 12, NextYear); // End of the next year

                        // Check if the record's date belongs to the current year
                        if ("Funder Loan".MaturityDate >= CurrentYearStartDate) and ("Funder Loan".MaturityDate <= CurrentYearEndDate) then begin
                            // The date belongs to the current year

                            if GetQuarter("Funder Loan".MaturityDate) = 1 then begin
                                Q1Cy += "Funder Loan"."Original Disbursed Amount";
                                // CurrReport.Skip();
                            end;
                            if GetQuarter("Funder Loan".MaturityDate) = 2 then begin
                                Q2Cy += "Funder Loan"."Original Disbursed Amount";
                                // CurrReport.Skip();
                            end;
                            if GetQuarter("Funder Loan".MaturityDate) = 3 then begin
                                Q3Cy += "Funder Loan"."Original Disbursed Amount";
                                // CurrReport.Skip();
                            end;
                            if GetQuarter("Funder Loan".MaturityDate) = 4 then begin
                                Q4Cy += "Funder Loan"."Original Disbursed Amount";
                                // CurrReport.Skip();
                            end;
                        end;


                        // Check if the record's date belongs to  next year
                        if ("Funder Loan".MaturityDate >= NextYearStartDate) and ("Funder Loan".MaturityDate <= NextYearEndDate) then begin
                            // The date belongs to next year
                            if GetQuarter("Funder Loan".MaturityDate) = 1 then begin
                                Q1Ny += "Funder Loan"."Original Disbursed Amount";
                                // CurrReport.Skip();
                            end;
                            if GetQuarter("Funder Loan".MaturityDate) = 2 then begin
                                Q2Ny += "Funder Loan"."Original Disbursed Amount";
                                // CurrReport.Skip();
                            end;
                            if GetQuarter("Funder Loan".MaturityDate) = 3 then begin

                            end;
                            if GetQuarter("Funder Loan".MaturityDate) = 4 then begin

                            end;
                        end;


                    until "Funder Loan".Next() = 0;
                end;
                _J := _J + 1;
                "Debt Computation".Init();
                "Debt Computation".Category := "Funder Loan Category".Code;
                "Debt Computation".Q1Cy := Q1Cy;
                "Debt Computation".Q2Cy := Q2Cy;
                "Debt Computation".Q3Cy := Q3Cy;
                "Debt Computation".Q4Cy := Q4Cy;
                "Debt Computation".Q1Ny := Q1Ny;
                "Debt Computation".Q2Ny := Q2Ny;
                "Debt Computation".SumRow := Q1Cy + Q2Cy + Q3Cy + Q4Cy + Q1Ny + Q2Ny;
                "Debt Computation".Counter := _J;
                "Debt Computation".Insert();
                Q1Cy := 0;
                Q2Cy := 0;
                Q3Cy := 0;
                Q4Cy := 0;
                Q1Ny := 0;
                Q2Ny := 0;
            until "Funder Loan Category".next() = 0;
        end;


    end;

    procedure GetQuarter(PassedDate: Date): Integer
    var
        Month: Integer;
        Quarter: Integer;
    begin
        Month := DATE2DMY(PassedDate, 2); // Extract the month from the passed date

        // Determine the quarter based on the month
        if Month in [1 .. 3] then
            Quarter := 1
        else if Month in [4 .. 6] then
            Quarter := 2
        else if Month in [7 .. 9] then
            Quarter := 3
        else
            Quarter := 4;

        exit(Quarter);
    end;

    var
        Q1Cy: Decimal;
        Q2Cy: Decimal;
        Q3Cy: Decimal;
        Q4Cy: Decimal;
        Q1Ny: Decimal; // Q1 next year
        Q2Ny: Decimal; // Q2 next year
        CurrentStartYear: Date;
        EndNextYearQuarter: Date;
        CategoryCountDown: Integer;
        "Funder Loan": Record "Funder Loan";
        "Funder Loan Category": Record "Funder Loan Category";
        CurrentYear: Integer;
        NextYear: Integer;
}