enum 50245 "Loan Approval Status"
{
    Extensible = true;

    value(0; Open)
    {
    }
    value(1; "Pending Approval")
    {
    }
    value(2; Approved)
    {
    }
    // value(3; Active)
    // {
    // }
    value(4; Rejected)
    {
        Caption = 'Rejected';
    }
}