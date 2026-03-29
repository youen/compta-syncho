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
                    , \c -> Expect.equal 0 (Caisse.jetonsVendus c)
                    ]
                    caisse
        , test "Vendre 12 jetons avec 20€ doit rendre 8€, diminuer le stock de jetons et augmenter le fond (US #2)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    result =
                        Caisse.vendreEspeces 12 20 0 caisseInitiale
                in
                case result of
                    Ok { caisse, aRendre } ->
                        Expect.all
                            [ \_ -> Expect.equal 8 aRendre
                            , \_ -> Expect.equal (1000 - 12) (Caisse.stockCaisse caisse)
                            , \_ -> Expect.equal (150 + 12) (Caisse.fondDeCaisse caisse)
                            , \_ -> Expect.equal 12 (Caisse.jetonsVendus caisse)
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
                        Caisse.vendreEspeces 12 10 0 caisseInitiale
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
                        Caisse.vendreEspeces 12 20 0 caisseInitiale
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
                        Caisse.vendreCB 5 0 caisseInitiale
                in
                case result of
                    Ok caissePostVente ->
                        Expect.all
                            [ \_ -> Expect.equal (1000 - 5) (Caisse.stockCaisse caissePostVente)
                            , \_ -> Expect.equal 150 (Caisse.fondDeCaisse caissePostVente)
                            , \_ -> Expect.equal 5 (Caisse.cumulCB caissePostVente)
                            , \_ -> Expect.equal 5 (Caisse.jetonsVendus caissePostVente)
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
                        Caisse.vendreCB 5 0 caisseInitiale
                in
                case result of
                    Err "Plus assez de jetons en caisse" ->
                        Expect.pass

                    _ ->
                        Expect.fail "La vente aurait dû échouer pour cause de stock insuffisant."
        , test "Rembourser 3 jetons incrémente le stock et décrémente le fond de caisse (US #4)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    result =
                        case Caisse.vendreEspeces 5 5 0 caisseInitiale of
                            Ok { caisse } -> Caisse.rembourser 3 0 caisse
                            Err _ -> Err "Setup failed"
                in
                case result of
                    Ok caissePostRemboursement ->
                        Expect.all
                            [ \_ -> Expect.equal (1000 - 5 + 3) (Caisse.stockCaisse caissePostRemboursement)
                            , \_ -> Expect.equal (150 + 5 - 3) (Caisse.fondDeCaisse caissePostRemboursement)
                            , \_ -> Expect.equal (5 - 3) (Caisse.jetonsVendus caissePostRemboursement)
                            ]
                            ()

                    Err msg ->
                        Expect.fail ("Le remboursement n'aurait pas dû échouer : " ++ msg)
        , test "Rembourser plus de 5 jetons est bloqué et renvoie une erreur (US #4)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    result =
                        Caisse.rembourser 6 0 caisseInitiale
                in
                case result of
                    Err "Maximum 5 jetons remboursables à la fois" ->
                        Expect.pass

                    _ ->
                        Expect.fail "Le remboursement de > 5 jetons aurait dû être bloqué."
        , test "Rembourser plus d'argent que disponible dans le fond de caisse renvoie une erreur" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 0 1000

                    result =
                        case Caisse.vendreEspeces 1 1 0 caisseInitiale of
                            Ok { caisse } -> Caisse.rembourser 2 0 caisse
                            Err _ -> Err "Setup failed"
                in
                case result of
                    Err "Pas assez de liquide en caisse pour rembourser" ->
                        Expect.pass

                    _ ->
                        Expect.fail "Le remboursement aurait dû être bloqué car fond insuffisant."
        , test "Donner des jetons à un stand décrémente la caisse et incrémente le stockStand (US #5)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    result =
                        Caisse.donnerAuStand 200 0 caisseInitiale
                in
                case result of
                    Ok caisseApresDon ->
                        Expect.all
                            [ \_ -> Expect.equal (1000 - 200) (Caisse.stockCaisse caisseApresDon)
                            , \_ -> Expect.equal 200 (Caisse.stockStands caisseApresDon)
                            , \_ -> Expect.equal 1000 (Caisse.stockTotal caisseApresDon)
                            ]
                            ()

                    Err _ ->
                        Expect.fail "Le transfert n'aurait pas dû échouer."
        , test "Donner au stand échoue s'il n'y a pas assez de jetons en caisse" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 100

                    result =
                        Caisse.donnerAuStand 200 0 caisseInitiale
                in
                case result of
                    Err "Pas assez de jetons en caisse centrale" ->
                        Expect.pass

                    _ ->
                        Expect.fail "A répondu Ok à tort."
        , test "Récupérer des jetons d'un stand incrémente la caisse et décrémente stockStand (US #5)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000
                in
                case Caisse.donnerAuStand 200 0 caisseInitiale of
                    Ok caisseApresDon ->
                        case Caisse.recupererDuStand 50 0 caisseApresDon of
                            Ok caisseApresRecup ->
                                Expect.all
                                    [ \_ -> Expect.equal (800 + 50) (Caisse.stockCaisse caisseApresRecup)
                                    , \_ -> Expect.equal (200 - 50) (Caisse.stockStands caisseApresRecup)
                                    ]
                                    ()

                            Err _ ->
                                Expect.fail "Le retour n'aurait pas dû échouer."

                    Err _ ->
                        Expect.fail "Le don préalable n'aurait pas dû échouer."
        , test "Scénario utilisateur: la vente ajoute les jetons dans le stock des stands pour récupération ultérieure" <|
            \_ ->
                let
                    caisseOuverte =
                        Caisse.ouvrir 10 10
                in
                case Caisse.vendreEspeces 5 5 0 caisseOuverte of
                    Ok { caisse } ->
                        case Caisse.recupererDuStand 5 0 caisse of
                            Ok caisseFinale ->
                                Expect.equal 10 (Caisse.stockCaisse caisseFinale)

                            Err msg ->
                                Expect.fail ("La récupération a échoué : " ++ msg)

                    Err msg ->
                        Expect.fail ("La vente a échoué : " ++ msg)

        , test "Scénario utilisateur: la vente suivie d'un remboursement empêche la récupération par le stand" <|
            \_ ->
                let
                    caisseInit = Caisse.ouvrir 20 20
                in
                case Caisse.vendreEspeces 5 5 0 caisseInit of
                    Ok { caisse } ->
                        case Caisse.rembourser 5 0 caisse of
                            Ok caisseRemboursee ->
                                case Caisse.recupererDuStand 5 0 caisseRemboursee of
                                    Err msg -> 
                                        Expect.equal "Le stand n'a pas autant de jetons" msg
                                    Ok _ -> 
                                        Expect.fail "La récupération aurait dû échouer car les jetons ont été remboursés."
                            Err msg ->
                                Expect.fail ("Le remboursement a échoué : " ++ msg)
                    Err msg ->
                        Expect.fail ("La vente a échoué : " ++ msg)
        , test "Rembourser plus de jetons que ceux en circulation doit échouer" <|
            \_ ->
                let
                    caisseInit = Caisse.ouvrir 20 20
                in
                case Caisse.vendreEspeces 2 2 0 caisseInit of
                    Ok { caisse } ->
                        case Caisse.rembourser 3 0 caisse of
                            Err msg -> 
                                Expect.equal "Pas assez de jetons en circulation pour un remboursement" msg
                            Ok _ -> 
                                Expect.fail "Le remboursement aurait dû échouer car il dépasse les jetons en circulation."
                    Err _ -> Expect.fail "Setup failed."

        , test "Ajouter Jetons Papier incrémente uniquement le stock caisse et le stock total (US #5)" <|
            \_ ->
                let
                    caisseInitiale =
                        Caisse.ouvrir 150 1000

                    caisseApresAjoutPapier =
                        Caisse.ajouterJetonsPapier 300 0 caisseInitiale
                in
                Expect.all
                    [ \_ -> Expect.equal 1300 (Caisse.stockCaisse caisseApresAjoutPapier)
                    , \_ -> Expect.equal 1300 (Caisse.stockTotal caisseApresAjoutPapier)
                    ]
                    ()
        ]
