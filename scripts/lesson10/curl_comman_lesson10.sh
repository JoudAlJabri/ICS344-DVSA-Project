export API= "https://p2x3oihjo8.execute-api.us-east-1.amazonaws.com/dvsa/order"
export TOKEN="JWT_TOKEN"


curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: $TOKEN" \
  -d '{"action": "get" , "order_id":null}' | python3 -m json.tool

curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: $TOKEN" \
  -d '{"action": "billing" , "order_id": XXXXX, "data" :null}' | python3 -m json.tool
