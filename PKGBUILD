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
source=(dmnet.sh)
noextract=()
md5sums=('c793db201ca52f4e5ee5d9b0f230f863')

build() {
  cd "$srcdir"
  cat "${source[0]}" >"${source[0]%.sh}"

  chmod a+x "${source[0]%.sh}"
}

package() {
  cd "$srcdir"
  install -d "$pkgdir/etc/rc.d"
  install dmnet "$pkgdir/etc/rc.d"
}
