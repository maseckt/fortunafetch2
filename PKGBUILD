
# Maintainer: Your Name <you@example.com>
pkgname=fortunafetch2
pkgver=2.1
pkgrel=3
pkgdesc="THE BEST FETCH IN THE WORLD OF ALL EXISTING. 100% FASTER THAN FASTFETCH AND NEOFETCH. PROVEN BY SCIENTISTS.( The following project is a meme and was made for fun dont take it seriously )"
arch=('any')
url="https://github.com/maseckt/fortunafetch2"
license=('GPL 3.0')
depends=('xorg-xrandr' 'lsb-release' 'pciutils' 'inetutils' 'procps-ng')  # нужные зависимости
source=("fortunafetch2.sh")
md5sums=('SKIP')

package() {
  install -Dm755 "$srcdir/fortunafetch2.sh" "$pkgdir/usr/bin/fortunafetch2"
}
