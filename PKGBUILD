# Maintainer: Blossom
pkgname=blossom-sound-theme
pkgver=1.0.0
pkgrel=2
pkgdesc="BlossomOS sound theme - minimalistic UI sounds adhering to the freedesktop naming standard"
arch=('any')
url="https://codeberg.org/BlossomOS/sound-theme"
license=('CC-BY-SA-4.0')
depends=()
makedepends=()
optdepends=('kde-plasma: For full integration with KDE Plasma'
            'gnome-shell: For full integration with GNOME'
            'gnome-tweaks: To enable theme in GNOME')
source=("https://codeberg.org/BlossomOS/sound-theme/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('3d356c3e3907af9762fc49b23cdb0b3cf6c63b7f13641b884ddcf73ce5d68f88')

package() {
  cd "${srcdir}/sound-theme"
  
  # Install sound theme to /usr/share/sounds/
  install -dm 755 "${pkgdir}/usr/share/sounds/blossom-sound-theme"
  
  # Copy the theme files
  cp -r stereo "${pkgdir}/usr/share/sounds/blossom-sound-theme/"
  cp index.theme "${pkgdir}/usr/share/sounds/blossom-sound-theme/"
  
  # Install license
  install -Dm 644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
  
  # Install documentation
  install -Dm 644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
}
