# GtkPacker

**A tool to pack GTK applications**

## Introduction

Usually, it is easy to distribute GTK applications under Linux, because almost all Linux distributions have complete dependency systems, so GTK dependencies are easy to install. However, the Windows platform does not have such a dependency system, and the dependencies of GTK applications often need to be distributed with the program.

At present, there are few tools for packaging GTK applications under Windows. This project aims to provide a convenient GTK application packaging solution for the Windows platform. Since this project is in the early stage of development, it is highly welcome to provide suggestions and PRs.

## Platform

* Windows with MSYS2 environment

## Build

### Dependencies

* For Runtime:
  * `glib`
  * `ntldd` to analyze the dependencies of Windows applications
* For Build:
  * `gcc` or other C compilers
  * `glib`
  * `vala`
  * `meson`
  * `ninja`

#### Environment Installation

Confirm your MSYS2 environment and install related packages, for example, `UCRT64`:

```bash
pacman -S mingw-w64-ucrt-x86_64-ntldd mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-vala mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-ninja
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
