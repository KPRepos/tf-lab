import pymongo, jsonify, json, random, os
from flask import Flask, jsonify, render_template
from bson.json_util import dumps


DATABASE_NAME = "sample_weatherdata"
DATABASE_HOST = os.getenv("db_host")
DATABASE_USERNAME = "adminUser"
DATABASE_PASSWORD = os.getenv("db_password")

myclient = pymongo.MongoClient( DATABASE_HOST , 27017, username= DATABASE_USERNAME , password= DATABASE_PASSWORD )
mydb = myclient["sample_weatherdata"]
collection = mydb["data"]
print("[+] Database connected!")

app = Flask(__name__)
@app.route('/')
def index():
    documents = list(collection.find().limit(4))
    print(documents)
    parseddata = dumps(documents)
    return parseddata


images = [
    "https://www.wiz.io/_next/static/media/G2HeroImage.38debc90.png",
    "https://www.datocms-assets.com/75231/1659993557-edited_hp_graph.png?fm=web"
]

@app.route("/images")
def displayimages():
    url = random.choice(images)
    return render_template('index.html', url=url)

   
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5555, debug=True)

