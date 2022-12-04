# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome2

DESCRIPTION="Integrated LaTeX environment for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/GNOME-LaTeX https://gitlab.gnome.org/swilmet/gnome-latex"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection +latexmk rubber"

DEPEND="
	>=dev-libs/glib-2.70:2
	>=x11-libs/gtk+-3.22:3
	>=app-text/gspell-1.8:0=
	>=gui-libs/amtk-5.6:5=
	>=x11-libs/gtksourceview-4.0:4
	>=gui-libs/tepl-6.2.0:6=
	>=dev-libs/libgee-0.10:0.8=
	gnome-base/gsettings-desktop-schemas
	x11-libs/gdk-pixbuf:2
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
	gnome-base/dconf
"
RDEPEND="${DEPEND}
	virtual/latex-base
	x11-themes/hicolor-icon-theme
	latexmk? ( dev-tex/latexmk )
	rubber? ( dev-tex/rubber )

	!app-editors/latexila
"
BDEPEND="
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.14
	dev-util/itstool
	>=sys-devel/gettext-0.19.6:0
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		$(use_enable introspection) \
		--enable-dconf_migration \
		--enable-vala=no
}
