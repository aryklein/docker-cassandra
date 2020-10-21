FROM busybox
ENV PROMETHEUS_JMX_AGENT_VERSION 0.13.0
RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${PROMETHEUS_JMX_AGENT_VERSION}/jmx_prometheus_javaagent-${PROMETHEUS_JMX_AGENT_VERSION}.jar \
    && wget https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/cassandra.yml

FROM cassandra:3.11.8
ENV PROMETHEUS_JMX_AGENT_VERSION 0.13.0
ENV PROMETHEUS_JMX_AGENT_PORT 7070
COPY --from=0 /jmx_prometheus_javaagent-${PROMETHEUS_JMX_AGENT_VERSION}.jar /opt
COPY --from=0 /cassandra.yml /opt
RUN echo "JVM_OPTS=\"\$JVM_OPTS -javaagent:/opt/jmx_prometheus_javaagent-${PROMETHEUS_JMX_AGENT_VERSION}.jar=${PROMETHEUS_JMX_AGENT_PORT}:/opt/cassandra.yml\"" >> /etc/cassandra/cassandra-env.sh
RUN echo "authenticator: PasswordAuthenticator" >> /etc/cassandra/cassandra.yaml

# Add support for extra env variables to setup cassandra.yml
## BATCH_SIZE_WARN_THRESHOLD_IN_KB
RUN sed -i '/for yaml in \\/a\\t\tbatch_size_warn_threshold_in_kb \\' /usr/local/bin/docker-entrypoint.sh

EXPOSE 7000 7001 ${PROMETHEUS_JMX_AGENT_PORT} 7199 9042 9160
