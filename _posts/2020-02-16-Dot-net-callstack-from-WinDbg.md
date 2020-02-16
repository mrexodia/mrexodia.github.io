---
layout: post
tagline: "It's surprisingly easy"
category: programming
tags : [dotnet, windbg, callstack]
---
{% include JB/setup %}

Recently I experienced a bug with [Git Extensions](https://gitextensions.github.io/) and I did not yet have [JitMagic](https://github.com/mrexodia/JitMagic) set up with [dnSpy](https://github.com/0xd4d/dnSpy) integration. I needed the callstack to report an issue to the developers.

I chose [WinDbg](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools) as the just-in-time debugger. And simply ran `!analyze -v`:

```
*******************************************************************************
*                                                                             *
*                        Exception Analysis                                   *
*                                                                             *
*******************************************************************************

DEBUG_FLR_EXCEPTION_CODE(80131509) and the ".exr -1" ExceptionCode(e0434352) don't match
MethodDesc:   00007ffc4ae31d70
Method Name:  System.Reactive.Concurrency.SynchronizationContextScheduler.Schedule[[System.ValueTuple`2[[System.__Canon, mscorlib],[System.__Canon, mscorlib]], System.ValueTuple]](System.ValueTuple`2<System.__Canon,System.__Canon>, System.Func`3<System.Reactive.Concurrency.IScheduler,System.ValueTuple`2<System.__Canon,System.__Canon>,System.IDisposable>)
Class:        00007ffc7f601a38
MethodTable:  00007ffc7fed5ba0
mdToken:      00000000060011ac
Module:       00007ffc7f3b1000
IsJitted:     yes
CodeAddr:     00007ffc4ad2e360
Transparency: Critical
GetUrlPageData2 (WinHttp) failed: 12007.

KEY_VALUES_STRING: 1

    Key  : CLR.System.InvalidOperationException._message
    Value: Invoke or BeginInvoke cannot be called on a control until the window handle has been created.


STACKHASH_ANALYSIS: 1

TIMELINE_ANALYSIS: 1

Timeline: !analyze.Start
    Name: <blank>
    Time: 2020-02-16T21:23:49.402Z
    Diff: 402 mSec

Timeline: Dump.Current
    Name: <blank>
    Time: 2020-02-16T21:23:49.0Z
    Diff: 0 mSec

Timeline: Process.Start
    Name: <blank>
    Time: 2020-02-16T21:17:54.0Z
    Diff: 355000 mSec

Timeline: OS.Boot
    Name: <blank>
    Time: 2020-02-16T13:48:23.0Z
    Diff: 27326000 mSec


DUMP_CLASS: 2

DUMP_QUALIFIER: 0

FAULTING_IP: 
KERNELBASE!RaiseException+68
00007ffc`b7e7908c 488b8c24c0000000 mov     rcx,qword ptr [rsp+0C0h]

EXCEPTION_RECORD:  (.exr -1)
ExceptionAddress: 00007ffcb7e7908c (KERNELBASE!RaiseException+0x0000000000000068)
   ExceptionCode: e0434352 (CLR exception)
  ExceptionFlags: 00000001
NumberParameters: 5
   Parameter[0]: ffffffff80131509
   Parameter[1]: 0000000000000000
   Parameter[2]: 0000000000000000
   Parameter[3]: 0000000000000000
   Parameter[4]: 00007ffcaa250000

FAULTING_THREAD:  000010d4

EXCEPTION_CODE: (HRESULT) 0x80131509 (2148734217) - <Unable to get error code text>

EXCEPTION_CODE_STR:  80131509

WATSON_BKT_PROCSTAMP:  5e1310a0

WATSON_BKT_PROCVER:  3.3.1.7897

PROCESS_VER_PRODUCT:  Git Extensions

WATSON_BKT_MODULE:  KERNELBASE.dll

WATSON_BKT_MODSTAMP:  5d26b6e9

WATSON_BKT_MODOFFSET:  908c

WATSON_BKT_MODVER:  6.3.9600.19425

MODULE_VER_PRODUCT:  Microsoft® Windows® Operating System

BUILD_VERSION_STRING:  9600.19629.amd64fre.winblue_ltsb_escrow.200127-1700

MODLIST_WITH_TSCHKSUM_HASH:  642958e44b66935a181d61b4c64e4bdbaa672d71

MODLIST_SHA1_HASH:  abdd8c7f6b6b349838b6e46c74e36108e0c55c11

NTGLOBALFLAG:  400

PROCESS_BAM_CURRENT_THROTTLED: 0

PROCESS_BAM_PREVIOUS_THROTTLED: 0

APPLICATION_VERIFIER_FLAGS:  0

PRODUCT_TYPE:  1

SUITE_MASK:  272

DUMP_TYPE:  fe

PROCESS_NAME:  unknown

MISSING_CLR_SYMBOL: 0

ANALYSIS_SESSION_HOST:  MYPC

ANALYSIS_SESSION_TIME:  02-16-2020 22:23:49.0402

ANALYSIS_VERSION: 10.0.17763.132 amd64fre

MANAGED_CODE: 1

MANAGED_ENGINE_MODULE:  clr

MANAGED_ANALYSIS_PROVIDER:  SOS

MANAGED_THREAD_ID: 10d4

MANAGED_EXCEPTION_ADDRESS: 3c4b0ff98

LAST_CONTROL_TRANSFER:  from 00007ffcaa26a451 to 00007ffcb7e7908c

THREAD_ATTRIBUTES: 
THREAD_SHA1_HASH_MOD_FUNC:  496307919b5c20eda4b6b1d7f8f57fe40ecc2624

THREAD_SHA1_HASH_MOD_FUNC_OFFSET:  27cfc7cdea8e40dd4dc3a7ebac53d16e2aeb6dac

OS_LOCALE:  NLD

BUGCHECK_STR:  CLR_EXCEPTION_System.InvalidOperationException

DEFAULT_BUCKET_ID:  CLR_EXCEPTION_System.InvalidOperationException

PRIMARY_PROBLEM_CLASS:  CLR_EXCEPTION

PROBLEM_CLASSES: 

    ID:     [0n254]
    Type:   [CLR_EXCEPTION]
    Class:  Primary
    Scope:  DEFAULT_BUCKET_ID (Failure Bucket ID prefix)
            BUCKET_ID
    Name:   Add
    Data:   Omit
    PID:    [Unspecified]
    TID:    [0x10d4]
    Frame:  [0] : KERNELBASE!RaiseException

    ID:     [0n252]
    Type:   [@ManagedObjectName]
    Class:  Addendum
    Scope:  DEFAULT_BUCKET_ID (Failure Bucket ID prefix)
            BUCKET_ID
    Name:   Omit
    Data:   Add
            String: [System.InvalidOperationException]
    PID:    [0x2f30]
    TID:    [Unspecified]
    Frame:  [0]

STACK_TEXT:  
00000003`dc8eec80 00007ffc`91ef1173 System_Windows_Forms_ni!System.Windows.Forms.Control.MarshaledInvoke+0x3d3
00000003`dc8eedc0 00007ffc`91ef0c72 System_Windows_Forms_ni!System.Windows.Forms.Control.BeginInvoke+0x62
00000003`dc8eee30 00007ffc`92972b71 System_Windows_Forms_ni!System.Windows.Forms.WindowsFormsSynchronizationContext.Post+0x51
00000003`dc8eee80 00007ffc`4ad2e47b System_Reactive_ni!System.Reactive.Concurrency.SynchronizationContextScheduler.Schedule[[System.ValueTuple_2[[System.__Canon,_mscorlib],[System.__Canon,_mscorlib]],_System.ValueTuple]]+0x11b
00000003`dc8eeef0 00007ffc`7fb379b4 System_Reactive_ni!System.Reactive.Concurrency.Scheduler.ScheduleAction[[System.__Canon,_mscorlib]]+0x154
00000003`dc8eef70 00007ffc`7fc56771 System_Reactive_ni!System.Reactive.Linq.ObservableImpl.EventProducer_2+Session+__c[[System.__Canon,_mscorlib],[System.__Canon,_mscorlib]]._Connect_b__5_0+0xf1
00000003`dc8eeff0 00007ffc`7fc623e2 System_Reactive_ni!System.Reactive.Disposables.AnonymousDisposable_1[[System.ValueTuple_3[[System.__Canon,_mscorlib],[System.__Canon,_mscorlib],[System.__Canon,_mscorlib]],_System.ValueTuple]].Dispose+0x82
00000003`dc8ef050 00007ffc`7fb3478e System_Reactive_ni!System.Reactive.Disposables.Disposable.TryDispose+0x5e
00000003`dc8ef090 00007ffc`7fc49314 System_Reactive_ni!System.Reactive.Linq.ObservableImpl.Throttle_1+_[[System.__Canon,_mscorlib]].Dispose+0x24
00000003`dc8ef0c0 00007ffc`7fb4797b System_Reactive_ni!System.Reactive.Sink_1[[System.__Canon,_mscorlib]].Dispose+0xab
00000003`dc8ef120 00007ffc`7fb3478e System_Reactive_ni!System.Reactive.Disposables.Disposable.TryDispose+0x5e
00000003`dc8ef160 00007ffc`7fb49003 System_Reactive_ni!System.Reactive.ObserveOnObserverNew_1[[System.__Canon,_mscorlib]].Dispose+0x23
00000003`dc8ef1a0 00007ffc`7fb4797b System_Reactive_ni!System.Reactive.Sink_1[[System.__Canon,_mscorlib]].Dispose+0xab
00000003`dc8ef200 00007ffc`81b9697b GitUI_ni!GitUI.CommitInfo.CommitInfoHeader.DisposeCustomResources+0x1b
00000003`dc8ef230 00007ffc`81aa6643 GitUI_ni!GitUI.GitModuleControl.Dispose+0x53
00000003`dc8ef270 00007ffc`a8233371 System_ni!System.ComponentModel.Component.Finalize+0x11


STACK_COMMAND:  !sos.pe 0x3c4b0ff98 ; ** Pseudo Context ** ManagedPseudo ** Value: 534961d8e0 ** ; kb

THREAD_SHA1_HASH_MOD:  15163896b4156cc0a0208a3b87e3d5d6d3923e94

FOLLOWUP_IP: 
System_Windows_Forms_ni+2c1173
00007ffc`91ef1173 90              nop

FAULT_INSTR_CODE:  1247e890

SYMBOL_STACK_INDEX:  0

SYMBOL_NAME:  System_Windows_Forms_ni!System.Windows.Forms.Control.MarshaledInvoke+2c1173

FOLLOWUP_NAME:  MachineOwner

MODULE_NAME: System_Windows_Forms

IMAGE_NAME:  System.Windows.Forms.dll

DEBUG_FLR_IMAGE_TIMESTAMP:  5d7a9e88

FAILURE_BUCKET_ID:  CLR_EXCEPTION_System.InvalidOperationException_80131509_System.Windows.Forms.dll!System.Windows.Forms.Control.MarshaledInvoke

BUCKET_ID:  CLR_EXCEPTION_System.InvalidOperationException_System_Windows_Forms_ni!System.Windows.Forms.Control.MarshaledInvoke+2c1173

FAILURE_EXCEPTION_CODE:  80131509

FAILURE_IMAGE_NAME:  System.Windows.Forms.dll

BUCKET_ID_IMAGE_STR:  System.Windows.Forms.dll

FAILURE_MODULE_NAME:  System_Windows_Forms

BUCKET_ID_MODULE_STR:  System_Windows_Forms

FAILURE_FUNCTION_NAME:  System.Windows.Forms.Control.MarshaledInvoke

BUCKET_ID_FUNCTION_STR:  System.Windows.Forms.Control.MarshaledInvoke

BUCKET_ID_OFFSET:  2c1173

BUCKET_ID_MODPRIVATE: 1

BUCKET_ID_MODTIMEDATESTAMP:  5d7a9e88

BUCKET_ID_MODCHECKSUM:  0

BUCKET_ID_MODVER_STR:  4.8.4042.0

BUCKET_ID_PREFIX_STR:  CLR_EXCEPTION_System.InvalidOperationException_

FAILURE_PROBLEM_CLASS:  CLR_EXCEPTION

FAILURE_SYMBOL_NAME:  System.Windows.Forms.dll!System.Windows.Forms.Control.MarshaledInvoke

WATSON_STAGEONE_URL:  http://watson.microsoft.com/StageOne/unknown/3.3.1.7897/5e1310a0/KERNELBASE.dll/6.3.9600.19425/5d26b6e9/80131509/0000908c.htm?Retriage=1

TARGET_TIME:  2020-02-16T21:23:56.000Z

OSBUILD:  9600

OSSERVICEPACK:  19538

SERVICEPACK_NUMBER: 0

OS_REVISION: 0

OSPLATFORM_TYPE:  x64

OSNAME:  Windows 8.1

OSEDITION:  Windows 8.1 WinNt SingleUserTS

USER_LCID:  0

OSBUILD_TIMESTAMP:  2019-10-15 05:45:31

BUILDDATESTAMP_STR:  200127-1700

BUILDLAB_STR:  winblue_ltsb_escrow

BUILDOSVER_STR:  6.3.9600.19629.amd64fre.winblue_ltsb_escrow.200127-1700

ANALYSIS_SESSION_ELAPSED_TIME:  1dab

ANALYSIS_SOURCE:  UM

FAILURE_ID_HASH_STRING:  um:clr_exception_system.invalidoperationexception_80131509_system.windows.forms.dll!system.windows.forms.control.marshaledinvoke

FAILURE_ID_HASH:  {c279e3a4-dab2-09ec-a135-2281bfa61101}

Followup:     MachineOwner
---------

```

Everything was magically analyzed and I was able to [open an issue](https://github.com/gitextensions/gitextensions/issues/7748). As an added bonus I recently worked to allowing dnSpy to be used as a JIT debugger from JitMagic:

![dnSpy JIT](https://i.imgur.com/RIFsOeS.png)

Best regards,

Duncan