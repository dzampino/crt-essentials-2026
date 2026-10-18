# To do

Working tracker for agents. Items are in the order they are being worked, grouped so each file is edited as few times as possible. Mark an item `[x]` when it is committed (`[~]` = partly done), and note the commit or any follow-up under it. Anything that needs David's decision goes under **Open decisions** at the end.

The original request list (October 18, 2026) is preserved, reworded only to group it.

## 0. Setup

- [x] Tracker (this file). Quarto available for rendering (portable copy in `.tools/`, ignored by Git).

## 1. No instructions or context in published output

- [x] Site, PowerPoint and GitHub README never show instructions or context (for example "a two-hour session" in the site description; editorial notes in speaker notes).
  - Done: site description, home page, README (working notes moved here), references subtitle, PKI and email wording, DFIR page. AGENTS.md now points to TODO.md. Speaker notes cleaned in the section 7 pass; editorial labels are now `<!-- PROPOSED -->` / `<!-- NOTES TO ADD -->` comments in `quarto/slides.qmd`, which do not render.
- [x] Site home: drop or rewrite the intro (everything before Topics).
- [x] Site home: drop the session plan.
- [x] Site home: drop "How to read this site".
- [x] Drop "Tested in PowerShell..." lines.

## 2. Passwords

- [x] Use superscript for exponents (site and slides).
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
- [x] Highlighting in email examples to show the back-and-forth.
  - `syntax/smtp.xml` (KDE syntax: client = Keyword, server = String, DNS policy = Function, notes = Comment). Used on the site (```smtp blocks, CSS in styles.css) and in the deck.
- [x] Replace "Few clients show it" with Outlook's "on behalf of".
- [x] Link and recommend Microsoft's Message Header Analyzer.

## 5. PowerShell

- [x] Introduce creating your own PowerShell module (site and slides); turn site examples into reusable functions for that module.
  - Site done: "Your own module" section on powershell.qmd; nine functions in `scripts/CrtEssentials/Functions/`, packaged by build.ps1 as `files/CrtEssentials.zip`. Old `Get-FileInventory.ps1` / `Get-EvtxSummary.ps1` scripts replaced by functions. Tested in PowerShell 7.6 and 5.1. Deck: "Your own module" slide.
- [x] Separate functions from usage examples so the copy button copies just the function.
- [x] Keep scripts simple for PowerShell beginners; comment where needed.

## 6. Windows DFIR box

- [x] Remove the scripts portion from the DFIR section.
  - Removed from the page, and `DfirTools.psd1`, `Install-DfirTools.ps1`, `Set-DfirAnalysisSettings.ps1`, `Test-DfirBox.ps1` deleted (in Git history). Settings are shown as one-line commands instead.
- [x] Recommend automating the Windows install with unattend files: <https://schneegans.de/windows/unattend-generator/>
- [x] Opinionated box: Windows Server 2025 (stable, Defender removable as a feature, no TPM requirement); VMware Workstation (non-persistent disks, Shared Folders with one read-only); Windows settings (long paths, show extensions and hidden files, disable UAC, etc.); tools via Chocolatey/Scoop (EZ Tools, KAPE, FTK Imager mounting, Volatility, log2timeline, Office if licensed, Chainsaw, Hayabusa, Autopsy, etc.).
  - Notes from verification: the unattend generator targets Windows 10/11 (page says to test on Server 2025); Server 2025 evaluation must be activated online within 10 days; Chocolatey's `chainsaw` is Apache Chainsaw, and the Microsoft Store "Hayabusa" is not from Yamato Security, so both point to GitHub releases; plaso on Windows is Docker only. The DFIR open decisions (Windows, hypervisor, networking, UAC/Defender, reset, storage, tools) are settled by this; KAPE licensing stays open below.

## 7. PowerPoint

- [x] Site URL and QR code at the beginning of the presentation.
  - Slide 2, `assets/site-qr.png` (made with segno 1.6.6, decoded to confirm). Replaced the "Why these five topics" slide; the agenda no longer shows minutes (timing is in the notes). Slides checked by exporting PNGs through PowerPoint.

## 8. Publish

- [x] Render deck and site, commit `docs/`, push to github.com/dzampino/crt-essentials-2026.
  - Rendered, committed and pushed October 18, 2026. Live site checked: pki.html shows `squeakycurds.example`, files/CrtEssentials.zip returns 200, home page has no session plan.

## 9. David's answers to the open decisions (October 18, 2026)

- [x] Speaker notes: none from David; placeholders removed, minor notes added (he walks around and may not see them).
- [x] Image alt text: descriptions as image titles in `quarto/slides.qmd`; `build.ps1` strips the file path Pandoc appends.
- [x] Timing confirmed: "proposed" removed from outline section 3 and the deck.
- [x] KAPE: free for CRT members; commercial use needs a Kroll enterprise license.
- [x] Unattend: works for Server 2025 with a generic or real product key and the image selected by name or index.
- [x] No version pinning: non-persistent disk fixes versions; VM stays off the internet during cases. (Only the Scoop side-by-side claim is stated; Chocolatey keeping old versions was not confirmed.)
- [x] Certificate-chain diagram updated to `squeakycurds.example`.

## 10. Second request list (October 18, 2026)

- [x] Entropy chart: y-axis resizes with the alphabet; the line must stay straight (it bent at length 27 to 28 because bits were clamped at 128).
  - x covers the whole length slider (1 to 64); y rounds up to a 1/2/5 step. Checked straight for alphabets 2 to 1,000,000.
- [x] No downloadable CrtEssentials module: learners may build their own; the material is a starting point for learning.
  - Zip and `.psm1` removed; the function files moved to `scripts/*.ps1`, still included by the site pages. "Your own module" section kept, with the functions described as starting points.
- [x] Deck: drop the companion site description.
  - Slide 2 is now the URL as the title plus the QR code (the URL wrapped in the narrow text column).
- [x] The deck subtitle appears only in the deck; drop it everywhere else.
  - Removed from the site home, README, outline and AGENTS.md (which now states the rule without naming it). `quarto/passwords.qmd` and `quarto/template.qmd` are decks, so they keep it.

## 11. Third request list (October 18, 2026)

- [x] Entropy chart: default view only as tall as the current length needs; x steps 1, 2, 3, 4 at small lengths; both axes grow as alphabet or length increase.
  - x runs 0 to the chosen length (step 1 up to 12, then 2/5/10); y rounds up to a 1/2/5 step. Default (95, length 8): x 0 to 8, y 0 to 60. Line straight in every case tested.
- [x] DFIR: basic instructions for using unattend files and customizing the ISO.
  - Second small ISO or rebuilt Windows ISO (oscdimg, BIOS and UEFI, efisys_noprompt, boot order file); install steps; delete the cached answer file in C:\Windows\Panther. Boot-order generation tested on a mock folder; oscdimg itself not run (no ADK or Server ISO on this machine).
- [x] DFIR: David's suggestion of a second clock set to UTC, or UTC as the system time zone.
  - Clock section on the site (generator setting, Set-TimeZone -Id 'UTC', Control Panel Additional Clocks); slide bullet marked PROPOSED.

## 12. Fourth request list (October 18, 2026)

- [x] DFIR: mention WSL for the VM, after confirming it works inside VMware Workstation.
  - Tested on this PC (Workstation 25.0.1, Windows 11 host with VBS running): a VM with nested VT-x enabled logged `Monitor Mode: ULM` and refused: "Virtualized Intel VT-x/EPT is not supported on this platform." So WSL 2 cannot run in the VM on such a host; the site recommends WSL 1 (no virtualization). WSL 1 itself not yet run inside a Server 2025 VM.
- [x] DFIR: suggested software list covering the common tools in DFIR distributions, including 7-Zip, FTK Imager, VS Code, Arsenal Image Mounter, Sysinternals, Wireshark, CyberChef, ExifTool, pestudio, log2timeline/plaso, Volatility 3, oletools.
  - Tool table grouped by job, with Chocolatey packages checked (`choco info`: package and project site). pestudio from Winitor (package flagged possibly broken); RegRipper, capa and FLOSS from GitHub (packages years behind); oletools via pip; plaso in WSL from the GIFT PPA. New deck slide "Suggested tool list" (PROPOSED).

## 13. Fifth request list (October 18, 2026)

- [x] Check whether WSL 2 works in VMware Workstation on Server 2025.
  - Not on this PC, whatever the guest: Workstation refuses nested VT-x while the host runs VBS (tested in section 12; the guest OS never starts). With VBS and Hyper-V off on the host, Microsoft says WSL 2 runs in a VM with nested virtualization; not tested here, because turning VBS off would break WSL 2 and Docker on the host.
- [x] Deck: "Extended Key Usage (EKU)".
- [x] Drop "Fictional" from the sample certificates.
  - Root regenerated as O=Cheese Curd Authority (new keys; leaf, DER and CSR reissued, keys deleted). Every value on the PKI page and deck re-run: serial 55:25:8b:df..., SHA-256 566D4525...AE67, thumbprint D3A4DAB5..., public key hash 7a764e05...; verify and certutil output re-captured. "Fictional" also dropped from the sample descriptions.
- [x] Deck: replace "Microsoft's Message Header Analyzer lays it all out" with David's prose: it is his preferred tool.
- [x] Deck: DMARC tag descriptions (not only policy and reporting) so the audience can solve the DMARC challenges.
  - New "DMARC record tags" slide from RFC 9989 section 4.7 (PROPOSED).
- [x] Drop "(briefly, for historical context)".
- [x] Deck PowerShell section after the intro: Verb-Noun, objects (for people new to OOP), PowerShell 5.1 and 7.
  - Three new slides (PROPOSED), code tested in 7.6.7 and 5.1.
- [x] Deck: drop SupportsShouldProcess (keep on the site).
- [x] Deck module slide: the 5.1 and 7 module paths with examples, not a script (site unchanged).
- [x] Deck "What we're building": describe more; drop the memory acquisition line.
- [x] Deck "Configuring Windows for analysis": itemize the high-level changes; the UAC reason goes under the general-recommendations point.
- [x] Check tool name capitalization in the tool list.
  - Plaso capitalized (project's own spelling); pestudio, oletools and capa are lowercase by their authors.
- [x] Deck: drop Wrap-up and the slides after it; end with a thank-you slide.

## 14. Sixth request list (October 18, 2026)

- [x] Rename Get-PasswordLength so the name says it is about entropy.
  - Now Get-PasswordLengthForEntropy (scripts/Get-PasswordLengthForEntropy.ps1); tested in 7.6.7 and 5.1.
- [x] Email page: keep the GitHub link for MHA, drop the sentence "It is open source (github.com/microsoft/MHA)."
- [x] Alignment checker: answer blank by default, a reveal button; fix the "--" example that has no example.
  - Opens on example 1 (the "—" option is gone; "Your own message" is selected when a field is edited). Show/Hide answer button; any change hides it again. Test-mode verdict corrected to RFC 9989 (reject drops to quarantine, quarantine to no action).
- [x] Deck: SPF and DKIM tag tables like the DMARC one.
  - From RFC 7208 and RFC 6376 (PROPOSED slides).
- [x] Deck: PowerShell default security settings (what Open does with a .ps1, execution policy).
  - From about_Scripts and about_Execution_Policies; PowerShell 7's RemoteSigned checked in $PSHOME\powershell.config.json on this PC (PROPOSED slide).

## 15. Seventh request list (October 18, 2026)

- [x] Deck: agenda before the companion site slide.
- [x] Deck footer: link to the GitHub repository.
  - Template footer now "CRT Annual Training Conference 2026 · github.com/dzampino/crt-essentials-2026", the address linked and in the footer's text color (quarto/add_footer_link.py). build.ps1 adds the link target Pandoc leaves out; all 65 footer links resolve and PowerPoint opens the deck cleanly.
- [x] Deck SPF slide: where the IP and domain come from (the connecting server; MAIL FROM, or HELO/EHLO when MAIL FROM is empty), from RFC 7208 sections 2.3, 2.4 and 4.1 (PROPOSED sub-points).
- [x] Deck Verb-Noun slide: wildcard example `Get-Command Get-*Event` (returns Get-Event and Get-WinEvent in 7.6.7 and 5.1).
- [x] PowerShell verbosity, tab completion, Ctrl+Space after `-`, aliases: deck slide "Long names, little typing" (PROPOSED) and site section of the same name under Finding commands. Bindings and aliases checked in 7.6.7 and 5.1 (PSReadLine 2.4.5).
- [x] Site dark mode: follows the reader's system setting (respect-user-color-scheme), navbar toggle remembers the choice. Dark theme is Cosmo plus site/dark.scss so fonts match; site colors are CSS variables switched under body.quarto-dark (chart, panels, SMTP transcripts, checker); code uses github-dark. Checked by screenshot with Edge forced to dark and light.
- [x] Diagrams readable in dark mode: assets/diagrams/make_dark.py writes NAME-dark.svg from each diagram (colors matched to the dark theme); PNGs rendered with headless Edge. Pages show light or dark with Quarto's .light-content/.dark-content, so the toggle switches them. The deck keeps the light versions; the xkcd comic is unchanged.

## Open decisions

- [ ] Review the `<!-- PROPOSED -->` wording in `quarto/slides.qmd` (wording that is not David's).
- [ ] Chocolatey and old versions: David said Chocolatey and Scoop keep old versions by default; only Scoop's behavior is confirmed and stated on the site.
- [ ] Run the ISO rebuild on the DFIR page end to end with the ADK and a Server 2025 ISO.
- [ ] In a Server 2025 VM: run the WSL 1 install commands and plaso from the GIFT PPA under WSL 1. (The plaso docs page says "Ubuntu 26.04 LTS (noble)"; noble is 24.04, so the site names no version.)
