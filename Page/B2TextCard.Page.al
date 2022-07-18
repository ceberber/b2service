page 50102 "B2 Text Card"
{

    Caption = 'Condition Text Card';
    PageType = Card;
    SourceTable = "B2 Text";
    DataCaptionFields = Code, "Language Code";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(code; Rec.code)
                {
                    ApplicationArea = All;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                }

            }

            group("Work Description")
            {
                Caption = 'Work Description';
                field(WorkDescription; descriptionG)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                    Width = 500;
                    ToolTip = 'Specifies the products or service being offered.';

                    trigger OnValidate()
                    begin
                        rec.SetDescription(descriptionG);
                    end;
                }
            }
        }

    }

    trigger OnAfterGetRecord()
    begin

        descriptionG := rec.GetDescription();

    end;

    var

        descriptionG: Text;
}
