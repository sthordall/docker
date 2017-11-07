FROM docker.elastic.co/logstash/logstash:5.6.3

COPY logstash.yml /usr/share/logstash/config/logstash.yml

RUN /usr/share/logstash/bin/logstash-plugin remove x-pack
