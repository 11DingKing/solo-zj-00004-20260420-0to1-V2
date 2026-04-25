FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm config set registry https://registry.npmmirror.com && npm install

COPY . .

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
