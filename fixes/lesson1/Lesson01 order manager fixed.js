// File: DVSA-ORDER-MANAGER/order-manager.js
// Lesson 01 — Event Injection
// Status: FIXED
//
// Mitigation: Replaced node-serialize.unserialize() with the standard
// JSON.parse() for event.body, and removed parsing of event.headers
// entirely (API Gateway already provides it as a plain object).
//
// JSON.parse has no concept of executable markers — the _$$ND_FUNC$$_
// payload is rejected as invalid JSON and the injected function is
// never reconstructed or invoked.
//
// Both sinks must be patched:
//   - event.body  (was: serialize.unserialize)
//   - event.headers (was: serialize.unserialize)

// ---------- BEFORE (vulnerable) ----------
// const serialize = require('node-serialize');
// var req = serialize.unserialize(event.body);
// var headers = serialize.unserialize(event.headers);

// ---------- AFTER (fixed) ----------
var req = JSON.parse(event.body);
var headers = event.headers;
