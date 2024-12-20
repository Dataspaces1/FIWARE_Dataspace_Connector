from flask import Flask, jsonify
import os
import json

app = Flask(__name__)

# Endpoint to read did.json and extract HOLDER_DID
@app.route('/read-did', methods=['GET'])
def read_did():
    # Path to did.json
    file_path = os.path.join(os.getcwd(), 'did.json')
    try:
        with open(file_path, 'r') as file:
            did_data = json.load(file)
            holder_did = did_data.get("id", None)
            if holder_did:
                return jsonify({"HOLDER_DID": holder_did}), 200
            else:
                return jsonify({"error": "HOLDER_DID not found in did.json"}), 404
    except FileNotFoundError:
        return jsonify({"error": "did.json not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Endpoint to read the private key
@app.route('/read-private-key', methods=['GET'])
def read_private_key():
    # Path to the private key file
    key_path = os.path.join(os.getcwd(), 'private-key.pem')
    try:
        with open(key_path, 'r') as file:
            private_key = file.read()
            return jsonify({"private_key": private_key}), 200
    except FileNotFoundError:
        return jsonify({"error": "private-key.pem not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
