FROM java:8

RUN apt-get update ; apt-get install -y supervisor

ENV CMB_VERSION 2.2.42

RUN mkdir -p /app; curl https://s3-us-west-1.amazonaws.com/cmb-releases/${CMB_VERSION}/cmb-distribution-${CMB_VERSION}.tar.gz | tar xzf - -C /app --strip=1

ADD conf.d/ /etc/supervisor/conf.d/
ADD run.sh /run.sh
RUN chmod 755 /run.sh

EXPOSE 5555 6059 6061 7777 52525

CMD /run.sh
