# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "Dex"
version = v"2.40.0"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/dexidp/dex.git", "23efe9200ccd9e0a69242bf61cd221462370d1f4"),
    DirectorySource("bundled"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
mkdir -p "${bindir}" "${prefix}/share"
cd dex/
for f in ${WORKSPACE}/srcdir/patches/*.patch; do
    atomic_patch -p1 ${f}
done
install_license LICENSE
go mod tidy
go mod download entgo.io/ent
make build
mkdir -p $bindir
mv bin/dex "$bindir/dex${exeext}"
tar -czvf $prefix/share/webtemplates.tar.gz -C ./web static templates themes
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()


# The products that we will ensure are always built
products = [
    ExecutableProduct("dex", :dex),
    FileProduct("share/webtemplates.tar.gz", :webtemplates),
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; compilers = [:go, :c], julia_compat  = "1.6")
