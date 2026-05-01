// File: DVSA-ORDER-MANAGER/order-manager.js
// Lesson 09 — Vulnerable Dependencies
// Status: FIXED
//
// Vulnerable package: node-serialize (CVE-2017-5941)
// Advisory: https://nvd.nist.gov/vuln/detail/CVE-2017-5941
//
// Mitigation: Remove the vulnerable dependency entirely from the
// request path. Replace serialize.unserialize() — which can
// reconstruct and invoke JavaScript functions from input strings —
// with the standard-library JSON.parse(), which produces only
// inert data structures.
//
// node-serialize is an unmaintained legacy library with a documented
// code-execution feature triggered by the _$$ND_FUNC$$_ marker.
// JSON.parse() has no such feature and is part of the Node.js
// runtime, so there is no third-party dependency to maintain.
//
// Both unsafe sinks must be removed:
//   - event.body  (was: serialize.unserialize)
//   - event.headers (was: serialize.unserialize)
//
// Additionally: remove `node-serialize` from package.json /
// package-lock.json so the vulnerable code is not even shipped
// in the deployment bundle. Add `npm audit` to the build pipeline
// to prevent reintroduction.

// ---------- BEFORE (vulnerable) ----------
// const serialize = require('node-serialize');   // CVE-2017-5941
// var req = serialize.unserialize(event.body);
// var headers = serialize.unserialize(event.headers);

// ---------- AFTER (fixed) ----------
// node-serialize import removed entirely
var req = JSON.parse(event.body);
var headers = event.headers;
