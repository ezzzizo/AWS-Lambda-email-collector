
## Move your frontend files (index.html) to the EC2 web directory:

scp -i your-key.pem index.html ec2-user@your-ec2-public-ip:/var/www/html/





curl -X POST -k "https://x7oayp3e3h.execute-api.us-east-1.amazonaws.com/submit-email" \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com"}'
