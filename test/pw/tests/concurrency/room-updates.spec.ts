import { test, expect } from '../../fixtures';

test.describe.parallel('Room concurrency tests - room configuration', () => {
    test('Room name can be changed and updates for all users', async ({ twoUserRoom: { page, altPage } }) => {
        await page.userActions.selectRoomTab('Settings');
        await page.getByLabel('Room name').fill('New room name');
        await page.getByRole('button', { name: 'save' }).click();
        await expect(page.getByRole('heading')).toHaveText('New room name');
        await expect(altPage.getByRole('heading')).toHaveText('New room name');
    });
});
