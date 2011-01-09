# This is an example PKGBUILD file. Use this as a start to creating your own,
# and remove these comments. For more information, see 'man PKGBUILD'.
# NOTE: Please fill out the license field for your package! If it is unknown,
# then please put 'unknown'.

# Maintainer: Dominik Burgdörfer <dominik.burgdoerfer@googlemail.com>
pkgname=dmnet
pkgver=0.1.1
pkgrel=1
pkgdesc="Starts netcfg profiles based on the network in the environment."
arch=(any)
url=""
license=('GPL')
groups=()
depends=('netcfg>=2.0.0' 'bash' 'awk')
optdepends=()
source=(https://github.com/domachine/dmnet/tarball/master)
noextract=()
md5sums=('6901f544c0d730fd1044780074bf73c7')

build() {
  cd "$srcdir"

  cd domachine-dmnet-*
  cat "dmnet.sh" >"dmnet"

  chmod a+x "dmnet"
}

package() {
  cd "$srcdir"/domachine-dmnet-*
  install -d "$pkgdir/etc/rc.d"
  install dmnet "$pkgdir/etc/rc.d"
}
