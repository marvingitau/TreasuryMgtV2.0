pageextension 50234 "Remove Doc Attach Actions" extends "Doc. Attachment List Factbox"
{
    actions
    {
        modify(OpenInDetail)
        {
            Visible = false;
        }
        modify(AttachmentsUpload)
        {
            Visible = false;
        }
        modify(AttachFromEmail)
        {
            Visible = false;
        }
        modify(OpenInOneDrive)
        {
            Visible = false;
        }

        modify(EditInOneDrive)
        {
            Visible = false;
        }
        modify(ShareWithOneDrive)
        {
            Visible = false;
        }

        modify(OpenInFileViewer)
        {
            Visible = false;
        }
        modify(DownloadInRepeater)
        {
            Visible = false;
        }
    }
}