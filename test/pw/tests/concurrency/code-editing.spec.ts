import { test, expect } from '../../fixtures';
import testUsers from '../../test-users';

test.describe.parallel('Room concurrency tests - code editing', () => {
    test('User can be made editor', async ({ twoUserRoom: { page, altPage } }) => {
        await test.step('Verify the owner is the initial editor', async () => {
            await expect(page.locator('#editor-lock')).toBeHidden();
            await page.userActions.setCaretPosition(0, 0);
            await page.userActions.typeInEditor(`Hello World!\n`);
            await expect(page.getByRole('code')).toContainText('Hello World!');
        });

        await test.step('Verify alt user is in read-only mode', async () => {
            await expect(altPage.locator('#editor-lock')).toBeVisible();
            await altPage.userActions.typeInEditor('testing');
            await expect(altPage.getByRole('code')).not.toContainText('testing');
        });

        await test.step('Editor role can be granted to another user', async () => {
            await page.userActions.makeEditor(testUsers.secondary.display_name);
            // Verify lock icon is displayed/hidden
            await expect(altPage.locator('#editor-lock')).toBeHidden();
            await expect(altPage.getByText('You are now an editor')).toBeVisible();
            // Verify secondary user can edit
            await altPage.userActions.setCaretPosition(0, 5);
            await altPage.userActions.typeInEditor(' cruel');
            await expect(altPage.getByRole('code')).toContainText('Hello cruel World!');
            // Ensure changes are broadcasted to other users
            await expect(page.getByRole('code')).toContainText('Hello cruel World!');
        });

        await test.step('Editor role can be removed', async () => {
            await page.userActions.removeEditor(testUsers.secondary.display_name);
            await expect(altPage.locator('#editor-lock')).toBeVisible();
            await expect(altPage.getByText('You are no longer an editor')).toBeVisible();
        });
    });

    test('Concurrent editing on the same line', async ({ twoUserRoom: { page, altPage } }) => {
        await test.step('Ensure both users are editors', async () => {
            await page.userActions.makeEditor(testUsers.secondary.display_name);
            await expect(page.locator('#editor-lock')).toBeHidden();
            await expect(altPage.locator('#editor-lock')).toBeHidden();
        });

        await test.step('First edit (by primary user)', async () => {
            await page.userActions.setCaretPosition(0, 0);
            await page.userActions.typeInEditor(`\n`);
            await page.userActions.setCaretPosition(0, 0);
            await page.userActions.typeInEditor(`World`);
            await expect(page.getByRole('code')).toContainText('World');
        });

        await test.step('Second edit (by secondary user)', async () => {
            await altPage.userActions.setCaretPosition(0, 0);
            await altPage.userActions.typeInEditor('Hello ');
            await expect(altPage.getByRole('code')).toContainText('Hello World');
            await expect(page.getByRole('code')).toContainText('Hello World');
        });

        await test.step('Third edit (by primary user)', async () => {
            // Ensure caret position remains unchanged while other user edits
            await page.userActions.typeInEditor('!');
            await expect(altPage.getByRole('code')).toContainText('Hello World!');
            await expect(page.getByRole('code')).toContainText('Hello World!');
        });
    });
});
