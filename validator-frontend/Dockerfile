# FROM node:alpine3.12
# WORKDIR /validator-frontend
# COPY package*.json ./
# RUN npm install
# RUN npm ci --omit=dev
# COPY . .
# RUN npm i serve -g
# CMD ["serve", "-s", "-l", "8081"]

FROM node:16.3.0-alpine AS build

WORKDIR /validator-frontend
COPY . .

RUN npm install 
RUN npm run build

FROM nginx:1.23

COPY --from=build /validator-frontend/build  /usr/share/nginx/html


EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]