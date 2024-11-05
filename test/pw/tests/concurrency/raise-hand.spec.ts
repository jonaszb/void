import { test, expect } from '../../fixtures';
import testUsers from '../../test-users';

test.describe.parallel('Room concurrency tests - raising hands', () => {
    test('Users can raise and lower their hand', async ({ twoUserRoom: { page, altPage } }) => {
        await altPage.userActions.raiseHand();
        await expect(page.getByTitle('Raised hand', { exact: true })).toBeVisible();
        await altPage.userActions.lowerHand();
        await expect(page.getByTitle('Raised hand', { exact: true })).toBeHidden();
    });

    test('Hand is lowered when becoming Editor', async ({ twoUserRoom: { page, altPage } }) => {
        await altPage.userActions.raiseHand();
        await expect(page.getByTitle('Raised hand', { exact: true })).toBeVisible();
        await page.userActions.makeEditor(testUsers.secondary.display_name);
        await expect(page.getByTitle('Raised hand', { exact: true })).toBeHidden();
    });

    test('Users are notified when a hand is raised', async ({ twoUserRoom: { page, altPage } }) => {
        await altPage.userActions.raiseHand();
        await expect(page.getByTitle('Raised hand notification')).toHaveText(testUsers.secondary.display_name);
        await expect(altPage.getByTitle('Raised hand notification')).toHaveText(testUsers.secondary.display_name);
    });
});
