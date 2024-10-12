# Dockerfile

# Stage 1: Build the Next.js front-end
FROM node:18-alpine AS frontend

WORKDIR /app

# Copy project files to the container
COPY package.json package-lock.json ./
RUN npm install

COPY tailwind.config.js ./
COPY postcss.config.js ./
COPY ./src ./src
COPY next.config.js ./
COPY tsconfig.json ./

# Run linting separately before building
RUN npm run lint --fix || echo "Linting errors ignored"

# Build the front-end
RUN npm run build

# Stage 2: Setup back-end and serve front-end with Express
FROM node:18-alpine

WORKDIR /app

# Copy project files and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy server files
COPY ./server ./server

# Copy built front-end from previous stage
COPY --from=frontend /app/.next ./.next
COPY --from=frontend /app/public ./public

# Copy .env file
COPY .env .env

# Expose port 4000 for the server
EXPOSE 4000

# Start the app
CMD ["npm", "start"]
