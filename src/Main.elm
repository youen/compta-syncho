module Main exposing (Model(..), Msg(..), init, main, update)

import Browser
import Caisse exposing (Caisse)
import Html exposing (Html, button, div, h1, h2, input, label, span, text)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


type Model
    = Configuration { fondSaisi : String, jetonsSaisis : String }
    | EnService
        { caisse : Caisse
        , jetonsEnCours : Int
        , eurosRecusEnCours : Int
        , messageErreur : Maybe String
        , messageSucces : Maybe String
        }


type Msg
    = SetFond String
    | SetJetons String
    | ValiderConfiguration
    | AjouterJetons Int
    | AjouterEuros Int
    | ValiderVenteEspece
    | ValiderVenteCB
    | AnnulerSaisie
    | RembourserClient


init : () -> ( Model, Cmd Msg )
init _ =
    ( Configuration { fondSaisi = "", jetonsSaisis = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetFond val ->
            case model of
                Configuration config ->
                    ( Configuration { config | fondSaisi = val }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SetJetons val ->
            case model of
                Configuration config ->
                    ( Configuration { config | jetonsSaisis = val }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ValiderConfiguration ->
            case model of
                Configuration { fondSaisi, jetonsSaisis } ->
                    case ( String.toInt fondSaisi, String.toInt jetonsSaisis ) of
                        ( Just fond, Just jetons ) ->
                            ( EnService
                                { caisse = Caisse.ouvrir fond jetons
                                , jetonsEnCours = 0
                                , eurosRecusEnCours = 0
                                , messageErreur = Nothing
                                , messageSucces = Nothing
                                }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        AjouterJetons quantite ->
            case model of
                EnService state ->
                    ( EnService { state | jetonsEnCours = state.jetonsEnCours + quantite, messageErreur = Nothing, messageSucces = Nothing }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        AjouterEuros euros ->
            case model of
                EnService state ->
                    ( EnService { state | eurosRecusEnCours = state.eurosRecusEnCours + euros, messageErreur = Nothing, messageSucces = Nothing }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ValiderVenteEspece ->
            case model of
                EnService state ->
                    if state.jetonsEnCours == 0 then
                        ( EnService { state | messageErreur = Just "Veuillez sélectionner au moins 1 jeton." }, Cmd.none )

                    else
                        case Caisse.vendreEspeces state.jetonsEnCours state.eurosRecusEnCours state.caisse of
                            Ok { caisse, aRendre } ->
                                ( EnService
                                    { state
                                        | caisse = caisse
                                        , jetonsEnCours = 0
                                        , eurosRecusEnCours = 0
                                        , messageErreur = Nothing
                                        , messageSucces = Just ("Rendre : " ++ String.fromInt aRendre ++ "€")
                                    }
                                , Cmd.none
                                )

                            Err erreur ->
                                ( EnService { state | messageErreur = Just erreur, messageSucces = Nothing }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        AnnulerSaisie ->
            case model of
                EnService state ->
                    ( EnService
                        { state
                            | jetonsEnCours = 0
                            , eurosRecusEnCours = 0
                            , messageErreur = Nothing
                            , messageSucces = Nothing
                        }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ValiderVenteCB ->
            case model of
                EnService state ->
                    if state.jetonsEnCours == 0 then
                        ( EnService { state | messageErreur = Just "Veuillez sélectionner au moins 1 jeton." }, Cmd.none )

                    else
                        case Caisse.vendreCB state.jetonsEnCours state.caisse of
                            Ok caisse ->
                                ( EnService
                                    { state
                                        | caisse = caisse
                                        , jetonsEnCours = 0
                                        , eurosRecusEnCours = 0
                                        , messageErreur = Nothing
                                        , messageSucces = Just ("Paiement CB validé : " ++ String.fromInt state.jetonsEnCours ++ "€")
                                    }
                                , Cmd.none
                                )

                            Err erreur ->
                                ( EnService { state | messageErreur = Just erreur, messageSucces = Nothing }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RembourserClient ->
            case model of
                EnService state ->
                    if state.jetonsEnCours == 0 then
                        ( EnService { state | messageErreur = Just "Veuillez sélectionner le nombre de jetons à rembourser." }, Cmd.none )

                    else
                        case Caisse.rembourser state.jetonsEnCours state.caisse of
                            Ok caisse ->
                                ( EnService
                                    { state
                                        | caisse = caisse
                                        , jetonsEnCours = 0
                                        , eurosRecusEnCours = 0
                                        , messageErreur = Nothing
                                        , messageSucces = Just ("Remboursement effectué : " ++ String.fromInt state.jetonsEnCours ++ "€ rendus au client")
                                    }
                                , Cmd.none
                                )

                            Err erreur ->
                                ( EnService { state | messageErreur = Just erreur, messageSucces = Nothing }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Configuration { fondSaisi, jetonsSaisis } ->
            div [ class "w-screen h-screen flex items-center justify-center bg-gray-50 p-6" ]
                [ div [ class "w-full max-w-lg bg-white p-10 rounded-3xl shadow-xl flex flex-col gap-8" ]
                    [ h1 [ class "font-display font-black text-primary text-4xl text-center uppercase tracking-tight" ]
                        [ text "Initialisation" ]
                    , div [ class "flex flex-col gap-6" ]
                        [ div [ class "flex flex-col gap-2" ]
                            [ label [ class "text-textDark font-semibold text-lg" ] [ text "Fond de caisse initial (€)" ]
                            , input
                                [ type_ "number"
                                , placeholder "Ex: 150"
                                , value fondSaisi
                                , onInput SetFond
                                , class "w-full text-2xl p-4 border-2 border-gray-200 rounded-2xl outline-none focus:border-primary transition-colors text-center font-bold"
                                ]
                                []
                            ]
                        , div [ class "flex flex-col gap-2" ]
                            [ label [ class "text-textDark font-semibold text-lg" ] [ text "Nombre de jetons initial" ]
                            , input
                                [ type_ "number"
                                , placeholder "Ex: 1000"
                                , value jetonsSaisis
                                , onInput SetJetons
                                , class "w-full text-2xl p-4 border-2 border-gray-200 rounded-2xl outline-none focus:border-primary transition-colors text-center font-bold"
                                ]
                                []
                            ]
                        ]
                    , button
                        [ onClick ValiderConfiguration
                        , class "mt-4 w-full bg-primary hover:bg-primaryDark active:scale-95 text-white font-bold py-5 rounded-2xl text-xl shadow-lg transition-all"
                        ]
                        [ text "Ouvrir la caisse" ]
                    ]
                ]

        EnService state ->
            div [ class "w-screen h-screen bg-bg flex flex-col" ]
                [ div [ class "w-full bg-dark text-white p-6 shadow-md flex justify-between items-center" ]
                    [ h1 [ class "font-display font-bold text-2xl uppercase tracking-wide text-primary" ]
                        [ text "Caisse Centrale" ]
                    , div [ class "text-sm text-gray-400 font-semibold" ]
                        [ text ("Stock: " ++ String.fromInt (Caisse.stockCaisse state.caisse) ++ " | Fond: " ++ String.fromInt (Caisse.fondDeCaisse state.caisse) ++ "€") ]
                    ]
                , div [ class "flex-1 flex flex-col md:flex-row p-6 gap-6" ]
                    [ -- Panneau Central (Jetons et Paiement)
                      div [ class "flex-1 bg-white p-6 rounded-3xl shadow-xl flex flex-col gap-8" ]
                        [ div []
                            [ h2 [ class "text-xl font-bold mb-4 text-textDark" ] [ text "1. Nombre de jetons" ]
                            , div [ class "flex gap-4" ]
                                [ button [ onClick (AjouterJetons 1), class "flex-1 bg-gray-100 hover:bg-gray-200 text-3xl p-6 rounded-2xl font-bold text-gray-800 transition-colors" ] [ text "+1" ]
                                , button [ onClick (AjouterJetons 5), class "flex-1 bg-gray-100 hover:bg-gray-200 text-3xl p-6 rounded-2xl font-bold text-gray-800 transition-colors" ] [ text "+5" ]
                                , button [ onClick (AjouterJetons 10), class "flex-1 bg-gray-100 hover:bg-gray-200 text-3xl p-6 rounded-2xl font-bold text-gray-800 transition-colors" ] [ text "+10" ]
                                ]
                            ]
                        , div []
                            [ h2 [ class "text-xl font-bold mb-4 text-textDark" ] [ text "2. Paiement reçu (€)" ]
                            , div [ class "grid grid-cols-5 gap-4" ]
                                [ button [ onClick (AjouterEuros 2), class "bg-green-100 hover:bg-green-200 text-green-800 font-bold p-4 rounded-xl text-xl" ] [ text "2€" ]
                                , button [ onClick (AjouterEuros 5), class "bg-green-100 hover:bg-green-200 text-green-800 font-bold p-4 rounded-xl text-xl" ] [ text "5€" ]
                                , button [ onClick (AjouterEuros 10), class "bg-green-100 hover:bg-green-200 text-green-800 font-bold p-4 rounded-xl text-xl" ] [ text "10€" ]
                                , button [ onClick (AjouterEuros 20), class "bg-green-100 hover:bg-green-200 text-green-800 font-bold p-4 rounded-xl text-xl" ] [ text "20€" ]
                                , button [ onClick (AjouterEuros 50), class "bg-green-100 hover:bg-green-200 text-green-800 font-bold p-4 rounded-xl text-xl" ] [ text "50€" ]
                                ]
                            ]
                        ]
                    , -- Panneau Latéral (Résumé)
                      div [ class "w-full md:w-1/3 bg-gray-50 p-6 rounded-3xl shadow-inner flex flex-col justify-between border-2 border-gray-200" ]
                        [ div [ class "flex flex-col gap-6" ]
                            [ h2 [ class "text-2xl font-black text-textDark border-b-2 border-gray-200 pb-4" ] [ text "Résumé Vente" ]
                            , div [ class "flex justify-between items-center text-xl" ]
                                [ text "Jetons :"
                                , span [ class "font-bold text-primary text-3xl" ] [ text (String.fromInt state.jetonsEnCours) ]
                                ]
                            , div [ class "flex justify-between items-center text-xl" ]
                                [ text "Total à payer :"
                                , span [ class "font-bold text-3xl" ] [ text (String.fromInt state.jetonsEnCours ++ "€") ]
                                ]
                            , div [ class "flex justify-between items-center text-xl" ]
                                [ text "Reçu :"
                                , span [ class "font-bold text-green-600 text-3xl" ] [ text (String.fromInt state.eurosRecusEnCours ++ "€") ]
                                ]
                            , case state.messageErreur of
                                Just err ->
                                    div [ class "bg-red-100 text-red-700 p-4 rounded-xl font-bold mt-4" ] [ text err ]

                                Nothing ->
                                    text ""
                            , case state.messageSucces of
                                Just msgSucces ->
                                    div [ class "bg-primary text-white p-4 rounded-xl font-bold text-2xl text-center shadow-lg mt-4 animate-bounce" ] [ text msgSucces ]

                                Nothing ->
                                    text ""
                            ]
                        , div [ class "flex gap-4 mt-8" ]
                            [ button
                                [ onClick AnnulerSaisie
                                , class "flex-1 bg-white text-gray-500 hover:bg-gray-100 hover:text-gray-800 font-bold p-6 rounded-2xl text-xl border-2 border-gray-200 active:scale-95 transition-all outline-none"
                                ]
                                [ text "Annuler" ]
                            ]
                        , div [ class "flex gap-4 mt-4" ]
                            [ button
                                [ onClick ValiderVenteEspece
                                , class "flex-1 bg-green-500 hover:bg-green-600 text-white font-bold p-6 rounded-2xl text-xl shadow-xl active:scale-95 transition-all outline-none"
                                ]
                                [ text "Valider Espèces" ]
                            , button
                                [ onClick ValiderVenteCB
                                , class "flex-1 bg-primary hover:bg-primaryDark text-white font-bold p-6 rounded-2xl text-xl shadow-xl active:scale-95 transition-all outline-none"
                                ]
                                [ text "Valider CB" ]
                            ]
                        , button
                            [ onClick RembourserClient
                            , class "w-full mt-4 bg-orange-500 hover:bg-orange-600 text-white font-bold p-6 rounded-2xl text-xl shadow-md active:scale-95 transition-all outline-none"
                            ]
                            [ text "Rembourser Client (max 5)" ]
                        ]
                    ]
                ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
