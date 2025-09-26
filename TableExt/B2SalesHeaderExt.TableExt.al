tableextension 50106 "B2 Sales Header Ext" extends "Sales Header"
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
