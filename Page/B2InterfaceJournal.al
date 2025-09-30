page 50103 "B2 Interface Journal"
{
    ApplicationArea = All;
    Caption = 'Interface Journal';
    PageType = List;
    SourceTable = "B2 Interface Journal";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Action Date Time"; Rec."Action Date Time")
                {
                    ToolTip = 'Specifies the value of the Action Date Time field.', Comment = '%';
                }
                field("Action type"; Rec."Action type")
                {
                    ToolTip = 'Specifies the value of the Action type field.', Comment = '%';
                }

                field("Sub Action type"; Rec."Sub Action Type")
                {
                    ToolTip = 'Specifies the value of the Sub Action type field.', Comment = '%';
                }

                field(Filename; rec.Filename)
                {

                }

                field("CSV "; Rec."CSV")
                {
                    ToolTip = 'Specifies the value of the CSV field.', Comment = '%';
                }
                field("Found On FTP"; Rec."Found On FTP")
                {
                    ToolTip = 'Specifies the value of the Found On FTP field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendItems)
            {
                ApplicationArea = all;
                image = SendTo;
                caption = 'Send Items';
                trigger OnAction()
                begin
                    rec.sendItems();
                end;
            }

            action(SendPurchaseOrders)
            {
                ApplicationArea = all;
                image = SendTo;
                caption = 'Send Purchase Orders';
                trigger OnAction()
                begin
                    rec.sendPurchOrder();
                end;
            }

            action(SendSalesOrders)
            {
                ApplicationArea = all;
                image = SendTo;
                caption = 'Send Sales Orders';
                trigger OnAction()
                begin
                    rec.sendSalesOrder();
                end;
            }

            action(SendVendors)
            {
                ApplicationArea = all;
                image = SendTo;
                caption = 'Send Vendors';
                trigger OnAction()
                begin
                    rec.sendVendors();
                end;
            }

            action(ShowCsv)
            {
                ApplicationArea = all;
                image = SendTo;
                caption = 'Show CSV';
                trigger OnAction()
                begin
                    rec.ShowCSV();
                end;

            }

            action(DownLoadCsv)
            {
                ApplicationArea = all;
                image = SendTo;
                caption = 'Download CSV';
                trigger OnAction()
                begin
                    rec.DownloadCSV();
                end;

            }

            action(ResetSendPro)
            {
                ApplicationArea = all;
                image = SendTo;
                caption = 'Reset Send to PRO';
                trigger OnAction()
                var
                    itemL: Record Item;
                    vendorL: record Vendor;
                begin
                    itemL.ModifyAll("Last Send to PRO", 0D);
                    vendorL.ModifyAll("Last Send to PRO", 0D);
                end;

            }

            group(reading)
            {
                caption = 'Read';
                action(ReadShipment)
                {
                    caption = 'Read Shipment';
                    image = Import;
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        proInterfaceL: Codeunit "B2 Pro Interface";
                    begin

                        proInterfaceL.readShipment();

                    end;
                }
            }
        }
    }
}
