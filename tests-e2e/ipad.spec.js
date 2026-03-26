import { test, expect } from '@playwright/test';

test.describe('Comportement iPad et Mobile', () => {

    test('L\'application doit empêcher le zoom intempestif au double-tap', async ({ page }) => {
        await page.goto('/');
        
        // On vérifie que les boutons ou éléments interactifs empêchent le zoom global
        // Une méthode courante est de vérifier que container global ou les boutons utilisent touch-action: manipulation
        // Mais plus globalement sur #app ou body c'est souvent touch-action: manipulation;
        const app = page.locator('body');
        
        // Ceci devrait échouer s'il n'y a pas la classe css ou style qui ajoute touch-action: manipulation
        // En playwright, on vérifie soit les classes tailwind (ex: touch-manipulation) soit la prop calculée
        await expect(app).toHaveCSS('touch-action', 'manipulation');
    });

    test('Le bas de l\'application n\'est pas tronqué (utilisation de dvh)', async ({ page }) => {
        await page.goto('/');
        
        // On veut s'assurer que le premier container plein écran utilise 100dvh et non 100vh pour Safari
        // Dans Elm, on génère <div class="w-screen h-screen ..."> par défaut
        // On vérifie que la classe n'est pas "h-screen" (100vh strict) mais on laisse dvh
        // Ou plus directement, vérifier que la hauteur calculée de l'élément contient 100dvh dans Inline style 
        // ou que la classe h-[100dvh] est utilisée.
        
        // On vérifie si y'a au moins un élement avec h-[100dvh] ou min-h-[100dvh] présent dans le dom root
        // h-screen en tailwind génère 100vh.
        const container = page.locator('.w-screen').first();
        
        // On vérifie que la classe css contient dvdh (ex: h-[100dvh] ou min-h-[100dvh]) ou n'utilise plus h-screen
        // Il doit être remplacé par h-[100dvh] ou `h-dvh` en Tailwind (v3.2+)
        await expect(container).toHaveClass(/h-\[100dvh\]|h-dvh/);
        await expect(container).not.toHaveClass(/h-screen/);
    });

    test('L\'application propose des options pour le plein écran et le screensaver', async ({ page }) => {
        await page.goto('/');
        
        // Passer l'écran de configuration
        await page.fill('input[placeholder="Ex: 150"]', '100');
        await page.fill('input[placeholder="Ex: 1000"]', '500');
        await page.click('button:has-text("Ouvrir la caisse")');
        
        // Vérifier la présence des boutons
        const btnPleinEcran = page.locator('button:has-text("Plein Écran")');
        const btnWakeLock = page.locator('button:has-text("Désactiver Veille")');

        await expect(btnPleinEcran).toBeVisible();
        await expect(btnWakeLock).toBeVisible();
    });
});

