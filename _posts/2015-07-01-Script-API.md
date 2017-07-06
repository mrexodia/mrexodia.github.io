---
layout: post
tagline: "A small update once again"
category: coding
tags : [x64dbg, coding, script]
---
{% include JB/setup %}

Hey everyone,

**For the people who keep checking this blog: thanks a lot!**

Recently I had quite a lot of deadlines, so as usual I didn't write anything on my blog :) I did however work on quite some interesting things. Together with the guys on [#x64dbg](http://webchat.freenode.net/?channels=x64dbg) and some other people I worked on a script API for x64dbg. What this means is that (once this API is finished) people can write bindings for their favorite script language and publish it as a plugin!

Right now I have these implemented:

- Basic debugging stuff (run, step, stop, pause);
- Register setters/getters;
- Memory read/write;
- Pattern finding/writing;
- Module information;
- GUI selection setters/getters.

I plan on adding much more:

- PE information;
- Breakpoint management;
- Comment/Bookmark/Label/Function/Loop management (useful for analysis scripts);
- Settings;
- Event callbacks;
- Etc (contact me if you have requests).

Some work was done with [AngelScript](http://www.angelcode.com/angelscript) in the [testplugin](https://github.com/x64dbg/testplugin).

```
void myStepOut()
{
    duint cip = Register::GetCIP();
    Print("[SCRIPT] Started on CIP = 0x%p\n", cip);
    do
    {
        Debug::StepOver();
        cip = Register::GetCIP();
    }
    while(Memory::ReadByte(cip) != 0xC3);
    Print("[SCRIPT] Finished on CIP = 0x%p\n", cip);
}

void main()
{
    Print("[SCRIPT] Welcome to AngelScript!\n");
    myStepOut();
}
```

Another idea I had was to load script DLLS, so you can write scripts in your favorite programming language (basically any language that supports native exports). You would write a single export `StartScript` that then calls the script API directly. This would allow for many possibilities, including commercial unpacking scripts.

This summer I will try to work on x64dbg as much as I can, to at least complete the script API. I also plan on fixing performance problems and solving as many issues as I can. Contact me if you know C++ and like to work on x64dbg. All help is appreciated.

Till next time,

mrexodia
