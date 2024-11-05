import { test, expect } from '../../fixtures';
import testUsers from '../../test-users';

test.describe.parallel('Room concurrency tests - room configuration', () => {
    test('Room name can be changed and updates for all users', async ({ twoUserRoom: { page, altPage } }) => {
        await page.userActions.selectRoomTab('Settings');
        await page.getByLabel('Room name').fill('Updated room name');
        await page.getByRole('button', { name: 'save' }).click();
        await expect(page.getByRole('heading')).toHaveText('Updated room name');
        await expect(altPage.getByRole('heading')).toHaveText('Updated room name');
    });

    test('Language can be changed and updates for all users', async ({ twoUserRoom: { page, altPage } }) => {
        const dropdown = page.getByRole('combobox', { name: 'Language' });
        const dropdownAlt = altPage.getByRole('combobox', { name: 'Language' });
        await test.step('Verify the default language is selected by default', async () => {
            await expect(dropdown).toHaveValue('typescript');
            await expect(dropdownAlt).toHaveValue('typescript');
        });

        await test.step('Ensure Viewers cannot change the language', async () => {
            await expect(dropdownAlt).toBeDisabled();
        });

        await test.step('Change language as owner', async () => {
            await dropdown.selectOption('Python');
            await expect(dropdownAlt).toHaveValue('python');
        });

        await test.step('Change language as editor', async () => {
            await page.userActions.makeEditor(testUsers.secondary.display_name);
            await dropdownAlt.selectOption('SCSS');
            await expect(dropdown).toHaveValue('scss');
        });
    });
});
