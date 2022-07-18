/// <summary>
/// Page B2SwissMedic Item Category (ID 50100).
/// </summary>
page 50100 "B2SwissMedic Item Category"
{

    ApplicationArea = All;
    Caption = 'SwissMedic Item Category';
    PageType = List;
    SourceTable = B2SwissMedicItemCategory;
    UsageCategory = Administration;
    SourceTableView = sorting("Sort Order");

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("SwissMedic Category"; rec."SwissMedic Category")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
