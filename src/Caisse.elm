module Caisse exposing (Caisse, fondDeCaisse, ouvrir, stockCaisse, stockTotal)


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
