let Hooks = {};

let isReadOnly = false;
let userColors = {};

Hooks.MonacoEditor = {
    mounted() {
        const monacoLoader = window.require;

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
                if (e.isFlush) return; // Do nothing if the change is not caused by this user
                if (!isReadOnly) {
                    const contents = this.editor.getValue();
                    this.pushEvent('update_room_state', { room_state: { contents } });
                }
            });

            this.userCursors = {}; // Store other users' cursor decorations

            // Listen for cursor position changes and send to LiveView
            this.editor.onDidChangeCursorPosition(({ position }) => {
                this.pushEvent('cursor_position_change', {
                    lineNumber: position.lineNumber,
                    column: position.column,
                });
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
                        node.className = 'cursor blink';
                        node.style.borderLeft = `2px solid ${userColors[userId]}`;
                        node.style.height = '1em';
                        node.style.position = 'absolute';
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
