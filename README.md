# CRT Essentials

**Full title:** CRT Essentials or The Dave Zampino Power Hour  
**Project:** CRT Annual Training Conference 2026  
**Format:** Two hours, PowerPoint plus a companion handbook

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
| `outline.md` | Editorial authority. Edit here first, then `quarto/slides.qmd`, then the matching `site/` page. |
| `quarto/slides.qmd` | The full deck, using the WICRT template in `quarto/_extensions/wicrt/` |
| `quarto/passwords.qmd` | Earlier Passwords-only draft, superseded by `slides.qmd` |
| `site/` | Quarto website source: one page per topic, `js/` for the interactive tools |
| `docs/` | Rendered site, served by GitHub Pages. Generated; do not edit by hand. |
| `scripts/` | PowerShell scripts published on the site (PowerShell and DFIR box sections) |
| `samples/` | PKI sample files and email exercises |
| `assets/` | Logo, diagrams and attributed artwork |
| `references.md` | Primary sources |
| `build.ps1` | Renders the deck and the site |

## Building

Requires [Quarto](https://quarto.org) 1.4 or later (tested with 1.10.19) and PowerShell 7 or Windows PowerShell 5.1.

```powershell
.\build.ps1 -Verbose            # deck, then site
.\build.ps1 -SlidesOnly
.\build.ps1 -SiteOnly
```

`build.ps1` copies the deck, samples, scripts and images into `site/files/` (ignored by Git) before rendering, so run it rather than `quarto render site` directly. Commit `docs/` after building.

## Publishing

GitHub Pages serves `docs/` from the `main` branch: repository **Settings → Pages → Build and deployment → Deploy from a branch → `main` / `/docs`**. No workflow or other tooling is needed.

## Slide adjustments relative to outline.md

The deck follows the outline's order and headings. Additions, all labeled in speaker notes as proposed wording where they are not David's:

- Introduction: an agenda with the proposed timing and a "Why these five topics" slide, drawn from outline section 1.
- Passwords: a worked-example table on "Entropy (cont.)" and a hash-rate table on "Cracking = time x money".
- PKI: a slide showing the training certificate's fields; a format table; a table of OpenSSL validation errors; the CA/Browser Forum validity schedule on "Renewal and maintenance".
- Email: SPF, DKIM and DMARC record examples on their slides; "Work through email headers" is three exercise slides with three answer slides, using the learndmarc transcripts converted to text (per `samples/email/README.md`) and the answers in `samples/email/answers.md`.
- PowerShell: one code example per slide.
- DFIR box: a reset/keep two-column split on the disposable VM slide.
- Wrap-up: key takeaways and references.

## Remaining decisions

Presentation:

- [ ] Speaker notes marked `[David's notes to add.]` need David's notes.
- [ ] Image alt text in the .pptx is the file path (Pandoc limitation); set real alt text in PowerPoint before sharing.
- [ ] Confirm the proposed timing in outline section 3.
- [ ] The entropy chart's "average" line is one bit below the total (half the search space), so on a 0–128 bit axis the two lines nearly coincide. This is mathematically correct; decide whether that visual is what was intended or whether the average should be shown differently (for example as time rather than bits).

Site and repository:

- [ ] Create or grant access to `github.com/dzampino/crt-essentials-2026`, push `main`, and enable Pages from `/docs`.
- [ ] Cracking explorer defaults ($/kWh, $/GPU-hour, tier GPU counts and prices) are placeholders; replace with figures David wants to stand behind.

Windows DFIR box (outline 5.2), all open:

- [ ] Windows version and image
- [ ] Hypervisor
- [ ] Networking
- [ ] UAC mode (`NoPrompt` or `Disabled`) and Defender configuration
- [ ] Reset method
- [ ] Persistent case storage
- [ ] Tool list and versions (`scripts/DfirTools.psd1` holds example entries only)
- [ ] Confirm KAPE is the intended tool and which KAPE license applies to CRT work
