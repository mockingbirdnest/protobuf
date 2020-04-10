./autogen.sh

# NOTE(Norgg): Really definitely needs to run twice on Ubuntu for some reason.
# See
# https://github.com/mockingbirdnest/Principia/commit/8be8f78eee44f384e1658f546,
# https://github.com/mockingbirdnest/Principia/commit/00f9d280a9054894dd22e1170.
./autogen.sh

./configure \
    CC=clang \
    CXX=clang++ \
    CXXFLAGS="${CXX_FLAGS?}" \
    LDFLAGS="${LD_FLAGS?}" \
    LIBS="-lc++ -lc++abi"
make -j8
