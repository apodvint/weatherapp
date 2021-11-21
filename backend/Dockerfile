FROM node:latest

WORKDIR /usr/src/app
COPY backend/package.json backend/package-lock.json /usr/src/app/

RUN npm i

COPY backend/.  /usr/src/app

CMD npm start