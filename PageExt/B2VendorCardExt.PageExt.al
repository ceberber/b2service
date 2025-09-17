pageextension 50104 "B2 Vendor Card Ext" extends "Vendor Card"
{
    layout
    {

        addlast(General)
        {
            field("Send To PRO"; rec."Send To PRO")
            {
                ApplicationArea = all;
            }
        }
    }
}
