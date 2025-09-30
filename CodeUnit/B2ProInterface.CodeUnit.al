codeunit 50101 "B2 Pro Interface"
{

    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        b2InterfaceJournalL: record "B2 Interface Journal";
    begin
        if Rec."Parameter String" <> '' then begin

            case rec."Parameter String" of

                'send item':
                    begin
                        b2InterfaceJournalL.sendItems();
                    end;

                'send vendor':
                    begin
                        b2InterfaceJournalL.sendVendors();
                    end;

                'send purchase':
                    begin
                        b2InterfaceJournalL.sendPurchOrder();
                    end;

                'send sales':
                    begin
                        b2InterfaceJournalL.sendSalesOrder();
                    end;

                'read shipment':
                    begin

                    end;
                'read receipt':
                    begin

                    end;

                'read inventory':
                    begin

                    end;


            end;
        end;
    end;

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
        csvBufferP.InsertEntry(lineNoP, 29, salesHeaderP."Bill-to City");
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

    procedure createPurchReceiptHeaderCSV(var PurchHeaderP: record "Purchase Header"; var lineNoP: Integer; modifyP: Boolean; var csvBufferP: record "CSV Buffer")
    var
        companyInfoL: record "Company Information";
        countryL: record "Country/Region";
    begin

        /* 
        1   TYPE LIGNE	            O	    Num	    1	        Constante = 1
        2   ACTION	                O	    Chaîne	1	        C: Pour une création
                                                                S : Pour une suppression
                                                                M : Pour une modification
        3   CODE ZONE ACTIVITE	    O	    Chaîne	5	        Zone logistique du prestataire
                                                                Exemple « LOGIS »
        4   CODE DEPOT	            O	    Chaîne	15	        Dépôt du prestataire
                                                                Constante = Exemple « FLEURY »
        5   CODE TIERS	            O	    Chaîne	15	        Identifiant du client dans le WMS - 
                                                                Constante = Exemple « ARTI »
        6   CODE ACTIVITE	        O	    Chaîne	15	        Identifiant de l’activité dans le WMS
                                                                Constante = Exemple « ARTI »
        7   CODE FOURNISSEUR	    O	    Chaîne	15	        Fournisseur de la réception
        8   REF1_BR	                O	    Chaîne	50	        Référence du BR N°1 :
                                                                Clé unique identifiant l’entête de la réception dans votre système
                                                                (Ce champ est remonté dans l’interface compte rendu de la réception)

        9   REF2_BR	                N	    Chaîne	50	        Référence du BR N°2 : Identifiant supplémentaire de l’entête de la réception dans votre système.
                                                                (Ce champ est remonté dans l’interface compte rendu de la réception)
        10  LIBELLE_COURT	        N	    Chaîne	30	        Libellé court
        11  REMARQUE	            N	    Chaîne	250	        Remarque concernant le BR
        12  DATE_RECEP_PREV	        O	    Date	10	        Date de réception prévue (DD/MM/YYYY)
        13  HEURE_RECEP_PREV	    O	    Heure	5	        Heure de réception prévue (HH:MM)
        14  CODE OPERATION	        N	    Chaîne	25	        Opération commerciale du client dont dépend la réception (Vide)
        15  TYPE_BR	                O	    Chaîne	15	        Type BR
                                                                Constante = CL : Réception classique
                                                                Constante = DI : Réception directe
        16  TRANS_E	                N	    Chaîne	500	        Zone de transit de données
        17  REF3_BR	                N	    Chaîne	50	        Référence du BR N°3 : Identifiant supplémentaire de l’entête de la réception dans votre système.
                                                                (Ce champ est remonté dans l’interface compte rendu de la réception)
        18  BATIMENT FOURNISSEUR	N	    Chaine	20	        Met à jour le bâtiment du fournisseur, le mettre à vide ne supprimera pas le bâtiment du fournisseur.
        19  BATIMENT BR	            N	    Chaine	20	        Bâtiment du BR.
                                                                Si le paramètre CAR004 est actif, un bâtiment est obligatoire.
                                                                Si le bâtiment du BR est vide on prend le bâtiment fournisseur du INREC courant.
                                                                Si le bâtiment du fournisseur du INREC courant est aussi vide, on prend le bâtiment du fournisseur dans IzyPro.
                                                                Si les trois champs sont vide, une erreur est générée.

   */

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
        csvBufferP.InsertEntry(lineNoP, 7, PurchHeaderP."Buy-from Vendor No.");
        csvBufferP.InsertEntry(lineNoP, 8, PurchHeaderP."No.");
        csvBufferP.InsertEntry(lineNoP, 9, '');
        csvBufferP.InsertEntry(lineNoP, 10, '');
        csvBufferP.InsertEntry(lineNoP, 11, '');
        csvBufferP.InsertEntry(lineNoP, 12, format(PurchHeaderP."Expected Receipt Date", 0, '<day,2>/<Month,2>/<year4>'));
        csvBufferP.InsertEntry(lineNoP, 13, '14:00');
        csvBufferP.InsertEntry(lineNoP, 14, '');
        csvBufferP.InsertEntry(lineNoP, 15, 'CL');
        csvBufferP.InsertEntry(lineNoP, 16, '');
        csvBufferP.InsertEntry(lineNoP, 17, '');
        csvBufferP.InsertEntry(lineNoP, 18, '');
        csvBufferP.InsertEntry(lineNoP, 19, '');

    end;

    procedure createPurchReceiptLineCSV(var PurchLineP: record "Purchase Line"; QuantityP: decimal; lotNoP: text; indiceP: text; dateExpP: date; var lineNoP: Integer; modifyP: Boolean; var csvBufferP: record "CSV Buffer")
    var
        companyInfoL: record "Company Information";
        countryL: record "Country/Region";
        itemTRackingL: record "Item Ledger Entry";
    begin

        /*

        1   TYPE LIGNE              O       Num	    1	    Constante = 2
        2   ACTION	                O	    Chaîne	1	    C: Pour une création
                                                            S : Pour une suppression
                                                            M : Pour une modification
        3   REF_BR	                O       Chaîne  50	    Référence de l’entête BR, assure la cohérence entre entêtes et lignes dans un même fichier égale à REF1 de l’entête
                                                            ENTETE.REF1_BR
        4   REF_LIGBR	            O	    Chaîne	15	    Référence de la Ligne BR
                                                            Identifiant de la ligne de réception dans votre système. Unique par REF_BR
                                                            (Ce champ est remonté dans l’interface compte rendu de la réception)
        5   CODE ARTICLE	        O	    Chaîne	45	    Code de l’article commandé existant pour le DO/ACT
        6   CODE_ACTIVITE	        O	    Chaine	15	    Activité du client dont dépend l’article 
                                                            Exemple « ARTI » doit être identique au CODE ACTIVITE de l’entête
        7   QTE UG	                O	    Num	    8	    Quantité d’Unités de Gestion commandées
                                                            Quantité en UVC
        8   QTE UG PREVUE	        O	    Num	    8	    Quantité d’UG prévues en réception
                                                            Quantité en UVC
        9   TYPE_CDT_MIN	        O	    Chaîne	2	    Type de l’Unité de Gestion : 
                                                            Constante = U
        10  CDT_MIN	                O	    Chaîne	5	    Unité de Gestion
                                                            Constante = UC
        11  CODE OPERATION	        N	    Chaîne	25	    Opération commerciale du client dont dépend la réception
                                                            SOUS CODE OPERATION	N	Chaîne	25	Sous-code opération du client dont dépend la réception
                                                            (Vide)
        12  DATE DLC	            N	    Date	10	    Date Limite de Consommation (DD/MM/YYYY)
                                                            (Vide)
        13  DATE DLV	            N	    Date	10	    Date Limite de Vente (DD/MM/YYYY)
                                                            (Vide)
        14  NUM_LOT	                N       Chaîne	20	    N° du Lot de l’article à entrer en stock
                                                            (Vide)
        15  DESTINATAIRE	        N	    Chaîne	25	    Code destinataire
                                                            (Vide)
        16  RESERVATION	            N	    Chaîne	50	    Code réservation
                                                            (Vide)
        17  SSCC	                N	    Chaine	20	    Identifiant unique du support de réception
        18  TRANS_L	                N	    Chaîne	250	    Zone de transit des données
        19  NUMERO DE SERIE	        N	    Chaîne	30	    NON ACTIF
        20  PUHT	                N	    Num	    8	    Prix unitaire Hors Taxes de l’article
                                                            0 par défaut
        21  TYPE_BLOCAGE 	        N	    Chaîne	2	    Type de blocage, doit exister dans IzyPro
        22  CODE_BLOCAGE	        N	    Chaîne	15	    Code de blocage, doit exister dans IzyPro et être lié au type de blocage
        23  REMARQUE	            N	    Chaîne	60	    Free remark field
                                                            (Empty if none, but no spaces)



        */


        companyInfoL.get();

        csvBufferP.InsertEntry(lineNoP, 1, Format(2)); //TYPE DE LIGNE	O	Chaîne	1	Constante = 2
        if modifyP then
            csvBufferP.InsertEntry(lineNoP, 2, 'M')
        else
            csvBufferP.InsertEntry(lineNoP, 2, 'C');
        csvBufferP.InsertEntry(lineNoP, 3, PurchLineP."Document No."); // REF_OL
        csvBufferP.InsertEntry(lineNoP, 4, format(PurchLineP."Line No.") + indiceP); // REF_LIGOL
        csvBufferP.InsertEntry(lineNoP, 5, PurchLineP."No."); // CODE ARTICLE
        csvBufferP.InsertEntry(lineNoP, 6, companyInfoL."PRO Activity Code"); //CODE_ACTIVITE
        csvBufferP.InsertEntry(lineNoP, 7, format(QuantityP)); //QTE UG
        csvBufferP.InsertEntry(lineNoP, 8, format(QuantityP)); //QTE UG
        csvBufferP.InsertEntry(lineNoP, 9, 'U'); // TYPE_CDT_MIN - Constante = U
        csvBufferP.InsertEntry(lineNoP, 10, 'UC'); // CDT_MIN
        csvBufferP.InsertEntry(lineNoP, 11, '');
        csvBufferP.InsertEntry(lineNoP, 12, '');
        if dateExpP <> 0D then
            csvBufferP.InsertEntry(lineNoP, 13, Format(dateExpP, 0, '<day,2>/<month,2>/<year4>'))
        else
            csvBufferP.InsertEntry(lineNoP, 13, '');
        csvBufferP.InsertEntry(lineNoP, 14, lotNoP);
        csvBufferP.InsertEntry(lineNoP, 15, '');
        csvBufferP.InsertEntry(lineNoP, 16, '');
        csvBufferP.InsertEntry(lineNoP, 17, '');
        csvBufferP.InsertEntry(lineNoP, 18, '');
        csvBufferP.InsertEntry(lineNoP, 19, '');
        csvBufferP.InsertEntry(lineNoP, 20, '');
        csvBufferP.InsertEntry(lineNoP, 21, '');
        csvBufferP.InsertEntry(lineNoP, 22, '');
        csvBufferP.InsertEntry(lineNoP, 23, '');

    end;

    procedure readShipment()
    var

        salesShipmentL: record "Sales Shipment Header";
        nbrParcelL: integer;
    begin
        nbrParcelL := 3;
        if salesShipmentL.Get('102735') then begin
            if nbrParcelL > 1 then generateAdditionalParcel(salesShipmentL, nbrParcelL);
        end;


    end;

    local procedure generateAdditionalParcel(var salesShipmentHeaderP: record "Sales Shipment Header"; var nbrParcelP: integer)
    var
        additionalPackageL: Record "B2 Additional Package";
        i: integer;
    begin
        for i := 1 to nbrParcelP - 1 do begin
            if not additionalPackageL.get(salesShipmentHeaderP."No.", i) then begin
                additionalPackageL.Init();
                additionalPackageL."Shipment Header No." := salesShipmentHeaderP."No.";
                additionalPackageL."Line No." := i;
                additionalPackageL."Shipping Agent Code" := salesShipmentHeaderP."Shipping Agent Code";
                additionalPackageL.Insert(true);
            end;
        end;


    end;






}
