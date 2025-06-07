# Use a minimal static file server
FROM nginx:alpine

# Copy static HTML and assets
COPY index.html /usr/share/nginx/html/
COPY static/ /usr/share/nginx/html/static/

# Expose port
EXPOSE 80

# Default command
CMD ["nginx", "-g", "daemon off;"]