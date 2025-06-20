from flask import Flask, request, jsonify, render_template
import requests

app = Flask(__name__, template_folder='templates')

# Dummy site key that always pass and is visible.
# CLOUDFLARE_SECRET_KEY = "1x0000000000000000000000000000000AA"
CLOUDFLARE_SECRET_KEY = "0x4AAAAAABEwqNSkvGCdbAMt4aYfPpbiuX0"
@app.route("/")
def home():
    return render_template("frontend.html")

@app.route("/status")
def healthcheck():
    return "Healthy"

@app.route("/verify", methods=["POST"])
def verify():
    token = request.form.get("cf-turnstile-response")
    if not token:
        return jsonify({"success": False, "message": "CAPTCHA token missing"}), 400

    response = requests.post("https://challenges.cloudflare.com/turnstile/v0/siteverify", verify=False, data={
        "secret": CLOUDFLARE_SECRET_KEY,
        "response": token
    })

    result = response.json()
    if result.get("success"):
        return jsonify({"success": True, "message": "CAPTCHA passed"})
    else:
        return jsonify({"success": False, "message": "CAPTCHA failed"}), 400

if __name__ == "__main__":
    # app.run(debug=True, ssl_context='adhoc')
    app.run(debug=True, host='ec2-3-145-156-203.us-east-2.compute.amazonaws.com')
    # app.run(debug=True, host='turnstile-demo.dynamicmotion.click')
    # app.run(debug=True)