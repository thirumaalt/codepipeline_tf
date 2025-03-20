# Use the official Nginx image
FROM nginx:alpine

# Copy your static website files into the Nginx webroot
COPY . /usr/share/nginx/html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
