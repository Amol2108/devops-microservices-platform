FROM python:3.14-slim

WORKDIR /app

COPY app.py /app/

RUN pip install flask

EXPOSE 5000

CMD ["python", "app.py"]