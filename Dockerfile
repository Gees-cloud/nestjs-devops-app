# Stage 1: Build the application
# Changed base image from node:18-alpine to node:18 (Debian-based)
# This image generally has better compatibility with native npm dependencies.
FROM node:18 AS builder

WORKDIR /app

COPY package*.json ./

# Clear npm cache to prevent potential issues
RUN npm cache clean --force

# Install dependencies
# Removed apk add as build tools are often pre-installed or easier to handle on Debian base.
RUN npm install

COPY . .

# Build the NestJS application
RUN npm run build

# Stage 2: Create the final production image
# Using node:18-slim for a smaller final image, while still being Debian-based.
FROM node:18-slim

WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

# Expose the port your NestJS app listens on (default is 3000)
EXPOSE 3000

# Command to run the NestJS application
CMD ["node", "dist/main"]
