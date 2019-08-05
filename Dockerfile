FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt
RUN mkdir ~/.aws


COPY unused.py .

CMD [ "python", "./unused.py", "--exporter"]