---
layout: post
tagline: "Abstractions to achieve greatness..."
category: x64dbg
tags : [x64dbg, coding, C++, lambdas, Qt]
---
{% include JB/setup %}

Hello folks,

While on the plane back home I decided to write another little blog post. This time I will be showing you a nice class I came up with for [x64dbg](http://x64dbg.com) to manage menu items.

## The problem

As with every abstraction it starts with a problem you are trying to solve. In this case the problem was code duplication and general tediousness with the construction of the context (right click) menus in x64dbg.

The general idea of Qt is great. From my understanding, every context menu is a `QMenu` with a bunch of `QAction` or other `QMenu` items in it. When a user right-clicks in the widget a *signal* will be emitted and the widget can *connect* to the *signal*, construct the `QMenu` and 'execute' the menu on the mouse position. Each `QAction` has a *signal* called `triggered()` which you can *connect* to a slot in your widget to handle the click event.

If there is no variation in the menu everything works perfectly fine. You just create all the actions, menus and connections in the constructor and store the final `QMenu` item in the class. Then when you need the menu you do `mMenu->exec(position)` and you are done with it.

In x64dbg the menus are based on the **context**, so the static approach doesn't work. What we did was create and connect all the `QAction` items in the constructor and then dynamically create the menu. What this did was create a lot of fragmentation. All the actions had to be declared in the header, the slots for the actions had to be declared in the header and the source and adding a new action would result in a lot of code that looked exactly like this:

```
mFollowAddress = new QAction("&Follow in Disassembler", this);
connect(mFollowAddress, SIGNAL(triggered()), this, SLOT(followAddress()));
```

For actions with a shortcut and an icon it was even worse:

```
mToggleBreakpoint = new QAction("Toggle Breakpoint", this);
mToggleBreakpoint->setShortcutContext(Qt::WidgetShortcut);
mToggleBreakpoint->setIcon(QIcon(":/images/icons/breakpoint.png"));
addAction(mToggleBreakpoint);
connect(mToggleBreakpoint, SIGNAL(triggered()), this, SLOT(toggleBreakpoint()));
```

Shortcuts also require setting the actual shortcut in a dedicated slot called `refreshShortcutsSlot()` which is connected to the settings dialog so shortcuts are updated when the user updates the settings:

```
void ReferenceView::refreshShortcutsSlot()
{
    mToggleBreakpoint->setShortcut(ConfigShortcut("ActionToggleBreakpoint"));
    mToggleBookmark->setShortcut(ConfigShortcut("ActionToggleBookmark"));
}
```

Finally the menu is created in `contextMenuEvent` like this:

```
if(!DbgMemIsValidReadPtr(addr))
        return;
wMenu->addAction(mFollowAddress);
wMenu->addAction(mFollowDumpAddress);
if(apiAddressFromString(mCurList->getCellContent(mCurList->getInitialSelection(), 1)))
    wMenu->addAction(mFollowApiAddress);
wMenu->addSeparator();
wMenu->addAction(mToggleBreakpoint);
wMenu->addAction(mToggleBookmark);
```

As you can imagine, adding an action with an icon, a shortcut and some context-dependent behaviour was a very tedious process and this needed to change.

## MenuBuilder

Part of the solution is a `MenuBuilder` class. This is a recursive datatype (like `QMenu`) but it lazily builds the menu, which allows for proper context-awareness.

To achieve context-awareness, each `QAction/QMenu/MenuBuilder` you add to a `MenuBuilder` is paired with an `std::function`. If the callback returns true, the item is added to the final `QMenu`, otherwise it is ommitted. This allows for constructs like this:

```
mBuilder->addAction(followAction, [this](QMenu* menu)
{ //only add followAction if the selected address is readable.
    return DbgMemIsValidReadPtr(this->selectedAddress());
});
```

The `followAction` will only be added to the final `QMenu` if the currently selected address is a valid memory address. This is a huge save in code, the menu creation slot can be replaced with:

```
QMenu menu;
mBuilder->build(&menu);
menu.exec(pos);
```

There are some extra features (like using the `menu` parameter of the lambda to add extra actions to the final `QMenu`, but if you want more details, read the code [here](https://github.com/x64dbg/x64dbg/blob/bc9c05537fa7d64ed440a40099beb2a2c2e407a0/src/gui/Src/Utils/MenuBuilder.h).

## Actions

The next problem to solve is the creation of the `QAction` and `QMenu` items. The solution was to create a few simple helper methods in the base class (`AbstractTableView`):

```
template<typename T>inline QAction* makeAction(const QString & text, T slot){    return connectAction(new QAction(text, this), slot);}

inline QAction* connectAction(QAction* action, const char* slot){    connect(action, SIGNAL(triggered(bool)), this, slot);    return action;}inline QAction* connectAction(QAction* action, QActionLambda::TriggerCallback callback){    auto lambda = new QActionLambda(action->parent(), callback);    connect(action, SIGNAL(triggered(bool)), lambda, SLOT(triggeredSlot()));    return action;}
```

The `makeAction` uses a template because I added lambda support to the actions. This is not in Qt 4 and rather simple to implemented so I decided to add it:

```
class QActionLambda : public QObject{    Q_OBJECTpublic:    typedef std::function<void()> TriggerCallback;    QActionLambda(QObject* parent, TriggerCallback callback)        : QObject(parent),          _callback(callback)    {    }public slots:    void triggeredSlot()    {        if(_callback)            _callback();    }private:    TriggerCallback _callback;};
```

Now to create an action you'd write:

```
makeAction("Selection (&No Bytes)", SLOT(copySelectionNoBytesSlot()))
```

And similarly an action with shortcut and icon:

```
makeShortcutAction(QIcon(":/icons/images/highlight.png"), "&Highlighting mode", SLOT(enableHighlightingModeSlot()), "ActionHighlightingMode")
```

## Final words

I guess that's about it for this blog post. If you want to see what the final menu creation code looks like, check out the code [here](https://github.com/x64dbg/x64dbg/blob/bc9c05537fa7d64ed440a40099beb2a2c2e407a0/src/gui/Src/Gui/CPUDisassembly.cpp#L187). For reference, the old code is available [here](https://github.com/x64dbg/x64dbg/blob/63ed769b6768323aebbc3042307213721abb24a8/src/gui/Src/Gui/CPUDisassembly.cpp#L170), as you can tell it is a great improvement.

Finally, I know reader interaction has been practically non-existent on this blog so far, however it would be nice if you could send me parts of x64dbg you'd like to get insight in development-wise. Any other topics (reversing/programming) related are also welcome!

Greetings,

Duncan