# Stage 1: Build the application
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
# Install a more comprehensive set of build tools required for npm packages with native dependencies.
# This includes git, make, g++, gcc, libc-dev, python3, linux-headers, and libtool.
RUN apk add --no-cache git make g++ gcc python3 libc-dev linux-headers libtool

# Install dependencies
RUN npm install

COPY . .

# Build the NestJS application
RUN npm run build

# Stage 2: Create the final production image
FROM node:18-alpine

WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

# Expose the port your NestJS app listens on (default is 3000)
EXPOSE 3000

# Command to run the NestJS application
CMD ["node", "dist/main"]
