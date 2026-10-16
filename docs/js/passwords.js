// Entropy calculator and cracking explorer for passwords.qmd. No dependencies.
// Large numbers are handled in log space so nothing overflows.
(function () {
	"use strict";

	const NAVY = "#0C2454";
	const RED = "#E03E3B";
	const MAX_BITS = 128;
	const SECONDS_PER_YEAR = 365.25 * 86400;

	const $ = (id) => document.getElementById(id);

	// Hashcat 6.2.6, one RTX 5090 FE (Chick3nman, Feb 2025). Derived rows scaled to OWASP work factors.
	const ALGORITHMS = [
		{ name: "NTLM (NT hash)", rate: 340.1e9 },
		{ name: "MD5", rate: 220.6e9 },
		{ name: "SHA1", rate: 70.2451e9 },
		{ name: "SHA2-256", rate: 28.3533e9 },
		{ name: "NetNTLMv2 (captured exchange)", rate: 16.0179e9 },
		{ name: "Kerberos TGS-REP etype 23", rate: 4.1787e9 },
		{ name: "sha512crypt, 5,000 rounds", rate: 1.4798e6 },
		{ name: "bcrypt, cost 5", rate: 304.8e3 },
		{ name: "PBKDF2-HMAC-SHA256, 600,000 iterations (derived)", rate: 11157.2e3 * 999 / 600000 },
		{ name: "bcrypt, cost 10 (derived)", rate: 304.8e3 / 32 },
		{ name: "scrypt, N=16384", rate: 7760 }
	];

	// Threat tiers. GPU counts and purchase costs are editable assumptions.
	const TIERS = [
		{ name: "Hobbyist", gpus: 1, purchase: 4000 },
		{ name: "$50k box", gpus: 8, purchase: 50000 },
		{ name: "Criminal cloud burst", gpus: 200, purchase: 0 },
		{ name: "Nation-state datacenter", gpus: 10000, purchase: 62500000 }
	];

	// ---------- formatting ----------

	function formatCount(log10) {
		if (log10 < 6) {
			return Math.round(Math.pow(10, log10)).toLocaleString();
		}
		const exp = Math.floor(log10);
		const mant = Math.pow(10, log10 - exp);
		return mant.toFixed(2) + " × 10^" + exp;
	}

	function formatDuration(log10Seconds) {
		if (log10Seconds < -3) return "instant";
		const s = Math.pow(10, log10Seconds);
		if (s < 1) return (s * 1000).toFixed(0) + " ms";
		if (s < 120) return s.toFixed(1) + " seconds";
		if (s < 7200) return (s / 60).toFixed(1) + " minutes";
		if (s < 172800) return (s / 3600).toFixed(1) + " hours";
		if (s < SECONDS_PER_YEAR * 2) return (s / 86400).toFixed(1) + " days";
		const log10Years = log10Seconds - Math.log10(SECONDS_PER_YEAR);
		if (log10Years < 6) return Math.round(Math.pow(10, log10Years)).toLocaleString() + " years";
		return formatCount(log10Years) + " years";
	}

	function formatMoney(log10Dollars) {
		if (!isFinite(log10Dollars)) return "$0";
		if (log10Dollars < -2) return "< $0.01";
		const d = Math.pow(10, log10Dollars);
		if (d < 100) return "$" + d.toFixed(2);
		if (log10Dollars < 12) return "$" + Math.round(d).toLocaleString();
		return "$" + formatCount(log10Dollars);
	}

	// ---------- entropy calculator ----------

	const state = { alphabet: 95, length: 8, rate: 340.1e9 };

	function bitsPerChar() {
		return Math.log2(state.alphabet);
	}

	function svgEl(name, attrs) {
		const el = document.createElementNS("http://www.w3.org/2000/svg", name);
		for (const k in attrs) el.setAttribute(k, attrs[k]);
		return el;
	}

	function drawChart() {
		const host = $("ent-chart");
		host.innerHTML = "";
		const W = 720, H = 320, m = { t: 14, r: 120, b: 38, l: 48 };
		const bpc = bitsPerChar();
		const xMax = Math.max(4, Math.min(256, Math.ceil(MAX_BITS / bpc)));
		const x = (len) => m.l + ((len - 1) / (xMax - 1)) * (W - m.l - m.r);
		const y = (bits) => H - m.b - (Math.min(bits, MAX_BITS) / MAX_BITS) * (H - m.t - m.b);

		const svg = svgEl("svg", { viewBox: "0 0 " + W + " " + H, role: "img",
			"aria-label": "Bits of entropy by password length for an alphabet of " + state.alphabet + " symbols" });

		// grid and y axis
		const grid = svgEl("g", { class: "grid" });
		const axis = svgEl("g", { class: "axis" });
		for (let b = 0; b <= MAX_BITS; b += 32) {
			grid.appendChild(svgEl("line", { x1: m.l, x2: W - m.r, y1: y(b), y2: y(b) }));
			const t = svgEl("text", { x: m.l - 8, y: y(b) + 4, "text-anchor": "end" });
			t.textContent = b;
			axis.appendChild(t);
		}
		const yl = svgEl("text", { x: 12, y: (H - m.b + m.t) / 2, transform: "rotate(-90 12 " + (H - m.b + m.t) / 2 + ")", "text-anchor": "middle" });
		yl.textContent = "Bits of entropy";
		axis.appendChild(yl);

		// x axis ticks
		const step = Math.max(1, Math.ceil(xMax / 10));
		for (let len = 1; len <= xMax; len += step) {
			const t = svgEl("text", { x: x(len), y: H - m.b + 16, "text-anchor": "middle" });
			t.textContent = len;
			axis.appendChild(t);
		}
		axis.appendChild(svgEl("line", { x1: m.l, x2: W - m.r, y1: H - m.b, y2: H - m.b }));
		const xl = svgEl("text", { x: (m.l + W - m.r) / 2, y: H - 4, "text-anchor": "middle" });
		xl.textContent = "Length";
		axis.appendChild(xl);
		svg.appendChild(grid);
		svg.appendChild(axis);

		// areas and lines
		function series(offset) {
			const pts = [];
			for (let len = 1; len <= xMax; len++) pts.push([x(len), y(Math.max(0, len * bpc - offset))]);
			return pts;
		}
		function area(pts) {
			return "M" + pts[0][0] + "," + y(0) + " L" + pts.map((p) => p.join(",")).join(" L") + " L" + pts[pts.length - 1][0] + "," + y(0) + " Z";
		}
		function line(pts) {
			return "M" + pts.map((p) => p.join(",")).join(" L");
		}
		const full = series(0), avg = series(1);
		svg.appendChild(svgEl("path", { d: area(full), fill: NAVY, "fill-opacity": 0.14 }));
		svg.appendChild(svgEl("path", { d: area(avg), fill: RED, "fill-opacity": 0.16 }));
		svg.appendChild(svgEl("path", { d: line(full), fill: "none", stroke: NAVY, "stroke-width": 2 }));
		svg.appendChild(svgEl("path", { d: line(avg), fill: "none", stroke: RED, "stroke-width": 2, "stroke-dasharray": "5 3" }));

		// direct labels at the right edge
		const lastFull = Math.min(xMax * bpc, MAX_BITS), lastAvg = Math.min(xMax * bpc - 1, MAX_BITS);
		const l1 = svgEl("text", { x: W - m.r + 8, y: y(lastFull) - 2, class: "series-label" });
		l1.textContent = "Entire space";
		const l2 = svgEl("text", { x: W - m.r + 8, y: y(lastAvg) + 14, class: "series-label" });
		l2.textContent = "Average case";
		svg.appendChild(l1);
		svg.appendChild(l2);

		// current length marker
		if (state.length <= xMax) {
			const cx = x(state.length);
			svg.appendChild(svgEl("line", { x1: cx, x2: cx, y1: m.t, y2: H - m.b, stroke: "#5A6472", "stroke-dasharray": "2 3" }));
			svg.appendChild(svgEl("circle", { cx: cx, cy: y(state.length * bpc), r: 5, fill: NAVY, stroke: "#FFFFFF", "stroke-width": 2 }));
		}

		// hover crosshair and tooltip
		const cross = svgEl("line", { y1: m.t, y2: H - m.b, stroke: "#9AA3AE", visibility: "hidden" });
		svg.appendChild(cross);
		const hit = svgEl("rect", { x: m.l, y: m.t, width: W - m.l - m.r, height: H - m.t - m.b, fill: "transparent" });
		svg.appendChild(hit);
		const tip = document.createElement("div");
		tip.className = "chart-tip";
		host.appendChild(svg);
		host.appendChild(tip);

		hit.addEventListener("mousemove", (ev) => {
			const r = svg.getBoundingClientRect();
			const sx = ((ev.clientX - r.left) / r.width) * W;
			const len = Math.min(xMax, Math.max(1, Math.round(1 + ((sx - m.l) / (W - m.l - m.r)) * (xMax - 1))));
			cross.setAttribute("x1", x(len));
			cross.setAttribute("x2", x(len));
			cross.setAttribute("visibility", "visible");
			const bits = len * bpc;
			const avgLog10 = (bits - 1) * Math.LOG10E * Math.LN2 - Math.log10(state.rate);
			tip.innerHTML = "<strong>Length " + len + "</strong><br>" +
				'<span class="swatch" style="background:' + NAVY + '"></span>' + bits.toFixed(1) + " bits<br>" +
				'<span class="swatch" style="background:' + RED + '"></span>' + Math.max(0, bits - 1).toFixed(1) + " bits average<br>" +
				"Average: " + formatDuration(avgLog10);
			tip.style.display = "block";
			const px = (x(len) / W) * r.width;
			tip.style.left = (px > r.width * 0.6 ? px - tip.offsetWidth - 12 : px + 12) + "px";
			tip.style.top = "12px";
		});
		hit.addEventListener("mouseleave", () => {
			cross.setAttribute("visibility", "hidden");
			tip.style.display = "none";
		});
	}

	function updateEntropy() {
		const bpc = bitsPerChar();
		const bits = state.length * bpc;
		const log10Space = bits * Math.log10(2);
		const log10Rate = Math.log10(state.rate);
		$("ent-length-out").textContent = state.length;
		$("ent-bpc").textContent = bpc.toFixed(2);
		$("ent-bits").textContent = bits.toFixed(1);
		$("ent-space").textContent = formatCount(log10Space);
		$("ent-full").textContent = formatDuration(log10Space - log10Rate);
		$("ent-avg").textContent = formatDuration(log10Space - Math.log10(2) - log10Rate);
		drawChart();
		updateCracking();
	}

	// ---------- cracking explorer ----------

	function readTiers() {
		TIERS.forEach((t, i) => {
			t.gpus = Math.max(1, Number($("crk-gpus-" + i).value) || 1);
			t.purchase = Math.max(0, Number($("crk-buy-" + i).value) || 0);
		});
	}

	function buildTierControls() {
		const host = $("crk-tiers");
		host.innerHTML = TIERS.map((t, i) =>
			'<label>' + t.name + ' GPUs<input id="crk-gpus-' + i + '" type="number" min="1" value="' + t.gpus + '"></label>' +
			'<label>' + t.name + ' purchase $<input id="crk-buy-' + i + '" type="number" min="0" step="1000" value="' + t.purchase + '"></label>'
		).join("");
		host.querySelectorAll("input").forEach((el) => el.addEventListener("input", updateCracking));
	}

	function updateCracking() {
		if (!$("crk-table")) return;
		readTiers();
		const bits = state.length * bitsPerChar();
		const log10AvgGuesses = (bits - 1) * Math.log10(2);
		$("crk-password").textContent = state.length + " chars from " + state.alphabet.toLocaleString() + " (" + bits.toFixed(1) + " bits)";
		const model = $("crk-model").value;
		const watts = Number($("crk-watts").value) || 0;
		const kwh = Number($("crk-kwh").value) || 0;
		const rent = Number($("crk-rent").value) || 0;
		const dollarsPerGpuHour = model === "energy" ? (watts / 1000) * kwh : rent;

		let html = "<thead><tr><th>Hash</th>" + TIERS.map((t) =>
			'<th class="num">' + t.name + "<br><small>" + t.gpus.toLocaleString() + " GPU" + (t.gpus > 1 ? "s" : "") +
			(t.purchase ? " · ~$" + t.purchase.toLocaleString() + " to buy" : " · rented") + "</small></th>").join("") +
			'<th class="num">Cost (any tier)</th></tr></thead><tbody>';
		ALGORITHMS.forEach((a) => {
			const log10GpuSeconds = log10AvgGuesses - Math.log10(a.rate);
			html += "<tr><td>" + a.name + "</td>";
			TIERS.forEach((t) => {
				html += '<td class="num">' + formatDuration(log10GpuSeconds - Math.log10(t.gpus)) + "</td>";
			});
			const log10Cost = log10GpuSeconds - Math.log10(3600) + Math.log10(dollarsPerGpuHour || 1e-300);
			html += '<td class="num">' + (dollarsPerGpuHour ? formatMoney(log10Cost) : "–") + "</td></tr>";
		});
		html += "</tbody>";
		$("crk-table").innerHTML = html;
	}

	// ---------- wiring ----------

	function init() {
		if (!$("entropy-tool")) return;
		$("ent-preset").addEventListener("change", (e) => {
			if (e.target.value !== "custom") {
				$("ent-alphabet").value = e.target.value;
				state.alphabet = Number(e.target.value);
				updateEntropy();
			}
		});
		$("ent-alphabet").addEventListener("input", (e) => {
			const v = Math.floor(Number(e.target.value));
			if (v >= 2) {
				state.alphabet = v;
				const match = Array.from($("ent-preset").options).find((o) => o.value === String(v));
				$("ent-preset").value = match ? match.value : "custom";
				updateEntropy();
			}
		});
		$("ent-length").addEventListener("input", (e) => {
			state.length = Number(e.target.value);
			updateEntropy();
		});
		$("ent-rate").addEventListener("change", (e) => {
			state.rate = Number(e.target.value);
			updateEntropy();
		});
		if ($("crk-table")) {
			buildTierControls();
			["crk-model", "crk-watts", "crk-kwh", "crk-rent"].forEach((id) => $(id).addEventListener("input", updateCracking));
		}
		updateEntropy();
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
