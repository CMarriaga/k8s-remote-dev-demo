echo "Generating config.json"
cat <<EOF > /usr/share/nginx/html/config.json
{
  "API_URL": "${API_URL}"
}
EOF

nginx -g "daemon off;"