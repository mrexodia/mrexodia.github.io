---
layout: post
tagline: "Analyzing absolutely nothing"
category: reversing
tags : [reversing, keyboard, arm]
---
{% include JB/setup %}

In the [first post](/reversing/2019/09/28/Analyzing-keyboard-firmware-part-1) I briefly discussed my motivation to analyze the keyboard's firmware and I did make a small amount of progress since last time (thanks to [/u/thoquz](https://www.reddit.com/user/thoquz/) who suggested to try [SVD Loader](https://leveldown.de/blog/svd-loader/)), but unfortunately other projects required my attention and I didn't think there was enough (interesting) progress to report. However I did make significant progress towards solving my actual problem (a caps lock macro layer), so I decided to share that here as well!

## The macro layer

The solution I came up with is based on [AutoHotkey](https://www.autohotkey.com/), which I heard about but never actually used myself before. For those not familiar, AutoHotkey allows you to create system-wide hotkeys in a custom scripting language. It is a bit weird, but it can apparently do [crazy things](https://www.autohotkey.com/docs/scripts/), so why not give it a try?

After a while of thinking and experimenting I came up with the following key map (thanks to [Keyboard Layout Editor](http://www.keyboard-layout-editor.com/). Green is the macro layer, the rest is just for reference:

![macro layer](https://i.imgur.com/i66YAW2.png)

Initially I just had the arrows + home/end, but while doing some actual programming work I came up with a bunch of other useful things. For example `Caps+G(it)` is bound to `F13`, which I linked in Visual Studio to start my [GitExtBar](https://github.com/mrexodia/FunUtils#gitextbar) utility:

![GitExtBar](https://i.imgur.com/pmFrNBu.png)

Similarly I bound `Caps+E(xplore)` to my DirBrowser utility in Visual Studio, which allows me to quickly open the project's output directory in [Total Commander](https://www.ghisler.com/) or a command prompt:

![DirBrowser](https://i.imgur.com/iN1KrQM.png)

A bunch of C++ related symbols are also bound to this layer, so I can keep holding caps lock when closing an `if`-block. I also bound `Caps+S/D` to scroll the mouse wheel, something I always appreciate in my browser with [Saka Key](https://key.saka.io/docs/about/introduction). Finally `Alt` is also used for quickly navigating. For Left/Right it acts as `Ctrl` (meaning `Caps+Alt+J` maps to `Ctrl+Left`), for Home/End it acts as `Shift` (meaning `Caps+Alt+U` maps to `Shift+Home`).

If you are interested you can find a snapshot of `capslayer.ahk` [here](https://gist.github.com/mrexodia/efe08d2ea563f82750db328b7a77b76c). I set up a cloud sync service and a hotkey to quickly reload the script to make sure things work the same across my various computers. Additionally I run the script as Administrator on login to make sure it is always available everywhere.

## Beating old habits

Even though my macro layer was working perfectly I still found myself using the arrows and home/end keys over the macro keys all the time. Because I think the macro layer will be a more economic way of typing in the long run I decided to completely disable the original keys (which thankfully is super easy with AutoHotkey). This was quite a pain for a few days at work, but I can now (proudly?) say that I am typing utter garbage on other machines.

Generally I noticed that when it comes to forming habits on your computer, you should always use that same computer to simply enforce what you want to learn and punish old habits. Want to take more breaks? Simply configure [Workrave](http://www.workrave.org/) to **not allow you to continue** and block all inputs. Want to get yourself in the habit of using Total Commander (which, frankly, you should if you value your time as a professional using Windows), use AutoHotkey to redirect `Win+E` to start Total Commander. Want to browse social media less? Use [StayFocusd](http://www.stayfocusd.com/).

## The future

If time permits and interest comes back I will definitely continue analyzing the keyboard firmware, because I did learn a lot from the short amount of time I spent on it so far. However, for my daily needs I will keep fine-tuning this AutoHotkey-based solution because it is so much easier. I did already find [Karabiner-Elements](https://pqrs.org/osx/karabiner/) for macOS, which should allow similar things, so I will play with that a bit before my trip next month.

Please let me know if you have any questions or suggestions with regards to my workflow and have a good week!

Duncan