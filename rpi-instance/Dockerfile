FROM debian:latest

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash \
    && apt-get install nodejs tmux openssh-client -yq \
    && apt-get clean -y

RUN curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.10.1-amd64.deb && dpkg -i metricbeat-7.10.1-amd64.deb
COPY ./metricbeat.yml /etc/metricbeat/metricbeat.yml 

ARG CLIENT_ID
ARG INSTALLATION_ID
ENV CLIENT_ID=$CLIENT_ID
ENV INSTALLATION_ID=$INSTALLATION_ID

RUN sed -i "s/{{ CLIENT_ID_VAR }}/"${CLIENT_ID}"/" /etc/metricbeat/metricbeat.yml
RUN sed -i "s/{{ INSTALLATION_ID_VAR }}/"${INSTALLATION_ID}"/" /etc/metricbeat/metricbeat.yml
RUN sed -i "s/{{ KIBANA_HOST_VAR }}/host.docker.internal\:5601/" /etc/metricbeat/metricbeat.yml
RUN sed -i "s/{{ LOGSTASH_HOST_VAR }}/host.docker.internal\:5045/" /etc/metricbeat/metricbeat.yml

WORKDIR /usr/app/node-local-server

COPY node-local-server/package.json node-local-server/index.* node-local-server/yarn.lock ./
COPY node-local-server/src ./src
RUN npm install

WORKDIR /usr/app

COPY ./start.sh .
CMD "./start.sh"