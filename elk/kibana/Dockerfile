FROM docker.elastic.co/kibana/kibana:5.6.3

COPY kibana.yml /usr/share/kibana/config/kibana.yml

RUN bin/kibana-plugin remove x-pack
