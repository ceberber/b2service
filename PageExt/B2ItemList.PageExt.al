pageextension 50105 "B2 Item List" extends "Item List"
{
    actions
    {
        addlast(Reports)
        {
            action(InventoryByLot)
            {
                caption = 'Inventory By lot', Comment = 'FRS="Inventaire par lot",DES=""';
                ApplicationArea = all;
                image = Lot;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                RunObject = report "B2 Inventory By Lot";
            }
        }
    }
}
