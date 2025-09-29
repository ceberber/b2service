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

        contentFileL: TextBuilder;

        companyInformationL: record "Company Information";
    begin

        lineNoL := 0;

        companyInformationL.get();

        filenameL := companyInformationL.Name + '_item_' + Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>') + '.art';


        if itemCsvBufferL.IsTemporary() then itemCsvBufferL.DeleteAll();

        ProInterfaceL.createHeaderCSV(lineNoL, itemCsvBufferL);

        contentFileL.Append(getCsvBufferText(itemCsvBufferL, true));

        itemL.Reset();
        itemL.SetRange("Send To PRO", true);
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

        contentFileL.Append(getCsvBufferText(itemCsvBufferL, true));

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
            outStreamCSVL.Write(contentFileL.ToText());

            if sendFileToFTP(filenameL, outStreamCSVL) then begin
                interfaceJournalL."Found On FTP" := true;
                interfaceJournalL.Insert(true);
                Commit()
            end else
                Error('Problème d''envoie sur FTP!');

        end;
    end;


    procedure sendSalesOrder()
    var
        SalesHeaderL: record "Sales Header";
        SalesLineL: Record "Sales Line";
        reservationL: Record "Reservation Entry";
        salesOrderCsvBufferL: record "CSV Buffer" temporary;
        ProInterfaceL: Codeunit "B2 Pro Interface";
        filenameL: text;
        interfaceJournalL: record "B2 Interface Journal";
        outStreamCSVL: OutStream;
        inStreamCSVL: InStream;
        modifyL: Boolean;
        lineNoL: integer;
        companyInformationL: record "Company Information";
        contentFileL: TextBuilder;
        lotsL: Dictionary of [Code[50], Decimal];
        lotL: Code[50];
        QuantityL: Decimal;
        lotLineL: integer;
    begin

        companyInformationL.get();

        SalesHeaderL.Reset();
        SalesHeaderL.SetRange("Document Type", SalesHeaderL."Document Type"::Order);
        SalesHeaderL.SetRange(Status, SalesHeaderL.Status::Released);
        if SalesHeaderL.FindSet() then
            repeat


                if (SalesHeaderL."Last Send to PRO" = 0D) or (Dt2Date(SalesHeaderL.SystemModifiedAt) > SalesHeaderL."Last Send to PRO") then begin

                    lineNoL := 1;

                    filenameL := companyInformationL.Name + '_SHIP_' + SalesHeaderL."No." + '_' + Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>') + '.liv';

                    if salesOrderCsvBufferL.IsTemporary() then salesOrderCsvBufferL.DeleteAll();

                    ProInterfaceL.createHeaderCSV(lineNoL, salesOrderCsvBufferL);
                    contentFileL.Append(getCsvBufferText(salesOrderCsvBufferL, true));

                    lineNoL += 1;
                    ProInterfaceL.CreateSalesShipmentHeaderCSV(SalesHeaderL, lineNoL, false, salesOrderCsvBufferL);
                    contentFileL.Append(getCsvBufferText(salesOrderCsvBufferL, true));

                    SalesLineL.Reset();
                    SalesLineL.SetRange("Document Type", SalesHeaderL."Document Type");
                    SalesLineL.SetRange("Document No.", SalesHeaderL."No.");
                    SalesLineL.SetRange(Type, SalesLineL.Type::Item);
                    if SalesLineL.FindSet() then
                        repeat
                            reservationL.Reset();
                            reservationL.SetRange("Source ID", SalesLineL."Document No.");
                            reservationL.SetRange("Source Ref. No.", SalesLineL."Line No.");
                            reservationL.SetRange("Reservation Status", reservationL."Reservation Status"::Surplus);
                            if reservationL.FindSet() then begin
                                repeat
                                    if lotsL.ContainsKey(reservationL."Lot No.") then begin
                                        if lotsL.Get(reservationL."Lot No.", QuantityL) then
                                            lotsL.Set(reservationL."Lot No.", QuantityL + (-reservationL.Quantity));

                                    end else
                                        lotsL.Add(reservationL."Lot No.", -reservationL.Quantity)

                                until reservationL.Next() = 0;
                                lotLineL := 0;
                                foreach lotL in lotsL.Keys do begin
                                    if lotsL.Get(lotL, quantityL) then begin
                                        lineNoL += 1;
                                        lotLineL += 1;
                                        ProInterfaceL.CreateSalesShipmentLineCSV(SalesLineL, QuantityL, lotL, '.' + format(lotLineL), lineNoL, SalesHeaderL."Send To PRO", salesOrderCsvBufferL);
                                    end;
                                end;

                            end else begin
                                lineNoL += 1;
                                ProInterfaceL.CreateSalesShipmentLineCSV(SalesLineL, SalesLineL.Quantity, '', '', lineNoL, SalesHeaderL."Send To PRO", salesOrderCsvBufferL);
                            end;


                        until SalesLineL.Next() = 0;

                    contentFileL.Append(getCsvBufferText(salesOrderCsvBufferL, true));


                    if lineNoL > 1 then begin

                        SalesHeaderL."Last Send to PRO" := WorkDate();
                        SalesHeaderL."Send To PRO" := true;
                        SalesHeaderL.Modify();

                        clear(outStreamCSVL);

                        interfaceJournalL.Init();
                        interfaceJournalL."Action Date Time" := CurrentDateTime();
                        interfaceJournalL."Action type" := interfaceJournalL."Action type"::Shipment;
                        interfaceJournalL."Sub Action Type" := interfaceJournalL."Sub Action Type"::Create;
                        interfaceJournalL.Filename := filenameL;

                        interfaceJournalL."CSV".CreateOutStream(outStreamCSVL, TextEncoding::UTF8);
                        outStreamCSVL.Write(contentFileL.ToText());

                        if sendFileToFTP(filenameL, outStreamCSVL) then begin
                            interfaceJournalL."Found On FTP" := true;
                            interfaceJournalL.Insert(true);
                            Commit();

                        end else
                            Error('Problème d''envoie sur FTP!');

                    end;
                end;

            until SalesHeaderL.Next() = 0;
    end;

    procedure sendVendors()
    var
        vendorCsvBufferL: record "CSV Buffer" temporary;
        vendorL: record Vendor;
        ProInterfaceL: Codeunit "B2 Pro Interface";
        filenameL: text;
        interfaceJournalL: record "B2 Interface Journal";
        outStreamCSVL: OutStream;
        inStreamCSVL: InStream;

        modifyL: Boolean;
        lineNoL: integer;


        companyInformationL: record "Company Information";

        contentFileL: TextBuilder;
    begin

        lineNoL := 1;

        companyInformationL.get();

        filenameL := companyInformationL.Name + '_VEND_' + Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>') + '.four';

        if vendorCsvBufferL.IsTemporary() then vendorCsvBufferL.DeleteAll();

        ProInterfaceL.createHeaderCSV(lineNoL, vendorCsvBufferL);

        contentFileL.Append(getCsvBufferText(vendorCsvBufferL, true));

        vendorL.Reset();
        vendorL.SetRange("Send To PRO", true);
        if vendorL.FindSet() then
            repeat
                if (vendorL."Last Send to PRO" = 0D) or (vendorL."Last Date Modified" > vendorL."Last Send to PRO") then begin
                    lineNoL += 1;
                    modifyL := vendorL."Last Send to PRO" <> 0D;
                    ProInterfaceL.CreateVendorCSV(vendorL, lineNoL, modifyL, vendorCsvBufferL);
                    vendorL."Last Send to PRO" := Today();
                    vendorL.Modify();
                end;
            until vendorL.Next() = 0;

        if lineNoL > 1 then begin

            clear(outStreamCSVL);

            contentFileL.Append(getCsvBufferText(vendorCsvBufferL, true));



            interfaceJournalL.Init();
            interfaceJournalL."Action Date Time" := CurrentDateTime();
            interfaceJournalL."Action type" := interfaceJournalL."Action type"::Vendor;
            interfaceJournalL."Sub Action Type" := interfaceJournalL."Sub Action Type"::Create;
            interfaceJournalL.Filename := filenameL;

            interfaceJournalL."CSV".CreateOutStream(outStreamCSVL, TextEncoding::UTF8);
            outStreamCSVL.Write(contentFileL.ToText());



            if sendFileToFTP(filenameL, outStreamCSVL) then begin
                interfaceJournalL."Found On FTP" := true;
                interfaceJournalL.Insert(true);
                Commit();

            end else
                Error('Problème d''envoie sur FTP!');

        end;
    end;


    procedure sendPurchOrder()
    var
        PurchHeaderL: record "Purchase Header";
        PurchLineL: Record "Purchase Line";
        reservationL: Record "Reservation Entry";
        purchaseOrderCsvBufferL: record "CSV Buffer" temporary;
        ProInterfaceL: Codeunit "B2 Pro Interface";
        filenameL: text;
        interfaceJournalL: record "B2 Interface Journal";
        outStreamCSVL: OutStream;
        inStreamCSVL: InStream;
        modifyL: Boolean;
        lineNoL: integer;
        companyInformationL: record "Company Information";
        contentFileL: TextBuilder;
        lotsL: Dictionary of [Code[50], Decimal];
        dtExpsL: Dictionary of [Code[50], Date];
        lotL: Code[50];
        dateExpL: date;
        QuantityL: Decimal;
        lotLineL: integer;
    begin

        companyInformationL.get();

        PurchHeaderL.Reset();
        PurchHeaderL.SetRange("Document Type", PurchHeaderL."Document Type"::Order);
        PurchHeaderL.SetRange(Status, PurchHeaderL.Status::Released);
        PurchHeaderL.SetRange("Expected Receipt Date", WorkDate());

        if PurchHeaderL.FindSet() then
            Repeat

                if (PurchHeaderL."Last Send to PRO" = 0D) or (Dt2Date(PurchHeaderL.SystemModifiedAt) > PurchHeaderL."Last Send to PRO") then begin


                    lineNoL := 1;

                    filenameL := companyInformationL.Name + '_RECPT_' + PurchHeaderL."No." + '_' + Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>') + '.rec';

                    if purchaseOrderCsvBufferL.IsTemporary() then purchaseOrderCsvBufferL.DeleteAll();

                    ProInterfaceL.createHeaderCSV(lineNoL, purchaseOrderCsvBufferL);
                    contentFileL.Append(getCsvBufferText(purchaseOrderCsvBufferL, true));


                    lineNoL += 1;
                    ProInterfaceL.createPurchReceiptHeaderCSV(PurchHeaderL, lineNoL, false, purchaseOrderCsvBufferL);
                    contentFileL.Append(getCsvBufferText(purchaseOrderCsvBufferL, true));

                    PurchLineL.Reset();
                    PurchLineL.SetRange("Document Type", PurchHeaderL."Document Type");
                    PurchLineL.SetRange("Document No.", PurchHeaderL."No.");
                    PurchLineL.SetRange(Type, PurchLineL.Type::Item);
                    if PurchLineL.FindSet() then
                        repeat
                            reservationL.Reset();
                            reservationL.SetRange("Source ID", PurchLineL."Document No.");
                            reservationL.SetRange("Source Ref. No.", PurchLineL."Line No.");
                            reservationL.SetRange("Reservation Status", reservationL."Reservation Status"::Surplus);
                            if reservationL.FindSet() then begin
                                repeat
                                    if lotsL.ContainsKey(reservationL."Lot No.") then begin
                                        if lotsL.Get(reservationL."Lot No.", QuantityL) then
                                            lotsL.Set(reservationL."Lot No.", QuantityL + (-reservationL.Quantity));

                                    end else begin
                                        lotsL.Add(reservationL."Lot No.", -reservationL.Quantity);
                                        dtExpsL.Add(reservationL."Lot No.", reservationL."Expiration Date");
                                    end;

                                until reservationL.Next() = 0;
                                lotLineL := 0;
                                foreach lotL in lotsL.Keys do begin
                                    if lotsL.Get(lotL, quantityL) and dtExpsL.get(LotL, dateExpL) then begin
                                        lineNoL += 1;
                                        lotLineL += 1;
                                        ProInterfaceL.createPurchReceiptLineCSV(PurchLineL, QuantityL, lotL, '.' + format(lotLineL), dateExpL, lineNoL, PurchHeaderL."Send To PRO", purchaseOrderCsvBufferL);
                                    end;
                                end;

                            end else begin
                                lineNoL += 1;
                                ProInterfaceL.createPurchReceiptLineCSV(PurchLineL, PurchLineL.Quantity, '', '', 0D, lineNoL, PurchHeaderL."Send To PRO", purchaseOrderCsvBufferL);
                            end;


                        until PurchLineL.Next() = 0;

                    contentFileL.Append(getCsvBufferText(purchaseOrderCsvBufferL, true));


                    if lineNoL > 1 then begin

                        PurchHeaderL."Last Send to PRO" := WorkDate();
                        PurchHeaderL."Send To PRO" := true;
                        PurchHeaderL.Modify();

                        clear(outStreamCSVL);

                        interfaceJournalL.Init();
                        interfaceJournalL."Action Date Time" := CurrentDateTime();
                        interfaceJournalL."Action type" := interfaceJournalL."Action type"::Receipt;
                        interfaceJournalL."Sub Action Type" := interfaceJournalL."Sub Action Type"::Create;
                        interfaceJournalL.Filename := filenameL;

                        interfaceJournalL."CSV".CreateOutStream(outStreamCSVL, TextEncoding::UTF8);
                        outStreamCSVL.Write(contentFileL.ToText());



                        if sendFileToFTP(filenameL, outStreamCSVL) then begin
                            interfaceJournalL."Found On FTP" := true;
                            interfaceJournalL.Insert(true);
                            Commit();

                        end else
                            Error('Problème d''envoie sur FTP!');

                    end;
                end;
            until PurchHeaderL.Next() = 0;
    end;


    procedure sendFileToFtp(fileNameP: text; var
                                                 outStreamP: OutStream): Boolean
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

    procedure downloadCSV()
    var
        inStreamCSVL: InStream;
    begin
        if rec.CSV.HasValue then begin
            rec.CSV.CreateInStream(inStreamCSVL, TextEncoding::UTF8);
            DownloadFromStream(inStreamCSVL, 'CSV', '', '', rec.Filename);
        end;

    end;

    local procedure getCsvBufferText(var csvBufferP: record "CSV Buffer"; clearBuffer: Boolean): Text
    var
        tempBlobL: Codeunit "Temp Blob";
        csvInStreamL: InStream;
        linesL: text;
    begin
        linesL := '';
        csvBufferP.Reset();
        csvBufferP.SaveDataToBlob(tempBlobL, ';');

        tempBlobL.CreateInStream(csvInStreamL, TextEncoding::UTF8);
        csvInStreamL.Read(linesL);

        if clearBuffer then csvBufferP.DeleteAll();
        exit(linesL);
    end;
}
