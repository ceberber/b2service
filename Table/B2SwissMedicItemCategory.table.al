table 50100 B2SwissMedicItemCategory
{
    Caption = 'B2SwissMedicItemCategory';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }

        field(2; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = ToBeClassified;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }

        field(20; "SwissMedic Category"; enum "B2Swissmedic Category")
        {
            Caption = 'SwissMedic Category';
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }

        key(SORTER; "Sort Order")
        {

        }
    }

}
