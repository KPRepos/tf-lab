# our base image
FROM --platform=amd64 alpine:3.5

# Install python and pip
RUN apk add --update py2-pip

# upgrade pip
RUN pip install --upgrade pip

# install Python modules needed by the Python app
RUN pip install -U Flask pymongo jsonify bson

# copy files required for the app to run
COPY app.py /usr/src/app/
COPY templates /usr/src/app/templates/

# tell the port number the container should expose
EXPOSE 5555

# run the application
CMD ["python", "/usr/src/app/app.py"]
