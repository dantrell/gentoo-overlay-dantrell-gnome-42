# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit gnome.org gnome2-utils meson virtualx xdg

DESCRIPTION="GNOME utility for installing applications and updating systems"
HOMEPAGE="https://wiki.gnome.org/Apps/Software https://gitlab.gnome.org/GNOME/gnome-software"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="flatpak firmware gnome gtk-doc sysprof udev"

RESTRICT="test" # See TODO below

RDEPEND="
	>=dev-libs/appstream-0.14.0:0=
	>=x11-libs/gdk-pixbuf-2.32.0:2
	>=dev-libs/libxmlb-0.1.7:=
	>=gui-libs/gtk-4.6:4
	>=dev-libs/glib-2.66.0:2
	>=dev-libs/json-glib-1.6.0
	>=net-libs/libsoup-2.52.0:2.4
	>=gui-libs/libadwaita-1.0.1:1
	sysprof? ( >=dev-util/sysprof-capture-3.40.1:4 )
	gnome? ( >=gnome-base/gsettings-desktop-schemas-3.18.0 )
	sys-auth/polkit
	firmware? ( >=sys-apps/fwupd-1.5.6 )
	flatpak? (
		>=sys-apps/flatpak-1.9.1
		dev-util/ostree
	)
	udev? ( dev-libs/libgudev )
	>=gnome-base/gsettings-desktop-schemas-3.11.5
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/libxml2:2
	dev-util/gdbus-codegen
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? (
		dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3 )
"
# test? ( dev-debug/valgrind )

src_prepare() {
	default
	xdg_environment_reset

	sed -i -e '/install_data.*README\.md.*share\/doc\/gnome-software/d' meson.build || die
	# We don't need language packs download support, and it fails tests in 3.34.2 for us (if they are enabled)
	sed -i -e '/subdir.*fedora-langpacks/d' plugins/meson.build || die
	# Trouble talking to spawned gnome-keyring socket for some reason, even if wrapped in dbus-run-session
	# TODO: Investigate; seems to work outside ebuild .. test/emerge
	sed -i -e '/g_test_add_func.*gs_auth_secret_func/d' lib/gs-self-test.c || die
}

src_configure() {
	local emesonargs=(
		$(meson_use test tests)
		$(meson_feature gnome gsettings_desktop_schemas) # Honoring of GNOME date format settings.
		-Dman=true
		-Dpackagekit=false
		# -Dpackagekit_autoremove
		-Dpolkit=true
		-Deos_updater=false # Endless OS updater
		$(meson_use firmware fwupd)
		$(meson_use flatpak)
		-Dmalcontent=false
		-Drpm_ostree=false
		$(meson_use udev gudev)
		-Dapt=false
		-Dsnap=false
		-Dexternal_appstream=false
		-Dvalgrind=false
		$(meson_use gtk-doc gtk_doc)
		-Dhardcoded_popular=true
		-Ddefault_featured_apps=false # TODO: Will this be beneficial to us with flatpak at least? If enabled, it shows some apps under installed (probably merely due to /usr/share/app-info presence), but launching and removal of them is broken
		-Dmogwai=false #TODO?
		$(meson_feature sysprof)
		-Dprofile=''
		-Dsoup2=true
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
