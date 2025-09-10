codeunit 50102 "Bfrei Poste API"
{

    Permissions = TableData "Service Shipment Header" = rm,
                  tabledata "Sales Shipment Header" = rm;


    procedure modifySalesShipmentHeader(var salesShipmentHeaderP: Record "Sales Shipment Header")
    var
        salesShptHeader: Record "Sales Shipment Header";
        oStreamL: OutStream;
        iStreamL: InStream;
    begin
        salesShptHeader := salesShipmentHeaderP;
        salesShptHeader.LockTable();
        salesShptHeader.Find();
        salesShptHeader."Shipping Agent Code" := salesShipmentHeaderP."Shipping Agent Code";
        salesShptHeader."Shipping Agent Service Code" := salesShipmentHeaderP."Shipping Agent Service Code";
        salesShptHeader."Package Tracking No." := salesShipmentHeaderP."Package Tracking No.";

        salesShipmentHeaderP.Label.CreateInStream(iStreamL);
        salesShptHeader.Label.CreateOutStream(oStreamL);
        CopyStream(oStreamL, iStreamL);

        OnBeforeSalesShptHeaderModify(salesShptHeader, salesShipmentHeaderP);
        salesShptHeader.TestField("No.", salesShipmentHeaderP."No.");
        salesShptHeader.Modify();
        salesShipmentHeaderP := salesShptHeader;

        OnRunOnAfterSalesShptHeaderEdit(salesShipmentHeaderP);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesShptHeaderModify(var SalesShptHeader: Record "Sales Shipment Header"; FromSalesShptHeader: Record "Sales Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterSalesShptHeaderEdit(var SalesShptHeader: Record "Sales Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeServiceShptHeaderModify(var SalesShptHeader: Record "Service Shipment Header"; FromServiceShptHeader: Record "Service Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterServiceShptHeaderEdit(var SalesShptHeader: Record "Service Shipment Header")
    begin
    end;



    procedure getBearerToken(var clientIdP: Text; var secretIdP: Text; scopeP: text): Text;
    var
        httpClientL: HttpClient;
        contentL: HttpContent;
        responseL: HttpResponseMessage;
        headerL: HttpHeaders;

        urlL: Text;
        paramL: Dictionary of [text, text];
        resultL: text;

        jsonResponseL: JsonObject;
        jsonTokenL: JsonToken;
        jsonValueL: JsonValue;

        tokenL: Text;

    begin
        resultL := '';
        tokenL := '';
        paramL.Add('grant_type', 'client_credentials');
        paramL.Add('client_id', clientIdP);
        paramL.Add('client_secret', secretIdP);
        paramL.Add('scope', scopeP);

        Clear(httpClientL);
        Clear(contentL);
        contentL.GetHeaders(headerL);
        headerL.Remove('content-type');
        headerL.Add('content-type', 'application/x-www-form-urlencoded');


        urlL := 'https://api.post.ch/OAuth/token' + addParameter(paramL);

        if httpClientL.Post(urlL, contentL, responseL) then begin

            if responseL.IsSuccessStatusCode then begin
                responseL.Content.ReadAs(ResultL);
                if resultL <> '' then begin
                    jsonResponseL.ReadFrom(resultL);

                    if jsonResponseL.get('access_token', jsonTokenL) then begin
                        if jsonTokenL.IsValue then begin
                            jsonValueL := jsonTokenL.AsValue();
                            tokenL := jsonValueL.AsText();
                        end;
                    end;
                end;
            end;
        end;
        exit(tokenL);
    end;


    local procedure addParameter(var paramP: Dictionary of [text, text]): text;
    var
        keyL: text;
        valueL: text;
        firstL: Boolean;
        sepL: text[1];
        queryStringL: TextBuilder;
    begin
        clear(queryStringL);
        firstL := true;
        foreach keyL in paramP.Keys do begin
            if paramP.Get(keyL, valueL) then begin

                if firstL then
                    sepL := '?'
                else
                    sepL := '&';

                queryStringL.Append(sepL + keyL + '=' + valueL);

            end;
            firstL := false;
        end;
        exit(queryStringL.ToText());
    end;

    local procedure generateAddressLabelJson(var recRefP: recordRef): Text
    var
        jsonBodyL: JsonObject;
        jsonCustomerL: JsonObject;
        jsonItemL: JsonObject;
        jsonLabelDefinitionL: JsonObject;
        jsonRecipientL: JsonObject;
        jsonAttributesL: JsonObject;
        jsonReturnInfoL: JsonObject;
        jsonPrzlL: JsonArray;
        jsonGeoL: jsonObject;
        jsonLogisticL: JsonObject;
        jsonHouseL: JsonObject;
        jsonZipL: JsonObject;
        jsonTextL: Text;
        jsonNullValue: JsonValue;

        fieldValuesL: Dictionary of [text, text];
        fieldRefL: FieldRef;
        i: Integer;
        companyInfoL: record "Company Information";
        shippingAgentL: record "Shipping Agent";
        shippingAgentCodeL: code[20];

        przLListL: List of [Text];
        pL: text;
        countryL: text;


    begin

        jsonNullValue.SetValueToNull();

        for i := 1 to recRefP.FieldCount do begin
            fieldRefL := recRefP.FieldIndex(i);
            case fieldRefL.Name of
                'Ship-to Name':
                    fieldValuesL.Add('name1', fieldRefL.Value);
                'Ship-to Address':
                    fieldValuesL.Add('street', fieldRefL.Value);
                'Ship-to Post Code':
                    fieldValuesL.Add('zip', fieldRefL.Value);
                'Ship-to City':
                    fieldValuesL.Add('city', fieldRefL.Value);
                'Ship-to Country/Region Code':
                    fieldValuesL.Add('country', fieldRefL.Value);
                'Shipping Agent Code':
                    shippingAgentCodeL := fieldRefL.Value;
            end;
        end;

        companyInfoL.Get();

        if (shippingAgentCodeL <> '') and shippingAgentL.get(shippingAgentCodeL) and (shippingAgentL."Franking Licence" <> '') then begin

            jsonCustomerL.add('name1', companyInfoL.Name);
            jsonCustomerL.add('street', companyInfoL.Address);
            jsonCustomerL.add('zip', companyInfoL."Post Code");
            jsonCustomerL.add('city', companyInfoL.City);
            jsonCustomerL.add('country', companyInfoL."Country/Region Code");
            jsonCustomerL.add('domicilePostOffice', companyInfoL."Post Code" + ' ' + companyInfoL.City);

            jsonLabelDefinitionL.add('labelLayout', shippingAgentL."Label Layout");
            jsonLabelDefinitionL.add('printAddresses', 'RECIPIENT_AND_CUSTOMER'); //'NONE');
            jsonLabelDefinitionL.add('imageFileType', 'PNG');
            jsonLabelDefinitionL.add('imageResolution', 300);
            //jsonLabelDefinitionL.add('colorPrintRequired', false);
            jsonLabelDefinitionL.add('printPreview', shippingAgentL.Test);


            jsonRecipientL.add('name1', fieldValuesL.Get('name1'));
            jsonRecipientL.add('street', fieldValuesL.Get('street'));
            jsonRecipientL.add('zip', fieldValuesL.Get('zip'));
            jsonRecipientL.add('city', fieldValuesL.Get('city'));
            countryL := fieldValuesL.Get('country');
            if countryL = '' then countryL := 'CH';
            jsonRecipientL.add('country', countryL);

            Clear(przLListL);
            clear(jsonPrzlL);

            przlListL := shippingAgentL.PrzL.Split(',');

            foreach pL in przlListL do begin
                if pl <> '' then
                    jsonPrzlL.Add(pL);
            end;


            jsonAttributesL.add('przl', jsonPrzlL);
            jsonAttributesL.add('deliveryDate', jsonNullValue);
            jsonAttributesL.Add('weight', 12);

            //jsonReturnInfoL.add('returnNote', false);
            //jsonReturnInfoL.add('instructionForReturns', false);
            //jsonReturnInfoL.add('returnService', jsonNullValue);
            //jsonReturnInfoL.add('customerIDReturnAddress', jsonNullValue);

            jsonItemL.Add('itemID', '000000000001');
            jsonItemL.Add('recipient', jsonRecipientL);
            jsonItemL.Add('attributes', jsonAttributesL);



            jsonBodyL.Add('language', 'FR');
            jsonBodyL.Add('frankingLicense', shippingAgentL."Franking Licence");
            jsonBodyL.Add('customer', jsonCustomerL);
            jsonBodyL.Add('customerSystem', jsonNullValue);
            jsonBodyL.Add('labelDefinition', jsonLabelDefinitionL);
            jsonBodyL.Add('item', jsonItemL);

            jsonBodyL.WriteTo(jsonTextL);

        end;

        exit(jsonTextL)

    end;

    local procedure getClientSecretFromRecRef(var recRefP: RecordRef): Dictionary of [text, text]
    var
        recRefDictionaryL: Dictionary of [text, text];
        shippingAgentL: record "Shipping Agent";
        i: Integer;
        fieldRefL: FieldRef;
        shippingAgentCodeL: code[20];
        identFieldNoL: Integer;
        labelFieldNoL: Integer;
    begin

        clear(recRefDictionaryL);

        for i := 1 to recRefP.FieldCount do begin
            fieldRefL := recRefP.FieldIndex(i);
            case fieldRefL.Name of
                'Shipping Agent Code':
                    shippingAgentCodeL := fieldRefL.Value;

                'Package Tracking No.':
                    identFieldNoL := i;

                'Label':
                    labelFieldNoL := i;

            end;
        end;

        if shippingAgentL.get(shippingAgentCodeL) then begin
            recRefDictionaryL.Add('clientId', shippingAgentL."Client ID");
            recRefDictionaryL.Add('secretId', shippingAgentL."Secret ID");
            recRefDictionaryL.Add('labelFieldNo', format(labelFieldNoL));
            recRefDictionaryL.Add('identFieldNo', Format(identFieldNoL));
        end;


        exit(recRefDictionaryL);

    end;

    local procedure validateTracking(var recRefP: RecordRef; image64P: text; identCodeP: text)
    var
        salesShipmentHeaderL: record "Sales Shipment Header";
        salesShipmentHeaderTL: record "Sales Shipment Header" temporary;
        serviceShipmentHeaderL: record "Service Shipment Header";
        serviceShipmentHeaderTL: record "Service Shipment Header" temporary;
        oStreamL: OutStream;
    begin

        if recRefP.Number = Database::"Sales Shipment Header" then begin
            recRefP.setTable(salesShipmentHeaderL);
            salesShipmentHeaderTL.Copy(salesShipmentHeaderL);
            salesShipmentHeaderTL.Label.CreateOutStream(oStreamL);
            oStreamL.Write(image64P);
            salesShipmentHeaderTL."Package Tracking No." := identCodeP;
            modifySalesShipmentHeader(salesShipmentHeaderTL);
        end;

    end;


    procedure addressValidation(var clientIdP: Text; var secretIdP: Text; var CustomerP: record Customer): Text;
    var
        tokenL: text;
        urlL: text;
        resultL: text;

        jsonTokenL: JsonToken;
        jsonTextL: Text;
        jsonResponseL: JsonObject;


        RequestL: HttpRequestMessage;
        requestHeadersL: HttpHeaders;
        ResponseL: HttpResponseMessage;
        ContentL: HttpContent;
        ContentHeadersL: HttpHeaders;
        ClientL: HttpClient;
        SuccessL: Boolean;

    begin
        tokenL := getBearerToken(clientIdP, secretIdP, 'DCAPI_ADDRESS_VALIDATE');

        jsonTextL := ''; //generateAddressJson();

        urlL := 'https://dcapi.apis.post.ch/address/v1/addresses/validation';

        ContentL.WriteFrom(jsonTextL);

        contentL.GetHeaders(ContentHeadersL);
        if ContentHeadersL.Contains('Content-Type') then ContentHeadersL.Remove('Content-Type');
        ContentHeadersL.Add('Content-Type', 'application/json');


        RequestL.SetRequestUri(urlL);
        RequestL.Method := 'POST';
        RequestL.GetHeaders(requestHeadersL);
        requestHeadersL.Add('Authorization', 'Bearer ' + tokenL);

        RequestL.Content := contentL;

        successL := ClientL.Send(RequestL, ResponseL);

        if SuccessL and ResponseL.IsSuccessStatusCode then begin
            ResponseL.Content.ReadAs(ResultL);
        end else
            Message(ResponseL.ReasonPhrase);
    end;


    internal procedure cropImage(var image64P: text)
    var
        clientL: HttpClient;
        urlL: text;
        contentL: HttpContent;
        contentHeadersL: HttpHeaders;
        requestL: HttpRequestMessage;
        successL: Boolean;
        ResponseL: HttpResponseMessage;
        ResultL: text;
    begin

        urlL := 'https://puidoux.erpservices.ch/ws/api/image/cropwhite';

        ContentL.WriteFrom(image64P);

        contentL.GetHeaders(ContentHeadersL);
        if ContentHeadersL.Contains('Content-Type') then ContentHeadersL.Remove('Content-Type');
        ContentHeadersL.Add('Content-Type', 'application/json');


        RequestL.SetRequestUri(urlL);
        RequestL.Method := 'GET';


        RequestL.Content := contentL;

        successL := ClientL.Send(RequestL, ResponseL);
        if successL then begin
            ResponseL.Content.ReadAs(ResultL);
            image64P := resultL;
        end;
    end;

    procedure generateAddressLabel(var recRefP: RecordRef): Text;
    var
        tokenL: text;
        urlL: text;
        resultL: text;

        jsonTokenL: JsonToken;
        jsonLabelTokenL: JsonToken;
        jsonIdentTokenL: JsonToken;
        jsonTextL: Text;
        jsonResponseL: JsonObject;
        jsonValueL: JsonValue;

        image64L: text;
        identCodeL: text;

        RequestL: HttpRequestMessage;
        requestHeadersL: HttpHeaders;
        ResponseL: HttpResponseMessage;
        ContentL: HttpContent;
        ContentHeadersL: HttpHeaders;
        ClientL: HttpClient;
        SuccessL: Boolean;

        clientIDL: text;
        secretIDL: Text;

        recRefDictionaryL: Dictionary of [text, text];

    begin

        recRefDictionaryL := getClientSecretFromRecRef(recRefP);

        if recRefDictionaryL.ContainsKey('clientId') then
            recRefDictionaryL.Get('clientId', clientIDL);

        if recRefDictionaryL.ContainsKey('secretId') then
            recRefDictionaryL.get('secretId', secretIDL);

        tokenL := getBearerToken(clientIDL, secretIDL, 'DCAPI_BARCODE_READ');

        jsonTextL := generateAddressLabelJson(recRefP);

        urlL := 'https://dcapi.apis.post.ch/barcode/v1/generateAddressLabel';

        ContentL.WriteFrom(jsonTextL);

        contentL.GetHeaders(ContentHeadersL);
        if ContentHeadersL.Contains('Content-Type') then ContentHeadersL.Remove('Content-Type');
        ContentHeadersL.Add('Content-Type', 'application/json');


        RequestL.SetRequestUri(urlL);
        RequestL.Method := 'POST';
        RequestL.GetHeaders(requestHeadersL);
        requestHeadersL.Add('Authorization', 'Bearer ' + tokenL);

        RequestL.Content := contentL;

        successL := ClientL.Send(RequestL, ResponseL);

        if SuccessL and ResponseL.IsSuccessStatusCode then begin
            ResponseL.Content.ReadAs(ResultL);

            if resultL <> '' then begin
                jsonResponseL.ReadFrom(resultL);

                if jsonResponseL.get('item', jsonTokenL) then begin
                    if jsonTokenL.AsObject().get('label', jsonLabelTokenL) then begin
                        jsonLabelTokenL.WriteTo(image64L);
                        image64L := image64L.Substring(3, strLen(image64L) - 4);
                        //cropImage(image64L);

                    end;
                    if jsonTokenL.AsObject().get('identCode', jsonIdentTokenL) then
                        if jsonIdentTokenL.IsValue then begin
                            jsonValueL := jsonIdentTokenL.AsValue();
                            identCodeL := jsonValueL.AsText();
                        end;
                end;

                if (image64L <> '') and (identCodeL <> '') then validateTracking(recRefP, image64L, identCodeL);

            end;


        end;
    end;

    /*
             "language": "FR",
    "frankingLicense": "60048724",
    "ppFranking": false,
    "customer": {
        "name1": "Muster AG",
        "name2": "Logistik",
        "street": "Musterstrasse 19",
        "zip": "8112",
        "city": "Otelfingen",
        "country": "CH",
        "logoRotation": 0,
        "domicilePostOffice": "8112 Otelfingen"
    },
    "customerSystem": null,
    "labelDefinition": {
        "labelLayout": "A6",
        "printAddresses": "RECIPIENT_AND_CUSTOMER",
        "imageFileType": "ZPL2",
        "imageResolution": 300,
        "printPreview": true
    },
    "item": {
        "itemID": "00000000001000727746",
        "recipient": {
            "title": "Frau",
            "name1": "Serena Muster",
            "street": "Teststrasse 11",
            "mailboxNo": null,
            "zip": "9000",
            "city": "St.Gallen",
            "country": "CH",
            "houseKey": "24",
            "email": "test@test.test"
        },
        "attributes": {
            "przl": [
                "PRI"
            ],
            "deliveryDate": null,
            "returnInfo": {
                "returnNote": false,
                "instructionForReturns": false,
                "returnService": null,
                "customerIDReturnAddress": null
            },
            "weight": 1
        }
    }

    */

    /*
        HttpClient httpClient = _clientFactory.CreateClient("Authentication");

    // Create query string with parameters
    var queryString = new StringBuilder();
    queryString.Append("?UN=").Append(Uri.EscapeDataString("aa"));
    queryString.Append("&AP=").Append(Uri.EscapeDataString("bb"));

    // Append query string to base URL
    string requestUrl = "/auth" + queryString;

    // Send GET request
    var response = await httpClient.GetAsync(requestUrl);
    */



    /*
            procedure callRestApiForBinary(queryP: text; var fileInStreamP: InStream; filenameP: text): text;
    var
        TempBlob: Codeunit "Temp Blob";
        PayloadOutStream: OutStream;
        PayLoadInStream: InStream;

        Client: HttpClient;
        Response: HttpResponseMessage;
        ContentL: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        RequestHeaders: HttpHeaders;


        Url: Text;
        resultL: text;

        mondaySetupL: record "ERPS MON Setup";

        mapL: text;

        successL: Boolean;
        HttpStatusCodeL: Integer;

        newLine: Text;
        CR: Char;
        LF: Char;

        itemL: record Item;
        TenantMedialL: record "Tenant Media";


    begin

        CR := 13;
        LF := 10;

        newLine := format(CR) + Format(LF);

        //queryL := 'mutation add_file($file: File!) {add_file_to_column (item_id: 7076890908, column_id:"fichier6__1" file: $file) {id}}';
        mapL := '{"image":"variables.file"}';



        resultL := '';


        if mondaySetupL.Get() then begin

            Url := mondaySetupL."API Url" + '/file';

            TempBlob.CreateOutStream(PayloadOutStream, TextEncoding::Windows);
            PayloadOutStream.WriteText('--123456' + newLine);
            PayloadOutStream.WriteText('Content-Disposition: form-data; name="query"' + newLine);
            PayloadOutStream.WriteText('Content-Type: application/json' + newLine);
            PayloadOutStream.WriteText(newLine);
            PayloadOutStream.WriteText(queryP + newLine);
            PayloadOutStream.WriteText(newLine);

            PayloadOutStream.WriteText('--123456' + newLine);
            PayloadOutStream.WriteText('Content-Disposition: form-data; name="map"' + newLine);
            PayloadOutStream.WriteText('Content-Type: application/json' + newLine);
            PayloadOutStream.WriteText(newLine);
            PayloadOutStream.WriteText(mapL + newLine);
            PayloadOutStream.WriteText(newLine);

            PayloadOutStream.WriteText('--123456' + newLine);
            PayloadOutStream.WriteText('Content-Disposition: form-data; name="image"; filename="' + filenameP + '"' + newLine);
            PayloadOutStream.WriteText('Content-Type: application/octet-stream' + newLine);
            payloadOutStream.WriteText('Content-Transfer-Encoding: binary' + newLine);
            PayloadOutStream.WriteText(newLine);
            System.CopyStream(PayloadOutStream, fileInStreamP);
            PayloadOutStream.WriteText(newLine);
            PayloadOutStream.WriteText('--123456--' + newLine);

            TempBlob.CreateInStream(PayLoadInStream, TextEncoding::Windows);
            ContentL.WriteFrom(PayloadInStream);


            // Get Content Headers
            contentL.GetHeaders(ContentHeaders);

            // update the content header information and define the boundary    
            if ContentHeaders.Contains('Content-Type') then ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'multipart/form-data; boundary="123456"');

            // Setup the URL
            request.SetRequestUri(url);

            // Setup the HTTP Verb
            request.Method := 'POST';

            // Add some request headers like:
            request.GetHeaders(RequestHeaders);
            requestHeaders.Add('Authorization', mondaySetupL."API Key");

            // Set the content
            request.Content := contentL;


            successL := client.Send(Request, Response);

            Response.Content().ReadAs(resultL);

            //successL := Client.Post(url, ContentL, Response);

            if not successL then begin
                // handle the error
                Message('Error Success');
            end;

            if not Response.IsSuccessStatusCode() then begin
                HttpStatusCodeL := response.HttpStatusCode();
                // handle the error (depending on the HTTP status code)
                Message('Response Status: ' + format(HttpStatusCodeL) + queryP);
            end;



        end;
        exit(resultL);
    end;



    */

}
