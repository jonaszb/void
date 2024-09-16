import { test as setup, expect } from '@playwright/test';
import testUsers from '../test-users';

setup.use({ headless: true });
for (const user of Object.values(testUsers)) {
    setup(`Create auth state: ${user.storageState}`, async ({ browser }) => {
        const context = await browser.newContext({ storageState: { cookies: [], origins: [] } });
        const page = await context.newPage();
        await page.goto('/dev/log_in');
        await page.getByLabel('Email').fill(user.email);
        await page.getByLabel('Password').fill(user.password);
        await page.getByRole('button', { name: 'Log in' }).click();
        await expect(page.getByText('Dashboard')).toBeVisible();

        await context.storageState({ path: user.storageState });
        await context.close();
    });
}
