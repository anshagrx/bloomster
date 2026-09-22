// ==UserScript==
// @name         Thunder Trail - Stealth Autoplayer v3.0
// @namespace    https://thunder-zone.coke2home.com/
// @version      3.0
// @description  Stealth v3.0 – Direct React-fiber queue injection. Zero KeyboardEvents.
// @match        https://thunder-zone.coke2home.com/*
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function () {
  "use strict";

  // ── CONFIGURATION ──
  const GAME_TIERS = [
    { untilMs: 15000, travelMs: 1700, spawnMs: 1000 },
    { untilMs: 31000, travelMs: 1500, spawnMs: 800 },
    { untilMs: 46000, travelMs: 1300, spawnMs: 700 },
    { untilMs: 61000, travelMs: 1100, spawnMs: 600 },
    { untilMs: 76000, travelMs: 950, spawnMs: 500 },
    { untilMs: Infinity, travelMs: 800, spawnMs: 400 },
  ];

  const config = {
    enabled: true,
    neverLose: true,
    targetScore: 0,
    missSome: true,
    mistakeEveryMin: 12,
    mistakeEveryMax: 22,
    minHpToMiss: 2,
  };

  const state = {
    currentScore: 0,
    currentHp: 3,
    currentPhase: "idle",
    statusMsg: "Waiting…",
    humanMisses: 0,
    movesToNextMistake: 0,
  };

  let gameStartTime = 0;
  let gameElapsedTime = 0;
  let isStopwatchRunning = false;
  let previousPhase = "idle";
  let currentTargetId = null;
  let movesSinceLastMistake = 0;
  let totalHumanMistakes = 0;
  let nextMistakeTarget = _randomMistakeTarget();
  let _swipeQueueRef = null;
  let _pending = null;
  let lastTickMs = 0;
  let hudEl = null;
  let _started = false;

  const DIRS = ["up", "down", "left", "right"];

  function _randomMistakeTarget() {
    return (
      Math.floor(
        Math.random() * (config.mistakeEveryMax - config.mistakeEveryMin + 1),
      ) + config.mistakeEveryMin
    );
  }

  function _getTierData(elapsedMs) {
    for (const t of GAME_TIERS) if (elapsedMs < t.untilMs) return t;
    return GAME_TIERS[GAME_TIERS.length - 1];
  }

  function _adaptiveSettings(elapsedMs) {
    const { travelMs } = _getTierData(elapsedMs);
    const triggerFrac = 0.42 + Math.random() * 0.08;
    const triggerProgress = triggerFrac;
    const remainingMs = (1 - triggerFrac) * travelMs;
    const reactionMin = Math.max(40, remainingMs * 0.15);
    const reactionMax = Math.max(reactionMin + 30, remainingMs * 0.45);
    return { triggerProgress, reactionMin, reactionMax };
  }

  function _adaptiveDelay(elapsedMs) {
    const { reactionMin, reactionMax } = _adaptiveSettings(elapsedMs);
    return reactionMin + Math.random() * (reactionMax - reactionMin);
  }

  function _adaptiveTriggerProgress(elapsedMs) {
    const { triggerProgress } = _adaptiveSettings(elapsedMs);
    const jitter = (Math.random() - 0.5) * 0.1;
    return Math.max(0.06, Math.min(0.7, triggerProgress + jitter));
  }

  function _fmtTime(ms) {
    if (!ms || ms < 0) return "00:00.0";
    const m = Math.floor(ms / 60000);
    const s = Math.floor((ms % 60000) / 1000);
    const t = Math.floor((ms % 1000) / 100);
    return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}.${t}`;
  }

  function _avoidDir(trapArrow) {
    const safe = DIRS.filter((d) => d !== trapArrow);
    return safe[Math.floor(Math.random() * safe.length)];
  }

  // ── FIND REACT GAME FIBER REF ──
  function getGameRef() {
    const canvas = document.querySelector("canvas");
    if (!canvas) return null;
    const fiberKey = Object.keys(canvas).find((k) =>
      k.startsWith("__reactFiber$"),
    );
    if (!fiberKey) return null;
    let fiber = canvas[fiberKey];
    while (fiber) {
      if (fiber.memoizedState) {
        let hook = fiber.memoizedState;
        while (hook) {
          const cur = hook.memoizedState?.current;
          if (
            cur &&
            Array.isArray(cur.boxes) &&
            typeof cur.hp === "number" &&
            typeof cur.score === "number"
          ) {
            return hook.memoizedState;
          }
          hook = hook.next;
        }
      }
      fiber = fiber.return;
    }
    return null;
  }

  // ── FIND THE INTERNAL SWIPE QUEUE (H.current) ──
  function getSwipeQueue() {
    if (_swipeQueueRef && Array.isArray(_swipeQueueRef.current))
      return _swipeQueueRef;
    const canvas = document.querySelector("canvas");
    if (!canvas) return null;
    const fiberKey = Object.keys(canvas).find((k) =>
      k.startsWith("__reactFiber$"),
    );
    if (!fiberKey) return null;
    let fiber = canvas[fiberKey];
    const candidates = [];
    while (fiber) {
      if (fiber.memoizedState) {
        let hook = fiber.memoizedState;
        while (hook) {
          const val = hook.memoizedState;
          if (
            val &&
            val.current !== undefined &&
            Array.isArray(val.current) &&
            !(val.current instanceof Set) &&
            !(val.current instanceof Map) &&
            val.current.length < 10
          ) {
            candidates.push(val);
          }
          hook = hook.next;
        }
      }
      fiber = fiber.return;
    }
    if (candidates.length > 0) {
      candidates.sort((a, b) => a.current.length - b.current.length);
      _swipeQueueRef = candidates[0];
      return _swipeQueueRef;
    }
    return null;
  }

  // ── INJECT SWIPE ──
  function injectSwipe(dir) {
    const qRef = getSwipeQueue();
    if (qRef) {
      qRef.current.push(dir);
      return;
    }
    _fallbackTouchSwipe(dir);
  }

  function _fallbackTouchSwipe(dir) {
    const canvas = document.querySelector("canvas");
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const cx = rect.left + rect.width / 2;
    const cy = rect.top + rect.height / 2;
    const dist = 36;
    const v = {
      up: [0, -dist],
      down: [0, dist],
      left: [-dist, 0],
      right: [dist, 0],
    };
    const [dx, dy] = v[dir] || [0, -dist];
    function mkTouch(x, y) {
      return new Touch({
        identifier: Date.now(),
        target: canvas,
        clientX: x,
        clientY: y,
      });
    }
    try {
      canvas.dispatchEvent(
        new TouchEvent("touchstart", {
          bubbles: true,
          cancelable: true,
          touches: [mkTouch(cx, cy)],
          changedTouches: [mkTouch(cx, cy)],
        }),
      );
      canvas.dispatchEvent(
        new TouchEvent("touchend", {
          bubbles: true,
          cancelable: true,
          touches: [],
          changedTouches: [mkTouch(cx + dx, cy + dy)],
        }),
      );
    } catch (_) {}
  }

  // ── PENDING SWIPE SCHEDULER ──
  function schedulePending(dir, boxId, elapsedMs) {
    _pending = {
      dir,
      boxId,
      fireAt: performance.now() + _adaptiveDelay(elapsedMs),
    };
  }

  function flushPending() {
    if (!_pending) return;
    if (performance.now() >= _pending.fireAt) {
      injectSwipe(_pending.dir);
      currentTargetId = _pending.boxId;
      _pending = null;
    }
  }

  // ── DECISION ENGINE ──
  function decideAction(gameState) {
    const boxes = gameState.boxes || [];
    if (!boxes.length) return;

    boxes.sort((a, b) => b.progress - a.progress);
    const elapsedMs = gameState.elapsedMs || 0;

    // Emergency flush: if ANY box is about to expire (>85% progress), swipe it NOW
    for (const box of boxes) {
      if (box.id !== currentTargetId && box.progress >= 0.85) {
        _pending = null;
        let emergDir;
        if (box.type === "heart") emergDir = box.arrow;
        else if (box.type === "trap") emergDir = _avoidDir(box.arrow);
        else emergDir = box.arrow;
        injectSwipe(emergDir);
        currentTargetId = box.id;
        movesSinceLastMistake++;
        return;
      }
    }

    const lead = boxes[0];

    // Already queued or pending for this box
    if (lead.id === currentTargetId) return;
    if (_pending && _pending.boxId === lead.id) return;

    // Wait until box enters the adaptive swipe window for this tier
    if (lead.progress < _adaptiveTriggerProgress(elapsedMs)) return;

    const isMistakeDue = movesSinceLastMistake >= nextMistakeTarget;
    const inSafeTier = elapsedMs < 160000;
    const canMiss =
      config.missSome &&
      isMistakeDue &&
      gameState.hp >= config.minHpToMiss &&
      inSafeTier;

    let dir;
    if (lead.type === "heart") {
      dir = lead.arrow;
      movesSinceLastMistake++;
    } else if (canMiss) {
      movesSinceLastMistake = 0;
      nextMistakeTarget = _randomMistakeTarget();
      totalHumanMistakes++;
      state.humanMisses = totalHumanMistakes;
      if (lead.type === "trap") {
        dir = lead.arrow; // Follow trap arrow = take damage (mistake)
      } else {
        const wrong = DIRS.filter((d) => d !== lead.arrow);
        dir = wrong[Math.floor(Math.random() * wrong.length)];
      }
    } else if (lead.type === "trap") {
      dir = _avoidDir(lead.arrow);
      movesSinceLastMistake++;
    } else {
      dir = lead.arrow;
      movesSinceLastMistake++;
    }

    state.movesToNextMistake = Math.max(
      0,
      nextMistakeTarget - movesSinceLastMistake,
    );
    schedulePending(dir, lead.id, elapsedMs);
  }

  // ── MAIN LOOP ──
  function tick() {
    const now = performance.now();
    if (now - lastTickMs < 12) return;
    lastTickMs = now;

    if (!config.enabled) return;

    flushPending();

    const ref = getGameRef();
    if (!ref || !ref.current) {
      state.statusMsg = "Open /game and click Play";
      updateHUD();
      return;
    }

    const g = ref.current;
    const phase = g.phase;
    state.currentPhase = phase;
    state.currentHp = g.hp;
    state.currentScore = g.score;

    if (phase === "playing") {
      if (previousPhase !== "playing") {
        gameStartTime = performance.now();
        isStopwatchRunning = true;
        currentTargetId = null;
        _pending = null;
        _swipeQueueRef = null;
        movesSinceLastMistake = 0;
        nextMistakeTarget = _randomMistakeTarget();
        totalHumanMistakes = 0;
        state.humanMisses = 0;
      }
      gameElapsedTime = performance.now() - gameStartTime;
      decideAction(g);

      const _tier = _getTierData(g.elapsedMs || 0);
      let _tierLabel;
      if (_tier.spawnMs >= 800) _tierLabel = `Slow(${_tier.spawnMs}ms)`;
      else if (_tier.spawnMs >= 500) _tierLabel = `Mid(${_tier.spawnMs}ms)`;
      else _tierLabel = `Fast(${_tier.spawnMs}ms)`;

      state.statusMsg = `⚡ ${_tierLabel} | Score: ${g.score.toLocaleString()} | HP: ${"❤️".repeat(Math.max(0, g.hp))}`;
    } else if (phase === "gameover") {
      if (isStopwatchRunning) {
        isStopwatchRunning = false;
        gameElapsedTime = performance.now() - gameStartTime;
      }
      currentTargetId = null;
      _pending = null;
      state.statusMsg = `💀 Game Over! Final: ${g.score.toLocaleString()} (${_fmtTime(gameElapsedTime)})`;
    } else {
      if (!isStopwatchRunning) gameElapsedTime = 0;
      currentTargetId = null;
      state.statusMsg = `Waiting… (phase: ${phase})`;
    }

    previousPhase = phase;
    updateHUD();
  }

  function animLoop() {
    tick();
    requestAnimationFrame(animLoop);
  }

  // ── FLOATING HUD ──
  function createHUD() {
    if (document.getElementById("tt-hud-v3")) return;
    hudEl = document.createElement("div");
    hudEl.id = "tt-hud-v3";
    Object.assign(hudEl.style, {
      position: "fixed",
      bottom: "16px",
      right: "16px",
      zIndex: "999999",
      background:
        "linear-gradient(135deg,rgba(10,15,30,0.97),rgba(20,28,52,0.97))",
      backdropFilter: "blur(14px)",
      color: "#f0f4ff",
      fontFamily: 'system-ui,-apple-system,"Segoe UI",Roboto,sans-serif',
      fontSize: "12px",
      padding: "14px 16px",
      borderRadius: "14px",
      boxShadow: "0 12px 36px rgba(0,0,0,0.7),0 0 0 1px rgba(100,160,255,0.18)",
      minWidth: "270px",
      userSelect: "none",
    });
    hudEl.innerHTML = `
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;padding-bottom:8px;border-bottom:1px solid rgba(255,255,255,0.08)">
                <span style="font-weight:800;color:#60a5fa;font-size:13px;letter-spacing:.5px">⚡ TT STEALTH v3.0</span>
                <button id="tt3-toggle" style="background:#22c55e;color:#000;font-weight:800;border:none;padding:3px 10px;border-radius:6px;cursor:pointer;font-size:11px">ON</button>
            </div>
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;background:rgba(96,165,250,0.08);padding:4px 8px;border-radius:6px;border:1px solid rgba(96,165,250,0.15)">
                <span style="color:#94a3b8;font-weight:700">⏱</span>
                <span id="tt3-time" style="font-weight:900;color:#60a5fa;font-size:15px;font-variant-numeric:tabular-nums;font-family:ui-monospace,monospace">00:00.0</span>
            </div>
            <div style="display:flex;justify-content:space-between;margin-bottom:5px">
                <span style="color:#94a3b8">Score:</span>
                <span id="tt3-score" style="font-weight:800;color:#facc15;font-size:14px">0</span>
            </div>
            <div style="display:flex;justify-content:space-between;margin-bottom:5px">
                <span style="color:#94a3b8">Lives:</span>
                <span id="tt3-hp" style="font-weight:700;letter-spacing:2px">❤️❤️❤️</span>
            </div>
            <div style="display:flex;justify-content:space-between;margin-bottom:5px">
                <span style="color:#94a3b8">Mistakes:</span>
                <span id="tt3-miss" style="font-weight:700;color:#fb923c;font-size:11px">0 (next in 0)</span>
            </div>
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px">
                <span style="color:#94a3b8">Make Mistakes:</span>
                <label style="display:flex;align-items:center;cursor:pointer;color:#60a5fa;font-weight:700;font-size:11px">
                    <input id="tt3-miss-cb" type="checkbox" checked style="accent-color:#60a5fa;margin-right:4px;cursor:pointer" />
                    <span id="tt3-miss-label">ON</span>
                </label>
            </div>
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px">
                <span style="color:#94a3b8">Mode:</span>
                <select id="tt3-mode" style="background:#0f172a;color:#60a5fa;border:1px solid #334155;border-radius:4px;padding:2px 4px;font-size:11px;font-weight:700;outline:none">
                    <option value="human" selected>👤 Human (Adaptive, Safe)</option>
                </select>
            </div>
            <div style="font-size:10px;color:#60a5fa;text-align:center;margin-bottom:6px;background:rgba(96,165,250,0.08);padding:4px;border-radius:4px">
                ⌨ Press <b>'S'</b> to Start / Pause
            </div>
            <div id="tt3-status" style="font-size:11px;color:#cbd5e1;border-top:1px solid rgba(255,255,255,0.08);padding-top:6px;line-height:1.4;min-height:28px">Waiting…</div>
        `;
    document.body.appendChild(hudEl);

    document
      .getElementById("tt3-toggle")
      .addEventListener("click", _toggleEnabled);
    document.getElementById("tt3-mode").addEventListener("change", (e) => {
      config.mode = e.target.value;
    });
    document.getElementById("tt3-miss-cb").addEventListener("change", (e) => {
      config.missSome = e.target.checked;
      document.getElementById("tt3-miss-label").textContent = config.missSome
        ? "ON"
        : "OFF";
    });
    window.addEventListener("keydown", (e) => {
      if (
        e.target &&
        (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA")
      )
        return;
      if (e.key === "s" || e.key === "S") _toggleEnabled();
    });
  }

  function _toggleEnabled() {
    config.enabled = !config.enabled;
    const btn = document.getElementById("tt3-toggle");
    if (btn) {
      btn.textContent = config.enabled ? "ON" : "OFF";
      btn.style.background = config.enabled ? "#22c55e" : "#ef4444";
    }
    state.statusMsg = config.enabled ? "⚡ Resumed" : "⏸ Paused (S to resume)";
    updateHUD();
  }

  function updateHUD() {
    if (!hudEl) createHUD();
    const timeEl = document.getElementById("tt3-time");
    const scoreEl = document.getElementById("tt3-score");
    const hpEl = document.getElementById("tt3-hp");
    const missEl = document.getElementById("tt3-miss");
    const statEl = document.getElementById("tt3-status");

    if (timeEl) {
      timeEl.textContent = _fmtTime(gameElapsedTime);
      timeEl.style.color = isStopwatchRunning
        ? "#60a5fa"
        : state.currentPhase === "gameover"
          ? "#f43f5e"
          : "#64748b";
    }
    if (scoreEl) scoreEl.textContent = state.currentScore.toLocaleString();
    if (hpEl)
      hpEl.textContent =
        "❤️".repeat(Math.max(0, state.currentHp)) +
        "🖤".repeat(Math.max(0, 3 - state.currentHp));
    if (missEl) {
      if (config.missSome) {
        const n =
          typeof state.movesToNextMistake === "number"
            ? state.movesToNextMistake
            : 0;
        missEl.textContent = `${state.humanMisses} (next in ${n})`;
      } else {
        missEl.textContent = `${state.humanMisses} (OFF)`;
      }
    }
    if (statEl) statEl.textContent = state.statusMsg;
  }

  // ── INIT ──
  function safeInit() {
    if (_started) return;
    _started = true;
    createHUD();
    requestAnimationFrame(animLoop);
    setInterval(tick, 10);
  }

  if (
    document.readyState === "complete" ||
    document.readyState === "interactive"
  ) {
    safeInit();
  } else {
    window.addEventListener("DOMContentLoaded", safeInit);
  }
})();
