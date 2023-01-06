# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome.org meson-multilib systemd virtualx xdg

GNOME_ORG_MODULE="at-spi2-core"

DESCRIPTION="D-Bus accessibility specifications and registration daemon"
HOMEPAGE="https://wiki.gnome.org/Accessibility https://gitlab.gnome.org/GNOME/at-spi2-core"
SRC_URI="mirror://gnome/sources/${GNOME_ORG_MODULE}/${GNOME_ORG_PVP}/${GNOME_ORG_MODULE}-${PV}.tar.${GNOME_TARBALL_SUFFIX}"

S="${WORKDIR}/${GNOME_ORG_MODULE}-${PV}"

LICENSE="LGPL-2.1+"
SLOT="2"
KEYWORDS="*"

IUSE="X gtk-doc +introspection"
REQUIRED_USE="gtk-doc? ( X )"

RDEPEND="
	>=sys-apps/dbus-1.5[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.67.4:2[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-1.54.0:= )
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXtst[${MULTILIB_USEDEP}]
		x11-libs/libXi[${MULTILIB_USEDEP}]
	)

	!<app-accessibility/at-spi2-core-2.46.0:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? (
		>=dev-util/gtk-doc-1.25
		app-text/docbook-xml-dtd:4.3
	)
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# disable teamspaces test since that requires Novell.ICEDesktop.Daemon
	"${FILESDIR}"/${GNOME_ORG_MODULE}-2.0.2-disable-teamspaces-test.patch
)

multilib_src_configure() {
	local emesonargs=(
		-Dsystemd_user_dir="$(systemd_get_userunitdir)"
		$(meson_native_use_bool gtk-doc docs)
		-Dintrospection=$(multilib_native_usex introspection)
		-Dx11=$(usex X)
	)
	meson_src_configure
}

multilib_src_test() {
	virtx dbus-run-session meson test -C "${BUILD_DIR}"
}
