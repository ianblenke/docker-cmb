FROM java:8

RUN apt-get update ; apt-get install -y supervisor

ENV CMB_VERSION 2.2.42

RUN wget -o /tmp/cmb.tar.gz https://s3-us-west-1.amazonaws.com/cmb-releases/${CMB_VERSION}/cmb-distribution-${CMB_VERSION}.tar.gz
ADD /tmp/cmb.tar.gz /app/

ADD conf.d/ /etc/supervisor/conf.d/
ADD run.sh /run.sh

EXPOSE 52525

CMD /run.sh
