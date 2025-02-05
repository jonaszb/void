export default {
    mounted() {
        let isReadOnly = false;
        let userColors = {};

        const monacoLoader = window.require;
        const overlay = document.getElementById('loading-overlay');
        this.isRemoteUpdate = false;

        monacoLoader.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.50.0/min/vs' } });

        monacoLoader(['vs/editor/editor.main'], () => {
            isReadOnly = this.el.dataset.read_only === 'true';
            const language = this.el.dataset.language;
            const theme = document.documentElement.classList.contains('dark') ? 'vs-dark' : 'vs';
            let model;

            if (language === 'javascript' || language === 'typescript') {
                // type definition for testing
                fetch('https://unpkg.com/@types/react/index.d.ts')
                    .then((response) => response.text())
                    .then((dts) => {
                        monaco.languages.typescript.typescriptDefaults.addExtraLib(
                            dts,
                            'file:///node_modules/@types/react/index.d.ts'
                        );
                    });

                // fetch('https://unpkg.com/@playwright/test@1.49.1/index.d.ts')
                //     .then((response) => response.text())
                //     .then((dts) => {
                //         monaco.languages.typescript.typescriptDefaults.addExtraLib(
                //             dts,
                //             'file:///node_modules/@types/@playwright/test/index.d.ts'
                //         );
                //     });

                // fetch('https://unpkg.com/@types/react-dom/index.d.ts')
                //     .then((response) => response.text())
                //     .then((dts) => {
                //         monaco.languages.typescript.typescriptDefaults.addExtraLib(
                //             dts,
                //             'file:///node_modules/@types/react-dom/index.d.ts'
                //         );
                //     });

                const uri = monaco.Uri.parse(`file:///main.tsx`); // Example URI

                model = monaco.editor.createModel(this.el.dataset.content, language, uri);

                monaco.languages.typescript.typescriptDefaults.setCompilerOptions({
                    module: monaco.languages.typescript.ModuleKind.ESNext, // Ensure ES module support
                    moduleResolution: monaco.languages.typescript.ModuleResolutionKind.NodeJs, // Use Node-style resolution
                    target: monaco.languages.typescript.ScriptTarget.ESNext, // Latest ES version
                    allowSyntheticDefaultImports: true,
                    esModuleInterop: true,
                    jsx: 'react',
                    baseUrl: '.',
                    // paths: {
                    //     react: ['https://esm.sh/react'],
                    //     'react-dom': ['https://esm.sh/react-dom'],
                    // },
                });

                monaco.languages.typescript.typescriptDefaults.setDiagnosticsOptions({
                    noSemanticValidation: false,
                    noSyntaxValidation: false,
                });
            }

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
                model,
            });

            if (overlay) {
                overlay.style.display = 'none';
            }

            this.editor.onDidChangeModelContent((e) => {
                if (e.isFlush || this.isRemoteUpdate || isReadOnly) return; // Do nothing if the change is not caused by this user
                this.pushEvent('update_editor_state', { changes: e.changes, full_value: this.editor.getValue() });
            });

            this.userCursors = {};

            this.editor.onDidChangeCursorPosition(({ position }) => {
                this.pushEvent('cursor_position_change', {
                    lineNumber: position.lineNumber,
                    column: position.column,
                });
            });

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

                this.isRemoteUpdate = true;
                this.editor.getModel().pushEditOperations(this.editor.getSelections(), changes, () => null);
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
                setLanguageConfig(language, this.editor);
                monaco.editor.setModelLanguage(this.editor.getModel(), language);
            }
        });

        this.handleEvent('set_read_only', ({ read_only }) => {
            isReadOnly = read_only;
            this.editor.updateOptions({ readOnly: read_only });
        });

        setLanguageConfig = (language, editor) => {
            if (language === 'javascript' || language == 'typescript') {
                // fetch modules
                // fetch('https://unpkg.com/@types/react/index.d.ts')
                //     .then((response) => response.text())
                //     .then((dts) => {
                //         monaco.languages.typescript.typescriptDefaults.addExtraLib(
                //             dts,
                //             'file:///node_modules/@types/react/index.d.ts'
                //         );
                //     });

                // fetch('https://unpkg.com/@playwright/test@1.49.1/index.d.ts')
                //     .then((response) => response.text())
                //     .then((dts) => {
                //         monaco.languages.typescript.typescriptDefaults.addExtraLib(
                //             dts,
                //             'file:///node_modules/@types/@playwright/test/index.d.ts'
                //         );
                //     });

                // fetch('https://unpkg.com/@types/react-dom/index.d.ts')
                //     .then((response) => response.text())
                //     .then((dts) => {
                //         monaco.languages.typescript.typescriptDefaults.addExtraLib(
                //             dts,
                //             'file:///node_modules/@types/react-dom/index.d.ts'
                //         );
                //     });

                console.log(editor.getValue());
            }
        };
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
