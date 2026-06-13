import { expect, test } from '@playwright/test';

test.describe('Paedia web smoke', () => {
  test('loads the app shell', async ({ page }) => {
    const response = await page.goto('/');
    expect(response?.ok()).toBeTruthy();

    await expect(page).toHaveTitle(/Paedia/i);
  });

  test('renders the Flutter web canvas', async ({ page }) => {
    await page.goto('/');

    const flutterRoot = page.locator('flutter-view, flt-glass-pane, canvas').first();
    await expect(flutterRoot).toBeVisible({ timeout: 30_000 });
  });

  test('takes a visual snapshot of the home screen', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/');

    await page.locator('flutter-view, flt-glass-pane, canvas').first().waitFor({
      state: 'visible',
      timeout: 30_000,
    });

    await page.waitForTimeout(2_000);
    await expect(page).toHaveScreenshot('home-screen.png', {
      maxDiffPixelRatio: 0.05,
    });
  });
});
