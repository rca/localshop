FROM python:2.7

MAINTAINER  Michael van Tellingen <michaelvantellingen@gmail.com>

# Install required packages
RUN apt-get update && \
  apt-get install -y libldap2-dev libsasl2-dev

# Create user / env
RUN useradd -r localshop -d /opt/localshop
RUN mkdir -p /opt/localshop/var && \
    chown -R localshop:localshop /opt/localshop/
RUN easy_install -U pip

WORKDIR /opt/localshop


ENV DJANGO_STATIC_ROOT /opt/localshop/static

# Install uWSGI / Honcho
run pip install psycopg2-binary==2.7.4
run pip install uwsgi==2.0.17
run pip install honcho==0.6.6

# change working directory
WORKDIR /opt/localshop/src/localshop

# Install requirements
COPY requirements.txt /opt/localshop/src/localshop
RUN pip install -r requirements.txt

# Install localshop
COPY ./ /opt/localshop/src/localshop
RUN pip install .

# Initialize the app
RUN DJANGO_SECRET_KEY=tmp localshop collectstatic --noinput

ARG VERSION
ENV VERSION=${VERSION}

EXPOSE 8000

CMD uwsgi --http 0.0.0.0:8000 --module localshop.wsgi --master --die-on-term
