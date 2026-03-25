module Caisse exposing (Caisse, ajouterJetonsPapier, cumulCB, donnerAuStand, fondDeCaisse, ouvrir, recupererDuStand, rembourser, stockCaisse, stockStands, stockTotal, vendreCB, vendreEspeces)


type Caisse
    = Caisse
        { fondEnEuros : Int
        , stockCentrale : Int
        , cumulCBEnEuros : Int
        , stockDansLesStands : Int
        }


ouvrir : Int -> Int -> Caisse
ouvrir fond jetons =
    Caisse
        { fondEnEuros = fond
        , stockCentrale = jetons
        , cumulCBEnEuros = 0
        , stockDansLesStands = 0
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


vendreEspeces : Int -> Int -> Caisse -> Result String { caisse : Caisse, aRendre : Int }
vendreEspeces nbJetons eurosRecus (Caisse c) =
    if eurosRecus < nbJetons then
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
                    }
            , aRendre = eurosRecus - nbJetons
            }


vendreCB : Int -> Caisse -> Result String Caisse
vendreCB nbJetons (Caisse c) =
    if c.stockCentrale < nbJetons then
        Err "Plus assez de jetons en caisse"

    else
        Ok
            (Caisse
                { fondEnEuros = c.fondEnEuros
                , stockCentrale = c.stockCentrale - nbJetons
                , cumulCBEnEuros = c.cumulCBEnEuros + nbJetons
                , stockDansLesStands = c.stockDansLesStands
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
                , stockCentrale = c.stockCentrale + nbJetons
                , cumulCBEnEuros = c.cumulCBEnEuros
                , stockDansLesStands = c.stockDansLesStands
                }
            )


donnerAuStand : Int -> Caisse -> Result String Caisse
donnerAuStand nbJetons (Caisse c) =
    if c.stockCentrale < nbJetons then
        Err "Pas assez de jetons en caisse centrale"

    else
        Ok
            (Caisse
                { c | stockCentrale = c.stockCentrale - nbJetons, stockDansLesStands = c.stockDansLesStands + nbJetons }
            )


recupererDuStand : Int -> Caisse -> Result String Caisse
recupererDuStand nbJetons (Caisse c) =
    if c.stockDansLesStands < nbJetons then
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
