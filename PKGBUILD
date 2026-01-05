# Maintainer: Your Name <your.email@example.com>
pkgname=blossom-sound-theme
pkgver=1.0.0
pkgrel=1
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
sha256sums=('SKIP')

package() {
  cd "${srcdir}/sound-theme"
  
  # Install sound theme to /usr/share/sounds/
  install -dm 755 "${pkgdir}/usr/share/sounds/modern-minimal-ui"
  
  # Copy the theme files
  cp -r stereo "${pkgdir}/usr/share/sounds/modern-minimal-ui/"
  cp index.theme "${pkgdir}/usr/share/sounds/modern-minimal-ui/"
  
  # Install license
  install -Dm 644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
  
  # Install documentation
  install -Dm 644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
}
