FROM node:latest as base

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY package.json /usr/src/app/

FROM base as test
RUN npm install
COPY . /usr/src/app/

FROM base as prod
RUN npm install --production
COPY . /usr/src/app/
EXPOSE 3000
ENTRYPOINT npm start