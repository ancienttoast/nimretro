# NimRetro

Nim bindings for the [libretro API](https://docs.libretro.com/development/libretro-overview/). This is mainly meant for developing [cores](https://docs.libretro.com/development/cores/developing-cores/).

## Usage

The bindings are made up of two parts:
* `nimretro/exports.nim`: Contains all the [function definitions](https://docs.libretro.com/development/cores/developing-cores/#implementing-the-api) a core has to export to the _frontend_ already setup for the shared library. This is meant to be `include`d into your the module implementing them.
* `nimretro/types`: Everything else required for the __libretro API__. All the constants and types.

```nim
import nimretro/types
include nimretro/exports

proc retro_init*() =
  discard
```

## Documentation

See the official [Libretro docs](https://docs.libretro.com/development/libretro-overview/) or the original [libretro.h](https://github.com/libretro/libretro-common/blob/master/include/libretro.h) file for more information.

## Sample core

The `sample` directory contains a bare bones sample core. This doesn't require any content, it simply displays a red and green checkerboard pattern with a blue rectangle under the mouse.

You can use the following command to compile it (set the extension in the `--out` parameter to the appropriate one for your platform):

```bash
nim --noMain --gc:arc --app:lib --out:sample_libretro.so c sample/sample_core.nim
```

To _play_ the compiled core in RetroArch you can use the following:

```bash
retroarch --verbose --libretro sample_libretro.so
```
