# Stage 1: Build the application
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
# Install build tools required for some npm packages (e.g., those with native dependencies)
RUN apk add --no-cache build-base python3

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
