let Hooks = {};

let isReadOnly = false;

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
                if (!isReadOnly) {
                    const contents = this.editor.getValue();
                    this.pushEvent('update_room_state', { room_state: { contents } });
                }
            });

            window.addEventListener('toggle-darkmode', this.updateTheme.bind(this));
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
