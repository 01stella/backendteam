ARG VITE_VM_IP
ENV VITE_VM_IP=$VITE_VM_IP
# /station/Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of your React app
COPY . .

# Expose the port Vite uses by default
EXPOSE 5173

# Run the dev server and expose it to the network
CMD ["npm", "run", "dev", "--", "--host"]