; ******************************************************
;           DC mBOT - Main Settings
; ******************************************************
alias mBOT { mDialog mBOT }

dialog mBOT {
  title "DC mBOT Main Settings [F1]"
  size -1 -1 216 216
  option dbu
  icon $mB.Imgs(Set.ico)
  list 1, -6 -1 230 30, size
  list 2, 4 4 25 25, size
  text "Main Settings", 3, 29 3 194 15
  text "Add/remove managers and setup the mBOT's core. ", 4, 30 17 193 10
  tab "Managers", 5, 3 30 210 169
  box " Current managers ", 6, 7 47 202 147, tab 5
  list 7, 12 58 192 117, tab 5 size
  button "&Add", 8, 13 178 40 12, tab 5
  button "Mo&dify", 9, 55 178 40 12, tab 5
  button "&Remove", 10, 97 178 40 12, tab 5
  tab "Miscellaneous", 11
  box " Trigger ", 12, 7 47 202 56, tab 11
  text "Default &Trigger:", 13, 13 59 42 10, tab 11
  edit "", 14, 55 58 25 10, tab 11 limit 1 center
  text "Triggers allowed by individual person within a minute:", 15, 13 73 131 10, tab 11
  edit "", 17, 143 72 25 10, tab 11 limit 2 center
  text "Overall triggers allowed within a minute:", 18, 13 87 99 10, tab 11
  edit "", 19, 112 86 25 10, tab 11 limit 2 center
  box " Bantype ", 20, 7 134 202 30, tab 11
  text "Default &Bantype:", 21, 13 147 45 10, tab 11
  combo 22, 59 146 135 55, tab 11 size drop
  box " Logging ", 23, 7 165 202 29, tab 11
  check "Enable logging (This will log almost everything.)", 24, 13 177 158 10, tab 11
  box " Queue System ", 16, 7 104 202 29, tab 11
  edit "", 30, 57 116 28 10, tab 11 center
  text "(ms) and execute", 31, 87 117 45 8, tab 11
  edit "", 32, 134 116 28 10, tab 11 center
  text "items.", 33, 164 117 19 8, tab 11
  check "Check every", 29, 13 116 43 10, tab 11
  check "Enable &mBOT", 25, 4 203 50 10
  button "&Help", 26, 94 202 35 12
  button "&OK", 27, 131 202 40 12, default
  button "&Cancel", 28, 173 202 40 12, cancel
}

on *:dialog:mBOT:*:*:{
  if ($devent == close) { unset %mB.Reset }
  if ($devent == init) {
    hOS EnableCloseBox $dialog($dname).hwnd true
    MDX MarkDialog $dname
    MDX SetMircVersion $version
    MDX SetBorderStyle $dname 1,2 Simple
    MDX SetControlMDX $dname 2 Toolbar Flat NoDivider Wrap List Arrows > $Bars
    MDX SetColor $dname 1,2,3,4 background $rgb(199,199,199)
    MDX SetColor $dname 1,2,3,4 textbg $rgb(199,199,199)
    MDX SetColor $dname 3 text $rgb(65,141,255)
    MDX SetColor $dname 4 text $rgb(0,0,0)
    MDX SetFont $dname 3 +a 25 700 Arial
    MDX SetFont $dname 4 +a 14 700 Arial
    did -i $dname 2 1 BmpSize 32 32
    did -i $dname 2 1 SetImage Icon Normal $noqt($mB.Imgs(Set.ico))
    did -a $dname 2 +a 1 $chr(9) $+ Main Settings
    did -b $dname 1,2,9,10
    MDX SetControlMDX $dname 7 ListView AlignLeft RowSelect ShowSel Single Report Grid > $Views
    did -i $dname 7 1 HeaderDims 135:1 80:2 80:3 80:4
    did -i $dname 7 1 HeaderText Mask $chr(9) Role $chr(9) Suspended $chr(9) Access
    mB.Mgr init
  }
  if ($devent == edit) && ($did == 18) {
    if ($did(18)) && (!%mB.Reset) { set %mB.Reset 1 | did -r $dname $did }
  }
  if ($devent == dclick) && ($did == 7 && $did(7).sel) { mB.Manager -m $wildtok($did(7).seltext,*!*@*,1,32) }
  if ($devent == sclick) {
    if ($did == 7) { did $iif($did(7).sel,-e,-b) $dname 9,10 }
    elseif ($istok(8 9 10,$did,32)) {
      if ($did == 8) { mB.Manager -a }
      elseif ($did == 9 || $did == 10) && ($did(7).sel) { mB.Manager $iif($did == 9,-m,-d) $wildtok($did(7).seltext,*!*@*,1,32) }
    }
    elseif ($did == 26) { }
    elseif ($did == 27) {
      var %save = mB.Write Managers Config
      %save Trigger $iif($did(14) != $null,$v1,!)
      %save Each $iif($did(17) != $null && $did(17) isnum 3-,$v1,5)
      %save Overall $iif($did(19) != $null && $did(19) isnum 10-30,$v1,20)
      %save BT $iif($calc($did(22).sel - 1) >= 0,$v1,2)
      %save Logging $did(24).state
      %save Status $did(25).state
      %save Queue $did(29).state
      %save QueueCheck $did(30)
      %save QueueItems $did(32)
      dialog -c $dname
    }
  }
}

alias -l mB.Mgr {
  if (!$dialog(mBOT)) return
  did -r mBOT 7
  var %x = 1,%y = $mB.Ini(Managers,0)
  while (%x <= %y) {
    WhileFix
    var %item = $mB.Ini(Managers,%x)
    if (%item != Config) && (%item != $null) {
      WhileFix
      did -a mBOT 7 %item $chr(9) $replacexcs($mB.Read(Managers,%item,Role),o,Owner,c,Co-Owner,m,Master) $chr(9) $iif($mB.Read(Managers,%item,Suspend) == 1,Yes,No) $chr(9) $iif($count($mB.Read(Managers,%item,Access),0) == 0,Full,Limited)
    }
    inc %x
  }
  if ($1 == init) {
    var %ra = did -ra mBOT,%c = did -c mBOT
    %ra 14 $iif($mB.Read(Managers,Config,Trigger) != $null,$v1,!)
    %ra 17 $iif($mB.Read(Managers,Config,Each) != $null,$v1,5)
    %ra 19 $iif($mB.Read(Managers,Config,Overall) != $null,$v1,20)
    did -r mBOT 22
    var %a = 0
    while (%a < 20) { WhileFix | did -a mBOT 22 $mask(Nick!User@127-0-0-1.host.com,%a) | inc %a }
    %c 22 $iif($mB.Read(Managers,Config,BT) isnum 0-19,$calc($v1 + 1),3)
    if ($mB.Read(Managers,Config,Logging) == 1) { %c 24 }
    if ($mB.Read(Managers,Config,Status) == 1) { %c 25 }
    if ($mB.Read(Managers,Config,Queue) == 1) { %c 29 }
    if ($mB.Read(Managers,Config,QueueCheck) != $null) { %ra 30 $iif($v1 isnum, $v1, 700) }
    if ($mB.Read(Managers,Config,QueueItems) != $null) { %ra 32 $iif($v1 isnum, $v1, 2) }
  }
}

dialog mB.Manager {
  title "Add/Modify a manager"
  size -1 -1 300 154
  option dbu
  icon $mB.Imgs(Set.ico)
  box " Mask ", 1, 3 1 145 26
  edit "", 2, 10 11 90 10, autohs
  box " Role ", 3, 3 29 145 25
  radio "&Owner", 4, 15 39 35 10, group
  radio "Co-O&wner", 5, 55 39 40 10
  radio "Ma&ster", 6, 103 39 33 10
  box " Acc&ess ", 12, 3 56 145 81
  list 13, 10 67 131 64, size check
  edit "", 17, -50 -50 10 10, hide disable autohs
  box " Limitation ", 18, 152 1 145 91
  text "Current items:", 19, 155 41 45 8, right
  combo 20, 202 40 79 60, size drop
  button "-", 21, 282 39 12 12
  text "Network:", 24, 154 55 45 8, right
  edit "", 25, 201 54 80 10, autohs
  button "+", 26, 282 53 12 12
  text "Channels:", 27, 154 68 45 8, right
  edit "", 28, 201 67 93 10, autohs
  box " Authentication ", 7, 152 94 145 43
  check "Manager's bound to their &mask", 9, 159 106 100 10
  check "Password:", 10, 159 120 40 10
  edit "", 11, 201 120 93 10, pass autohs
  check "This account is suspended", 14, 4 141 75 10
  button "Add", 15, 221 139 37 12
  button "&Cancel", 16, 259 139 37 12, cancel
  radio "All Networks and Channels (Unlimited Access)", 23, 159 11 130 10, group
  radio "Limited", 29, 159 28 50 10
  edit "", 30, 178 24 95 2
  text "(Separated by comma, or * for all)", 8, 202 79 92 8
  text "(CaSe-sensitiVe)", 22, 102 12 44 8
}

on *:dialog:mB.Manager:*:*:{
  if ($devent == sclick) {
    if ($istok(4 5 6,$did,32)) { mB.Checks $did }
    if ($did == 15) {
      if (!$did(4).state) && (!$did(5).state) && (!$did(6).state) return
      if (* * iswm $did(2)) return
      if ($remove($did(2),$chr(32),$chr(9)) == $null) || (*!*@* !iswm $did(2)) return
      if ($mB.Read(Managers,$did(2),Role) != $null) && ($did(15) == Add) return
      var %x = 1,%states,%save = mB.Write Managers $did(2),%rem = mB.Remove Managers $did(2)
      while (%x <= $did(13).lines) {
        if ($did(13,%x).cstate == 1) { %states = %states $gettok($Accesses($null).short,%x,32) }
        inc %x
      }
      var %role = $+($iif($did(4).state,o),$iif($did(5).state,c),$iif($did(6).state,m))
      %save Role %role
      %save Access %states
      %save Suspend $did(14).state
      var %i = 2,%all,%current
      while ($did(20).lines) {
        var %c = $did($dname,20,1),%chans,%net
        if ($chr(160) !isin %c) { %net = $+(%c,@) | did -d $dname 20 1 }
        while ($chr(160) isin $did($dname,20,1)) {
          %chans = $addtok(%chans,$remove($did($dname,20,1),$chr(160)),32)
          did -d $dname 20 1
        }
        %all = $addtok(%all,$+(%net,%chans),44)
      }
      $iif(%all,%save,%rem) List $iif(%all,$v1)
      %save Everywhere $did(23).state
      %save Bind $did(9).state
      %save Auth $did(10).state
      if ($did(11)) { %save Password $v1 }
      if ($did(15).text == Modify) && ($did(2) !== $did(17)) && ($mB.Read(Managers,$did(17),Role) != $null) { mB.Remove Managers $did(17) }
      dialog -c $dname
      mB.Mgr
    }
    elseif ($did == 10) { did $iif($did($did).state,-e,-b) $dname 11 }
    elseif ($did == 20) {
      if ($left($did(20).seltext,1) != $chr(160)) {
        did -r $dname 25,28
        did -b $dname 20,15
        did -a $dname 25 $did(20).seltext
        var %x = 1
        while (%x) {
          var %l = $calc($did(20).sel + 1)
          if ($chr(160) !isin $did($dname,20,%l)) break
          var %chans = $addtok(%chans,$remove($did($dname,20,%l),$chr(160)),44)
          did -ra $dname 28 %chans
          did -d $dname 20 %l
          inc %x
        }
        did -d $dname 20 $did(20).sel
      }
    }
    elseif ($did == 21) { did -r $dname 25,28 | did -e $dname 20,15 | did -d $dname 20 $did(20).sel }
    elseif ($did == 26) {
      if ($did(25)) {
        if (* * iswm $did(25)) return
        if ($did(28) == $null) { did -ra $dname 28 * }
        did -a $dname 20 $did(25)
        var %x = 1,%chans = $remove($did(28),$chr(32),$iif($len($did(28)) > 1,$chr(42)))
        while ($gettok(%chans,%x,44)) { did -a $dname 20 $+($str($chr(160),3),$v1) | inc %x }
        did -r $dname 25,28
        did -e $dname 20,15
      }
    }
  }
}

alias mB.Manager {
  if ($dialog(mBOT)) && (($1 == -a) || ($istok(-m -d,$1,32) && $2 != $null)) {
    if ($1 == -d) && ($mB.Read(Managers,$2,Role) != $null) {
      if ($input(Are you sure? You want to remove the selected manager?,qyvg,Confirmation) == $yes) {
        mB.Remove Managers $wildtok($did(7).seltext,*!*@*,1,32)
        mB.Mgr
      }
      return
    }
    if ($1 == -m) && (!$mB.Read(Managers,$2,Role)) {
      if ($dialog(mB.Manager)) { dialog -x mB.Manager }
      return
    }
    mDialog mB.Manager
    did -hb mB.Manager 17
    did -ra mB.Manager 15 $iif($1 == -a,Add,Modify)
    var %x = 1,%acc = $Accesses($null).Long
    while (%x <= $numtok(%acc,44)) { did -a mB.Manager 13 $gettok(%acc,%x,44) | inc %x }
    if ($1 == -a) {
      did -b mB.Manager 11
      did -c mB.Manager 20 1
      mB.Checks 4
      return
    }
    if ($1 == -m) {
      var %a = 1,%acc = $mB.Read(Managers,$2,Access),%names = $Accesses($null).short
      while ($gettok(%names,%a,32) != $null) {
        var %item = $v1
        did $iif($istok(%acc,%item,32), -s, -l) mB.Manager 13 %a
        inc %a
      }
      did -r mB.Manager 20
      var %x = 1
      while (%x <= $numtok($mB.Read(Managers,$2,List),44)) {
        var %b = $gettok($mB.Read(Managers,$2,List),%x,44),%y = 1
        did -a mB.Manager 20 $gettok(%b,1,64)
        while (%y <= $numtok($gettok(%b,2,64),32)) { did -a mB.Manager 20 $+($str($chr(160),3),$gettok($gettok(%b,2,64),%y,32)) | inc %y }
        inc %x
      }
      did -ra mB.Manager 2,17 $2
      did -u mB.Manager 4-6,9,10,15,16
      did -c mB.Manager $gettok(4 5 6,$findtok(o c m,$mB.Read(Managers,$2,Role),1,32),32)
      did $iif($mB.Read(Managers,$2,Bind) == 1,-c,-u) mB.Manager 9
      did $iif($mB.Read(Managers,$2,Auth) == 1 && $mB.Read(Managers,$2,Password) != $null,-c,-u) mB.Manager 10
      if ($mB.Read(Managers,$2,Password)) { did -ra mB.Manager 11 $v1 }
      did -c mB.Manager $iif($mB.Read(Managers,$2,Everywhere) == 1,23,29)
      var %i = $did(mB.Manager,10).state
      did $iif(%i,-e,-b) mB.Manager 11
      if ($mB.Read(Managers,$2,Password) != $null) && (%i) { did -ra mB.Manager 11 $v1 }
      if ($mB.Read(Managers,$2,Suspend) == 1) { did -c mB.Manager 14 }
    }
  }
}

alias -l mB.Checks {
  if ($1 !isnum 4-6) || (!$dialog(mB.Manager)) return
  did -u mB.Manager 4-6
  did -c mB.Manager $1
  did $iif($1 == 4,-c,-u) mB.Manager 23
  did $iif($1 == 4,-u,-c) mB.Manager 29
  var %x = 1,%y = $findtok(4 5 6,$1,1,32),%z = 1 1 1 1 1 1 1 1 1 1|0 1 1 1 1 1 1 1 1 1|0 0 0 0 0 0 0 1 1 0
  while (%x <= $did(mB.Manager,13).lines) { did $iif($gettok($gettok(%z,%y,124),%x,32) == 1,-s,-l) mB.Manager 13 %x | inc %x }
}
