# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/zeitgeist-datasources/zeitgeist-datasources-0.8.0.1.ebuild,v 1.3 2012/02/15 17:46:04 jlec Exp $

EAPI=4

AUTOTOOLS_AUTORECONF=true

inherit autotools-utils eutils mono multilib python versionator

DIR_PV=$(get_version_component_range 1-2)
DIR_PV2=$(get_version_component_range 1-3)

DESCRIPTION="Plugins whose work is to push activities as events into Zeitgeist daemon"
HOMEPAGE="https://launchpad.net/zeitgeist-datasources/ http://zeitgeist-project.com/"
SRC_URI="http://launchpad.net/zeitgeist-datasources/${DIR_PV}/${DIR_PV2}/+download/${P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
LICENSE="GPL-3"
PLUGINS_IUSE="bzr chromium eog geany gedit vim emacs tomboy telepathy xchat rhythmbox firefox totem"
IUSE="${PLUGINS_IUSE} static-libs"

RDEPEND="
	dev-libs/libzeitgeist
	x11-libs/gtk+:2
	chromium? ( www-client/chromium )
	eog? ( media-gfx/eog[python] )
	geany? ( dev-util/geany )
	gedit? ( app-editors/gedit[zeitgeist] )
	vim? ( app-editors/vim )
	emacs? ( virtual/emacs )
	tomboy? (
		app-misc/tomboy
		dev-dotnet/gtk-sharp
		dev-dotnet/mono-addins
		dev-dotnet/zeitgeist-sharp
		dev-python/dbus-python )
	telepathy? (
		dev-python/telepathy-python
		dev-python/dbus-python
		dev-python/pygobject )
	xchat? ( net-irc/xchat-gnome )
	rhythmbox? ( media-sound/rhythmbox[zeitgeist] )
	firefox? ( || ( >=www-client/firefox-4.0 >=www-client/firefox-bin-4.0 ) )
	totem? ( media-video/totem[zeitgeist] )"
DEPEND="${RDEPEND}
	dev-lang/vala:0.14"
PDEPEND="gnome-extra/zeitgeist"

PLUGINS="bzr chrome eog geany vim emacs tomboy telepathy xchat firefox-40-libzg"

src_prepare() {
	sed \
		-e '/^allowed_plugin/s:^:#:g' \
		-i configure.ac || die

	SEARCH='$(datadir)/opt/google/chrome/resources'
	REPLACE="/usr/$(get_libdir)/chromium-browser/resources"
	sed \
		-e "s:${SEARCH}:${REPLACE}:" \
		-i chrome/Makefile.* || die
	sed \
		-e 's:vim72:vimfiles:' \
		-i vim/Makefile.* || die
	sed \
		-e "s:/xchat/:/xchat-gnome/:g" \
		-i xchat/Makefile.* || die
	autotools-utils_src_prepare
}

src_configure() {
	export VALAC=$(type -p valac-0.14)

	local i myplugins

	for i in ${PLUGINS}; do
		case ${i} in
			chrome )
				use chromium && myplugins+=( ${i} )
				;;
			firefox-40-libzg )
				use firefox && myplugins+=( ${i} )
				;;
			totem-libzg )
				use totem && myplugins+=( ${i} )
				;;
			* )
				use ${i} && myplugins+=( ${i} )
				;;
		esac
	done

	local myeconfargs=(
		allowed_plugins="${myplugins[@]}"
		)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install
	find "${ED}" -name "*.la" -delete || die
}

pkg_postinst() {
	if use chromium; then
		elog "to use the chromium plugin you must open chromium"
		elog "then click the wrench -> tools -> extensions"
		elog "expand the \"Developer mode\" section"
		elog "and click the \"Load unpacked extension...\" button"
		elog "then browse to..."
		elog "\t/usr/$(get_libdir)/chromium-browser/resources/zeitgeist_plugin/"
		elog ""
		elog "More info available here"
		elog "http://code.google.com/chrome/extensions/packaging.html"
	fi
}
