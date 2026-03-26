import { defineConfig } from 'vite'
import elmPlugin from 'vite-plugin-elm'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
    base: '/compta-syncho/',
    plugins: [
        elmPlugin(),
        VitePWA({
            registerType: 'autoUpdate',
            manifest: {
                name: 'Caisse Jeton Synchro',
                short_name: 'Caisse Synchro',
                description: 'Caisse pour la vente de jetons Synchro',
                theme_color: '#ffffff',
                background_color: '#ffffff',
                display: 'standalone',
                icons: [
                    {
                        src: 'icon-192x192.png',
                        sizes: '192x192',
                        type: 'image/png'
                    },
                    {
                        src: 'icon-512x512.png',
                        sizes: '512x512',
                        type: 'image/png'
                    }
                ]
            }
        })
    ]
})
