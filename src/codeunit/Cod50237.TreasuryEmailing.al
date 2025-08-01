codeunit 50237 "Treasury Emailing"
{
    trigger OnRun()
    begin

    end;

    procedure SendConfirmationEmailWithAttachment(funderLoanNo: Code[20]) Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        FileInStream1: InStream;
        FileOutStream1: OutStream;
        RecRef: RecordRef;
        RecRef1: RecordRef;
        FunderLoan: Record "Funder Loan";
        Funders: Record Funders;
        // BufferSetup: Record BufferSetup;
        Body: Text;

        PrimaryEmail: Text[100];

    begin

        FunderLoan.Reset();
        FunderLoan.SetRange(FunderLoan."No.", funderLoanNo);
        if not FunderLoan.Find('-') then
            Error('Funder Loan %1 Not found.', funderLoanNo);

        Funders.Reset();
        Funders.SetRange("No.", FunderLoan."Funder No.");
        if not Funders.Find('-') then
            Error('Funder %1 Not found.', FunderLoan."Funder No.");

        FunderMgtCU.SetFunderNoFilter(funderLoanNo);// Update report Mandatory Field
        Company.get();





        // Body := '<p>Dear ' + Funders.Name + '</p><p> Thank you for your placement of ' + Format(FunderLoan."Original Disbursed Amount") + ' on ' + Format(FunderLoan.PlacementDate) + ' with ' + CompanyName + '.</p> <p> Please find attached the placement confirmation for your review. Kindly sign and return the document at your earliest convenience.</p> <p>If you have any questions or require further assistance, please feel free to contact us at ' + Company."Phone No." + '.</p> <p>Best regards,</p> <p>' + CompanyName + ' – Treasury</p> <br><br><br><br> <p>(This is a system-generated email.)</p>';
        Body := '<p>I hope youre doing well.Please find attached the placement confirmation certificate for your review.</p><p> Kindly let us know if you have any feedback. The final execution copy will be shared for sign-off at a later stage.Please don’t hesitate to reach out if you need any clarifications.</p> <p>Best regards,</p>' + GeneralSetup."Trsy Recipient Name" + ' – Treasury</p> <br><br><br><br> <p>(This is a system-generated email.)</p>';

        // if (Funders.FunderType = Funders.FunderType::"Bank Loan") or (Funders.FunderType = Funders.FunderType::"Bank Overdraft") or (Funders.FunderType = Funders.FunderType::Corporate) then begin
        //     exit
        // end;
        if (Funders.FunderType <> Funders.FunderType::Individual) then begin
            exit
        end;
        if Funders.FunderType = Funders.FunderType::Individual then begin
            if Funders."Mailing Address" = '' then
                Error('Email Address is Empty');
        end;

        EmailMessage.Create(Funders."Mailing Address", 'Placement Confirmation with Company' + CompanyName + ' Ltd', Body, true);

        // if Funders."Email Address" <> '' then
        //     EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, BufferSetup.POEmailCC1);

        RecRef.GetTable(FunderLoan);
        TempBlob.CreateOutStream(FileOutStream);
        Report.SaveAs(Report::"Investment Confirmation", '', ReportFormat::Pdf, FileOutStream, RecRef);
        TempBlob.CreateInStream(FileInStream);
        EmailMessage.AddAttachment('Confirmation.pdf', 'PDF', FileInStream);
        // Clear(TempBlob);
        // // RecRef1.GetTable(FunderLoan);
        // TempBlob.CreateOutStream(FileOutStream1);
        // Report.SaveAs(Report::"Interest Amortization", '', ReportFormat::Pdf, FileOutStream1);
        // TempBlob.CreateInStream(FileInStream1);
        // EmailMessage.AddAttachment('Amortization.pdf', 'PDF', FileInStream1);


        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;

        // if HasCollectedErrors then
        //     Message(GetCollectedErrors().Get(1).Message)
        // else begin


        Message('Confirmation Mailed');
        // end;





    end;

    procedure SendConfirmationEmailWithAttachmentRelatedParty(RelatedPartyLoanNo: Code[20]) Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        FileInStream1: InStream;
        FileOutStream1: OutStream;
        RecRef: RecordRef;
        RecRef1: RecordRef;
        RelatedPartyLoan: Record "RelatedParty Loan";
        RelatedParty: Record RelatedParty;
        // BufferSetup: Record BufferSetup;
        Body: Text;

        PrimaryEmail: Text[100];

    begin

        RelatedPartyLoan.Reset();
        RelatedPartyLoan.SetRange(RelatedPartyLoan."No.", RelatedPartyLoanNo);
        if not RelatedPartyLoan.Find('-') then
            Error('RelatedParty Loan %1 Not found.', RelatedPartyLoanNo);

        RelatedParty.Reset();
        RelatedParty.SetRange("No.", RelatedPartyLoan."RelatedParty No.");
        if not RelatedParty.Find('-') then
            Error('RelatedParty %1 Not found.', RelatedPartyLoan."RelatedParty No.");

        FunderMgtCU.SetFunderNoFilter(RelatedPartyLoanNo);// Update report Mandatory Field
        Company.get();





        // Body := '<p>Dear ' + Funders.Name + '</p><p> Thank you for your placement of ' + Format(FunderLoan."Original Disbursed Amount") + ' on ' + Format(FunderLoan.PlacementDate) + ' with ' + CompanyName + '.</p> <p> Please find attached the placement confirmation for your review. Kindly sign and return the document at your earliest convenience.</p> <p>If you have any questions or require further assistance, please feel free to contact us at ' + Company."Phone No." + '.</p> <p>Best regards,</p> <p>' + CompanyName + ' – Treasury</p> <br><br><br><br> <p>(This is a system-generated email.)</p>';
        Body := '<p>I hope youre doing well.Please find attached the placement confirmation certificate for your review.</p><p> Kindly let us know if you have any feedback. The final execution copy will be shared for sign-off at a later stage.Please don’t hesitate to reach out if you need any clarifications.</p> <p>Best regards,</p>' + GeneralSetup."Trsy Recipient Name" + ' – Treasury</p> <br><br><br><br> <p>(This is a system-generated email.)</p>';

        if RelatedParty.FunderType = RelatedParty.FunderType::"Bank Loan" then begin
            exit
        end;
        if RelatedParty.FunderType = RelatedParty.FunderType::Individual then begin
            if RelatedParty."Mailing Address" = '' then
                Error('Email Address is Empty');
        end;

        EmailMessage.Create(RelatedParty."Mailing Address", 'Placement Confirmation with Company ' + CompanyName + ' Ltd', Body, true);

        // if RelatedParty."Email Address" <> '' then
        //     EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, BufferSetup.POEmailCC1);

        RecRef.GetTable(RelatedParty);
        TempBlob.CreateOutStream(FileOutStream);
        Report.SaveAs(Report::"RelatedParty Invest. Conf.", '', ReportFormat::Pdf, FileOutStream, RecRef);
        TempBlob.CreateInStream(FileInStream);
        EmailMessage.AddAttachment('Confirmation.pdf', 'PDF', FileInStream);
        // Clear(TempBlob);
        // // RecRef1.GetTable(FunderLoan);
        // TempBlob.CreateOutStream(FileOutStream1);
        // Report.SaveAs(Report::"Interest Amortization", '', ReportFormat::Pdf, FileOutStream1);
        // TempBlob.CreateInStream(FileInStream1);
        // EmailMessage.AddAttachment('Amortization.pdf', 'PDF', FileInStream1);


        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;

        // if HasCollectedErrors then
        //     Message(GetCollectedErrors().Get(1).Message)
        // else begin


        Message('Confirmation Mailed');
        // end;





    end;

    // Client
    procedure SendReminderOnPlacementMaturity(funderLoanNo: Code[20]) Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        RecRef: RecordRef;
        FunderLoan: Record "Funder Loan";
        Funders: Record Funders;
        Body: Text;

        PrimaryEmail: Text[100];
        PersistedCalc: Record "Schedule Total";
        MatureAmount: Decimal;
        CurrencySymbol: Text;
    begin

        FunderLoan.Reset();
        FunderLoan.SetRange(FunderLoan."No.", funderLoanNo);
        if not FunderLoan.Find('-') then
            Error('Funder Loan %1 Not found.', funderLoanNo);

        Funders.Reset();
        Funders.SetRange("No.", FunderLoan."Funder No.");
        if not Funders.Find('-') then
            Error('Funder %1 Not found.', FunderLoan."Funder No.");

        GeneralSetup.Get();
        Company.Get();

        CurrencySymbol := 'KES';
        if FunderLoan.Currency <> '' then
            CurrencySymbol := FunderLoan.Currency;

        PersistedCalc.Reset();
        PersistedCalc.SetRange(LoanNo, funderLoanNo);
        PersistedCalc.CalcSums(TotalPayment);
        MatureAmount := PersistedCalc.TotalPayment;

        Body := '<p>Dear ' + Funders.Name + '</p><p>You are receiving D365 Treasury reminders:</p><p>' + Format(FunderLoan.MaturityDate) + ' ' + Format(FunderLoan."Loan Name") + ' <b>' + Format(FunderLoan."No.") + ' </b> for entity ' + Company.Name + ' in the amount of ' + CurrencySymbol + ' ' + Format(Round(MatureAmount, 0.01, '=')) + ' matures on ' + Format(FunderLoan.MaturityDate) + '.Please take the necessary actions </p>';

        if Funders."Mailing Address" = '' then
            Error('Treasury Recipient Email Missing');

        EmailMessage.Create(Funders."Mailing Address", 'Placement Maturity Reminder with Company ' + CompanyName + ' Ltd', Body, true);

        // if GeneralSetup."Trsy Recipient mail1" <> '' then
        //     EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, GeneralSetup."Trsy Recipient mail1");

        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;


        Message('Mailed Reminder');
        // end;





    end;
    // Staff
    procedure SendReminderOnPlacementMaturityStaff() Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        RecRef: RecordRef;
        FunderLoan: Record "Funder Loan";
        Funders: Record Funders;
        Body: Text;

        PrimaryEmail: Text[100];
        PersistedCalc: Record "Schedule Total";
        MatureAmount: Decimal;
        CurrencySymbol: Text;

        _remOnPlacementMature: Record ReminderMaturityPerCategory;
        _ttotalPayment: Decimal;
    begin

        // FunderLoan.Reset();
        // FunderLoan.SetRange(FunderLoan."No.", funderLoanNo);
        // if not FunderLoan.Find('-') then
        //     Error('Funder Loan %1 Not found.', funderLoanNo);

        // Funders.Reset();
        // Funders.SetRange("No.", FunderLoan."Funder No.");
        // if not Funders.Find('-') then
        //     Error('Funder %1 Not found.', FunderLoan."Funder No.");

        GeneralSetup.Get(0);
        // Company.Get();

        // CurrencySymbol := 'KES';
        // if FunderLoan.Currency <> '' then
        //     CurrencySymbol := FunderLoan.Currency;

        // PersistedCalc.Reset();
        // PersistedCalc.SetRange(LoanNo, funderLoanNo);
        // PersistedCalc.CalcSums(TotalPayment);
        // MatureAmount := PersistedCalc.TotalPayment;

        _remOnPlacementMature.Reset();
        _remOnPlacementMature.SetFilter(Line, '<>%1', 0);

        Body := '<p>Dear ' + GeneralSetup."Trsy Recipient Name" + '</p><p>You are receiving D365 Treasury reminders of All Loans Maturing with ' + Format(GeneralSetup."Placemnt. Matur Rem. Time") + ' day(s) </p><p> For entity ' + Company.Name + '.Please take the necessary actions </p>';

        if GeneralSetup."Trsy Recipient mail" = '' then
            Error('Treasury Recipient Email Missing');

        EmailMessage.Create(GeneralSetup."Trsy Recipient mail", 'Placement Maturity Reminder with Company ' + CompanyName + ' Ltd', Body, true);

        RecRef.GetTable(_remOnPlacementMature);
        TempBlob.CreateOutStream(FileOutStream);
        Report.SaveAs(Report::ReminderAlertPerCategory, '', ReportFormat::Pdf, FileOutStream, RecRef);
        TempBlob.CreateInStream(FileInStream);
        EmailMessage.AddAttachment('CategoryMaturity.pdf', 'PDF', FileInStream);

        if GeneralSetup."Trsy Recipient mail1" <> '' then
            EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, GeneralSetup."Trsy Recipient mail1");

        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;


        Message('Mailed Treasury Teams');
        // end;
        _remOnPlacementMature.DeleteAll();




    end;

    // Client
    procedure SendReminderOnPlacementMaturityRelatedParty(RelatedPartyLoanNo: Code[20]) Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        RecRef: RecordRef;
        RelatedPartyLoan: Record "RelatedParty Loan";
        RelatedParty: Record RelatedParty;
        Body: Text;

        PrimaryEmail: Text[100];
        PersistedCalc: Record "Schedule Total";
        MatureAmount: Decimal;
        CurrencySymbol: Text;
    begin

        RelatedPartyLoan.Reset();
        RelatedPartyLoan.SetRange(RelatedPartyLoan."No.", RelatedPartyLoanNo);
        if not RelatedPartyLoan.Find('-') then
            Error('RelatedParty Loan %1 Not found.', RelatedPartyLoanNo);

        RelatedParty.Reset();
        RelatedParty.SetRange("No.", RelatedPartyLoan."RelatedParty No.");
        if not RelatedParty.Find('-') then
            Error('RelatedParty %1 Not found.', RelatedPartyLoan."RelatedParty No.");

        GeneralSetup.Get();
        Company.Get();

        CurrencySymbol := 'KES';
        if RelatedPartyLoan.Currency <> '' then
            CurrencySymbol := RelatedPartyLoan.Currency;

        PersistedCalc.Reset();
        PersistedCalc.SetRange(LoanNo, RelatedPartyLoanNo);
        PersistedCalc.CalcSums(TotalPayment);
        MatureAmount := PersistedCalc.TotalPayment;

        Body := '<p>Dear ' + RelatedParty.Name + '</p><p>You are receiving D365 Treasury reminders:</p><p>' + Format(RelatedPartyLoan.MaturityDate) + ' ' + Format(RelatedPartyLoan."Loan Name") + ' <b>' + Format(RelatedPartyLoan."No.") + ' </b> for entity ' + Company.Name + ' in the amount of ' + CurrencySymbol + ' ' + Format(Round(MatureAmount, 0.01, '=')) + ' matures on ' + Format(RelatedPartyLoan.MaturityDate) + '.Please take the necessary actions </p>';

        if RelatedParty."Mailing Address" = '' then
            Error('Treasury Recipient Email Missing');

        EmailMessage.Create(RelatedParty."Mailing Address", 'Placement Maturity Reminder with Company ' + CompanyName + ' Ltd', Body, true);

        // if GeneralSetup."Trsy Recipient mail1" <> '' then
        //     EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, GeneralSetup."Trsy Recipient mail1");

        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;


        Message('Mailed Reminder');


    end;
    // Staff
    procedure SendReminderOnPlacementMaturityStaffRelatedParty() Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        RecRef: RecordRef;
        // FunderLoan: Record "Funder Loan";
        RelatedParty: Record RelatedParty;
        Body: Text;

        PrimaryEmail: Text[100];
        PersistedCalc: Record "Schedule Total";
        MatureAmount: Decimal;
        CurrencySymbol: Text;

        _remOnPlacementMature: Record ReminderMaturityPerCategory;
        _ttotalPayment: Decimal;
    begin

        // FunderLoan.Reset();
        // FunderLoan.SetRange(FunderLoan."No.", funderLoanNo);
        // if not FunderLoan.Find('-') then
        //     Error('Funder Loan %1 Not found.', funderLoanNo);

        // Funders.Reset();
        // Funders.SetRange("No.", FunderLoan."Funder No.");
        // if not Funders.Find('-') then
        //     Error('Funder %1 Not found.', FunderLoan."Funder No.");

        GeneralSetup.Get(0);
        // Company.Get();

        // CurrencySymbol := 'KES';
        // if FunderLoan.Currency <> '' then
        //     CurrencySymbol := FunderLoan.Currency;

        // PersistedCalc.Reset();
        // PersistedCalc.SetRange(LoanNo, funderLoanNo);
        // PersistedCalc.CalcSums(TotalPayment);
        // MatureAmount := PersistedCalc.TotalPayment;

        _remOnPlacementMature.Reset();
        _remOnPlacementMature.SetFilter(Line, '<>%1', 0);

        Body := '<p>Dear ' + GeneralSetup."Trsy Recipient Name" + '</p><p>You are receiving D365 Treasury reminders of All Loans Maturing with ' + Format(GeneralSetup."Placemnt. Matur Rem. Time") + ' day(s) </p><p> For entity ' + Company.Name + '.Please take the necessary actions </p>';

        if GeneralSetup."Trsy Recipient mail" = '' then
            Error('Treasury Recipient Email Missing');

        EmailMessage.Create(GeneralSetup."Trsy Recipient mail", 'Placement Maturity Reminder with Company ' + CompanyName + ' Ltd', Body, true);

        RecRef.GetTable(_remOnPlacementMature);
        TempBlob.CreateOutStream(FileOutStream);
        Report.SaveAs(Report::ReminderAlertPerCategory, '', ReportFormat::Pdf, FileOutStream);
        TempBlob.CreateInStream(FileInStream);
        EmailMessage.AddAttachment('CategoryMaturity.pdf', 'PDF', FileInStream);

        if GeneralSetup."Trsy Recipient mail1" <> '' then
            EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, GeneralSetup."Trsy Recipient mail1");

        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;


        Message('Mailed Treasury Teams');
        // end;
        _remOnPlacementMature.DeleteAll();




    end;

    procedure SendReminderOnInterestDue(funderLoanNo: Code[20]) Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        RecRef: RecordRef;
        FunderLoan: Record "Funder Loan";
        Funders: Record Funders;
        // BufferSetup: Record BufferSetup;
        Body: Text;

        PrimaryEmail: Text[100];
    begin

        GeneralSetup.Get();

        FunderLoan.Reset();
        FunderLoan.SetRange(FunderLoan."No.", funderLoanNo);
        if not FunderLoan.Find('-') then
            Error('Funder Loan %1 Not found.', funderLoanNo);

        Funders.Reset();
        Funders.SetRange("No.", FunderLoan."Funder No.");
        if not Funders.Find('-') then
            Error('Funder %1 Not found.', FunderLoan."Funder No.");

        RecRef.GetTable(FunderLoan);
        TempBlob.CreateOutStream(FileOutStream);
        Report.SaveAs(Report::"Reminder On Intr. Due", '', ReportFormat::Excel, FileOutStream);
        TempBlob.CreateInStream(FileInStream);

        Body := '<p>Dear ' + GeneralSetup."Trsy Recipient Name" + '</p><p> You are receiving D365 Treasury reminders for interest due </p>';

        if GeneralSetup."Trsy Recipient mail" = '' then
            Error('Treasury Recipient Email Missing');

        EmailMessage.Create(GeneralSetup."Trsy Recipient mail", 'Reminder on Interest Due For  ' + CompanyName + ' Ltd', Body, true);
        EmailMessage.AddAttachment('IntrestDue.xlsx', 'xlsx', FileInStream);
        // if Funders."Email Address" <> '' then
        //     EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, BufferSetup.POEmailCC1);

        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;

        // if HasCollectedErrors then
        //     Message(GetCollectedErrors().Get(1).Message)
        // else begin


        Message('Mailed Confirmation');
        // end;





    end;

    procedure SendReminderOnInterestDueRelatedParty(RelatedPartyLoanNo: Code[20]) Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        RecRef: RecordRef;
        RelatedPartyLoan: Record "RelatedParty Loan";
        RelatedParty: Record RelatedParty;
        // BufferSetup: Record BufferSetup;
        Body: Text;

        PrimaryEmail: Text[100];
    begin

        GeneralSetup.Get();

        RelatedPartyLoan.Reset();
        RelatedPartyLoan.SetRange(RelatedPartyLoan."No.", RelatedPartyLoanNo);
        if not RelatedPartyLoan.Find('-') then
            Error('RelatedParty Loan %1 Not found.', RelatedPartyLoanNo);

        RelatedParty.Reset();
        RelatedParty.SetRange("No.", RelatedPartyLoan."RelatedParty No.");
        if not RelatedParty.Find('-') then
            Error('RelatedParty %1 Not found.', RelatedPartyLoan."RelatedParty No.");

        RecRef.GetTable(RelatedPartyLoan);
        TempBlob.CreateOutStream(FileOutStream);
        Report.SaveAs(Report::"Related Rem. On Intr. Due", '', ReportFormat::Excel, FileOutStream);
        TempBlob.CreateInStream(FileInStream);

        Body := '<p>Dear ' + GeneralSetup."Trsy Recipient Name" + '</p><p> You are receiving D365 Treasury reminders for interest due </p>';

        if GeneralSetup."Trsy Recipient mail" = '' then
            Error('Treasury Recipient Email Missing');

        EmailMessage.Create(GeneralSetup."Trsy Recipient mail", 'Reminder on Interest Due For  ' + CompanyName + ' Ltd', Body, true);
        EmailMessage.AddAttachment('IntrestDue.xlsx', 'xlsx', FileInStream);
        // if Funders."Email Address" <> '' then
        //     EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, BufferSetup.POEmailCC1);

        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;

        // if HasCollectedErrors then
        //     Message(GetCollectedErrors().Get(1).Message)
        // else begin


        Message('EMail Sent');
        // end;

    end;

    procedure EmailFunderOnNewPrincipalFromCapitalization(LoanNo: Code[20])
    var
        funderLegderEntry2: Record FunderLedgerEntry;
        _totalOutstandingAmount: Decimal;
        FunderLoan: Record "Funder Loan";
        Funders: Record Funders;

        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Body: Text;
        PrimaryEmail: Text[100];
    begin
        GeneralSetup.Get();

        FunderLoan.Reset();
        FunderLoan.SetRange(FunderLoan."No.", LoanNo);
        if not FunderLoan.Find('-') then
            Error('Funder Loan %1 Not found.', LoanNo);

        FunderLoan.CalcFields(OutstandingAmntDisbLCY);
        _totalOutstandingAmount := FunderLoan.OutstandingAmntDisbLCY;

        Funders.Reset();
        Funders.SetRange("No.", FunderLoan."Funder No.");
        if not Funders.Find('-') then
            Error('Funder %1 Not found.', FunderLoan."Funder No.");

        Body := '<p>Dear ' + Funders.Name + '</p><p> You are receiving D365 Treasury alert on your New Principal which is ' + Format(_totalOutstandingAmount) + ' as of ' + Format(Today, 0, 4) + '</p>';

        if FunderLoan.Category <> 'INDIVIDUAL' then
            exit;

        if Funders."Mailing Address" = '' then
            Error('Funder Email Missing');

        EmailMessage.Create(Funders."Mailing Address", 'Notification for the Latest Capitalization ', Body, true);


        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;



        Message('Mailed Confirmation');
    end;

    procedure EmailRelatedOnNewPrincipalFromCapitalization(LoanNo: Code[20])
    var
        relatedLegderEntry2: Record RelatedLedgerEntry;
        _totalOutstandingAmount: Decimal;
        RelatedLoan: Record "RelatedParty Loan";
        Relatedparty: Record RelatedParty;

        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Body: Text;
        PrimaryEmail: Text[100];
    begin
        GeneralSetup.Get();

        RelatedLoan.Reset();
        RelatedLoan.SetRange(RelatedLoan."No.", LoanNo);
        if not RelatedLoan.Find('-') then
            Error('Funder Loan %1 Not found.', LoanNo);

        RelatedLoan.CalcFields(OutstandingAmntDisbLCY);
        _totalOutstandingAmount := RelatedLoan.OutstandingAmntDisbLCY;

        Relatedparty.Reset();
        Relatedparty.SetRange("No.", RelatedLoan."Funder No.");
        if not Relatedparty.Find('-') then
            Error('Funder %1 Not found.', RelatedLoan."Funder No.");

        Body := '<p>Dear ' + Relatedparty.Name + '</p><p> You are receiving D365 Treasury alert on your New Principal which is ' + Format(_totalOutstandingAmount) + ' as of ' + Format(Today, 0, 4) + '</p>';

        if RelatedLoan.Category <> 'INDIVIDUAL' then
            exit;

        if Relatedparty."Mailing Address" = '' then
            Error('Funder Email Missing');

        EmailMessage.Create(Relatedparty."Mailing Address", 'Notification for the Latest Capitalization ', Body, true);


        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;



        Message('Mailed Confirmation');
    end;

    procedure SendPartidalRedemptionEmailWithAttachment(funderLoanNo: Code[20]) Result: Text
    var
        RecordRef: RecordRef;
        EMail: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MailSent: Boolean;
        ErrInfo: ErrorInfo;
        Vendors: Record Vendor;

        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        FileInStream1: InStream;
        FileOutStream1: OutStream;
        RecRef: RecordRef;
        RecRef1: RecordRef;
        FunderLoan: Record "Funder Loan";
        Funders: Record Funders;
        // BufferSetup: Record BufferSetup;
        Body: Text;

        PrimaryEmail: Text[100];

    begin

        FunderLoan.Reset();
        FunderLoan.SetRange(FunderLoan."No.", funderLoanNo);
        if not FunderLoan.Find('-') then
            Error('Funder Loan %1 Not found.', funderLoanNo);

        Funders.Reset();
        Funders.SetRange("No.", FunderLoan."Funder No.");
        if not Funders.Find('-') then
            Error('Funder %1 Not found.', FunderLoan."Funder No.");

        FunderMgtCU.SetFunderNoFilter(funderLoanNo);// Update report Mandatory Field
        Company.get();





        Body := '<p>Dear ' + Funders.Name + '</p><p> This is your Partial Redemption Document</p> <p>Best regards,</p> <p>' + CompanyName + ' – Treasury</p> <br><br><br><br> <p>(This is a system-generated email.)</p>';

        if Funders.FunderType = Funders.FunderType::"Bank Loan" then begin
            exit
        end;
        if Funders.FunderType = Funders.FunderType::Individual then begin
            if Funders."Mailing Address" = '' then
                Error('Email Address is Empty');
        end;

        EmailMessage.Create(Funders."Mailing Address", 'REDEMPTION / PARTIAL REDEMPTION CONFIRMATION', Body, true);

        if GeneralSetup."Trsy Recipient mail" <> '' then
            EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, GeneralSetup."Trsy Recipient mail");

        // RecRef.GetTable(FunderLoan);
        TempBlob.CreateOutStream(FileOutStream);
        Report.SaveAs(Report::"Redemption Document", '', ReportFormat::Pdf, FileOutStream);
        TempBlob.CreateInStream(FileInStream);
        EmailMessage.AddAttachment('Partial Redemption.pdf', 'PDF', FileInStream);
        // Clear(TempBlob);
        // // RecRef1.GetTable(FunderLoan);
        // TempBlob.CreateOutStream(FileOutStream1);
        // Report.SaveAs(Report::"Interest Amortization", '', ReportFormat::Pdf, FileOutStream1);
        // TempBlob.CreateInStream(FileInStream1);
        // EmailMessage.AddAttachment('Amortization.pdf', 'PDF', FileInStream1);


        MailSent := EMail.Send(EmailMessage, Enum::"Email Scenario"::Default);

        if not MailSent then begin
            ErrInfo := ErrorInfo.Create('This is error: ' + Format(1));
            ErrInfo.ErrorType(ErrorType::Client);
            ErrInfo.Verbosity(Verbosity::Error);
            ErrInfo.DetailedMessage(GetLastErrorText());
            ErrInfo.DataClassification(DataClassification::SystemMetadata);
            ErrInfo.Collectible(true);
            Error(ErrInfo);
        end;

        // if HasCollectedErrors then
        //     Message(GetCollectedErrors().Get(1).Message)
        // else begin


        Message('Partial Redemption Mailed');
        // end;





    end;


    var
        FunderMgtCU: Codeunit 50231;
        Company: Record "Company Information";
        GeneralSetup: Record "Treasury General Setup";
}