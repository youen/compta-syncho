module ViewTest exposing (..)

import Main exposing (Model(..), view)
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (class, text, tag)
import Caisse
import Expect

suite : Test
suite =
    describe "Structure de la vue"
        [ test "Les outils et compteurs doivent être bien positionnés et le header supprimé" <|
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
                        , currentTime = 0
                        }
                    html = view model |> Query.fromHtml
                in
                Expect.all
                    [ -- Le titre "Caisse Centrale" ne doit plus être présent
                      \_ -> html |> Query.findAll [ tag "h1", text "Caisse Centrale" ] |> Query.count (Expect.equal 0)
                    
                    -- Le panneau de gauche doit contenir les outils ET les compteurs
                    , \_ -> html
                        |> Query.find [ class "gap-8" ] -- Panneau de gauche
                        |> Expect.all
                            [ Query.has [ text "QR Code Sync" ]
                            , Query.has [ text "Export CSV" ]
                            , Query.has [ text "Reset" ]
                            , Query.has [ text "Plein Écran" ]
                            , Query.has [ text "Désactiver Veille" ]
                            -- Il doit contenir les informations de la caisse (en majuscules selon l'implémentation)
                            , Query.has [ text "FOND: 150€" ]
                            , Query.has [ text "STOCK: 1000" ]
                            ]
                    
                    -- Le panneau de droite doit être exempt des outils
                    , \_ -> html
                        |> Query.find [ class "md:w-1/3" ] 
                        |> Expect.all
                            [ \panel -> panel |> Query.findAll [ text "QR Code Sync" ] |> Query.count (Expect.equal 0)
                            , \panel -> panel |> Query.findAll [ text "Export CSV" ] |> Query.count (Expect.equal 0)
                            ]
                    ]
                    ()
        ]
