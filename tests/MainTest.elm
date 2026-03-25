module MainTest exposing (..)

import Caisse
import Expect
import Main exposing (Model(..), Msg(..), init, update)
import Test exposing (..)


suite : Test
suite =
    describe "Main - Flux de l'application (US #1)"
        [ test "L'envoi du message OuvrirCaisse passe le modèle en mode EnService avec la Caisse initialisée" <|
            \_ ->
                let
                    ( initialModel, _ ) =
                        init ()

                    fondEnEuros =
                        150

                    jetonsInitiaux =
                        1000

                    ( updatedModel, _ ) =
                        update (OuvrirCaisse fondEnEuros jetonsInitiaux) initialModel
                in
                case updatedModel of
                    EnService caisse ->
                        Expect.all
                            [ \c -> Expect.equal jetonsInitiaux (Caisse.stockTotal c)
                            , \c -> Expect.equal fondEnEuros (Caisse.fondDeCaisse c)
                            ]
                            caisse

                    Configuration ->
                        Expect.fail "Le modèle est resté bloqué sur l'écran de configuration."
        ]
