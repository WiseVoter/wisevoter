FROM node:20

COPY ./site/ /mount/site/
WORKDIR /mount/app/
COPY ./edit-app/package.json ./
RUN npm install
COPY ./edit-app/ ./

EXPOSE 3000

CMD ["npm", "start"]
