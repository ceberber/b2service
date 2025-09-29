pageextension 50101 "B2 Shipping Agents Ext" extends "Shipping Agents"
{
    layout
    {
        addlast(Control1)
        {
            field("Client ID"; rec."Client ID")
            {
                ApplicationArea = All;
                ToolTip = 'Client ID';
            }

            field("Secret ID"; rec."Secret ID")
            {
                ApplicationArea = All;
                ToolTip = 'Client ID';
                ExtendedDatatype = Masked;
            }

            field("Franking Licence"; rec."Franking Licence")
            {
                ApplicationArea = All;
                ToolTip = 'Franking Licence';
            }

            field(PrzL; rec.PrzL)
            {
                ApplicationArea = all;
                ToolTip = 'Product description (e.g. PRI, SEM)';
            }

            field("Label Layout"; rec."Label Layout")
            {
                ApplicationArea = All;
                ToolTip = 'Label layout (e.g. A6, A7)';
            }

            field("Test"; rec."Test")
            {
                ApplicationArea = All;
                ToolTip = 'Test';
            }

            field(BESO; rec.BESO)
            {

            }
        }
    }
}
