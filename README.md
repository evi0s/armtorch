# armtorch

This repo aims to build an aarch64 pytorch image.

With the help of [multiarch/qemu-user-static](https://github.com/multiarch/qemu-user-static), we can build this image on a x86_64 host to cut down the cost of time in compiling code.

## Build

* **Python**: 3.7
* **PyTorch version**: 1.5.1
* **torchvision version**: 0.6.0
* **OpenCV version**: 3.4.10

**On a ARM64 host:**

```shell
docker build -t armtorch:tag .
```

**On a x86_64 host:**

```shell
docker run --rm --privileged \
    multiarch/qemu-user-static \
    --reset -p yes

# Require docker experimental flag enabled
docker build --platform=linux/aarch64 \
    -t armtorch:tag .
```


