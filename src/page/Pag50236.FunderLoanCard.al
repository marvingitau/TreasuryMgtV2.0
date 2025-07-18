page 50236 "Funder Loan Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Funder Loan";

    layout
    {
        area(Content)
        {

            group("General Overdraft")
            {
                Visible = isOverdraftLoan;
                field("No._OD"; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Funder No._OD"; Rec."Funder No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Name_OD; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Funder Name';
                }
                field("Portfolio No._OD"; Rec."Portfolio No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Portfolio Name_OD"; Rec."Portfolio Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                // field("Loan Name"; Rec."Loan Name")
                // {
                //     ApplicationArea = All;
                //     // ShowMandatory = true;
                //     Visible = false;
                // }
                field(PlacementDate_OD; Rec.PlacementDate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if (Rec.PlacementDate <> 0D) and (Rec.MaturityDate <> 0D) then begin
                            PlacementAndMaturityDifference := (Rec.MaturityDate - Rec.PlacementDate);


                            if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Monthly then begin
                                Rec.FirstDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                            end;
                            if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Monthly then begin
                                Rec.SecondDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                            end;

                            Message('Loan Duration is %1', Format(PlacementAndMaturityDifference));
                        end;
                    end;
                }
                field(MaturityDate_OD; Rec.MaturityDate)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if (Rec.PlacementDate <> 0D) and (Rec.MaturityDate <> 0D) then begin

                            PlacementAndMaturityDifference := (Rec.MaturityDate - Rec.PlacementDate);
                            Message('Loan Duration is %1', Format(PlacementAndMaturityDifference));
                        end;
                    end;
                }
                field(LoanDurationDays_OD; Rec.LoanDurationDays)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Loan Duration (Days)';
                }
                field(FundSource_OD; Rec.FundSource)
                {

                    ApplicationArea = All;
                    Caption = 'Receiving Bank Account';
                    Editable = EditStatus;
                }
                field(Currency_OD; Rec.Currency)
                {
                    Caption = 'Currency';
                    // Visible = false;
                    ApplicationArea = All;
                    Editable = EditStatus;
                    // Editable = false;
                    // Visible = isCurrencyVisible;
                    // ShowMandatory = isCurrencyVisible;
                    // ShowMandatory = true;
                }
                // field(CustomFX; Rec.CustomFX)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Custom Foreign Exchage';
                //     ToolTip = 'This field indicate a negotiated Foreign Exchange Amount under Treasury Currencies';
                //     // Editable = false;
                // }
                // field("Posting Group"; Rec."Posting Group")
                // {
                //     ApplicationArea = All;
                //     // Editable = false;
                // }
                field("BankRefNo_OD"; Rec."Bank Ref. No.")
                {
                    ApplicationArea = All;
                    Caption = 'Bank Reference No.';
                    Editable = EditStatus;
                    ShowMandatory = false;
                }
                // field("Coupa Ref No._OD"; Rec."Coupa Ref No.")
                // {
                //     ApplicationArea = all;
                //     Editable = EditStatus;
                // }
                field("Overdraft Limit_OD"; Rec."Overdraft Limit")
                {
                    ApplicationArea = All;
                    // Visible = isOverdraftLoan;
                    Editable = EditStatus and isOverdraftLoan;
                    // ShowMandatory = true;

                }
                group("G/L Mapping_OD")
                {
                    field("Payables Account_OD"; Rec."Payables Account")
                    {

                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Principal Account';
                    }
                    field("Interest Expense_OD"; Rec."Interest Expense")
                    {

                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Interest Payable_OD"; Rec."Interest Payable")
                    {

                        ApplicationArea = All;
                        Editable = false;
                    }
                }





                field(TaxStatus_OD; Rec.TaxStatus)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if Rec.TaxStatus = Rec.TaxStatus::"Tax Exempt" then
                            Rec.Withldtax := 0;
                    end;
                }

                field(Withldtax_OD; Rec.Withldtax)
                {
                    ApplicationArea = All;
                    Editable = EditStatus and not (Rec.TaxStatus = Rec.TaxStatus::"Tax Exempt");
                    Caption = 'Withholding tax applied (%)';
                }

                field(InterestMethod_OD; Rec.InterestMethod)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field(InterestRateType_OD; Rec.InterestRateType)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then begin
                            isFloatRate := true;
                            Rec."Reference Rate" := 0;
                            Rec.Margin := 0;
                        end else begin

                            isFloatRate := false;
                        end;
                        CurrPage.Update();
                    end;
                }
                field(InterestRate_OD; Rec.InterestRate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = (not isFloatRate);
                    Caption = 'Gross Interest rate (p.a)';
                }
                field(NetInterestRate_OD; Rec.NetInterestRate)
                {
                    ApplicationArea = All;
                    Caption = 'Net Interest Rate';
                    Editable = (not isFloatRate);
                }
                group(FloatInterestFields_OD)
                {
                    Caption = 'Float Rate Related Fields';
                    ShowCaption = true;
                    field("Reference Rate_OD"; Rec."Reference Rate")
                    {
                        ApplicationArea = All;
                        Editable = isFloatRate;

                        // trigger OnValidate()
                        // begin
                        //     Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                        //     Rec.Modify();
                        //     CurrPage.Update();
                        // end;

                        // LookupPageId = "Intr. Rate Change";
                        // trigger OnLookup(var Text: Text): Boolean
                        // var

                        // begin

                        // end;


                        DrillDownPageId = "Intr. Rate Change";
                        trigger OnDrillDown()
                        var
                            funder: Record Funders;
                            intrChange: Record "Interest Rate Change";
                        begin
                            funder.Reset();
                            funder.SetRange("No.", Rec."Funder No.");
                            if not funder.Find('-') then
                                Error('Funder %1 not found', Rec."Funder No.");

                            intrChange.Reset();
                            if funder.FunderType = funder.FunderType::"Bank Loan" then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::"Bank Loan");
                            if funder.FunderType = funder.FunderType::Corporate then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::Corporate);
                            if funder.FunderType = funder.FunderType::Individual then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::Individual);
                            if funder.FunderType = funder.FunderType::Institutional then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::Institutional);
                            if funder.FunderType = funder.FunderType::"Joint Application" then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::"Joint Application");
                            if funder.FunderType = funder.FunderType::"Bank Overdraft" then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::"Bank Overdraft");

                            if Page.RunModal(Page::"Intr. Rate Change", intrChange) = Action::LookupOK then begin
                                Rec."Reference Rate Name" := intrChange.Description;
                                Rec."Reference Rate" := intrChange."New Interest Rate";
                                Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                                Rec.Validate(InterestRate);
                                Rec."Group Reference No." := intrChange."Inter. Rate Group";
                                Rec."Group Reference Name" := intrChange."Inter. Rate Group Name";
                                CurrPage.Update();
                            end;

                        end;


                    }
                    field("Reference Rate Name_OD"; Rec."Reference Rate Name")
                    {
                        ApplicationArea = All;
                        Editable = false;



                    }
                    field(Margin_OD; Rec.Margin)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = isFloatRate;
                        trigger OnValidate()
                        begin
                            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                            Rec.Validate(InterestRate);
                            Rec.Modify();
                            CurrPage.Update();
                        end;
                    }
                }








                // field("Enable GL Posting_OD"; Rec.EnableGLPosting)
                // {
                //     ApplicationArea = All;
                //     Editable = EditStatus;
                // }



                field(Category_OD; Rec.Category)
                {
                    ApplicationArea = All;
                    Editable = false;
                }








                field(Status_OD; Rec.Status)
                {
                    ApplicationArea = All;
                    // Editable = false;
                }
                field(State_OD; Rec.State)
                {
                    ApplicationArea = All;
                    Caption = 'Operational State';
                    Editable = false;
                    // Visible = Rec.Status = Rec.Status::Approved;
                    ToolTip = 'This shows the Loan is in Operation';
                }

            }

            group(General)
            {
                Visible = not isOverdraftLoan;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Funder No."; Rec."Funder No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Funder Name';
                }
                field("Portfolio No."; Rec."Portfolio No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Portfolio Name"; Rec."Portfolio Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                // field("Loan Name"; Rec."Loan Name")
                // {
                //     ApplicationArea = All;
                //     // ShowMandatory = true;
                //     Visible = false;
                // }
                field(PlacementDate; Rec.PlacementDate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if (Rec.PlacementDate <> 0D) and (Rec.MaturityDate <> 0D) then begin
                            PlacementAndMaturityDifference := (Rec.MaturityDate - Rec.PlacementDate);


                            if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Monthly then begin
                                Rec.FirstDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                            end;
                            if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Monthly then begin
                                Rec.SecondDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                            end;

                            Message('Loan Duration is %1', Format(PlacementAndMaturityDifference));
                        end;
                    end;
                }
                field(MaturityDate; Rec.MaturityDate)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if (Rec.PlacementDate <> 0D) and (Rec.MaturityDate <> 0D) then begin

                            PlacementAndMaturityDifference := (Rec.MaturityDate - Rec.PlacementDate);
                            Message('Loan Duration is %1', Format(PlacementAndMaturityDifference));
                        end;
                    end;
                }
                field(LoanDurationDays; Rec.LoanDurationDays)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Loan Duration (Days)';
                }
                field(FundSource; Rec.FundSource)
                {

                    ApplicationArea = All;
                    Caption = 'Receiving Bank Account';
                    // Editable = false;
                    Editable = EditStatus;
                }
                field(Currency; Rec.Currency)
                {
                    Caption = 'Currency';
                    // Visible = false;
                    ApplicationArea = All;
                    Editable = EditStatus;
                    // Editable = false;
                    // Visible = isCurrencyVisible;
                    // ShowMandatory = isCurrencyVisible;
                    // ShowMandatory = true;
                }
                // field(CustomFX; Rec.CustomFX)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Custom Foreign Exchage';
                //     ToolTip = 'This field indicate a negotiated Foreign Exchange Amount under Treasury Currencies';
                //     // Editable = false;
                // }
                // field("Posting Group"; Rec."Posting Group")
                // {
                //     ApplicationArea = All;
                //     // Editable = false;
                // }
                field("Bank Ref. No."; Rec."Bank Ref. No.")
                {
                    ApplicationArea = All;
                    Caption = 'Bank Reference No.';
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field("Coupa Ref No."; Rec."Coupa Ref No.")
                {
                    ApplicationArea = all;
                    Editable = EditStatus;
                }
                field("Overdraft Limit"; Rec."Overdraft Limit")
                {
                    ApplicationArea = All;
                    // Visible = isOverdraftLoan;
                    Editable = EditStatus and isOverdraftLoan;
                    // ShowMandatory = true;

                }
                group("G/L Mapping")
                {
                    field("Payables Account"; Rec."Payables Account")
                    {

                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Principal Account';
                    }
                    field("Interest Expense"; Rec."Interest Expense")
                    {

                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Interest Payable"; Rec."Interest Payable")
                    {

                        ApplicationArea = All;
                        Editable = false;
                    }
                }

                field("Total Payed"; Rec."Total Payed")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Tranche Loan";
                    Editable = not (Rec.Status = Rec.Status::Approved);
                    ToolTip = 'This indicates the Total to Be Payed under Tranches Loan';
                    Caption = 'Total facility amount on Tranche loans';


                }
                field("Original Disbursed Amount"; Rec."Original Disbursed Amount")
                {
                    ApplicationArea = All;
                    // Editable = not (Rec.Status = Rec.Status::Approved);
                    Editable = EditStatus;
                    Caption = 'Original / First disbursement Amount';
                }
                // field(OrigAmntDisbLCY; Rec.OrigAmntDisbLCY)
                // {
                //     DrillDown = true;
                //     DrillDownPageId = FunderLedgerEntry;
                //     ApplicationArea = All;
                //     Caption = 'Original Amount Disbursed';
                // }

                field(OutstandingAmntDisbLCY; Rec.OutstandingAmntDisbLCY)
                {
                    // ApplicationArea = Basic, Suite;
                    // Importance = Promoted;
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Outstanding Amount';
                }
                field("Outstanding Interest"; Rec."Outstanding Interest")
                {
                    // ApplicationArea = Basic, Suite;
                    // Importance = Promoted;
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Outstanding Interest';
                }
                field("Withholding Tax Amount"; Rec."Withholding Tax Amount")
                {
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ApplicationArea = All;
                    Caption = 'Withholding Amount';
                }
                field(TaxStatus; Rec.TaxStatus)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if Rec.TaxStatus = Rec.TaxStatus::"Tax Exempt" then
                            Rec.Withldtax := 0;
                    end;
                }

                field(Withldtax; Rec.Withldtax)
                {
                    ApplicationArea = All;
                    Editable = EditStatus and not (Rec.TaxStatus = Rec.TaxStatus::"Tax Exempt");
                    Caption = 'Withholding tax applied (%)';
                }
                field(InterestMethod; Rec.InterestMethod)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                }
                field(InterestRateType; Rec.InterestRateType)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then begin
                            isFloatRate := true;
                            Rec."Reference Rate" := 0;
                            Rec.Margin := 0;
                        end else begin

                            isFloatRate := false;
                        end;
                        CurrPage.Update();
                    end;
                }
                field(InterestRate; Rec.InterestRate)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = EditStatus;
                    // Editable = (not isFloatRate) or EditStatus;
                    Caption = 'Gross Interest rate (p.a)';
                }
                field(NetInterestRate; Rec.NetInterestRate)
                {
                    ApplicationArea = All;
                    Caption = 'Net Interest Rate';
                    Editable = EditStatus;
                    // Editable = (not isFloatRate);
                }
                group(FloatInterestFields)
                {
                    Caption = 'Float Rate Related Fields';
                    ShowCaption = true;
                    Editable = EditStatus;
                    field("Reference Rate"; Rec."Reference Rate")
                    {
                        ApplicationArea = All;
                        Editable = isFloatRate;

                        // trigger OnValidate()
                        // begin
                        //     Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                        //     Rec.Modify();
                        //     CurrPage.Update();
                        // end;

                        // LookupPageId = "Intr. Rate Change";
                        // trigger OnLookup(var Text: Text): Boolean
                        // var

                        // begin

                        // end;


                        DrillDownPageId = "Intr. Rate Change";
                        trigger OnDrillDown()
                        var
                            funder: Record Funders;
                            intrChange: Record "Interest Rate Change";
                        begin
                            funder.Reset();
                            funder.SetRange("No.", Rec."Funder No.");
                            if not funder.Find('-') then
                                Error('Funder %1 not found', Rec."Funder No.");

                            intrChange.Reset();
                            if funder.FunderType = funder.FunderType::"Bank Loan" then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::"Bank Loan");
                            if funder.FunderType = funder.FunderType::Corporate then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::Corporate);
                            if funder.FunderType = funder.FunderType::Individual then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::Individual);
                            if funder.FunderType = funder.FunderType::Institutional then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::Institutional);
                            if funder.FunderType = funder.FunderType::"Joint Application" then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::"Joint Application");
                            if funder.FunderType = funder.FunderType::"Bank Overdraft" then
                                intrChange.SetRange(intrChange.Category, intrChange.Category::"Bank Overdraft");

                            if Page.RunModal(Page::"Intr. Rate Change", intrChange) = Action::LookupOK then begin
                                Rec."Reference Rate Name" := intrChange.Description;
                                Rec."Reference Rate" := intrChange."New Interest Rate";
                                Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                                Rec.Validate(InterestRate);
                                Rec."Group Reference No." := intrChange."Inter. Rate Group";
                                Rec."Group Reference Name" := intrChange."Inter. Rate Group Name";
                                CurrPage.Update();
                            end;

                        end;


                    }
                    field("Reference Rate Name"; Rec."Reference Rate Name")
                    {
                        ApplicationArea = All;
                        Editable = false;



                    }
                    field(Margin; Rec.Margin)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = isFloatRate;
                        trigger OnValidate()
                        begin
                            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
                            Rec.Validate(InterestRate);
                            Rec.Modify();
                            CurrPage.Update();
                        end;
                    }
                }

                // field(InterestRepaymentHz; Rec.InterestRepaymentHz)
                // {
                //     ApplicationArea = All;
                // }
                field(GrossInterestamount; Rec.GrossInterestamount)
                {
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ToolTip = '';
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Interest';
                }

                field(NetInterestamount; Rec.NetInterestamount)
                {
                    DrillDown = true;
                    DrillDownPageId = FunderLedgerEntry;
                    ToolTip = '';
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Interest';
                }
                field(PeriodicPaymentOfInterest; Rec.PeriodicPaymentOfInterest)
                {
                    Caption = '*Payment Period (Interest) ';
                    ApplicationArea = All;
                    Editable = EditStatus;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        //Check placement date for the interest amortization
                        if Rec.PlacementDate = 0D then
                            Error('Please populate Placement Date first.');
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Monthly then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                            Rec."Inclusive Counting Interest" := false;
                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Quarterly then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetQuarterClosingDate(Rec.PlacementDate);
                            Rec."Inclusive Counting Interest" := false;
                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Biannually then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetBiannualClosingDate(Rec.PlacementDate);
                            Rec."Inclusive Counting Interest" := false;
                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Annually then begin
                            Rec.FirstDueDate := TreasuryMgtCU.GetYearEndClosingDate(Rec.PlacementDate);
                            Rec."Inclusive Counting Interest" := false;
                        end;

                        UpdateInterestPaymentVisibility();

                        // CurrPage.Update();
                    end;

                }

                field(PeriodicPaymentOfPrincipal; Rec.PeriodicPaymentOfPrincipal)
                {
                    Caption = '*Payment Period (Principal) ';
                    ApplicationArea = All;
                    Editable = EditStatus;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        //Check placement date for the interest amortization
                        if Rec.PlacementDate = 0D then
                            Error('Please populate Placement Date first.');
                        if Rec.MaturityDate = 0D then
                            Error('Please populate Maturity Date first.');

                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Monthly then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Quarterly then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetQuarterClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Biannually then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetBiannualClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::Annually then begin
                            Rec.SecondDueDate := TreasuryMgtCU.GetYearEndClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.PeriodicPaymentOfPrincipal = Rec.PeriodicPaymentOfPrincipal::"Total at Due Date" then begin
                            Rec.SecondDueDate := Rec.MaturityDate;
                        end;

                    end;
                }

                field(AmortCapPaymentOfPrincipal; Rec.AmortCapPaymentOfPrincipal)
                {
                    Caption = '*Payment Period (Amortize Capitalize)';
                    ApplicationArea = All;
                    Editable = EditStatus;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        //Check placement date for the interest amortization
                        if Rec.PlacementDate = 0D then
                            Error('Please populate Placement Date first.');
                        if Rec.MaturityDate = 0D then
                            Error('Please populate Maturity Date first.');

                        if Rec.AmortCapPaymentOfPrincipal = Rec.AmortCapPaymentOfPrincipal::Monthly then begin
                            Rec.ThirdDueDate := TreasuryMgtCU.GetEndOfMonthDate(Rec.PlacementDate);
                        end;
                        if Rec.AmortCapPaymentOfPrincipal = Rec.AmortCapPaymentOfPrincipal::Quarterly then begin
                            Rec.ThirdDueDate := TreasuryMgtCU.GetQuarterClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.AmortCapPaymentOfPrincipal = Rec.AmortCapPaymentOfPrincipal::Biannually then begin
                            Rec.ThirdDueDate := TreasuryMgtCU.GetBiannualClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.AmortCapPaymentOfPrincipal = Rec.AmortCapPaymentOfPrincipal::Annually then begin
                            Rec.ThirdDueDate := TreasuryMgtCU.GetYearEndClosingDate(Rec.PlacementDate);
                        end;
                        if Rec.AmortCapPaymentOfPrincipal = Rec.AmortCapPaymentOfPrincipal::" " then begin
                            Rec.ThirdDueDate := 0D;
                        end;

                    end;
                }


                // field(InvestmentTenor; Rec.InvestmentTenor)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Investment Tenor (Months)';
                // }
                field(InvstPINNo; Rec.InvstPINNo)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field("Enable GL Posting"; Rec.EnableGLPosting)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }


                field("Tranche Loan"; Rec."Tranche Loan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Is this loan a Tranched Loan';
                    // Editable = TranchesView;
                    // Visible = TranchesView;
                    Editable = EditStatus and TranchesView;
                }

                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                // field(sTenor; Rec.StartTenor)
                // {
                //     ApplicationArea = All;
                // }
                // field(eTenor; Rec.EndTenor)
                // {
                //     ApplicationArea = All;
                // }
                field(SecurityType; Rec.SecurityType)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                    trigger OnValidate()
                    begin
                        if Rec.SecurityType = Rec.SecurityType::"Senior secured" then begin
                            isSecureLoanActive := true;
                            isUnsecureLoanActive := false;
                        end
                        else begin
                            isUnsecureLoanActive := true;
                            isSecureLoanActive := false;
                        end;
                        CurrPage.Update();
                    end;
                }
                field("Secured Loan"; Rec."Secured Loan")
                {
                    ApplicationArea = All;
                    Editable = isSecureLoanActive;

                }
                field("Secured Loan Other"; Rec."Secured Loan Other")
                {
                    ApplicationArea = All;
                    Editable = isSecureLoanActive;
                    Caption = 'Secure Loan Other Option';

                }
                field("UnSecured Loan"; Rec."UnSecured Loan")
                {
                    ApplicationArea = All;
                    Editable = EditStatus and isUnsecureLoanActive;

                }

                field(FormofSec; Rec.FormofSec)
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field(PlacementMaturity; Rec.PlacementMaturity)
                {
                    Caption = 'Placement Maturity Term';
                    ApplicationArea = All;
                    Editable = EditStatus;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    // Editable = (Rec.Status = Rec.Status::Open);
                    Editable = false;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                    Caption = 'Operational State';
                    Editable = false;
                    // Visible = Rec.Status = Rec.Status::Approved;
                    ToolTip = 'This shows the Loan is in Operation';
                }
                group("Rollover Details")
                {
                    Visible = IsRollovered;
                    Editable = EditStatus;
                    field(Rollovered; Rec.Rollovered)
                    {
                        ApplicationArea = All;
                        Caption = 'Record Origin';
                        Editable = false;
                    }
                    field("Original Record No."; Rec."Original Record No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Rollovered Interest"; Rec."Rollovered Interest")
                    {
                        ApplicationArea = All;
                        Caption = '* Rollovered Interest';
                        ToolTip = 'Applicable only for the case of Rollovered Interest';
                        Editable = false;
                    }
                    field("Rollovered Principal"; Rec."Rollovered Principal")
                    {
                        ApplicationArea = All;
                        Caption = '* Rollovered Principal';
                        ToolTip = 'Applicable only for the case of Rollovered Principal';
                        Editable = false;
                    }
                }


            }
            group("Intrest Amortization Settings") //Amortized Interest Advanced
            {
                Visible = not isOverdraftLoan;
                Editable = EditStatus;
                //     // Visible = EnableInterestPaymentVisibility;
                field(FirstDueDate; Rec.FirstDueDate)
                {
                    Caption = 'Interest Due Date';
                    ApplicationArea = All;
                    // Editable = EditStatus;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin

                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Monthly then begin
                            if TreasuryMgtCU.IsEndOfMonth(Rec.FirstDueDate) then begin
                                Rec."Inclusive Counting Interest" := false;
                            end else begin
                                Rec."Inclusive Counting Interest" := true;
                            end;

                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Quarterly then begin
                            if TreasuryMgtCU.IsEndOfQuarter(Rec.FirstDueDate) then begin
                                Rec."Inclusive Counting Interest" := false;
                            end else begin
                                Rec."Inclusive Counting Interest" := true;
                            end;

                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Biannually then begin
                            if TreasuryMgtCU.IsEndOfBiannual(Rec.FirstDueDate) then begin
                                Rec."Inclusive Counting Interest" := false;
                            end else begin
                                Rec."Inclusive Counting Interest" := true;
                            end;

                        end;
                        if Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Annually then begin
                            if TreasuryMgtCU.IsEndOfYear(Rec.FirstDueDate) then begin
                                Rec."Inclusive Counting Interest" := false;
                            end else begin
                                Rec."Inclusive Counting Interest" := true;
                            end;
                        end;
                    end;

                }

                field("Enable Dynamic Period"; Rec.EnableDynamicPeriod)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }
                field("Enable WeekDay Reporting"; Rec.EnableWeekDayReporting)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }

                field("Inclusive Counting Interest"; Rec."Inclusive Counting Interest")
                {
                    Caption = 'Inclusive counting';
                    ToolTip = 'Including both start and end dates';
                    ApplicationArea = All;
                    Visible = false;


                }
            }

            group("Payment Amortization Settings") //Amortized Interest Advanced
            {
                Visible = not isOverdraftLoan;
                Editable = EditStatus;
                //     // Visible = EnableInterestPaymentVisibility;
                // field(FirstDueDate; Rec.FirstDueDate)
                // {
                //     Caption = 'Interest Due Date';
                //     ApplicationArea = All;
                //     Editable = EditStatus;
                //     ShowMandatory = true;

                // }
                field(SecondDueDate; Rec.SecondDueDate)
                {
                    Caption = 'Principal Payment Due Date';
                    ApplicationArea = All;
                    // Editable = EditStatus;
                    ShowMandatory = true;

                }

                field("Enable Dynamic Period P"; Rec.EnableDynamicPeriod_Payment)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }
                field("Enable WeekDay Reporting P"; Rec.EnableWeekDayReporting_Payment)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }
                // field("Add Day to End Period"; Rec."Add Day to Start Period")
                // {
                //     Caption = 'Add One (1) day to Start Date';
                //     ApplicationArea = All;
                //     // Editable = EditStatus;


                // }

            }
            group("Amortized Capitalize Settings") //Amortized Interest Advanced
            {
                Visible = not (Rec.AmortCapPaymentOfPrincipal = Rec.AmortCapPaymentOfPrincipal::" ");
                Editable = EditStatus;
                field(ThirdDueDate; Rec.ThirdDueDate)
                {
                    Caption = 'Capitalized Payment Due Date';
                    ApplicationArea = All;
                    // Editable = EditStatus;
                    ShowMandatory = true;

                }

                field("Enable Dynamic Period Amot"; Rec.EnableDynamicPeriod_AmortCap)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }
                field("Enable WeekDay Reporting Amot"; Rec.EnableWeekDayRep_AmortCap)
                {
                    ApplicationArea = All;
                    // Editable = EditStatus;
                }


            }

            group(Encumbrance)
            {
                Visible = EncumberanceView and not isOverdraftLoan;
                //  Visible = not isOverdraftLoan;

                field("Encumbrance Percentage"; Rec."Encumbrance Percentage")
                {
                    ApplicationArea = All;
                    Editable = EditStatus;
                }

                field("Encumbrance Input"; Rec."Encumbrance Input")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                // field("Total Asset Value"; Rec."Total Asset Value")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }

            }
            group("Loan Repayment")
            {
                Visible = LoanRepaymentView;
                Editable = EditStatus;
                field("Repayment Frequency"; Rec."Repayment Frequency")
                {
                    ApplicationArea = All;
                }
                field("Repayment Amount"; Rec."Repayment Amount")
                {
                    ApplicationArea = All;
                }
                // field("Repayment interest"; Rec."Repayment interest")
                // {
                //     ApplicationArea = All;
                // }
            }

        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50232),
                              "No." = FIELD("No.");
            }
            // systempart(FunderLinks; Links)
            // {
            //     ApplicationArea = RecordLinks;
            // }
            // systempart(FunderNotes; Notes)
            // {
            //     ApplicationArea = Notes;
            // }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Process Funder Loan")
            {
                Caption = 'Process Funder Loan';
                Image = Interaction;
                action("Funder Ledger Entry")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Funder Ledger';
                    Image = LedgerEntries;
                    PromotedCategory = Process;
                    Promoted = true;
                    // RunObject = Page "Funder Loans List";
                    //RunPageLink = "Funder No." = FIELD("No.");
                    trigger OnAction()
                    var
                        funderLedgerEntry: Record FunderLedgerEntry;
                    begin
                        funderLedgerEntry.SETRANGE(funderLedgerEntry."Loan No.", Rec."No.");
                        funderLedgerEntry.SetFilter(funderLedgerEntry."Document Type", '<>%1', funderLedgerEntry."Document Type"::"Remaining Amount");
                        PAGE.RUN(PAGE::FunderLedgerEntry, funderLedgerEntry);

                    end;
                }

                action("Compute Interest")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Interaction;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Compute Interest';
                    ToolTip = 'Compute Interest ';
                    trigger OnAction()
                    var
                        funderMgt: Codeunit FunderMgtCU;
                    begin
                        funderMgt.CalculateInterest(Rec."No.");
                    end;
                }
                action("Rollover Record")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Interaction;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Rollover Record';
                    ToolTip = 'Rollover Record';
                    trigger OnAction()
                    var
                        funderMgt: Codeunit FunderMgtCU;
                        RO: Page "Roll over";
                        GFilter: Codeunit GlobalFilters;
                        ROTbl: Record "Roll over Tbl";
                    begin
                        // funderMgt.DuplicateRecord(Rec."No.");
                        //Page.Run(Page::"Roll over", Rec);
                        // ROTbl.Reset();
                        // ROTbl.DeleteAll();
                        GFilter.SetGlobalLoanFilter(Rec."No.");
                        RO.Run();
                    end;
                }
                action("Redemption Record")
                {
                    ApplicationArea = Basic, Suite;
                    Image = RefreshDiscount;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Redemption Record';
                    ToolTip = 'Redemption Record';
                    trigger OnAction()
                    var
                        funderMgt: Codeunit FunderMgtCU;
                        RD: Page Redemption;
                        GFilter: Codeunit GlobalFilters;
                        RDTbl: Record "Redemption Tbl";
                    begin
                        // funderMgt.DuplicateRecord(Rec."No.");
                        //Page.Run(Page::"Roll over", Rec);
                        RDTbl.Reset();
                        RDTbl.DeleteAll();

                        GFilter.SetGlobalLoanFilter(Rec."No.");
                        RD.Run();
                    end;
                }

                action("Loan Tranche")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Trace;
                    PromotedIsBig = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    Caption = 'Loan Tranche';
                    ToolTip = 'Loan Tranche';
                    Enabled = Rec."Tranche Loan" = true;
                    Visible = TranchesView;

                    trigger OnAction()
                    var
                        tranchLoan: Record "Disbur. Tranched Loan";
                        GFilter: Codeunit GlobalFilters;
                    begin
                        GFilter.SetGlobalLoanFilter(Rec."No.");
                        tranchLoan.SETRANGE(tranchLoan."Loan No.", Rec."No.");
                        // tranchLoan.SetFilter(tranchLoan."Document Type", '<>%1', tranchLoan."Document Type"::"Remaining Amount");
                        PAGE.RUN(PAGE::"Disbur. Tranched Loan", tranchLoan);

                    end;
                }

                action("Portfolio Fee Setup")
                {
                    Caption = 'Applicable Fee';
                    Image = InsertStartingFee;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    // RunObject = page "Portfolio Fee Setup";
                    trigger OnAction()
                    var
                        _portfolio: page "Portfolio Fee Setup";
                        GFilter: Codeunit GlobalFilters;
                        _portfolioFeeTbl: Record "Portfolio Fee Setup";
                    begin
                        // // Page.Run(Page::"Portfolio Fee Setup", Rec, Rec."No.");
                        // GFilter.SetGlobalLoanFilter(Rec."No.");
                        // _portfolio.Run();
                        // // _portfolio.SetTableView(Rec);
                        // // _portfolio.run()

                        _portfolioFeeTbl.Reset();
                        _portfolioFeeTbl.SetRange(_portfolioFeeTbl.FunderLoanNo, Rec."No.");
                        Page.Run(Page::"Portfolio Fee Setup", _portfolioFeeTbl);
                    end;
                }

            }

            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval to change the record.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()

                    var
                        CustomWorkflowMgmt: Codeunit "Treasury Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        //Validate Key Fields
                        // Interest Value, Method and Principal

                        if (Rec.Category <> UpperCase('Bank Overdraft')) then begin //and (Rec.Category <> UpperCase('INSTITUTIONAL'))
                            if Rec."Original Disbursed Amount" = 0 then
                                Error('Original Disbursed Amount Required');
                            // if Rec.InterestRate = 0 then
                            //     Error('Gross Interest rate (p.a) Required');
                        end else begin
                            if Rec."Overdraft Limit" = 0 then
                                Error('Overdraft Limit Required');
                        end;


                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Treasury Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        CustomWorkflowMgmt.OnCancelWorkflowForApproval(RecRef);
                    end;
                }
                action(SendReopenApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send Reopen A&pproval Request';
                    Enabled = Rec.Status = Rec.Status::Approved;
                    Image = UnApply;
                    ToolTip = 'Request Reopen approval to change the record.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()

                    var
                        CustomWorkflowMgmt: Codeunit "Treasury Approval Mgt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
                    end;
                }
            }

            group(Communication)
            {
                Caption = 'Communications';
                Image = MapSetup;
                action("Email Send Confirmation")
                {
                    Image = Confirm;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        EmailingCU.SendConfirmationEmailWithAttachment(Rec."No.")
                    end;
                }
                action("Reminder On Placement Maturity")
                {
                    Image = Reminder;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        PlacementReminder: Report "Reminder on Placement Mature";
                        _funderLoan: Record "Funder Loan";
                        EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        //PlacementReminder.Run();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Reminder on Placement Mature", true, false, _funderLoan);
                        // EmailingCU.SendReminderOnPlacementMaturity(Rec."No.")
                    end;
                }
                action("Reminder On Instrest Due")
                {
                    Image = Intercompany;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    trigger OnAction()
                    var
                        EmailingCU: Codeunit "Treasury Emailing";
                    begin
                        EmailingCU.SendReminderOnInterestDue(Rec."No.")
                    end;
                }
                action("Update Loan Data")
                {
                    Image = Intercompany;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = report "Update Loan Data";

                }
            }
            // "Update Loan Data"
            group(OverdraftActions)
            {
                action("Overdraft Ledger Entry")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Overdraft Ledger';
                    Image = Entries;
                    PromotedCategory = Process;
                    Promoted = true;
                    Enabled = isOverdraftLoan;
                    Visible = isOverdraftLoan;
                    trigger OnAction()
                    var
                        overdraftLedgerEntry: Record "Overdraft Ledger Entries";
                    begin
                        overdraftLedgerEntry.SETRANGE(overdraftLedgerEntry."Loan No.", Rec."No.");
                        PAGE.RUN(PAGE::"Overdraft Ledger Entries", overdraftLedgerEntry);
                    end;
                }
                action("Overdraft Check Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Overdraft Check Report';
                    Image = OverdueEntries;
                    PromotedCategory = Process;
                    Promoted = true;
                    Enabled = isOverdraftLoan;
                    Visible = isOverdraftLoan;
                    RunObject = report "Overdraft Check Report";

                }
                // action("Overdraft Int. Post. Rep.")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Overdraft Interest Post';
                //     Image = PostedMemo;
                //     PromotedCategory = Process;
                //     Promoted = true;
                //     Enabled = isOverdraftLoan;
                //     Visible = isOverdraftLoan;
                //     RunObject = report "Overdraft Interest Posting";

                // }
            }
            group(InterestRates)
            {
                // "Intr. Rate Change"
                action("Interest Rates")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reference Interest Rates';
                    Image = OverdueEntries;
                    PromotedCategory = Process;
                    Promoted = true;
                    // Enabled = isOverdraftLoan;
                    // Visible = isOverdraftLoan;
                    // RunObject = page "Intr. Rate Change";

                    trigger OnAction()
                    var
                        _interestPageOnLoanCard: Page "Intr. Rate Change Loan Card";
                        _interestRates: Record "Interest Rate Change";
                        funder: Record Funders;
                    begin
                        funder.Reset();
                        funder.SetRange("No.", Rec."Funder No.");
                        if not funder.Find('-') then
                            Error('Funder %1 not found', Rec."Funder No.");

                        _interestRates.Reset();
                        if funder.FunderType = funder.FunderType::"Bank Loan" then
                            _interestRates.SetRange(_interestRates.Category, _interestRates.Category::"Bank Loan");
                        if funder.FunderType = funder.FunderType::Corporate then
                            _interestRates.SetRange(_interestRates.Category, _interestRates.Category::Corporate);
                        if funder.FunderType = funder.FunderType::Individual then
                            _interestRates.SetRange(_interestRates.Category, _interestRates.Category::Individual);
                        if funder.FunderType = funder.FunderType::Institutional then
                            _interestRates.SetRange(_interestRates.Category, _interestRates.Category::Institutional);
                        if funder.FunderType = funder.FunderType::"Joint Application" then
                            _interestRates.SetRange(_interestRates.Category, _interestRates.Category::"Joint Application");
                        if funder.FunderType = funder.FunderType::"Bank Overdraft" then
                            _interestRates.SetRange(_interestRates.Category, _interestRates.Category::"Bank Overdraft");

                        _interestRates.SetRange("Inter. Rate Group Name", Rec."Group Reference Name");
                        _interestRates.SetRange("Inter. Rate Group", Rec."Group Reference No.");
                        _interestRates.SetFilter("Loan No.", '<>%1', Rec."No.");

                        _interestPageOnLoanCard.SetTableView(_interestRates);
                        _interestPageOnLoanCard.Run();

                    end;

                }
            }
        }

        area(Reporting)
        {
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()

                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;

                    PromotedCategory = New;


                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View approval requests.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = HasApprovalEntries;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
            }

            group(Reports)
            {
                action("Amortized Interest")
                {
                    ApplicationArea = All;
                    Caption = 'Amortized Interest';
                    Image = Report2;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    // RunObject = report "Interest Amortization";
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Interest Amortization", true, false, _funderLoan);
                    end;



                }
                action("Amortized Payment")
                {
                    ApplicationArea = All;
                    Caption = 'Amortized Payment';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    // RunObject = report "Payment Amortization";
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Payment Amortization", true, false, _funderLoan);

                        // Report.Run(50230, true, false, _funderLoan);
                    end;
                }
                action("Amortized Payment B")
                {
                    ApplicationArea = All;
                    Caption = 'Bank Loan Schedule';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    // RunObject = report "Payment Amortization";
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Payment Amortization B", true, false, _funderLoan);

                        // Report.Run(50230, true, false, _funderLoan);
                    end;
                }
                action("Amortized Capitalize")
                {
                    ApplicationArea = All;
                    Caption = 'Amortized Capitalize';
                    Image = TestReport;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Funder Capitalization Schedule", true, false, _funderLoan);

                        // Report.Run(50230, true, false, _funderLoan);
                    end;
                }
                action("Loan Repayment Schedule")
                {
                    ApplicationArea = All;
                    Caption = 'Loan Repayment';
                    Image = Replan;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    // RunObject = report "Loan Repayment Schedule";
                    trigger OnAction()
                    var
                        _funderLoan: Record "Funder Loan";
                    begin
                        // _funderLoan.Reset();
                        // _funderLoan.SetRange("No.", Rec."No.");
                        // // Report.Run(50230, true, false, _funderLoan);
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::"Loan Repayment Schedule", true, false, _funderLoan);

                    end;
                }
                action("Capitalize Interest")
                {
                    ApplicationArea = All;
                    Caption = 'Capitalize Interest';
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        LoanRec: Record "Funder Loan";
                        Capitalizarp: Report "Capitalize Interest";
                    begin
                        LoanRec.SetRange("No.", Rec."No.");
                        Capitalizarp.SetTableView(LoanRec);
                        Capitalizarp.Run();
                    end;
                }
                action("ReEvaluateFX")
                {
                    ApplicationArea = All;
                    Caption = 'ReEvaluateFX';
                    Image = Report;
                    // ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    // RunObject = report ReEvaluateFX;
                    trigger OnAction()
                    var
                        // Report:Report ReEvaluateFX;
                        _funderLoan: Record "Funder Loan";
                    begin
                        _funderLoan.Reset();
                        _funderLoan.SetRange("No.", Rec."No.");
                        Report.Run(Report::ReEvaluateFX, true, false, _funderLoan);

                    end;
                }
            }
            group(Documents)
            {
                action("attachment")
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                }
                action(Confirmation)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Confirmation Document';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Report;
                    // RunObject = report "Investment Confirmation";
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        InvestConfRp: Report "Investment Confirmation";
                        ReportFlag: Record "Report Flags";
                    begin
                        // InvestConfRp.SetFunderNoFilter(Rec."No.");
                        Rec.Reset();
                        Rec.SetRange("No.", Rec."No.");

                        Report.Run(Report::"Investment Confirmation", true, false, Rec);
                    end;

                }
                action(Redemption)
                {
                    ApplicationArea = All;
                    Caption = 'Redemption Document';
                    Image = MoveNegativeLines;
                    Promoted = true;
                    PromotedCategory = Report;
                    // RunObject = report "Investment Confirmation";
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        RedemptionDoc: Report "Redemption Document";
                        LoanRec: Record "Funder Loan";
                    // ReportFlag: Record "Report Flags";
                    begin
                        LoanRec.SetRange("No.", Rec."No.");
                        RedemptionDoc.SetTableView(LoanRec);
                        RedemptionDoc.Run();
                        // Report.Run(Report::"Investment Confirmation");
                    end;

                }
            }
        }

    }


    trigger OnInit()
    begin
        isCurrencyVisible := true;
        isSecureLoanActive := false;
        isUnsecureLoanActive := true;
        isFloatRate := false;
        isOverdraftLoan := false;

        _funderNo := GlobalFilters.GetGlobalFilter();
        if _funderNo <> '' then begin
            if FunderTbl.Get(_funderNo) then begin
                if FunderTbl.FunderType = FunderTbl.FunderType::Individual then begin
                    if FunderTbl."Mailing Address" = '' then begin
                        Error('Email Required');
                        exit;
                    end;
                end;
            end;
        end;
    end;

    trigger OnOpenPage()
    var
        ReportFlag: Record "Report Flags";
    begin
        "Region/Country".Reset();
        if "Region/Country".IsEmpty() then begin
            Error('Region/Country must have atleast one entry');
            exit;
        end;
        _funderNo := GlobalFilters.GetGlobalFilter();
        // if _funderNo <> '' then begin
        //     if FunderTbl.Get(_funderNo) then begin
        //         if FunderTbl."Funder Type" = FunderTbl."Funder Type"::Local then
        //             isCurrencyVisible := false;
        //     end;
        // end;
        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then begin
            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
            Rec.Modify();
            isFloatRate := true
        end
        else
            isFloatRate := false;
        //  Rec."Document Number" := TrsyMgt.GenerateDocumentNumber();
        if Rec.SecurityType = Rec.SecurityType::"Senior secured" then begin
            isSecureLoanActive := true;
            isUnsecureLoanActive := false;

        end;

        if Rec.SecurityType = Rec.SecurityType::"Senior Unsecured" then begin
            isUnsecureLoanActive := true;
            isSecureLoanActive := false;
        end;

        ReportFlag.Reset();
        ReportFlag.SetFilter("Line No.", '<>%1', 0);
        ReportFlag.SetFilter("Utilizing User", '=%1', UserId);
        if ReportFlag.Find('-') then begin
            repeat
                ReportFlag.Delete();
            until ReportFlag.Next() = 0;
        end;
        ReportFlag.Init();
        ReportFlag."Funder Loan No." := Rec."No.";
        ReportFlag."Utilizing User" := UserId;
        ReportFlag.Insert();

        if Rec."Payables Account" = '' then
            Rec."Payables Account" := FunderTbl."Payables Account";
        if Rec."Interest Expense" = '' then
            Rec."Interest Expense" := FunderTbl."Interest Expense";
        if Rec."Interest Payable" = '' then
            Rec."Interest Payable" := FunderTbl."Interest Payable";

        UpdateInterestPaymentVisibility();
        FieldEditProp();
        RolloveredChecker();

        EncumberanceView := false;
        LoanRepaymentView := false;
        TranchesView := false;

        isOverdraftLoan := Rec.Category = UpperCase('Bank Overdraft')
    end;


    trigger OnNextRecord(Steps: Integer): Integer
    begin
        if Rec.InterestRateType = Rec.InterestRateType::"Floating Rate" then begin
            Rec.InterestRate := Rec."Reference Rate" + Rec.Margin;
            Rec.Modify();
            isFloatRate := true
        end
        else
            isFloatRate := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        _pportfolio: Record Portfolio;
    begin
        _pportfolio.Reset();
        _pportfolio.SetRange("No.", FunderTbl.Portfolio);
        if not _pportfolio.FindFirst() then
            Error('Portfolio not found %1', FunderTbl.Portfolio);

        Rec.FundSource := FunderTbl.FundSource;
        Rec.Validate(FundSource);

        if _pportfolio.Category = _pportfolio.Category::"Bank Loan" then
            Rec.Category := UpperCase('Bank Loan');
        if _pportfolio.Category = _pportfolio.Category::Individual then
            Rec.Category := UpperCase('Individual');
        if _pportfolio.Category = _pportfolio.Category::Institutional then
            Rec.Category := UpperCase('Institutional');
        if _pportfolio.Category = _pportfolio.Category::"Asset Term Manager" then
            Rec.Category := UpperCase('Asset Term Manager');
        if _pportfolio.Category = _pportfolio.Category::"Medium Term Notes" then
            Rec.Category := UpperCase('Medium Term Notes');
        if _pportfolio.Category = _pportfolio.Category::"Bank Overdraft" then
            Rec.Category := UpperCase('Bank Overdraft');

        Rec."Origin Entry" := Rec."Origin Entry"::Funder;

        // if Rec."Payables Account" = '' then
        //     Rec."Payables Account" := FunderTbl."Payables Account";
        // if Rec."Interest Expense" = '' then
        //     Rec."Interest Expense" := FunderTbl."Interest Expense";
        // if Rec."Interest Payable" = '' then
        //     Rec."Interest Payable" := FunderTbl."Interest Payable";

        isOverdraftLoan := Rec.Category = UpperCase('Bank Overdraft')


    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FilterVal: Text[30];
    begin

        if _funderNo <> '' then begin
            Rec."Funder No." := _funderNo;
            Rec.Validate("Funder No.");
            // Rec.Insert();
        end;

    end;

    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        // OpenApprovalEntriesExist := ApprovalsMgmt.HasApprovedApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
        UpdateInterestPaymentVisibility();
        FieldEditProp();
        RolloveredChecker();
        OverdraftView := Rec.Category = UpperCase('BANK OVERDRAFT');
        EncumberanceView := Rec.Category = UpperCase('Bank Loan');
        LoanRepaymentView := Rec.Category = UpperCase('Bank Loan');
        TranchesView := (Rec.Category = UpperCase('Institutional')) or (Rec.Category = UpperCase('Bank Loan'));

    end;

    trigger OnAfterGetRecord()
    begin
        isOverdraftLoan := Rec.Category = UpperCase('Bank Overdraft')

    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ReportFlag: Record "Report Flags";
    begin
        ReportFlag.Reset();
        ReportFlag.SetFilter("Line No.", '<>%1', 0);
        ReportFlag.SetFilter("Utilizing User", '=%1', UserId);
        if ReportFlag.Find('-') then begin
            repeat
                ReportFlag.Delete();
            until ReportFlag.Next() = 0;
        end;
    end;

    local procedure UpdateInterestPaymentVisibility()
    begin
        EnableInterestPaymentVisibility := Rec.PeriodicPaymentOfInterest = Rec.PeriodicPaymentOfInterest::Quarterly;

    end;

    local procedure FieldEditProp()
    var
    begin
        EditStatus := (Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Rejected);

        // EditStatus := not (Rec.Status = Rec.Status::Approved) or not (Rec.Status = Rec.Status::"Pending Approval");
    end;

    local procedure RolloveredChecker()
    var
    begin
        IsRollovered := (Rec.Rollovered = Rec.Rollovered::"Roll overed");
    end;

    var
        myInt: Integer;
        GenSetup: Record "Treasury General Setup";
        NoSer: Codeunit "No. Series";
        TreasuryMgtCU: Codeunit "Treasury Mgt CU";
        GlobalFilters: Codeunit GlobalFilters;
        isCurrencyVisible, isSecureLoanActive, isUnsecureLoanActive, isFloatRate, isOverdraftLoan : Boolean;
        _funderNo: Text[30];
        FunderTbl: Record Funders;

        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        PlacementAndMaturityDifference: Integer;
        EnableInterestPaymentVisibility, EncumberanceView, LoanRepaymentView, TranchesView, EditStatus, OverdraftView : Boolean;
        "Region/Country": Record Country_Region;

        IsRollovered: Boolean;

    protected var

    // _docNo: Code[20];
    // TrsyMgt: Codeunit "Treasury Mgt CU";
}