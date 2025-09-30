table 50103 "B2 Additional Package"
{
    Caption = 'B2 Additional Package';
    DataClassification = ToBeClassified;
    LookupPageId = "B2 Additional Package List";
    DrillDownPageId = "B2 Additional Package List";

    fields
    {
        field(1; "Shipment Header No."; Code[20])
        {
            Caption = 'Shipment Header No. ';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; "Shipping Agent Code"; code[10])
        {
            Caption = 'Shipping Agent Code';
        }

        field(10; "Package Tracking No."; Text[50])
        {
            Caption = 'Package Tracking No.';
        }

        field(20; "Label"; Blob)
        {
            Caption = 'Label';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Shipment Header No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
