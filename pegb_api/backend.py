from flask import Flask, jsonify, request
from flask_restful import Api, Resource


backend = Flask(__name__)
api = Api(backend)

def checkPostedData(postedData, functionName):
    if (functionName == "add" or functionName == "subtract" or functionName == "multiply"):
        if "x" not in postedData or "y" not in postedData:
            return 301
        
        else:
            return 200
    
    elif (functionName == "divide"):
        if "x" not in postedData or "y" not in postedData:
            return 301

        elif int(postedData["y"]) == 0:
            return 302

        else:
            return 200

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


api.add_resource(Add, "/add")
api.add_resource(AddMany, "/addmany")
api.add_resource(Subtract, "/subtract")
api.add_resource(Multiply, "/multiply")
api.add_resource(Divide, "/divide")


@backend.route('/')
def hello_backend():
    return "Hello there! This message means the backend is working."


@backend.route('/users')
def users():
    users = {
            'users':[{
                    'fname':'Clark',
                    'lname':'Kent',
                    'age':'47',
                    'sex': 'male',
                    'phone':'112233'
                },
                {
                    'fname':'Barry',
                    'lname':'Allen',
                    'age':'32',
                    'sex': 'male',
                    'phone':'234656'
                },
                {
                    'fname':'Oliver',
                    'lname':'Queen',
                    'age':'33',
                    'sex': 'male',
                    'phone':'23567867'
                },
                {
                    'fname':'Sara',
                    'lname':'Lance',
                    'age':'32',
                    'sex': 'female',
                    'phone':'234790'
                },
                {
                    'fname':'Bruce',
                    'lname':'Waine',
                    'age':'45',
                    'sex': 'male',
                    'phone':'3454576'
                }]
    }
    return jsonify(users)


@backend.route('/posts')
def posts():
    posts = {
            'posts':[
                {
                    'title':'Lorem Ipsum',
                    'date_created':'2015-03-01',
                    'date_updated':'2015-02-05',
                    'author':'Bruce Waine',
                    'body':'Spicy jalapeno bacon ipsum dolor amet ipsum ham reprehenderit pastrami in tenderloin ball tip, t-bone nostrud. Ut in brisket cupidatat ex venison swine bacon ad hamburger, t-bone corned beef short ribs. Pork chop ball tip venison ipsum magna commodo ground round nulla. Aute sed pork belly esse.'
                },
                {
                    'title':'Bacon Ipsum',
                    'date_created':'2015-06-06',
                    'date_updated':'2015-07-14',
                    'author':'Admin',
                    'body':'Aliquip nostrud meatloaf brisket aute, qui filet mignon anim eiusmod ullamco ribeye ball tip sirloin swine. Id et ball tip, qui dolor brisket ea. Shoulder cupim sirloin corned beef excepteur, spare ribs bacon short loin magna deserunt tail ut mollit ground round. Meatball dolor velit, in alcatra leberkas beef ham hock tenderloin pancetta biltong bacon fatback porchetta shankle. Burgdoggen fatback swine aliqua.'
                },
                {
                    'title':'Buffalo tail',
                    'date_created':'2015-06-20',
                    'date_updated':'2017-04-14',
                    'author':'Clark Kent',
                    'body':'Prosciutto dolore jowl kevin. Pig sint pork cow esse sunt dolore cupidatat minim ipsum anim ad pariatur. Doner ball tip eiusmod, minim shoulder voluptate landjaeger sint ad. Ipsum porchetta ut kielbasa, shank esse minim frankfurter dolor cupidatat. Ribeye ground round filet mignon sausage minim anim reprehenderit. Commodo enim short ribs, reprehenderit laboris fatback jowl pork id deserunt shank spare ribs nulla sausage aute.'
                },
                {
                    'title':'Laboris reprehenderit',
                    'date_created':'2015-09-17',
                    'date_updated':'2017-07-09',
                    'author':'Barry Alen',
                    'body':'Buffalo tail cupidatat rump pastrami filet mignon. Lorem sirloin beef ut minim leberkas ut do shankle tail shoulder pig. Non reprehenderit chuck ham beef ut nulla sed lorem in ipsum beef ribs porchetta voluptate magna. Veniam pariatur velit ea, landjaeger quis ad. Porchetta boudin sirloin jerky incididunt venison, brisket enim pastrami dolore t-bone sed.'
                },
                {
                    'title':'Occaecat mollit',
                    'date_created':'2017-12-11',
                    'date_updated':'2017-10-23',
                    'author':'Sara Lance',
                    'body':'Laboris reprehenderit duis venison drumstick tenderloin landjaeger tail nostrud. Landjaeger andouille meatball ea biltong chuck esse picanha tail. Irure minim pork loin drumstick in fugiat. Cow commodo shank esse pancetta. Qui incididunt est buffalo, cupidatat short loin rump nostrud sed labore sausage anim ut. Jerky deserunt eiusmod pancetta id aliquip tongue salami officia pork chop ad consectetur meatball exercitation. Occaecat mollit aute non nostrud tongue shoulder in, sint flank in eiusmod brisket pork chop nisi.'
                },
    ]}
    return jsonify(posts)




if __name__ == "__main__":
    backend.run(debug=True, host='0.0.0.0')


