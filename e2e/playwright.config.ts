import { defineConfig, devices } from '@playwright/test';

const baseURL = process.env.PAEDIA_WEB_URL ?? 'http://localhost:7358';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: 'list',
  use: {
    baseURL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: process.env.PAEDIA_SKIP_WEB_SERVER
    ? undefined
    : {
        command: 'cd .. && flutter run -d web-server --web-port=7358 --web-hostname=localhost',
        url: baseURL,
        reuseExistingServer: !process.env.CI,
        timeout: 120_000,
      },
});
