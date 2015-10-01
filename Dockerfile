##########################################################################
# Dockerfile to build Dynomite container images with Redis as the backend
# Based on Ubuntu
##########################################################################
# Copyright 2014 Netflix, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##########################################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Ioannis Papapanagiotou - dynomite@netflix.com

# Update the repository sources list and Install package Build Essential
RUN apt-get update && apt-get install -y \
	autoconf \
	build-essential \
	dh-autoreconf \
	git \
	libssl-dev \
	libtool \
	python-software-properties \
	redis-server \
	tcl8.5

# Get Redis Running
RUN service redis-server start

# Clone the Dynomite Git
RUN git clone https://github.com/Netflix/dynomite.git
RUN echo 'Git repo has been cloned in your Docker VM'

# Move to working directory
WORKDIR dynomite/

# Autoreconf
RUN autoreconf -fvi \
	&& ./configure --enable-debug=log \
	&& CFLAGS="-ggdb3 -O0" ./configure --enable-debug=full \
	&& make \
	&& make install

##################### INSTALLATION ENDS #####################

# Expose the peer port
RUN echo 'Exposing peer port 8101'
EXPOSE 8101

# Expose the stat/admin port
RUN echo 'Exposing stat/admin port 22122'
EXPOSE 22122

# Default port to acccess Dynomite
RUN echo 'Exposing client port for Dynomite'
EXPOSE 8102

# Default port to execute the entrypoint (Dynomite)
CMD ["--port 8102"]

# Setting the dynomite as the dockerized entry-point application
RUN echo 'Starting Dynomite'
ENTRYPOINT ["src/dynomite", "--conf-file=conf/redis_single.yml", "-v11"]

CMD ["run"]


