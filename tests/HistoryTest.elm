module HistoryTest exposing (..)

import Test exposing (..)
import Expect
import Caisse exposing (Caisse)

suite : Test
suite =
    describe "Historique des transactions"
        [ test "Une caisse ouverte n'a pas d'historique" <|
            \_ ->
                let
                    caisse = Caisse.ouvrir 150 1000
                in
                Caisse.historique caisse
                    |> Expect.equal []
        ]
