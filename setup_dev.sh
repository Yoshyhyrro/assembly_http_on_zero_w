#!/bin/bash
# Development and cross-compilation setup for Raspberry Pi Zero W

echo "Setting up OCaml ARM cross-compilation environment..."

# Create ARM-specific opam switch
opam switch create ./cross-arm 4.14.0
eval 

# Install cross-compilation tools
echo "Installing ARM cross-compilation dependencies..."
opam install dune-configurator conf-libev

# Install lightweight versions of dependencies for Pi Zero
echo "Installing Pi Zero optimized packages..."
opam install lwt.5.6.1 angstrom.0.15.1 alcotest.1.7.0

# Setup cross-compilation environment
export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++
export AR=arm-linux-gnueabihf-ar
export STRIP=arm-linux-gnueabihf-strip

# Configure for ARMv6 (Pi Zero architecture)
export CFLAGS="-march=armv6 -mfpu=vfp -mfloat-abi=hard -O2 -fPIC"
export CXXFLAGS="-march=armv6 -mfpu=vfp -mfloat-abi=hard -O2 -fPIC"

echo "Creating cross-compilation configuration..."
cat > cross-compile.txt << EOF
# ARM Cross-compilation settings for Raspberry Pi Zero W
CC=arm-linux-gnueabihf-gcc
CXX=arm-linux-gnueabihf-g++
AR=arm-linux-gnueabihf-ar
STRIP=arm-linux-gnueabihf-strip
CFLAGS=-march=armv6 -mfpu=vfp -mfloat-abi=hard -O2
TARGET=arm-linux-gnueabihf
EOF

echo "Creating Pi Zero deployment script..."
cat > deploy_to_pi.sh << 'EOF'
#!/bin/bash
PI_HOST=
PI_USER=

# Set defaults if not provided
if [ -z "" ]; then
    PI_HOST="raspberrypi.local"
fi

if [ -z "" ]; then
    PI_USER="pi"
fi

echo "Building for ARM..."
eval 
CC=arm-linux-gnueabihf-gcc dune build --profile release

echo "Deploying to Pi Zero at ..."
scp _build/default/bin/main.exe @:~/http-router
ssh @ "chmod +x ~/http-router"

echo "Starting service on Pi..."
ssh @ "sudo systemctl stop http-router || true"
ssh @ "sudo cp ~/http-router /usr/local/bin/"
ssh @ "sudo systemctl start http-router"
EOF

chmod +x deploy_to_pi.sh

echo "Creating Pi Zero systemd service..."
cat > http-router.service << EOF
[Unit]
Description=OCaml HTTP Router with p-adic filtering
After=network.target

[Service]
Type=simple
User=pi
ExecStart=/usr/local/bin/http-router
Restart=always
RestartSec=3
Environment=OCAML_GC_STATS=1

# Pi Zero memory constraints
Environment=CAMLRUNPARAM=s=256k,i=32k,o=150

[Install]
WantedBy=multi-user.target
EOF

echo "Setup complete!"
echo "Usage:"
echo "1. Source environment: eval \"
echo "2. Cross-compile: CC=arm-linux-gnueabihf-gcc dune build"  
echo "3. Deploy: ./deploy_to_pi.sh [pi_hostname] [username]"
