FROM ubuntu:18.04

RUN apt update
RUN apt-get install -y python3-pip wget
RUN python3 -m pip install Flask psutil

RUN wget https://gist.githubusercontent.com/jameshwc/18011f20b0025dd7923ea26dcc19ad46/raw/b38434ccbef1dfc3fad4a661c627e537d47e1922/main.py 
CMD ["python3", "main.py"]
