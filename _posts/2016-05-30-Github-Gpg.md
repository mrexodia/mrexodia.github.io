---
layout: post
tagline: "Getting Github GPG to work on Windows"
category: guide
tags : [git, gpg, git extensions, configuration, tutorial, guide, windows]
---
{% include JB/setup %}

Hello everyone,

Today I saw [this broadcast](https://github.com/blog/2144-gpg-signature-verification) on [Github](https://github.com) which states that GPG signature verification was added to Github. It took me a bit of searching before I got it to work from both the command line and [Git Extensions](https://gitextensions.github.io) so in this guide I will explain how I did it.

## Installing Git (Extensions)

The first thing to install is the latest (v2.0.0+) version of [Git for Windows](https://git-for-windows.github.io).

After will have to install [Git Extensions](https://github.com/gitextensions/gitextensions/releases). Make sure to select the `-SetupComplete` but **do not** install MsysGit from there since you already installed a newer version.

Make sure you configure Git (Extensions) correctly so your identity is in sync with your Github email/username.

## Installing GPG

You can download and install GPG from [here](https://www.gpg4win.org/download.html). Next verify that you installed everything correctly:

```
C:\Users\Admin>git --version
git version 2.8.3.windows.1

C:\Users\Admin>gpg --version
gpg (GnuPG) 2.0.30 (Gpg4win 2.3.1)
libgcrypt 1.6.5
Copyright (C) 2015 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Home: C:/Users/Admin/AppData/Roaming/gnupg
Supported algorithms:
Pubkey: RSA, RSA, RSA, ELG, DSA
Cipher: IDEA, 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH,
        CAMELLIA128, CAMELLIA192, CAMELLIA256
Hash: MD5, SHA1, RIPEMD160, SHA256, SHA384, SHA512, SHA224
Compression: Uncompressed, ZIP, ZLIB, BZIP2
```

If you get any errors, make sure you added everything to your `PATH` environment variable.

## Generating GPG Keys

Follow [this](https://help.github.com/articles/generating-a-new-gpg-key) guide. In short:

```
C:\Users\Admin>gpg --gen-key
gpg (GnuPG) 2.0.30; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0
Key does not expire at all
Is this correct? (y/N) y

Real name: githubgpgtest
Email address: githubgpgtest@gmail.com
Comment:

gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
pub   4096R/6B84CA35 2016-05-30
      Key fingerprint = DF55 D8E3 B4E5 9614 7ADF  8E6E E5B6 4A58 6B84 CA35
uid       [ultimate] githubgpgtest <githubgpgtest@gmail.com>
sub   4096R/63BEB3EE 2016-05-30
```

**Notice**: I will be using `6B84CA35` as my identifier for my key, you should use your own in the upcoming commands.

## Adding your key to Github

Follow [this](https://help.github.com/articles/adding-a-new-gpg-key-to-your-github-account) guide. In short:

```
C:\Users\Admin>gpg --list-keys
C:/Users/Admin/AppData/Roaming/gnupg/pubring.gpg
------------------------------------------------
pub   4096R/6B84CA35 2016-05-30
uid       [ultimate] githubgpgtest <githubgpgtest@gmail.com>
sub   4096R/63BEB3EE 2016-05-30


C:\Users\Admin>gpg --armor --export 6B84CA35
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQINBFdMlawBEADUmBNVR8psLgeBQ1hz2N7VjVmiPiwbgpIK9VAToLX8BYl2ZPYB
...
=k1LJ
-----END PGP PUBLIC KEY BLOCK-----
```

Add your key to your Github account through [this](https://github.com/settings/keys) page:

![github screenshot](https://i.imgur.com/1C6SKwz.png) 

## Configuring Git

Set your globally installed GPG version in Git (make sure to alter this path if you installed `gpg2.exe` in a different location):

```
git config --global gpg.program "C:/Program Files (x86)/GNU/GnuPG/gpg2.exe"
```

Then set your generated signing key:

```
git config --global user.signingkey 6B84CA35
```

These commands enable automatic GPG signing for commits and tags (which is required if you want this to work with Git Extensions):

```
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Now when commiting the Git Extensions it should show you the following dialog:

![gpg password](https://i.imgur.com/3VdRMSg.png)

After pushing to the repository Github shows your commits as verified:

![verified](https://i.imgur.com/LcZ9qIO.png)

## Conclusion

That's about it, your passphrase should cache for a while so you shouldn't be bothered with entering your passphrase every single time you commit. You can configure your caching times here:

![gpg cache](https://i.imgur.com/TMT2T9t.png)

The first entry is the `default-cache-ttl` option, the second `max-cache-ttl`:

```
--default-cache-ttl n
    Set the time a cache entry is valid to n seconds. The default is 600
    seconds.
--max-cache-ttl n
    Set the maximum time a cache entry is valid to n seconds. After this time a
    cache entry will be expired even if it has been accessed recently. The
    default is 2 hours (7200 seconds).
```

If you enjoyed this post, feel free to share it with your friends through social media.

Duncan