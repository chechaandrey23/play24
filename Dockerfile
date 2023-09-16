FROM ubuntu:latest

###################
RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install nodejs
#RUN apt-get -y install npm

RUN mkdir -p /usr/src/app/server
RUN mkdir -p /usr/src/app/client

WORKDIR /usr/src/app

COPY .git .git
COPY .gitignore .gitignore
COPY .gitmodules .gitmodules

RUN git submodule update --init --recursive
###################

#FROM node:alpine

# Set the Enviournment to production
#ENV NODE_ENV=production
ENV NODE_ENV=development

#RUN npm install -g npm@10.1.0

WORKDIR /usr/src/app/client

COPY ./client/package*.json .

RUN npm install react-scripts -g

# Installs only the dependencies and skips devDependencies.
RUN npm install --force

# Copy all the files to the container.
COPY ./client/. .

# Create a "dist" folder with the production build.
#(Skip for Node.js Projects)
RUN npm run build

# Install Server

WORKDIR /usr/src/app/server

COPY ./server/package*.json .

# Install nestjs which is required for bulding the Nest.js project.
# (Skip for Node.js Projects)
RUN npm install -g @nestjs/cli

# Installs only the dependencies and skips devDependencies.
RUN npm install --omit=dev

# Copy all the files to the container.
COPY ./server/. .

# Create a "dist" folder with the production build.
#(Skip for Node.js Projects)
RUN npm run build

# Nest.js:
CMD [ "nodejs", "dist/main.js" ]
