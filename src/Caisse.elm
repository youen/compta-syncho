module Caisse exposing (Caisse, ajouterJetonsPapier, cumulCB, decoder, donnerAuStand, encode, fondDeCaisse, jetonsVendus, ouvrir, recupererDuStand, rembourser, stockCaisse, stockStands, stockTotal, vendreCB, vendreEspeces)

import Json.Decode as Decode
import Json.Encode as Encode


type Caisse
    = Caisse
        { fondEnEuros : Int
        , stockCentrale : Int
        , cumulCBEnEuros : Int
        , stockDansLesStands : Int
        , cumulJetonsVendus : Int
        }


ouvrir : Int -> Int -> Caisse
ouvrir fond jetons =
    Caisse
        { fondEnEuros = fond
        , stockCentrale = jetons
        , cumulCBEnEuros = 0
        , stockDansLesStands = 0
        , cumulJetonsVendus = 0
        }


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
        ]


decoder : Decode.Decoder Caisse
decoder =
    Decode.map5
        (\f s c stands vendus ->
            Caisse
                { fondEnEuros = f
                , stockCentrale = s
                , cumulCBEnEuros = c
                , stockDansLesStands = stands
                , cumulJetonsVendus = vendus
                }
        )
        (Decode.field "fondEnEuros" Decode.int)
        (Decode.field "stockCentrale" Decode.int)
        (Decode.field "cumulCBEnEuros" Decode.int)
        (Decode.field "stockDansLesStands" Decode.int)
        (Decode.oneOf [ Decode.field "cumulJetonsVendus" Decode.int, Decode.succeed 0 ])
