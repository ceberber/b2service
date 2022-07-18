page 50101 "B2 Text List"
{

    ApplicationArea = All;
    Caption = 'Condition Text List';
    PageType = List;
    SourceTable = "B2 Text";
    UsageCategory = Lists;
    CardPageID = "B2 Text Card";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(code; Rec.code)
                {
                    ApplicationArea = All;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                }
                field(Text; DescriptionG)
                {
                    ApplicationArea = All;
                    MultiLine = false;

                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        descriptionG := CopyStr(rec.GetDescription(), 1, 50);

    end;

    var
        descriptionG: text;

}
