page 50104 "B2 Additional Package List"
{
    ApplicationArea = All;
    Caption = 'B2 Additional Package List';
    PageType = List;
    SourceTable = "B2 Additional Package";
    InsertAllowed = false;
    DeleteAllowed = true;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Shipping Agent Code"; rec."Shipping Agent Code")
                {
                    Editable = false;

                }
                field("Package Tracking No."; Rec."Package Tracking No.")
                {
                    ToolTip = 'Specifies the value of the Package Tracking No. field.', Comment = '%';
                }
            }
        }
    }
}
