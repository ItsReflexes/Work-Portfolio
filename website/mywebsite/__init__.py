from flask import Flask
import json
import os
from mywebsite.config import Config
basedir = os.path.abspath(os.path.dirname(__file__))
data = json.load(open(os.path.join(basedir, 'data.json')))


def create_app(config_class=Config):
    """Sets up the application ans returns a flask application instance"""
    app = Flask(__name__)
    app.config.from_object(Config)
    from mywebsite.project.routes import app2
    app.register_blueprint(app2)
    return(app)
