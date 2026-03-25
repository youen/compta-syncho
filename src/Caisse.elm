module Caisse exposing (Caisse, cumulCB, fondDeCaisse, ouvrir, rembourser, stockCaisse, stockTotal, vendreCB, vendreEspeces)


type Caisse
    = Caisse
        { fondEnEuros : Int
        , jetonsInitiaux : Int
        , cumulCBEnEuros : Int
        }


ouvrir : Int -> Int -> Caisse
ouvrir fond jetons =
    Caisse
        { fondEnEuros = fond
        , jetonsInitiaux = jetons
        , cumulCBEnEuros = 0
        }


stockTotal : Caisse -> Int
stockTotal (Caisse c) =
    c.jetonsInitiaux


stockCaisse : Caisse -> Int
stockCaisse (Caisse c) =
    c.jetonsInitiaux


fondDeCaisse : Caisse -> Int
fondDeCaisse (Caisse c) =
    c.fondEnEuros


cumulCB : Caisse -> Int
cumulCB (Caisse c) =
    c.cumulCBEnEuros


vendreEspeces : Int -> Int -> Caisse -> Result String { caisse : Caisse, aRendre : Int }
vendreEspeces nbJetons eurosRecus (Caisse c) =
    if eurosRecus < nbJetons then
        Err "Montant reçu insuffisant"

    else if c.jetonsInitiaux < nbJetons then
        Err "Plus assez de jetons en caisse"

    else
        Ok
            { caisse =
                Caisse
                    { fondEnEuros = c.fondEnEuros + nbJetons
                    , jetonsInitiaux = c.jetonsInitiaux - nbJetons
                    , cumulCBEnEuros = c.cumulCBEnEuros
                    }
            , aRendre = eurosRecus - nbJetons
            }


vendreCB : Int -> Caisse -> Result String Caisse
vendreCB nbJetons (Caisse c) =
    if c.jetonsInitiaux < nbJetons then
        Err "Plus assez de jetons en caisse"

    else
        Ok
            (Caisse
                { fondEnEuros = c.fondEnEuros
                , jetonsInitiaux = c.jetonsInitiaux - nbJetons
                , cumulCBEnEuros = c.cumulCBEnEuros + nbJetons
                }
            )


rembourser : Int -> Caisse -> Result String Caisse
rembourser nbJetons (Caisse c) =
    if nbJetons > 5 then
        Err "Maximum 5 jetons remboursables à la fois"

    else if nbJetons > c.fondEnEuros then
        Err "Pas assez de liquide en caisse pour rembourser"

    else
        Ok
            (Caisse
                { fondEnEuros = c.fondEnEuros - nbJetons
                , jetonsInitiaux = c.jetonsInitiaux + nbJetons
                , cumulCBEnEuros = c.cumulCBEnEuros
                }
            )
