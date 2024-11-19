import { defineConfig } from '@playwright/test';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);

const __dirname = path.dirname(__filename);

// Read from ".env" file.
dotenv.config({ path: path.resolve(__dirname, '.env.local') });

export default defineConfig({
  testDir: 'src/tests',
  webServer: {
    command: 'vite',
    port: 6006,
    // Ensures the server starts before running tests
    timeout: 120 * 1000, // Waits longer for the server to start if necessary
    reuseExistingServer: true,
  },
  use: {
    viewport: { width: 1920, height: 1080 }, // Set to screen resolution
    launchOptions: {
      args: ['--start-fullscreen', '--force-device-scale-factor=1.5'], // For Chrome/Edge full-screen
    },
    baseURL: process.env.VITE_HOST || 'http://localhost:6006',
  },
});
