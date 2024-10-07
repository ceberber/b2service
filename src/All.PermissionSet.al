permissionset 50100 "B2S All"
{
    Access = Internal;
    Assignable = true;
    Caption = 'B2 Service All permissions', Locked = true;

    Permissions =
         codeunit "B2S Management" = X,
         page "B2 Text Card" = X,
         page "B2 Text List" = X,
         page "B2SwissMedic Item Category" = X,
         report "B2 Invoice" = X,
         report "B2 Sales Shipment" = X,
         report "ERPS Invoice" = X,
         table "B2 Text" = X,
         table B2SwissMedicItemCategory = X,
         tabledata "B2 Text" = RIMD,
         tabledata B2SwissMedicItemCategory = RIMD;
}