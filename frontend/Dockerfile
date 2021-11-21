FROM node:16

WORKDIR /usr/src/app
COPY frontend/package.json frontend/package-lock.json /usr/src/app/

RUN npm i

COPY frontend/.  /usr/src/app

EXPOSE 8000

CMD npm start