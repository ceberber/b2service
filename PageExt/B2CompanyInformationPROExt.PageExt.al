pageextension 50102 "B2 Company Information PRO Ext" extends "Company Information"
{
    layout
    {
        addlast(content)
        {
            group(Pro)
            {
                Caption = 'PRO';

                field("PRO Activity Zone"; rec."PRO Activity Zone")
                {
                    ApplicationArea = all;
                }

                field("PRO Location Code"; rec."PRO Location Code")
                {
                    ApplicationArea = all;
                }

                field("PRO Tiers Code"; rec."PRO Tiers Code")
                {
                    ApplicationArea = all;
                }

                field("PRO Activity Code"; rec."PRO Activity Code")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
