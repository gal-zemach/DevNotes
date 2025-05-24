from flask import Flask, request, jsonify
from flask_cors import CORS, cross_origin
import json
import os

app = Flask(__name__)
CORS(app)

ROUTE_NOTES = "/notes"
DATA_FILE = "notes.json"
NOTES_FIELD = "note"

HTML_CREATED = 201
HTML_BAD_REQUEST = 400

ERROR_MISSING_NOTE = {"error" : "Note is required"}
SUCCESS_RESPONSE = {"success" : True}

@app.route(ROUTE_NOTES, methods=["GET"])
@cross_origin()
def get_notes():
    return jsonify(load_notes())

@app.route(ROUTE_NOTES, methods=["POST"])
@cross_origin()
def add_note():
    new_note = request.json.get(NOTES_FIELD)
    if not new_note:
        return jsonify(ERROR_MISSING_NOTE), HTML_BAD_REQUEST

    notes = load_notes()
    notes.append(new_note)
    save_notes(notes)
    return jsonify(SUCCESS_RESPONSE), HTML_CREATED

def load_notes():
    """
    Loads the notes file
    :return: The open file
    """
    if not os.path.exists(DATA_FILE):
        return []

    with open(DATA_FILE, "r") as f:
        return json.load(f)

def save_notes(notes):
    """
    Saves the notes to file
    :param notes: the current notes
    """
    with open(DATA_FILE, "w") as f:
        json.dump(notes, f)

print(app.url_map)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
