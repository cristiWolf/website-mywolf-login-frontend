import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 6006,
    host: true,
  },
  build: {
    outDir: 'build',
    rollupOptions: {
      output: {
        entryFileNames: `[name].js`,
        chunkFileNames: `[name].js`,
        assetFileNames: `[name].[ext]`,
      },
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './vitest.setup.ts',
    include: ['src/**/*.test.ts', 'src/**/*.test.tsx'],
    exclude: ['src/tests/e2e/**'],
    coverage: {
      exclude: ['**/index.ts', '**/**.test.**'],
      include: ['src'],
      reporter: ['lcov'],
    },
    deps: {
      optimizer: {
        web: {
          include: ['@wolf-gmbh/lupine-design-system'],
        },
      },
    },
  },
});
