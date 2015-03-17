# Hawk OpenResty (nginx) Dockerfile
# 2015-01-13

# Pull base image
FROM ubuntu:14.04

# Main developer
MAINTAINER Dave Pederson <dave.pederson@gmail.com>

# Download and install OpenResty (nginx)
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install build-essential libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make wget -y --force-yes --no-install-recommends
WORKDIR /tmp/
RUN wget http://openresty.org/download/ngx_openresty-1.7.7.1.tar.gz
RUN tar -xzvf ngx_openresty-1.7.7.1.tar.gz
WORKDIR /tmp/ngx_openresty-1.7.7.1
RUN ./configure --with-luajit --with-pcre-jit
RUN make
RUN make install

# Set PATH
ENV PATH /usr/local/openresty/nginx/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install the hawk module
ADD lib /usr/local/openresty/lualib/hawk

# Install service config
ADD ./conf/service.lua /usr/local/openresty/packages/service.lua
ADD ./conf/config.lua /usr/local/openresty/packages/config.lua
ADD ./conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD boot.sh /opt/boot.sh
RUN chmod +x /opt/boot.sh

# Expose port 80 of the container
EXPOSE 80

# Run nginx
CMD /opt/boot.sh
