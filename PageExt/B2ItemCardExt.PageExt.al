pageextension 50100 B2ItemCardExt extends "Item Card"
{

    layout
    {
        addafter("No.")
        {
            field("EAN Code";  rec."EAN Code")
            {
                ApplicationArea = all;
            }
            field("Pharma Code"; rec."Pharma Code")
            {
                ApplicationArea = all;
            }

            field(" SwissMedic Item Category Code"; rec."SwissMedic Item Category Code")
            {
                ApplicationArea = all;
            }
        }
    }

}
