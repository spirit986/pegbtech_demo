FROM python:3.7-buster

COPY backend /usr/src/app/
WORKDIR /usr/src/app
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "backend.py"]

EXPOSE 5000

