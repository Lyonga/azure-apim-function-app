import logging
import azure.functions as func
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    try:
        # Retrieve the message parameter from the query string or request body
        your_message = req.params.get("message")
        if not your_message:
            try:
                req_body = req.get_json()
            except ValueError:
                req_body = None
            if req_body:
                your_message = req_body.get("message")

        if not your_message:
            return func.HttpResponse(
                body=json.dumps({ "error": "Please provide a message" }),
                status_code=400,
                mimetype="application/json"
            )

        # Check the content of the message
        if "hello" in your_message.lower() or "world" in your_message.lower():
            return func.HttpResponse(
                body=json.dumps({ "error": "Think of a better message" }),
                status_code=422,
                mimetype="application/json"
            )

        return func.HttpResponse(
            body=json.dumps({ "message": your_message }),
            status_code=200,
            mimetype="application/json"
        )
    except Exception as e:
        logging.error(f"Exception: {e}")
        return func.HttpResponse(
            body=json.dumps({ "error": "An error occurred" }),
            status_code=500,
            mimetype="application/json"
        )
