module Caisse exposing (Caisse, Transaction, ajouterJetonsPapier, cumulCB, decoder, donnerAuStand, encode, fondDeCaisse, historique, jetonsVendus, ouvrir, recupererDuStand, rembourser, stockCaisse, stockStands, stockTotal, vendreCB, vendreEspeces)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Transaction =
    { horodatage : Int
    , montant : Int
    , type_ : String
    }


type Caisse
    = Caisse
        { fondEnEuros : Int
        , stockCentrale : Int
        , cumulCBEnEuros : Int
        , stockDansLesStands : Int
        , cumulJetonsVendus : Int
        , historique : List Transaction
        }


ouvrir : Int -> Int -> Caisse
ouvrir fond jetons =
    Caisse
        { fondEnEuros = fond
        , stockCentrale = jetons
        , cumulCBEnEuros = 0
        , stockDansLesStands = 0
        , cumulJetonsVendus = 0
        , historique = []
        }


historique : Caisse -> List Transaction
historique (Caisse c) =
    c.historique


stockTotal : Caisse -> Int
stockTotal (Caisse c) =
    c.stockCentrale + c.stockDansLesStands


stockCaisse : Caisse -> Int
stockCaisse (Caisse c) =
    c.stockCentrale


stockStands : Caisse -> Int
stockStands (Caisse c) =
    c.stockDansLesStands


fondDeCaisse : Caisse -> Int
fondDeCaisse (Caisse c) =
    c.fondEnEuros


cumulCB : Caisse -> Int
cumulCB (Caisse c) =
    c.cumulCBEnEuros


jetonsVendus : Caisse -> Int
jetonsVendus (Caisse c) =
    c.cumulJetonsVendus


vendreEspeces : Int -> Int -> Caisse -> Result String { caisse : Caisse, aRendre : Int }
vendreEspeces nbJetons eurosRecus (Caisse c) =
    if nbJetons <= 0 then
        Err "Le nombre de jetons doit être supérieur à zero"

    else if eurosRecus < nbJetons then
        Err "Montant reçu insuffisant"

    else if c.stockCentrale < nbJetons then
        Err "Plus assez de jetons en caisse"

    else
        Ok
            { caisse =
                Caisse
                    { fondEnEuros = c.fondEnEuros + nbJetons
                    , stockCentrale = c.stockCentrale - nbJetons
                    , cumulCBEnEuros = c.cumulCBEnEuros
                    , stockDansLesStands = c.stockDansLesStands
                    , cumulJetonsVendus = c.cumulJetonsVendus + nbJetons
                    , historique = c.historique
                    }
            , aRendre = eurosRecus - nbJetons
            }


vendreCB : Int -> Caisse -> Result String Caisse
vendreCB nbJetons (Caisse c) =
    if nbJetons <= 0 then
        Err "Le nombre de jetons doit être supérieur à zero"

    else if c.stockCentrale < nbJetons then
        Err "Plus assez de jetons en caisse"

    else
        Ok
            (Caisse
                { fondEnEuros = c.fondEnEuros
                , stockCentrale = c.stockCentrale - nbJetons
                , cumulCBEnEuros = c.cumulCBEnEuros + nbJetons
                , stockDansLesStands = c.stockDansLesStands
                , cumulJetonsVendus = c.cumulJetonsVendus + nbJetons
                , historique = c.historique
                }
            )


rembourser : Int -> Caisse -> Result String Caisse
rembourser nbJetons (Caisse c) =
    if nbJetons <= 0 then
        Err "Le nombre de jetons doit être supérieur à zero"

    else if nbJetons > 5 then
        Err "Maximum 5 jetons remboursables à la fois"

    else if nbJetons > c.fondEnEuros then
        Err "Pas assez de liquide en caisse pour rembourser"

    else
        Ok
            (Caisse
                { fondEnEuros = c.fondEnEuros - nbJetons
                , stockCentrale = c.stockCentrale + nbJetons
                , cumulCBEnEuros = c.cumulCBEnEuros
                , stockDansLesStands = c.stockDansLesStands
                , cumulJetonsVendus = c.cumulJetonsVendus - nbJetons
                , historique = c.historique
                }
            )


donnerAuStand : Int -> Caisse -> Result String Caisse
donnerAuStand nbJetons (Caisse c) =
    if nbJetons <= 0 then
        Err "Le nombre de jetons doit être supérieur à zero"

    else if c.stockCentrale < nbJetons then
        Err "Pas assez de jetons en caisse centrale"

    else
        Ok
            (Caisse
                { c | stockCentrale = c.stockCentrale - nbJetons, stockDansLesStands = c.stockDansLesStands + nbJetons }
            )


recupererDuStand : Int -> Caisse -> Result String Caisse
recupererDuStand nbJetons (Caisse c) =
    if nbJetons <= 0 then
        Err "Le nombre de jetons doit être supérieur à zero"

    else if c.stockDansLesStands < nbJetons then
        Err "Le stand n'a pas autant de jetons"

    else
        Ok
            (Caisse
                { c | stockCentrale = c.stockCentrale + nbJetons, stockDansLesStands = c.stockDansLesStands - nbJetons }
            )


ajouterJetonsPapier : Int -> Caisse -> Caisse
ajouterJetonsPapier nbJetons (Caisse c) =
    Caisse
        { c | stockCentrale = c.stockCentrale + nbJetons }


-- JSON


encode : Caisse -> Encode.Value
encode (Caisse c) =
    Encode.object
        [ ( "fondEnEuros", Encode.int c.fondEnEuros )
        , ( "stockCentrale", Encode.int c.stockCentrale )
        , ( "cumulCBEnEuros", Encode.int c.cumulCBEnEuros )
        , ( "stockDansLesStands", Encode.int c.stockDansLesStands )
        , ( "cumulJetonsVendus", Encode.int c.cumulJetonsVendus )
        , ( "historique", Encode.list encodeTransaction c.historique )
        ]


encodeTransaction : Transaction -> Encode.Value
encodeTransaction t =
    Encode.object
        [ ( "horodatage", Encode.int t.horodatage )
        , ( "montant", Encode.int t.montant )
        , ( "type_", Encode.string t.type_ )
        ]


decoder : Decode.Decoder Caisse
decoder =
    Decode.map6
        (\f s c stands vendus h ->
            Caisse
                { fondEnEuros = f
                , stockCentrale = s
                , cumulCBEnEuros = c
                , stockDansLesStands = stands
                , cumulJetonsVendus = vendus
                , historique = h
                }
        )
        (Decode.field "fondEnEuros" Decode.int)
        (Decode.field "stockCentrale" Decode.int)
        (Decode.field "cumulCBEnEuros" Decode.int)
        (Decode.field "stockDansLesStands" Decode.int)
        (Decode.oneOf [ Decode.field "cumulJetonsVendus" Decode.int, Decode.succeed 0 ])
        (Decode.oneOf [ Decode.field "historique" (Decode.list decoderTransaction), Decode.succeed [] ])


decoderTransaction : Decode.Decoder Transaction
decoderTransaction =
    Decode.map3 Transaction
        (Decode.field "horodatage" Decode.int)
        (Decode.field "montant" Decode.int)
        (Decode.field "type_" Decode.string)
