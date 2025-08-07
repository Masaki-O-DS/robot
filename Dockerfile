FROM osrf/ros:humble-desktop

RUN apt-get update && apt-get install -y \
    ros-humble-moveit \
    python3-colcon-common-extensions python3-vcstool python3-rosdep \
    ros-humble-rosbag2 \
    xvfb ffmpeg x11-apps git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ws
RUN mkdir -p src

# ★COBOTTA 用スタック（後で置き換えるとき用＝今はビルドだけ）
RUN git clone -b humble https://github.com/DENSORobot/denso_robot_ros2.git src/denso_robot_ros2 || true \
 && vcs import src --skip-existing --input src/denso_robot_ros2/denso_robot_drivers_ros2.repos || true

RUN rosdep init || true && rosdep update \
 && rosdep install --from-paths src -y -r --rosdistro humble --ignore-src || true
RUN /bin/bash -lc "source /opt/ros/humble/setup.bash && colcon build"

COPY demo/ /ws/demo/
COPY run_demo.sh /run_demo.sh
RUN chmod +x /run_demo.sh

ENV DISPLAY=:99
ENTRYPOINT ["/run_demo.sh"]
