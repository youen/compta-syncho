module EdgeCaseTest exposing (..)

import Caisse
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Caisse - Cas Limites et Robustesse"
        [ describe "Initialisation"
            [ test "On peut initialiser une caisse avec 0€ et 0 jetons" <|
                \_ ->
                    let
                        caisse = Caisse.ouvrir 0 0
                    in
                    Expect.all
                        [ \c -> Expect.equal 0 (Caisse.fondDeCaisse c)
                        , \c -> Expect.equal 0 (Caisse.stockCaisse c)
                        ]
                        caisse
            , test "L'initialisation avec des valeurs négatives est-elle possible ? (Dépend de si Main filtre)" <|
                \_ ->
                    -- Actuellement Caisse.ouvrir prend des Int. 
                    -- Si on passe du négatif, que se passe-t-il ?
                    let
                        caisse = Caisse.ouvrir -10 -100
                    in
                    Expect.all
                        [ \c -> Expect.equal -10 (Caisse.fondDeCaisse c)
                        , \c -> Expect.equal -100 (Caisse.stockCaisse c)
                        ]
                        caisse
            ]
        , describe "Ventes et Fonds"
            [ test "On ne peut pas vendre si le stock est épuisé (0 jetons)" <|
                \_ ->
                    let
                        caisse = Caisse.ouvrir 100 0
                    in
                    case Caisse.vendreEspeces 1 10 0 caisse of
                        Err msg -> Expect.equal "Plus assez de jetons en caisse" msg
                        Ok _ -> Expect.fail "La vente aurait dû échouer."
            , test "On ne peut pas vendre un nombre négatif de jetons" <|
                \_ ->
                    let
                        caisse = Caisse.ouvrir 100 100
                    in
                    case Caisse.vendreEspeces -1 10 0 caisse of
                        Err _ -> Expect.pass
                        Ok _ -> Expect.fail "Vendre un nombre négatif devrait être interdit."
            , test "Vendre avec 0 jetons demandés" <|
                \_ ->
                    -- Actuellement Main empêche cela, mais la logique métier ?
                    let
                        caisse = Caisse.ouvrir 100 100
                    in
                    case Caisse.vendreEspeces 0 10 0 caisse of
                        Err _ -> Expect.pass
                        Ok _ -> Expect.fail "Vendre 0 jetons devrait être interdit."
            , test "Vendre exactement le dernier jeton" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 100 1
                    in
                    case Caisse.vendreEspeces 1 1 0 caisseInit of
                        Ok { caisse } -> Expect.equal 0 (Caisse.stockCaisse caisse)
                        Err _ -> Expect.fail "Devrait pouvoir vendre le dernier jeton."
            ]
        , describe "Remboursements"
            [ test "Rembourser pile 5 jetons (limite haute)" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 100 100
                    in
                    case Caisse.vendreEspeces 5 5 0 caisseInit of
                        Ok { caisse } ->
                            case Caisse.rembourser 5 0 caisse of
                                Ok _ -> Expect.pass
                                Err msg -> Expect.fail ("5 jetons devraient être acceptés : " ++ msg)
                        Err _ -> Expect.fail "Setup failed"
            , test "Rembourser plus que le fond de caisse disponible" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 0 100 -- Fond de 0€
                    in
                    case Caisse.vendreEspeces 1 1 0 caisseInit of
                        Ok { caisse } ->
                            case Caisse.rembourser 2 0 caisse of
                                Err msg -> Expect.equal "Pas assez de liquide en caisse pour rembourser" msg
                                Ok _ -> Expect.fail "Le remboursement aurait dû échouer car fond de caisse < 2€."
                        Err _ -> Expect.fail "Setup failed"
            , test "Rembourser un nombre négatif de jetons" <|
                \_ ->
                    let
                        caisse = Caisse.ouvrir 100 100
                    in
                    case Caisse.rembourser -1 0 caisse of
                        Err _ -> Expect.pass
                        Ok _ -> Expect.fail "Rembourser un nombre négatif devrait être interdit."
            ]
        , describe "Logistique / Stands"
            [ test "Donner plus de jetons qu'on en a en centrale" <|
                \_ ->
                    let
                        caisse = Caisse.ouvrir 100 10
                    in
                    case Caisse.donnerAuStand 11 0 caisse of
                        Err msg -> Expect.equal "Pas assez de jetons en caisse centrale" msg
                        Ok _ -> Expect.fail "N'aurait pas dû permettre de donner 11 jetons quand on en a 10."
            , test "Récupérer plus de jetons que les stands n'en ont" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 100 100
                    in
                    case Caisse.donnerAuStand 20 0 caisseInit of
                        Ok caisseAvecStands ->
                            case Caisse.recupererDuStand 21 0 caisseAvecStands of
                                Err msg -> Expect.equal "Le stand n'a pas autant de jetons" msg
                                Ok _ -> Expect.fail "N'aurait pas dû permettre de récupérer 21 jetons quand les stands en ont 20."
                        Err _ -> Expect.fail "Setup failed."
            , test "Mouvement de stock négatif (Donner)" <|
                \_ ->
                    let
                        caisse = Caisse.ouvrir 100 100
                    in
                    case Caisse.donnerAuStand -1 0 caisse of
                        Err _ -> Expect.pass
                        Ok _ -> Expect.fail "Donner un nombre négatif devrait être interdit."
            ]
        , describe "Intégrité des données"
            [ test "Le stock total (Centrale + Stands) reste-t-il constant après un mouvement ?" <|
                \_ ->
                    let
                        caisseInit = Caisse.ouvrir 100 1000
                        totalAvant = Caisse.stockTotal caisseInit
                    in
                    case Caisse.donnerAuStand 300 0 caisseInit of
                        Ok caisseApres ->
                            Expect.equal totalAvant (Caisse.stockTotal caisseApres)
                        Err _ -> Expect.fail "Mouvement échoué."
            ]
        ]
