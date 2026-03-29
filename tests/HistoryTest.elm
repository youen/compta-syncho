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
        , test "Une vente en espèces est enregistrée dans l'historique" <|
            \_ ->
                let
                    timestamp = 1711710000
                    caisseInitiale = Caisse.ouvrir 150 1000
                    result = Caisse.vendreEspeces 10 10 timestamp caisseInitiale
                in
                case result of
                    Ok { caisse } ->
                        Caisse.historique caisse
                            |> Expect.equal [ { horodatage = timestamp, montant = 10, type_ = "Espèces" } ]
                    _ ->
                        Expect.fail "La vente devrait réussir"
        , test "Une vente en CB est enregistrée dans l'historique" <|
            \_ ->
                let
                    timestamp = 1711710001
                    caisseInitiale = Caisse.ouvrir 150 1000
                    result = Caisse.vendreCB 5 timestamp caisseInitiale
                in
                case result of
                    Ok caisse ->
                        Caisse.historique caisse
                            |> Expect.equal [ { horodatage = timestamp, montant = 5, type_ = "CB" } ]
                    _ ->
                        Expect.fail "La vente CB devrait réussir"
        , test "Un remboursement est enregistré dans l'historique" <|
            \_ ->
                let
                    timestamp = 1711710002
                    caisseInit = Caisse.ouvrir 150 1000
                    result = 
                        case Caisse.vendreEspeces 5 5 0 caisseInit of
                            Ok { caisse } -> Caisse.rembourser 3 timestamp caisse
                            Err _ -> Err "Setup failed"
                in
                case result of
                    Ok caisse ->
                        Caisse.historique caisse
                            |> List.filter (\t -> t.type_ == "Remboursement")
                            |> Expect.equal [ { horodatage = timestamp, montant = 3, type_ = "Remboursement" } ]
                    Err msg ->
                        Expect.fail ("Le remboursement devrait réussir : " ++ msg)
        , test "Donner aux stands est enregistré dans l'historique" <|
            \_ ->
                let
                    timestamp = 1711710003
                    caisseInitiale = Caisse.ouvrir 150 1000
                    result = Caisse.donnerAuStand 50 timestamp caisseInitiale
                in
                case result of
                    Ok caisse ->
                        Caisse.historique caisse
                            |> Expect.equal [ { horodatage = timestamp, montant = 50, type_ = "Transfert Stand" } ]
                    _ ->
                        Expect.fail "Le transfert devrait réussir"
        , test "Récupérer des stands est enregistré dans l'historique" <|
            \_ ->
                let
                    timestamp = 1711710004
                    caisseInitiale = Caisse.ouvrir 150 1000
                in
                case Caisse.donnerAuStand 100 0 caisseInitiale of
                    Ok caisseAvecStands ->
                        case Caisse.recupererDuStand 40 timestamp caisseAvecStands of
                            Ok caisse ->
                                List.filter (\t -> t.type_ == "Récupération Stand") (Caisse.historique caisse)
                                    |> Expect.equal [ { horodatage = timestamp, montant = 40, type_ = "Récupération Stand" } ]
                            _ -> Expect.fail "La récupération devrait réussir"
                    _ -> Expect.fail "Le don devrait réussir"
        , test "Ajouter des jetons papier est enregistré dans l'historique" <|
            \_ ->
                let
                    timestamp = 1711710005
                    caisseInitiale = Caisse.ouvrir 150 1000
                    caisse = Caisse.ajouterJetonsPapier 100 timestamp caisseInitiale
                in
                Caisse.historique caisse
                    |> Expect.equal [ { horodatage = timestamp, montant = 100, type_ = "Ajout Papier" } ]
        ]
