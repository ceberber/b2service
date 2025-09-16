pageextension 50100 B2ItemCardExt extends "Item Card"
{

    layout
    {
        addafter("No.")
        {
            field("EAN Code"; rec."EAN Code")
            {
                ApplicationArea = all;
            }
            field("Pharma Code"; rec."Pharma Code")
            {
                ApplicationArea = all;
            }

            field(" SwissMedic Item Category Code"; rec."SwissMedic Item Category Code")
            {
                ApplicationArea = all;
            }

        }
    }

    actions
    {
        addafter("Item Tracing")
        {
            action(TestsalesOrder)
            {
                Caption = 'Test Sales Order';
                Image = TestReport;
                ApplicationArea = all;
                trigger OnAction()
                var
                    managementL: Codeunit "B2S Management";
                    customerL: record Customer;
                    salesItemsL: Dictionary of [code[20], Decimal];
                begin
                    salesItemsL.Add('0102', 4);
                    salesItemsL.add('4030', 5);
                    if customerL.get('C00170') then
                        managementL.generateSalesOrder(customerL, 0D, 0D, salesItemsL);
                end;
            }
            action(TestWarehouseShipment)
            {
                Caption = 'Test Warehouse Shipment';
                Image = TestReport;
                ApplicationArea = all;
                trigger OnAction()
                var
                    managementL: Codeunit "B2S Management";
                    locationL: record Location;
                begin
                    locationL.Get('MARLY');
                    managementL.generateWarehouseShipment(locationL, 0D);

                end;
            }


            action(TestComplet)
            {
                Caption = 'Test Warehouse Log. Document';
                Image = TestReport;
                ApplicationArea = all;
                trigger OnAction()
                var
                    managementL: Codeunit "B2S Management";
                    locationL: record Location;
                begin
                    locationL.Get('MARLY');
                    managementL.generateLogisticDocument(locationL, 0D);

                end;

            }

            action(TestMail)
            {
                Caption = 'Test Warehouse Mail';
                Image = TestReport;
                ApplicationArea = all;
                trigger OnAction()
                var
                    managementL: Codeunit "B2S Management";
                    locationL: record Location;
                begin
                    locationL.Get('MARLY');
                    managementL.generateShipmentMail('EX000012', 20241005D);

                end;

            }
        }
    }

}
