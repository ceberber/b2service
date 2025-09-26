tableextension 50107 "B2 Purchase Header Ext" extends "Purchase Header"
{
    fields
    {
        field(50103; "Last Send to PRO"; Date)
        {
            Caption = 'Last Sent to pro';
        }

        field(50104; "Send To PRO"; Boolean)
        {
            Caption = 'Send To PRO', Comment = 'FRS="Envoyer à PRO",DES="Send To PRO"';
        }
    }
}
