# CRT Essentials or The Dave Zampino Power Hour

## CRT Annual Training Conference 2026 project master outline

## 1. What we are making

- A two-hour presentation for Wisconsin Cyber Response Team (CRT) volunteers and fellow SLTT IT professionals, primarily interested in incident response.
- An editable PowerPoint, developed from an outline.
- A supplementary website with the technical depth, examples, commands, references, and interactive demonstrations that do not fit comfortably into the live presentation.
- Shared, portable project files that ChatGPT and Claude can both work with.

The final title is **CRT Essentials or The Dave Zampino Power Hour**. In working discussion, use **CRT Essentials** or **the CRT Annual Training Conference 2026 project**. The session is two hours.

The five topics were assigned and are somewhat disparate. Their connection is practical security knowledge CRT responders should understand and be able to explain, including preventative advice that helps organizations avoid the incidents we respond to. There is no need to force everything into one fictional incident or an artificial narrative.

## 2. Principles to preserve

1. **Simple above all else.** Start with readable text files and a small project structure. Add tooling only when it solves a real problem.
2. **David's voice.** Preserve his prose, terminology preferences, examples, and reasoning. Make editorial suggestions without turning the material into generic presentation language.
3. **Professional appearance.** Use a restrained, consistent design. Prefer useful diagrams, screenshots, and worked examples to decorative imagery and dense bullet lists.
4. **An outline first.** Settle the message and order before polishing slides.
5. **Slides and a field guide.** The SANS-inspired model is a focused live presentation supported by material attendees can use afterward. The website should add value beyond reproducing the slides.
6. **Technical accuracy.** Correct factual errors and identify uncertainty while preserving David's intended point. Verify standards, changing guidance, commands, and software behavior before publishing them.

## 3. Presentation order and proposed timing

The order is **Passwords → PKI → Email Security → PowerShell → DFIR workstation**.

The following is a proposed pacing budget, not a previously settled schedule. Demonstrations are included within each section's allocation.

| Segment | Minutes | Running time |
| --- | ---: | ---: |
| Introduction and purpose | 5 | 0–5 |
| Passwords | 20 | 5–25 |
| PKI | 25 | 25–50 |
| Email security | 30 | 50–80 |
| PowerShell | 20 | 80–100 |
| Building a Windows DFIR box | 15 | 100–115 |
| Questions and wrap-up | 5 | 115–120 |
| **Total** | **120** | |

## 4. Master content outline

### 1. Passwords

**Purpose:** Explain how passwords get guessed, what an entropy model can tell us, and what infrastructure should do to protect users.

#### 1.1 Password Outline

1. Discussion about authentication
  - Something you know, something you are, something you have
  - Passwords are something you know; we refer to them as secrets. Other types of secrets: passphrases, PINs, secret questions
  - Goal in all authentication methods is **good enough** uniqueness
  - We can add behavior to assist in making risk assessments
2. correct horse battery staple
  - insert comic and link to url
3. Entropy
  - "My greatest concern was what to call it. I thought of calling it 'information,' but the word was overly used, so I decided to call it 'uncertainty.' When I discussed it with John von Neumann, he had a better idea. Von Neumann told me, 'You should call it entropy, for two reasons. In the first place your uncertainty function has been used in statistical mechanics under that name, so it already has a name. In the second place, and more important, no one really knows what entropy really is, so in a debate you will always have the advantage.'"
4. Entropy (cont.)
  - Bits of entropy (aka shannons) = log2(search space)
  - Search space = alphabet ^ length
5. Entropy calculator
NOTE: swap to site for entropy calculation
  - multiplicative vs exponentional
  - entire search space
  - average time to crack
6. Cracking = time x money
  - Who is the threat
  - How is it protected
7. Protecting users
  - Do what we can to protect users
  - Attack modeling should be based on online attacks
  - We have duties to protect hashes from getting stolen
8. Takeaways
  - Uniqueness means password managers
  - Check for compromised password; no complexity, no rotation
  - Use standards otherwise, NIST is 8 w/MFA and 15 w/o MFA
  - Use MFA
9. Questions?

#### 1.1 Password Supplementary Material

1. Site should include an interactive entropy calculator. Should have an input for alphabet size. Graph should should length on x axis and bits of entropy on y axis (no more than 128). This should be shaded down from line to bottom of graph. A second line should be halfway to show average time to guess and should be shaded down with a different color.
2. There should be another interactive portion that shows 1) different hashing algorithms, 2) different threat levels (show purchase cost of equipment, i.e. cracking potential of a $50k box or cracking potential of nationstate distributed datacenter), 3) time to crack and cost of cracking (don't include initial equipment costs)


### 2. PKI

**Purpose** Inspect a certificate, explain issuance, and name the validation check that fails.

#### 2.1 PKI Outline

1. Public key infrastructure
  - Public keys and private keys
  - What a certificate does and does not prove
  - Certificate authorities and trust
2. What's in a certificate?
  - X.509 certificates
  - Subject, issuer, serial number, validity, public key, signature
  - Distinguished names, common name, subject alternative name (SAN)
  - Extensions: key usage, extended key usage, basic constraints
3. Certificate chains
  - Leaf, intermediate, root
  - Trust anchors and the certificate store
  - A valid signature is not the same as a trusted certificate
4. Certificate formats
  - ASN.1, DER, PEM
  - Common extensions: .cer, .crt, .pem, .p7b, .pfx, .csr
  - A file extension does not necessarily tell you what's inside
5. Certificate requests and issuance
  - Certificate signing requests (CSR / PKCS #10)
  - Creating a key pair and submitting a request
  - Internal CAs / AD CS and certificate templates
  - ACME and automated issuance
6. Putting a certificate to use
  - Certificate, private key, and intermediate certificates
  - The certificate presented by a service versus the trust configured on a client
7. Certificate validation
  - Name matching, validity dates, chain, trust, and permitted usage
  - CRLs and OCSP; client behavior varies
  - What happens when a check fails?
8. Renewal and maintenance
  - Expiration, replacing certificates, and deployment
9. Questions?

#### 2.2 PKI Supplementary Material

1. Certificate examples attendees can inspect. Include a certificate field reference (names, extensions, OIDs) and a simple chain diagram.
2. Examples of the same certificate in different encodings/formats. Include `certutil -dump` and other useful inspection commands.
3. CSR and certificate issuance examples, including AD CS and ACME. Commands and longer explanations belong on the site.
4. Certificate validation examples: untrusted root, incorrect name, expired certificate. Include CRL/OCSP details and differences in client behavior.
5. References to the relevant RFCs, including RFC 5280, RFC 9525, RFC 2986, and RFC 8555.


### 3. Email security

**Purpose:** Understand how email moves, which identities are being authenticated, and how to determine whether a message passes DMARC.

#### 3.1 Email Security Outline

1. How email works
  - MUA, MSA, MTA, MDA
  - SMTP, submission, relay, delivery, and DNS/MX records
2. The envelope versus the message
  - SMTP `MAIL FROM` and `RCPT TO` are not message headers
  - `From`, `Sender`, `Return-Path` — what each means
  - The difference between the visible sender and the envelope sender
3. Reading email headers
  - `Received` headers and the path a message took
  - `Authentication-Results` and which system added them
  - Which headers can be trusted?
4. SPF
  - What SPF checks
  - DNS records, sending IPs, and envelope domains
  - SPF pass does not necessarily mean DMARC pass
5. DKIM
  - What DKIM signs and verifies
  - Signing domain (`d=`), selector (`s=`), and DNS public key
  - The relevant fields in a DKIM signature
6. DMARC
  - Start with the domain in the message `From` header
  - Alignment with SPF and/or DKIM
  - Strict versus relaxed alignment
  - DMARC policy and reporting
7. Work through email headers
  - Identify the different sender identities
  - Identify the SPF and DKIM results
  - Determine whether the message passes DMARC, and why
8. Other email security mechanisms
  - MTA-STS and TLS reporting (TLS-RPT)
  - Sender ID (briefly, for historical context)
9. Questions?

#### 3.2 Email Security Supplementary Material

1. Sample email headers and SMTP transcripts, with an explanation of what each important field means.
2. DMARC alignment exercises using supplied SPF and DKIM results and domains, including strict and relaxed alignment.
3. SPF, DKIM, and DMARC DNS record examples. Include lookup and troubleshooting details that do not need to be covered live.
4. DMARC reporting, domain discovery, alignment rules, and the changes in the 2026 RFCs (9989, 9990, 9991).
5. MTA-STS and TLS-RPT examples, with references to the relevant RFCs.


### 4. PowerShell

**Purpose:** Show how PowerShell can make administrative and incident-response tasks easier to repeat and automate.

#### 4.1 PowerShell Outline

1. Why PowerShell?
  - Administration, automation, and analysis
  - Turning a repetitive task into something repeatable
2. Finding commands
  - `Get-Command`, `Get-Help`
  - Find the parameters and figure out what a command returns
3. Objects and the pipeline
  - Objects versus plain text
  - `Get-Member`, `Select-Object`
  - Pass objects between commands
4. Working with data
  - `Where-Object`, `Sort-Object`, `Group-Object`
  - Selecting information and exporting results
5. Example tasks
  - Working with an existing collection of files
  - File metadata, hashing, and reports
  - Looking at collected Windows event logs with `Get-WinEvent`
6. Making a script reusable
  - Parameters instead of hard-coded values
  - Functions, `-Verbose`, `-WhatIf` where applicable
  - An example of automating part of the DFIR box build
7. Questions?

#### 4.2 PowerShell Supplementary Material

1. Short command examples attendees can copy and modify, including object inspection, filtering, sorting, and exporting.
2. Example scripts for a file inventory and querying an existing EVTX file; analysis rather than evidence acquisition.
3. Reference material on pipelines, functions, parameters, error handling, and `ShouldProcess`.
4. Notes on differences between Windows PowerShell 5.1 and PowerShell 7 where relevant.


### 5. Building a Windows DFIR box

**Purpose:** Build a repeatable Windows workstation for analyzing evidence that has already been collected.

#### 5.1 Windows DFIR Box Outline

1. What we're building
  - A Windows analysis machine, not an evidence acquisition machine
  - Evidence is already collected; memory acquisition is handled separately (Magnet in our workflow)
2. Disposable/nonpersistent virtual machine
  - Return the machine to a known state
  - Keep case data and analysis output separate from what gets reset
3. Automating the build
  - Decide on the Windows image and tool list
  - Make setup repeatable rather than configuring it by hand each time
4. Configuring Windows for analysis
  - Tools that need to run as administrator
  - UAC: normally I don't disable security features, but this is a disposable VM and reducing friction matters
  - Other Windows security settings as decisions specific to this machine, not general recommendations
5. Tools for analysis
  - Select the tools and versions
  - KAPE modules for processing already-collected artifacts (confirm intended tool name)
6. Using and resetting the box
  - Run tools against existing artifacts
  - Retain the results and relevant logs
  - Verify the environment and reset it for the next case
7. Questions?

#### 5.2 Windows DFIR Box Supplementary Material

1. Build instructions and automation scripts, including the selected Windows image, tools, versions, and configuration.
2. Tool inventory and references. Keep the exact list open until selected.
3. A working example of processing an existing artifact set with a module, without adding an evidence collection workflow.
4. VM reset/persistence instructions and checks to confirm outputs are retained.
5. A list of open implementation decisions: Windows version, hypervisor, networking, UAC/Defender configuration, reset method, and persistent case storage.
