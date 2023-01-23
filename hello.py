#!/usr/bin/env python
# encoding: utf-8
import json
from flask import Flask, jsonify,request
import werkzeug

app = Flask(__name__)


@app.route('/upload', methods=['POST'])
def upload():
    if(request.method == 'POST'):
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)
        imagefile.save("./assets/"+filename)
        return jsonify({"message":"Image Iploaded Successsfully"})
    else:
        return 'Something went wrong'

if __name__ == "__main__":

    app.run(host='0.0.0.0',debug=True, port=4000)