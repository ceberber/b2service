tableextension 50101 "B2 Sales Shipment Header Ext" extends "Sales Shipment Header"
{
    fields
    {

        field(50100; "Label"; Blob)
        {
            Caption = 'Label';
            DataClassification = ToBeClassified;
        }

        field(50101; "Additional Package"; integer)
        {
            caption = 'Additional Package';
            FieldClass = FlowField;
            CalcFormula = count("B2 Additional Package" where("Shipment Header No." = field("No.")));

        }

    }
}
