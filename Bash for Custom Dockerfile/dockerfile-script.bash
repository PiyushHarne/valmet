#!/bin/bash

# Prompt the user for the base image name and tag
read -p "Enter the base image name (default: node): " base_image_name
base_image_name=${base_image_name:-node}

read -p "Enter the base image tag (default: lts-alpine): " base_image_tag
base_image_tag=${base_image_tag:-lts-alpine}

# Prompt the user for the application files directory
read -p "Enter the application files directory (default: /app): " app_directory
app_directory=${app_directory:-/app}

# Generate the Dockerfile
cat << EOF > Dockerfile
# Build stage
FROM $base_image_name:$base_image_tag AS build

# Set the working directory
WORKDIR $app_directory

# Copy the application files to the container
COPY . .

# Install dependencies
RUN npm install

# Build the application
RUN npm run build

# Production stage
FROM $base_image_name:$base_image_tag

# Set the working directory
WORKDIR $app_directory

# Copy the application files from the build stage
COPY --from=build $app_directory/dist .

# Start the application
CMD ["npm", "start"]
EOF

# Print the Dockerfile contents
echo "Dockerfile contents:"
cat Dockerfile
