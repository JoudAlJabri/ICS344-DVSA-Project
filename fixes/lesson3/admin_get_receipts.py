def lambda_handler(event, context):
    if not event.get("isAdmin") or event.get("isAdmin") != "true":
        return {
            "status": "err",
            "message": "Unauthorized - Admin access required"
}
