FROM debian:latest

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash \
    && apt-get install nodejs -yq \
    && apt-get clean -y

WORKDIR /usr/app

COPY package.json index.js ./
COPY src ./src
RUN npm install
COPY ./start.sh .

EXPOSE $PORT
CMD "./start.sh"