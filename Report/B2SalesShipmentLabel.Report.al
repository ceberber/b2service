report 50102 "B2 Post Shipment Label"
{
    ApplicationArea = All;
    Caption = 'Post Shipment Label';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Report/RDLC/B2PostShipmentLabel.rdlc';

    dataset
    {

        dataitem(SalesShipmentHeader; "Sales Shipment Header")
        {

            RequestFilterFields = "No.";

            column(ShipmentNo; "No.")
            {

            }

            column(Your_Reference; "Your Reference")
            {

            }

            column(ParcelLbl; PackageLblG)
            {

            }

            column(TotalPackage; packageNbrG)
            {

            }

            dataitem(package; Integer)
            {

                column(PackageNo; Number)
                {

                }

                column(BESO; besoG)
                {
                }

                column(Image64; Image64G)
                {
                }


                trigger OnPreDataItem()
                begin
                    SalesShipmentHeader.CalcFields("Additional Package");
                    package.SetRange(number, 1, packageNbrG);
                end;

                trigger OnAfterGetRecord()
                var
                    inStreamL: InStream;
                    additionalPackageL: record "B2 Additional Package";
                begin
                    if package.Number = 1 then begin
                        SalesShipmentHeader.CalcFields("Label");
                        SalesShipmentHeader.Label.CreateInStream(inStreamL);
                        inStreamL.Read(image64G);
                    end else begin
                        additionalPackageL.SetRange("Shipment Header No.", SalesShipmentHeader."No.");
                        additionalPackageL.FindFirst();
                        if package.number > 2 then
                            additionalPackageL.Next(package.number - 2);

                        additionalPackageL.CalcFields("Label");
                        additionalPackageL.Label.CreateInStream(inStreamL);
                        inStreamL.Read(image64G);

                    end;
                end;

            }

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

                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                if shippingAgentL.get(SalesShipmentHeader."Shipping Agent Code") and (shippingAgentL."Client ID" = '') then begin
                    CurrReport.Skip();
                end;

                SalesShipmentHeader.CalcFields("Additional Package");
                packageNbrG := "Additional Package" + 1;

                besoG := shippingAgentL.BESO;
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
        besoG: Boolean;
        packageNbrG: integer;
        shipmentNoG: code[20];
        packageLblG: Label 'Parcel', Comment = 'FRS="Colis",DES="Paket"';
        languageMGT: Codeunit Language;
}
