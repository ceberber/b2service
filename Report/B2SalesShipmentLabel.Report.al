report 50126 "B2 Post Shipment Label"
{
    ApplicationArea = All;
    Caption = 'Post Shipment Label';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Report/RDLC/BFreiPostShipmentLabel.rdlc';

    dataset
    {
        dataitem(SalesShipmentHeader; "Sales Shipment Header")
        {

            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                if SalesShipmentHeader.GetFilter("No.") = '' then
                    SalesShipmentHeader.SetRange("No.", '.');
            end;

            trigger OnAfterGetRecord()
            var
                inStreamL: InStream;
                shippingAgentL: record "Shipping Agent";
            begin

                if shippingAgentL.get(SalesShipmentHeader."Shipping Agent Code") and (shippingAgentL."Client ID" = '') then begin
                    CurrReport.Skip();
                end;

                CalcFields("Label");
                Label.CreateInStream(inStreamL);
                inStreamL.Read(image64G);
            end;
        }

        dataitem(Image; Integer)
        {
            DataItemTableView = sorting(Number);

            column(Image64; Image64G)
            {
            }

            trigger OnPreDataItem()
            begin
                Image.SetRange(Number, 1);
                if image64G = '' then
                    CurrReport.Quit();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {

            }
        }
    }

    trigger OnPreReport()
    begin
        image64G := '';
    end;

    var
        image64G: text;
}
