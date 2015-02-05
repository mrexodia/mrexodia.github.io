---
layout: post
tagline: "Some things about the Windows kernel..."
category: reversing
tags : [debugger, detection, hiding, code, windows, kernel, ssdt, hooks, rootkit, patchguard]
---
{% include JB/setup %}

Hello,

First of all I would like to thank to ~200 people (or bots) who still visit this blog! I didn't post for a long time (again) because I was busy with a project for the university. Right now I had my exams, so I will have a little time to write a new blogpost.

## Introduction

Some people might remember a project I started about a year ago. This project is called [TitanHide](https://bitbucket.org/mrexodia/titanhide) and it was created to make kernel-mode debugger hiding possible on the x64 versions of Windows. At the time there was no kernel-mode hiding driver that worked on the x64 versions of Windows and that was also open-source. Trusting kernel drivers is really important (especially when they install hooks) because they can do anything with your system they like. TitanHide was meant to be easy to extend and it should work on both x32 and x64 systems.

## Debug Detection

Software protection or malware usually doesn't like being debugged. For this reason they usually insert various debugger checks. There are lots and lots of anti-debug tricks, see [this paper](http://pferrie.host22.com/papers/antidebug.pdf) for example. Some tricks like `IsDebuggerPresent` or `NtGlobalFlag` can be bypassed by changing the [PEB](http://undocumented.ntinternals.net/source/usermode/undocumented%20functions/nt%20objects/process/peb.html) in memory of the usermode process. Other detection methods cannot be evaded by a simple memory patch (`NtClose` for example). These detection methods require hooks. Hooks in user-mode (such as done by [ScyllaHide](https://bitbucket.org/NtQuery/scyllahide)) work in most cases, but more advanced debugger detection systems also detect user-mode hooks. In this case there is need for kernel-mode hooks, which is what TitanHide is using to evade debug detection methods. TitanHide does **not** patch the PEB or other things that can be done in user-mode, it's focus lays purely in kernel-mode.

## PatchGuard

In x32 times patching the kernel was officially unsupported by Microsoft, but there were no countermeasures built into the operating system against it. When Windows x64 came along, Microsoft added [Kernel Patch Protection](http://bit.ly/1zBtSV0), also referred to as 'PatchGuard'. PatchGuard prevents modification of critical kernel structures, such as the SSDT, which TitanHide uses to hook kernel functions. There are various methods of disabling PatchGuard, but TitanHide does not implement any of those. The main reason behind this is that TitanHide is purely meant to bypass debugger checks, not as a full-fledged rootkit library. If you want a quick way to disable PatchGuard, simply enable debug mode on your computer. This effectively stops PatchGuard from loading. If you want more information about PatchGuard I recommend reading [this article](http://www.leviathansecurity.com/wp-content/uploads/uninformed_v3a3.pdf). Everything that happens after this point is with PatchGuard enabled.

## TitanHide

This post will mainly be about TitanHide installs it's hooks. If you want more information about how the functions are modified to make it look like certain processes are not being debugged, you should read the [code](https://bitbucket.org/mrexodia/titanhide/src/master/TitanHide/hooks.cpp). I also recommend reading [this paper](https://bitbucket.org/NtQuery/scyllahide/downloads/ScyllaHide.pdf) about ScyllaHide. It can help while reading the TitanHide code (since the code itself is not greatly documented).

*Many ideas in TitanHide come from different people around the internet, but the code in TitanHide is mostly written by myself. Code I used from the internet usually has a comment explaining where it came from. Some code was also written by cypherpunk. You can see which code specifically in the commit log.*

## SSDT Hooking

In short the System Service Dispatch Table (SSDT) is used by the operating system to determine which function to call after a transition from user to kernel-mode. The table contains kernel-mode function pointers and when a user-mode program wants to call such a function it provides an index to the function it wants to call in EAX. SSDT Hooking means replacing these kernel-mode function pointers with custom functions that either fully replace the existing function or modify the function behavior.

In x32 mode, replacing SSDT functions is quite straightforward (see [this article](http://resources.infosecinstitute.com/hooking-system-service-dispatch-table-ssdt) for more information). Basically what happens is this:

```
SSDTStruct* SSDT = MmGetSystemRoutineAddress(L"KeServiceDescriptorTable");
SSDT->pServiceTable[FunctionIndex] = NewFunctionPointer;
```

On x32 versions of the operating system the SSDT structure is exported under the name `KeServiceDescriptorTable` by `ntoskrnl.exe`, which makes SSDT hooks really easy to implement.

On x64 versions of the operating system SSDT hooking becomes much harder. There are two reasons for this. The first reason is that the SSDT is no longer exported by `ntoskrnl.exe`, which means TitanHide must use different ways to find the SSDT. The other reason is that the SSDT no longer uses direct pointers, but offsets relative to the start of the SSDT. This means our hooks cannot be located too far from the `ntoskrnl` memory region.

#### Locating the SSDT on x64

After lots of searching around I found someone who discovered a semi-reliable way of locating the SSDT on x64 (I tested this method on Windows XP x64 - Windows 8.1 x64 with success). Read the original post [here](https://code.google.com/p/volatility/issues/detail?id=189#c2). For the purpose of this post I will line out the basics here, supported with some code.

An exported function called `KeAddSystemServiceTable` has a reference to the RVA of the SSDT. To find this RVA, TitanHide uses the following code:

```
/*
000000014050EA4A 48 C1 E0 05                shl rax, 5
000000014050EA4E 48 83 BC 18 80 3A 36 00 00 cmp qword ptr [rax+rbx+363A80h], 0 <- we are looking for this instruction
000000014050EA57 0F 85 B2 5C 0A 00          jnz loc_1405B470F
000000014050EA5D 48 8D 8B C0 3A 36 00       lea rcx, rva KeServiceDescriptorTableShadow[rbx]
000000014050EA64 48 03 C8                   add rcx, rax
000000014050EA67 48 83 39 00                cmp qword ptr [rcx], 0
*/
unsigned int rvaSSDT = 0;
for (unsigned int i = 0; i < function_size; i++)
{
    if (((*(unsigned int*)(function + i)) & 0x00FFFFF0) == 0xBC8340 && //4?83bc??
        !*(unsigned char*)(function + i + 8)) //???????? 00 
    { //cmp qword ptr [r?+r?+????????h], 0
        rvaSSDT = *(unsigned int*)(function + i + 4);
        break;
    }
}
```

#### Hooking the SSDT on x64

In order to make sure the new function pointers 'fit' into the SSDT, I created a function called `FindCaveAddress`. That looks for compiler-generated padding, usually found around functions. It searched for a certain number of padding bytes and when found, a hook stub like this is inserted:

```
mov rax, NewFunctionPointer
push rax
ret
```

These stubs redirect the instruction pointer to our hooked function, making things really easy.

## SSDT Function Index

Every function in the SSDT has an index, there are websites such as [this one](http://j00ru.vexillium.org/ntapi_64) that list the all Nt* functions and their index, but hardcoding everything for every possible OS is tedious and error-prone work so I wrote a function to heuristically find an SSDT index for an exported `ntdll.dll` function. What is does is reading `ntdll.dll` from disk and then it parses the export table, searching for a function. If the function was found it looks for `mov eax, XXXXXXXX`, where `XXXXXXXX` will be the SSDT index. This is based on the fact that the `ntdll.dll` stubs look pretty much the same on every version of `ntdll.dll` until Windows 8.1:

```
0000000077EF0E10 | 4C 8B D1       | mov r10,rcx
0000000077EF0E13 | B8 40 00 00 00 | mov eax,40
0000000077EF0E18 | 0F 05          | syscall
0000000077EF0E1A | C3             | ret
```

If you are interested in the specifics of this code, take a look at [ntdll.cpp](https://bitbucket.org/mrexodia/titanhide/src/master/TitanHide/ntdll.cpp).

This is how you hook a function exported by `ntdll.dll` using the current TitanHide codebase:

```
HOOK hNtQueryInformationProcess = SSDT::Hook("NtQueryInformationProcess", (void*)HookNtQueryInformationProcess);
```

That's right, only one line of code to do any SSDT hook you want!

## Conclusion

I hope you found this blogpost interesting, if you have any remarks, feel free to post them in the comments or send them to me.