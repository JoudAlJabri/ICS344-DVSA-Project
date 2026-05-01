// File: DVSA-ORDER-MANAGER/order-manager.js
// Lesson 02 — Broken Authentication
// Status: FIXED
//
// Mitigation: Verify the JWT signature against Cognito's published JWKS
// before trusting any identity field (username, sub) from the payload.
//
// The vulnerable version decoded the payload and read token.username
// without invoking any signature-verification function. The fix:
//   1. Fetch the JWKS from the Cognito User Pool's well-known endpoint.
//   2. Build a keystore with jose.JWK.asKeyStore().
//   3. Cryptographically verify the token with jose.JWS.createVerify().
//   4. Only after successful verification, trust token.username.
//
// Any token whose signature does not validate against the JWKS is
// rejected with HTTP 401 "Invalid token".
//
// The User Pool ID is read from the Lambda environment variable
// `userpoolid` (set by the SAR deployment) so this code does not
// hard-code account-specific values.

// ---------- BEFORE (vulnerable) ----------
// var auth_data = jose.util.base64url.decode(token_sections[1]);
// var token = JSON.parse(auth_data);
// var user = token.username;   // trusted without ANY signature check

// ---------- AFTER (fixed) ----------
exports.handler = async (event, context) => {
    return new Promise(async (resolve, reject) => {
        const callback = (err, response) => resolve(response);

        var req = JSON.parse(event.body);
        var headers = event.headers;
        var auth_header = headers.Authorization || headers.authorization;

        if (!auth_header) {
            callback(null, {
                statusCode: 401,
                body: JSON.stringify({ status: 'err', msg: 'Missing authorization header' })
            });
            return;
        }

        var token_str = auth_header.replace(/^Bearer\s+/i, '').trim();

        const region = process.env.AWS_REGION;
        const userPoolId = process.env.userpoolid;
        const jwksUri = `https://cognito-idp.${region}.amazonaws.com/${userPoolId}/.well-known/jwks.json`;

        var user;
        try {
            const https = require('https');
            const jwks = await new Promise((resolve, reject) => {
                https.get(jwksUri, (res) => {
                    let data = '';
                    res.on('data', chunk => data += chunk);
                    res.on('end', () => resolve(JSON.parse(data)));
                    res.on('error', reject);
                });
            });

            const keystore = await jose.JWK.asKeyStore(jwks);
            const verified = await jose.JWS.createVerify(keystore).verify(token_str);
            var token = JSON.parse(verified.payload.toString());

            // Only trusted AFTER cryptographic verification
            user = token.username;
        } catch (err) {
            console.error('Token verification failed:', err.message);
            callback(null, {
                statusCode: 401,
                body: JSON.stringify({ status: 'err', msg: 'Invalid token' })
            });
            return;
        }

        var isAdmin = false;
        // ... rest of handler unchanged ...
    });
};
