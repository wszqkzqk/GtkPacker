# GtkPacker

**A tool to pack GTK applications**

## Platform

* Windows with MSYS2 environment

## Build

### Dependencies

* For Runtime:
  * `gtk4` and its dependencies
  * `ntldd` to analyze the dependencies of Windows applications
* For Build:
  * `gtk4` and its dependencies
  * `gcc` or other C compilers
  * `vala`
  * `meson`
  * `ninja`

#### Environment Installation

Confirm your MSYS2 environment and install related packages, for example, `UCRT64`:

```bash
pacman -S mingw-w64-ucrt-x86_64-gtk4 mingw-w64-ucrt-x86_64-ntldd mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-vala mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-ninja
```

### Setup, Compile and Install

Clone this repo:
```bash
git clone https://github.com/wszqkzqk/GtkPacker.git
```

Setup:
```bash
cd GtkPacker
meson setup --libexecdir lib --sbindir bin --buildtype release --auto-features enabled --wrap-mode nodownload -D b_lto=true -D b_pie=true builddir
```

Build:
```bash
meson compile -C builddir
```

Install:
```
meson install -C builddir
```
