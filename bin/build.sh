#!/bin/bash

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Build kernel image, modules, device tree, u-boot script and test tools."
	echo ""
	echo "Supported options:"
        echo "-a, --all                 Build kernel image, modules and device tree"
        echo "-d, --dt                  Build device tree"
        echo "-h, --help                Show this help text"
        echo "-k, --kernel              Build kernel image"
        echo "-m, --modules             Build kernel modules"
}

configure() {
        . config/configure.sh
        . /opt/fsl-imx-xwayland/5.4-zeus/environment-setup-aarch64-poky-linux
}

patch_kernel() {
        echo "Copying driver sources into kernel sources ..."
        cp -Ruv $SRC_DIR/* $KERNEL_SOURCE
}

configure_kernel() {
        cd $KERNEL_SOURCE
        make imx_v8_defconfig imx8_phytec_distro.config imx8_phytec_platform.config imx8_vc_mipi.config
}

build_kernel() {
        echo "Build kernel ..."
        cd $KERNEL_SOURCE
        make -j$(nproc) Image.gz
}

build_modules() {
        echo "Build kernel modules ..."
        cd $KERNEL_SOURCE
        make -j$(nproc) modules 
}

create_modules() {
        rm -Rf $MODULES_DIR
        mkdir -p $MODULES_DIR
        export INSTALL_MOD_PATH=$MODULES_DIR
        make modules_install
        cd $MODULES_DIR
        echo Create module archive ...
        rm -f $BUILD_DIR/modules.tar.gz 
        tar -czf ../modules.tar.gz .
        rm -Rf $MODULES_DIR    
}

build_device_tree() {
        echo "Build device tree ..."
        cd $KERNEL_SOURCE
        # make -j$(nproc) freescale/imx8mp-phyboard-pollux-rdk.dtb
        make -j$(nproc) dtbs
}

while [ $# != 0 ] ; do
	option="$1"
	shift

	case "${option}" in
	-a|--all)
		configure
                patch_kernel
                configure_kernel
                build_kernel
                build_modules	
                create_modules
                build_device_tree
                exit 0
		;;
        -d|--dt)
		configure
                patch_kernel
                configure_kernel
                build_device_tree
                exit 0
		;;
	-h|--help)
		usage
		exit 0
		;;
	-k|--kernel)
		configure
                patch_kernel
                configure_kernel
		build_kernel
                exit 0
		;;
        -m|--modules)
		configure
                patch_kernel
                configure_kernel
                build_modules
                create_modules
                exit 0
		;;
	*)
		echo "Unknown option ${option}"
		exit 1
		;;
	esac
done

usage
exit 1