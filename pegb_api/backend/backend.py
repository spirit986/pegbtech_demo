from flask import Flask, jsonify, request, render_template
from flask_restful import Api, Resource
from pymongo import MongoClient

#Own classes and functions
from classes.api_classes import *

backend = Flask(__name__)
api = Api(backend)


api.add_resource(ListUsers, "/users")
api.add_resource(ListPosts, "/posts")
api.add_resource(Add, "/add")
api.add_resource(AddMany, "/addmany")
api.add_resource(Subtract, "/subtract")
api.add_resource(Multiply, "/multiply")
api.add_resource(Divide, "/divide")


@backend.route('/')
@backend.route('/index')
def index():
    return render_template("welcome.html")


if __name__ == "__main__":
    backend.run(debug=True, host='0.0.0.0')

