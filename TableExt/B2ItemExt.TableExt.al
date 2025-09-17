tableextension 50100 B2ItemExt extends Item
{
    fields
    {
        field(50100; "EAN Code"; Code[20])
        {
            Caption = 'EAN Code';
            DataClassification = ToBeClassified;
        }

        field(50101; "Pharma Code"; Code[20])
        {
            Caption = 'Pharma Code';
            DataClassification = ToBeClassified;
        }

        field(50102; "SwissMedic Item Category Code"; code[20])
        {
            Caption = 'SwissMedic Item Category Code';
            DataClassification = ToBeClassified;
            TableRelation = B2SwissMedicItemCategory;
            ValidateTableRelation = true;
        }

        field(50103; "Last Send to PRO"; Date)
        {
            Caption = 'Last Sent to pro';
        }

        field(50104; "Send To PRO"; Boolean)
        {
            Caption = 'Send To PRO', Comment = 'FRS="Envoyer à PRO",DES="Send To PRO"';
        }

        field(50105; "Hide Date Exp"; Boolean)
        {
            Caption = 'Hide date exp', Comment = 'FRS="Cacher la date exp."';
            ToolTip = 'Hide date exp. on Sales Shipment Report', Comment = 'FRS="Cacher la date exp. sur l''impression des BL"';
        }
    }
}
