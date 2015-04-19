#! /bin/sh
set -e

SH_DIR=$1
if [ -z "${SH_DIR}" ]; then
	echo "Usage: $0 /usr/src/bin/sh" >&2
	exit 1
fi
DESTDIR=external/sh
rm -rf "${DESTDIR}"
mkdir -p "${DESTDIR}"
DESTDIR_REAL="$(realpath "${DESTDIR}")"
ORIG_PWD="${PWD}"
cd "${SH_DIR}"
export MK_TESTS=no
make clean cleanobj
make depend
paths=$(make -V '${.PATH:N.*bltin*}'|xargs realpath)
for src in *.h $(make -V SRCS); do
	if [ -f "${src}" ]; then
		echo "${PWD}/${src}"
	else
		for p in ${paths}; do
			[ -f "${p}/${src}" ] && echo "${p}/${src}" && break
		done
	fi
done | sort -u | tar -c -T - --exclude bltin -s ",.*/,,g" -f - | tar -C "${DESTDIR_REAL}" -xf -
cp -R "${SH_DIR}/bltin" "${DESTDIR_REAL}/bltin"
cd "${ORIG_PWD}"
git add -A "${DESTDIR}"
echo "sh_SOURCES= \\"
find "${DESTDIR}" -name '*.c'|sed -e 's,$, \\,'
