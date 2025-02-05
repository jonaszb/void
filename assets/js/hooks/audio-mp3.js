import { Howl } from 'howler';

export default {
    sounds: {},

    mounted() {
        this.sounds = this.setupSounds(JSON.parse(this.el.dataset.sounds));

        // Received instruction from the server to play a sound
        window.addEventListener('phx:play-sound', ({ detail: { name, force } }) => {
            this.playSound(name, force);
        });

        // Local request to play a sound
        window.addEventListener('js:play-sound', ({ detail: { name, force } }) => {
            this.playSound(name, force);
        });

        window.addEventListener('js:stop-sound', ({ detail: { name, force } }) => {
            this.stopSound(name, force);
        });

        // Received server instruction to stop playing a sound
        window.addEventListener('phx:stop-sound', ({ detail: { name, force } }) => {
            this.stopSound(name, force);
        });
    },

    destroyed() {
        Object.entries(this.sounds).forEach((entry) => {
            var [key, value] = entry;
            value.unload();
        });
    },

    // Play the named sound
    playSound(name, force = false) {
        if (document.hidden || force)
            if (this.sounds[name]) {
                this.sounds[name].play();
            }
    },

    // Stop the named sound
    stopSound(name) {
        if (this.sounds[name]) {
            this.sounds[name].stop();
        } else {
            console.warn('STOP: No sound "' + name + '" found');
        }
    },

    // Setup the sounds. Load them as Howl objects. Return setup sound object with
    // sounds ready for playing. Key is name, Value is Howl object.
    setupSounds(obj) {
        Object.entries(obj).forEach((entry) => {
            var [key, value] = entry;
            obj[key] = new Howl({
                src: value,
                preload: true,
                onplayerror: function () {
                    console.error('FAILED to play' + key);
                },
            });
        });
        return obj;
    },
};
