#!/bin/bash

# Install ngrok for x86-64 Ubuntu
echo "Installing ngrok for x86-64 Ubuntu..."

# Download ngrok
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz

# Extract ngrok
tar xvzf ngrok-v3-stable-linux-amd64.tgz

# Make ngrok executable
chmod +x ngrok

# Move ngrok to /workspace
sudo mv ngrok /workspace/

# Clean up
rm ngrok-v3-stable-linux-amd64.tgz

# Configure ngrok token
if [ -z "$NGROK_TOKEN" ]; then
    echo "Please enter your ngrok authentication token:"
    read NGROK_TOKEN
fi
/workspace/ngrok config add-authtoken $NGROK_TOKEN

# Create systemd service
sudo bash -c 'cat > /etc/systemd/system/ngrok.service <<EOF
[Unit]
Description=ngrok
After=network.target

[Service]
ExecStart=/workspace/ngrok start --all
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF'

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable ngrok
sudo systemctl start ngrok

echo "ngrok installation and configuration complete!"
echo "Run 'systemctl status ngrok' to check service status"
echo "Run '/workspace/ngrok --version' to verify installation"
