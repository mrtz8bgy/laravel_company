import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { defineConfig, type Plugin } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

const frontendRoot = path.dirname(fileURLToPath(import.meta.url))
const appDir = path.resolve(frontendRoot, '../backend/public/app')
const shellDir = path.resolve(frontendRoot, '../backend/resources/spa')

function publishSpaShell(): Plugin {
  return {
    name: 'publish-spa-shell',
    apply: 'build',
    closeBundle() {
      const builtIndex = path.join(appDir, 'index.html')
      if (!fs.existsSync(builtIndex)) return
      fs.mkdirSync(shellDir, { recursive: true })
      fs.copyFileSync(builtIndex, path.join(shellDir, 'index.html'))
      fs.unlinkSync(builtIndex)
      fs.writeFileSync(
        path.join(appDir, '.htaccess'),
        "Options -Indexes\n<Files \"index.html\">\n    Require all denied\n</Files>\n",
      )
    },
  }
}

export default defineConfig({
  plugins: [vue(), tailwindcss(), publishSpaShell()],
  // Relative asset names. Laravel rewrites them to the real XAMPP subdirectory.
  base: './',
  build: {
    outDir: appDir,
    emptyOutDir: true,
    assetsDir: 'assets',
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    allowedHosts: true,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1',
        changeOrigin: true,
        rewrite: (requestPath) => `/laravel_company/backend/public${requestPath}`,
      },
    },
  },
  preview: {
    host: '0.0.0.0',
    port: 5173,
    allowedHosts: true,
  },
})
