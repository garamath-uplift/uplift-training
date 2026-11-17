/* uplift-scorm-runtime v1.0
 *
 * SCORM 2004 4th Edition tracking for Uplift training modules. tools/module.ps1 adds this file to a module's
 * index.html when it builds a package or a preview. Don't paste it into a module's source by hand.
 *
 * What it reports to the LMS:
 * - cmi.completion_status: "incomplete" on first launch, then "completed" once every milestone is reached.
 *   Milestones are the [data-jalon] markers in the page; the module reaches them with SCORM2004.reach(id).
 * - cmi.progress_measure: share of milestones reached (0 to 1).
 * - cmi.score.raw / min / max / scaled: whatever the module passes to SCORM2004.score(raw, min, max).
 * - cmi.suspend_data: {"v":1,"reached":[...]} so a returning learner resumes. The module reads it on load.
 * - cmi.session_time and cmi.exit "suspend" when the window closes, so progress is kept.
 * - cmi.success_status is set by the module itself (it calls the LMS API directly once every check is passed).
 * - cmi.interactions (one record per answered check question): ONLY when the module's settings turn
 *   "interactions" on. Off by default.
 *
 * Nothing is written in the LMS's browse or review mode (SCORM2004.isPreview() is true then).
 *
 * Settings come from window.__UPLIFT_SCORM, which the build adds just before this file:
 *   { interactions: false, testMode: false }
 * testMode is true only in preview builds (tools/module.ps1 preview). When no LMS is found, test mode installs a
 * pretend LMS in the browser and shows a small panel with what would be reported. Packages built for the LMS
 * always have testMode false, so learners never see the panel.
 *
 * Plain ES5 on purpose: no build step, and it runs in every browser the LMS supports.
 */
(function () {
  "use strict";
  if (window.SCORM2004 && window.SCORM2004.__uplift) { return; } // added twice: keep the first

  var VERSION = "1.0";
  var SUSPEND_MAX = 64000;
  var COMMIT_DELAY_MS = 1000;
  var cfg = window.__UPLIFT_SCORM || {};
  var interactionsOn = cfg.interactions === true;
  var testMode = cfg.testMode === true;

  var api = null, initialized = false, terminated = false, readOnly = false;
  var reached = [], completed = false, startTime = new Date().getTime();
  var commitTimer = null, interactionCount = null;

  function log(msg) { if (testMode && window.console) { console.log("[uplift-scorm] " + msg); } }

  // ---------- Finding the LMS ----------
  // The SCORM 2004 API object (API_1484_11) lives on a parent frame or on the window that opened this one.
  function findApi() {
    var start = [window];
    try { if (window.opener) { start.push(window.opener); } } catch (e) {}
    for (var s = 0; s < start.length; s++) {
      var win = start[s];
      for (var depth = 0; win && depth < 500; depth++) {
        try { if (win.API_1484_11) { return win.API_1484_11; } } catch (e) { break; } // another site's frame
        try { if (!win.parent || win.parent === win) { break; } win = win.parent; } catch (e) { break; }
      }
    }
    return null;
  }

  function get(name) {
    if (!api) { return ""; }
    try { return String(api.GetValue(name)); } catch (e) { return ""; }
  }
  function set(name, value) {
    if (!api || !initialized || terminated || readOnly) { return false; }
    try {
      var ok = String(api.SetValue(name, String(value))) === "true";
      if (!ok) { log("SetValue " + name + " failed: " + api.GetLastError() + " " + api.GetErrorString(api.GetLastError())); }
      return ok;
    } catch (e) { return false; }
  }
  function commitSoon() {
    if (commitTimer) { return; }
    commitTimer = setTimeout(function () { commitTimer = null; commitNow(); }, COMMIT_DELAY_MS);
  }
  function commitNow() {
    if (commitTimer) { clearTimeout(commitTimer); commitTimer = null; }
    if (!api || !initialized || terminated || readOnly) { return; }
    try { api.Commit(""); } catch (e) {}
    if (panel) { panel.refresh(); }
  }

  // ---------- Milestones ----------
  function milestoneIds() {
    var ids = [], els = document.querySelectorAll("[data-jalon]");
    for (var i = 0; i < els.length; i++) {
      var id = els[i].getAttribute("data-jalon");
      if (id && ids.indexOf(id) === -1) { ids.push(id); }
    }
    return ids;
  }
  function progress() {
    var ids = milestoneIds();
    if (!ids.length) { return 0; }
    var n = 0;
    for (var i = 0; i < ids.length; i++) { if (reached.indexOf(ids[i]) !== -1) { n++; } }
    return n / ids.length;
  }
  function saveSuspend() {
    var data = JSON.stringify({ v: 1, reached: reached });
    if (data.length > SUSPEND_MAX) { log("suspend_data too long, not saved"); return; }
    set("cmi.suspend_data", data);
  }
  function reach(id) {
    id = String(id || "");
    var ids = milestoneIds();
    if (ids.indexOf(id) === -1) { log('reach("' + id + '") ignored: no [data-jalon="' + id + '"] marker'); return; }
    if (reached.indexOf(id) !== -1) { return; }
    reached.push(id);
    var p = progress();
    set("cmi.progress_measure", p.toFixed(4));
    saveSuspend();
    if (p >= 1 && !completed) {
      completed = true;
      set("cmi.completion_status", "completed");
      log("all milestones reached: completed");
    }
    commitSoon();
  }

  // ---------- Score ----------
  function score(raw, min, max) {
    raw = Number(raw); min = Number(min || 0); max = Number(max);
    if (!isFinite(raw) || !isFinite(max) || max <= min) { log("score ignored: bad numbers"); return; }
    var scaled = Math.max(0, Math.min(1, (raw - min) / (max - min)));
    set("cmi.score.min", min);
    set("cmi.score.max", max);
    set("cmi.score.raw", raw);
    set("cmi.score.scaled", scaled.toFixed(4));
    commitSoon();
  }

  // ---------- Question-level answers (off unless the module turns them on) ----------
  function timestamp() {
    var d = new Date();
    function two(n) { return (n < 10 ? "0" : "") + n; }
    return d.getFullYear() + "-" + two(d.getMonth() + 1) + "-" + two(d.getDate()) + "T" +
      two(d.getHours()) + ":" + two(d.getMinutes()) + ":" + two(d.getSeconds());
  }
  function cleanId(s) { return String(s || "").replace(/\s+/g, "-").replace(/[^A-Za-z0-9_.:\-]/g, "").slice(0, 200); }
  function answer(questionId, response, correctResponse, isCorrect, description) {
    if (!interactionsOn) { return; }
    var id = cleanId(questionId);
    if (!id) { return; }
    if (interactionCount === null) { interactionCount = Number(get("cmi.interactions._count")) || 0; }
    var n = "cmi.interactions." + interactionCount + ".";
    if (!set(n + "id", id)) { return; }
    set(n + "type", "choice");
    set(n + "timestamp", timestamp());
    if (correctResponse) { set(n + "correct_responses.0.pattern", cleanId(correctResponse)); }
    set(n + "learner_response", cleanId(response));
    set(n + "result", isCorrect ? "correct" : "incorrect");
    if (description) { set(n + "description", String(description).replace(/\s+/g, " ").trim().slice(0, 250)); }
    interactionCount++;
    commitSoon();
  }

  // ---------- Start and finish ----------
  function sessionTime() {
    var secs = Math.max(0, Math.round((new Date().getTime() - startTime) / 1000));
    var h = Math.floor(secs / 3600), m = Math.floor((secs % 3600) / 60), s = secs % 60;
    return "PT" + h + "H" + m + "M" + s + "S";
  }
  function terminate() {
    if (!api || !initialized || terminated) { return; }
    if (!readOnly) {
      set("cmi.session_time", sessionTime());
      set("cmi.exit", "suspend"); // keep the attempt open, so progress and completion carry over
      try { api.Commit(""); } catch (e) {}
    }
    try { api.Terminate(""); } catch (e) {}
    terminated = true;
    if (panel) { panel.refresh(); }
  }

  function init() {
    api = findApi();
    if (!api && testMode) { api = installTestLms(); }
    if (!api) { log("no LMS found: the module runs, nothing is reported"); return; }
    try { initialized = String(api.Initialize("")) === "true"; } catch (e) { initialized = false; }
    if (!initialized) { log("Initialize failed"); return; }

    var mode = get("cmi.mode");
    readOnly = mode === "browse" || mode === "review";

    try {
      var data = JSON.parse(get("cmi.suspend_data") || "{}");
      if (data && Object.prototype.toString.call(data.reached) === "[object Array]") { reached = data.reached.slice(); }
    } catch (e) { reached = []; }
    completed = get("cmi.completion_status") === "completed";
    if (!completed && !readOnly) { set("cmi.completion_status", "incomplete"); commitSoon(); }

    window.addEventListener("pagehide", terminate);
    window.addEventListener("beforeunload", terminate);
    document.addEventListener("visibilitychange", function () { if (document.visibilityState === "hidden") { commitNow(); } });
  }

  // ---------- Test mode: a pretend LMS for previews ----------
  var panel = null;
  function installTestLms() {
    var key = "uplift-scorm-test:" + (document.title || "module");
    var store = {}, lastError = "0";
    try { store = JSON.parse(localStorage.getItem(key) || "{}"); } catch (e) { store = {}; }
    var returning = !!store["cmi.suspend_data"] && store["cmi.exit"] === "suspend";
    store["cmi.entry"] = returning ? "resume" : "ab-initio";
    store["cmi.mode"] = "normal";
    if (!store["cmi.completion_status"]) { store["cmi.completion_status"] = "not attempted"; }
    if (!store["cmi.success_status"]) { store["cmi.success_status"] = "unknown"; }
    function save() { try { localStorage.setItem(key, JSON.stringify(store)); } catch (e) {} }
    var mock = {
      Initialize: function () { return "true"; },
      Terminate: function () { save(); return "true"; },
      Commit: function () { save(); return "true"; },
      GetValue: function (k) {
        if (k === "cmi.interactions._count") {
          var n = 0; while (store["cmi.interactions." + n + ".id"] !== undefined) { n++; } return String(n);
        }
        return store[k] === undefined ? "" : String(store[k]);
      },
      SetValue: function (k, v) { store[k] = String(v); lastError = "0"; if (panel) { panel.refresh(); } return "true"; },
      GetLastError: function () { return lastError; },
      GetErrorString: function () { return ""; },
      GetDiagnostic: function () { return ""; }
    };
    window.API_1484_11 = mock;
    function build() {
      var box = document.createElement("aside");
      box.setAttribute("aria-label", "Test LMS (preview only)");
      box.style.cssText = "position:fixed;left:12px;bottom:12px;z-index:9999;width:300px;max-width:calc(100vw - 24px);" +
        "font:13px/1.45 system-ui,sans-serif;background:#fff;color:#1a1a1a;border:2px solid #1a1a1a;border-radius:10px;" +
        "box-shadow:0 8px 24px rgba(0,0,0,.25);padding:10px 12px";
      box.innerHTML = '<strong>Test LMS</strong> <span style="color:#4b5563">(preview only, not in packages)</span>' +
        '<dl style="margin:6px 0;display:grid;grid-template-columns:auto 1fr;gap:2px 10px"></dl>' +
        '<button type="button" data-act="reset">Reset test learner</button> ' +
        '<button type="button" data-act="hide">Hide</button>';
      document.body.appendChild(box);
      var dl = box.querySelector("dl");
      box.addEventListener("click", function (e) {
        var act = e.target.getAttribute && e.target.getAttribute("data-act");
        if (act === "reset") { try { localStorage.removeItem(key); } catch (x) {} terminated = true; location.reload(); }
        if (act === "hide") { box.hidden = true; }
      });
      return {
        refresh: function () {
          var rows = [
            ["Completion", store["cmi.completion_status"]],
            ["Success", store["cmi.success_status"]],
            ["Score", (store["cmi.score.raw"] || "-") + " of " + (store["cmi.score.max"] || "-") + " (scaled " + (store["cmi.score.scaled"] || "-") + ")"],
            ["Progress", Math.round(Number(store["cmi.progress_measure"] || 0) * 100) + "%"],
            ["Reached", reached.join(", ") || "-"],
            ["Answers", interactionsOn ? mock.GetValue("cmi.interactions._count") + " recorded" : "off"],
            ["Entry", store["cmi.entry"]]
          ];
          dl.innerHTML = "";
          rows.forEach(function (r) {
            var dt = document.createElement("dt"), dd = document.createElement("dd");
            dt.textContent = r[0]; dt.style.fontWeight = "700"; dd.textContent = r[1]; dd.style.margin = "0";
            dl.appendChild(dt); dl.appendChild(dd);
          });
        }
      };
    }
    function show() { panel = build(); panel.refresh(); }
    if (document.body) { show(); } else { document.addEventListener("DOMContentLoaded", show); }
    log("test mode: pretend LMS installed (stored in this browser)");
    return mock;
  }

  // ---------- Public interface used by the module ----------
  window.SCORM2004 = {
    __uplift: VERSION,
    reach: reach,
    progress: progress,
    score: score,
    answer: answer,
    isPreview: function () { return readOnly; },
    commit: commitNow
  };

  init();
})();
