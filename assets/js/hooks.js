try {
    let { Howl } = require('howler');
} catch {}
let Hooks = {};

let isReadOnly = false;
let userColors = {};

Hooks.MonacoEditor = {
    mounted() {
        const monacoLoader = window.require;
        this.isRemoteUpdate = false;

        monacoLoader.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.50.0/min/vs' } });

        monacoLoader(['vs/editor/editor.main'], () => {
            isReadOnly = this.el.dataset.read_only === 'true';
            const language = this.el.dataset.language;
            const theme = document.documentElement.classList.contains('dark') ? 'vs-dark' : 'vs';

            this.editor = monaco.editor.create(document.getElementById('editor'), {
                value: this.el.dataset.content,
                language: language || 'javascript',
                readOnly: isReadOnly,
                automaticLayout: true,
                renderValidationDecorations: 'on',
                padding: {
                    top: 12,
                    bottom: 12,
                },
                theme,
            });
            this.editor.onDidChangeModelContent((e) => {
                if (e.isFlush || this.isRemoteUpdate || isReadOnly) return; // Do nothing if the change is not caused by this user
                this.pushEvent('update_editor_state', { changes: e.changes, full_value: this.editor.getValue() });
            });

            this.userCursors = {}; // Store other users' cursor decorations

            // Listen for cursor position changes and send to LiveView
            this.editor.onDidChangeCursorPosition(({ position }) => {
                this.pushEvent('cursor_position_change', {
                    lineNumber: position.lineNumber,
                    column: position.column,
                });
            });

            // Listen for incoming changes from LiveView
            this.handleEvent('apply_changes', (payload) => {
                const changes = payload.changes.map((change) => ({
                    range: new monaco.Range(
                        change.range.startLineNumber,
                        change.range.startColumn,
                        change.range.endLineNumber,
                        change.range.endColumn
                    ),
                    text: change.text,
                    forceMoveMarkers: true,
                }));

                // Apply the changes to the editor without a full text refresh
                this.isRemoteUpdate = true;
                this.editor.getModel().pushEditOperations(this.editor.getSelections(), changes, () => null);
                // this.editor.executeEdits('remote', changes);
                this.isRemoteUpdate = false;
            });

            // Listen for incoming cursor positions from other users
            this.handleEvent('update_cursor_positions', ({ userId, position }) => {
                if (!userColors.hasOwnProperty(userId)) {
                    userColors[userId] = getCaretColor();
                }
                if (this.userCursors[userId]) {
                    this.editor.removeContentWidget(this.userCursors[userId]);
                }
                const widget = {
                    getId: () => `cursor-${userId}`,
                    getDomNode: () => {
                        const node = document.createElement('div');
                        node.className = 'z-[100] bottom-0 absolute h-4 hover:animate-none relative';
                        node.style.borderLeft = `2px solid ${userColors[userId]}`;
                        return node;
                    },
                    getPosition: () => {
                        return {
                            position: new monaco.Position(position.lineNumber, position.column),
                            preference: [monaco.editor.ContentWidgetPositionPreference.EXACT],
                        };
                    },
                };

                this.editor.addContentWidget(widget);
                this.userCursors[userId] = widget;
            });

            window.addEventListener('toggle-darkmode', this.updateTheme.bind(this));
        });

        this.handleEvent('remove_user_cursor', ({ userId }) => {
            if (this.userCursors[userId]) {
                this.editor.removeContentWidget(this.userCursors[userId]);
                delete this.userCursors[userId];
            }
        });

        this.handleEvent('update_editor', ({ content, language }) => {
            if (content !== undefined && this.editor.getValue() !== content) {
                this.editor.setValue(content || '');
            }
            if (language !== undefined && this.editor) {
                monaco.editor.setModelLanguage(this.editor.getModel(), language);
            }
        });

        this.handleEvent('set_read_only', ({ read_only }) => {
            isReadOnly = read_only;
            this.editor.updateOptions({ readOnly: read_only });
        });
    },

    updated() {
        // const newContent = this.el.dataset.content;
        // if (this.editor && newContent !== this.editor.getValue()) {
        //     this.editor.setValue(newContent);
        // }
    },

    updateTheme() {
        const theme = document.documentElement.classList.contains('dark') ? 'vs-dark' : 'vs';
        if (this.editor) {
            monaco.editor.setTheme(theme); // Dynamically update the theme
        }
    },

    destroyed() {
        window.removeEventListener('toggle-darkmode', this.updateTheme.bind(this));
    },
};

Hooks.FormatTimestampsHook = {
    mounted() {
        this.formatTimestamps();
    },
    updated() {
        this.formatTimestamps();
    },
    formatTimestamps() {
        const timeElements = this.el.querySelectorAll('time[msg-timestamp]');

        timeElements.forEach((timeElement) => {
            const timestampIso = timeElement.getAttribute('msg-timestamp');
            const date = new Date(timestampIso);

            const now = new Date();
            let formattedDate;

            if (date.toDateString() === now.toDateString()) {
                formattedDate = new Intl.DateTimeFormat(undefined, {
                    hour: '2-digit',
                    minute: '2-digit',
                }).format(date);
            } else if (date.getFullYear() === now.getFullYear()) {
                formattedDate = new Intl.DateTimeFormat(undefined, {
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                }).format(date);
            } else {
                formattedDate = new Intl.DateTimeFormat(undefined, {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                }).format(date);
            }
            timeElement.textContent = formattedDate;
        });
    },
};

Hooks.Notification = {
    mounted() {
        const msgHeight = this.el.getBoundingClientRect().height + 8;
        const container = document.querySelector('#notifications-container');
        container.classList.add('transition-none');
        container.style.transform = `translateY(${msgHeight}px)`;
        setTimeout(() => {
            this.el.classList.remove('opacity-0', 'translate-y-full');
            this.el.classList.add('opacity-100', 'translate-y-0');
            container.classList.add('transition-all');
            container.classList.remove('transition-none');
            container.style.transform = `translateY(0px)`;
        }, 100);

        setTimeout(() => {
            this.pushEvent('remove_notification', { id: this.el.id });
        }, 5500);
    },
};

Hooks.AudioMp3 = {
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

export default Hooks;

function getCaretColor() {
    const colors = [
        '#FF0000', // Red
        '#FF7F00', // Orange
        '#00FF00', // Green
        '#00FFFF', // Cyan
        '#8B00FF', // Violet
        '#FF1493', // Deep Pink
        '#FF4500', // Orange Red
        '#32CD32', // Lime Green
        '#FFD700', // Gold
        '#00FA9A', // Medium Spring Green
        '#FF6347', // Tomato
        '#40E0D0', // Turquoise
        '#1E90FF', // Dodger Blue
        '#FF69B4', // Hot Pink
        '#ADFF2F', // Green Yellow
        '#FF00FF', // Magenta
        '#FF8C00', // Dark Orange
        '#7FFF00', // Chartreuse
    ];

    const randomIndex = Math.floor(Math.random() * colors.length);
    return colors[randomIndex];
}
