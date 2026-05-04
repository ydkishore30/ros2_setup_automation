# ROS2 Setup Automation

Automated setup and configuration for ROS2 on Raspberry Pi with support for LIDAR, camera, and development tools using Ansible playbooks.

## Project Overview

This project provides a collection of Ansible playbooks to automate the installation and configuration of ROS2 (Humble distribution) on Raspberry Pi and Ubuntu systems. It includes specialized setup for LIDAR sensors, cameras, and development dependencies.

## Project Structure

```
.
├── README.md                    # This file
├── Makefile                     # Convenient commands for running playbooks
├── inventory.ini.example        # Template for inventory configuration
├── setup_ros2.yml              # Base ROS2 setup for Raspberry Pi
├── install_tools.yml           # Basic system tools installation
├── camera.yml                  # Camera system setup and ROS2 camera packages
├── lidar.yml                   # YDLIDAR SDK and ROS2 driver setup
└── ros2_local.yml              # ROS2 setup for local development (laptop)
```

## Playbooks

### 1. **setup_ros2.yml** - ROS2 Base Setup (Raspberry Pi)
Installs and configures ROS2 Humble on Raspberry Pi:
- Updates system and apt packages
- Adds ROS2 official repository
- Installs ROS2 base, build tools, and colcon
- Initializes rosdep
- Creates ROS2 workspace
- Clones and builds sample ROS packages

**Target Host:** `raspberrypi`

### 2. **camera.yml** - Camera System Setup
Configures camera support on Raspberry Pi:
- Installs system camera dependencies (libcamera, gstreamer, ffmpeg)
- Installs ROS2 camera packages (v4l2-camera, image-transport, cv-bridge)
- Configures camera permissions and device access

**Target Host:** `raspberrypi`

### 3. **lidar.yml** - LIDAR Driver Setup
Sets up YDLIDAR X2L sensor integration:
- Installs system dependencies for LIDAR
- Clones and builds YDLIDAR SDK
- Installs YDLIDAR ROS2 driver
- Configures environment variables
- Adds user to dialout group for USB access

**Target Host:** `raspberrypi`

### 4. **install_tools.yml** - System Tools
Installs basic development and system tools:
- Git, curl, vim
- Network tools (net-tools, htop, network-manager)
- SSH server

**Target Host:** `raspberrypi`

### 5. **ros2_local.yml** - Laptop Setup (Ubuntu 22.04)
Installs ROS2 on local Ubuntu development machine:
- Adds ROS2 Humble repository
- Installs ROS2 Desktop with visualization tools (RViz2, Gazebo)
- Sets up development environment
- Initializes rosdep

**Target Host:** `localhost`

## Prerequisites

### On Control Machine
- Ansible 2.9 or higher
- SSH access to Raspberry Pi

### On Raspberry Pi
- Raspberry Pi OS (Debian-based)
- SSH enabled
- Network connectivity

### On Ubuntu (for laptop setup)
- Ubuntu 22.04 LTS
- Sudo privileges

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/ydkishore30/ros2_setup_automation.git
cd ros2_setup_automation
```

### 2. Configure Inventory
Copy the example inventory and update with your Raspberry Pi details:
```bash
cp inventory.ini.example inventory.ini
```

Edit `inventory.ini`:
```ini
[raspberrypi]
pi ansible_host=raspberrypi.local ansible_user=<your_username>
```

### 3. Install Ansible
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install ansible

# macOS
brew install ansible
```

## Usage

### Using Makefile (Recommended)
```bash
# Run all playbooks (complete setup)
make robot-up

# Run individual playbooks
ansible-playbook -i inventory.ini setup_ros2.yml
ansible-playbook -i inventory.ini camera.yml
ansible-playbook -i inventory.ini lidar.yml
ansible-playbook -i inventory.ini install_tools.yml
ansible-playbook -i inventory.ini ros2_local.yml
```

### Direct Ansible Commands
```bash
# Setup ROS2 on Raspberry Pi
ansible-playbook -i inventory.ini setup_ros2.yml

# Setup camera support
ansible-playbook -i inventory.ini camera.yml -K

# Setup LIDAR driver
ansible-playbook -i inventory.ini lidar.yml

# Setup on local laptop (Ubuntu)
ansible-playbook -i inventory.ini ros2_local.yml -K
```

### With Sudo Password Prompt
```bash
# Add -K flag to prompt for sudo password
ansible-playbook -i inventory.ini setup_ros2.yml -K
```

## Configuration

### Default Paths (customizable via playbook variables)
- ROS2 Workspace: `$HOME/ros2_ws` (configurable via `ws_path`)
- YDLIDAR SDK: `$HOME/ydlidar_sdk` (configurable via `sdk_path`)
- ROS Distro: `humble`
- Default User: Configure in `inventory.ini` and playbook `vars` section

### Environment Variables
After setup, the following will be configured in `~/.bashrc`:
- `source /opt/ros/humble/setup.bash` - ROS2 environment
- `source $HOME/ros2_ws/install/setup.bash` - Workspace setup (adjust path as needed)
- `export ROS_DOMAIN_ID=0` - ROS2 domain ID
- `export CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH` - CMake path (LIDAR)

## Verification

### Verify ROS2 Installation
```bash
# On Raspberry Pi or Ubuntu
source /opt/ros/humble/setup.bash
ros2 --version
```

### Test Camera
```bash
# List video devices
v4l2-ctl --list-devices

# List camera permissions
groups $USER
```

### Test LIDAR
```bash
# Check USB devices
lsusb

# Verify LIDAR connectivity
ls -la /dev/ttyUSB*
```

## Troubleshooting

### SSH Connection Issues
```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa <your_username>@raspberrypi.local

# Enable SSH on Raspberry Pi if needed
sudo systemctl start ssh
sudo systemctl enable ssh
```

### Ansible Connection Fails
```bash
# Ensure inventory is correct
ansible-inventory -i inventory.ini --list

# Test connectivity
ansible all -i inventory.ini -m ping
```

### Permission Denied on USB Devices
```bash
# Ensure user is in dialout group
groups <your_username>

# Add if needed
sudo usermod -aG dialout <your_username>
```

### rosdep Issues
```bash
# Reinitialize rosdep
sudo rosdep init
rosdep update
```

## Project Variables

Key variables used across playbooks:
- `ros_user`: System user (automatically set from `inventory.ini` via `{{ ansible_user }}`)
- `ws_path`: ROS2 workspace path (default: `/home/{{ ros_user }}/ros2_ws`, customize in playbook `vars`)
- `sdk_path`: YDLIDAR SDK path (default: `/home/{{ ros_user }}/ydlidar_sdk`, customize in playbook `vars`)
- `ros_distro`: ROS distribution (default: `humble`)

## Security Notes

- `inventory.ini` is not tracked in git (added to `.gitignore`)
- Use `inventory.ini.example` as a template
- SSH keys should be configured for passwordless authentication
- Use `-K` flag only when necessary to prompt for sudo password

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Contributed by the ROS2 Setup Automation community

## References

- [ROS2 Humble Documentation](https://docs.ros.org/en/humble/)
- [Ansible Documentation](https://docs.ansible.com/)
- [YDLIDAR GitHub](https://github.com/YDLIDAR/)
- [Raspberry Pi OS](https://www.raspberrypi.org/software/)

## Support

For issues and questions:
- Check the Troubleshooting section above
- Review playbook logs: `ansible-playbook -i inventory.ini setup_ros2.yml -vv`
- Create an issue on GitHub

---

**Last Updated:** May 4, 2026
