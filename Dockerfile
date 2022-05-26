FROM ubuntu:jammy AS ccls

# C++
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt install -y curl build-essential cmake zlib1g-dev libncurses-dev clang-14 libclang-14-dev git
RUN git clone --depth=1 --recursive https://github.com/MaskRay/ccls
RUN cd ccls && \
    cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/usr/lib/llvm-14 \
    -DLLVM_INCLUDE_DIR=/usr/lib/llvm-14/include \
    -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-14 && \
    cmake --build Release && \
    cp Release/ccls /usr/local/bin

FROM ubuntu:jammy
ARG DEBIAN_FRONTEND=noninteractive

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV TERM=xterm-256color

ARG USERNAME=ryo
ARG GROUPNAME=ryo
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /usr/bin/zsh -u $UID -g $GID $USERNAME

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl gnupg ca-certificates && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb http://ppa.launchpad.net/jonathonf/vim-daily/ubuntu jammy main" | tee /etc/apt/sources.list.d/vim-daily.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv 4ab0f789cba31744cc7da76a8cf63ad3f06fc659 && \
    echo 'deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x jammy main' > /etc/apt/sources.list.d/nodesource.list && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null && \
    apt-get update && apt-get install -y \
    make \
    cmake \
    g++ \
    git \
    python3-pip \
    ros-humble-ros-base \
    ros-humble-ros-testing \
    python3-colcon-common-extensions \
    python3-rosdep \
    vim-nox nodejs clang-14 clang-tidy-14 clang-tools-14 ripgrep fzf zsh && \
    rosdep init && \
    rosdep update && \
    pip install --upgrade pip && \
    hash -r && \
    pip install pipenv && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ccls /usr/local/bin/ccls /usr/local/bin

USER $USERNAME

RUN mkdir /home/$USERNAME/.config && \
    ln -s dotfiles/vim/.vim /home/$USERNAME && \
    ln -s dotfiles/vim/.vimrc /home/$USERNAME && \
    ln -s dotfiles/zsh/.zsh /home/$USERNAME && \
    ln -s dotfiles/zsh/.zshenv /home/$USERNAME

WORKDIR /home/$USERNAME/

RUN echo "source /opt/ros/humble/setup.zsh" >> ~/.zshrc.local