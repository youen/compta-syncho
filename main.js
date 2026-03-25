import './src/style.css'
import { Elm } from './src/Main.elm'

const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: localStorage.getItem('caisse_state')
})

app.ports.sauvegarderCaisse.subscribe(function(state) {
    localStorage.setItem('caisse_state', JSON.stringify(state));
});
