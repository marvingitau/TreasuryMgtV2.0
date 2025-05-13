pageextension 50233 "Doc. Attchment _" extends 1173
{
    layout
    {
        // Add changes to page layout here
        addafter("File Type")
        {
            field("Document Name"; Rec."Document Name")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()
    var
    begin
        OpParadigm := Rec.GetFilter("Table ID");
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // if OpParadigm = '50232' then begin
        //     DocAttch.Reset();
        //     DocAttch.SetRange("Table ID", 50232);
        //     if DocAttch.Find('-') then begin
        //         repeat
        //             if DocAttch.DocType = DocAttch.DocType::" " then
        //                 Error('Document Type Needed');
        //         until DocAttch.Next() = 0;
        //     end;
        // end;
    end;

    var
        myInt: Integer;
        OpParadigm: Text;
        DocAttch: Record "Document Attachment";
}