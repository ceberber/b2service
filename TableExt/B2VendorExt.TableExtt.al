tableextension 50105 "B2 Vendor Ext" extends Vendor
{
    fields
    {
        field(50100; "Last Send to PRO"; Date)
        {
            Caption = 'Last Send To PRO';
            DataClassification = ToBeClassified;
        }
    }
}
