import { test as base, expect, Page } from '@playwright/test';
import testUsers from './test-users';
import UserActions from './actions';

const test = base.extend<CustomFixtures>({
    page: async ({ page }, use) => {
        await use(Object.assign(page, { userActions: new UserActions(page) }));
    },

    room: async ({ page }, use) => {
        await page.goto('/dashboard');
        await page.getByText('New Room').click();
        await expect(page).toHaveURL(/room/);
        const uuid = /((\w{4,12}-?)){5}/.exec(page.url())[0];
        await use({ page, uuid });
        await page.userActions.deleteRoom();
    },

    guestPage: async ({ browser }, use) => {
        const ctx = await browser.newContext({ storageState: { origins: [], cookies: [] } });
        const page = await ctx.newPage();
        await use(Object.assign(page, { userActions: new UserActions(page) }));
        await page.close();
        await ctx.close();
    },

    altPage: async ({ browser }, use) => {
        const ctx = await browser.newContext({ storageState: testUsers.secondary.storageState });
        const page = await ctx.newPage();
        await use(Object.assign(page, { userActions: new UserActions(page) }));
        await page.close();
        await ctx.close();
    },

    twoUserRoom: async ({ room: { page, uuid }, altPage }, use) => {
        await altPage.goto(`/rooms/${uuid}`);
        await altPage.userActions.requestAccess();
        await page.userActions.admitUser(testUsers.secondary.display_name);
        await expect(altPage.getByRole('code')).toContainText('Welcome to');
        await use({ page, uuid, altPage });
    },
});

export { test, expect };

type CustomFixtures = {
    page: PageWithActions;
    /** Create and enter a room as Primary user */
    room: { page: PageWithActions; uuid: string };
    /** Page authenticated as Secondary user */
    altPage: PageWithActions;
    /** Page with no authentication */
    guestPage: PageWithActions;
    /** Room owned by Primary user with Secondary user present */
    twoUserRoom: { page: PageWithActions; uuid: string; altPage: PageWithActions };
};

type PageWithActions = Page & { userActions: UserActions };
