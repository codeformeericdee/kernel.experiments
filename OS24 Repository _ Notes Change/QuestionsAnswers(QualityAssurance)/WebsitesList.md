https://docker.com : Allows you to build on a Linux container in Windows, which I find to be the easiest method for cross compiling, which is required
                     on a higher level language development setup like C, or C++.

https://bochs.com : An emulator that can load binaries and other sorts of bootable devices. I use Windows, and I find this one slightly easier to use
                    than QEMU.

https://www.qemu.org/ : An emulator that can load binaries and other sorts of bootable devices. On Linux as the native OS, I find this one easier to use
                        than Bochs.

    ^ Please note that you have to run the application in your native OS when developing. Containers are command line only, and don't run apps with a GUI

https://clang.llvm.org/ : This is the cross compiler that I use, as it is a cross compiler by default, and very simple to set up.

https://gcc.gnu.org/ : This is the compiler that wiki.osdev recommends you use to turn into a cross compiler. It can be very difficult and time consuming to set up.

https://wiki.osdev.org/Main_Page : This is a directory for a lot of helpful OS information, but can sometimes have outdated instructions on compilation, so keep 
                                  that in mind.

https://savannah.nongnu.org/projects/pgubook/ : This book covers a lot of topics that you need to get started with assembly language

https://wiki.osdev.org/Multiboot : What multiboot is. Plus grub, which is the program used to load this kernel and allow you to boot from any mode.
https://www.gnu.org/software/grub/manual/multiboot/multiboot.html