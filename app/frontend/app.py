from flask import Flask
import requests

app = Flask(__name__)

BACKEND_URL = "http://backend-container:5000"

@app.route('/')
def home():
    try:
        response = requests.get(f"{BACKEND_URL}/")
        return f"Frontend talking to Backend: {response.text}"
    except Exception as e:
        return f"Error connecting to backend: {str(e)}"

@app.route('/health')
def health():
    return "Frontend is healthy!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)