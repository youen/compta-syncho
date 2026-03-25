module MainTest exposing (..)

import Caisse
import Expect
import Main exposing (Model(..), Msg(..), init, update)
import Test exposing (..)


suite : Test
suite =
    describe "Main - Flux de l'application (US #1)"
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

                    -- On configure les entrées
                    ( modelConf1, _ ) =
                        update (SetFond "150") initialModel

                    ( modelConf2, _ ) =
                        update (SetJetons "1000") modelConf1

                    ( updatedModel, _ ) =
                        update ValiderConfiguration modelConf2
                in
                case updatedModel of
                    EnService caisse ->
                        Expect.all
                            [ \c -> Expect.equal 1000 (Caisse.stockTotal c)
                            , \c -> Expect.equal 150 (Caisse.fondDeCaisse c)
                            ]
                            caisse

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
