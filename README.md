## Compile watch from source on macOS
This is the result of my attempt to compile the unix [watch](https://en.wikipedia.org/wiki/Watch_(Unix)) utility from source on macOS (Catalina).

After unsuccessfully futzing to guess autoconf settings, I eventually got this working using scripts and configure options copied from [homebrew](https://brew.sh/) formulae.

- All the steps are in [build.sh](build.sh)
- Binaries are installed in ~/local/bin, ~/local/lib etc.
- The resulting `watch` binary depends on an ncurses dynlib under my home directory, making it not very portable.

Credit: Thanks to [homebrew](https://github.com/Homebrew/brew/graphs/contributors) and other OSS community contributors!
