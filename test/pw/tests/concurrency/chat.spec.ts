import { test, expect } from '../../fixtures';

test.describe.parallel('Room concurrency tests - chat', () => {
    test('Users can send chat messages to the Room', async ({ twoUserRoom: { page, altPage } }) => {
        const latestMessage = page.getByRole('listitem', { name: 'Message' }).first();
        const latestMessageAlt = altPage.getByRole('listitem', { name: 'Message' }).first();

        await test.step('Send first message', async () => {
            await page.userActions.selectRoomTab('Chat');
            await altPage.userActions.selectRoomTab('Chat');

            await page.userActions.sendMessage('_SYN_');

            await expect(latestMessage).toContainText('_SYN_');
            await expect(latestMessageAlt).toContainText('_SYN_');
        });

        await test.step('Reply to the message', async () => {
            await latestMessageAlt.hover();
            await altPage.getByRole('button', { name: 'Reply' }).click();
            await altPage.userActions.sendMessage('_SYN-ACK_');

            // The reply should contain the new message and the original one
            await expect(latestMessage).toContainText('_SYN_');
            await expect(latestMessageAlt).toContainText('_SYN_');
            await expect(latestMessage).toContainText('_SYN-ACK_');
            await expect(latestMessageAlt).toContainText('_SYN-ACK_');
        });

        await test.step('Reply to the reply', async () => {
            await latestMessage.hover();
            await page.getByRole('button', { name: 'Reply' }).first().click();
            await page.userActions.sendMessage('_ACK_');

            // The reply should contain the new message and the previous one, but not the message the original reply responded to
            await expect(latestMessage).not.toContainText('_SYN_');
            await expect(latestMessageAlt).not.toContainText('_SYN_');
            await expect(latestMessage).toContainText('_SYN-ACK_');
            await expect(latestMessageAlt).toContainText('_SYN-ACK_');
            await expect(latestMessage).toContainText('_ACK_');
            await expect(latestMessageAlt).toContainText('_ACK_');
        });
    });

    //     await test.step('Ensure both users are editors', async () => {
    //         await page.userActions.makeEditor(testUsers.secondary.display_name);
    //         await expect(page.locator('#editor-lock')).toBeHidden();
    //         await expect(altPage.locator('#editor-lock')).toBeHidden();
    //     });

    //     await test.step('First edit (by primary user)', async () => {
    //         await page.userActions.setCaretPosition(0, 0);
    //         await page.userActions.typeInEditor(`\n`);
    //         await page.userActions.setCaretPosition(0, 0);
    //         await page.userActions.typeInEditor(`World`);
    //         await expect(page.getByRole('code')).toContainText('World');
    //     });

    //     await test.step('Second edit (by secondary user)', async () => {
    //         await altPage.userActions.setCaretPosition(0, 0);
    //         await altPage.userActions.typeInEditor('Hello ');
    //         await expect(altPage.getByRole('code')).toContainText('Hello World');
    //         await expect(page.getByRole('code')).toContainText('Hello World');
    //     });

    //     await test.step('Third edit (by primary user)', async () => {
    //         // Ensure caret position remains unchanged while other user edits
    //         await page.userActions.typeInEditor('!');
    //         await expect(altPage.getByRole('code')).toContainText('Hello World!');
    //         await expect(page.getByRole('code')).toContainText('Hello World!');
    //     });
    // });
});
