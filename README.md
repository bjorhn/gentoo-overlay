# Oz Gentoo Overlay

To add this overlay, edit __/etc/layman/layman.cfg__ and add the following url to the overlays value __https://raw.github.com/bjorhn/gentoo-overlay/master/profiles/repo.xml__

Example:

    overlays  : http://www.gentoo.org/proj/en/overlays/repositories.xml
                https://raw.github.com/bjorhn/gentoo-overlay/master/profiles/repo.xml

Then add it with __layman -a oz__