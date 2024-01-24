![Ox64 BL808 Emulator with TinyEMU RISC-V Emulator and Apache NuttX RTOS](https://lupyuen.github.io/images/tinyemu2-title.png)

[_(Live Demo of Ox64 BL808 Emulator)_](https://lupyuen.github.io/nuttx-tinyemu/smode)

[_(Watch the Demo on YouTube)_](https://youtu.be/FAxaMt6A59I)

# Emulate Ox64 BL808 SBC in the Web Browser with TinyEMU RISC-V Emulator <br><br> Part 3: Emulate the System Timer

Read the article...

-   ["Emulate Ox64 BL808 in the Web Browser: Experiments with TinyEMU RISC-V Emulator and Apache NuttX RTOS"](https://lupyuen.github.io/articles/tinyemu2)

Continues from [Part 2](https://github.com/lupyuen/ox64-tinyemu/tree/smode/README.md)...

# Fix the System Timer

TODO

[For OpenSBI Set Timer: Clear the pending timer interrupt bit](https://github.com/lupyuen/ox64-tinyemu/commit/758287cc3aa8165303c6a726292e665af099aefd)

[For RDTIME: Return the time](https://github.com/lupyuen/ox64-tinyemu/commit/1bcf19a4b2354bc47b515a3fe2f2e8a427e3900d)

[Regularly trigger the Supervisor-Mode Timer Interrupt](https://github.com/lupyuen/ox64-tinyemu/commit/ddedb862a786e52b17cf3331752d50662eddffd3)

`usleep` works OK yay!

```text
Loading...
TinyEMU Emulator for Ox64 BL808 RISC-V SBC
ABC
NuttShell (NSH) NuttX-12.4.0-RC0
nsh> usleep 1
nsh> 
```

[Patch DCACHE.IALL and SYNC.S to become ECALL](https://github.com/lupyuen/ox64-tinyemu/commit/b8671f76414747b6902a7dcb89f6fc3c8184075f)

[Handle System Timer with mtimecmp](https://github.com/lupyuen/ox64-tinyemu/commit/f00d40c0de3d97e93844626c0edfd3b19e8252db)

[Emulator Timer Log](https://gist.github.com/lupyuen/31bde9c2563e8ea2f1764fb95c6ea0fc)

Test `ostest`...

```text
semtimed_test: Starting poster thread
semtimed_test: Set thread 1 priority to 191
semtimed_test: Starting poster thread 3
semtimed_test: Set thread 3 priority to 64
semtimed_test: Waiting for two second timeout
poster_func: Waiting for 1 second
semtimed_test: ERROR: sem_timedwait failed with: 110
_assert: Current Version: NuttX  12.4.0-RC0 55ec92e181 Jan 24 2024 00:11:51 risc
-v
_assert: Assertion failed (_Bool)0: at file: semtimed.c:240 task: ostest process
: ostest 0x8000004a
up_dump_register: EPC: 0000000050202008
```

[Remove the Timer Interrupt Interval because ostest will fail](https://github.com/lupyuen/ox64-tinyemu/commit/169dd727a5e06bdc95ac3f32e1f1b119c3cbbb75)

`ostest` is OK yay!

https://lupyuen.github.io/nuttx-tinyemu/timer/

`expect` script works OK with Ox64 BL808 Emulator...

```bash
#!/usr/bin/expect
set send_slow {1 0.001}
spawn /Users/Luppy/riscv/ox64-tinyemu/temu root-riscv64.cfg

expect "nsh> "
send -s "uname -a\r"

expect "nsh> "
send -s "ostest\r"
expect "ostest_main: Exiting with status -1"
expect "nsh> "
```

We'll run this for Daily Automated Testing, right after the Daily Automated Build.

# Emulate BL808 GPIO to Blink an LED

TODO

# TinyEMU

[![Build](https://github.com/lupyuen/TinyEMU/workflows/Build/badge.svg)][GitHub Actions]

This is a modified version of [Fabrice Bellard's TinyEMU][TinyEMU].

[GitHub Actions]: https://github.com/fernandotcl/TinyEMU/actions?query=workflow%3ABuild
[TinyEMU]: https://bellard.org/tinyemu/

## Features

- 32/64/128-bit RISC-V emulation.
- VirtIO console, network, block device, input and 9P filesystem.
- Framebuffer emulation through SDL.
- Remote HTTP block device and filesystem.
- Small code, easy to modify, no external dependencies.

Changes from Fabrice Bellard's 2019-02-10 release:

- macOS and [iOS][TinyEMU-iOS] support.
- Support for loading ELF images.
- Support for loading initrd images or compressed initramfs archives.
- Framebuffer support through SDL 2 instead of 1.2.

[TinyEMU-iOS]: https://github.com/fernandotcl/TinyEMU-iOS

## Usage

Use the VM images available from Fabrice Bellard's [jslinux][] (no need to download them):

```
$ temu https://bellard.org/jslinux/buildroot-riscv64.cfg

Welcome to JS/Linux (riscv64)

Use 'vflogin username' to connect to your account.
You can create a new account at https://vfsync.org/signup .
Use 'export_file filename' to export a file to your computer.
Imported files are written to the home directory.

[root@localhost ~]# uname -a
Linux localhost 4.15.0-00049-ga3b1e7a-dirty #11 Thu Nov 8 20:30:26 CET 2018 riscv64 GNU/Linux
[root@localhost ~]#
```

Use `C-a x` to exit the emulator.

You can also use TinyEMU with local configuration and disks. You can find more information in Fabrice Bellard's [documentation for TinyEMU][tinyemu-readme].

[jslinux]: https://bellard.org/jslinux
[tinyemu-readme]: https://bellard.org/tinyemu/readme.txt

## Installing

The easiest way to install TinyEMU is through [Homebrew][]. There is a formula for TinyEMU in [my Homebrew tap][tap].

[homebrew]: https://brew.sh
[tap]: https://github.com/fernandotcl/homebrew-fernandotcl

If you're compiling from source, you'll need:

- [OpenSSL][] (optional)
- [SDL 2.0][sdl] (optional)

[openssl]: https://www.openssl.org
[sdl]: https://www.libsdl.org

Make sure to disable `CONFIG_INT128` for 32-bit hosts.

## Credits

TinyEMU was created by [Fabrice Bellard][fabrice]. This port is maintained by [Fernando Tarlá Cardoso Lemos][fernando].

[fabrice]: https://bellard.org
[fernando]: mailto:fernandotcl@gmail.com

## License

Unless otherwise specified in individual files, TinyEMU is available under the MIT license.

The SLIRP library has its own license (two-clause BSD license).
