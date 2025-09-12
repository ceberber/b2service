tableextension 50103 "B2 Company Info Pro Ext" extends "Company Information"
{
    fields
    {
        field(50100; "PRO Activity Zone"; Text[5])
        {
            Caption = 'Activity Zone';
            DataClassification = ToBeClassified;
        }
        field(50101; "PRO Location Code"; Text[15])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
        }
        field(50102; "PRO Tiers Code"; Text[15])
        {
            Caption = 'Tiers Code';
            DataClassification = ToBeClassified;
        }
        field(50103; "PRO Activity Code"; Text[15])
        {
            Caption = 'Activity Code';
            DataClassification = ToBeClassified;
        }
    }
}
