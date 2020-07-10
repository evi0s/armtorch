FROM python:3.7
MAINTAINER evi0s

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Update package manager & Install CMake
RUN sed -i 's/security.debian.org/mirrors.163.com/g' \
        /etc/apt/sources.list && \
    sed -i 's/deb.debian.org/mirrors.163.com/g' \
        /etc/apt/sources.list && \
    sed -i 's/http/https/g' /etc/apt/sources.list && \
    apt update && apt install cmake -y

# Python deps
RUN pip install numpy pyyaml cffi --verbose

# Fetch OpenCV source version 3.4.10
RUN cd /root && \
    wget https://github.com/opencv/opencv/archive/3.4.10.tar.gz && \
    tar zxvf 3.4.10.tar.gz

# Compile OpenCV
RUN cd /root/opencv-3.4.10 && mkdir build && cd build && \
    cmake -DWITH_OPENMP=ON -DCMAKE_BUILD_TYPE=RELEASE \
        -DBUILD_EXAMPLES=OFF -DBUILD_DOCS=OFF -DBUILD_PERF_TESTS=OFF \
        -DBUILD_TESTS=OFF -DWITH_CSTRIPES=ON -DWITH_OPENCL=ON \
        -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(grep processor /proc/cpuinfo | wc -l) && \
    make install

# Fetch pytorch version 1.5.1
RUN cd /root && \
    git clone --recursive --branch release/1.5 \
        https://github.com/pytorch/pytorch

# Compile pytorch
RUN cd /root/pytorch && \
    cd aten/src/ATen/native/quantized/cpu/qnnpack && \
    # Apply aarch64 patch
    sed -i '662,669s/4s/16b/g' src/q8gemm/8x8-dq-aarch64-neon.S && \
    cd && cd pytorch && \
    USE_CUDA=0 USE_CUDNN=0 BUILD_TEST=0 python setup.py install

# Compile torchvision
RUN cd /root && \
    git clone --recursive --branch release/0.6 \
        https://github.com/pytorch/vision && \
    cd vision && python setup.py install

CMD ["python3"]

