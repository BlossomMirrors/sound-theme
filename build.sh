#!/bin/bash
set -e

PACKAGE_NAME=blossom-sound-theme
VERSION=1.0.0
RELEASE=3
BUILDROOT=$(pwd)/rpmbuild
SPECS_DIR=$BUILDROOT/SPECS
SOURCES_DIR=$BUILDROOT/SOURCES

rm -rf $BUILDROOT
mkdir -p $SPECS_DIR $SOURCES_DIR

# Create source tarball
tar -czf $SOURCES_DIR/$PACKAGE_NAME-$VERSION.tar.gz \
    --transform "s|^|$PACKAGE_NAME-$VERSION/|" \
    stereo/ index.theme LICENSE README.md

SPECFILE=$SPECS_DIR/$PACKAGE_NAME.spec

cat > $SPECFILE <<EOF
Name:           $PACKAGE_NAME
Version:        $VERSION
Release:        $RELEASE%{?dist}
Summary:        BlossomOS sound theme - minimalistic UI sounds adhering to the freedesktop naming standard
License:        CC-BY-SA-4.0
BuildArch:      noarch
URL:            https://codeberg.org/BlossomOS/sound-theme

Source0:        $PACKAGE_NAME-$VERSION.tar.gz

Suggests:       plasma-desktop
Suggests:       gnome-shell
Suggests:       gnome-tweaks

BuildRequires:  tar

%description
BlossomOS sound theme - minimalistic UI sounds adhering to the freedesktop
naming standard. Supports KDE Plasma and GNOME.

%prep
%setup -q

%build
# nothing to build

%install
install -dm 755 %{buildroot}/usr/share/sounds/$PACKAGE_NAME
cp -r stereo %{buildroot}/usr/share/sounds/$PACKAGE_NAME/
install -m 644 index.theme %{buildroot}/usr/share/sounds/$PACKAGE_NAME/
install -Dm 644 LICENSE %{buildroot}/usr/share/licenses/$PACKAGE_NAME/LICENSE
install -Dm 644 README.md %{buildroot}/usr/share/doc/$PACKAGE_NAME/README.md

%files
%dir /usr/share/sounds/$PACKAGE_NAME
/usr/share/sounds/$PACKAGE_NAME/stereo
/usr/share/sounds/$PACKAGE_NAME/index.theme
%license /usr/share/licenses/$PACKAGE_NAME/LICENSE
%doc /usr/share/doc/$PACKAGE_NAME/README.md

%changelog
* $(date +"%a %b %d %Y") Leonie Ain <me@koyu.space> - $VERSION-$RELEASE
- Initial release
EOF

rpmbuild -bb $SPECFILE \
    --define "_topdir $BUILDROOT" \
    --define "_sourcedir $SOURCES_DIR"

echo ""
echo "Build complete! RPM package is available at:"
echo "$BUILDROOT/RPMS/noarch/$PACKAGE_NAME-$VERSION-$RELEASE.*.noarch.rpm"
