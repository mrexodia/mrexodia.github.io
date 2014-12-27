---
layout: post
tagline: "Reversing the iTunes Library File Format"
category: reversing
tags : [binary, drm, iTunes, library, file, format, itl, aes, zlib]
---
{% include JB/setup %}

A few days ago I wrote some things about the iTunes library file format. Today I will try to write the remainder about this subject.

## A small recap

In the previous post I discussed the structure of the encrypted file and there should also be enough information for a mediocre programmer to decrypt a `.itl` file by yourself. In this post I will be using a decrypted `.itl` file.

## The base structure

Every `.itl` file starts with an `hdfm` information header. The approximate format of this header block is documented the [older file format from iTunes v1.x - v3.x](http://search.cpan.org/~bdfoy/Mac-iTunes/doc/file_format.pod). Basically after this everything is the same as in the older file format, except the header 'names'. The `hdsm` now is reversed to `msdh`. The whole file is basically build of `msdh` blocks with variables sizes.

Here is a small screenshot that shows the header and the `msdh` blocks:

![header](/images/itl_header.png)

## Structure of the 'msdh' blocks

The `msdh` blocks contain the `headerLength`, `totalLength` and `blockType` as most important fields. After the `msdh` header, there is `blockData` that can contain various other types of structures. These structures very often look like this:

```
struct mlrh
{
    char signature[4]; //"mlrh"
    int headerLength; //total length of the header
    char unknown[headerLength - 8]; //some data
}
```

A screenshot of the grammar:

![basic block structure](/images/itl_basic_block_data.png)

## Content of the 'msdh' blocks

The `blockType` field of the `msdh` block says something about the content of the block. The value `4` for example has `blockData` that contains a path to the music library (`/Users/xxxxxx/Music/iTunes/iTunes%20Media` in my case). `blockData` can also contain other blocks. The `miah` and `mith` blocks for example both contain `mhoh` blocks. `mhoh` blocks are some kind of general-purpose block that can contain a lot of things.

## Conclusion

The basic file format was all I needed to continue fixing requiem, so this it all for now. Maybe I will blog about my progress another time. You can find the grammar [here](https://gist.github.com/mrexodia/0e0ddec9460e6aaca43f), feel free to expand on it and don't forget to send me the latest version :)

Merry Christmas,

Mr. eXoDia