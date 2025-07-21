FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnucobol \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy source files
COPY . .

# Build COBOL program
RUN cobc -x -o payroll payroll.cob

# Expose port
EXPOSE 3000

# Start the server
CMD ["npm", "start"]