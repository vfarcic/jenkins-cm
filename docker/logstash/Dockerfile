FROM logstash

RUN logstash-plugin install logstash-input-github

COPY logstash.conf /logstash.conf

EXPOSE 5678

CMD ["-f", "/logstash.conf"]