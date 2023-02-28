# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python{3_9,3_10,3_11} )

inherit gnome.org gnome2-utils meson python-any-r1 xdg

DESCRIPTION="Collection of GSettings schemas for GNOME desktop"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gsettings-desktop-schemas"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection"

BDEPEND="
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	${PYTHON_DEPS}
"

PATCHES=(
	# Revert change to 'Source Code Pro 10' and 'Cantarell 11' fonts back to generic sans and monospace aliases
	"${FILESDIR}"/${PN}-3.32.0-default-fonts.patch
)

src_prepare() {
	default

	python_fix_shebang build-aux/meson/post-install.py
}

src_configure() {
	meson_src_configure $(meson_use introspection)
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
