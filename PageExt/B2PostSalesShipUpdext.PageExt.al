pageextension 50106 "B2 Post. Sales Ship - Upd. ext" extends "Posted Sales Shipment - Update"
{
    layout
    {
        addafter("Package Tracking No.")
        {
            field("Additional Package"; rec."Additional Package")
            {
                ApplicationArea = all;
            }
        }
    }
}
