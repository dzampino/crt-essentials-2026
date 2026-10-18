# To do

Working tracker for agents. Items are in the order they are being worked, grouped so each file is edited as few times as possible. Mark an item `[x]` when it is committed (`[~]` = partly done), and note the commit or any follow-up under it. Anything that needs David's decision goes under **Open decisions** at the end.

The original request list (October 18, 2026) is preserved, reworded only to group it.

## 0. Setup

- [x] Tracker (this file). Quarto available for rendering (portable copy in `.tools/`, ignored by Git).

## 1. No instructions or context in published output

- [~] Site, PowerPoint and GitHub README never show instructions or context (for example "a two-hour session" in the site description; editorial notes in speaker notes).
  - Done: site description, home page, README (working notes moved here), references subtitle, PKI and email wording. AGENTS.md now points to TODO.md. Remaining: speaker notes in `quarto/slides.qmd` (done in the section 7 slide pass) and the DFIR page (section 6).
- [x] Site home: drop or rewrite the intro (everything before Topics).
- [x] Site home: drop the session plan.
- [x] Site home: drop "How to read this site".
- [x] Drop "Tested in PowerShell..." lines.

## 2. Passwords

- [~] Use superscript for exponents (site and slides).
  - Site done (page text and calculator output). Slides in the section 7 pass.
- [x] Site: drop the average case.
- [x] Site: add the cooling required for the wattage in the cracking scenario.
- [x] Very simple PowerShell functions: (1) password entropy from alphabet size and length, (2) length needed to reach a given entropy with a given alphabet size.
  - `scripts/CrtEssentials/Functions/Get-PasswordEntropy.ps1`, `Get-PasswordLength.ps1`; included on the page with `{{< include >}}` so the module and site share one source.

## 3. PKI

- [x] Fun sample domain and details for the PKI sample files (regenerate files and every output shown).
  - Squeaky Curd Root CA / `squeakycurds.example`. Site outputs re-captured with OpenSSL 3.5.5, certutil and .NET; slide outputs in the section 7 pass. Keys were generated in a scratch folder and deleted.
- [x] Recommendations for installing OpenSSL on Windows.
- [x] Link to XCA, David's preferred graphical certificate tool.
  - Also added `Get-CertificateInfo` to the module.

## 4. Email security

- [x] Confirm that an MSA can also be unauthenticated and use port 25.
  - Confirmed: RFC 6409 §4.3 (unauthenticated when authorization is established otherwise, e.g. a protected subnetwork) and §3.1 ("A site MAY choose to use port 25 for message submission"). Added to the MSA row and a paragraph on the site.
- [~] Highlighting in email examples to show the back-and-forth.
  - `syntax/smtp.xml` (KDE syntax: client = Keyword, server = String, DNS policy = Function, notes = Comment). Site done (```smtp blocks, CSS in styles.css). Slides in the section 7 pass.
- [x] Replace "Few clients show it" with Outlook's "on behalf of".
- [x] Link and recommend Microsoft's Message Header Analyzer.

## 5. PowerShell

- [ ] Introduce creating your own PowerShell module (site and slides); turn site examples into reusable functions for that module.
- [ ] Separate functions from usage examples so the copy button copies just the function.
- [ ] Keep scripts simple for PowerShell beginners; comment where needed.

## 6. Windows DFIR box

- [ ] Remove the scripts portion from the DFIR section.
- [ ] Recommend automating the Windows install with unattend files: <https://schneegans.de/windows/unattend-generator/>
- [ ] Opinionated box: Windows Server 2025 (stable, Defender removable as a feature, no TPM requirement); VMware Workstation (non-persistent disks, Shared Folders with one read-only); Windows settings (long paths, show extensions and hidden files, disable UAC, etc.); tools via Chocolatey/Scoop (EZ Tools, KAPE, FTK Imager mounting, Volatility, log2timeline, Office if licensed, Chainsaw, Hayabusa, Autopsy, etc.).

## 7. PowerPoint

- [ ] Site URL and QR code at the beginning of the presentation.

## 8. Publish

- [ ] Render deck and site, commit `docs/`, push to github.com/dzampino/crt-essentials-2026.

## Open decisions

Carried over from README.md, which no longer holds working notes.

Presentation:

- [ ] Speaker notes marked as needing David's notes (see `<!-- David's notes to add -->` comments in `quarto/slides.qmd`).
- [ ] Image alt text in the .pptx is the file path (Pandoc limitation); set real alt text in PowerPoint before sharing.
- [ ] Confirm the proposed timing in outline section 3.

Site:

- [ ] Cracking explorer defaults ($/kWh, $/GPU-hour, tier GPU counts and prices) are placeholders; replace with figures David wants to stand behind.

Windows DFIR box:

- [ ] Confirm which KAPE license applies to CRT work.
