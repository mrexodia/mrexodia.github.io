---
layout: post
tagline: "Sweet, clicky fun"
category: reversing
tags : [reversing, keyboard, arm]
---
{% include JB/setup %}

Recently I bought a cheap [SPC Gear GK530](https://spcgear.com/en/products/gk530-tournament-kailh-brown-rgb-2/) mechanical keyboard to test out the Kailh Brown keyswitches. Overall it has a nice feel and you can change the epic RGB-lights to just be a dimmed constant color so I would recommend it for typing.

Unfortunately the macro/rebind feature is not very much to my liking. Right now you have to switch to *Gaming mode* (`FN+Win`) and then you can use use your modified keymap (with macros). In this mode you cannot use the Windows key (because it is locked) and it is generally quite awkward.

My preferred mode would be that holding `Caps Lock` enables my custom layer, which unfortunately does not seem to be supported. At this point I thought it would be a fun project to try and hack the firmware to support this behavior.

![keyboard](https://i.imgur.com/WqaAxFi.png)

## Obtaining the firmware

Luckily for us SPC Gear provides two firmware update utilities on their [Software page](https://spcgear.com/en/support/software/). The utility is called `1 - GK530 keyboard upgrade.exe` and when I started it I was reminded of a similar utility I took at look at in the past.

![firmware upgrade](https://i.imgur.com/yBzOPfh.png)

The similar utility was a firmware upgrade tool for my current keyboard:

![similar utility](https://i.imgur.com/f46qDKx.png)

When looking at a firmware upgrade tool in the past [I documented it](https://github.com/lentinj/tp-compact-keyboard/issues/32#issuecomment-376147869) on a Github issue. From a quick glance it appears that nothing has changed, except that the firmware is no longer 'encypted' now and the UI looks a bit more fancy.

To obtain the image:

- Extract the `"BINARY"` resource (170). You can use [CFF Explorer](https://ntcore.com/?page_id=388) for this task.
- The extracted blob is an executable with no functionality, which has an 'overlay' appended to it (data after the end of the last section).
- The overlay is the firmware image (65k) with some additional metadata at the end.

![metadata](https://i.imgur.com/KrLcUVi.png)

The interesting string there is at the very end, which says `SN32F24x` (all SONiX chips seem to start with SN). With a bit of Google-fu and creativity you can land on the product page for the [SN32F248](http://www.sonix.com.tw/article-en-998-21395). Over there you can also find a bunch of links to utilities and manuals, one of which is called `SONiX_USB_MCU_ISP_Tool_V2.3.1.7.7z`. Opening the extracted firmware yields a good result:

![original flash tool](https://i.imgur.com/wS9TGdp.png)

Additionally there is also a data sheet available to the public (`SN32F248_V2.0_EN.pdf`), which should help progressing further. Initial information I gathered is that the chip is based on an ARM Cortex-M0.

## Next steps

My next idea of progression is to try and set up the same tooling as someone developing hardware with this chip would. Get a C compiler and actually build a ROM of our own, to have a point of reference when starting reverse engineering. I do not have any experience looking at ARM code and not much experience with embedded software, so anything to aid my understanding in that area will be good.

Hopefully till next time,

Duncan

Thanks to F for the proofread!