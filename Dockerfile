# Multi-stage build for login page
FROM node:24-alpine AS builder

WORKDIR /app

# Copy files
COPY index.html app.js ./
COPY i18n/ ./i18n/

# Optimize HTML (remove whitespace if needed)
# For now, just copy as-is

# Production stage with nginx
FROM nginx:1.29-alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static files
COPY --from=builder /app /usr/share/nginx/html

# Set permissions for existing nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Switch to non-root user
USER nginx

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
