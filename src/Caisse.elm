module Caisse exposing (Caisse, fondDeCaisse, ouvrir, stockCaisse, stockTotal, vendreEspeces)


type Caisse
    = Caisse
        { fondEnEuros : Int
        , jetonsInitiaux : Int
        }


ouvrir : Int -> Int -> Caisse
ouvrir fond jetons =
    Caisse
        { fondEnEuros = fond
        , jetonsInitiaux = jetons
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
                    { c | jetonsInitiaux = c.jetonsInitiaux - nbJetons, fondEnEuros = c.fondEnEuros + nbJetons }
            , aRendre = eurosRecus - nbJetons
            }
