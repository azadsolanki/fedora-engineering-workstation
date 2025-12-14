#!/bin/bash
#
# Verify Installation Script
# Checks that all tools are properly installed
#

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================="
echo "  Fedora Setup Verification"
echo "=================================="
echo ""

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1: $(command -v $1)"
        return 0
    else
        echo -e "${RED}✗${NC} $1: not found"
        return 1
    fi
}

check_version() {
    echo -e "${YELLOW}→${NC} $1: $($2 2>&1 | head -n 1)"
}

# Check commands
echo "Checking installed commands:"
echo ""

check_command git && check_version "Git" "git --version"
check_command podman && check_version "Podman" "podman --version"
check_command kubectl && check_version "kubectl" "kubectl version --client --short"
check_command kind && check_version "kind" "kind version"
check_command java && check_version "Java" "java -version"
check_command javac
check_command uv && check_version "UV" "uv --version"

echo ""
echo "Checking Python installations:"
uv python list 2>/dev/null || echo "No Python versions installed via UV"

echo ""
echo "Checking environment variables:"
echo "JAVA_HOME: ${JAVA_HOME:-NOT SET}"
echo "PATH includes .cargo: $(echo $PATH | grep -q .cargo && echo 'Yes' || echo 'No')"

echo ""
echo "Checking directory structure:"
[ -d ~/code/apps ] && echo -e "${GREEN}✓${NC} ~/code/apps" || echo -e "${RED}✗${NC} ~/code/apps missing"
[ -d ~/code/infra ] && echo -e "${GREEN}✓${NC} ~/code/infra" || echo -e "${RED}✗${NC} ~/code/infra missing"
[ -d ~/code/learning ] && echo -e "${GREEN}✓${NC} ~/code/learning" || echo -e "${RED}✗${NC} ~/code/learning missing"

echo ""
echo "Checking running services:"
systemctl is-active tlp &> /dev/null && echo -e "${GREEN}✓${NC} TLP active" || echo -e "${YELLOW}○${NC} TLP not active"
systemctl is-active power-profiles-daemon &> /dev/null && echo -e "${GREEN}✓${NC} Power profiles active" || echo -e "${YELLOW}○${NC} Power profiles not active"

echo ""
echo "Checking Podman containers:"
podman ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "No containers running"

echo ""
echo "=================================="
echo "  Verification Complete"
echo "=================================="
