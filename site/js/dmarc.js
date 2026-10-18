// DMARC alignment checker for email.qmd. No dependencies.
// Organizational domains are approximated; RFC 9989 section 4.10 uses a DNS tree walk.
// The answer stays hidden until "Show answer" is selected, and hides again when anything changes.
(function () {
	"use strict";

	const $ = (id) => document.getElementById(id);
	const FIELDS = ["dm-from", "dm-org", "dm-mailfrom", "dm-spf", "dm-dkimd", "dm-dkim", "dm-aspf", "dm-adkim", "dm-p", "dm-t"];

	const PRESETS = {
		1: { from: "blue.secondary.com", org: "secondary.com", mailfrom: "red.secondary.com", spf: "fail", dkimd: "primary.com", dkim: "pass", aspf: "r", adkim: "r", p: "quarantine", t: "y" },
		2: { from: "blue.primary.com", org: "primary.com", mailfrom: "red.primary.com", spf: "softfail", dkimd: "secondary.com", dkim: "fail", aspf: "s", adkim: "s", p: "quarantine", t: "n" },
		3: { from: "red.primary.com", org: "primary.com", mailfrom: "blue.secondary.com", spf: "softfail", dkimd: "blue.primary.com", dkim: "pass", aspf: "s", adkim: "s", p: "none", t: "n" },
		4: { from: "example.org", org: "example.org", mailfrom: "mailer.esp.example", spf: "pass", dkimd: "example.org", dkim: "pass", aspf: "r", adkim: "r", p: "none", t: "n" }
	};

	function clean(d) {
		return String(d || "").trim().toLowerCase().replace(/\.$/, "");
	}

	function lastTwo(d) {
		return d.split(".").slice(-2).join(".");
	}

	function escapeHtml(s) {
		return s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
	}

	function evaluate() {
		const from = clean($("dm-from").value);
		const org = clean($("dm-org").value) || lastTwo(from);
		const orgOf = (d) => (d === org || d.endsWith("." + org)) ? org : lastTwo(d);
		const aligned = (mode, d) => mode === "s" ? d === from : orgOf(d) === orgOf(from);

		const mailfrom = clean($("dm-mailfrom").value);
		const spf = $("dm-spf").value;
		const dkimd = clean($("dm-dkimd").value);
		const dkim = $("dm-dkim").value;
		const aspf = $("dm-aspf").value;
		const adkim = $("dm-adkim").value;
		const p = $("dm-p").value;
		const t = $("dm-t").value;

		const reasons = [];
		const modeName = (m) => m === "s" ? "strict" : "relaxed";

		const spfAligned = aligned(aspf, mailfrom);
		const spfOk = spf === "pass" && spfAligned;
		reasons.push("SPF " + spf + " for <code>" + escapeHtml(mailfrom) + "</code>; " +
			(spfAligned ? "aligned" : "not aligned") + " with <code>" + escapeHtml(from) + "</code> (" + modeName(aspf) + ")" +
			(spfOk ? " → counts for DMARC." : spf === "pass" ? " → does not count." : " → does not count; only a pass can."));

		const dkimAligned = dkimd !== "" && aligned(adkim, dkimd);
		const dkimOk = dkim === "pass" && dkimAligned;
		reasons.push("DKIM " + dkim + (dkimd ? " for d=<code>" + escapeHtml(dkimd) + "</code>; " +
			(dkimAligned ? "aligned" : "not aligned") + " (" + modeName(adkim) + ")" : "") +
			(dkimOk ? " → counts for DMARC." : " → does not count."));

		if (adkim === "r" || aspf === "r") {
			reasons.push("Relaxed alignment compares organizational domains; the From domain's is taken as <code>" + escapeHtml(orgOf(from)) + "</code>.");
		}

		const pass = spfOk || dkimOk;
		let verdict;
		if (pass) {
			verdict = "DMARC passes (" + [spfOk ? "SPF" : null, dkimOk ? "DKIM" : null].filter(Boolean).join(" and ") + " aligned).";
		} else if (t === "y" && p !== "none") {
			// RFC 9989 section 4.7: test mode applies the policy one level below
			verdict = "DMARC fails; t=y (test mode) asks receivers to apply " + (p === "reject" ? "quarantine" : "no action") + " instead of p=" + p + ".";
		} else if (p === "none") {
			verdict = "DMARC fails; p=none, so no action is requested.";
		} else {
			verdict = "DMARC fails; the requested action is " + p + ".";
		}

		const v = $("dm-verdict");
		v.textContent = verdict;
		v.className = "verdict " + (pass ? "pass" : "fail");
		$("dm-reasons").innerHTML = reasons.map((r) => "<li>" + r + "</li>").join("");
	}

	function hideAnswer() {
		$("dm-answer").hidden = true;
		$("dm-reveal").textContent = "Show answer";
	}

	function toggleAnswer() {
		const show = $("dm-answer").hidden;
		if (show) evaluate();
		$("dm-answer").hidden = !show;
		$("dm-reveal").textContent = show ? "Hide answer" : "Show answer";
	}

	// A field edited by hand no longer matches the loaded example
	function edited() {
		$("dm-preset").value = "custom";
		hideAnswer();
	}

	function load(n) {
		const pr = PRESETS[n];
		hideAnswer();
		if (!pr) return;
		$("dm-from").value = pr.from;
		$("dm-org").value = pr.org;
		$("dm-mailfrom").value = pr.mailfrom;
		$("dm-spf").value = pr.spf;
		$("dm-dkimd").value = pr.dkimd;
		$("dm-dkim").value = pr.dkim;
		$("dm-aspf").value = pr.aspf;
		$("dm-adkim").value = pr.adkim;
		$("dm-p").value = pr.p;
		$("dm-t").value = pr.t;
	}

	function init() {
		if (!$("dmarc-tool")) return;
		$("dm-from").addEventListener("change", () => {
			$("dm-org").value = lastTwo(clean($("dm-from").value));
		});
		FIELDS.forEach((id) => $(id).addEventListener("input", edited));
		$("dm-preset").addEventListener("change", (e) => load(e.target.value));
		$("dm-reveal").addEventListener("click", toggleAnswer);
		load($("dm-preset").value);
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
