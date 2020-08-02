# pull official base image
FROM python:3.8.2-alpine AS build

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBUG 0

RUN apk update \
  # psycopg2 dependencies
  && apk add --virtual build-deps gcc python3-dev musl-dev \
  && apk add postgresql-dev \
  # Pillow dependencies
  && apk add jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev \
  # CFFI dependencies
  && apk add libffi-dev py-cffi \
  && apk add --no-cache \
    build-base \
    && pip install gevent==20.4.0 \
    && apk del build-base


RUN addgroup -S hybricam \
    && adduser -S -G hybricam hybricam

RUN pip install update pip
COPY ./requirements /requirements
RUN pip install --no-cache-dir -r /requirements/production.txt \
    && rm -rf /requirements

COPY ./utility/start.sh /start.sh
RUN sed -i 's/\r//' /start.sh
RUN chmod +x /start.sh

COPY . /app


RUN chown -R hybricam /app

USER hybricam

WORKDIR /app
RUN python manage.py collectstatic --noinput

CMD /start.sh

