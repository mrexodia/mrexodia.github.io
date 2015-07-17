---
layout: post
tagline: "Adding or replacing deobfuscators in de4dot..."
category: coding
tags : [.NET, coding, obfuscation, de4dot]
---
{% include JB/setup %}

Hey, what's up everybody?

About two months ago I came across a modified version of [de4dot](http://de4dot.com) someone made, which required me to replace my current de4dot version in it's entirety. I did not like this and therefore I decided to work on extension support for de4dot. Basically it allows you to add new deobfuscator modules or **replace** the existing (sometimes outdated) ones, in a dynamic way.

In this blogpost I will explain to you how to add a simple deobfuscator for [OrangeHeap](http://orangeheap.blogspot.com). The actual deobfuscator code is not written by me, but by someone called [TheProxy](https://forum.tuts4you.com/topic/37122-de4dot-cryptophoenixreactororangeheap-fixed-by-ivancitooz/?p=174475). It only serves as an example of how de4dot can be extended :)

## Getting started

To get started, we need to set up our development environment. For this you need [Git](https://git-scm.com) and [Visual Studio](https://www.visualstudio.com). Follow these steps to get a development environment running:

1. Clone the repository with `git clone --recursive https://github.com/0xd4d/de4dot.git`;
2. Copy and rename the `deobfuscator.Template` directory to `deobfuscator.OrangeHeap`;
3. In that same directory, rename `deobfuscator.Template.csproj` to `deobfuscator.OrangeHeap.csproj`;
4. Open the main `de4dot.sln` in Visual Studio 2010 or higher and add `deobfuscator.OrangeHeap.csproj` to the solution;
5. Now the only thing left is to rename the output file name and namespace from `deobfuscator.Template` to `deobfuscator.OrangeHeap`.

## Coding the deobfuscator

In this post I won't go too much in depth about the internal de4dot architecture, mainly because I don't know a whole lot about it. You'd have to check the built-in deobfuscators by yourself to find out how it works. Here is a [post by kao](http://lifeinhex.com/string-decryption-with-de4dot) that explains extending de4dot in a more detailed manner.

The identifying class for a deobfuscator is the `DeobfuscatorInfo` class. It has to provide a `Name` and a `Type` string field, where the `Type` field must be unique. It also has a `CreateDeobfuscator` method that will handle the actual deobfuscation.

You can find the full code over [here](https://github.com/mrexodia/de4dot/tree/OrangeHeap) (again thanks to TheProxy for his code).

## Sharing the deobfuscator

Now before I go into this, I have to say that you are **obligated** by the license de4dot uses (GPL) to share any modifications you make to de4dot under the same (GPL) license. This includes extensions that are dynamically loaded by de4dot, although this is [controversial](http://www.gnu.org/licenses/gpl-faq.en.html#GPLAndPlugins).

Now to share the deobfuscator, for example for [internal company usage](http://www.gnu.org/licenses/gpl-faq.en.html#UnreleasedMods) or simply because you want to share prebuilt binaries of your GPL extension, simply copy the `bin/deobfuscator.OrangeHeap.dll` to the de4dot `bin` directory on another machine. Here is a screenshot that shows what happens before and after I added the DLL to the `bin` directory (obviously without any other modifications to de4dot):

![extensibility!](/images/de4dot_orangeheap.png)

## Overriding/Extending existing deobfuscators

If you want to change the behavior of an existing deobfuscator, simply make the `DeobfuscatorInfo.Type` field return an already-present typename (like `co` for CryptoDeobfuscator or `df` for Dotfuscator). Basically you have to rip the current deobfuscator class out in a separate project (I tested this). See [here](https://github.com/mrexodia/de4dot/blob/master/de4dot.code/deobfuscators/Dotfuscator/Deobfuscator.cs) for a starting point. It should be pretty straightforward.

Well, that's all for today. Hopefully till next time!

Mr. eXoDia