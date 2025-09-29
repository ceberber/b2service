permissionset 50100 "All"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "B2 Poste API" = X,
         codeunit "B2 Pro Interface" = X,
         codeunit "B2S Management" = X,
         page "B2 Interface Journal" = X,
         page "B2 Text Card" = X,
         page "B2 Text List" = X,
         page "B2SwissMedic Item Category" = X,
         report "B2 Inventory By Lot" = X,
         report "B2 Invoice" = X,
         report "B2 Post Shipment Label" = X,
         table "B2 Interface Journal" = X,
         table "B2 Text" = X,
         table B2SwissMedicItemCategory = X,
         tabledata "B2 Interface Journal" = RIMD,
         tabledata "B2 Text" = RIMD,
         tabledata B2SwissMedicItemCategory = RIMD;
}