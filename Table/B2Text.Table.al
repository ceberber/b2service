table 50101 "B2 Text"
{
    Caption = 'B2 Text';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; code; Code[20])
        {
            Caption = 'code';
            NotBlank = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            NotBlank = true;
            TableRelation = Language;
        }

        field(10; Description; Blob)
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; code, "Language Code")
        {
            Clustered = true;
        }
    }


    procedure SetDescription(NewDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear(rec.Description);
        rec.Description.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewDescription);
        Modify;
    end;

    procedure GetDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        rec.CalcFields("Description");
        rec.Description.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
    end;

}
