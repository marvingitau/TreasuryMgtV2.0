// namespace Trsy;

permissionset 50230 Treasury
{
    Assignable = true;
    Permissions = tabledata "Funder Loan" = RIMD,
        tabledata "Funder Loan Category" = RIMD,
        tabledata FunderLedgerEntry = RIMD,
        tabledata Funders = RIMD,
        tabledata "General Setup" = RIMD,
        tabledata Portfolio = RIMD,
        tabledata "Trsy Journal" = RIMD,
        table "Funder Loan" = X,
        table "Funder Loan Category" = X,
        table FunderLedgerEntry = X,
        table Funders = X,
        table "General Setup" = X,
        table Portfolio = X,
        table "Trsy Journal" = X,
        codeunit FunderMgtCU = X,
        codeunit GlobalFilters = X,
        codeunit "Treasury Approval Mgt" = X,
        codeunit "Treasury Mgt CU" = X,
        codeunit TreasuryGeneralCU = X,
        page "Funder Card" = X,
        page "Funder List" = X,
        page "Funder Loan" = X,
        page "Funder Loan Card" = X,
        page "Funder Loan Categories" = X,
        page "Funder Loans List" = X,
        page FunderLedgerEntry = X,
        page "General Setup" = X,
        page "Portfolio List" = X,
        page "Trsy Journal" = X;
}