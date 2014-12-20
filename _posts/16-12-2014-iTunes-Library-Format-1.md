---
layout: post
tagline: "Reversing the iTunes Library File Format"
category: reversing
tags : [binary, drm, iTunes, library, file, format, itl, aes, zlib]
---
{% include JB/setup %}

Hello everyone,

More than a month ago I posted about some code I had to write for a project, today it will be about exploring the iTunes Library file format.

##Background

"Why reverse the iTunes Library format?" you might ask, well it all started with a university project. Basically we're developing an app for Android/iOS using [Xamarin](http://xamarin.com) and since Apple doesn't like Windows, it is **impossible** to create/compile/test iOS apps without having access to Mac OS X. I installed a [hackintosh distribution](http://hackintosh.zone) to start developing the app.

One time, when I was browsing iTunes I saw I had 15 euros left on my account, so I decided to buy an eBook I saw on TV. But Apple still hates Windows/Android/Whatever and after I spent my money I discovered it was impossible to read books bought in the iBooks store on a non-iDevice. I tried searching for some DRM removal tools, but there was only one and it didn't work (it's called [requiem](https://www.google.com/?#q=requiem+drm) by the way).

Since I like reversing I decided to take on FairPlay (Apple's DRM) in order to unlock the .epub file so I can read it on my Sony eReader.

In the process of checking out the [old sources](https://www.google.nl/?#q=requiem-3.3.6-src.zip) I discovered that the iTunes Library was read and decrypted, but after that the file format did not match the code anymore. Since the code was made for iTunes v10.x, not v12.x I had to figure out the new library file format.

##The past

In the past people tried to reverse the iTunes Library file format, the more notable document is [this one](http://search.cpan.org/~bdfoy/Mac-iTunes/doc/file_format.pod). It's for iTunes v1.x - v3.x, but it was still useful for me now. Another resource is the previously mentioned [requiem source code](https://www.google.nl/?#q=requiem-3.3.6-src.zip).

##Getting started

Before we get started I'd like to introduce a very good tool called [Synalyze It! Pro](https://www.synalysis.net). Basically it's a hex editor, but it's main feature (for us at least) is the 'Grammars' option. Grammers are XML files that describe data structures and when a structure matches with a file, you can see the structure contents and highlight/manipulate the bytes they are mapped to. Reading the documentation is recommended before you continue.

It might also be useful to note I'm doing everything on Mac OS X (probably iTunes for Windows has the same format, but I didn't check).

Now copy the iTunes Library file called `iTunes Library.itl` from `~/Music/iTunes/` to your documents folder or something and open it up in Synalyze It to start working with it.

##Encryption + ZLIB

In the requiem source code, you can see in `ModifyLib.loadLibrary()` that the iTunes file from v10.x used `AES/ECB/NoPadding` with the key `BHUILuilfghuila3`:

```
...

// decrypt all full blocks in the body
Key key = new SecretKeySpec("BHUILuilfghuila3".getBytes(), "AES");
Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
cipher.init(Cipher.DECRYPT_MODE, key);
int crypt_size = (data.length - header_size) & ~0xf;
int max_crypt_size = read32(data, 0x5C);
if (max_crypt_size != 0)
    crypt_size = Math.min(crypt_size, max_crypt_size);
cipher.doFinal(data, header_size, crypt_size, data, header_size);

// un-zip body (ZLIB)
Inflater inflater = new Inflater();
inflater.setInput(data, header_size, data.length - header_size);
byte[] clear_data = new byte[65536];
while (!inflater.finished())
{
    int n = inflater.inflate(clear_data);
    o.write(clear_data, 0, n);
}

...
```

After reading the [older file format from iTunes v1.x - v3.x](http://search.cpan.org/~bdfoy/Mac-iTunes/doc/file_format.pod) and the requiem source it is quite easy to create [a Grammar for the encrypted file format](https://gist.github.com/mrexodia/b21b429cdab57fa64e81):

![Encrypted iTunes Library](/images/itunes_1_screenshot.png)

##Conclusion (for now)

Hopefully this was an interesting start. Unfortunately I don't have enough time to post the full story, but there will be a next post soon (I hope). In the meantime, try modifying the requiem source to output a decrypted iTunes library of your own. This will be required for the next post. Another thing you might want to do it setting up Eclipse with the `Makefile` included in the requiem source. This will make dumping the decrypted library a lot easier.

Till next time,

Mr. eXoDia
