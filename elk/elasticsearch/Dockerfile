FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.3

ENV http.host 0.0.0.0
ENV transport.host 127.0.0.1

RUN bin/elasticsearch-plugin remove x-pack
