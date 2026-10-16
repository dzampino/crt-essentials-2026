# WICRT Training Slides for Quarto

A PowerPoint reference template and Quarto format for Wisconsin Cyber Response Team training decks.

## Use it

Start a new deck from this folder (or the zip):

```
quarto use template path\to\wicrt-quarto-pptx.zip
```

Or add the format to an existing project:

```
quarto add path\to\wicrt-quarto-pptx.zip
```

Then in your document's front matter:

```yaml
format: wicrt-pptx
```

`template.qmd` is a skeleton deck with one slide of each kind and placeholder text. Replace the placeholders with your outline, keeping the same heading and list structure, then render with `quarto render template.qmd`. The comment at the top of the file is a quick reference for the outline syntax.

## How Markdown maps to layouts

Pandoc picks the layout from what is on each slide; there is no per-slide layout option.

| In the .qmd | Layout |
|---|---|
| `title`, `subtitle`, `author`, `date` in the YAML | Title Slide |
| `# Heading` with nothing under it | Section Header |
| `## Heading` with text, lists, code, a table or an image | Title and Content |
| A `columns` div with two `column` divs | Two Content |
| Columns where a column has text, then a table or image | Comparison |
| Text, then a table or image (no columns) | Content with Caption |
| `##` with an empty title and no content | Blank |

Speaker notes go in a `::: notes` div.

## What the format sets

- Reference doc `wicrt-template.pptx` (13.33 × 7.5 in)
- Code in Consolas with a matching highlight theme (`wicrt.theme`)
- Dates as "October 16, 2026"

## Changing the footer

The footer reads "CRT Annual Training Conference 2026" and is fixed in the template. The original TLP:CLEAR marking was removed.

- **One deck:** after rendering, open the .pptx and use Insert → Header & Footer → Apply to All.
- **Every deck:** edit the footer text in `wicrt-template.pptx` (View → Slide Master, on the master and each layout), or edit `FOOTER_TEXT` in `build_template.py` (in the separate source zip) and rebuild (below). If you rebuild from that source, also remove its TLP marking (`TLP_LABEL`) and set `FOOTER_TEXT` again, or the old footer and marking come back.

## Fonts

Segoe UI and Segoe UI Semibold (Windows) and Consolas (Office). On macOS, PowerPoint substitutes a similar sans.

## Known limits (Pandoc's PowerPoint writer)

- Code blocks have no shaded background.
- Tables use PowerPoint's built-in Medium Style 2, recoloured by the theme (navy header, grey banding).
- Image alt text is the file path. Set real alt text in PowerPoint before sharing.

## Rebuilding the template

The generator lives in `wicrt-template-source.zip`, kept separate so `quarto use template` doesn't copy it into every deck. Requires Python 3 and Quarto. From the unzipped source folder:

```
quarto pandoc -o ref-default.pptx --print-default-data-file reference.pptx
python build_template.py ref-default.pptx wicrt-badge.png circuit-ring.png wicrt-bare.pptx
quarto pandoc specimen.md --reference-doc wicrt-bare.pptx -V monofont=Consolas -o wicrt-template.pptx
```

Copy the new `wicrt-template.pptx` over `_extensions\wicrt\wicrt-template.pptx`. `make_motif.py` redraws the section-slide circuit ring (needs Pillow).
