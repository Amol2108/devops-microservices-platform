FROM python:3.14-slim

WORKDIR /app

COPY app.py .

RUN pip install flask requests

EXPOSE 3000

CMD ["python", "app.py"]