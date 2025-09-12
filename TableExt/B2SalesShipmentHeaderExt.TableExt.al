tableextension 50101 "B2 Sales Shipment Header Ext" extends "Sales Shipment Header"
{
    fields
    {

        field(50100; "Label"; Blob)
        {
            Caption = 'Label';
            DataClassification = ToBeClassified;
        }

    }
}
