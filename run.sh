#!/bin/bash
env >> ~/.profile

# Cassandra
if [ -n "${CASSANDRA_PORT_9160_TCP_ADDR}" ]; then
  cmb_cassandra_clusterUrl=${CASSANDRA_PORT_9160_TCP_ADDR}
fi

# Redis
if [ -n "${REDIS_PORT_6379_TCP_ADDR}" ]; then
  cmb_redis_serverList=${REDIS_PORT_6379_TCP_ADDR}:6379
fi

# CQS/CNS default overrides
cmb_cqs_server_port=${cmb_cqs_server_port:-6059}
cmb_cns_server_port=${cmb_cns_server_port:-6061}

# Allow HOST to specify a special place to bind() to
if [ -n "${HOST}" ]; then
  cmb_cqs_service_url=http://${HOST}:${cmb_cqs_server_port}/
  cmb_cns_service_url=http://${HOST}:${cmb_cns_server_port}/
fi

# Inherit standard variable names for AWS keys if available
if [ -n "${AWS_ACCESS_KEY_ID}" ]; then
  aws_access_key=${AWS_ACCESS_KEY_ID}
fi
if [ -n "${AWS_SECRET_ACCESS_KEY}" ]; then
  aws_secret_key=${AWS_SECRET_ACCESS_KEY}
fi

# Allow for 12factor overrides of defaults in the generated config

# Take a look at https://github.com/Comcast/cmb/blob/master/config/cmb.properties
# Rename the property key to use an underscore instead of a .
# If you pass a variable with this name, it will override the properties file.

grep -v -e '^#' /app/config/cmb.properties | sed -e '/^$/d' | while read line ; do
  IFS='=' read -a keyvalue <<< "$line"
  key=$(echo "${keyvalue[0]}" | sed -e 's/\./_/g')
  value="${keyvalue[1]}"
  eval override="\$$key"
  if [ -n "$override" ]; then
    value="$override"
  fi
  echo $(echo $key | sed -e 's/_/./g')=$value
done > /tmp/cmb.properties
mv -f /tmp/cmb.properties /app/config/cmb.properties

# Logging to stdout
cat <<EOF > /app/config/log4j.properties
log4j.rootLogger=${LOG_LEVEL:-INFO}, stdout

log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=com.comcast.cmb.common.util.CMBPatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{ISO8601} [%t] [%R] %-5p %c{1} - %m%n
EOF

/usr/bin/supervisord
