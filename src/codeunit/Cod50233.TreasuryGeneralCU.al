codeunit 50233 TreasuryGeneralCU
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Page, Page::"Doc. Attachment List Factbox", OnBeforeDocumentAttachmentDetailsRunModal, '', false, false)]
    local procedure OnBeforeDocumentAttachmentDetailsRunModal(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        funder: Record "Funders";
        _portfolio: Record Portfolio;
        _loan: Record "Funder Loan";
    begin
        case DocumentAttachment."Table ID" of
            DATABASE::"Funders":
                begin
                    RecRef.Open(DATABASE::"Funders");
                    if funder.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(funder);
                end;
            Database::Portfolio:
                begin
                    RecRef.Open(DATABASE::Portfolio);
                    if _portfolio.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(_portfolio);
                end;
            Database::"Funder Loan":
                begin
                    RecRef.Open(DATABASE::"Funder Loan");
                    if _loan.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(_loan);
                end;
        end;
    end;

    // [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", OnBeforeDrillDown, '', false, false)]
    // local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    // var
    //     funder: Record "Funders";
    //     _portfolio: Record Portfolio;
    // begin
    //     case DocumentAttachment."Table ID" of
    //         DATABASE::"Funders":
    //             begin
    //                 RecRef.Open(DATABASE::"Funders");
    //                 if funder.Get(DocumentAttachment."No.") then
    //                     RecRef.GetTable(funder);
    //             end;
    //         Database::Portfolio:
    //             begin
    //                 RecRef.Open(DATABASE::Portfolio);
    //                 if funder.Get(DocumentAttachment."No.") then
    //                     RecRef.GetTable(_portfolio);
    //             end;
    //     end;
    // end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", OnAfterOpenForRecRef, '', false, false)]
    local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef);
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        case RecRef.Number of
            DATABASE::"Funders":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
            DATABASE::Portfolio:
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
            DATABASE::"Funder Loan":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", OnAfterInitFieldsFromRecRef, '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        case RecRef.Number of
            DATABASE::Funders:
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
            DATABASE::Portfolio:
                begin
                    FieldRef := RecRef.Field(16);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
            DATABASE::"Funder Loan":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    var


}