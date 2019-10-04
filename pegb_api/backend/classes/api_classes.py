from flask import Flask, jsonify, request
from flask_restful import Api, Resource
from pymongo import MongoClient

#DB Operations
client = MongoClient("mongodb://pegb-db:27017", username="mongoadmin", password="secret")
db = client.pebptechdemodb #DB Name
users_coll = db["Users"] #Users collention
posts_coll = db["Posts"] #Posts collention


def checkPostedData(postedData, functionName):
    if (functionName == "add" or functionName == "subtract" or functionName == "multiply"):
        if "x" not in postedData or "y" not in postedData:
            return 301
        else:
            return 200

    if (functionName == "divide"):
        if "x" not in postedData or "y" not in postedData:
            return 301
        elif int(postedData["y"]) == 0:
            return 302
        else:
            return 200


class ListUsers(Resource):
    def get(self):
        dbusers = []
        for user in users_coll.find():
            #user.pop("_id")
            user["_id"] = str(user["_id"])
            dbusers.append(user)

        return jsonify(dbusers)


class ListPosts(Resource):
    def get(self):
        dbposts = []
        for post in posts_coll.find():
            post["_id"] = str(post["_id"])
            dbposts.append(post)

        return jsonify(dbposts)


class Add(Resource):
    def post(self):
        #Get posted data:
        postedData = request.get_json()

        #Verify validity of posted data
        status_code = checkPostedData(postedData, "add")
        if (status_code != 200):
            retJson = {
                    "Message": "An error happened",
                    "Status Code":status_code
            }
            return jsonify(retJson)

        x = postedData["x"]
        y = postedData["y"]
        x = int(x)
        y = int(y)

        ret = x+y
        retMap = {
                'Message': ret,
                'Status Code': 200
        }
        return jsonify(retMap)


#Experimental attempt to add n number of arguments
class AddMany(Resource):
    def post(self):
        #Get posted data:
        postedData = request.get_json()
        
        sum = 0
        for i in postedData:
            postedData[i] = int(postedData[i])
            sum += postedData[i]

        return sum


class Subtract(Resource):
    def post(self):
        #Get posted data:
        postedData = request.get_json()

        #Verify validity of posted data
        status_code = checkPostedData(postedData, "subtract")
        if (status_code != 200):
            retJson = {
                    "Message": "An error happened",
                    "Status Code":status_code
            }
            return jsonify(retJson)

        x = postedData["x"]
        y = postedData["y"]
        x = int(x)
        y = int(y)

        ret = x-y
        retMap = {
                'Message': ret,
                'Status Code': 200
        }
        return jsonify(retMap)


class Divide(Resource):
    def post(self):
        #Get posted data:
        postedData = request.get_json()

        #Verify validity of posted data
        status_code = checkPostedData(postedData, "divide")
        if (status_code != 200):
            retJson = {
                    "Message": "An error happened",
                    "Status Code":status_code
            }
            return jsonify(retJson)

        x = postedData["x"]
        y = postedData["y"]
        x = int(x)
        y = int(y)

        ret = (x*1.0)/y
        retMap = {
                'Message': ret,
                'Status Code': 200
        }
        return jsonify(retMap)


class Multiply(Resource):
    def post(self):
        #Get posted data:
        postedData = request.get_json()

        #Verify validity of posted data
        status_code = checkPostedData(postedData, "multiply")
        if (status_code != 200):
            retJson = {
                    "Message": "An error happened",
                    "Status Code":status_code
            }
            return jsonify(retJson)

        x = postedData["x"]
        y = postedData["y"]
        x = int(x)
        y = int(y)

        ret = x*y
        retMap = {
                'Message': ret,
                'Status Code': 200
        }
        return jsonify(retMap)
