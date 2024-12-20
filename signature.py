from flask import Flask, request, jsonify
import subprocess
import base64
import json

app = Flask(__name__)

@app.route('/generate-signature', methods=['POST'])
def generate_signature():
    # Get the JWT header and payload from the POST request
    data = request.json
    jwt_header = data['header']
    jwt_payload = data['payload']
    private_key_path = "/home/datalab/sara/data-space-connector/private-key.pem"  # Replace with your private key path

    # Combine the JWT header and payload
    jwt_unsigned = f"{jwt_header}.{jwt_payload}"

    # Use OpenSSL to sign the JWT (ES256)
    try:
        signature = subprocess.check_output(
            ['openssl', 'dgst', '-sha256', '-binary', '-sign', private_key_path],
            input=jwt_unsigned.encode('utf-8')
        )

        # Base64 URL-encode the signature
        signature_base64 = base64.urlsafe_b64encode(signature).decode('utf-8').rstrip("=")

        # Return the signature
        return jsonify({'signature': signature_base64}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)  # Change port if needed
