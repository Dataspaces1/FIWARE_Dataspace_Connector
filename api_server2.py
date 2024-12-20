from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route('/run-docker', methods=['POST'])
def run_docker():
    try:
        # Path to mount
        cert_path = request.json.get('cert_path', './')
        
        # Convert to absolute path
        cert_path = os.path.abspath(cert_path)
        
        # Check if the path exists
        if not os.path.exists(cert_path):
            return jsonify({'error': f'Path does not exist: {cert_path}'}), 400
        
        # Docker command
        command = [
            'docker', 'run', '-v', f'{cert_path}:/cert',
            'quay.io/wi_stefan/did-helper:0.1.1'
        ]

        # Execute Docker command
        result = subprocess.run(command, capture_output=True, text=True)

        if result.returncode != 0:
            return jsonify({'error': result.stderr.strip()}), 400

        return jsonify({'output': result.stdout.strip()}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005)
