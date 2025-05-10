FROM alpine:edge as base

WORKDIR /root/mingwcrtdll

RUN apk update \
	&& apk upgrade \
	&& apk add --no-cache pacman pacman-makepkg fakeroot make gcc g++ texinfo mpc mpc1-dev curl mpfr-dev gmp-dev file xz zlib-dev patch gcc-gnat \
	&& sed -i -e 's/EUID == 0/EUID == 100000/g' /usr/bin/makepkg

COPY . .

RUN makepkg -si --noconfirm -D mingw-binutils \
	&& makepkg -si --noconfirm -D mingw-winpthreads-dummy-headers \
	&& makepkg -si --noconfirm -D mingw-headers-bootstrap \
	&& makepkg -si --noconfirm -D mingw-gcc-bootstrap \
	&& yes | makepkg -si -D mingw-crt-with-headers-bootstrap \
	&& yes | makepkg -si -D mingw-gcc \
	&& yes | makepkg -si -D mingw-headers-crt-final

RUN apk del pacman pacman-makepkg fakeroot gcc g++ texinfo mpc mpc1-dev curl mpfr-dev gmp-dev file xz zlib-dev patch gcc-gnat

FROM alpine:edge
RUN apk update && apk upgrade && apk add --no-cache make mpc1 mpfr gmp
COPY --from=base /usr /usr
RUN ln -sf /usr/bin/i386-mingw32crt-c++ /usr/bin/c++ \
	&& ln -sf /usr/bin/i386-mingw32crt-cc /usr/bin/cc \
	&& ln -sf /usr/bin/i386-mingw32crt-cpp /usr/bin/cpp \
	&& ln -sf /usr/bin/i386-mingw32crt-ar /usr/bin/ar \
	&& ln -sf /usr/bin/i386-mingw32crt-nm /usr/bin/nm \
	&& ln -sf /usr/bin/i386-mingw32crt-objcopy /usr/bin/objcopy \
	&& ln -sf /usr/bin/i386-mingw32crt-objdump /usr/bin/objdump \
	&& ln -sf /usr/bin/i386-mingw32crt-as /usr/bin/as \
	&& ln -sf /usr/bin/i386-mingw32crt-size /usr/bin/size \
	&& ln -sf /usr/bin/i386-mingw32crt-ld /usr/bin/ld \
	&& ln -sf /usr/bin/i386-mingw32crt-addr2line /usr/bin/addr2line \
	&& ln -sf /usr/bin/i386-mingw32crt-ranlib /usr/bin/ranlib \
	&& ln -sf /usr/bin/i386-mingw32crt-strip /usr/bin/strip \
	&& ln -sf /usr/bin/i386-mingw32crt-g++ /usr/bin/g++ \
	&& ln -sf /usr/bin/i386-mingw32crt-strings /usr/bin/strings