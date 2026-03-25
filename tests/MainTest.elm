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
                            init ()

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
                            init ()

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
                            init ()

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
                            EnService { caisse = caisseInit, jetonsEnCours = 0, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing }

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
                            EnService { caisse = caisseInit, jetonsEnCours = 12, eurosRecusEnCours = 20, messageErreur = Nothing, messageSucces = Nothing }

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
                            EnService { caisse = caisseInit, jetonsEnCours = 12, eurosRecusEnCours = 20, messageErreur = Nothing, messageSucces = Nothing }

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
                            EnService { caisse = caisseInit, jetonsEnCours = 10, eurosRecusEnCours = 0, messageErreur = Nothing, messageSucces = Nothing }

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
            ]
        ]
