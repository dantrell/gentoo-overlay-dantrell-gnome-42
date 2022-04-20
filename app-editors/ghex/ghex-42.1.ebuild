# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org gnome2-utils meson xdg

DESCRIPTION="GNOME hexadecimal editor"
HOMEPAGE="https://wiki.gnome.org/Apps/Ghex"

LICENSE="GPL-2+ FDL-1.1+"
SLOT="4"
KEYWORDS="*"

IUSE="gtk-doc test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.66.0:2
	>=gui-libs/gtk-4.0.0:4
	dev-libs/gobject-introspection:=
	!app-editors/ghex:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	gtk-doc? ( dev-util/gi-docgen )
	test? (
		dev-util/desktop-file-utils
		dev-libs/appstream-glib
	)
	dev-util/gtk-update-icon-cache
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Ddocdir="${EPREFIX}"/usr/share/gtk-doc/
		-Dintrospection=enabled
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
