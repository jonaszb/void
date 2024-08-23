let Hooks = {};

Hooks.MonacoEditor = {
    mounted() {
        const monacoLoader = window.require;

        monacoLoader.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.50.0/min/vs' } });

        monacoLoader(['vs/editor/editor.main'], () => {
            const isReadOnly = this.el.dataset.read_only === 'true';
            const theme = document.documentElement.classList.contains('dark') ? 'vs-dark' : 'vs';

            this.editor = monaco.editor.create(document.getElementById('editor'), {
                value: this.el.dataset.content,
                language: 'javascript',
                readOnly: isReadOnly,
                automaticLayout: true,
                padding: {
                    top: 12,
                    bottom: 12,
                },
                theme,
            });
            if (!isReadOnly) {
                this.editor.onDidChangeModelContent(() => {
                    const contents = this.editor.getValue();
                    this.pushEvent('update_room_state', { room_state: { contents } });
                });
            }

            window.addEventListener('toggle-darkmode', this.updateTheme.bind(this));
        });

        this.handleEvent('update_editor', ({ content }) => {
            if (this.editor.getValue() !== content) {
                this.editor.setValue(content || '');
            }
        });

        this.handleEvent('set_read_only', ({ read_only }) => {
            this.editor.updateOptions({ readOnly: read_only });
        });
    },

    updated() {
        const newContent = this.el.dataset.content;
        if (this.editor && newContent !== this.editor.getValue()) {
            this.editor.setValue(newContent);
        }
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

export default Hooks;
