// File: DVSA-ORDER-MANAGER/order-manager.js
// Lesson 05 — Broken Access Control
// Status: FIXED (router-level admin gate added)
//
// Mitigation: Add an explicit admin allow-list check immediately
// before the switch(action) dispatch. Non-admin callers attempting
// admin-only actions are rejected with HTTP 403 before any
// downstream Lambda is invoked.
//
// This is the router-level fix (defense layer #2). The full
// defense-in-depth posture for this vulnerability also requires:
//   - Layer #1: JSON.parse fix (see Lesson 01) — blocks the injection vector
//   - Layer #3: IAM least privilege (see Lesson 07)  — removes broad
//               lambda:InvokeFunction permission so even if injection
//               returned, admin Lambdas would not be reachable.
//
// The gate must run AFTER:
//   - JWT signature verification (Lesson 02 fix)
//   - The Cognito AdminGetUserCommand lookup that populates `isAdmin`
// so the `isAdmin` value being checked is trustworthy.

// ---------- BEFORE (vulnerable) ----------
// // No router-level admin check. Only one downstream branch
// // (admin-orders) checked isAdmin; all other branches dispatched
// // regardless of caller privilege.
// switch (action) {
//     case "complete":     /* dispatched without checking isAdmin */ break;
//     case "admin-orders": /* checked isAdmin internally */ break;
//     // ...
// }

// ---------- AFTER (fixed) ----------

// Lesson 5 fix: explicit admin gate before dispatch
const adminOnlyActions = ["complete", "admin-orders"];

if (adminOnlyActions.includes(action) && isAdmin !== "true") {
    const response = {
        statusCode: 403,
        headers: { "Access-Control-Allow-Origin": "*" },
        body: JSON.stringify({ status: "err", msg: "Forbidden: admin only" })
    };
    callback(null, response);
    return;
}

switch (action) {
    // ... existing cases unchanged ...
}
