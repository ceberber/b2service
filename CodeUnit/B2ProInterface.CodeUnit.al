codeunit 50101 "B2 Pro Interface"
{

    procedure createHeaderCSV(var lineNoP: Integer; var csvBufferP: record "CSV Buffer")
    var
        companyInfoL: record "Company Information";
    begin
        companyInfoL.get();
        lineNoP := 1;
        csvBufferP.InsertEntry(lineNoP, 1, format(0));
        csvBufferP.InsertEntry(lineNoP, 2, companyInfoL."PRO Tiers Code");
    end;

    procedure CreateItemCSV(var ItemP: record Item; var lineNoP: Integer; modifyP: Boolean; var csvBufferP: record "CSV Buffer")
    begin
        csvBufferP.InsertEntry(lineNoP, 1, format(1)); // TYPE DE LIGNE

        if modifyP then
            csvBufferP.InsertEntry(lineNoP, 2, 'M') // ACTION	C : Pour une création S : Pour une suppression M : Pour une modification
        else
            csvBufferP.InsertEntry(lineNoP, 2, 'C'); // ACTION	C : Pour une création S : Pour une suppression M : Pour une modification


        csvBufferP.InsertEntry(lineNoP, 3, ''); // ZONE ACTIVITE
        csvBufferP.InsertEntry(lineNoP, 4, ''); // CODE DEPOT
        csvBufferP.InsertEntry(lineNoP, 5, ''); // CODE TIERS

        csvBufferP.InsertEntry(lineNoP, 6, ItemP."Vendor No."); //CODE FOURNISSEUR
        csvBufferP.InsertEntry(lineNoP, 7, ItemP."No."); //CODE ARTICLE
        csvBufferP.InsertEntry(lineNoP, 8, CopyStr(ItemP."Description", 1, 30));//LIBELLE COURT
        csvBufferP.InsertEntry(lineNoP, 9, ItemP."Description");//LIBELLE

    end;

    procedure CreateSalesShipmentHeaderCSV(var salesHeaderP: record "Sales Header"; var lineNoP: Integer; modifyP: Boolean; var csvBufferP: record "CSV Buffer")
    var
        companyInfoL: record "Company Information";
        countryL: record "Country/Region";
    begin

        companyInfoL.get();

        csvBufferP.InsertEntry(lineNoP, 1, Format(1)); //TYPE DE LIGNE	O	Chaîne	1	Constante = 0
        if modifyP then
            csvBufferP.InsertEntry(lineNoP, 2, 'M') //ACTION C : Pour une création, S : Pour une suppression, M : Pour une modification
        else
            csvBufferP.InsertEntry(lineNoP, 2, 'C'); //ACTION C : Pour une création, S : Pour une suppression, M : Pour une modification

        csvBufferP.InsertEntry(lineNoP, 3, companyInfoL."PRO Activity Zone");
        csvBufferP.InsertEntry(lineNoP, 4, companyInfoL."PRO Location Code");
        csvBufferP.InsertEntry(lineNoP, 5, companyInfoL."PRO Tiers Code");
        csvBufferP.InsertEntry(lineNoP, 6, companyInfoL."PRO Activity Code");
        csvBufferP.InsertEntry(lineNoP, 7, salesHeaderP."No.");
        csvBufferP.InsertEntry(lineNoP, 8, '');
        csvBufferP.InsertEntry(lineNoP, 9, '');
        csvBufferP.InsertEntry(lineNoP, 10, salesHeaderP."Sell-to Customer No.");
        csvBufferP.InsertEntry(lineNoP, 11, salesHeaderP."Ship-to Name");
        csvBufferP.InsertEntry(lineNoP, 12, salesHeaderP."Ship-to Name 2");
        csvBufferP.InsertEntry(lineNoP, 13, salesHeaderP."Ship-to Address");
        csvBufferP.InsertEntry(lineNoP, 14, salesHeaderP."Ship-to Address 2");
        csvBufferP.InsertEntry(lineNoP, 15, salesHeaderP."Ship-to Post Code");
        csvBufferP.InsertEntry(lineNoP, 16, salesHeaderP."Ship-to City");
        csvBufferP.InsertEntry(lineNoP, 17, ''); // CODE_TOURNEE
        csvBufferP.InsertEntry(lineNoP, 18, 'CL'); //TYPE_OL
        csvBufferP.InsertEntry(lineNoP, 19, ''); // COMMENTAIRE COURT
        csvBufferP.InsertEntry(lineNoP, 20, ''); // COMMENTAIRE LONG
        csvBufferP.InsertEntry(lineNoP, 21, format(salesHeaderP."Shipment Date", 0, '<Day,2>/<Month,2>/<year4>'));
        csvBufferP.InsertEntry(lineNoP, 22, '11:00');
        csvBufferP.InsertEntry(lineNoP, 23, '');
        csvBufferP.InsertEntry(lineNoP, 24, salesHeaderP."Bill-to Name");
        csvBufferP.InsertEntry(lineNoP, 25, salesHeaderP."Bill-to Name 2");
        csvBufferP.InsertEntry(lineNoP, 26, salesHeaderP."Bill-to Address");
        csvBufferP.InsertEntry(lineNoP, 27, salesHeaderP."Bill-to Address 2");
        csvBufferP.InsertEntry(lineNoP, 28, salesHeaderP."Bill-to Post Code");
        csvBufferP.InsertEntry(lineNoP, 39, salesHeaderP."Bill-to City");
        csvBufferP.InsertEntry(lineNoP, 30, ''); //TRANS_E

        if countryL.get(salesHeaderP."Ship-to Country/Region Code") then
            csvBufferP.InsertEntry(lineNoP, 31, countryL."ISO 3 Code")
        else
            csvBufferP.InsertEntry(lineNoP, 31, 'CHE');

        if countryL.get(salesHeaderP."Bill-to Country/Region Code") then
            csvBufferP.InsertEntry(lineNoP, 32, countryL."ISO 3 Code")
        else
            csvBufferP.InsertEntry(lineNoP, 32, 'CHE');

        csvBufferP.InsertEntry(lineNoP, 33, salesHeaderP."Shipping Agent Code");
        csvBufferP.InsertEntry(lineNoP, 34, '');
        csvBufferP.InsertEntry(lineNoP, 35, '');
        csvBufferP.InsertEntry(lineNoP, 36, '');
        csvBufferP.InsertEntry(lineNoP, 37, '');
        csvBufferP.InsertEntry(lineNoP, 38, '');
        csvBufferP.InsertEntry(lineNoP, 39, '');
        csvBufferP.InsertEntry(lineNoP, 40, '');
        csvBufferP.InsertEntry(lineNoP, 41, '');
        csvBufferP.InsertEntry(lineNoP, 42, '');
        csvBufferP.InsertEntry(lineNoP, 43, '');
        csvBufferP.InsertEntry(lineNoP, 44, '');
        csvBufferP.InsertEntry(lineNoP, 45, '');
        csvBufferP.InsertEntry(lineNoP, 46, '');
        csvBufferP.InsertEntry(lineNoP, 47, '');

    end;

    procedure CreateSalesShipmentLineCSV(var salesLineP: record "Sales Line"; QuantityP: decimal; lotNoP: text; indiceP: text; var lineNoP: Integer; modifyP: Boolean; var csvBufferP: record "CSV Buffer")
    var
        companyInfoL: record "Company Information";
        countryL: record "Country/Region";
        itemTRackingL: record "Item Ledger Entry";
    begin

        companyInfoL.get();

        csvBufferP.InsertEntry(lineNoP, 1, Format(2)); //TYPE DE LIGNE	O	Chaîne	1	Constante = 2
        if modifyP then
            csvBufferP.InsertEntry(lineNoP, 2, 'M')
        else
            csvBufferP.InsertEntry(lineNoP, 2, 'C');
        csvBufferP.InsertEntry(lineNoP, 3, salesLineP."Document No."); // REF_OL
        csvBufferP.InsertEntry(lineNoP, 4, format(salesLineP."Line No.") + indiceP); // REF_LIGOL
        csvBufferP.InsertEntry(lineNoP, 5, salesLineP."No."); // CODE ARTICLE
        csvBufferP.InsertEntry(lineNoP, 6, companyInfoL."PRO Activity Code"); //CODE_ACTIVITE
        csvBufferP.InsertEntry(lineNoP, 7, format(QuantityP)); //QTE UG
        csvBufferP.InsertEntry(lineNoP, 8, 'U'); // TYPE_CDT_MIN - Constante = U
        csvBufferP.InsertEntry(lineNoP, 9, salesLineP."Unit of Measure Code"); // CDT_MIN
        csvBufferP.InsertEntry(lineNoP, 10, ''); // COMMENTAIRE COURT
        csvBufferP.InsertEntry(lineNoP, 11, ''); // CODE OPERATION
        csvBufferP.InsertEntry(lineNoP, 12, ''); // SOUS CODE OPERATION
        csvBufferP.InsertEntry(lineNoP, 13, ''); // PUHT
        csvBufferP.InsertEntry(lineNoP, 14, ''); // TOTAL HT
        csvBufferP.InsertEntry(lineNoP, 15, ''); // TOTAL TTC
        csvBufferP.InsertEntry(lineNoP, 16, ''); // TRANS_L
        csvBufferP.InsertEntry(lineNoP, 17, ''); // TYPE_BLOCAGE
        csvBufferP.InsertEntry(lineNoP, 18, ''); // CODE BLOCAGE
        csvBufferP.InsertEntry(lineNoP, 19, ''); // FLAG_EMBALLAGE
        csvBufferP.InsertEntry(lineNoP, 20, ''); // MESSAGE
        csvBufferP.InsertEntry(lineNoP, 21, lotNoP); // NUM LOT
        csvBufferP.InsertEntry(lineNoP, 22, ''); // CLE_TRI
    end;

    procedure CreateVendorCSV(var vendorP: record Vendor; var lineNoP: Integer; modifyP: Boolean; var csvBufferP: record "CSV Buffer")
    var
        companyInfoL: record "Company Information";
        countryL: record "Country/Region";
    begin

        companyInfoL.get();

        csvBufferP.InsertEntry(lineNoP, 1, Format(1)); //TYPE DE LIGNE	O	Chaîne	1	Constante = 0
        if modifyP then
            csvBufferP.InsertEntry(lineNoP, 2, 'M')
        else
            csvBufferP.InsertEntry(lineNoP, 2, 'C');

        csvBufferP.InsertEntry(lineNoP, 3, companyInfoL."PRO Tiers Code"); // CODE TIERS	O	Chaîne	15	Code tiers du fournisseur   Constante 
        csvBufferP.InsertEntry(lineNoP, 4, companyInfoL."PRO Activity Code"); // CODE_ACTIVITE	O	Chaîne	15	Identifiant de l'activité dans le WMS
        csvBufferP.InsertEntry(lineNoP, 5, vendorP."No."); // CODE FOURN	O	Chaîne	15	Code du Fournisseur (unique pour un couple Code_tiers/Code_activite)
        csvBufferP.InsertEntry(lineNoP, 6, CopyStr(vendorP.Name, 1, 30)); // LIBELLE COURT	O	Chaîne	30	Libelle du fournisseur
        csvBufferP.InsertEntry(lineNoP, 7, CopyStr(vendorP."Name 2", 1, 30)); //ADRESSE1	N	Chaine	30	Champ 1 de l'adresse du fournisseur
        csvBufferP.InsertEntry(linenoP, 8, copyStr(vendorP.Address, 1, 30));// ADRESSE2	N	Chaine	30	Champ 2 de l'adresse du fournisseur
        csvBufferP.InsertEntry(linenoP, 9, CopyStr(vendorP."Address 2", 1, 30));// ADRESSE3	N	Chaîne	30	Champ 3 de l'adresse du fournisseur
        csvBufferP.InsertEntry(linenoP, 10, vendorP.City);// VILLE	N	Chaîne	30	Ville
        csvBufferP.InsertEntry(linenoP, 11, vendorP."Post Code");// CODE_POSTAL	N	Chaîne	10	Champ Code postal

        if countryL.get(vendorP."Country/Region Code") and (countryL."ISO 3 Code" <> '') then
            csvBufferP.InsertEntry(linenoP, 12, countryL."ISO 3 Code")// CODE_PAYS	N	Chaîne	3	Voir liste des codes pays sur 3 caractères Iso. 3166-1 A3
        else
            csvBufferP.InsertEntry(linenop, 12, '');

        csvBufferP.InsertEntry(lineNoP, 13, CopyStr(vendorP."Phone No.", 1, 20)); // NUM_TELEPHONE	N	Chaîne	20	Numéro de téléphone
        csvBufferP.InsertEntry(lineNoP, 14, CopyStr(vendorP."E-Mail", 1, 50));// ADR_MAIL	N	Chaine	50	Adresses mails du contact
        csvBufferP.InsertEntry(lineNoP, 15, vendorP.GLN);  //CODE_EDI	N	Chaine	20	Code d'identification dans l'ERP
        csvBufferP.InsertEntry(lineNoP, 16, ''); // 
    end;

    local procedure CreateShippingCSV(var SalesOrderP: record "Sales Header"; var lineNoP: Integer; modifyP: Boolean; var CSVBufferP: record "CSV Buffer")
    begin

    end;


    /* 
6.2 Fichier Fournisseur – Format de la ligne : Code fournisseur
Champ	Obligatoire	Format	Taille	Définition & Valeurs
TYPE LIGNE	O	Num	1	Constante = 1
ACTION	O	Chaîne	1	C: Pour une création
M : Pour une modification
CODE_TIERS	O	Chaîne	15	Identifiant du client dans le WMS
Constante 
CODE_ACTIVITE	O	Chaîne	15	Identifiant de l'activité dans le WMS
CODE FOURN	O	Chaîne	15	Code du Fournisseur (unique pour un couple Code_tiers/Code_activite)
LIBELLE COURT	O	Chaîne	30	Libelle du fournisseur
ADRESSE1	N	Chaine	30	Champ 1 de l'adresse du fournisseur
ADRESSE2	N	Chaine	30	Champ 2 de l'adresse du fournisseur
ADRESSE3	N	Chaîne	30	Champ 3 de l'adresse du fournisseur
VILLE	N	Chaîne	30	Ville
CODE_POSTAL	N	Chaîne	10	Champ Code postal
CODE_PAYS	N	Chaîne	3	Voir liste des codes pays sur 3 caractères Iso. 3166-1 A3
NUM_TELEPHONE	N	Chaîne	20	Numéro de téléphone
ADR_MAIL	N	Chaine	50	Adresses mails du contact
CODE_EDI	N	Chaine	20	Code d'identification dans l'ERP
COMMENTAIRE	N	Chaine	50	Champ libre


    */

}
