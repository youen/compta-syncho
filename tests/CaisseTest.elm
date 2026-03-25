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
        , test "Vendre 12 jetons avec 20€ doit rendre 8€, diminuer le stock de jetons et augmenter le fond (US #2)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    result =
                        Caisse.vendreEspeces 12 20 caisseInitiale
                in
                case result of
                    Ok { caisse, aRendre } ->
                        Expect.all
                            [ \_ -> Expect.equal 8 aRendre
                            , \_ -> Expect.equal (1000 - 12) (Caisse.stockCaisse caisse)
                            , \_ -> Expect.equal (150 + 12) (Caisse.fondDeCaisse caisse)
                            ]
                            ()

                    Err _ ->
                        Expect.fail "La vente n'aurait pas dû échouer."
        , test "Vendre avec montant insuffisant doit renvoyer une erreur" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    result =
                        Caisse.vendreEspeces 12 10 caisseInitiale
                in
                case result of
                    Err "Montant reçu insuffisant" ->
                        Expect.pass

                    _ ->
                        Expect.fail "Devrait refuser la vente car on donne moins que le coût."
        , test "Vendre plus de jetons qu'en stock doit renvoyer une erreur" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 10

                    result =
                        Caisse.vendreEspeces 12 20 caisseInitiale
                in
                case result of
                    Err "Plus assez de jetons en caisse" ->
                        Expect.pass

                    _ ->
                        Expect.fail "Devrait refuser car stock insuffisant."
        , test "Vendre par CB décrémente le stock et incrémente le cumul CB (US #3)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    result =
                        Caisse.vendreCB 5 caisseInitiale
                in
                case result of
                    Ok caissePostVente ->
                        Expect.all
                            [ \_ -> Expect.equal (1000 - 5) (Caisse.stockCaisse caissePostVente)
                            , \_ -> Expect.equal 150 (Caisse.fondDeCaisse caissePostVente)
                            , \_ -> Expect.equal 5 (Caisse.cumulCB caissePostVente)
                            ]
                            ()

                    Err _ ->
                        Expect.fail "La vente CB n'aurait pas dû échouer."
        , test "Vendre par CB plus de jetons qu'en stock doit renvoyer une erreur" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 3

                    result =
                        Caisse.vendreCB 5 caisseInitiale
                in
                case result of
                    Err "Plus assez de jetons en caisse" ->
                        Expect.pass

                    _ ->
                        Expect.fail "La vente aurait dû échouer pour cause de stock insuffisant."
        ]
