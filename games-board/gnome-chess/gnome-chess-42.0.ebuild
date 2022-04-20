# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python{3_8,3_9,3_10} )
VALA_MIN_API_VERSION="0.52"

inherit gnome.org gnome2-utils meson python-any-r1 vala xdg

DESCRIPTION="Play the classic two-player boardgame of chess"
HOMEPAGE="https://wiki.gnome.org/Apps/Chess"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="+engines"

RDEPEND="
	>=dev-libs/glib-2.44:2
	gui-libs/gtk:4
	>=gui-libs/libadwaita-1.0.0:1
	>=gnome-base/librsvg-2.46.0:2
	engines? (
		games-board/crafty
		games-board/gnuchess
		games-board/sjeng
		games-board/stockfish
	)
"
DEPEND="${RDEPEND}
	gnome-base/librsvg:2[vala]
"
BDEPEND="
	${PYTHON_DEPS}
	$(vala_depend)
	dev-util/itstool
	dev-libs/appstream-glib
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	default
	vala_setup
	xdg_environment_reset
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
