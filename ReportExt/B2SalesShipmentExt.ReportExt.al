reportextension 50100 "B2 Sales Shipment Ext" extends "Standard Sales - Shipment"
{
    dataset
    {
        add(Header)
        {
            column(HeaderTitle; headerTitleLblG)
            {

            }

            column(headerDirectedByLbl; headerDirectedByLblG)
            {

            }

            column(FooterHeadOfficeLbl; footerHeaderQuarterLblG)
            {

            }

            column(FootContactDetailLbl; footerContactDetailLblG)
            {

            }

            column(ContactNameLbl; header.FieldCaption("Sell-to Contact"))
            {

            }

            column(ContactName; header."Sell-to Contact")
            {

            }

            column(Location; headerLocationLblG)
            {

            }

            column(LocationCity; locationG.City)
            {

            }

        }

        add(Line)
        {
            column(lotNos; lotTextG)
            {

            }

            column(EANCode_Lbl; itemG.FieldCaption("EAN Code"))
            {

            }

            column(EANCode; itemG."EAN Code")
            {

            }

            column(PharmaCode_Lbl; itemG.FieldCaption("Pharma Code"))
            {

            }

            column(PharmaCode; itemG."Pharma Code")
            {

            }
        }

        modify(line)
        {
            trigger OnAfterAfterGetRecord()
            var
                itemLedgerEntryL: record "Item Ledger Entry";
                withQuantityL: Boolean;
                textBuilderL: TextBuilder;

            begin
                clear(textBuilderL);

                itemLedgerEntryL.SetRange("Entry Type", itemLedgerEntryL."Entry Type"::Sale);
                itemLedgerEntryL.SetRange("Document No.", Line."Document No.");
                itemLedgerEntryL.SetRange("Document Line No.", Line."Line No.");
                itemLedgerEntryL.SetRange(Positive, false);
                withQuantityL := itemLedgerEntryL.Count() > 1;
                if itemLedgerEntryL.FindSet() then
                    repeat

                        if withQuantityL then
                            textBuilderL.AppendLine(Format(itemLedgerEntryL.Quantity) + 'x ' + itemLedgerEntryL."Lot No.")
                        else
                            textBuilderL.Append(itemLedgerEntryL."Lot No.");
                    until itemLedgerEntryL.Next() = 0;

                lotTextG := textBuilderL.ToText();

                itemG.Init();
                if line.Type = line.Type::Item then
                    if Not ItemG.Get(line."No.") then
                        itemG.Init();
            end;
        }

        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            begin
                locationG.get('PRO');
            end;
        }


    }

    var
        lotTextG: text;
        itemG: Record Item;

        footerHeaderQuarterLblG: Label 'Head office', Comment = 'FRS="Siège social",DES="Hauptverwaltung",ITS="Sede central"';
        footerContactDetailLblG: Label 'Contact details', Comment = 'FRS="Contact",DES="Kontaktangaben",ITS="Dettagli del contatto"';

        headerDirectedByLblG: Label 'Directed by', Comment = 'FRS="Réalisé par",DES="Regie führt",ITS="Diretto da"';
        headerLocationLblG: Label 'Location', Comment = 'FRS="Emplacement",DES="Standort",ITS="Località"';
        headerTitleLblG: Label 'Delivery note', Comment = 'FRS="Bulletin de livraison",DES="Lieferschein",ITS="Bollettino di consegna"';
        locationG: record Location;
}
