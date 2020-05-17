FROM python:3.8.2-alpine3.11

# Install Dependencies
RUN apk --no-cache add openssl curl ca-certificates

# Install Nginx
RUN printf "%s%s%s\n" \
    "http://nginx.org/packages/alpine/v" \
    `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
    "/main" \
    | tee -a /etc/apk/repositories && \
    curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub && \
    openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout && \
    mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ && \
    apk --no-cache add nginx

# Change Working Directory
WORKDIR /home/www-data

# Copy Source Code
COPY . .

# Install Application Dependencies, Gunicorn & Supervisor
RUN pip install --no-cache-dir -r requirements.txt 

# Setup Configs
RUN mv nginx.conf /etc/nginx/nginx.conf && \
    mv gunicorn.conf.py /etc/gunicorn.conf.py && \
    mv supervisord.conf /etc/supervisord.conf && \
    mv start-container /usr/local/bin/start-container && \
    chmod +x /usr/local/bin/start-container

# Add User
RUN adduser -D -H -u 1000 -s /bin/bash www-data -G www-data && \
    chown -R www-data:www-data /home/www-data

# Expose Port
EXPOSE 8080

# Switch User
USER www-data

ENTRYPOINT [ "start-container" ]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080
