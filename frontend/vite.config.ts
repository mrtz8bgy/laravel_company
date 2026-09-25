import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { defineConfig, type Plugin } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

const frontendRoot = path.dirname(fileURLToPath(import.meta.url))
const appDir = path.resolve(frontendRoot, '../backend/public/app')
const publicDir = path.resolve(frontendRoot, '../backend/public')
const shellDir = path.resolve(frontendRoot, '../backend/resources/spa')

const bootScript = `<script>(function(){var path=location.pathname.replace(/\\\\/g,'/');var marker='/backend/public';var at=path.indexOf(marker);var basePath=at>=0?path.slice(0,at+marker.length):'';window.__VCOS_BASE__=basePath;if(!document.querySelector('base')){var el=document.createElement('base');el.href=location.origin+(basePath||'')+'/';document.head.appendChild(el);}})();</script>`

function publishSpaShell(): Plugin {
  return {
    name: 'publish-spa-shell',
    apply: 'build',
    closeBundle() {
      const builtIndex = path.join(appDir, 'index.html')
      if (!fs.existsSync(builtIndex)) return
      let html = fs.readFileSync(builtIndex, 'utf8')
      html = html.replace(/<script>\s*if \(!\['5173', '4173'\][\s\S]*?<\/script>\s*/g, '')
      html = html.replace(/\s+crossorigin(?:="[^"]*")?/g, '')
      html = html.replace(/(src|href)="\.\/assets\//g, '$1="app/assets/')
      html = html.replace(/<head([^>]*)>/i, `<head$1>${bootScript}`)
      html = html.replace(
        '<div id="app"></div>',
        '<div id="app"><p id="boot-status" style="font-family:Tahoma,sans-serif;padding:2rem;text-align:center">در حال بارگذاری سامانه…</p></div>',
      )
      html = html.replace(
        '</body>',
        '<script>setTimeout(function(){var el=document.getElementById("boot-status");if(!el)return;el.textContent="رابط بارگذاری نشد. آدرس را روی backend/public بگذارید، نه پوشه frontend.";},6000)</script></body>',
      )
      fs.mkdirSync(shellDir, { recursive: true })
      fs.writeFileSync(path.join(shellDir, 'index.html'), html)
      fs.writeFileSync(path.join(publicDir, 'index.html'), html)
      fs.unlinkSync(builtIndex)
      const blocking = path.join(appDir, '.htaccess')
      if (fs.existsSync(blocking)) fs.unlinkSync(blocking)
    },
  }
}

export default defineConfig({
  plugins: [vue(), tailwindcss(), publishSpaShell()],
  // Relative names. The Apache shell resolves them from backend/public.
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
