FROM nginx:alpine

COPY index.html /usr/share/nginx/html/
COPY static/ /usr/share/nginx/html/static/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]