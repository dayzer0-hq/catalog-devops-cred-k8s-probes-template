FROM python:3.12-slim

COPY app/ /srv/app/
WORKDIR /srv

ENV WARMUP_SECONDS=5
EXPOSE 8080
CMD ["python3", "app/server.py"]
