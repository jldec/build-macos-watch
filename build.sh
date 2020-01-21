# NOTE: this cannot be run in one step - start with just the curl and jq steps below
# improvements todo:
# - just extract **/.brew/*.rb for each bottle
# - pull mirror or git url from bottle
# - use non-versioned directories for extracted source (see .gitignore)

export PREFIX=~/local
echo "PREFIX = $PREFIX"

export BUILD_DIR=~/homebrew
echo "BUILD_DIR = $BUILD_DIR"
mkdirp $BUILD_DIR
cd $BUILD_DIR

curl https://formulae.brew.sh/api/formula/autoconf.json   | jq > autoconf.json
curl https://formulae.brew.sh/api/formula/automake.json   | jq > automake.json
curl https://formulae.brew.sh/api/formula/gettext.json    | jq > gettext.json
curl https://formulae.brew.sh/api/formula/libtool.json    | jq > libtool.json
curl https://formulae.brew.sh/api/formula/pkg-config.json | jq > pkg-config.json
curl https://formulae.brew.sh/api/formula/ncurses.json    | jq > ncurses.json
curl https://formulae.brew.sh/api/formula/watch.json      | jq > watch.json

jq '.bottle.stable.files.catalina.url' < autoconf.json   | xargs curl -OL
jq '.bottle.stable.files.catalina.url' < automake.json   | xargs curl -OL
jq '.bottle.stable.files.catalina.url' < gettext.json    | xargs curl -OL
jq '.bottle.stable.files.catalina.url' < libtool.json    | xargs curl -OL
jq '.bottle.stable.files.catalina.url' < pkg-config.json | xargs curl -OL
jq '.bottle.stable.files.catalina.url' < ncurses.json    | xargs curl -OL
jq '.bottle.stable.files.catalina.url' < watch.json      | xargs curl -OL

# now manually un-tar the downloaded bottle archives
# open the xxx.rb file in each .brew directory to check versions of the curl/clone steps below

curl -LO https://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.xz
curl -LO https://ftpmirror.gnu.org/automake/automake-1.16.1.tar.xz
curl -LO https://ftpmirror.gnu.org/gettext/gettext-0.20.1.tar.xz
curl -LO https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.xz
curl -LO https://dl.bintray.com/homebrew/mirror/pkg-config-0.29.2.tar.gz
curl -LO https://ftpmirror.gnu.org/ncurses/ncurses-6.1.tar.gz
git clone https://gitlab.com/procps-ng/procps.git && git checkout v3.3.16

# versions below must match the versions curled/cloned above.
# build steps are copied from the install function in each .brew file

cd $BUILD_DIR
rm -fr  autoconf-2.69
tar xzf autoconf-2.69.tar.xz
cd      autoconf-2.69
export PERL=/usr/bin/perl
sed -i '' 's/libtoolize/glibtoolize/g' bin/autoreconf.in
sed -i '' 's/libtoolize/glibtoolize/g' man/autoreconf.1
./configure --prefix=${PREFIX}
make install

cd $BUILD_DIR
rm -fr  automake-1.16.1
tar xzf automake-1.16.1.tar.xz
cd      automake-1.16.1
curl -L https://git.savannah.gnu.org/cgit/automake.git/patch/?id=a348d830659fffd2cfc42994524783b07e69b4b5 >sedpatch.patch
patch -p1 <sedpatch.patch
export PERL=/usr/bin/perl
./configure --prefix=${PREFIX}
make install

cd $BUILD_DIR
rm -fr  gettext-0.20.1
tar xzf gettext-0.20.1.tar.xz
cd      gettext-0.20.1
./configure \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --disable-debug \
  --prefix=${PREFIX} \
  --with-included-gettext \
  gl_cv_func_ftello_works=yes \
  --with-included-glib \
  --with-included-libcroco \
  --with-included-libunistring \
  --disable-java \
  --disable-csharp \
  --without-git \
  --without-cvs \
  --without-xz
make
make install

cd $BUILD_DIR
rm -fr  libtool-2.4.6
tar xzf libtool-2.4.6.tar.xz
cd      libtool-2.4.6
export SED=sed
./configure \
  --disable-dependency-tracking \
  --prefix=${PREFIX} \
  --program-prefix=g \
  --enable-ltdl-install
make install

cd $BUILD_DIR
rm -fr  pkg-config-0.29.2
tar xzf pkg-config-0.29.2.tar.gz
cd      pkg-config-0.29.2
./configure \
  --disable-debug \
  --prefix=${PREFIX} \
  --disable-host-tool \
  --with-internal-glib \
  --with-pc-path=${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig
make
make check
make install

# did not implement make_libncurses_symlinks from ncurses/ncurses/6.1/.brew/ncurses.rb
cd $BUILD_DIR
rm -fr  ncurses-6.1
tar xzf ncurses-6.1.tar.gz
cd      ncurses-6.1
./configure \
  --prefix=${PREFIX} \
  --enable-pc-files \
  --with-pkg-config-libdir=${PREFIX}/lib/pkgconfig \
  --enable-sigwinch \
  --enable-symlinks \
  --enable-widec \
  --with-shared \
  --with-gpm=no
make install

cd $BUILD_DIR/procps
autoreconf -fiv
./configure \
  --disable-dependency-tracking \
  --prefix=${PREFIX} \
  --disable-nls \
  --enable-watch8bit
make watch
cp watch ~/local/bin
cp watch.1 ~/local/share/man/man1/