import type { Page } from '@playwright/test';

export default class UserActions {
    constructor(private page: Page) {}

    async leaveRoom() {
        await this.page.getByTitle('Exit room').click();
    }

    async raiseHand() {
        await this.page.getByRole('button', { name: 'Raise hand' }).click();
    }

    async lowerHand() {
        await this.page.getByRole('button', { name: 'Lower hand' }).click();
    }

    async selectRoomTab(tabName: RoomTab) {
        await this.page.getByRole('tab', { name: tabName }).click();
    }

    async toggleRoomMenu() {
        await this.page.getByRole('button', { name: 'Toggle room menu' }).click();
    }

    async requestAccess(name?: string) {
        name && (await this.page.getByRole('textbox').pressSequentially(name, { delay: 25 }));
        await this.page.getByRole('button', { name: 'Request access' }).click();
    }

    async admitUser(name: string) {
        const userRow = this.page.getByRole('listitem', { name: 'Pending user' }).filter({ hasText: name });
        await userRow.getByRole('button', { name: 'admit' }).click();
    }

    async denyUser(name: string) {
        const userRow = this.page.getByRole('listitem', { name: 'Pending user' }).filter({ hasText: name });
        await userRow.getByRole('button', { name: 'deny' }).click();
    }

    async makeEditor(name: string) {
        const userRow = this.page.getByRole('listitem', { name: 'Room user' }).filter({ hasText: name });
        await userRow.getByRole('button', { name: 'Make editor' }).click();
    }

    async removeEditor(name: string) {
        const userRow = this.page.getByRole('listitem', { name: 'Room user' }).filter({ hasText: name });
        await userRow.getByRole('button', { name: 'Remove editor' }).click();
    }

    async deleteRoom() {
        await this.page.getByRole('tab', { name: 'Settings' }).click();
        this.page.on('dialog', (d) => d.accept());
        await this.page.getByText('Delete room').click();
    }

    async setCaretPosition(lineNumber: number, column: number) {
        await this.page.evaluate(
            ([lineNumber, column]) => {
                const win = window as any;
                const editor = win.monaco.editor.getEditors()[0];
                editor.setPosition({ lineNumber, column });
            },
            [lineNumber + 1, column + 1]
        );
    }

    async typeInEditor(text: string, options?: { delay?: number }) {
        await this.page.getByRole('code').getByRole('textbox').focus();
        await this.page.keyboard.type(text, { delay: options?.delay ?? 50 });
    }

    async clearEditor() {
        await this.page.getByRole('code').getByRole('textbox').clear();
    }

    async sendMessage(text: string) {
        await this.page.locator('#message_content').fill(text);
        await this.page.getByTitle('Send message').click();
    }
}

type RoomTab = 'Chat' | 'User list' | 'Settings';
