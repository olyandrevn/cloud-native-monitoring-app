FROM python:3.9-buster

WORKDIR /app

COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# setups params for flask app
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8000

# only for documentation
EXPOSE 8000

CMD ["flask", "run"]