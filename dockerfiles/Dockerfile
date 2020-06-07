FROM phusion/baseimage:0.11

# If you're mounting local volumes for deveopment (or using docker-compose to do
# this), change 501 to be your id.
RUN groupadd --gid 1000 -o appuser
RUN adduser --uid 1000 --gid 1000 --disabled-password --gecos "" appuser
RUN mkdir /app
RUN chown -R appuser:appuser /app
WORKDIR /app

# apt update and install required packages
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get -y --no-install-recommends install software-properties-common \
    build-essential \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-virtualenv \
    libpq-dev \
    netcat \
    nginx \
    nodejs && \
    npm install -g yuglify sass

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up virtual environment
ENV VIRTUAL_ENV_DIR /.venv
RUN python3 -m virtualenv --python=python3 $VIRTUAL_ENV_DIR
# Set the virtual environment as the main Python directory
ENV PATH $VIRTUAL_ENV_DIR/bin:$PATH

# Upgrade pip and install pip-tools
RUN pip3 install --upgrade pip
RUN pip3 install pip-tools

# Copy and install requirements
COPY ./requirements.txt $PROJECT_DIR/requirements.txt
RUN [ -e $PROJECT_DIR/requirements.txt ] &&  pip-sync $PROJECT_DIR/requirements.txt

COPY . /app

# Production related setup
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./app_nginx.conf /etc/nginx/sites-available/app_nginx.conf

EXPOSE 8000
ENTRYPOINT ["/app/dockerfiles/entrypoint.sh"]
CMD ["/app/dockerfiles/run.sh"]
