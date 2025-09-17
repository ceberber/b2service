tableextension 50104 "B2 Country Region Ext" extends "Country/Region"
{
    fields
    {
        field(50100; "ISO 3 Code"; Code[3])
        {
            Caption = 'ISO 3 Code';
            DataClassification = ToBeClassified;
        }
    }
}
