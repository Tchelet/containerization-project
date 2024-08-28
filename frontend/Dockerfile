FROM python:3.8-slim

WORKDIR /app

COPY ../requirements.txt .

RUN pip install -r requirements.txt

COPY . /app/frontend

ENV FLASK_APP=frontend/app.py

CMD ["python", "frontend/app.py"]