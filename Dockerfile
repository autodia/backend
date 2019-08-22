FROM python:3

WORKDIR /usr/src/app

COPY . .

ARG dep

# avoid getting prompted for kerberos settings
ENV DEBIAN_FRONTEND noninteractive

# ODBC 17 driver installation repositories
RUN apt-get update && apt-get -y install apt-transport-https ca-certificates multiarch-support
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list -o /etc/apt/sources.list.d/mssql-release.list

# ODBC 17 driver dependency
RUN wget -O libssl1.0.0 http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb && dpkg -i libssl1.0.0

RUN apt-get update && ACCEPT_EULA=Y apt-get install -y \
    libsasl2-dev \
    python-dev \
    libldap2-dev \
    libssl-dev \
    vim \
    unixodbc-dev \
    msodbcsql17 \
    locales \
    mssql-tools \
    krb5-user

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

ENV PATH "$PATH:/opt/mssql-tools/bin"

# install dependencies
RUN pip install -r "$dep"

# make scripts executable
RUN chmod +x scripts/*

RUN chmod +x gunicorn_start
ENTRYPOINT [ "./gunicorn_start" ]

