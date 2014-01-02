# Riak
#
# VERSION       0.1.0

# Use the Ubuntu base image provided by dotCloud
FROM ubuntu:12.04
MAINTAINER Hector Castro hector@basho.com

# Update the APT cache
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update

# Install and setup project dependencies
RUN apt-get install -y curl lsb-release supervisor openssh-server

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

RUN locale-gen en_US en_US.UTF-8

RUN echo 'root:basho' | chpasswd

# Add Basho's APT repository
RUN curl http://apt.basho.com/gpg/basho.apt.key | apt-key add -
RUN echo "deb http://apt.basho.com precise main" > /etc/apt/sources.list.d/basho.list
RUN apt-get update
RUN apt-get -y -q install riak || true

# Configure Riak and prepare it to run
RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/app.config
RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/vm.args
# RUN echo "sed -i.bak \"s/127.0.0.1/\${RIAK_NODE_NAME}/\" /etc/riak/vm.args" > /etc/default/riak
RUN sed -i.bak 's/{storage_backend, riak_kv_bitcask_backend}/{storage_backend, riak_kv_eleveldb_backend}/' /etc/riak/app.config
# attemp to enable riak_search
RUN sed -i.bak -e 0,/"enabled, false"/{s/"enabled, false"/"enabled, true"/} /etc/riak/app.config
RUN echo "ulimit -n 4096" >> /etc/default/riak

# Hack for initctl
# See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

RUN chmod 1777 /tmp
RUN chmod 0666 /dev/null

ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose Protocol Buffers and HTTP interfaces
EXPOSE 8087 8098 22

CMD ["/usr/bin/supervisord"]
