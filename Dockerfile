FROM ubuntu:latest
RUN apt-get -y update
RUN apt-get -y install git

RUN mkdir -p /usr/src/app/server
RUN mkdir -p /usr/src/app/client

WORKDIR /usr/src/app

COPY . .
COPY .git .git
COPY .gitignore .gitignore
COPY .gitmodules .gitmodules

RUN git submodule update --init --recursive

FROM node:alpine

# Set the Enviournment to production
#ENV NODE_ENV=production
ENV NODE_ENV=development

RUN npm install -g npm@10.1.0

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
CMD [ "node", "dist/main.js" ]
