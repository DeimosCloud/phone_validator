FROM node:16.3.0-alpine AS build

WORKDIR /validator-frontend
COPY . .

RUN apt-get npm install 
RUN npm run build

FROM nginx:1.23

COPY --from=build /validator-frontend/build  /usr/share/nginx/html


EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]