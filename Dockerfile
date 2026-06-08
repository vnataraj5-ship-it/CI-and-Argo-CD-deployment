FROM python:3.11

WORKDIR /app

COPY . .

RUN pip install flask

EXPOSE 8085

CMD ["python", "app.py"]
