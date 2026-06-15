#!/bin/bash
set -e

PACKAGE_NAME=blossom-sound-theme
VERSION=1.0.0
RELEASE=5
BUILDROOT=$(pwd)/rpmbuild
SPECS_DIR=$BUILDROOT/SPECS

SRCDIR=$(pwd)

rm -rf $BUILDROOT
mkdir -p $SPECS_DIR

SPECFILE=$SPECS_DIR/$PACKAGE_NAME.spec

cat > $SPECFILE <<EOF
Name:           $PACKAGE_NAME
Version:        $VERSION
Release:        $RELEASE%{?dist}
Summary:        BlossomOS sound theme - minimalistic UI sounds adhering to the freedesktop naming standard
License:        CC-BY-SA-4.0
BuildArch:      noarch
URL:            https://codeberg.org/BlossomOS/sound-theme

%description
BlossomOS sound theme - minimalistic UI sounds adhering to the freedesktop
naming standard. Supports KDE Plasma and GNOME.

%prep

%build

%install
install -dm 755 %{buildroot}/usr/share/sounds/$PACKAGE_NAME
cp -r %{srcdir}/stereo %{buildroot}/usr/share/sounds/$PACKAGE_NAME/
install -m 644 %{srcdir}/index.theme %{buildroot}/usr/share/sounds/$PACKAGE_NAME/

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
    if [ -d "\$home" ]; then
        local owner="\$(stat -c '%u:%g' "\$home")"
        chown "\$owner" "\$home/.config/kdeglobals" "\$home/.config/xsettingsd/xsettingsd.conf" "\$home/.config/gtk-3.0/settings.ini" 2>/dev/null
    fi
}

for home in /etc/skel /root /home/*; do
    [ -d "\$home" ] || continue
    apply_sound_theme "\$home"
done

%files
%dir /usr/share/sounds/$PACKAGE_NAME
/usr/share/sounds/$PACKAGE_NAME/stereo
/usr/share/sounds/$PACKAGE_NAME/index.theme

%changelog
* $(date +"%a %b %d %Y") Leonie Ain <me@koyu.space> - $VERSION-$RELEASE
- Simplify package to only install sound files
EOF

rpmbuild -bb $SPECFILE \
    --define "_topdir $BUILDROOT" \
    --define "srcdir $SRCDIR"

echo ""
echo "Build complete! RPM package is available at:"
echo "$BUILDROOT/RPMS/noarch/$PACKAGE_NAME-$VERSION-$RELEASE.*.noarch.rpm"
