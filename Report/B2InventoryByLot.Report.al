report 50101 "B2 Inventory By Lot"
{
    ApplicationArea = All;
    Caption = 'Inventory By Lot';
    UsageCategory = Administration;
    DefaultLayout = Excel;
    ExcelLayout = './Report/excel/b2inventorybylot.xlsx';


    dataset
    {
        dataitem(Item; item)
        {
            RequestFilterFields = "No.", Description, "Item Category Code", "Inventory Posting Group";
            column(ItemNo; item."No.")
            {
                caption = 'Item No.';
            }
            column(Description; item.Description)
            {
                caption = 'Description';
            }

            column(Inventory; item."Inventory")
            {
                Caption = 'Total Quantity';
            }

            dataitem(Location; location)
            {
                RequestFilterFields = Code;
                column(LocationCode; location.Code)
                {
                    Caption = 'Location Code';
                }

                dataitem(Lot; integer)
                {
                    DataItemTableView = sorting(Number);

                    column(LotNo; itemLedgerEntryByLotG."Lot No.")
                    {
                        Caption = 'Lot No.';
                    }

                    column(ExpirationDate; itemLedgerEntryByLotG."Expiration Date")
                    {
                        Caption = 'Expiration Date';
                    }

                    column(Quantity; itemLedgerEntryByLotG."Remaining Quantity")
                    {
                        caption = 'Quantity';
                    }

                    trigger OnPreDataItem()
                    var
                        ctL: Integer;
                    begin
                        itemLedgerEntryByLotG.Reset();
                        lot.SetRange(Number, 1, itemLedgerEntryByLotG.Count());
                        if itemLedgerEntryByLotG.FindFirst() then;
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        if lot.Number > 1 then
                            itemLedgerEntryByLotG.Next();
                    end;

                }

                trigger OnAfterGetRecord()
                var
                    itemLedgerEntryL: record "Item Ledger Entry";
                begin
                    if itemLedgerEntryByLotG.IsTemporary then itemLedgerEntryByLotG.DeleteAll();
                    itemLedgerEntryL.SetRange("Item No.", item."No.");
                    itemLedgerEntryL.SetRange("Location Code", Location.Code);
                    itemLedgerEntryL.SetRange(Open, true);
                    if itemLedgerEntryL.FindSet() then
                        repeat
                            itemLedgerEntryByLotG.SetRange("Lot No.", itemLedgerEntryL."Lot No.");
                            if itemLedgerEntryByLotG.FindFirst() then begin
                                itemLedgerEntryByLotG."Remaining Quantity" += itemLedgerEntryL."Remaining Quantity";
                                itemLedgerEntryByLotG.Modify();
                            end else begin
                                itemLedgerEntryByLotG.copy(itemLedgerEntryL);
                                if itemLedgerEntryByLotG.Insert() then;
                            end;
                        until itemLedgerEntryL.Next() = 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                item.CalcFields(Inventory, "Net Change");
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    var
        itemLedgerEntryByLotG: record "Item Ledger Entry" temporary;
}
