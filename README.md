# Vision Components MIPI CSI-2 driver for Phytec i.MX8M Plus
![VC MIPI camera](https://www.vision-components.com/fileadmin/external/documentation/hardware/VC_MIPI_Camera_Module/VC_MIPI_Camera_Module-Dateien/mipi_sensor_front_back.png)

## Version 0.1.0
* Supported boards
* Supported cameras 
* Linux kernel 
* Features
* Known Issues

## Prerequisites for cross-compiling
### Host PC
* Recommended OS is Ubuntu 18.04 LTS
* You need git to clone this repository
* All other packages are installed by the scripts contained in this repository

# Installation
When we use the **$** sign it is meant that the command is executed on the host PC. A **#** sign indicates the promt from the target so the execution on the target. In our case the Ixora Apalis board.

1. Create a directory and clone the repository   
   ```
     $ cd <working_dir>
     $ git clone https://github.com/pmliquify/vc_mipi_phytec
   ```

2. Setup the toolchain and the kernel sources. The script will additionaly install some necessary packages like *build-essential* or *device-tree-compiler*.
   ```
     $ cd vc_mipi_phytec/bin
     $ ./setup.sh --host
   ```

3. Build the kernel image, kernel modules and device tree files.
   ```
     $ ./build.sh --all
   ```