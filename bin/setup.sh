#!/bin/bash

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Setup host and target for development and testing."
	echo ""
	echo "Supported options:"
	echo "-h, --help                Show this help text"
        echo "-k, --kernel              Setup/Reset kernel sources"
        echo "-o, --host                Installs some system tools, the toolchain and kernel sources"
        echo "-p, --repatch             Repatch kernel sources."

}

configure() {
        . config/configure.sh
}

# https://develop.phytec.com/phycore-imx8x/latest/software-development/application-development/install-the-sdk
install_system_tools() {
        echo "Setup system tools."
        sudo apt update
        sudo apt install -y gawk wget git-core diffstat
        sudo apt install -y unzip texinfo gcc-multilib 
        sudo apt install -y build-essential chrpath socat cpio 
        sudo apt install -y python python3 python3-pip python3-pexpect 
        sudo apt install -y xz-utils libsdl1.2-dev curl vim libyaml-dev 
        # sudo apt install -y repo
}

setup_toolchain() {
        echo "Setup tool chain."
        if [[ ! -d /opt/fsl-imx-xwayland/5.4-zeus/ ]]; then
                mkdir -p $BUILD_DIR
                cd $BUILD_DIR
                wget https://artifactory.phytec.com/artifactory/imx8x-images-released-public/BSP-Yocto-FSL-i.MX8X-PD21.1.0/fsl-imx-xwayland-glibc-x86_64-imx-image-multimedia-aarch64-imx8x-phycore-kit-toolchain-5.4-zeus.sh
                sudo chmod a+x fsl-imx-xwayland-glibc-x86_64-imx-image-multimedia-aarch64-imx8x-phycore-kit-toolchain-5.4-zeus.sh
                ./fsl-imx-xwayland-glibc-x86_64-imx-image-multimedia-aarch64-imx8x-phycore-kit-toolchain-5.4-zeus.sh
        fi
}

# https://github.com/phytec/meta-phytec/blob/hardknott/dynamic-layers/fsl-bsp-release/recipes-kernel/linux/linux-imx_5.10.72_2.2.0-phy17.bb
setup_kernel() {
        echo "Setup kernel sources."
        mkdir -p $BUILD_DIR
        cd $BUILD_DIR
        rm -Rf $KERNEL_SOURCE
        git clone -b v5.10.72_2.2.0-phy https://github.com/phytec/linux-phytec-imx.git $KERNEL_SOURCE
        cd $KERNEL_SOURCE
        git checkout v5.10.72_2.2.0-phy17 # Same as 452fa7e700fe953808d1c7a781fec6829f554333
}

repatch_kernel() {
        echo "Repatch kernel ..."
        cd $KERNEL_SOURCE
        git am --abort
        git reset --hard v5.10.72_2.2.0-phy17

        git config gc.auto 0
        for patchfile in $PATCH_DIR/*.patch; do
                git am -3 --whitespace=fix --ignore-whitespace < ${patchfile}
        done
        git config gc.auto 1
}

while [ $# != 0 ] ; do
	option="$1"
	shift

	case "${option}" in
	-h|--help)
		usage
		exit 0
		;;
	-k|--kernel)
		configure
		setup_kernel
                exit 0
		;;
	-o|--host)
		configure
                install_system_tools
                setup_toolchain
		setup_kernel
                exit 0
		;;
        -p|--repatch)
                configure
                repatch_kernel
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