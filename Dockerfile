FROM ubuntu:20.04

# Install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3-vcstools \
    curl \
	wget \
    gnupg \
	gnupg2 \
	lsb-release \
	ca-certificates \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list' \
    && apt-get update && apt-get install -y --no-install-recommends \
        git \
        cmake \
        build-essential \
        ros-noetic-ros-base \
        ros-noetic-rosbash \
        ros-noetic-diagnostic-aggregator \
        ros-noetic-diagnostic-analysis \
        ros-noetic-diagnostic-common-diagnostics \
        ros-noetic-diagnostic-msgs \
        ros-noetic-diagnostic-updater \
        python3 \
        python3-dev \
        python3-pip \
        python3-catkin-pkg \
        python3-catkin-tools \
        python3-catkin-pkg \
        python3-rosdep \
        python3-rosdistro \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-rospkg \
        python3-vcstools \
        python3-wstool \
        ros-noetic-catkin \
        libboost-dev \
        libboost-thread-dev \
        libboost-program-options-dev \
        libboost-filesystem-dev \
        libboost-regex-dev \
        libboost-chrono-dev \
        libconsole-bridge-dev \
        liblog4cxx-dev \
        libtinyxml2-dev \
        libpocofoundation62 \
    && mkdir -p ~/catkin_ws/src/ \
    && cd ~/catkin_ws/src/ \
    && git clone -b noetic-devel https://github.com/UbiquityRobotics/raspicam_node \
    && mkdir -p /etc/ros/rosdep/sources.list.d/ \
    && echo "yaml https://raw.githubusercontent.com/UbiquityRobotics/rosdep/master/raspberry-pi.yaml" > /etc/ros/rosdep/sources.list.d/30-ubiquity.list \
    && apt update && apt-get install -y $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances libraspberrypi-bin libraspberrypi-dev | grep "^\w" | sort -u) \
    && pip3 install -U netifaces defusedxml empy \
    && rosdep init && rosdep update \
    && . /opt/ros/noetic/setup.sh \
    && cd /root/catkin_ws/src/ \
    && catkin_init_workspace \
    && cd /root/catkin_ws  \
    && wstool init src \
    && rosinstall_generator camera_calibration_parsers  --rosdistro noetic --wet-only --tar > camera_calibration_parsers.rosinstall \
    && rosinstall_generator image_transport --rosdistro noetic --wet-only --tar > image_transport.rosinstall \
    && rosinstall_generator cv_bridge --rosdistro noetic --wet-only --tar > cv_bridge.rosinstall \
    && rosinstall_generator compressed_image_transport --rosdistro noetic --wet-only --tar > compressed_image_transport.rosinstall \
    && rosinstall_generator camera_info_manager --rosdistro noetic --wet-only  --tar > camera_info_manager.rosinstall \ 
    && rosinstall_generator dynamic_reconfigure --rosdistro noetic --wet-only --tar > dynamic_reconfigure.rosinstall \
    && rosinstall_generator diagnostics --rosdistro noetic --wet-only --tar > diagnostics.rosinstall \
    && wstool merge -t src camera_calibration_parsers.rosinstall \
    && wstool merge -t src cv_bridge.rosinstall \
    && wstool merge -t src image_transport.rosinstall \
    && wstool merge -t src compressed_image_transport.rosinstall \
    && wstool merge -t src camera_info_manager.rosinstall \
    && wstool merge -t src dynamic_reconfigure.rosinstall \
    && wstool merge -t src diagnostics.rosinstall \
    && wstool update -t src \
    && . /opt/ros/noetic/setup.sh \
    && cd /root/catkin_ws \
    && rosdep install --from-paths src --ignore-src --rosdistro=noetic -y --os=ubuntu:focal  \
    && catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release \
    && export SUDO_FORCE_REMOVE=yes \
    && apt purge --auto-remove -y \ 
        git \
        cmake \
        build-essential \
        python3-pip \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-vcstools \
        python3-wstool \
       # ros-noetic-catkin \
        #libboost-dev \
        #libboost-thread-dev \
        #libboost-program-options-dev \
        #libboost-filesystem-dev \
        #libboost-regex-dev \
        #libboost-chrono-dev \
        #libconsole-bridge-dev \
    && apt autoremove 

CMD ldconfig && \
    . /opt/ros/noetic/setup.sh && \
    . /root/catkin_ws/devel/setup.sh && \
    roslaunch raspicam_node camerav2_1280x960.launch
