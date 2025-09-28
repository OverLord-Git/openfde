#!/bin/bash

set -euo pipefail

# === Lista principal de paquetes (los que diste originalmente) ===
MAIN_PACKAGES=(
  alsa-topology-conf alsa-ucm-conf alsa-utils anacron apg apport-gtk appstream
  apt-config-icons apt-config-icons-hidpi aptdaemon aptdaemon-data apturl
  apturl-common aspell aspell-en at-spi2-core avahi-autoipd avahi-daemon
  avahi-utils baobab bluez bluez-cups bluez-obexd branding-ubuntu bridge-utils
  brltty bubblewrap build-essential bzip2 cheese cheese-common colord colord-data
  cpp cpp-11 cracklib-runtime cups cups-browsed cups-bsd cups-client cups-common
  cups-core-drivers cups-daemon cups-filters cups-filters-core-drivers
  cups-ipp-utils cups-pk-helper cups-ppdc cups-server-common dc dconf-cli
  dconf-gsettings-backend dconf-service ddcutil deja-dup desktop-file-utils
  dictionaries-common dmz-cursor-theme dns-root-data dnsmasq-base docbook-xml
  dpkg-dev duplicity emacsen-common enchant-2 eog espeak-ng-data evince
  evince-common evolution-data-server evolution-data-server-common fakeroot
  file-roller firefox fontconfig fontconfig-config fonts-beng fonts-beng-extra
  fonts-dejavu-core fonts-deva fonts-deva-extra fonts-droid-fallback
  fonts-freefont-ttf fonts-gargi fonts-gubbi fonts-gujr fonts-gujr-extra
  fonts-guru fonts-guru-extra fonts-indic fonts-kacst fonts-kacst-one fonts-kalapi
  fonts-khmeros-core fonts-knda fonts-lao fonts-liberation fonts-liberation2
  fonts-lklug-sinhala fonts-lohit-beng-assamese fonts-lohit-beng-bengali
  fonts-lohit-deva fonts-lohit-gujr fonts-lohit-guru fonts-lohit-knda
  fonts-lohit-mlym fonts-lohit-orya fonts-lohit-taml fonts-lohit-taml-classical
  fonts-lohit-telu fonts-mlym fonts-nakula fonts-navilu fonts-noto-cjk
  fonts-noto-color-emoji fonts-noto-mono fonts-opensymbol fonts-orya
  fonts-orya-extra fonts-pagul fonts-sahadeva fonts-samyak-deva fonts-samyak-gujr
  fonts-samyak-mlym fonts-samyak-taml fonts-sarai fonts-sil-abyssinica
  fonts-sil-padauk fonts-smc fonts-smc-anjalioldlipi fonts-smc-chilanka
  fonts-smc-dyuthi fonts-smc-gayathri fonts-smc-karumbi fonts-smc-keraleeyam
  fonts-smc-manjari fonts-smc-meera fonts-smc-rachana fonts-smc-raghumalayalamsans
  fonts-smc-suruma fonts-smc-uroob fonts-taml fonts-telu fonts-telu-extra
  fonts-teluguvijayam fonts-thai-tlwg fonts-tibetan-machine fonts-tlwg-garuda
  fonts-tlwg-garuda-ttf fonts-tlwg-kinnari fonts-tlwg-kinnari-ttf
  fonts-tlwg-laksaman fonts-tlwg-laksaman-ttf fonts-tlwg-loma fonts-tlwg-loma-ttf
  fonts-tlwg-mono fonts-tlwg-mono-ttf fonts-tlwg-norasi fonts-tlwg-norasi-ttf
  fonts-tlwg-purisa fonts-tlwg-purisa-ttf fonts-tlwg-sawasdee
  fonts-tlwg-sawasdee-ttf fonts-tlwg-typewriter fonts-tlwg-typewriter-ttf
  fonts-tlwg-typist fonts-tlwg-typist-ttf fonts-tlwg-typo fonts-tlwg-typo-ttf
  fonts-tlwg-umpush fonts-tlwg-umpush-ttf fonts-tlwg-waree fonts-tlwg-waree-ttf
  fonts-ubuntu fonts-urw-base35 fonts-yrsa-rasa foomatic-db-compressed-ppds
  fprintd g++ g++-11 gamemode gamemode-daemon gcc gcc-11 gcc-11-base gcr gdb gdm3
  gedit gedit-common genisoimage geoclue-2.0 ghostscript ghostscript-x
  gir1.2-accountsservice-1.0 gir1.2-adw-1 gir1.2-atk-1.0 gir1.2-atspi-2.0
  gir1.2-dbusmenu-glib-0.4 gir1.2-dee-1.0 gir1.2-freedesktop gir1.2-gck-1
  gir1.2-gcr-3 gir1.2-gdesktopenums-3.0 gir1.2-gdkpixbuf-2.0 gir1.2-gdm-1.0
  gir1.2-geoclue-2.0 gir1.2-gmenu-3.0 gir1.2-gnomebluetooth-3.0
  gir1.2-gnomedesktop-3.0 gir1.2-goa-1.0 gir1.2-graphene-1.0
  gir1.2-gst-plugins-base-1.0 gir1.2-gstreamer-1.0 gir1.2-gtk-3.0 gir1.2-gtk-4.0
  gir1.2-gtksource-4 gir1.2-gudev-1.0 gir1.2-gweather-3.0 gir1.2-handy-1
  gir1.2-harfbuzz-0.0 gir1.2-ibus-1.0 gir1.2-javascriptcoregtk-4.0 gir1.2-json-1.0
  gir1.2-mutter-10 gir1.2-nm-1.0 gir1.2-nma-1.0 gir1.2-notify-0.7 gir1.2-pango-1.0
  gir1.2-peas-1.0 gir1.2-polkit-1.0 gir1.2-rb-3.0 gir1.2-rsvg-2.0 gir1.2-secret-1
  gir1.2-snapd-1 gir1.2-soup-2.4 gir1.2-totem-1.0 gir1.2-totemplparser-1.0
  gir1.2-udisks-2.0 gir1.2-unity-7.0 gir1.2-upowerglib-1.0 gir1.2-vte-2.91
  gir1.2-webkit2-4.0 gir1.2-wnck-3.0 gjs gkbd-capplet glib-networking
  glib-networking-common glib-networking-services gnome-accessibility-themes
  gnome-bluetooth gnome-bluetooth-3-common gnome-bluetooth-common gnome-calculator
  gnome-calendar gnome-characters gnome-control-center gnome-control-center-data
  gnome-control-center-faces gnome-desktop3-data gnome-disk-utility
  gnome-font-viewer gnome-initial-setup gnome-keyring gnome-keyring-pkcs11
  gnome-logs gnome-mahjongg gnome-menus gnome-mines gnome-online-accounts
  gnome-power-manager gnome-remote-desktop gnome-session-bin
  gnome-session-canberra gnome-session-common gnome-settings-daemon
  gnome-settings-daemon-common gnome-shell gnome-shell-common
  gnome-shell-extension-appindicator gnome-shell-extension-desktop-icons-ng
  gnome-shell-extension-ubuntu-dock gnome-startup-applications gnome-sudoku
  gnome-system-monitor gnome-terminal gnome-terminal-data gnome-themes-extra
  gnome-themes-extra-data gnome-todo gnome-todo-common gnome-user-docs
  gnome-video-effects grilo-plugins-0.3-base gsettings-desktop-schemas
  gsettings-ubuntu-schemas gstreamer1.0-alsa gstreamer1.0-clutter-3.0
  gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-packagekit gstreamer1.0-pipewire
  gstreamer1.0-plugins-base gstreamer1.0-plugins-base-apps
  gstreamer1.0-plugins-good gstreamer1.0-pulseaudio gstreamer1.0-tools
  gstreamer1.0-x gtk-update-icon-cache gtk2-engines-murrine gtk2-engines-pixbuf
  guile-2.2-libs gvfs gvfs-backends gvfs-common gvfs-daemons gvfs-fuse gvfs-libs
  hicolor-icon-theme hplip hplip-data humanity-icon-theme hunspell-en-us i2c-tools
  ibus ibus-data ibus-gtk ibus-gtk3 ibus-gtk4 ibus-table iio-sensor-proxy
  im-config inputattach ipp-usb javascript-common kerneloops
  language-selector-common language-selector-gnome laptop-detect ldap-utils libaa1
  libabsl20210324 libabw-0.1-1 libaccountsservice0 libadwaita-1-0
  libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl
  libao-common libao4 libasan6 libasound2 libasound2-data libasound2-plugins
  libaspell15 libasyncns0 libatk-adaptor libatk-bridge2.0-0 libatk1.0-0
  libatk1.0-data libatkmm-1.6-1v5 libatomic1 libatopology2 libatspi2.0-0
  libauthen-sasl-perl libavahi-client3 libavahi-common-data libavahi-common3
  libavahi-core7 libavahi-glib1 libavahi-ui-gtk3-0 libavc1394-0
  libayatana-appindicator3-1 libayatana-ido3-0.4-0 libayatana-indicator3-7
  libbabeltrace1 libbasicobjects0 libblkid-dev libbluetooth3
  libboost-filesystem1.74.0 libboost-iostreams1.74.0 libboost-locale1.74.0
  libboost-regex1.74.0 libboost-thread1.74.0 libbrlapi0.8 libc-ares2 libc-dev-bin
  libc-devtools libc6-dbg libc6-dev libcaca0 libcairo-gobject-perl
  libcairo-gobject2 libcairo-perl libcairo-script-interpreter2 libcairo2
  libcairomm-1.0-1v5 libcamel-1.2-63 libcanberra-gtk3-0 libcanberra-gtk3-module
  libcanberra-pulse libcanberra0 libcc1-0 libcdio-cdda2 libcdio-paranoia2
  libcdio19 libcdparanoia0 libcdr-0.1-1 libcheese-gtk25 libcheese8 libclone-perl
  libclucene-contribs1v5 libclucene-core1v5 libclutter-1.0-0 libclutter-1.0-common
  libclutter-gst-3.0-0 libclutter-gtk-1.0-0 libcogl-common libcogl-pango20
  libcogl-path20 libcogl20 libcolamd2 libcollection4 libcolord-gtk1 libcolord2
  libcolorhug2 libcrack2 libcrypt-dev libcue2 libcups2 libcupsfilters1
  libcupsimage2 libdaemon0 libdata-dump-perl libdatrie1 libdazzle-1.0-0
  libdazzle-common libdbusmenu-glib4 libdbusmenu-gtk3-4 libdconf1
  libdebuginfod-common libdebuginfod1 libdee-1.0-4 libdeflate0 libdhash1
  libdjvulibre-text libdjvulibre21 libdmapsharing-3.0-2 libdotconf0 libdpkg-perl
  libdrm-amdgpu1 libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libdv4
  libe-book-0.1-1 libebackend-1.2-10 libebook-1.2-20 libebook-contacts-1.2-3
  libecal-2.0-1 libedata-book-1.2-26 libedata-cal-2.0-1 libedataserver-1.2-26
  libedataserverui-1.2-3 libegl-mesa0 libegl1 libenchant-2-2 libencode-locale-perl
  libeot0 libepoxy0 libepubgen-0.1-1 libespeak-ng1 libetonyek-0.1-1
  libevdocument3-4 libevent-2.1-7 libevview3-3 libexempi8 libexif12 libexiv2-27
  libexpat1-dev libexttextcat-2.0-0 libexttextcat-data libextutils-depends-perl
  libfakeroot libffi-dev libfftw3-single3 libfile-basedir-perl
  libfile-desktopentry-perl libfile-fcntllock-perl libfile-listing-perl
  libfile-mimeinfo-perl libfile-readbackwards-perl libflac8 libfont-afm-perl
  libfontconfig1 libfontembed1 libfontenc1 libfprint-2-2 libfreehand-0.1-1
  libfreerdp-client2-2 libfreerdp-server2-2 libfreerdp2-2 libfuse2 libgail-common
  libgail18 libgamemode0 libgamemodeauto0 libgbm1 libgc1 libgcc-11-dev libgck-1-0
  libgcr-base-3-1 libgcr-ui-3-1 libgd3 libgdata-common libgdata22
  libgdk-pixbuf-2.0-0 libgdk-pixbuf2.0-bin libgdk-pixbuf2.0-common libgdm1
  libgee-0.8-2 libgeoclue-2-0 libgeocode-glib0 libgexiv2-2 libgif7 libgjs0g libgl1
  libgl1-amber-dri libgl1-mesa-dri libglapi-mesa libgles2
  libglib-object-introspection-perl libglib-perl libglib2.0-0 libglib2.0-bin
  libglib2.0-dev libglib2.0-dev-bin libglibmm-2.4-1v5 libglu1-mesa libglvnd0
  libglx-mesa0 libglx0 libgnome-autoar-0-0 libgnome-bg-4-1
  libgnome-bluetooth-3.0-13 libgnome-bluetooth13 libgnome-desktop-3-19
  libgnome-desktop-4-1 libgnome-games-support-1-3 libgnome-games-support-common
  libgnome-menu-3-0 libgnome-todo libgnomekbd-common libgnomekbd8 libgoa-1.0-0b
  libgoa-1.0-common libgoa-backend-1.0-1 libgom-1.0-0 libgomp1 libgpgmepp6
  libgphoto2-6 libgphoto2-l10n libgphoto2-port12 libgpod-common libgpod4
  libgraphene-1.0-0 libgraphite2-3 libgrilo-0.3-0 libgs9 libgs9-common
  libgsf-1-114 libgsf-1-common libgsound0 libgspell-1-2 libgspell-1-common
  libgssdp-1.2-0 libgstreamer-gl1.0-0 libgstreamer-plugins-base1.0-0
  libgstreamer-plugins-good1.0-0 libgtk-3-0 libgtk-3-bin libgtk-3-common
  libgtk-4-1 libgtk-4-bin libgtk-4-common libgtk2.0-0 libgtk2.0-bin
  libgtk2.0-common libgtk3-perl libgtkd-3-0 libgtkmm-3.0-1v5 libgtksourceview-4-0
  libgtksourceview-4-common libgtop-2.0-11 libgtop2-common libgupnp-1.2-1
  libgupnp-av-1.0-3 libgupnp-dlna-2.0-4 libgweather-3-16 libgweather-common
  libgxps2 libhandy-1-0 libharfbuzz-icu0 libharfbuzz0b libhpmud0 libhtml-form-perl
  libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl
  libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl
  libhttp-negotiate-perl libhunspell-1.7-0 libhyphen0 libi2c0 libibus-1.0-5
  libical3 libice6 libidn12 libiec61883-0 libieee1284-3 libijs-0.35 libimagequant0
  libini-config5 libinput-bin libinput10 libio-html-perl libio-socket-ssl-perl
  libio-stringy-perl libipa-hbac0 libipc-system-simple-perl libipt2 libisl23
  libitm1 libiw30 libjack-jackd2-0 libjavascriptcoregtk-4.0-18 libjbig0
  libjbig2dec0 libjpeg-turbo8 libjpeg8 libjs-jquery libjs-sphinxdoc
  libjs-underscore libkpathsea6 liblangtag-common liblangtag1 liblcms2-2
  liblcms2-utils libldap-2.5-0 libldb2 liblirc-client0 libllvm11 libllvm15
  liblouis-data liblouis20 liblouisutdml-bin liblouisutdml-data liblouisutdml9
  liblsan0 libltdl7 liblua5.3-0 liblwp-mediatypes-perl liblwp-protocol-https-perl
  liblxc-common liblxc1 libmailtools-perl libmanette-0.2-0 libmediaart-2.0-0
  libmessaging-menu0 libmhash2 libminiupnpc17 libmount-dev libmozjs-91-0
  libmp3lame0 libmpc3 libmpg123-0 libmspub-0.1-1 libmtdev1 libmtp-common
  libmtp-runtime libmtp9 libmutter-10-0 libmwaw-0.3-3 libmythes-1.2-0 libnatpmp1
  libnautilus-extension1a libndp0 libnet-dbus-perl libnet-http-perl
  libnet-smtp-ssl-perl libnet-ssleay-perl libnfs13 libnfsidmap1 libnm0
  libnma-common libnma0 libnotify-bin libnotify4 libnsl-dev libnss-mdns libnss-sss
  libodfgen-0.1-1 libogg0 libopengl0 libopenjp2-7 libopus0 liborc-0.4-0
  liborcus-0.17-0 liborcus-parser-0.17-0 libpackagekit-glib2-18 libpagemaker-0.0-0
  libpam-cgfs libpam-fprintd libpam-gnome-keyring libpam-pwquality libpam-sss
  libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpangomm-1.4-1v5
  libpangoxft-1.0-0 libpaper-utils libpaper1 libpath-utils1 libpcaudio0
  libpciaccess0 libpcre16-3 libpcre2-16-0 libpcre2-32-0 libpcre2-dev
  libpcre2-posix3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libpeas-1.0-0
  libpeas-common libphobos2-ldc-shared98 libphonenumber8 libpipewire-0.3-0
  libpipewire-0.3-common libpipewire-0.3-modules libpixman-1-0 libpkcs11-helper1
  libpkgconf3 libpoppler-cpp0v5 libpoppler-glib8 libpoppler118 libprotobuf23
  libproxy1-plugin-gsettings libproxy1-plugin-networkmanager libproxy1v5
  libpthread-stubs0-dev libpulse-mainloop-glib0 libpulse0 libpulsedsp
  libpwquality-common libpwquality1 libpython3-dev libpython3.10-dev libqpdf28
  libqqwing2v5 libquadmath0 libraptor2-0 libraqm0 librasqal3 libraw1394-11
  libraw20 librdf0 libref-array1 libreoffice-base-core libreoffice-calc
  libreoffice-common libreoffice-core libreoffice-draw libreoffice-gnome
  libreoffice-gtk3 libreoffice-impress libreoffice-math libreoffice-pdfimport
  libreoffice-style-breeze libreoffice-style-colibre libreoffice-style-elementary
  libreoffice-style-yaru libreoffice-writer librest-0.7-0 librevenge-0.0-0
  librhythmbox-core10 librsvg2-2 librsvg2-common librsync2 librygel-core-2.6-2
  librygel-db-2.6-2 librygel-renderer-2.6-2 librygel-server-2.6-2 libsamplerate0
  libsane-common libsane-hpaio libsane1 libsasl2-modules-gssapi-mit libsbc1
  libsecret-1-0 libsecret-common libselinux1-dev libsensors-config libsensors5
  libsepol-dev libshout3 libsigc++-2.0-0v5 libsm6 libsmbclient libsnapd-glib1
  libsndfile1 libsnmp-base libsnmp40 libsonic0 libsoup-gnome2.4-1 libsoup2.4-1
  libsoup2.4-common libsource-highlight-common libsource-highlight4v5 libsoxr0
  libspa-0.2-modules libspectre1 libspeechd2 libspeex1 libspeexdsp1
  libsss-certmap0 libsss-idmap0 libsss-nss-idmap0 libstartup-notification0
  libstdc++-11-dev libsuitesparseconfig5 libsynctex2 libsysmetrics1 libtag1v5
  libtag1v5-vanilla libtalloc2 libtdb1 libteamdctl0 libtevent0 libthai-data
  libthai0 libtheora0 libtie-ixhash-perl libtiff5 libtimedate-perl libtirpc-dev
  libtotem-plparser-common libtotem-plparser18 libtotem0 libtracker-sparql-3.0-0
  libtry-tiny-perl libtsan0 libtwolame0 libu2f-udev libubsan1
  libunity-protocol-private0 libunity-scopes-json-def-desktop libunity9
  libuno-cppu3 libuno-cppuhelpergcc3-3 libuno-purpenvhelpergcc3-3 libuno-sal3
  libuno-salhelpergcc3-3 liburi-perl libv4l-0 libv4lconvert0 libvisio-0.1-1
  libvisual-0.4-0 libvncclient1 libvncserver1 libvorbis0a libvorbisenc2
  libvorbisfile3 libvpx7 libvte-2.91-0 libvte-2.91-common libvted-3-0 libvulkan1
  libwacom-bin libwacom-common libwacom9 libwavpack1 libwayland-client0
  libwayland-cursor0 libwayland-egl1 libwayland-server0 libwbclient0
  libwebkit2gtk-4.0-37 libwebp7 libwebpdemux2 libwebpmux3
  libwebrtc-audio-processing1 libwhoopsie-preferences0 libwhoopsie0 libwinpr2-2
  libwmf-0.2-7 libwmf-0.2-7-gtk libwmf0.2-7-gtk libwmflite-0.2-7 libwnck-3-0
  libwnck-3-common libwoff1 libwpd-0.10-10 libwpg-0.3-3 libwps-0.4-4 libwww-perl
  libwww-robotrules-perl libx11-dev libx11-protocol-perl libx11-xcb1 libx86-1
  libxatracker2 libxau-dev libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0
  libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-present0 libxcb-randr0
  libxcb-render-util0 libxcb-render0 libxcb-res0 libxcb-shape0 libxcb-shm0
  libxcb-sync1 libxcb-util1 libxcb-xfixes0 libxcb-xkb1 libxcb-xv0 libxcb1-dev
  libxcomposite1 libxcursor1 libxcvt0 libxdamage1 libxdmcp-dev libxfixes3
  libxfont2 libxft2 libxi6 libxinerama1 libxkbcommon-x11-0 libxkbcommon0
  libxkbfile1 libxkbregistry0 libxklavier16 libxml-parser-perl libxml-twig-perl
  libxml-xpathengine-perl libxmlsec1-nss libxmu6 libxpm4 libxrandr2 libxrender1
  libxres1 libxshmfence1 libxss1 libxt6 libxtst6 libxv1 libxvmc1 libxxf86dga1
  libxxf86vm1 libyajl2 libyelp0 linux-libc-dev linux-sound-base lp-solve
  lto-disabled-list lxc lxc-utils lxcfs mailcap make manpages-dev
  media-player-info memtest86+ mesa-vulkan-drivers mime-support
  mobile-broadband-provider-info mousetweaks mscompress mutter mutter-common
  nautilus nautilus-data nautilus-extension-gnome-terminal nautilus-sendto
  nautilus-share network-manager network-manager-config-connectivity-ubuntu
  network-manager-gnome network-manager-openvpn network-manager-openvpn-gnome
  network-manager-pptp network-manager-pptp-gnome openprinting-ppds openvpn orca
  p11-kit p11-kit-modules packagekit packagekit-tools pcmciautils
  perl-openssl-defaults pinentry-gnome3 pipewire pipewire-bin
  pipewire-media-session pkgconf plymouth-label plymouth-theme-spinner
  policykit-desktop-privileges poppler-data poppler-utils power-profiles-daemon
  ppp pptp-linux printer-driver-brlaser printer-driver-c2esp
  printer-driver-foo2zjs printer-driver-foo2zjs-common printer-driver-hpcups
  printer-driver-m2300w printer-driver-min12xxw printer-driver-pnm2ppa
  printer-driver-postscript-hp printer-driver-ptouch printer-driver-pxljr
  printer-driver-sag-gdi printer-driver-splix pulseaudio
  pulseaudio-module-bluetooth pulseaudio-utils python3-aptdaemon
  python3-aptdaemon.gtk3widgets python3-brlapi python3-cairo python3-cups
  python3-cupshelpers python3-dateutil python3-defer python3-dev python3-fasteners
  python3-future python3-gi-cairo python3-ibus-1.0 python3-ldb python3-lockfile
  python3-louis python3-macaroonbakery python3-mako python3-monotonic python3-nacl
  python3-olefile python3-paramiko python3-pil python3-pip python3-protobuf
  python3-pyatspi python3-pymacaroons python3-renderpm python3-reportlab
  python3-reportlab-accel python3-rfc3339 python3-speechd python3-sss
  python3-talloc python3-uno python3-update-manager python3-wheel python3-xdg
  python3.10-dev read-edid remmina remmina-common remmina-plugin-rdp
  remmina-plugin-secret remmina-plugin-vnc rfkill rhythmbox rhythmbox-data
  rhythmbox-plugin-alternative-toolbar rhythmbox-plugins rpcsvc-proto rtkit rygel
  samba-libs sane-airscan sane-utils seahorse session-migration sgml-base
  sgml-data shotwell shotwell-common simple-scan software-properties-gtk
  sound-icons sound-theme-freedesktop speech-dispatcher
  speech-dispatcher-audio-plugins speech-dispatcher-espeak-ng spice-vdagent
  ssl-cert sssd sssd-ad sssd-ad-common sssd-common sssd-ipa sssd-krb5
  sssd-krb5-common sssd-ldap sssd-proxy switcheroo-control system-config-printer
  system-config-printer-common system-config-printer-udev systemd-oomd thunderbird
  thunderbird-gnome-support tigervnc-common tigervnc-standalone-server
  tigervnc-tools tilix tilix-common totem totem-common totem-plugins tracker
  tracker-extract tracker-miner-fs transmission-common transmission-gtk
  ubuntu-advantage-desktop-daemon ubuntu-desktop ubuntu-desktop-minimal
  ubuntu-docs ubuntu-mono ubuntu-release-upgrader-gtk ubuntu-report ubuntu-session
  ubuntu-settings ubuntu-wallpapers ubuntu-wallpapers-jammy uidmap
  uno-libs-private unzip update-inetd update-manager update-manager-core
  update-notifier ure usb-creator-common usb-creator-gtk uuid-dev wamerican
  whoopsie whoopsie-preferences wireless-tools wl-clipboard x11-apps x11-common
  x11-session-utils x11-utils x11-xkb-utils x11-xserver-utils x11proto-dev
  xbitmaps xbrlapi xclip xcursor-themes xcvt xdg-dbus-proxy xdg-desktop-portal
  xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-user-dirs-gtk xdg-utils
  xfonts-base xfonts-encodings xfonts-scalable xfonts-utils xinit xinput xml-core
  xorg xorg-docs-core xorg-sgml-doctools xserver-common xserver-xephyr
  xserver-xorg xserver-xorg-core xserver-xorg-input-all
  xserver-xorg-input-libinput xserver-xorg-input-wacom xserver-xorg-legacy
  xserver-xorg-video-all xserver-xorg-video-amdgpu xserver-xorg-video-ati
  xserver-xorg-video-fbdev xserver-xorg-video-intel xserver-xorg-video-nouveau
  xserver-xorg-video-qxl xserver-xorg-video-radeon xserver-xorg-video-vesa
  xserver-xorg-video-vmware xtrans-dev xwayland yaru-theme-gnome-shell
  yaru-theme-gtk yaru-theme-icon yaru-theme-sound yelp yelp-xsl zenity
  zenity-common zip zlib1g-dev
)

# === Paquetes sugeridos (Suggested packages) ===
SUGGESTED_PACKAGES=(
  gnome-cards-data
  apmd
  alsa-oss
  oss-compat
  dialog
  # Para default-mta | mail-transport-agent → elegimos postfix como opción razonable
  postfix
  libgtk2-perl
  aspell-doc
  spellutils
  ifupdown
  brltty-speechd
  brltty-x11
  console-braille
  unicode-cldr-core
  bzip2-doc
  gnome-video-effects-frei0r
  cpp-doc
  gcc-doc
)

# Combinar ambas listas
ALL_PACKAGES=("${MAIN_PACKAGES[@]}" "${SUGGESTED_PACKAGES[@]}")

echo "🔄 Actualizando lista de paquetes..."
sudo apt update

echo "🔍 Verificando paquetes ya instalados..."
TO_INSTALL=()
for pkg in "${ALL_PACKAGES[@]}"; do
  if ! dpkg -l "$pkg" &> /dev/null; then
    TO_INSTALL+=("$pkg")
  fi
done

if [ ${#TO_INSTALL[@]} -eq 0 ]; then
  echo "✅ Todos los paquetes (incluyendo sugeridos) ya están instalados."
  exit 0
fi

echo "📦 Instalando ${#TO_INSTALL[@]} paquetes adicionales (incluyendo sugeridos)..."
# Instalar con -y y sin interacción (postfix usará configuración por defecto)
sudo DEBIAN_FRONTEND=noninteractive apt install -y "${TO_INSTALL[@]}"

# Marcar como instalados automáticamente (mejor gestión futura)
sudo apt-mark auto "${TO_INSTALL[@]}" 2>/dev/null || true

echo "✅ Instalación completa. Se han instalado todos los paquetes principales y sugeridos."
