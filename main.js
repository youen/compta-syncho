import './src/style.css'
import { Elm } from './src/Main.elm'
import QRCode from 'qrcode'

// Récupération de l'état (URL > LocalStorage > null)
const getInitialState = () => {
    const hash = window.location.hash
    if (hash.startsWith('#state=')) {
        try {
            return atob(hash.substring(7));
        } catch (e) {
            console.error("Erreur décodage Hash", e);
        }
    }
    return localStorage.getItem('caisse_state');
}

const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: getInitialState()
})

// Persistence
app.ports.sauvegarderCaisse.subscribe(function(state) {
    localStorage.setItem('caisse_state', JSON.stringify(state));
});

app.ports.effacerCaisse.subscribe(function() {
    localStorage.removeItem('caisse_state');
});

// QR Code
app.ports.genererQRCode.subscribe(function(stateJson) {
    const url = window.location.origin + window.location.pathname + '#state=' + btoa(stateJson);
    QRCode.toDataURL(url, { width: 400, margin: 2 }, function (err, urlData) {
        if (err) console.error(err)
        app.ports.qrcodeRecu.send(urlData);
    })
});

// CSV Export
app.ports.exporterCSV.subscribe(function(state) {
    const rows = [
        ["Date", new Date().toLocaleString()],
        ["Fond de caisse", state.fondEnEuros + "€"],
        ["Ventes CB", state.cumulCBEnEuros + "€"],
        ["Jetons Vendus (Net)", state.cumulJetonsVendus],
        ["Total Espèces (Théorique)", state.fondEnEuros + "€"],
        ["Stock Central", state.stockCentrale],
        ["Stock Stands", state.stockDansLesStands],
        ["Total Jetons", state.stockCentrale + state.stockDansLesStands]
    ];
    
    let csvContent = "data:text/csv;charset=utf-8," 
        + rows.map(e => e.join(",")).join("\n");
        
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "cloture_caisse_" + new Date().toISOString().split('T')[0] + ".csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
});

// Gestion de la veille (Wake Lock)
let wakeLock = null;
const requestWakeLock = async () => {
    try {
        if ('wakeLock' in navigator) {
            wakeLock = await navigator.wakeLock.request('screen');
            console.log('Wake Lock est actif');
            wakeLock.addEventListener('release', () => {
                console.log('Wake Lock relâché');
            });
        }
    } catch (err) {
        console.error(`${err.name}, ${err.message}`);
    }
};

// Demander le wake lock au démarrage
requestWakeLock();

// Réactiver le Wake Lock si l'ongle redevient visible
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
        requestWakeLock();
    }
});
