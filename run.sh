#!/bin/bash
env >> ~/.profile

# Allow for 12factor overrides of defaults in the generated config
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
