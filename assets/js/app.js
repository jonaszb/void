// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html';
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';
import topbar from '../vendor/topbar';
import hooks from './hooks';

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
    longPollFallbackMs: 2500,
    params: { _csrf_token: csrfToken },
    hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' });
window.addEventListener('phx:page-loading-start', (_info) => topbar.show(300));
window.addEventListener('phx:page-loading-stop', (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Theme mode handling
function darkExpected() {
    return (
        localStorage.theme === 'dark' ||
        (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)
    );
}

function initDarkMode() {
    // On page load or when changing themes, best to add inline in `head` to avoid FOUC
    if (darkExpected()) document.documentElement.classList.add('dark');
    else document.documentElement.classList.remove('dark');
}

window.addEventListener('toggle-darkmode', (e) => {
    if (darkExpected()) localStorage.theme = 'light';
    else localStorage.theme = 'dark';
    initDarkMode();
});

// document.addEventListener(
//     'click',
//     () => {
//         const audio = document.getElementById('message-sound');
//         if (audio) {
//             audio.play();
//         }
//     },
//     { once: true }
// );

initDarkMode();
