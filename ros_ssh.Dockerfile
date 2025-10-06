# docker build -t ros-ssh-ubuntu -f ros_ssh.Dockerfile
#
# docker run -d -p 22000:22000 --name ros-ssh-ubu ros-ssh-ubuntu
#                  ^^^^^^^^^^^ -> SSH Port
# TODO: Ros add Ros Port

# Use Ubuntu 22.04 as base
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update and install common tools + OpenSSH server
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    bash \
    curl \
    wget \
    vim \
    nano \
    git \
    htop \
    iputils-ping \
    net-tools \
    software-properties-common \
    unzip \
    zip \
    build-essential \
    python3 \
    python3-pip \
    lsb-release \
    gnupg \
    openssh-server \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install ROS 2 Humble (for Ubuntu 22.04)
# -----------------------------
# Add ROS 2 apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | tee /etc/apt/trusted.gpg.d/ros.asc > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/ros2-latest.list

# Install ROS 2 base
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    python3-argcomplete \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Source ROS setup in bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

# -----------------------------
# Configure SSH
# -----------------------------
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    sed -i 's/^#Port 22/Port 22000/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22000

# Set working directory
WORKDIR /workspace

# Default command: run SSH server
CMD ["/usr/sbin/sshd", "-D"]
