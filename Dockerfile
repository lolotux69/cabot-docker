# Cabot Dockerfile
#
# https://github.com/shoonoise/cabot-docker
#
# VERSION 1.1

FROM debian:bullseye

MAINTAINER lolotux


# Prepare
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && echo "deb http://debian.ens-cachan.fr/ftp/debian/ bullseye main contrib non-free" > /etc/apt/sources.list \
&& apt-get update && apt-get install -y python3-pip python3-dev gunicorn nodejs npm curl libpq-dev libldap2-dev libsasl2-dev

RUN pip3 install --upgrade pip && pip install setuptools --upgrade
RUN pip3 install gitsome
RUN pip3 uninstall celery
RUN pip3 install celery==4.4.2
    
# Deploy cabot
ADD ./ /opt/cabot/

# Install dependencies
RUN export PYTHONPATH=/usr/bin/python
RUN pip install -e /opt/cabot/
RUN npm install --no-color -g coffee-script less@1.3 --registry http://registry.npmjs.org/


# Set env var
ENV PATH $PATH:/opt/cabot/
ENV PYTHONPATH $PYTHONPATH:/opt/cabot/

# Cabot settings
ENV DJANGO_SETTINGS_MODULE cabot.settings
ENV HIPCHAT_URL https://api.hipchat.com/v1/rooms/message
ENV LOG_FILE /dev/stdout
ENV PORT 5000
ENV ADMIN_EMAIL admin@example.com
ENV CABOT_FROM_EMAIL noreply@example.com
ENV DEBUG t
ENV DB_HOST db
ENV DB_PORT 5432
ENV DB_USER docker
ENV DB_PASS docker
ENV TERM xterm

ENV DJANGO_SECRET_KEY 2FL6ORhHwr5eX34pP9mMugnIOd3jzVuT45f7w430Mt5PnEwbcJgma0q8zUXNZ68A

# Used for pointing links back in alerts etc.
ENV WWW_HTTP_HOST localhost
ENV WWW_SCHEME http

RUN unlink /usr/bin/node
RUN ["ln","-s","/usr/bin/nodejs","/usr/bin/node"]

EXPOSE 5000

WORKDIR /opt/cabot/
CMD . /opt/cabot/provision/run.sh
