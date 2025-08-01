table 50241 "Treasury Currency"
{
    // Currency (4)
    Caption = 'Treasury Currency';
    LookupPageID = "Treasury Currencies";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;


        }
        field(2; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(3; "Last Date Adjusted"; Date)
        {
            Caption = 'Last Date Adjusted';
            Editable = false;
        }
        field(4; "ISO Code"; Code[3])
        {
            Caption = 'ISO Code';
            DataClassification = CustomerContent;


        }
        field(5; "ISO Numeric Code"; Code[3])
        {
            Caption = 'ISO Numeric Code';
            DataClassification = CustomerContent;


        }
        field(6; "Unrealized Gains Acc."; Code[20])
        {
            Caption = 'Unrealized Gains Acc.';
            TableRelation = "G/L Account";

        }
        field(7; "Realized Gains Acc."; Code[20])
        {
            Caption = 'Realized Gains Acc.';
            TableRelation = "G/L Account";


        }
        field(8; "Unrealized Losses Acc."; Code[20])
        {
            Caption = 'Unrealized Losses Acc.';
            TableRelation = "G/L Account";


        }
        field(9; "Realized Losses Acc."; Code[20])
        {
            Caption = 'Realized Losses Acc.';
            TableRelation = "G/L Account";


        }
        field(10; "Invoice Rounding Precision"; Decimal)
        {
            AutoFormatExpression = Code;
            DecimalPlaces = 2 : 5;
            Caption = 'Invoice Rounding Precision';
            InitValue = 0.01;


        }
        field(12; "Invoice Rounding Type"; Option)
        {
            Caption = 'Invoice Rounding Type';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(13; "Amount Rounding Precision"; Decimal)
        {
            Caption = 'Amount Rounding Precision';
            DecimalPlaces = 2 : 5;
            InitValue = 0.01;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Amount Rounding Precision" <> 0 then begin
                    "Invoice Rounding Precision" := Round("Invoice Rounding Precision", "Amount Rounding Precision");
                    if "Amount Rounding Precision" > "Invoice Rounding Precision" then
                        "Invoice Rounding Precision" := "Amount Rounding Precision";
                end;
            end;
        }
        field(14; "Unit-Amount Rounding Precision"; Decimal)
        {
            Caption = 'Unit-Amount Rounding Precision';
            DecimalPlaces = 0 : 9;
            InitValue = 0.00001;
            MinValue = 0;
        }
        field(15; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(17; "Amount Decimal Places"; Text[5])
        {
            Caption = 'Amount Decimal Places';
            InitValue = '2:2';
            NotBlank = true;


        }
        field(18; "Unit-Amount Decimal Places"; Text[5])
        {
            Caption = 'Unit-Amount Decimal Places';
            InitValue = '2:5';
            NotBlank = true;


        }
        field(19; "Customer Filter"; Code[20])
        {
            Caption = 'Customer Filter';
            FieldClass = FlowFilter;
            TableRelation = Customer;
        }
        field(20; "Vendor Filter"; Code[20])
        {
            Caption = 'Vendor Filter';
            FieldClass = FlowFilter;
            TableRelation = Vendor;
        }
        field(21; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(22; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(23; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(24; "Cust. Ledg. Entries in Filter"; Boolean)
        {
            CalcFormula = exist("Cust. Ledger Entry" where("Customer No." = field("Customer Filter"),
                                                            "Currency Code" = field(Code)));
            Caption = 'Cust. Ledg. Entries in Filter';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Customer Balance"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = sum("Detailed Cust. Ledg. Entry".Amount where("Customer No." = field("Customer Filter"),
                                                                         "Initial Entry Global Dim. 1" = field("Global Dimension 1 Filter"),
                                                                         "Initial Entry Global Dim. 2" = field("Global Dimension 2 Filter"),
                                                                         "Posting Date" = field("Date Filter"),
                                                                         "Currency Code" = field(Code)));
            Caption = 'Customer Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Customer Outstanding Orders"; Decimal)
        {
            // AccessByPermission = TableData "Sales Shipment Header" = R;
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = sum("Sales Line"."Outstanding Amount" where("Document Type" = const(Order),
                                                                       "Bill-to Customer No." = field("Customer Filter"),
                                                                       "Currency Code" = field(Code),
                                                                       "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                       "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter")));
            Caption = 'Customer Outstanding Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; "Customer Shipped Not Invoiced"; Decimal)
        {
            // AccessByPermission = TableData "Sales Shipment Header" = R;
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = sum("Sales Line"."Shipped Not Invoiced" where("Document Type" = const(Order),
                                                                         "Bill-to Customer No." = field("Customer Filter"),
                                                                         "Currency Code" = field(Code),
                                                                         "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter")));
            Caption = 'Customer Shipped Not Invoiced';
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Customer Balance Due"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = sum("Detailed Cust. Ledg. Entry".Amount where("Customer No." = field("Customer Filter"),
                                                                         "Initial Entry Global Dim. 1" = field("Global Dimension 1 Filter"),
                                                                         "Initial Entry Global Dim. 2" = field("Global Dimension 2 Filter"),
                                                                         "Initial Entry Due Date" = field("Date Filter"),
                                                                         "Posting Date" = field(upperlimit("Date Filter")),
                                                                         "Currency Code" = field(Code)));
            Caption = 'Customer Balance Due';
            Editable = false;
            FieldClass = FlowField;
        }
        field(29; "Vendor Ledg. Entries in Filter"; Boolean)
        {
            CalcFormula = exist("Vendor Ledger Entry" where("Vendor No." = field("Vendor Filter"),
                                                             "Currency Code" = field(Code)));
            Caption = 'Vendor Ledg. Entries in Filter';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Vendor Balance"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Vendor Filter"),
                                                                           "Initial Entry Global Dim. 1" = field("Global Dimension 1 Filter"),
                                                                           "Initial Entry Global Dim. 2" = field("Global Dimension 2 Filter"),
                                                                           "Posting Date" = field("Date Filter"),
                                                                           "Currency Code" = field(Code)));
            Caption = 'Vendor Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Vendor Outstanding Orders"; Decimal)
        {
            // AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = sum("Purchase Line"."Outstanding Amount" where("Document Type" = const(Order),
                                                                          "Pay-to Vendor No." = field("Vendor Filter"),
                                                                          "Currency Code" = field(Code),
                                                                          "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                          "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter")));
            Caption = 'Vendor Outstanding Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Vendor Amt. Rcd. Not Invoiced"; Decimal)
        {
            // AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = sum("Purchase Line"."Amt. Rcd. Not Invoiced" where("Document Type" = const(Order),
                                                                              "Pay-to Vendor No." = field("Vendor Filter"),
                                                                              "Currency Code" = field(Code),
                                                                              "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                              "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter")));
            Caption = 'Vendor Amt. Rcd. Not Invoiced';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33; "Vendor Balance Due"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Vendor Filter"),
                                                                           "Initial Entry Global Dim. 1" = field("Global Dimension 1 Filter"),
                                                                           "Initial Entry Global Dim. 2" = field("Global Dimension 2 Filter"),
                                                                           "Initial Entry Due Date" = field("Date Filter"),
                                                                           "Posting Date" = field(upperlimit("Date Filter")),
                                                                           "Currency Code" = field(Code)));
            Caption = 'Vendor Balance Due';
            Editable = false;
            FieldClass = FlowField;
        }
        field(34; "Customer Balance (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" where("Customer No." = field("Customer Filter"),
                                                                                 "Initial Entry Global Dim. 1" = field("Global Dimension 1 Filter"),
                                                                                 "Initial Entry Global Dim. 2" = field("Global Dimension 2 Filter"),
                                                                                 "Posting Date" = field("Date Filter"),
                                                                                 "Currency Code" = field(Code)));
            Caption = 'Customer Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Vendor Balance (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" where("Vendor No." = field("Vendor Filter"),
                                                                                   "Initial Entry Global Dim. 1" = field("Global Dimension 1 Filter"),
                                                                                   "Initial Entry Global Dim. 2" = field("Global Dimension 2 Filter"),
                                                                                   "Posting Date" = field("Date Filter"),
                                                                                   "Currency Code" = field(Code)));
            Caption = 'Vendor Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Realized G/L Gains Account"; Code[20])
        {
            Caption = 'Realized G/L Gains Account';
            TableRelation = "G/L Account";


        }
        field(41; "Realized G/L Losses Account"; Code[20])
        {
            Caption = 'Realized G/L Losses Account';
            TableRelation = "G/L Account";


        }
        field(44; "Appln. Rounding Precision"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            Caption = 'Appln. Rounding Precision';
            MinValue = 0;
        }
        field(45; "EMU Currency"; Boolean)
        {
            Caption = 'EMU Currency';
        }
        field(46; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(47; "Residual Gains Account"; Code[20])
        {
            Caption = 'Residual Gains Account';
            TableRelation = "G/L Account";
        }
        field(48; "Residual Losses Account"; Code[20])
        {
            Caption = 'Residual Losses Account';
            TableRelation = "G/L Account";
        }
        field(50; "Conv. LCY Rndg. Debit Acc."; Code[20])
        {
            Caption = 'Conv. LCY Rndg. Debit Acc.';
            TableRelation = "G/L Account";
        }
        field(51; "Conv. LCY Rndg. Credit Acc."; Code[20])
        {
            Caption = 'Conv. LCY Rndg. Credit Acc.';
            TableRelation = "G/L Account";
        }
        field(52; "Max. VAT Difference Allowed"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            Caption = 'Max. VAT Difference Allowed';


        }
        field(53; "VAT Rounding Type"; Option)
        {
            Caption = 'VAT Rounding Type';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(54; "Payment Tolerance %"; Decimal)
        {
            Caption = 'Payment Tolerance %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(55; "Max. Payment Tolerance Amount"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            Caption = 'Max. Payment Tolerance Amount';
            Editable = false;
            MinValue = 0;
        }
        field(56; Symbol; Text[10])
        {
            Caption = 'Symbol';
        }
        field(57; "Last Modified Date Time"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }

        field(721; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::Currency)));
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}