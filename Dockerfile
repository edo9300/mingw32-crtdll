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
RUN apk update && apk upgrade && apk add --no-cache make
COPY --from=base /usr /usr