codeunit 50100 "B2S Management"
{

    procedure generateSalesOrder(var customerP: record Customer; documentDateP: date; shipmentDateP: date; var salesItems: Dictionary of [Code[20], Decimal])
    var
        salesOrderL: record "Sales Header";
        salesLineL: record "Sales Line";
        itemsL: List of [code[20]];
        itemL: code[20];
        lineNoL: Integer;
        releaseSalesDocL: Codeunit "Release Sales Document";
    begin
        salesOrderL.Init();
        salesOrderL."Document Type" := salesOrderL."Document Type"::Order;
        salesOrderL."No." := '';
        salesOrderL.Validate("Sell-to Customer No.", customerP."No.");
        if salesOrderL.Insert(true) then begin
            if documentDateP <> 0D then
                salesOrderL.Validate("Document Date", documentDateP);
            if shipmentDateP <> 0D then begin
                salesOrderL.Validate("Shipment Date", shipmentDateP);
                salesOrderL.Validate("Posting Date", shipmentDateP);
            end;

            itemsL := salesItems.Keys();
            foreach itemL in itemsL do begin
                salesLineL.Init();
                salesLineL."Document Type" := salesOrderL."Document Type";
                salesLineL."Document No." := salesOrderL."No.";
                lineNoL += 10000;
                salesLineL."Line No." := lineNoL;
                salesLineL.Type := salesLineL.Type::Item;
                salesLineL.Validate("No.", itemL);
                salesLineL.Validate(Quantity, salesItems.Get(itemL));
                salesLineL.Insert(true);
            end;
            attributeLotNo(salesOrderL);
            salesOrderL.PerformManualRelease();

            Message('Sales Order Created');
        end;
    end;

    procedure generateWarehouseShipment(var locationLP: record Location; shipmentDateP: date): record "Warehouse Shipment Header";
    var
        warehouseShipmentHeaderL: record "Warehouse Shipment Header";
    begin
        warehouseShipmentHeaderL.Init();
        warehouseShipmentHeaderL."No." := '';
        warehouseShipmentHeaderL.Validate("Location Code", locationLP.Code);
        if shipmentDateP <> 0D then
            warehouseShipmentHeaderL.Validate("Shipment Date", shipmentDateP);
        warehouseShipmentHeaderL.Insert(true);
        addSalesOrderToWareHouseShipment(warehouseShipmentHeaderL);
        exit(warehouseShipmentHeaderL);
    end;

    internal procedure addSalesOrderToWareHouseShipment(var warehouseShipmentHeaderP: record "Warehouse Shipment Header")
    var
        warehouseRequestL: record "Warehouse Request";
        getSourceDocumentsL: report "Get Source Documents";
        ReleaseWhseShptDocL: Codeunit "Whse.-Shipment Release";
    begin

        warehouseRequestL.Reset();
        warehouseRequestL.SetRange(Type, warehouseRequestL.Type::Outbound);
        warehouseRequestL.SetRange("Location Code", warehouseShipmentHeaderP."Location Code");
        warehouseRequestL.SetRange("Document Status", warehouseRequestL."Document Status"::Released);
        warehouseRequestL.SetRange("Completely Handled", false);


        GetSourceDocumentsL.SetOneCreatedShptHeader(WarehouseShipmentHeaderP);
        GetSourceDocumentsL.SetSkipBlocked(true);
        GetSourceDocumentsL.UseRequestPage(false);
        GetSourceDocumentsL.SetTableView(WarehouseRequestL);
        GetSourceDocumentsL.RunModal();


        if warehouseShipmentHeaderP.Status = warehouseShipmentHeaderP.Status::Open then
            ReleaseWhseShptDocL.Release(warehouseShipmentHeaderP);


    end;

    internal procedure attributeLotNo(var SalesOrderP: record "Sales Header")
    var
        salesLineL: record "Sales Line";
        reservationEntryL: record "Reservation Entry";
        itemLedgerEntryL: record "Item Ledger Entry";
        QuantityReservedL: Decimal;
        foundL: Boolean;
        remainingQtyL: decimal;
        remainingQtyBaseL: decimal;
    begin
        salesLineL.Reset();
        salesLineL.SetRange("Document Type", SalesOrderP."Document Type");
        salesLineL.SetRange("Document No.", SalesOrderP."No.");
        if salesLineL.FindSet() then
            repeat

                reservationEntryL.Reset();
                reservationEntryL.SetRange("Item No.", salesLineL."No.");
                reservationEntryL.SetRange("Source Type", 37);
                reservationEntryL.SetRange("Source Subtype", SalesOrderP."Document Type");
                reservationEntryL.SetRange("Location Code", salesLineL."Location Code");
                reservationEntryL.SetRange("Source ID", SalesOrderP."No.");
                reservationEntryL.SetRange("Source Ref. No.", salesLineL."Line No.");
                reservationEntryL.SetRange("Reservation Status", reservationEntryL."Reservation Status"::Surplus);
                reservationEntryL.CalcSums("Quantity (Base)");
                QuantityReservedL := -reservationEntryL."Quantity (Base)";

                if QuantityReservedL <> salesLineL."Quantity (Base)" then begin
                    reservationEntryL.DeleteAll(true);

                    foundL := false;

                    salesLineL.GetRemainingQty(remainingQtyL, remainingQtyBaseL);

                    itemLedgerEntryL.SetCurrentKey("Expiration Date");
                    itemLedgerEntryL.SetRange("Item No.", salesLineL."No.");
                    itemLedgerEntryL.SetFilter("Remaining Quantity", '>%1', 0);
                    itemLedgerEntryL.SetFilter("Lot No.", '<>%1', '');
                    itemLedgerEntryL.SetFilter("Expiration Date", '>=%1', CalcDate('<+2M>', salesLineL."Shipment Date"));
                    if itemLedgerEntryL.FindSet() then
                        repeat
                            if itemLedgerEntryL."Remaining Quantity" >= remainingQtyBaseL then begin
                                addReservation(SalesOrderP, salesLineL, itemLedgerEntryL, remainingQtyBaseL);
                                remainingQtyBaseL := 0;
                            end else begin
                                addReservation(SalesOrderP, salesLineL, itemLedgerEntryL, itemLedgerEntryL."Remaining Quantity");
                                remainingQtyBaseL -= itemLedgerEntryL."Remaining Quantity";
                            end;

                        until (itemLedgerEntryL.Next() = 0) or (remainingQtyBaseL = 0);
                end;


            until salesLineL.Next() = 0;
    end;

    local procedure addReservation(var salesOrderP: record "Sales Header"; var SalesLineP: record "Sales Line"; var itemLedgerEntryP: record "Item Ledger Entry"; quantityP: decimal)
    var
        reservationEntryL: record "Reservation Entry";
    begin
        reservationEntryL.Reset();
        reservationEntryL.Init();
        reservationEntryL.Validate("Item No.", salesLineP."No.");
        reservationEntryL.Validate("Location Code", salesLineP."Location Code");
        reservationEntryL.Validate("Source Type", 37);
        reservationEntryL.Validate("Source Subtype", SalesOrderP."Document Type");
        reservationEntryL.Validate("Source ID", SalesOrderP."No.");
        reservationEntryL.Validate("Source Ref. No.", salesLineP."Line No.");
        reservationEntryL.Validate("Reservation Status", reservationEntryL."Reservation Status"::Surplus);
        reservationEntryL.Validate("Quantity (Base)", -quantityP);
        reservationEntryL.Validate("Lot No.", itemLedgerEntryP."Lot No.");
        reservationEntryL.Validate("Expiration Date", itemLedgerEntryP."Expiration Date");
        reservationEntryL.Validate("Item Tracking", reservationEntryL."Item Tracking"::"Lot No.");
        reservationEntryL.Validate("Shipment Date", salesLineP."Shipment Date");
        reservationEntryL.Insert(true);
    end;

    procedure postWarehouseShipment(var warehouseShipmentHeaderP: record "Warehouse Shipment Header")
    var
        warehouseShipmentLineL: record "Warehouse Shipment Line";
        wareHousePostShipmentL: codeUnit "Whse.-Post Shipment";
    begin
        warehouseShipmentLineL.Reset();
        warehouseShipmentLineL.SetRange("No.", warehouseShipmentHeaderP."No.");
        warehouseShipmentLineL.AutofillQtyToHandle(warehouseShipmentLineL);

        wareHousePostShipmentL.Run(warehouseShipmentLineL);

    end;


    procedure generateShipmentMail(warehouseShipmentCode: code[20]; postingDateP: date)
    var
        postedWhseShimentHeaderL: record "Posted Whse. Shipment Header";
        postedWhseShipmentLineL: record "Posted Whse. Shipment Line";
        postedSalesInvoiceHeaderL: record "Sales Invoice Header";
        postedSalesInvoiceLineL: record "Sales Invoice Line";
        postedSalesShipmentHeaderL: record "Sales Shipment Header";
        postedSalesShipmentLineL: record "Sales Shipment Line";
        printSalesInvoiceTL: record "Sales Invoice Header" temporary;
        printSalesShipmentTL: record "Sales Shipment Header" temporary;
        paymentMethod: record "Payment Method";

        shipmentListL: List of [Code[20]];
        invoiceListL: List of [Code[20]];

    begin

        if printSalesInvoiceTL.IsTemporary() then printSalesInvoiceTL.DeleteAll();
        if printSalesShipmentTL.IsTemporary() then printSalesShipmentTL.DeleteAll();

        postedWhseShimentHeaderL.Reset();
        postedWhseShimentHeaderL.SetRange("Whse. Shipment No.", warehouseShipmentCode);
        if postingDateP > 0D then
            postedWhseShimentHeaderL.SetRange("Posting Date", postingDateP);
        if postedWhseShimentHeaderL.FindSet() then
            repeat
                postedWhseShipmentLineL.Reset();
                postedWhseShipmentLineL.SetRange("No.", postedWhseShimentHeaderL."No.");
                if postedWhseShipmentLineL.FindSet() then
                    repeat
                        if postedWhseShipmentLineL."Source Document" = postedWhseShipmentLineL."Source Document"::"Sales Order" then begin
                            postedSalesShipmentLineL.SetRange("Order No.", postedWhseShipmentLineL."Source No.");
                            postedSalesShipmentLineL.SetRange("Order Line No.", postedWhseShipmentLineL."Source Line No.");
                            postedSalesShipmentLineL.SetRange("Posting Date", postedWhseShimentHeaderL."Posting Date");
                            postedSalesShipmentLineL.SetRange(Type, postedSalesShipmentLineL.Type::Item);
                            postedSalesShipmentLineL.SetRange(Quantity, postedWhseShipmentLineL.Quantity);
                            if postedSalesShipmentLineL.FindSet() then
                                repeat
                                    if postedSalesShipmentHeaderL.get(postedSalesShipmentLineL."Document No.") then begin
                                        if (postedSalesShipmentHeaderL."Payment Method Code" = '') or (paymentMethod.get(postedSalesShipmentHeaderL."Payment Method Code") and
                                         (paymentMethod."Bal. Account No." = '')) then begin
                                            postedSalesInvoiceLineL.SetRange("Order No.", postedWhseShipmentLineL."Source No.");
                                            postedSalesInvoiceLineL.SetRange("Order Line No.", postedWhseShipmentLineL."Source Line No.");
                                            postedSalesInvoiceLineL.SetRange("Posting Date", postedWhseShimentHeaderL."Posting Date");
                                            postedSalesInvoiceLineL.SetRange(Type, postedSalesInvoiceLineL.Type::Item);
                                            postedSalesInvoiceLineL.SetRange(Quantity, postedWhseShipmentLineL.Quantity);
                                            if postedSalesInvoiceLineL.FindSet() then
                                                repeat
                                                    if postedSalesInvoiceHeaderL.get(postedSalesInvoiceLineL."Document No.") then begin
                                                        printSalesInvoiceTL.Copy(postedSalesInvoiceHeaderL);
                                                        if printSalesInvoiceTL.Insert() then;
                                                    end;
                                                until postedSalesInvoiceLineL.Next() = 0;
                                        end else begin
                                            printSalesShipmentTL.Copy(postedSalesShipmentHeaderL);
                                            if printSalesShipmentTL.Insert() then;
                                        end;
                                    end;
                                until postedSalesShipmentLineL.Next() = 0;
                        end;
                    until postedWhseShipmentLineL.Next() = 0;
            until postedWhseShimentHeaderL.Next() = 0;

        printSalesShipmentTL.Reset();
        if printSalesShipmentTL.FindSet() then
            repeat
                shipmentListL.Add(printSalesShipmentTL."No.");
            until printSalesShipmentTL.Next() = 0;

        printSalesInvoiceTL.Reset();
        if printSalesInvoiceTL.FindSet() then
            repeat
                invoiceListL.Add(printSalesInvoiceTL."No.");
            until printSalesInvoiceTL.Next() = 0;


    end;

    procedure generateLogisticDocument(var locationP: record Location; shipmentDateP: date)
    var
        warehouseShipmentHeaderL: record "Warehouse Shipment Header";
    begin
        warehouseShipmentHeaderL := generateWarehouseShipment(locationP, shipmentDateP);
        postWarehouseShipment(warehouseShipmentHeaderL);
        generateShipmentMail(warehouseShipmentHeaderL."No.", shipmentDateP);
    end;

}


/*
 WhseShptHeader.Find();

        WhseRqst.FilterGroup(2);
        WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
        WhseRqst.SetRange("Location Code", WhseShptHeader."Location Code");
        OnGetSingleOutboundDocOnSetFilterGroupFilters(WhseRqst, WhseShptHeader);
        WhseRqst.FilterGroup(0);
        WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
        WhseRqst.SetRange("Completely Handled", false);
        OnGetSingleOutboundDocOnAfterSetFilters(WhseRqst, WhseShptHeader);

        GetSourceDocForHeader(WhseShptHeader, WhseRqst);

        UpdateShipmentHeaderStatus(WhseShptHeader);
        


        
    local procedure GetSourceDocForHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseRequest: Record "Warehouse Request")
    var
        SourceDocSelection: Page "Source Documents";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetSourceDocForHeader(WarehouseShipmentHeader, WarehouseRequest, IsHandled);
        if IsHandled then
            exit;

        SourceDocSelection.LookupMode(true);
        SourceDocSelection.SetTableView(WarehouseRequest);
        if SourceDocSelection.RunModal() <> ACTION::LookupOK then
            exit;
        SourceDocSelection.GetResult(WarehouseRequest);

        GetSourceDocuments.SetOneCreatedShptHeader(WarehouseShipmentHeader);
        GetSourceDocuments.SetSkipBlocked(true);
        GetSourceDocuments.UseRequestPage(false);
        WarehouseRequest.SetRange("Location Code", WarehouseShipmentHeader."Location Code");
        GetSourceDocuments.SetTableView(WarehouseRequest);
        GetSourceDocuments.RunModal();

*/
