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

export default Hooks;
