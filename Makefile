robot-up:
	ansible-playbook -i inventory.ini ros2_laptop.yml
	ansible-playbook -i inventory.ini camera.yml
	ansible-playbook -i inventory.ini lidar.yml
	ansible-playbook -i inventory.ini install_tools.yml
	ansible-playbook -i inventory.ini setup_ros2.yml
	