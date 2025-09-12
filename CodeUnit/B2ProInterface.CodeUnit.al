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

    local procedure CreateCustomerCSV(var CustomerP: record Customer; var lineNoP: Integer; ModifyP: Boolean; var csvBufferP: record "CSV Buffer")
    begin

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

        if countryL.get(vendorP."Country/Region Code") and (countryL."ISO 3 Code " <> '') then
            csvBufferP.InsertEntry(linenoP, 12, countryL."ISO 3 Code ")// CODE_PAYS	N	Chaîne	3	Voir liste des codes pays sur 3 caractères Iso. 3166-1 A3
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
