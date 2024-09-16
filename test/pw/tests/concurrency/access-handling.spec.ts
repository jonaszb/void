import { test, expect } from '../../fixtures';
import testUsers from '../../test-users';

test.describe.parallel('Room concurrency tests - acces handling', () => {
    test('Guest access can be received and rejected', async ({ room: { page, uuid }, guestPage }) => {
        await guestPage.goto(`/rooms/${uuid}`);
        await guestPage.userActions.requestAccess('Richard Wagner');

        await page.userActions.denyUser('Richard Wagner');

        await expect(guestPage).toHaveURL(/access_denied/);
    });

    test('Guest access can be received and granted', async ({ room: { page, uuid }, guestPage }) => {
        await guestPage.goto(`/rooms/${uuid}`);
        await guestPage.userActions.requestAccess('Antonio Vivaldi');

        await page.userActions.admitUser('Antonio Vivaldi');

        await expect(guestPage).toHaveURL(new RegExp(`\/rooms\/${uuid}`));
    });

    test('User access can be received and rejected', async ({ room: { page, uuid }, altPage }) => {
        await altPage.goto(`/rooms/${uuid}`);
        await altPage.userActions.requestAccess();

        await page.userActions.denyUser(testUsers.secondary.display_name);

        await expect(altPage).toHaveURL(/access_denied/);
    });

    test('User access can be received and granted', async ({ room: { page, uuid }, altPage }) => {
        await altPage.goto(`/rooms/${uuid}`);
        await altPage.userActions.requestAccess();

        await page.userActions.admitUser(testUsers.secondary.display_name);

        await expect(altPage).toHaveURL(new RegExp(`\/rooms\/${uuid}`));
    });

    test('Non-owners do not see access requests', async ({ twoUserRoom: { page, altPage, uuid }, guestPage }) => {
        await guestPage.goto(`/rooms/${uuid}`);
        await guestPage.userActions.requestAccess('Leonard Bernstein');

        await page.getByText('Leonard Bernstein').waitFor();
        await expect(altPage.getByText('Leonard Bernstein')).toBeHidden();
    });
});
