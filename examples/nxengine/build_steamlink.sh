#!/bin/bash
#

TOP=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
if [ "${MARVELL_SDK_PATH}" = "" ]; then
	MARVELL_SDK_PATH="$(cd "${TOP}/../.." && pwd)"
fi
if [ "${MARVELL_ROOTFS}" = "" ]; then
	source "${MARVELL_SDK_PATH}/setenv.sh" || exit 1
fi
BUILD="${PWD}"
SRC="${BUILD}/nxengine-evo"

#
# Download the source
#
if [ ! -d "${SRC}" ]; then
	git clone https://github.com/nxengine/nxengine-evo "${SRC}"
	(cd "${SRC}")
	rm -f "${BUILD}/.patch-applied"
fi

#
# Apply any patches
#
if [ "${TOP}/cavestory.patch" -nt "${BUILD}/.patch-applied" ]; then
	pushd "${SRC}"
	git checkout -- .
	patch -p1 <"${TOP}/cavestory.patch" || exit 1
	popd
	touch "${BUILD}/.patch-applied"
fi

#
# Build it
#
pushd "${SRC}"
if [ -d build ]; then
	rm -rf build
fi
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../../../../toolchain/steamlink-toolchain.cmake ..
make || exit 1
popd

#
# Get the data file
#
if [ ! -f cavestoryen.zip ]; then
	wget http://www.cavestory.org/downloads/cavestoryen.zip
fi

export APPSDIR="${BUILD}/steamlink/apps"
export DESTDIR="${APPSDIR}/CaveStory"

# Copy the files to the app directory
mkdir -p "${APPSDIR}"
(cd "${APPSDIR}"; rm -rf CaveStory; unzip ${BUILD}/cavestoryen.zip)
cp -rv "${SRC}/bin/." "${DESTDIR}/" || exit 1
cp -rv "${SRC}/data/." "${DESTDIR}/data/" || exit 1
if [ -d ${BUILD}/music ]; then
	if [ -d ${BUILD}/music/new ]; then
		cp -rv "${BUILD}/music/new/." "${DESTDIR}/data/Ogg/" || exit 1
	fi
	if [ -d ${BUILD}/music/remastered ]; then
		cp -rv "${BUILD}/music/remastered" "${DESTDIR}/data/Ogg11" || exit 1
	fi
fi
cp -v "${BUILD}/run_cavestory" "${DESTDIR}/" || exit 1

# Create the table of contents and icon
cat >"${DESTDIR}/toc.txt" <<__EOF__
name=CaveStory
icon=icon.png
run=run_cavestory
__EOF__

base64 -d >"${DESTDIR}/icon.png" <<__EOF__
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
__EOF__

#
# Pack it up
#
name=$(basename ${DESTDIR})
pushd "$(dirname ${DESTDIR})"
tar zcvf $name.tgz $name || exit 3
rm -rf $name
popd

#
# All done!
#
echo "Build complete!"
echo
echo "Put the steamlink folder onto a USB drive, insert it into your Steam Link, and cycle the power to install."
