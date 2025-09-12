tableextension 50102 "B2 Shipping Agent Ext" extends "Shipping Agent"
{
    fields
    {
        field(50100; "Client ID"; Text[50])
        {
            Caption = 'Client ID';
            DataClassification = ToBeClassified;
        }
        field(50101; "Secret ID"; Text[50])
        {
            Caption = 'Secret ID';
            DataClassification = ToBeClassified;
        }
        field(50102; "Franking Licence"; Text[50])
        {
            Caption = 'Franking Licence';
            DataClassification = ToBeClassified;
        }
        field(50103; Test; Boolean)
        {
            Caption = 'Test';
            DataClassification = ToBeClassified;
        }

        field(50104; PrzL; Text[50])
        {
            Caption = 'PrzL Product description';
            ToolTip = 'Product description (e.g. PRI, SEM)';
        }
        field(50105; "Label Layout"; text[20])
        {
            Caption = 'Label Layout';
            ToolTip = 'Label layout (e.g. A6, A7)';
            InitValue = 'A7';
        }
    }
}
