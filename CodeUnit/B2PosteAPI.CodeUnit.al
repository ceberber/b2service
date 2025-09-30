codeunit 50102 "B2 Poste API"
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

    local procedure generateAddressLabelJson(var recRefP: recordRef; parcelNo: integer): Text
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

        languageCodeL: text;

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
                'Language Code':
                    languageCodeL := fieldRefL.Value;
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

            jsonItemL.Add('itemID', Format(parcelNo));
            jsonItemL.Add('recipient', jsonRecipientL);
            jsonItemL.Add('attributes', jsonAttributesL);


            if (languageCodeL <> '') and (strLen(languageCodeL) > 2) then
                languageCodeL := languageCodeL.Substring(1, 2)
            else
                languageCodeL := 'FR';

            jsonBodyL.Add('language', languageCodeL);
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
        additionalPackageL: record "B2 Additional Package";
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

        if recRefP.Number = Database::"B2 Additional Package" then begin
            recRefP.setTable(additionalPackageL);
            clear(oStreamL);
            additionalPackageL.Label.CreateOutStream(oStreamL);
            oStreamL.Write(image64P);
            additionalPackageL."Package Tracking No." := identCodeP;
            additionalPackageL.Modify();
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
        resultL: text;
        ResponseL: HttpResponseMessage;

        image64L: text;
        identCodeL: text;

        SuccessL: Boolean;

        additionalPackageL: record "B2 Additional Package";
        recRefL: RecordRef;
        fieldRefL: FieldRef;

    begin

        successL := callApi(recRefP, 1, responseL);

        if SuccessL and ResponseL.IsSuccessStatusCode then begin
            ResponseL.Content.ReadAs(ResultL);
            if resultL <> '' then begin
                decodeAddressLabel(ResultL, identCodeL, image64L);
                if (image64L <> '') and (identCodeL <> '') then validateTracking(recRefP, image64L, identCodeL);
            end;
        end;


        fieldRefL := recRefP.Field(3);
        additionalPackageL.Reset();
        additionalPackageL.SetRange("Shipment Header No.", fieldRefL.Value);

        if additionalPackageL.FindSet() then
            repeat
                successL := callApi(recRefP, additionalPackageL."Line No." + 1, responseL);

                if SuccessL and ResponseL.IsSuccessStatusCode then begin
                    ResponseL.Content.ReadAs(ResultL);
                    if resultL <> '' then begin
                        recRefL.GetTable(additionalPackageL);
                        decodeAddressLabel(ResultL, identCodeL, image64L);
                        if (image64L <> '') and (identCodeL <> '') then validateTracking(recRefL, image64L, identCodeL);
                    end;
                end;
            until additionalPackageL.Next() = 0;
    end;

    local procedure callApi(var recRefP: RecordRef; parcelNoP: integer; var responseP: HttpResponseMessage): Boolean;
    var
        tokenL: text;
        jsonTextL: Text;
        urlL: text;
        RequestL: HttpRequestMessage;
        requestHeadersL: HttpHeaders;

        ContentL: HttpContent;
        ContentHeadersL: HttpHeaders;
        ClientL: HttpClient;
        recRefDictionaryL: Dictionary of [text, text];
        clientIDL: text;
        secretIDL: Text;
    begin
        recRefDictionaryL := getClientSecretFromRecRef(recRefP);

        if recRefDictionaryL.ContainsKey('clientId') then
            recRefDictionaryL.Get('clientId', clientIDL);

        if recRefDictionaryL.ContainsKey('secretId') then
            recRefDictionaryL.get('secretId', secretIDL);

        tokenL := getBearerToken(clientIDL, secretIDL, 'DCAPI_BARCODE_READ');

        jsonTextL := generateAddressLabelJson(recRefP, parcelNoP);

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

        Exit(ClientL.Send(RequestL, ResponseP));

    end;

    local procedure decodeAddressLabel(var resultP: text; var identCodeL: text; var image64P: text)
    var
        jsonResponseL: JsonObject;
        jsonValueL: JsonValue;
        jsonTokenL: JsonToken;
        jsonLabelTokenL: JsonToken;
        jsonIdentTokenL: JsonToken;
    begin
        if resultP <> '' then begin
            jsonResponseL.ReadFrom(resultP);

            if jsonResponseL.get('item', jsonTokenL) then begin
                if jsonTokenL.AsObject().get('label', jsonLabelTokenL) then begin
                    jsonLabelTokenL.WriteTo(image64P);
                    image64P := image64P.Substring(3, strLen(image64P) - 4);
                    //cropImage(image64L);

                end;
                if jsonTokenL.AsObject().get('identCode', jsonIdentTokenL) then
                    if jsonIdentTokenL.IsValue then begin
                        jsonValueL := jsonIdentTokenL.AsValue();
                        identCodeL := jsonValueL.AsText();
                    end;
            end;

        end;
    end;




}
