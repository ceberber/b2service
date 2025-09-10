table 50102 "B2 Interface Journal"
{
    Caption = 'B2 Interface Journal';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Action Date Time"; DateTime)
        {
            Caption = 'Action Date Time';
        }
        field(20; "Action type"; Enum "B2 Interface Action")
        {
            Caption = 'Action type';
        }

        field(21; "Sub Action Type"; Enum "B2 Interface Sub Action")
        {
            Caption = 'Sub Action Type';
        }


        field(30; "Filename"; text[50])
        {
            Caption = 'File name';
        }

        field(31; "CSV"; Blob)
        {
            Caption = 'CSV ';
        }
        field(40; "Found On FTP"; Boolean)
        {
            Caption = 'Found On FTP';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }


    procedure sendItems()
    var
        itemCsvBufferL: record "CSV Buffer" temporary;
        itemL: record Item;
        ProInterfaceL: Codeunit "B2 Pro Interface";
        filenameL: text;
        interfaceJournalL: record "B2 Interface Journal";
        csvBlobL: codeUnit "Temp Blob";
        outStreamCSVL: OutStream;
        inStreamCSVL: InStream;


        modifyL: Boolean;
        lineNoL: integer;


        companyInformationL: record "Company Information";
    begin

        lineNoL := 0;

        companyInformationL.get();

        filenameL := companyInformationL.Name + '_item_' + Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>') + '.art';


        if itemCsvBufferL.IsTemporary() then itemCsvBufferL.DeleteAll();

        ProInterfaceL.createHeaderItemCSV(lineNoL, itemCsvBufferL, 'Identifiant Propriétaire');

        itemL.Reset();
        if itemL.FindSet() then
            repeat
                if (itemL."Last Send to PRO" = 0D) or (itemL."Last Date Modified" > itemL."Last Send to PRO") then begin
                    lineNoL += 1;
                    modifyL := itemL."Last Send to PRO" <> 0D;
                    ProInterfaceL.CreateItemCSV(itemL, lineNoL, modifyL, itemCsvBufferL);
                    itemL."Last Send to PRO" := Today();
                    itemL.Modify();
                end;
            until itemL.Next() = 0;

        if lineNoL > 1 then begin

            clear(csvBlobL);
            clear(inStreamCSVL);
            clear(outStreamCSVL);

            itemCsvBufferL.SaveDataToBlob(csvBlobL, ';');
            csvBlobL.CreateInStream(inStreamCSVL, TextEncoding::UTF8);

            interfaceJournalL.Init();
            interfaceJournalL."Action Date Time" := CurrentDateTime();
            interfaceJournalL."Action type" := interfaceJournalL."Action type"::Item;
            interfaceJournalL."Sub Action Type" := interfaceJournalL."Sub Action Type"::Create;
            interfaceJournalL.Filename := filenameL;
            interfaceJournalL."CSV".CreateOutStream(outStreamCSVL, TextEncoding::UTF8);
            CopyStream(outStreamCSVL, inStreamCSVL);


            if sendFileToFTP(filenameL, outStreamCSVL) then begin
                interfaceJournalL."Found On FTP" := true;
                interfaceJournalL.Insert(true);
                Commit()
            end else
                Error('Problème d''envoie sur FTP!');

        end;
    end;


    procedure sendFileToFtp(fileNameP: text; var outStreamP: OutStream): Boolean
    begin
        exit(checkFileOnFtp(filenameP))
    end;

    procedure checkFileOnFtp(filename: text): Boolean
    begin
        Exit(true);
    end;



    procedure showCSV()
    var
        fileL: text;
        csvInStreamL: InStream;
    begin
        if rec.CSV.HasValue then begin
            rec.CSV.CreateInStream(csvInStreamL);
            csvInStreamL.Read(fileL);
        end else
            fileL := 'Pas de fichier';
        Message(fileL);
    end;
}
