---
layout: post
tagline: "We all eat RAM when our disks are full..."
category: coding
tags : [Windows, InnoSetup, unarc, dll, FreeArcExtract, FreeArc]
---
{% include JB/setup %}

In my free time I work on lots of small projects. One of those is called [DarkSouls3.TextViewer](https://github.com/mrexodia/DarkSouls3.TextViewer) and it lets you view all dialogue and item descriptions in [Dark Souls 3](https://www.darksouls3.com):

![DarkSouls3.TextViewer](https://i.imgur.com/E0XuU2Y.png)

To do this you have to extract the contents of `Data1.bdt`, which can be done with [BinderTool](https://github.com/Atvaark/BinderTool) by Atvaark. However, recently I got interested in possible changes made to item descriptions during updates, so I went on a hunt for all versions of `Data1.bdt`. Because Steam does not allow you to downgrade the game versions I started looking for pirated releases and updates to try to piece everything together. I downloaded `Dark.Souls.III.The.Ringed.City-CODEX` to get started, but then I noticed that I was too low on disk space to install the game...

## InnoSetup

A quick look at `setup.exe` with [ProtectionID](https://pid.gamecopyworld.com) reveals that it is an InnoSetup installer:

![inno setup](https://i.imgur.com/pYTIYHJ.png)

There are several free tools available ([innoextract](http://constexpr.org/innoextract), [innounp](http://innounp.sourceforge.net)) to see what's inside:

```
>innoextract.exe -l e:\setup.exe
Listing "Dark Souls III The Ringed City" - setup data version 5.5.0.1 (unicode)
 - "tmp\ISDone.dll" [temp] (446 KiB)
 - "tmp\english.ini" [temp] (15.4 KiB)
 - "tmp\Style.vsf" [temp] (44.7 KiB)
 - "tmp\VclStylesinno.dll" [temp] (1.95 MiB)
 - "tmp\BASS.dll" [temp] (107 KiB)
 - "tmp\bp.dll" [temp] (129 KiB)
 - "tmp\wintb.dll" [temp] (27.5 KiB)
 - "tmp\Music.ogg" [temp] (2.34 MiB)
 - "tmp\Play1.bmp" [temp] (540 B)
 - "tmp\Play2.bmp" [temp] (540 B)
 - "tmp\Play3.bmp" [temp] (540 B)
 - "tmp\Pause1.bmp" [temp] (540 B)
 - "tmp\Pause2.bmp" [temp] (540 B)
 - "tmp\Pause3.bmp" [temp] (540 B)
 - "tmp\trackBkg.bmp" [temp] (776 B)
 - "tmp\trackbtn1.bmp" [temp] (344 B)
 - "tmp\trackbtn2.bmp" [temp] (344 B)
 - "tmp\trackbtn3.bmp" [temp] (344 B)
 - "tmp\unarc.dll" [temp] (368 KiB)
Warning: "setup-1.bin" is not part of the installer!
Use the --gog option to try listing the contents of this file.
Done with 1 warning.
```

The `setup-1.bin` file starts with `ArC`, so I checked the exports of `unarc.dll` and one that stands out is called `FreeArcExtract`, which points to [FreeArc](https://en.wikipedia.org/wiki/FreeArc).

I tried to list the files in the archive, but the file format appears to be customized (or an older version):

```
>unarc l e:\setup-1.bin
FreeArc 0.67 unpacker
ERROR: archive structure corrupted (descriptor failed CRC check)
```

## FreeArc

Then I thought, perhaps I can use `unarc.dll` from the setup to extract the relevant files? The lead is the name of the export `FreeArcExtract`. A bit of Googlefoo pointed to the [relevant code](https://github.com/svn2github/freearc/blob/298ae5fece821c4a187f782df034bbd9e029688f/Unarc/unarcdll.cpp#L142), which looks like this:

```c++
int __cdecl FreeArcExtract (cbtype *callback, ...)
{
  va_list argptr;
  va_start(argptr, callback);

  int argc=0;
  char *argv[1000] = {"c:\\unarc.dll"};  //// Здесь будет искаться arc.ini!

  for (int i=1; i<1000; i++)
  {
    argc = i;
    argv[i] = va_arg(argptr, char*);
    if (argv[i]==NULL || argv[i][0]==0)
      {argv[i]=NULL; break;}
  }
  va_end(argptr);

  COMMAND command (argc, argv);    // Распарсить команду
  if (command.ok) {                // Если парсинг был удачен и можно выполнить команду
    command.Prepare();
    CThread thread;
    DLLUI *ui = new DLLUI(&command);
    thread.Create (timer_thread,      ui);   //   Спец. тред, вызывающий callback 100 раз в секунду
    thread.Create (decompress_thread, ui);   //   Выполнить разобранную команду

    for(;;)
    {
      ui->DoEvent.Lock();
      if (strequ (ui->what, "quit"))
        return ui->n1;  // error code of command
      ui->result = callback (ui->what, ui->n1, ui->n2, ui->str);
      ui->EventDone.Signal();
    }
    thread.Wait();
  }
  return command.ok? FREEARC_OK : FREEARC_ERRCODE_GENERAL;
}
```

Basically what this does is forward all the input parameters as the `argv` of `unarc`. After a _lot_ of fooling around with the awfulness of `va_list` and lots of crashes I finally got the code to forward `argv` to the `FreeArcExtract` function:

```c++
#include <windows.h>
#include <cstdio>

#define whut(x) (strcmp(what, #x) == 0)

static int __stdcall cbExtract(char* what, int int1, int int2, char* str)
{
    if(whut(read) || whut(write))
        return 0; //filter out the plentiful "read" and "write" messages
    printf("\"%s\", %d, %d, \"%s\"\n", what, int1, int2, str);
    return 0;
}

typedef int __stdcall cbtype(char* what, int int1, int int2, char* str);
typedef int __cdecl pFreeArcExtract(cbtype* callback, ...);

int main(int argc, char* argv[])
{
    auto hMod = LoadLibraryA("unarc.dll");
    if(!hMod)
    {
        puts("Failed to load DLL: unarc.dll!");
        return 1;
    }
    auto FreeArcExtract = (pFreeArcExtract*)GetProcAddress(hMod, "FreeArcExtract");
    if(!FreeArcExtract)
    {
        puts("Failed to find export: FreeArcExtract");
        return 1;
    }
    auto a = [&](int i)
    {
        return i < argc ? argv[i] : "";
    };
    return FreeArcExtract(cbExtract, a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), a(9), a(10), nullptr);
}
```

First I tried to get the help with `unarc_cmd.exe`, but this came up empty. Instead I asked `unarc.exe`:

```
>unarc
FreeArc 0.67 unpacker  http://freearc.org  2014-03-16
Usage: unarc command [options] archive[.arc] [filenames...]
Available commands:
  l - display archive listing
  v - display verbose archive listing
  e - extract files into current directory
  x - extract files with pathnames
  t - test archive integrity
... (more irrelevant options)
```

Then I tried to list all the files in the archive, which did not give me the output I expected at all (but hey, at least no CRC errors):

```
>unarc_cmd.exe l e:\setup-1.bin
"total_files", 283, 0, ""
"origsize", 25527, 998151285, ""
"compsize", 25096, 545797223, ""
```

The `v` option also came up empty, but the `t` option had more promise:

```
>unarc_cmd t e:\setup-1.bin
"total", 25096, 545800879, ""
"filename", 0, 810208, "Game\Data0.bdt"
"filename", 922, 967053390, "Game\Data1.bdt"
"filename", 2450, -1724920912, "Game\Data2.bdt"
... (it takes a few minutes to test all files)
```

To extract `Data1.bdt`, BinderTool also needs a file with decryption keys called `Data1.bhd`, so I used the following command to extract both those files:

```
>unarc_cmd x e:\setup-1.bin Data1.bdt Data1.bhd
"total", 25096, 545800879, ""
"filename", 0, 810208, "Game\Data0.bdt"
"overwrite?", 922, 967053390, "Game\Data1.bdt"
"filename", 922, 967053390, "Game\Data1.bdt"
"filename", 2450, -1724920912, "Game\Data2.bdt"
"filename", 1474, 1546563828, "Game\Data3.bdt"
"filename", 1172, 1229026224, "Game\Data4.bdt"
"filename", 13172, 927431435, "Game\Data5.bdt"
"filename", 1551, 1626443628, "Game\DLC1.bdt"
"filename", 2929, -1222753793, "Game\DLC2.bdt"
"filename", 0, 2212, "Game\Data0.bhd"
"filename", 0, 411904, "Game\Data1.bhd"
```

## Conclusion

Well, I hope this was interesting to some people. It was just a 45 minute side project of mine that I decided to share.

If anyone has `魔法うんちく_dlc2.fmg` from before the description of the White Birch Bow was changed, please ping me (the `CODEX` release is from after the update apparently).