module ViewTest exposing (..)

import Main exposing (Model(..), view)
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (class, text)
import Caisse
import Expect

suite : Test
suite =
    describe "Structure de la vue"
        [ test "Les boutons de synchronisation et d'outils doivent avoir été déplacés de droite à gauche" <|
            \_ ->
                let
                    caisseInit = Caisse.ouvrir 150 1000
                    model = EnService 
                        { caisse = caisseInit
                        , jetonsEnCours = 0
                        , eurosRecusEnCours = 0
                        , messageErreur = Nothing
                        , messageSucces = Nothing
                        , qrCodeDataURL = Nothing
                        , resetConfirmVisible = False
                        , resetConfirmInput = ""
                        }
                    html = view model |> Query.fromHtml
                in
                Expect.all
                    [ \_ -> html
                        |> Query.find [ class "gap-8" ] -- Panneau de gauche
                        |> Expect.all
                            [ Query.has [ text "QR Code Sync" ]
                            , Query.has [ text "Export CSV" ]
                            , Query.has [ text "Reset" ]
                            , Query.has [ text "Plein Écran" ]
                            , Query.has [ text "Désactiver Veille" ]
                            ]
                    , \_ -> html
                        |> Query.find [ class "md:w-1/3" ] -- Panneau de droite
                        |> Expect.all
                            [ \panel -> panel |> Query.findAll [ text "QR Code Sync" ] |> Query.count (Expect.equal 0)
                            , \panel -> panel |> Query.findAll [ text "Export CSV" ] |> Query.count (Expect.equal 0)
                            , \panel -> panel |> Query.findAll [ text "Reset" ] |> Query.count (Expect.equal 0)
                            , \panel -> panel |> Query.findAll [ text "Plein Écran" ] |> Query.count (Expect.equal 0)
                            , \panel -> panel |> Query.findAll [ text "Désactiver Veille" ] |> Query.count (Expect.equal 0)
                            ]
                    ]
                    ()
        ]
