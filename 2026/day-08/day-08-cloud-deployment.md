
## DAY 08 — Cloud Server Setup (Nginx)

### What it is:
Deploy Nginx web server on AWS EC2 and access it from the browser.

### Key Commands:
```bash
# Connect to server
ssh -i key.pem ec2-user@<public-ip>

# Install & start Nginx
sudo yum install nginx -y       # Amazon Linux
sudo apt install nginx -y       # Ubuntu
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Save logs to file
sudo cat /var/log/nginx/access.log > nginx-logs.txt

# Download file from server to local
scp -i key.pem ec2-user@<ip>:~/nginx-logs.txt .
```

### Remember:
- Open port 80 in AWS Security Group to access from browser
- Nginx default page = http://your-public-ip
- Logs are at /var/log/nginx/

---
