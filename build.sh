#!/bin/bash
set -e

PACKAGE_NAME=blossom-sound-theme
VERSION=1.0.0
RELEASE=4
BUILDROOT=$(pwd)/rpmbuild
SPECS_DIR=$BUILDROOT/SPECS
SOURCES_DIR=$BUILDROOT/SOURCES

rm -rf $BUILDROOT
mkdir -p $SPECS_DIR $SOURCES_DIR

# Create source tarball
tar -czf $SOURCES_DIR/$PACKAGE_NAME-$VERSION.tar.gz \
    --transform "s|^|$PACKAGE_NAME-$VERSION/|H" \
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

install -dm 755 %{buildroot}/etc/skel/.config/xsettingsd
install -dm 755 %{buildroot}/etc/skel/.config/gtk-3.0
printf '[Sounds]\nTheme=blossom-sound-theme\n' > %{buildroot}/etc/skel/.config/kdeglobals
printf 'Net/SoundThemeName "blossom-sound-theme"\n' > %{buildroot}/etc/skel/.config/xsettingsd/xsettingsd.conf
printf '[Settings]\ngtk-sound-theme-name=blossom-sound-theme\n' > %{buildroot}/etc/skel/.config/gtk-3.0/settings.ini

%post
set_ini_value() {
    local cfg="\$1" section="\$2" key="\$3" value="\$4"
    mkdir -p "\$(dirname "\$cfg")"
    if [ ! -f "\$cfg" ]; then
        printf '[%s]\n%s=%s\n' "\$section" "\$key" "\$value" > "\$cfg"
        return
    fi
    if grep -q "^\[\$section\]" "\$cfg"; then
        if ! grep -q "^\$key=" "\$cfg"; then
            sed -i "/^\[\$section\]/a \$key=\$value" "\$cfg"
        fi
    else
        printf '\n[%s]\n%s=%s\n' "\$section" "\$key" "\$value" >> "\$cfg"
    fi
}

set_xsettingsd_value() {
    local cfg="\$1" key="\$2" value="\$3"
    mkdir -p "\$(dirname "\$cfg")"
    if [ ! -f "\$cfg" ]; then
        printf '%s %s\n' "\$key" "\$value" > "\$cfg"
        return
    fi
    if ! grep -q "^\$key " "\$cfg"; then
        printf '%s %s\n' "\$key" "\$value" >> "\$cfg"
    fi
}

apply_sound_theme() {
    local home="\$1"
    set_ini_value "\$home/.config/kdeglobals" "Sounds" "Theme" "blossom-sound-theme"
    set_xsettingsd_value "\$home/.config/xsettingsd/xsettingsd.conf" "Net/SoundThemeName" '"blossom-sound-theme"'
    set_ini_value "\$home/.config/gtk-3.0/settings.ini" "Settings" "gtk-sound-theme-name" "blossom-sound-theme"
    if [ "\$home" != "/etc/skel" ] && [ -d "\$home" ]; then
        local owner="\$(stat -c '%u:%g' "\$home")"
        chown "\$owner" "\$home/.config/kdeglobals" "\$home/.config/xsettingsd/xsettingsd.conf" "\$home/.config/gtk-3.0/settings.ini" 2>/dev/null
    fi
}

apply_sound_theme /etc/skel
for home in /root /home/*; do
    [ -d "\$home" ] || continue
    apply_sound_theme "\$home"
done

%files
%dir /usr/share/sounds/$PACKAGE_NAME
/usr/share/sounds/$PACKAGE_NAME/stereo
/usr/share/sounds/$PACKAGE_NAME/index.theme
%license /usr/share/licenses/$PACKAGE_NAME/LICENSE
%doc /usr/share/doc/$PACKAGE_NAME/README.md
%dir /etc/skel/.config/xsettingsd
%dir /etc/skel/.config/gtk-3.0
%config(noreplace) /etc/skel/.config/kdeglobals
%config(noreplace) /etc/skel/.config/xsettingsd/xsettingsd.conf
%config(noreplace) /etc/skel/.config/gtk-3.0/settings.ini

%changelog
* $(date +"%a %b %d %Y") Leonie Ain <me@koyu.space> - $VERSION-$RELEASE
- Add /etc/skel defaults for KDE sound theme (kdeglobals, gtk-3.0/settings.ini, xsettingsd.conf)
EOF

rpmbuild -bb $SPECFILE \
    --define "_topdir $BUILDROOT" \
    --define "_sourcedir $SOURCES_DIR"

echo ""
echo "Build complete! RPM package is available at:"
echo "$BUILDROOT/RPMS/noarch/$PACKAGE_NAME-$VERSION-$RELEASE.*.noarch.rpm"
