FROM node:20-alpine

RUN apk add --no-cache python3 make g++ 

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

RUN npm run build

EXPOSE 3000

# Force preview to use port 3000 and bind to all interfaces
CMD ["npm", "run", "preview", "--", "--port", "3000", "--host", "0.0.0.0"]

