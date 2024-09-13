FROM python:3.9.20-slim
WORKDIR /app
COPY ./hello_world.py /app
RUN pip install Flask
EXPOSE 8080
CMD ["python", "hello_world.py"]