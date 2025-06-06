# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org gnome2-utils meson readme.gentoo-r1 virtualx xdg

DESCRIPTION="Default file manager for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Nautilus"

LICENSE="GPL-3+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gnome +gstreamer gtk-doc +introspection +previewer selinux sendto"

DEPEND="
	>=dev-libs/glib-2.67.1:2
	>=media-libs/gexiv2-0.14.0
	gstreamer? ( media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0 )
	>=app-arch/gnome-autoar-0.4.0
	>=gnome-base/gnome-desktop-3.0.0:3=
	>=gnome-base/gsettings-desktop-schemas-42
	>=x11-libs/gtk+-3.22.27:3[X,introspection?]
	>=gui-libs/libhandy-1.5.0:1
	>=x11-libs/pango-1.28.3
	selinux? ( >=sys-libs/libselinux-2.0 )
	>=app-misc/tracker-3.0:3=
	x11-libs/libX11
	>=dev-libs/libxml2-2.7.8:2
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
"
RDEPEND="${DEPEND}
	>=app-misc/tracker-miners-3.0:3=
" # uses org.freedesktop.Tracker.Miner.Files gsettings schema from tracker-miners
BDEPEND="
	>=dev-util/gdbus-codegen-2.51.2
	>=dev-build/meson-0.57.2
	gtk-doc? (
		>=dev-util/gtk-doc-1.10
		app-text/docbook-xml-dtd:4.1.2 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
"
PDEPEND="
	gnome? ( x11-themes/adwaita-icon-theme )
	previewer? ( >=gnome-extra/sushi-0.1.9 )
	sendto? ( >=gnome-extra/nautilus-sendto-3.0.1 )
	>=gnome-base/gvfs-1.14[gtk(+)]
" # Need gvfs[gtk] for recent:/// support; always built (without USE=gtk) since gvfs-1.34

PATCHES=(
	"${FILESDIR}"/${PN}-3.30.5-docs-build.patch # Always install pregenerated manpage, keeping docs option for gtk-doc
	"${FILESDIR}"/${PN}-42.0-optional-gstreamer.patch # Allow controlling audio-video-properties build
)

src_prepare() {
	default
	xdg_environment_reset

	if use previewer; then
		DOC_CONTENTS="nautilus uses gnome-extra/sushi to preview media files.
			To activate the previewer, select a file and press space; to
			close the previewer, press space again."
	fi

	# Disable test-nautilus-search-engine-tracker; bug #831170
	sed -e '/^tracker_tests = /{n;N;N;d}' -i test/automated/displayless/meson.build || die
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc docs)
		-Dextensions=true # image file properties, sendto support; also required for -Dgstreamer=true
		$(meson_use gstreamer) # gstreamer audio-video-properties extension
		$(meson_use introspection)
		-Dlibportal=false # As of 40.2, all libportal usages are flatpak-specific
		-Dpackagekit=false
		$(meson_use selinux)
		-Dprofiling=false
		-Dtests=$(usex test all none)
	)
	meson_src_configure
}

src_install() {
	use previewer && readme.gentoo_create_doc
	meson_src_install
}

src_test() {
	gnome2_environment_reset # Avoid dconf that looks at XDG_DATA_DIRS, which can sandbox fail if flatpak is installed
	# TODO: Tests require tracker testutils (e.g. tracker-sandbox), which may need some sorting out with tracker use flag deps
	virtx meson_src_test
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	if use previewer; then
		readme.gentoo_print_elog
	else
		elog "To preview media files, emerge nautilus with USE=previewer"
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
