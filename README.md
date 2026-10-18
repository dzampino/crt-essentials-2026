# CRT Essentials

**Full title:** CRT Essentials or The Dave Zampino Power Hour  
**Event:** CRT Annual Training Conference 2026

## Topics

1. Passwords
2. PKI
3. Email security
4. PowerShell
5. Windows DFIR workstation

## Output

1. PowerPoint: `output/slides.pptx`, rendered from `quarto/slides.qmd`
2. Companion website: <https://dzampino.github.io/crt-essentials-2026/>, rendered from `site/` into `docs/`

## Layout

| Path | What it is |
| --- | --- |
| `outline.md` | Content outline for the deck and site |
| `quarto/slides.qmd` | The full deck, using the WICRT template in `quarto/_extensions/wicrt/` |
| `site/` | Quarto website source: one page per topic, `js/` for the interactive tools |
| `docs/` | Rendered site, served by GitHub Pages. Generated; do not edit by hand. |
| `scripts/` | The `CrtEssentials` PowerShell module: every function shown on the site |
| `samples/` | PKI sample files and email exercises |
| `assets/` | Logo, diagrams and attributed artwork |
| `references.md` | Primary sources |
| `build.ps1` | Renders the deck and the site |

## Building

Requires [Quarto](https://quarto.org) 1.4 or later and PowerShell 7 or Windows PowerShell 5.1. `build.ps1` uses `quarto` from `PATH`, a portable copy unzipped to `.tools\quarto`, or the default install folder.

```powershell
.\build.ps1 -Verbose            # deck, then site
.\build.ps1 -SlidesOnly
.\build.ps1 -SiteOnly
```

`build.ps1` copies the deck, samples, scripts and images into `site/files/` (ignored by Git) before rendering, so run it rather than `quarto render site` directly. Commit `docs/` after building.

## Publishing

GitHub Pages serves `docs/` from the `main` branch: repository **Settings → Pages → Build and deployment → Deploy from a branch → `main` / `/docs`**. No workflow or other tooling is needed.
