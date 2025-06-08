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
                field(RelatedPartyPortfolioNo; Rec.RelatedPartyPortfolioNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = RelatedPartyPortfolioView;
                }
                field(FunderNo; Rec.FunderNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FunderView;
                }
                field(RelatedPartyNo; Rec.RelatedPartyNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = RelatedPartyView;
                }

                field(Applicable; Rec.Applicable)
                {
                    ApplicationArea = All;
                    Visible = LoanView or RelatedPartyLoanView;
                }
                field(FunderLoanNo; Rec.FunderLoanNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = LoanView;
                }

                field(RelatedPartyLoanNo; Rec.RelatedPartyLoanNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = RelatedPartyLoanView;
                }

                field("G/L"; Rec."G/L")
                {
                    ApplicationArea = All;
                    Visible = TranchView;
                }
                field("Is G/L Enabled"; Rec."Is G/L Enabled")
                {
                    ApplicationArea = All;
                    Visible = TranchView;
                    trigger OnValidate()
                    var
                        _counter: Integer;
                    begin
                        // CurrPage.Update();
                        "Disbur Tranched Entry".Reset();
                        if "Disbur Tranched Entry".FindLast() then
                            _counter := "Disbur Tranched Entry".Line
                        else
                            _counter := 0;

                        if Rec."Is G/L Enabled" = true then begin
                            if Rec."G/L" = '' then
                                exit;

                            DisburTranchedLoan.Reset();
                            DisburTranchedLoan.SetRange(LineNo, TranchedNoInt);
                            if DisburTranchedLoan.Find('-') then begin
                                "Disbur Tranched Entry".Line := _counter + 1;
                                "Disbur Tranched Entry".GLAccount := Rec."G/L";
                                "Disbur Tranched Entry".TranchedAmount := DisburTranchedLoan."Tranche Amount";
                                "Disbur Tranched Entry".BankAccount := DisburTranchedLoan."Bank Account";
                                "Disbur Tranched Entry".BankRefNo := DisburTranchedLoan."Bank Reference No";
                                "Disbur Tranched Entry"."Fee %" := Rec."Fee Percentage";
                                "Disbur Tranched Entry".LoanNo := DisburTranchedLoan."Loan No.";
                                "Disbur Tranched Entry".DisbursedTrachNo := TranchedNoInt;
                                "Disbur Tranched Entry".PortfolioRecLineNo := Rec.LineNo;
                                "Disbur Tranched Entry".Insert();

                            end;


                        end else begin
                            "Disbur Tranched Entry".Reset();
                            "Disbur Tranched Entry".SetRange(PortfolioRecLineNo, Rec.LineNo);
                            "Disbur Tranched Entry".SetRange("Disbur Tranched Entry".utilized, false);// Extra , ensure only the non utized are deleted
                            if "Disbur Tranched Entry".FindSet() then
                                "Disbur Tranched Entry".DeleteAll();
                        end;

                    end;

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

    // trigger OnInit()
    // begin
    //     PortfolioNo := GFilter.GetGlobalPortfolioFilter();
    //     if PortfolioNo <> '' then begin
    //         PortfolioTbl.Reset();
    //         PortfolioTbl.SetRange("No.", PortfolioNo);
    //         if PortfolioTbl.Find('-') then begin
    //             if PortfolioTbl.Category = PortfolioTbl.Category::" " then begin
    //                 Error('Select Category First');
    //                 exit;
    //             end;
    //             if PortfolioTbl.Category = PortfolioTbl.Category::"Bank Loan" then
    //                 Rec.Category := Rec.Category::"Bank Loan";
    //             if PortfolioTbl.Category = PortfolioTbl.Category::Individual then
    //                 Rec.Category := Rec.Category::Individual;
    //             if PortfolioTbl.Category = PortfolioTbl.Category::Institutional then
    //                 Rec.Category := Rec.Category::Institutional;
    //             if PortfolioTbl.Category = PortfolioTbl.Category::"Asset Term Manager" then
    //                 Rec.Category := Rec.Category::"Asset Term Manager";
    //             if PortfolioTbl.Category = PortfolioTbl.Category::"Medium Term Notes" then
    //                 Rec.Category := Rec.Category::"Medium Term Notes";
    //             Rec.PortfolioNo := PortfolioTbl."No.";
    //         end;
    //     end;

    //     LoanNo := GFilter.GetGlobalLoanFilter();
    //     if LoanNo <> '' then begin
    //         LoanTbl.Reset();
    //         LoanTbl.SetRange("No.", LoanNo);
    //         if LoanTbl.Find('-') then begin
    //             if LoanTbl.Category = '' then begin
    //                 Error('Select Category First');
    //                 exit;
    //             end;
    //             if LoanTbl.Category = 'Bank Loan' then
    //                 Rec.Category := Rec.Category::"Bank Loan";
    //             if LoanTbl.Category = 'Individual' then
    //                 Rec.Category := Rec.Category::Individual;
    //             if LoanTbl.Category = 'Institutional' then
    //                 Rec.Category := Rec.Category::Institutional;
    //             if LoanTbl.Category = 'Asset Term Manager' then
    //                 Rec.Category := Rec.Category::"Asset Term Manager";
    //             if LoanTbl.Category = 'Medium Term Notes' then
    //                 Rec.Category := Rec.Category::"Medium Term Notes";
    //             Rec.FunderLoanNo := LoanTbl."No.";
    //         end;
    //     end;

    //     FunderNo := GFilter.GetGlobalFilter();
    //     if FunderNo <> '' then begin
    //         FunderTbl.Reset();
    //         FunderTbl.SetRange("No.", FunderNo);
    //         if FunderTbl.Find('-') then begin
    //             if FunderTbl.Portfolio = '' then begin
    //                 Error('Select Portfolio First');
    //                 exit;
    //             end;
    //             // if FunderTbl.Category = 'Bank Loan' then
    //             //     Rec.Category := Rec.Category::"Bank Loan";
    //             // if FunderTbl.Category = 'Individual' then
    //             //     Rec.Category := Rec.Category::Individual;
    //             // if FunderTbl.Category = 'Institutional' then
    //             //     Rec.Category := Rec.Category::Institutional;
    //             // if FunderTbl.Category = 'Asset Term Manager' then
    //             //     Rec.Category := Rec.Category::"Asset Term Manager";
    //             // if FunderTbl.Category = 'Medium Term Notes' then
    //             //     Rec.Category := Rec.Category::"Medium Term Notes";
    //             Rec.FunderNo := FunderTbl."No.";
    //         end;
    //     end;
    // end;

    trigger OnOpenPage()
    var
        CurrentFilters: Text;
    begin
        CurrentFilters := Rec.GetFilters();

        PortfolioNo := Rec.GetFilter(PortfolioNo);
        FunderNo := Rec.GetFilter(FunderNo);
        LoanNo := Rec.GetFilter(FunderLoanNo);
        TranchedNoTxt := Rec.GetFilter("Disbur. Tranched No.");
        RelatedPartyNo := Rec.GetFilter(RelatedPartyNo);
        RelatedPartyLoanNo := Rec.GetFilter(RelatedPartyLoanNo);
        RelatedPartyPortfolioNo := Rec.GetFilter(RelatedPartyPortfolioNo);

        PortfolioView := false;
        FunderView := false;
        LoanView := false;
        TranchView := false;
        RelatedPartyView := false;
        RelatedPartyPortfolioView := false;
        RelatedPartyLoanView := false;

        // PortfolioNo := GFilter.GetGlobalPortfolioFilter();
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

        if RelatedPartyPortfolioNo <> '' then begin
            PortfolioRelatedTbl.Reset();
            PortfolioRelatedTbl.SetRange("No.", RelatedPartyPortfolioNo);
            if PortfolioRelatedTbl.Find('-') then begin
                Rec.Reset();
                Rec.SetRange(Rec.RelatedPartyPortfolioNo, RelatedPartyPortfolioNo);
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Bank Loan" then
                    Rec.SetRange(Rec.Category, Rec.Category::"Bank Loan");
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::Individual then
                    Rec.SetRange(Rec.Category, Rec.Category::Individual);
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::Institutional then
                    Rec.SetRange(Rec.Category, Rec.Category::Institutional);
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Asset Term Manager" then
                    Rec.SetRange(Rec.Category, Rec.Category::"Asset Term Manager");
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Medium Term Notes" then
                    Rec.SetRange(Rec.Category, Rec.Category::"Medium Term Notes");
            end;
            RelatedPartyPortfolioView := true;
        end;


        // FunderNo := GFilter.GetGlobalFilter();
        if FunderNo <> '' then begin
            FunderTbl.Reset();
            FunderTbl.SetRange("No.", FunderNo);
            if FunderTbl.Find('-') then begin
                Rec.Reset();
                Rec.SetRange(PortfolioNo, FunderTbl.Portfolio);
                // if FunderTbl.Category = FunderTbl.Category::"Bank Loan" then
                //     Rec.SetRange(Rec.Category, Rec.Category::"Bank Loan");
                // if FunderTbl.Category = FunderTbl.Category::Individual then
                //     Rec.SetRange(Rec.Category, Rec.Category::Individual);
                // if FunderTbl.Category = FunderTbl.Category::Institutional then
                //     Rec.SetRange(Rec.Category, Rec.Category::Institutional);
                // if FunderTbl.Category = FunderTbl.Category::"Asset Term Manager" then
                //     Rec.SetRange(Rec.Category, Rec.Category::"Asset Term Manager");
                // if FunderTbl.Category = FunderTbl.Category::"Medium Term Notes" then
                //     Rec.SetRange(Rec.Category, Rec.Category::"Medium Term Notes");
            end;
            FunderView := true;
        end;

        if RelatedPartyNo <> '' then begin
            RelatedPartyTbl.Reset();
            RelatedPartyTbl.SetRange("No.", RelatedPartyNo);
            if RelatedPartyTbl.Find('-') then begin
                Rec.Reset();
                Rec.SetRange(Rec.RelatedPartyPortfolioNo, RelatedPartyTbl.Portfolio);
                Rec.SetRange(Rec."Origin Entry", Rec."Origin Entry"::RelatedParty);
            end;
            RelatedPartyView := true;
        end;

        if (LoanNo <> '') and (TranchedNoTxt = '') then begin
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


        if (RelatedPartyLoanNo <> '') and (TranchedNoTxt = '') then begin
            RelatedPartyLoanTbl.Reset();
            RelatedPartyLoanTbl.SetRange("No.", RelatedPartyLoanNo);
            if RelatedPartyLoanTbl.Find('-') then begin
                Rec.Reset();
                // Rec.SetRange(Rec.RelatedPartyLoanNo, RelatedPartyLoanNo);
                if RelatedPartyLoanTbl.Category = 'BANK LOAN' then
                    Rec.SetRange(Rec.Category, Rec.Category::"Bank Loan");
                if RelatedPartyLoanTbl.Category = UpperCase('Individual') then
                    Rec.SetRange(Rec.Category, Rec.Category::Individual);
                if RelatedPartyLoanTbl.Category = UpperCase('Institutional') then
                    Rec.SetRange(Rec.Category, Rec.Category::Institutional);
                if RelatedPartyLoanTbl.Category = UpperCase('Asset Term Manager') then
                    Rec.SetRange(Rec.Category, Rec.Category::"Asset Term Manager");
                if RelatedPartyLoanTbl.Category = UpperCase('Medium Term Notes') then
                    Rec.SetRange(Rec.Category, Rec.Category::"Medium Term Notes");
                Rec.SetRange(Rec."Origin Entry", Rec."Origin Entry"::RelatedParty);
            end;
            RelatedPartyLoanView := true;
        end;


        // LoanNo := GFilter.GetGlobalLoanFilter();


        if (LoanNo <> '') and (TranchedNoTxt <> '') then begin
            if not Evaluate(TranchedNoInt, TranchedNoTxt) then
                Error('Conversion failed for value: %1 under Tranch Portfolio Fee setup', TranchedNoTxt);


            LoanTbl.Reset();
            LoanTbl.SetRange("No.", LoanNo);
            if LoanTbl.Find('-') then begin
                Rec.Reset();
                // Rec.SetRange(Rec."Disbur. Tranched No.", TranchedNoInt);
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
            TranchView := true;
        end;

        if (RelatedPartyLoanNo <> '') and (TranchedNoTxt <> '') then begin
            if not Evaluate(TranchedNoInt, TranchedNoTxt) then
                Error('Conversion failed for value: %1 under Tranch Portfolio Fee setup', TranchedNoTxt);


            RelatedPartyLoanTbl.Reset();
            RelatedPartyLoanTbl.SetRange("No.", RelatedPartyLoanNo);
            if RelatedPartyLoanTbl.Find('-') then begin
                Rec.Reset();
                // Rec.SetRange(Rec."Disbur. Tranched No.", TranchedNoInt);
                if RelatedPartyLoanTbl.Category = 'BANK LOAN' then
                    Rec.SetRange(Rec.Category, Rec.Category::"Bank Loan");
                if RelatedPartyLoanTbl.Category = UpperCase('Individual') then
                    Rec.SetRange(Rec.Category, Rec.Category::Individual);
                if RelatedPartyLoanTbl.Category = UpperCase('Institutional') then
                    Rec.SetRange(Rec.Category, Rec.Category::Institutional);
                if RelatedPartyLoanTbl.Category = UpperCase('Asset Term Manager') then
                    Rec.SetRange(Rec.Category, Rec.Category::"Asset Term Manager");
                if RelatedPartyLoanTbl.Category = UpperCase('Medium Term Notes') then
                    Rec.SetRange(Rec.Category, Rec.Category::"Medium Term Notes");
            end;
            TranchView := true;
        end;

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin
        // PortfolioNo := GFilter.GetGlobalPortfolioFilter();
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
                Rec."Origin Entry" := Rec."Origin Entry"::Funder;

            end
        end;

        if RelatedPartyPortfolioNo <> '' then begin
            PortfolioRelatedTbl.Reset();
            PortfolioRelatedTbl.SetRange("No.", RelatedPartyPortfolioNo);
            if PortfolioRelatedTbl.Find('-') then begin
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Bank Loan" then
                    Rec.Category := Rec.Category::"Bank Loan";
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::Individual then
                    Rec.Category := Rec.Category::Individual;
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::Institutional then
                    Rec.Category := Rec.Category::Institutional;
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Asset Term Manager" then
                    Rec.Category := Rec.Category::"Asset Term Manager";
                if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Medium Term Notes" then
                    Rec.Category := Rec.Category::"Medium Term Notes";
                Rec.RelatedPartyPortfolioNo := PortfolioRelatedTbl."No.";
                Rec."Origin Entry" := Rec."Origin Entry"::RelatedParty;
            end
        end;


        // FunderNo := GFilter.GetGlobalFilter();
        if FunderNo <> '' then begin
            FunderTbl.Reset();
            FunderTbl.SetRange("No.", FunderNo);
            if FunderTbl.Find('-') then begin
                PortfolioTbl.Reset();
                PortfolioTbl.SetRange("No.", FunderTbl.Portfolio);
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

                end;
                Rec.FunderNo := FunderNo;
                Rec."Origin Entry" := Rec."Origin Entry"::Funder;
            end;
        end;

        if RelatedPartyNo <> '' then begin
            RelatedPartyTbl.Reset();
            RelatedPartyTbl.SetRange("No.", RelatedPartyNo);
            if RelatedPartyTbl.Find('-') then begin
                PortfolioRelatedTbl.Reset();
                PortfolioRelatedTbl.SetRange("No.", RelatedPartyTbl.Portfolio);
                if PortfolioRelatedTbl.Find('-') then begin
                    if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Bank Loan" then
                        Rec.Category := Rec.Category::"Bank Loan";
                    if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::Individual then
                        Rec.Category := Rec.Category::Individual;
                    if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::Institutional then
                        Rec.Category := Rec.Category::Institutional;
                    if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Asset Term Manager" then
                        Rec.Category := Rec.Category::"Asset Term Manager";
                    if PortfolioRelatedTbl.Category = PortfolioRelatedTbl.Category::"Medium Term Notes" then
                        Rec.Category := Rec.Category::"Medium Term Notes";
                    Rec.RelatedPartyPortfolioNo := PortfolioRelatedTbl."No.";

                end;
                Rec.RelatedPartyNo := RelatedPartyNo;
                Rec."Origin Entry" := Rec."Origin Entry"::RelatedParty;
            end;
        end;



        // LoanNo := GFilter.GetGlobalLoanFilter();
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
                Rec."Origin Entry" := Rec."Origin Entry"::Funder;
            end
        end;

        if RelatedPartyLoanNo <> '' then begin
            RelatedPartyLoanTbl.Reset();
            RelatedPartyLoanTbl.SetRange("No.", RelatedPartyLoanNo);
            if RelatedPartyLoanTbl.Find('-') then begin
                if RelatedPartyLoanTbl.Category = UpperCase('Bank Loan') then
                    Rec.Category := Rec.Category::"Bank Loan";
                if RelatedPartyLoanTbl.Category = UpperCase('Individual') then
                    Rec.Category := Rec.Category::Individual;
                if RelatedPartyLoanTbl.Category = UpperCase('Institutional') then
                    Rec.Category := Rec.Category::Institutional;
                if RelatedPartyLoanTbl.Category = UpperCase('Asset Term Manager') then
                    Rec.Category := Rec.Category::"Asset Term Manager";
                if RelatedPartyLoanTbl.Category = UpperCase('Medium Term Notes') then
                    Rec.Category := Rec.Category::"Medium Term Notes";
                Rec.RelatedPartyLoanNo := RelatedPartyLoanTbl."No.";
                Rec."Origin Entry" := Rec."Origin Entry"::RelatedParty;
            end
        end;


    end;

    var
        GFilter: Codeunit GlobalFilters;
        PortfolioNo: Code[20];
        LoanNo: Code[20];
        FunderNo: Code[20];
        RelatedPartyPortfolioNo: Code[20];
        RelatedPartyNo: Code[20];
        RelatedPartyLoanNo: Code[20];
        TranchedNoTxt: Text[10];
        TranchedNoInt: Integer;
        PortfolioTbl: Record Portfolio;
        PortfolioRelatedTbl: Record "Portfolio RelatedParty";
        LoanTbl: Record "Funder Loan";
        // RelatedPartyLoanTbl: Record "Funder Loan";
        FunderTbl: Record Funders;
        RelatedPartyTbl: Record RelatedParty;
        RelatedPartyLoanTbl: Record "RelatedParty Loan";
        "Disbur Tranched Entry": Record "Disbur. Tranched Entry";
        DisburTranchedLoan: Record "Disbur. Tranched Loan";
        PortfolioView, FunderView, LoanView, TranchView, RelatedPartyView, RelatedPartyPortfolioView, RelatedPartyLoanView : boolean;

}