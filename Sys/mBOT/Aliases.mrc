; ******************************************************
;                 DC mBOT - Aliases
; ******************************************************
;kick { }
;ban { }
cs { .msg ChanServ $$1- }
ns { .msg NickServ $$1- }
ms { .msg MemoServ $$1- }
bs { .msg BotServ $$1- }
os { .msg OperServ $$1- }
j { join #$$1- }
n { notice $$1- }
q { query $$1- }
p { part $chan $$1- }
w { whois $$1 $$1 }
pingme { ctcp $me ping }
ping { ctcp $$1 ping }
opme { ChanServ op $chan $me }
deopme { mode $chan -o $me }
owner { ChanServ Owner $chan }
deowner { ChanServ DeOwner $chan }
info { ChanServ info $chan }
infoall { ChanServ info $chan all }
cop { ChanServ op $chan $iif($1 != $null, $v1, $me) }
cdeop { ChanServ deop $chan $$1- }
op { mode $chan +oooooo $$1- }
deop { mode $chan -oooooo $$1- }
v { mode $chan +vvvvvv $1- }
voice { ChanServ voice $chan $$1- }
dv { mode $chan -vvvvvv $$1- }
devoice { ChanServ devoice $chan $$1- }
deopvoice { mode $chan -o+v-o+v-o+v-o+v-o+v $$1 $$1 $2 $2 $3 $3 $4 $4 $5 $5 }
dehop { mode $chan -hhhhhh $$1- }
hop { mode $chan +hhhhhh $$1- }
dehopme { mode $chan -h $me }
deoper { mode $me -o }
cycle { Rejoin }
hop { Rejoin }
k { kick $chan $$1- }
F1 { mBOT }
F2 { mB.Pro }
F3 { mB.MemberMgr }
F4 { mB.Extra }
F5 { xSeen }
F6 { mB.Admin }
F7 { mB.ConMgr }
F8 { mB.ChanMgr }
F9 { SB.Settings }
F10 {  }
F11 {  }
F12 { mB.About }

;------------------------------------------

mB.Author { return MaSOuD }
mB.Ver { return v2.0.0b3 }
mB.Version { return DC mBOT $mB.Ver by $+($mB.Author,.) (Running on 12m04IR08C $+(v,$version,$chr(41),$chr(15)) }
mB.Release { return 1 March 2017 }
mB.InitialRelease { return 05 May 2008 }
mB.Mail { return M.Newsted@Yahoo.com }
mB.Imgs { return $mB.Dir($+(Graphics\,$iif($1 != $null,$1))).qt }
mB.Dir {
  var %path = $+($mircdir,Sys\,$iif($1 != $null,$1-))
  if (!$prop) || ($prop == qt) { return $qt(%path) }
  elseif ($prop == sfn) { return $shortfn(%path) }
}
mB.Top { return $mB.Dir($+(mBOT\TopDB\,$iif($1,$1))).qt }
mB.Dll { return $mB.Dir($+(DLLs\,$1)).sfn }
mB.Write { .writeini -n $qt($+($scriptdir,$1,.ini)) $2- }
mB.Read { return $readini($qt($+($scriptdir,$1,.ini)),n,$2,$iif($3 != $null,$3)) }
mB.Remove { .remini $qt($+($scriptdir,$1,.ini)) $2- $iif($3,$3) }
mB.Ini {
  var %file = $qt($+($scriptdir,$1,.ini))
  if ($0 == 2) { return $ini(%file,$2) }
  elseif ($0 == 3) { return $ini(%file,$2,$3) }
}

mB.Queue {
  if ($mB.Read(Managers,Config,Queue) == 1) {
    var %win = $+(@Queue.,$network)
    if (!$window(%win)) {
      window -k0lnzh %win
      aline %win $cid
    }

    ; $1 = -a -d (Add/Remove) -- $2- = to be executed line
    if ($istok(-a -d, $1, 32)) {
      if ($1 == -a) {
        .aline %win $2-
        ; if ($line(%win,0) > 2) {
        ;   var %x = $v1
        ;   if (%x > 2) {
        ;     while (%x) {
        ;       var %line = $line(%win,%x)
        ;       if (* ban * iswm %line) {

        ;       }
        ;       dec %x
        ;     }
        ;  }
        ;}
      }
      elseif ($1 == -d) && ($line(%win,0) > 1) { dline %win 2 }
    }
    var %every = $iif($mB.Read(Managers,Config,QueueCheck) isnum, $v1, 700)
    $+(.timer.Queue.,$network) $iif($line(%win,0) > 1, -m 0 %every mB.Queue.Exec %win , off)
  }
  else {
    $iif($1 == h, $$2-, $$1-)
  }
}

mB.Queue.Exec {
  if (!$window($1)) { mB.Queue }
  ; mB.Queue.Rearrange
  var %cid = $activecid
  if ($line($1,0) > 1) {
    scid $line($1,1)
    var %x = $iif($mB.Read(Managers,Config,QueueItems) isnum 1-, $v1, 2)
    while (%x) {
      if ($line($1,0) > 1) {
        if ($fline($1,h *,1) != $null) { $+(!,$gettok($line($1,$v1),2-,32)) | dline $1 $v1 }
        else { $+(!,$line($1,2)) | mB.Queue -d }
      }
      dec %x
    }
    scid %cid
  }
}

mB.Queue.Close {
  ; $1 = $network - [$2 = $chan]
  if ($1 != $null) {
    $+(.timer.Queue.,$network) off
    var %win = $+(@Queue.,$network)
    if ($2 == $null) {
      if ($window(%win)) { window -c %win }
      return
    }
    var %x = 2
    if ($line(%win,0) > 1) {
      while ($fline(%win, * $2 *,%x) != $null) {
        dline %win $v1
        inc %x
      }
      var %every = $iif($mB.Read(Managers,Config,QueueCheck) isnum, $v1, 700)
      $+(.timer.Queue.,$network) $iif($line(%win,0) > 1, -m 0 %every mB.Queue.Exec %win , off)
    }
  }
}

mDialog { dialog $iif($dialog($$1), -v, -m $$1) $$1 }
Safe { return $!decode( $encode($1-, m) ,m) }
mB.QuitMsg { return 01mBOT $mB.Ver by MaSOuD. Get it now from 02Http://DeadCeLL.eu5.org/ $+ $chr(15) }
Bars { return $mB.Dll(Bars.mdx) }
Views { return $mB.Dll(Views.mdx) }
hOS { return $dll($mB.Dll(hOS.dll),$1,$2-) }
MDX { return $dll($mB.Dll(MDX.dll),$1,$2-) }
WhileFix { return | dll $mB.Dll(WhileFix.dll) WhileFix . }
Trigger {
  var %x = $mB.Read(Channels,$1,$2)
  if ($0 != 2) || (%x == $null) { return $iif($mB.Read(Managers,Config,Trigger) != $null,$v1,!) }
  else {
    if ($istok(%x,NickTr,32)) { return $me }
    var %t = $wildtok(%x,Trigger|*,1,32)
    if ($remove(%t,Trigger|) != $null) { return $v1 }
    else { return $iif($mB.Read(Managers,Config,Trigger) != $null,$v1,!) }
  }
}

Accesses {
  if ($prop == Long) {
    return Full Access,Add/Remove Managers,Manage Members list,Manage Top10 databases,Manage Auto Kill List,Enable/Disable Features,Using Channel Controller Commands,Do NOT Kick/Ban This Manager
  }
  elseif ($prop == Short) {
    return Full Manager Members Top AKill EDFeatures ChanCmd NoKickBan
  }
}

AccessList {
  if ($istok(IsOwner IsCOwner IsMaster IsLogged Login Logout HasAcc Granted Acc Suspended,$prop,32)) && ($isid) {
    if ($prop == IsLogged) {
      if ($1 != $null) {
        ; $1 = $nick - $2 = Manager
        if ($mB.Read(Managers,$2,Auth) == 0) { return $true }
        if ($mB.Read(Managers,%item,Bound) == 1) && ($2 !iswmcs $3) { return $false }
        return $iif($mB.Read(Managers,Logged,$1) == $2,$true,$false)
      }
    }
    elseif ($prop == Login) && ($0 >= 2) {
      ; $1 = $fulladdress - $2 = Password
      if ($($+(%,LoginTries.,%nick),2) > 2) return
      var %x = $mB.Ini(Managers,0),%nick = $gettok($1,1,33),%msg
      while (%x) {
        var %item = $mB.Ini(Managers,%x)
        if (%item != Config) && (%item != $null) {
          if (%item == $1) || (%item iswmcs $1) {
            if ($mB.Read(Managers,%item,Everywhere) == 1) || ($wildtok($mB.Read(Managers,%item,List), $+($network,@*),0,32) == 1) {
              if ($md5($2-,0) === $mB.Read(Managers,%item,Password)) {
                if ($mB.Read(Managers,Logged,%nick) == %item) { %msg = You're already logged in. }
                else { mB.Write Managers Logged %nick %item | %msg = Welcome back $+(%nick,!) You're successfully recognized and logged in. }
              }
              else { %msg = Wrong password. | inc $+(-u,10000) $+(%,LoginTries.,%nick) }
              if (%msg != $null) { mB.Queue -a .msg %nick %msg | return }
            }
          }
        }
        dec %x
      }
    }
    elseif ($prop == Logout) && ($1 != $null) {
      ; $1 = $nick
      if ($mB.Read(Managers,Logged,$1) != $null) {
        mB.Remove Managers Logged $1
        mB.Queue -a msg $1 Logged out.
        return
      }
    }
    elseif ($prop == IsOwner) {
      var %x = $mB.Ini(Managers,0)
      while (%x) {
        var %item = $mB.Ini(Managers,%x)
        if (%item != Config) && (%item != $null) {
          if (%item == $3) || (%item iswmcs $3) {
            if ($mB.Read(Managers,%item,Role) == o) { return $true }
            return $false
          }
        }
        dec %x
      }
    }
    elseif ($prop == HasAcc) { 
      ; $1 = $nick - $2 = $network - $3 = $fulladdress - $4 = Section
      var %x = $mB.Ini(Managers,0)
      while (%x) {
        var %item = $mB.Ini(Managers,%x)
        if (%item != Config) && (%item != $null) {
          if (%item iswmcs $3) && ($IsLogged($1,%item,$3)) {
            if (!$IsSuspended(%item)) && ($ReadAcc(%item,$4)) { return $true }
            return $false
          }
        }
        dec %x
      }
      return $false
    }
    elseif ($prop == Granted) {
      if ($IsOwner($1,$2,$3)) { return $true }
      var %pub = IP Weather Ping Top Seen Quotes
      if ($istok(%pub,$4,32)) { return $eval($+($,mB.Channels($1,$2).,$4),2) }
      else {
        var %chanCmds = Owner DeOwner Protect Deprotect Op Deop Hop Dehop Voice Devoice Ban Unban Kick KickBan Mode RemLastBan ClearBanList ClearExceptList ClearInviteList Topic Invite
        var %manager = Join Part Rejoin Nick SysInfo Quote
        var %full = Quit Eval UnsetAll SysInfo
        var %akill = Akill Kill Gline Kline
        var %rest = Members Top
        var %x
        if ($istok(%chanCmds,$4,32)) { %x = ChanCmd }
        elseif ($istok(%manager,$4,32)) { %x = Manager }
        elseif ($istok(%full,$4,32)) { %x = Full }
        elseif ($istok(%akill,$4,32)) { %x = AKill }
        elseif ($istok(%rest,$4,32)) { %x = $4 }
        elseif ($4 == chan) { %x = EDFeatures }
        return $HasAcc($gettok($3,1,33),$1,$3,%x)
      }
    }
  }
  ;else {
  ;  var %x = $+($2,.,$3)
  ;  if ($istok(-a -d -w,$1,32)) {
  ;    ; $1 = Flag - $2 = $nick - $3 = $network - $4 = Sender - $5- = Password
  ;    if ($1 == -a) && ($numtok($2-,32) > 4) {
  ;      var %code = $+($r(A,Z),$r(0,9),$r(A,Z),$r(a,z),$r(0,9),$r(A,Z))
  ;      mB.Write Managers %x Password $md5($5-,0)
  ;      mB.Write Managers %x Code %code
  ;      mB.Write Managers %x Logged 1
  ;      .msg $2 You have been added and logged in my Managers list on $3 IRC network. For any help use2 $+($Trigger,Help) OR2 /msg $me Help
  ;      .msg $2 Your Security Code is:2 %code (Don't forget that security code and password are caSe-sEnsiTiVe)
  ;      .msg $2 Don't forget your Security Code! It's for Password recovery and/or when you want to remove yourself from Master list!
  ;      .msg $2 To Login or logout type2 /msg $me <Login|Logout> $2 $5-
  ;      .notice $4 $qt($2) has been successfully added to the master list.
  ;      return
  ;    }
  ;    elseif ($1 == -d) && ($numtok($2-,32) >= 3) {
  ;      ; $1 =  Flag - $2 = $nick - $3 = $network - $4 = Sender
  ;      if ($2 != $4) {
  ;        if ($mB.Read(Managers,%x)) { mB.Remove Managers %x | .msg $4 $qt($2) has been removed from master list. }
  ;        else { .msg $4 $qt($2) not found in manager list. }
  ;      }
  ;    }
  ;  }
  ;}
}

mB.Status { return $mB.Read(Managers,Config,Status) }
OperStatus { return $iif($server != $null && o isincs $usermode,$true,$false) }
HasAcc { return $AccessList($1,$2,$3,$4).HasAcc }
ReadAcc { return $istok($mB.Read(Managers, $$1,Access), $$2, 32) }
IsOwner { return $AccessList($1,$2,$3).IsOwner }
IsLogged { return $AccessList($1,$2).IsLogged }
IsSuspended { return $iif($mB.Read(Managers,$1,Suspend) == 1,$true,$false) }

mB.CleanUp {
  mB.UTime
  Top.Save
  Quote.Save
  UnsetAll
  mB.Remove Managers Logged
  dll -u MDX.dll
  dll -u hOS.dll
}

mB.Startup {
  if ($version < 7.41) { 
    var %Result = $input(DC mBOT doesn't work with mIRC v $+ $version $crlf $+ It required v7.41 or above. $+ $crlf $+ $crlf $+ Would you like to download the latest version of mIRC?,hyvg,mIRC Version)
    if (%Result == $yes) { run http://mirc.co.uk/get.html }
    exit -n
  }
  else {
    UnsetAll
    mB.Loader
    mB.Start
  }
}

VersionSilencer { .ignore -tw * | scon -a .debug -i NUL StopVer }
mOpt { .Sendkeys $+($chr(37),o) }

Sendkeys {
  var %a = $+(SendKeys,$ticks)
  .comopen %a WScript.Shell
  if (!$comerr) { 
    var %b = $com(%a,SendKeys,3,bstr,$1-)
    .comclose %a
    return %b
  }
  return 0
}

mB.Toolbar {
  toolbar -c
  var %t = toolbar -axz1,%s = toolbar -is
  var %x = $scid($activecid).status
  if ($istok(connecting connected,%x,32)) || (*logging* iswm %x) {
    %t Disconnect $qt($+(Disconnecting from,$chr(32),$chr(40),$server,:,$port,$chr(41))) $mB.Imgs(Conn.ico) "/mB.Toolbar.Connection"
  }
  else { %t Connect $qt($mB.Toolbar.ConnectionTooltip) $mB.Imgs(Connection.ico) "/mB.Toolbar.Connection" }
  %s Xsep
  %t mIRCOpt "mIRC Options" $mB.Imgs(Options.ico) "/mOpt"
  %s Rsep
  %t mB "mBOT Main Settings" $mB.Imgs(Set.ico) "/mBOT"
  %t Extra "Extra Settings" $mB.Imgs(Extra.ico) "/mB.Extra"
  %t AJoin "Connection Manager" $mB.Imgs(ConSetting.ico) "/mB.ConMgr"
  %t CManager "Channel Manager" $mB.Imgs(Channel.ico) "/mB.ChanMgr"
  %t Pro "Channel Protections" $mB.Imgs(Protections.ico) "/mB.Pro"
  %t Members "Member Area" $mB.Imgs(F-Sh.ico) "/mB.MemberMgr"
  %t Admin "Server Administrator Settings" $mB.Imgs(Oper.ico) "/mB.Admin"
  %t Seen "xSeen System" $mB.Imgs(Seen.ico) "/xSeen"
  %s Msep
  %t Help "Help" $mB.Imgs(M1.ico) "/.run http://DeadCeLL.eu5.org/?p=mbot&help=1"
  %t DC-About $qt(About DC mBOT $mB.Ver) $mB.Imgs(About.ico) "/mB.About"
  %s Bsep
}

Statusbar {
  if (!$server) || ($1 == -r) { hOS RemStatusBar | return }
  hOS AddStatusBar SizeGrip
  hOS SBSetHeight 22
  hOS SBCreateIconList Small
  hOS SBSetPanels 200 400 600 800 1000 -1
  hOS SBSetFont 14 700 Arial

  hOS SBSetData 1 1 Network: $iif($iif($len($network) > 20,$+($left($network,19),...),$network) != $null, $v1, N/A)
  hOS SBSetData 2 2 Server: $iif($iif($len($server) > 20,$+($left($server,19),...),$server) != $null, $v1, N/A)
  hOS SBSetData 3 3 IP: $iif($ip != $null, $ip, N/A)
  hOS SBSetData 4 4 Active: $active
  hOS SBSetData 5 5 Active Modes: $iif($active ischan && $chan($active).mode != $null, $chan($active).mode, N/A)
  hOS SBSetData 6 6 Usermodes: $iif($usermode != $null, $v1, N/A)
  hOS SBSetData 7 7 IRCOp?: $iif(o isincs $usermode, Yes, No)
}

mB.Toolbar.Connection {
  var %x = $scid($activecid).status
  if ($istok(connecting connected,%x,32)) || (*logging* iswm %x) { scid $activecid disconnect }
  else { scid $activecid server }
  .timer.Cons 1 1 mB.Toolbar
}

mB.Toolbar.ConnectionTooltip {
  var %string = $remove($replace($readini($qt($mircini),mirc,host),$chr(58),$chr(32)),SERVER,GROUP)
  if (%string != $null) { tokenize 32 %string | return Connect to $+($chr(40),$2,:,$3,$chr(41)) }
  else { return Connect }
}

Rejoin {
  var %chan = $iif($1 ischan, $1, $active)
  if (%chan !ischan) return
  part %chan 01Rejoining to02 %chan $+ $chr(15)
  $+(.timer.rejoin.,%chan) 1 1 join %chan
}

RejoinAll {
  if ($server) && ($chan(0) > 0) {
    var %a = 1
    while (%a <= $chan(0)) { var %ch = $addtok(%ch,$chan(%a),44) | inc %a }
    .partall 02Rejoining all channels. $iif($1 != $null,01[Requested by $1 $+ $chr(93)) $+ $chr(15)
    .timer.reja 1 1 join %ch
  }
}

Quit { !quit $iif($1-,$1-,$mB.QuitMsg) $+ $chr(15) | halt }
Umode { return $iif(!$scid($activecid).server,N/A,$remove($scid($activecid).usermode,+)) }

Title.Wel {
  var %msg = Welcome to mBOT $mB.Ver by $mB.Author
  var %x = 1,%delay = 200
  while (%x <= $len(%msg)) {
    $+(.timer.,%x) -m 1 $calc(%delay * %x) titlebar $+([,$left(%msg,%x),])
    inc %x
  }
  .timer.t2 -m 1 $calc($calc(%delay * %x) + 2300) Title-Wel
}

Title-Wel {
  var %msg = Welcome to mBOT $mB.Ver by $mB.Author
  var %to = mBOT $mB.Ver by $mB.Author
  var %x = 1,%delay = 200,%go
  while ($titlebar) {
    %go = $right(%msg,- $+ %x $+ )
    $+(.timer.,%x) -m 1 $calc(%delay * %x) titlebar $+([,%go,])
    inc %x
    if (%go == %to) break
  }
}

;Sys Info
OS.Ver { return $gettok($OS.GET(Name),1,124) }
OS.Build { return $OS.Get(Version) }
OS.SP {
  var %x = $OS.Get(ServicePackMajorVersion)
  return $iif(%x isnum 1-,$+(SP,%x),$null)
}
OS.Get {
  var %r
  if ($com(osLoc)) { .comclose osLoc }
  if ($com(osSrv)) { .comclose osSrv }
  if ($com(osOS)) { .comclose osOS }
  .comopen osLoc WbemScripting.SWbemLocator
  if ($comerr) goto error
  elseif (!$com(osLoc,ConnectServer,3,dispatch* osSrv)) goto error
  elseif (!$com(osSrv,ExecQuery,3,bstr*,select $1 from Win32_OperatingSystem,dispatch* osOS)) goto error
  %r = $comval(osOS,1,$1)
  :error
  if ($com(osLoc)) { .comclose osLoc }
  if ($com(osSrv)) { .comclose osSrv }
  if ($com(osOS)) { .comclose osOS }
  return %r
}

CRep {
  var %x = (R) (TM) (C)
  return $replace($1-,$gettok(%x,1,32),$chr(174),$gettok(%x,2,32),™,$gettok(%x,3,32),$chr(169))
}

RegRead {
  var %a = RegRead
  .comopen %a WScript.Shell
  if (!$comerr) {
    var %b = $com(%a,RegRead,3,bstr,$1-)
    var %c = $com(%a).result
    .comclose %a
    return $iif(%c,%c,N/A)
  }
}

GetSys {
  if ($1 == CPU) {
    var %l $GetSysInfo(win32_processor,1).deviceid,processortype,loadpercentage
    var %k $+(HKLM\hardware\description\system\CentralProcessor\,$remove($gettok(%l,1,124),CPU),\)
    return $RegRead(%k $+ \ProcessorNameString)
  }
  elseif ($1 == OS) { return $GetSysInfo(win32_operatingsystem,1).name,version,numberofprocesses,csdversion }
  elseif ($1 == Sound) { return $GetSysInfo(Win32_sounddevice).name }
  elseif ($1 == Video) { return $RegRead(HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000\DriverDesc) }
  elseif ($1 == Monitor) { return $RegRead(HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E96E-E325-11CE-BFC1-08002BE10318}\0000\DriverDesc) }
  elseif ($1 == Display) { return $GetSysInfo(win32_videocontroller,1).currentbitsperpixel,CurrentRefreshRate }
  elseif ($1 == TotalMemory) { return $bytes($TotalMemory).suf }
  elseif ($1 == Bios) { 
    var %info = $GetSysInfo(win32_bios,1).name,version,manufacturer
    return $gettok(%info,3,124) -- $gettok(%info,1,124)
  }
}

GetSysInfo {
  if ($isid) && ($prop) {
    if ($com(Locator)) { .comclose Locator }
    if ($com(Services)) { .comclose Services }
    if ($com(Instances)) { .comclose Instances }
    .comopen Locator WbemScripting.SWbemLocator
    if ($comerr) { .comclose Locator | return }
    var %com = $com(Locator,ConnectServer,3,dispatch* Services)
    .comclose Locator
    if $com(Services) {
      var %com = $com(Services, InstancesOf,3,string,$$1,dispatch* Instances)
      .comclose Services
    }
    if ($com(Instances)) {
      var %com = $com(Instances,Count,3)
      var %x 1
      while ($gettok($prop,%x,44)) {
        var %r = $+($iif(%r,%r $+ $chr(124)),$comval(Instances,$iif($2,$2,1),$gettok($prop,%x,44)))
        inc %x
      }
      .comclose Instances
    }
    return %r
  }
}

TotalMemory {
  if ($isid) {
    if ($com(Locator)) { .comclose Locator }
    if ($com(Services)) { .comclose Services }
    if ($com(Instances)) { .comclose Instances }
    .comopen Locator WbemScripting.SWbemLocator
    if ($comerr) { .comclose Locator | return }
    var %com = $com(Locator,ConnectServer,3,dispatch* Services)
    .comclose Locator
    if $com(Services) {
      var %com = $com(Services, InstancesOf,3,string,Win32_PhysicalMemory,dispatch* Instances)
      .comclose Services
    }
    if $com(Instances) {
      var %com = $com(Instances,Count,3)
      var %x = 1,%t = 0
      while ($comval(Instances,%x,Capacity)) {
        inc %t $ifmatch
        inc %x
      }
      .comclose Instances
    }
    return %t
  }
}

mB.SysInfo.Msg {
  var %msg = $mB.Read(Extra,Msgs,SysInfo)
  var %def = 02System Info:03 <OS> <SP> (Build <OSB>) [CPU: <CPU> - RAM: <RAM>] - Uptime: <SysUT> (Record: <SysUTR>)
  return $iif(%msg == $null,%def,%msg)
}

mB.mBInfo.Msg { return 02mBOT Info:03 v<mBVer> (Running on mIRC v<Ver>) - Uptime: <mUT> (Record: <mUTR>) }
mB.SysInfo { return $replace($mB.SysInfo.Msg,<OS>,$OS.Ver,<SP>,$OS.SP,<OSB>,$OS.Build,<CPU>,$CRep($GetSys(CPU)),<RAM>,$GetSys(TotalMemory),<SysUT>,$uptime(system,1),<SysUTR>,$mB.UTime(System)) }
mB.mBInfo { return $replace($mB.mBInfo.Msg,<mBVer>,$right($mB.Ver,-1),<Ver>,$version,<mUT>,$uptime(mirc,1),<mUTR>,$mB.UTime(mBOT)) }

mB.UTime {
  var %mb = $mB.Read(Extra,Records,mBOT),%sys = $mB.Read(Extra,Records,System)
  if (%mb == $null) || ($uptime(mirc) > $gettok(%mb,1,32)) { mB.Write Extra Records mBOT $uptime(mirc) $uptime(mirc,1) }
  if (%sys == $null) || ($uptime(system) > $gettok(%sys,1,32)) { mB.Write Extra Records System $uptime(system) $uptime(system,1) }
  if ($isid) && ($istok(mBOT System,$1,32)) { return $gettok($mB.Read(Extra,Records,$1),2-,32) }
}

IsCmd {
  var %x = $GetRootCmd($1)
  if (%x != $null) && (%x != NoCmd) { return $true }
  return $false
}

GetRootCmd {
  if ($istok(Owner Q,$1,32)) { return Owner }
  elseif ($istok(DeOwner dq deq,$1,32)) { return DeOwner }
  elseif ($istok(Protect Admin A,$1,32)) { return Protect }
  elseif ($istok(DeProtect DeAdmin dep da,$1,32)) { return DeProtect }
  elseif ($istok(Op o,$1,32)) { return Op }
  elseif ($istok(DeOp dop dp,$1,32)) { return DeOp }
  elseif ($istok(Hop H,$1,32)) { return Hop }
  elseif ($istok(DeHop Deh dh,$1,32)) { return DeHop }
  elseif ($istok(Voice Vo V,$1,32)) { return Voice }
  elseif ($istok(DeVoice DV Dev,$1,32)) { return DeVoice }
  elseif ($istok(Ban b,$1,32)) { return Ban }
  elseif ($istok(UnBan ub,$1,32)) { return UnBan }
  elseif ($istok(Mode m,$1,32)) { return Mode }
  elseif ($istok(Kick k,$1,32)) { return Kick }
  elseif ($istok(KickBan kb,$1,32)) { return KickBan }
  elseif ($istok(Topic t,$1,32)) { return Topic }
  elseif ($istok(RemLastBan UnbanLast rlastban rlb ubl,$1,32)) { return RemLastBan }
  elseif ($istok(ClearBans ClearBan ClearBanList CBL CB,$1,32)) { return ClearBanList }
  elseif ($istok(ClearExcepts ClearExcept ClearExceptList CEL CE,$1,32)) { return ClearExceptList }
  elseif ($istok(ClearInvites ClearInvite ClearInviteList CIL CI,$1,32)) { return ClearInviteList }
  elseif ($istok(Invite Inv,$1,32)) { return Invite }
  ;elseif ($istok(Message Msg Say,$1,32)) { return Message }
  ;elseif ($istok(Describe Action Act,$1,32)) { return Action }
  elseif ($istok(Weather Wth W,$1,32)) { return Weather }
  elseif ($istok(Top Stat Stats TStat TStats,$1,32)) { return Top }
  elseif ($istok(Join J,$1,32)) { return Join }
  elseif ($istok(Rejoin Rej,$1,32)) { return Rejoin }
  elseif ($istok(Part P,$1,32)) { return Part }
  elseif ($istok(Peak SysInfo mBInfo IP Quote Ping Slap ChanStat Quit Nick Eval UnsetAll Members Chan Akill Kill Gline Kline,$1,32)) { return $1 }
  else { return NoCmd }
}

RequiresOp {
  var %x = Owner DeOwner Protect DeProtect Op DeOp Hop DeHop Voice DeVoice Mode Ban UnBan KickBan Topic RemLastBan ClearBanList ClearExceptList ClearInviteList Invite
  return $istok(%x,$1,32)
}

DoOperation {
  if ($me !isop $1) return
  var %x = $iif($remove($iif($4 != $null,$4-,$2),@,+,%,~,!,:,&,$chr(44),$chr(46)) != $null,$ifmatch,$2),%y = $numtok(%x,32)
  if (q isin $3) || (a isin $3) goto Mode
  var %cmd = $remove($+($iif($3 == +o,isop),$iif($3 == -o,!isop),$iif($3 == +h,ishop),$iif($3 == -h,!ishop),$iif($3 == +v,isvoice),$iif($3 == -v,!isvoice)),$chr(32))
  while (%y) {
    if ($gettok(%x,%y,32) %cmd $1) || ($gettok(%x,%y,32) !ison $1) {
      if ($numtok(%x,32) == 1) return
      %x = $remtok(%x,$gettok(%x,%y,32),1,32)
    }
    dec %y
  }
  :Mode
  if ($numtok(%x,32) > 0) { mB.Queue -a h mode $1 $+($str($3,$numtok(%x,32))) %x }
}

GetMethod {
  if ($isid) {
    var %x = $mB.Read(Extra,Msgs,$+($1,M))
    if (%x != $null) && (%x isnum 1-4) { return $gettok(NoticeNick MsgNick MsgChan DescribeChan,%x,32) }
    else { return NoticeNick }
  }
}

GetChanStat {
  if (!$1) return N/A
  var %o = $nick($1,0,o),%h = $nick($1,0,h),%v = $nick($1,0,v),%r = $nick($1,0,r),%t = $nick($1,0)
  var %o.p = $round($calc(100 * (%o / %t)),2) $+ $chr(37),%h.p = $round($calc(100 * (%h / %t)),2) $+ $chr(37),%v.p = $round($calc(100 * (%v / %t)),2) $+ $chr(37),%r.p = $round($calc(100 * (%r / %t)),2) $+ $chr(37)
  return 03[ $+ $1 Stats]02 Ops:04 %o ( $+ %o.p $+ )02 - Hops:04 %h ( $+ %h.p $+ )02 - Voices:04 %v ( $+ %v.p $+ )02 - Normal:04 %r ( $+ %r.p $+ )02 - Total:04 %t
}

ToPascal {
  if ($1-) {
    var %in = $1-,%out
    var %x = 1,%y
    var %a = ` 1 2 3 4 5 6 7 8 9 0 - = ; ' , . / \ ~ ! @ # $ % ^ & * ( ) _ + : " < > ? |
    while (%x <= $numtok(%in,32)) {
      if ($istok(%a,$left($gettok(%in,%x,32),1),32)) { %y = $gettok(%in,%x,32) | goto Next }
      ;if ($len($gettok(%in,%x,32)) < 4) && (!$istok(%excepts,$lower($gettok(%in,%x,32)),44)) { %y = $upper($gettok(%in,%x,32)) }
      else { %y = $+($upper($left($gettok(%in,%x,32),1)),$lower($right($gettok(%in,%x,32),-1))) }
      :Next
      if (%out == $null) { %out = %y }
      else { %out = $+(%out,$chr(32),%y) }
      inc %x
    }
    return %out
  }
}

TriggerFlood {
  var %x = 0
  if ($eval($+(%,TrFlood.All.,$1),2) == $null) { set -u60 $+(%,TrFlood.All.,$1) 1 | %x = 1 }
  if ($eval($+(%,TrFlood.,$1,.,$2),2) == $null) { set -u60 $+(%,TrFlood.,$1,.,$2) 1 | %x = 1 }
  if (%x == 1) && ($eval($+(%,TrFlood.All.,$1),2) < $mB.Read(Managers,Config,Overall)) { return $false }
  else {
    inc $+(%,TrFlood.,$1,.,$2)
    inc $+(%,TrFlood.All.,$1)
    if ($eval($+(%,TrFlood.,$1,.,$2),2) >= $mB.Read(Managers,Config,Each)) { return $true }
    if ($eval($+(%,TrFlood.All.,$1),2) >= $mB.Read(Managers,Config,Overall)) { return $true }
  }
  return $false
}

HTMLFree { return $regsubex($1,/^[^<]*>|(<(?:[^<]|(?1))*>)|<.*$/gU,) }
StripHTML { var %x, %i = $regsub($1-,/(^[^<]*>|<[^>]*>|<[^>]*$)/g,$null,%x),%x = $remove(%x,&nbsp;) | return %x }
URLEncode { return $replace($regsubex($1-,/([^a-z0-9\s])/ig,% $+ $base($asc(\t),10,16,2)),$chr(32),+) }
HashTable {
  if ($0 < 2) return
  if (!$hget($1)) { hmake $1 }
  if ($3 != $null) { hadd -m $1 $2 $3- }
}

StopVer {
  tokenize 32 $1-
  if ($+(:,$chr(1),version,$chr(1)) == $5 && <- == $1 && privmsg == $3 && $left($4,1) != $chr(35)) {
    .ctcpreply $right($gettok($2,1,33),-1) VERSION $mB.Version
  }
}

HList {
  if (!$hget($1)) return
  var %a = 1
  echo -ta 03* Hash table $+($1,:)
  while ($hget($1,%a).item) { echo -ta 03* $+($chr(40),%a,$chr(41)) $v1 = $hget($1,$v1) | inc %a }
  echo -ta 03* Hash table $qt($1) end.
}

mB.Start {
  VersionSilencer
  AskForShortcut
  .fullname DC mBOT $mB.Ver
  mB.Toolbar
  background -sfe $mB.Imgs(mBOT.png)
  background -lte $mB.Imgs(Black.png)
  background -hex
  hOS SetIcon $window(-2).hwnd $noqt($mB.Imgs(mB.ico))
  mB.Remove Managers Logged
  .tray -i $mB.Imgs(mB.ico)
  .echo $color(normal) -st 02***01 Welcome to DC 02mB01OT $mB.Ver by02 MaSOuD01 - Released at:02 $mB.Release $+ 01.
  .echo $color(normal) -st 02***01 For more Options Right-click on 02Status01/02Channels 01or click 02Menubar01/02Toolbar01.
  DailyStuff.Init
  Title.Wel
  Top.Load
  Quote.Load
  ConnectionsOnOpen
}

mB.Loader {
  prog -o DC mBOT Startup, please wait...
  var %dsg = 1
  while (%dsg <= 101) {
    .timer -m 1 $calc(15 * %dsg) prog -p $iif(%dsg <= 95,%dsg,100)
    if (!$window(@Progress)) { unset %dsg | return }
    %dsg = $calc(%dsg + 5)
  }
  .timer -m 1 $calc(20 * %dsg + 1) Start.Prog.Close
}

prog { Progress $1- }
Progress {
  if ($1 == -o && !$window(@Progress) && !$window(@Progress.B) && $2-) {
    window -CpdohknB +dL @Progress -1 -1 $iif($calc($width($2-,tahoma,13) +30) < 256,$v2,$v1) 64
    drawrect -rf @Progress 12632256 1 0 0 $window(@Progress).w $window(@Progress).h
    drawrect -r @Progress 14869218 2 0 0 $window(@Progress).w $window(@Progress).h
    drawtext -r @Progress 0 tahoma 13 $calc(($window(@Progress).w - $width($2-,tahoma,13))/2) 12 $2-
    drawrect -r @Progress 6842472 1 10 40 $calc($window(@Progress).w -20) 13
    window -a @Progress
    var %prog = 164,202,255 149,183,231 142,178,228 133,170,223 124,164,220 117,158,214 20,125,251 25,136,243 36,150,238 50,170,238 91,228,255,%p = 1
    window -phkBC +d @Progress.B 1 1 $calc($window(@Progress).w -22) 11
    while (%p <= 11) {
      var %c = $gettok(%prog,%p,32)
      drawdot -r @Progress.B $rgb($gettok(%c,1,44),$gettok(%c,2,44),$gettok(%c,3,44)) 1 0 %p
      inc %p
    }
    %p = 1
    while (%p <= $window(@Progress.B).w) {
      drawcopy @Progress.B 0 0 1 11 @Progress.B %p 0
      inc %p
    }
  }
  if ($1 == -c) { close -@ @Progress* }
  if ($1 == -p && $window(@Progress) && $window(@Progress.B) && $2 isnum 0-100) {
    drawrect -rnf @Progress 16514043 1 11 41 $window(@Progress.B).w 11
    drawcopy -n @Progress.B 0 0 $round($calc(($window(@Progress.B).w * $2) / 100),0) 11 @Progress 11 41
    drawtext -rn @Progress 0 Tahoma 9 $calc(($window(@Progress).w - 20 - $width($+($2,%),tahoma,9)) / 2 +10) 41 $+($2,%)
    drawdot @Progress
  }
}

Start.Prog.Close { if ($window(@Progress)) { prog -c | unset %Load } }

MultiServMsg {
  var %x = 1
  while ($scon(%x)) {
    .scon %x
    if ($scon(%x).network == $1) && ($scon(%x).status == Connected) {
      if ($istok(msg describe,$2,32)) && ($3 ischan) && ($me ison $3) {
        mB.Queue -a $iif(c isincs $gettok($chan($3).mode,1,32),$eval($strip($2-),2),$eval($2-,2))
        return
      }
      elseif ($2 == notice) { mB.Queue -a .notice $3 $4- | return }
    }
    inc %x
  }
}

DailyStuff.Init { .timer.DailyStuff -io 0:00 1 1 DailyStuff }
DailyStuff {
  mB.Queue -a scon -at1 amsg Resetting Daily Statistics, It's midnight here...
  Top.ResetTotalStats
}

; [ASCII Table]
ASCII {
  if ($window(@ASCII)) { window -c @ASCII }
  window -al @ASCII
  aline @ASCII 04** Description:
  aline @ASCII 01ASCII numbers between 0-31 got no real characters, those were intended for teleprinters and have functions such as: Start heading, Start of text, End of text, Line feed.
  aline @ASCII 01Some of those ASCII characters are now used by mIRC for control codes such as: 04C1olour, Bold, Underline, Reverse and Plain.
  aline @ASCII 04Note:1 You can not see the character 32, because it is SPACE.
  aline @ASCII 02-----------------------------
  aline @ASCII 04** Usage & Syntax:
  aline @ASCII 05$chr(2N5)1: The "02N01" MUST be a number between 1-255. By this identifier you can get its $asc() character.
  aline @ASCII $+($str($chr(160),16),01) Example: //echo -a $chr(36) $+ chr(64)
  aline @ASCII $chr(160)
  aline @ASCII 05$asc(02C05)1: The "02C01" can be an ASCII character. By this identifier you can get its $chr() number.
  aline @ASCII $+($str($chr(160),16),01) Do NOT forget that you can NOT use it for more than 1 character at once! 
  aline @ASCII $+($str($chr(160),16),01) Example: //echo -a $chr(36) $+ asc(@)
  aline @ASCII 02-----------------------------
  aline @ASCII 04** ASCII List Begin:
  var %x = 32
  while (%x <= 255) {
    var %y = $calc(%x - 31) 
    aline @ASCII $+($str(0,$calc(3 - $len(%y))),%y,$chr(41)) Character:02 $+($chr(%x),$chr(160),$chr(160),01Number:02) %x 
    inc %x
  }
  aline @ASCII 4End of ASCII List...
}

ASCIIMenu {
  var %num = $calc($sline(@ASCII,1).ln + 17)
  var %line = $sline(@ASCII,1).ln
  if ($sline(@ASCII,0).ln > 1) { .sline @ASCII %line }
  if ($sline(@ASCII,1).ln < 15) { .sline @ASCII 15 }
  if ($sline(@ASCII,1).ln == 239) { .sline @ASCII 238 }
  if ($1 isnum 1-3) || ($1 == begin || $1 == end) {
    if ($1 == begin) || ($1 == end) || ($1 == 2) return -
    if ($1 == 1) { 
      if (%line < 16) { return $style(2) &Character:: }
      else { return C&haracter:clipboard $chr(%num) }
    }
    if ($1 == 3) {
      if (%line < 15) { return $style(2) &Number:: }
      else { return &Number:clipboard %num }
    }
  }
}

AskForShortcut {
  if ($mB.Read(Managers,Config,Shortcut) != 1) || ($1 == UserRequested) {
    var %x = $input(Would you like to create a shortcut on your Desktop?,qyvg,Welcome to mBOT!)
    if (%x == $yes) { ShortcutCreator }
    if ($mB.Read(Managers,Config,Shortcut) != 1) { mB.Write Managers Config Shortcut 1 }
  }
}

ShortcutCreator {
  ; Here we go, This is a Windows Script File (*.wsf) generator which ables us to make 'Shortcut' programmaticly,
  ; You can see the original source code from: http://msdn.microsoft.com/en-us/library/xk6kst2k%28VS.85%29.aspx

  var %file = $+($mircdir,TempFile.tmp)
  var %w = .write $qt(%file)
  .write -c $qt(%file)
  %w <package>
  %w <job id="vbs">
  %w <script language="VBScript">
  %w set WshShell = WScript.CreateObject("WScript.Shell")
  %w strDesktop = WshShell.SpecialFolders("Desktop")
  %w set oShellLink = WshShell.CreateShortcut(strDesktop & "\mBOT.lnk")
  %w oShellLink.TargetPath = $qt($mircexe)
  %w oShellLink.WindowStyle = 1
  %w oShellLink.Hotkey = ""
  %w oShellLink.IconLocation = $+(",$noqt($longfn($mB.Imgs(mB.ico))),$chr(44),$chr(32),0,")
  %w oShellLink.Description = $+(",mBOT,$chr(32),$mB.Ver,$chr(32),by,$chr(32),$mB.Author,.,")
  %w oShellLink.WorkingDirectory = $qt($mircdir)
  %w oShellLink.Save
  %w </script>
  %w </job>
  %w $crlf
  %w <job id="js">
  %w <script language="JScript">
  %w var WshShell = WScript.CreateObject("WScript.Shell");
  %w strDesktop = WshShell.SpecialFolders("Desktop");
  %w var oShellLink = WshShell.CreateShortcut(strDesktop + "\\DC mBOT.lnk");
  %w oShellLink.TargetPath = $+($qt($mircexe),;)
  %w oShellLink.WindowStyle = 1;
  %w oShellLink.Hotkey = "";
  %w oShellLink.IconLocation = $+(",$noqt($longfn($mB.Imgs(mB.ico))),$chr(44),$chr(32),0,",;)
  %w oShellLink.Description = $+(",mBOT,$chr(32),$mB.Ver,$chr(32),by,$chr(32),$mB.Author,.,",;)
  %w oShellLink.WorkingDirectory = $+(",$left($mircdir,-1),",;)
  %w oShellLink.Save();
  %w </script>
  %w </job>
  %w </package>
  var %script = $replace(%file,TempFile.tmp,ShortcutCreator.wsf)
  .rename $qt(%file) $qt(%script)
  .timer.run -m 1 1 .run $qt(%script)
  .noop $input(mBOT's shortcut was successfully created on your Desktop!,ivgok30,Operation successful)
  .timer.shortcut 1 2 .remove $qt(%script)
}

ClearCentralList {
  if ($2 == $null) || ($2 !ischan) return
  if ($($+($,i,$1,l($2,0)),2) < 1) || ($me !ison $2) return
  var %x = 1,%list
  while ($($+($,i,$1,l($2,%x)),2)) {
    %list = $addtok(%list,$v1,32)
    if ($numtok(%list,32) >= $modespl) {
      mB.Queue -a h mode $2 $+(-,$str($1,$v2)) %list
      %list = ""
    }
    inc %x
  }
  if ($numtok(%list,32) > 0) { mB.Queue -a h mode $2 $+(-,$str($1,$modespl)) %list }
}

Tab { return $chr(9) }
NoLong { return $iif($len($1) < 13,$1,$+($left($1,12),...)) }
Logger { return $iif($mB.Read(Managers,Config,Logging) == 1, $true, $false) }

DoLog {
  echo -a here
  if (!$server) return
  var %ldir = $qt($+($noqt($mB.Dir), mBOT\Logs\))
  if (!$exists(%ldir)) { mkdir %ldir }
  if (!$window(@Log)) {
    window -k0nz -t2,20,40,60,80,100 @Log
    echo 2 @Log $+($Tab,Date,$Tab,Time,$Tab,Network,$Tab,Channel,$Tab,Nickname,$Tab,Description)
  }
  if ($1 != $null) {
    echo 1 @Log $+($Tab,$date,$Tab,$time,$Tab,$NoLong($1),$Tab,$NoLong($2),$Tab,$NoLong($3),$Tab,$4-)
    var %x = $+(mBOT\Logs\, $network, .mldb)
    .write $mB.Dir(%x) $+($chr(40),$date $time,$chr(41)) $2-
  }
}
