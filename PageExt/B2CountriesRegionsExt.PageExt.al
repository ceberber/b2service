pageextension 50103 "B2 Countries/Regions Ext" extends "Countries/Regions"
{
    layout
    {
        addlast(Control1)
        {
            field("ISO 3 Code "; rec."ISO 3 Code ")
            {
                ApplicationArea = all;
            }
        }
    }
}
