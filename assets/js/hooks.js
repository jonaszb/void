let Hooks = {};

Hooks.MonacoEditor = {
    mounted() {
        const monacoLoader = window.require;

        monacoLoader.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.50.0/min/vs' } });

        monacoLoader(['vs/editor/editor.main'], () => {
            const isReadOnly = this.el.dataset.readOnly === 'true';
            const theme = document.documentElement.classList.contains('dark') ? 'vs-dark' : 'vs';

            this.editor = monaco.editor.create(document.getElementById('editor'), {
                value: this.el.dataset.content,
                language: 'javascript',
                readOnly: isReadOnly,
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

        this.handleEvent('update_editor', ({ content, is_read_only }) => {
            if (this.editor.getValue() !== content) {
                this.editor.setValue(content || '');
            }
            this.editor.updateOptions({ readOnly: is_read_only });
        });
    },

    updated() {
        const newContent = this.el.dataset.content;
        const isReadOnly = this.el.dataset.readOnly === 'true';
        if (this.editor && newContent !== this.editor.getValue()) {
            this.editor.setValue(newContent);
        }
        this.editor.updateOptions({ readOnly: isReadOnly });
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
