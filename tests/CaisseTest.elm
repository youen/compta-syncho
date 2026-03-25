module CaisseTest exposing (..)

import Caisse exposing (Caisse)
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Caisse - Initialisation (US #1)"
        [ test "Ouvrir la caisse doit assigner le stock total au stock caisse, et conserver le fond de caisse" <|
            \_ ->
                let
                    fondEnEuros =
                        150

                    jetonsInitiaux =
                        1000

                    caisse : Caisse
                    caisse =
                        Caisse.ouvrir fondEnEuros jetonsInitiaux
                in
                Expect.all
                    [ \c -> Expect.equal jetonsInitiaux (Caisse.stockTotal c)
                    , \c -> Expect.equal jetonsInitiaux (Caisse.stockCaisse c)
                    , \c -> Expect.equal fondEnEuros (Caisse.fondDeCaisse c)
                    ]
                    caisse
        ]
