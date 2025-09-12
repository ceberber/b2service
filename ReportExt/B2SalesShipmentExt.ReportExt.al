reportextension 50100 "B2 Sales Shipment Ext" extends "Standard Sales - Shipment"
{
    dataset
    {
        add(Header)
        {
            column(FooterHeadOfficeLbl; footerHeaderQuarterLblG)
            {

            }

            column(FootContactDetailLbl; footerContactDetailLblG)
            {

            }



            column(ContactName; header."Sell-to Contact")
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


    }

    var
        lotTextG: text;
        itemG: Record Item;

        footerHeaderQuarterLblG: Label 'Head office', Comment = 'FRS="Siège social",DES="Hauptverwaltung"';
        footerContactDetailLblG: Label 'Contact details', Comment = 'FRS="Contact",DES="Kontaktangaben"';

        headerDirectedbyLblG: Label 'Directed by', Comment = 'FRS="Réalisé par",DES="Regie führt"';
}
