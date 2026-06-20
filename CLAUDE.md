# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Deploy automático

Toda alteração solicitada pelo usuário deve ser seguida de deploy imediato — sem pedir confirmação. Após editar qualquer arquivo, executar:

```powershell
$token = & "C:\Program Files\GitHub CLI\gh.exe" auth token
git -C "C:\Users\PC\Desktop\Nova pasta\fdp-site (1)\fdp-site" remote set-url origin "https://mansurvitoriag:$token@github.com/mansurvitoriag/fdp-site.git"
git -C "C:\Users\PC\Desktop\Nova pasta\fdp-site (1)\fdp-site" add .
git -C "C:\Users\PC\Desktop\Nova pasta\fdp-site (1)\fdp-site" commit -m "atualizacao: <descrever o que mudou>"
git -C "C:\Users\PC\Desktop\Nova pasta\fdp-site (1)\fdp-site" push origin main
git -C "C:\Users\PC\Desktop\Nova pasta\fdp-site (1)\fdp-site" remote set-url origin "https://github.com/mansurvitoriag/fdp-site.git"
```

A Vercel detecta o push e publica automaticamente em 1-2 minutos.

## Deploy

- **GitHub:** `github.com/mansurvitoriag/fdp-site`
- **Vercel:** conectado ao GitHub, deploy automático a cada push na branch `main`
- Não há etapa de build — o site é HTML/CSS/JS puro, a Vercel serve os arquivos estáticos diretamente

## Arquitetura

Site estático de 4 páginas independentes, sem framework:

| Arquivo | Página |
|---|---|
| `index.html` | Home |
| `loja.html` | Loja |
| `onde-estamos.html` | Onde Estamos |
| `sobre.html` | Sobre |

Cada página é **autossuficiente**: contém seu próprio `<style>` inline no `<head>` e `<script>` inline antes do `</body>`. O arquivo `assets/style.css` existe mas é usado como referência/base compartilhada — as páginas replicam e estendem os estilos inline.

## Design system

Variáveis CSS definidas em `:root` em cada página:

```css
--branco: #ffffff
--preto: #0a0a0a
--grafite: #1b1b1b
--cinza: #666666
--cinza-claro: #e9e9e9
--neon: #d0ff00       /* cor principal de destaque */
--laranja: #f58220    /* cor secundária de destaque */
--maxw: 1280px
```

**Tipografia (Google Fonts):**
- `Anton` — títulos (`h1`–`h4`), sempre uppercase
- `Archivo` — corpo e UI
- `Rajdhani` — textos descritivos e parágrafos longos

## Convenções de componentes

- `.wrap` — container centralizado com `max-width: 1280px` e `padding: 0 32px`
- `.eyebrow` — label pequena acima de títulos de seção, com traço neon antes
- `.page-hero` — hero escuro com borda neon inferior, usado nas páginas internas
- `.frisos` — barras laterais fixas decorativas (esquerda neon/laranja, direita inverso)
- Breakpoints responsivos: `980px`, `760px`, `480px`
- Botões CTA: fundo preto + texto neon, hover muda para laranja
