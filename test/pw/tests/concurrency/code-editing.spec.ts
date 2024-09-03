import { test, expect } from '../../fixtures';
import testUsers from '../../test-users';

test.describe.parallel('Room concurrency tests - code editing', () => {
    test('User can be made editor', async ({ twoUserRoom: { page, altPage } }) => {
        await test.step('Verify the owner is the initial editor', async () => {
            await expect(page.locator('#editor-lock')).toBeHidden();
            await page.userActions.typeInEditor('Hello World!');
            await expect(page.getByRole('code')).toContainText('Hello World!');
        });

        await test.step('Verify alt user is in read-only mode', async () => {
            await expect(altPage.locator('#editor-lock')).toBeVisible();
            await altPage.userActions.typeInEditor('testing');
            await expect(altPage.getByRole('code')).not.toContainText('testing');
        });

        await test.step('Editor role can be passed to another user', async () => {
            await page.userActions.makeEditor(testUsers.secondary.display_name);
            // Verify lock icon is displayed/hidden
            await expect(page.locator('#editor-lock')).toBeVisible();
            await expect(altPage.locator('#editor-lock')).toBeHidden();
            // Verify Primary user cannot edit
            await page.userActions.typeInEditor('blocked');
            await expect(altPage.getByRole('code')).not.toContainText('blocked');
            // and Secondary user can
            await altPage.userActions.setCaretPosition(0, 5);
            await altPage.userActions.typeInEditor(' cruel');
            await expect(altPage.getByRole('code')).toContainText('Hello cruel World!');
            // Ensure changes are broadcasted to other users
            await expect(page.getByRole('code')).toContainText('Hello cruel World!');
        });

        await test.step('Editor role can be returned', async () => {
            await altPage.userActions.makeEditor(testUsers.primary.display_name);
            await expect(page.locator('#editor-lock')).toBeHidden();
            await expect(altPage.locator('#editor-lock')).toBeVisible();
        });
    });

    test('Owner can take back editor role', async ({ twoUserRoom: { page } }) => {
        await page.userActions.makeEditor(testUsers.secondary.display_name);
        await page.locator('#editor-lock').waitFor();
        await page.userActions.takeEditorRole();
        await expect(page.locator('#editor-lock')).toBeHidden();
    });
});
