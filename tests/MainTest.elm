module MainTest exposing (..)

import Caisse
import Expect
import Main exposing (Model(..), Msg(..), init, update)
import Test exposing (..)


suite : Test
suite =
    describe "Main - Flux de l'application"
        [ describe "US #1 - Configuration initiale"
            [ test "L'envoi des messages SetFond et SetJetons met à jour le modèle de Configuration" <|
                \_ ->
                    let
                        ( model1, _ ) =
                            init Nothing

                        ( model2, _ ) =
                            update (SetFond "150") model1

                        ( model3, _ ) =
                            update (SetJetons "1000") model2
                    in
                    case model3 of
                        Configuration { fondSaisi, jetonsSaisis } ->
                            Expect.all
                                [ \_ -> Expect.equal "150" fondSaisi
                                , \_ -> Expect.equal "1000" jetonsSaisis
                                ]
                                ()

                        EnService _ ->
                            Expect.fail "Le modèle ne devrait pas être EnService"
            , test "L'envoi du message ValiderConfiguration avec des entrées valides passe le modèle en mode EnService avec la Caisse initialisée" <|
                \_ ->
                    let
                        ( initialModel, _ ) =
                            init Nothing

                        ( modelConf1, _ ) =
                            update (SetFond "150") initialModel

                        ( modelConf2, _ ) =
                            update (SetJetons "1000") modelConf1

                        ( updatedModel, _ ) =
                            update ValiderConfiguration modelConf2
                    in
                    case updatedModel of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 1000 (Caisse.stockTotal state.caisse)
                                , \_ -> Expect.equal 150 (Caisse.fondDeCaisse state.caisse)
                                , \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal 0 state.eurosRecusEnCours
                                ]
                                ()

                        Configuration _ ->
                            Expect.fail "Le modèle est resté bloqué sur l'écran de configuration."
            , test "L'envoi du message ValiderConfiguration avec des entrées invalides ne passe pas en mode EnService" <|
                \_ ->
                    let
                        ( initialModel, _ ) =
                            init Nothing

                        ( modelConf, _ ) =
                            update (SetFond "abc") initialModel

                        ( updatedModel, _ ) =
                            update ValiderConfiguration modelConf
                    in
                    case updatedModel of
                        Configuration _ ->
                            Expect.pass

                        EnService _ ->
                            Expect.fail "Le modèle ne devrait pas passer EnService avec des entrées invalides."
            ]
        , describe "US #2 - Vente au comptant"
            [ test "Pendant le service, AjouterJetons et AjouterEuros mettent à jour le compteur en cours" <|
                \_ ->
                    let
                        caisseInit =
                            Caisse.ouvrir 150 1000

                        enServiceInit =
                            EnService { caisse = caisseInit, jetonsEnCours = 0, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }

                        ( model1, _ ) =
                            update (AjouterJetons 5) enServiceInit

                        ( model2, _ ) =
                            update (AjouterJetons 7) model1

                        ( model3, _ ) =
                            update (AjouterEuros 20) model2
                    in
                    case model3 of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 12 state.jetonsEnCours
                                , \_ -> Expect.equal 20 state.eurosRecusEnCours
                                ]
                                ()

                        _ ->
                            Expect.fail "Mauvais état."
            , test "Pendant le service, ValiderVenteEspece met à jour la caisse et réinitialise les compteurs s'il y a assez de stock et d'euros" <|
                \_ ->
                    let
                        caisseInit =
                            Caisse.ouvrir 150 1000

                        enServiceInit =
                            EnService { caisse = caisseInit, jetonsEnCours = 12, eurosRecusEnCours = 20, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }

                        ( modelMiseAJour, _ ) =
                            update ValiderVenteEspece enServiceInit
                    in
                    case modelMiseAJour of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal 0 state.eurosRecusEnCours
                                , \_ -> Expect.equal (1000 - 12) (Caisse.stockCaisse state.caisse)
                                , \_ -> Expect.equal (150 + 12) (Caisse.fondDeCaisse state.caisse)
                                , \_ -> Expect.equal (Just "Rendre : 8€") state.messageSucces
                                ]
                                ()

                        _ ->
                            Expect.fail "Mauvais état."
            , test "L'envoi du message AnnulerSaisie réinitialise les compteurs de jetons et d'euros en cours" <|
                \_ ->
                    let
                        caisseInit =
                            Caisse.ouvrir 150 1000

                        enServiceAvecSaisie =
                            EnService { caisse = caisseInit, jetonsEnCours = 12, eurosRecusEnCours = 20, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }

                        ( modelApresAnnulation, _ ) =
                            update AnnulerSaisie enServiceAvecSaisie
                    in
                    case modelApresAnnulation of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal 0 state.eurosRecusEnCours
                                ]
                                ()

                        _ ->
                            Expect.fail "Mauvais état."
            ]
        , describe "US #3 - Vente par CB"
            [ test "ValiderVenteCB met à jour la caisse et réinitialise les compteurs s'il y a assez de stock" <|
                \_ ->
                    let
                        caisseInit =
                            Caisse.ouvrir 150 1000

                        enServiceInit =
                            EnService { caisse = caisseInit, jetonsEnCours = 10, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }

                        ( modelApresValidation, _ ) =
                            update ValiderVenteCB enServiceInit
                    in
                    case modelApresValidation of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal 0 state.eurosRecusEnCours
                                , \_ -> Expect.equal (1000 - 10) (Caisse.stockCaisse state.caisse)
                                , \_ -> Expect.equal 10 (Caisse.cumulCB state.caisse)
                                , \_ -> Expect.equal (Just "Paiement CB validé : 10€") state.messageSucces
                                ]
                                ()

                        _ ->
                            Expect.fail "Mauvais état."
            , test "ValiderVenteCB réinitialise eurosRecusEnCours même si l'utilisateur a saisi du liquide" <|
                \_ ->
                    let
                        caisseInit =
                            Caisse.ouvrir 150 1000

                        enServiceInit =
                            EnService { caisse = caisseInit, jetonsEnCours = 10, eurosRecusEnCours = 5, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }

                        ( modelApresValidation, _ ) =
                            update ValiderVenteCB enServiceInit
                    in
                    case modelApresValidation of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal 0 state.eurosRecusEnCours
                                , \_ -> Expect.equal 10 (Caisse.cumulCB state.caisse)
                                ]
                                ()

                        _ ->
                            Expect.fail "Mauvais état."
            ]
        , describe "US #4 - Rembourser Client"
            [ test "RembourserClient avec 3 jetons met à jour la caisse et affiche un succès" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 150 1000
                        caisseApresVente = 
                            case Caisse.vendreEspeces 5 5 0 caisseInit of
                                Ok { caisse } -> caisse
                                Err _ -> caisseInit

                        enServiceInit =
                            EnService { caisse = caisseApresVente, jetonsEnCours = 3, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }

                        ( modelApresRemboursement, _ ) =
                            update RembourserClient enServiceInit
                    in
                    case modelApresRemboursement of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal (1000 - 5 + 3) (Caisse.stockCaisse state.caisse)
                                , \_ -> Expect.equal (150 + 5 - 3) (Caisse.fondDeCaisse state.caisse)
                                , \_ -> Expect.equal (Just "Remboursement effectué : 3€ rendus au client") state.messageSucces
                                ]
                                ()

                        _ ->
                            Expect.fail "Mauvais état."
            , test "RembourserClient avec 6 jetons est bloqué par la caisse et affiche une erreur" <|
                \_ ->
                    let
                        caisseInit =
                            Caisse.ouvrir 150 1000

                        enServiceInit =
                            EnService { caisse = caisseInit, jetonsEnCours = 6, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }

                        ( modelApresErreur, _ ) =
                            update RembourserClient enServiceInit
                    in
                    case modelApresErreur of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 6 state.jetonsEnCours
                                , \_ -> Expect.equal (Just "Maximum 5 jetons remboursables à la fois") state.messageErreur
                                ]
                                ()

                        _ ->
                            Expect.fail "Mauvais état."
            ]
        , describe "US #5 - Gestion des flux logistiques (Stands)"
            [ test "DonnerJetonsAuStand transfère les jetons vers les stands" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 150 1000
                        enServiceInit = EnService { caisse = caisseInit, jetonsEnCours = 100, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }
                        
                        ( modelApresDon, _ ) = update DonnerJetonsAuStand enServiceInit
                    in
                    case modelApresDon of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal (1000 - 100) (Caisse.stockCaisse state.caisse)
                                , \_ -> Expect.equal 100 (Caisse.stockStands state.caisse)
                                , \_ -> Expect.equal (Just "100 jetons envoyés aux stands") state.messageSucces
                                ]
                                ()
                        _ ->
                            Expect.fail "Mauvais état."

            , test "RecupererJetonsDuStand rapatrie les jetons des stands" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 150 1000
                    in
                    case Caisse.donnerAuStand 200 0 caisseInit of
                        Ok caisseAvecStands ->
                            let
                                enServiceInit = EnService { caisse = caisseAvecStands, jetonsEnCours = 50, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }
                                
                                ( modelApresRecup, _ ) = update RecupererJetonsDuStand enServiceInit
                            in
                            case modelApresRecup of
                                EnService state ->
                                    Expect.all
                                        [ \_ -> Expect.equal 0 state.jetonsEnCours
                                        , \_ -> Expect.equal (800 + 50) (Caisse.stockCaisse state.caisse)
                                        , \_ -> Expect.equal (200 - 50) (Caisse.stockStands state.caisse)
                                        , \_ -> Expect.equal (Just "50 jetons récupérés des stands") state.messageSucces
                                        ]
                                        ()
                                _ ->
                                    Expect.fail "Mauvais état."
                        Err _ ->
                            Expect.fail "Donner au stand a échoué dans le setup du test."

            , test "ApprovisionnerJetonsPapier ajoute des jetons au stock central" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 150 1000
                        enServiceInit = EnService { caisse = caisseInit, jetonsEnCours = 500, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }
                        
                        ( modelApresAppro, _ ) = update ApprovisionnerJetonsPapier enServiceInit
                    in
                    case modelApresAppro of
                        EnService state ->
                            Expect.all
                                [ \_ -> Expect.equal 0 state.jetonsEnCours
                                , \_ -> Expect.equal 1500 (Caisse.stockCaisse state.caisse)
                                , \_ -> Expect.equal (Just "500 jetons papier ajoutés à la caisse") state.messageSucces
                                ]
                                ()
                        _ ->
                            Expect.fail "Mauvais état."
            ]
        , describe "Fonctionnalité de Reset"
            [ test "DemanderReset affiche la modal" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 150 1000
                        enServiceInit = EnService { caisse = caisseInit, jetonsEnCours = 0, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = False, resetConfirmInput = "", currentTime = 0 }
                        ( modelFinal, _ ) = update DemanderReset enServiceInit
                    in
                    case modelFinal of
                        EnService state -> Expect.equal True state.resetConfirmVisible
                        _ -> Expect.fail "Mauvais état."

            , test "ConfirmerReset avec mauvais texte ne fait rien" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 150 1000
                        enServiceInit = EnService { caisse = caisseInit, jetonsEnCours = 0, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = True, resetConfirmInput = "WRONG", currentTime = 0 }
                        ( modelFinal, _ ) = update ConfirmerReset enServiceInit
                    in
                    case modelFinal of
                        EnService state -> 
                            Expect.all [ \_ -> Expect.equal True state.resetConfirmVisible ] ()
                        _ -> Expect.fail "N'aurait pas dû changer d'état."

            , test "ConfirmerReset avec 'RESET' repasse en Configuration" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 150 1000
                        enServiceInit = EnService { caisse = caisseInit, jetonsEnCours = 0, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing, qrCodeDataURL = Nothing, resetConfirmVisible = True, resetConfirmInput = "RESET", currentTime = 0 }
                        ( modelFinal, _ ) = update ConfirmerReset enServiceInit
                    in
                    case modelFinal of
                        Configuration _ -> Expect.pass
                        _ -> Expect.fail "Aurait dû repasser en Configuration."
            ]
        ]
