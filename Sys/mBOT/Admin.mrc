; ******************************************************
;             DC mBOT - IRCOp Settings
; ******************************************************
dialog mB.Admin {
  title "DC mBOT IRCOp Access [F6]"
  size -1 -1 247 193
  option dbu
  icon $mB.Imgs(Oper.ico)
  button "OK", 45, 203 178 40 12, ok
  button "Help", 70, 4 178 40 12
  list 3, -6 -1 259 30, size
  list 6, 4 4 25 25, size
  text "Server Administrator", 7, 29 3 223 15
  text "Do you have an IRCOp access? Enjoy!", 9, 30 17 222 10
  box "", 71, 142 30 102 146
  edit "", 41, 7 161 127 10, autohs
  list 74, 149 50 90 94, sort size vsbar
  edit "", 75, 149 147 90 10, autohs
  button "+", 76, 150 159 12 12
  button "-", 77, 164 159 12 12
  button "&Clear", 72, 178 159 25 12
  check "&Enable Internal Auto Kill List", 73, 150 38 80 10
  box " Commands ", 90, 3 122 135 25
  box " Events to Report ", 84, 3 70 135 49
  box " Logs ", 1, 3 30 135 38
  check "Server Notice Window", 4, 12 40 80 10
  check "Sort Logs by Date", 5, 12 52 65 10
  check "", 92, 55 132 35 10
  check "", 93, 97 132 35 10
  check "", 91, 12 132 35 10
  check "Client Exits", 86, 78 80 39 10
  check "Oper Fails", 89, 78 92 37 10
  check "Client Connects", 85, 12 80 50 10
  check "Client Kills", 87, 12 104 38 10
  check "Whois Me", 88, 12 92 35 10
  box " Default Kill Reason ", 2, 3 150 135 26
}

on 1:dialog:mB.Admin:*:*:{
  if ($devent == init) {
    hOS EnableCloseBox $dialog(mB.Admin).hwnd false
    MDX MarkDialog $dname
    MDX SetMircVersion $version
    MDX SetBorderStyle $dname 3,6 simple
    MDX SetControlMDX $dname 6 Toolbar flat nodivider wrap list arrows > $Bars
    MDX SetColor $dname 3,6,7,9 background $rgb(199,199,199)
    MDX SetColor $dname 3,6,7,9 textbg $rgb(199,199,199)
    MDX SetColor $dname 3,7 text $rgb(65,141,255)
    MDX SetColor $dname 9 text $rgb(0,0,0)
    MDX SetFont $dname 7 +a 25 700 Ringbearer
    MDX SetFont $dname 9 +a 14 700 Arial
    did -i $dname 6 1 bmpsize 32 32
    did -i $dname 6 1 setimage icon normal $noqt($mB.Imgs(Oper.ico))
    did -a $dname 6 +a 1 $chr(9) $+ Administrator Settings
    did -b $dname 3,6
    if ($mB.Read(Admin,AKill,Reason) != $null) { did -a $dname 41 $v1 }
    did -a $dname 91 $+($Trigger,Kill)
    did -a $dname 92 $+($Trigger,Gline)
    did -a $dname 93 $+($Trigger,Kline)
    if ($mB.Read(Admin,Logs,SNotice) == 1) { did -c $dname 4 }
    if ($mB.Read(Admin,Logs,Sort) == 1) { did -c $dname 5 }
    if ($mB.Read(Admin,Reports,Connect) == 1) { did -c $dname 85 }
    if ($mB.Read(Admin,Reports,Exit) == 1) { did -c $dname 86 }
    if ($mB.Read(Admin,Reports,Kill) == 1) { did -c $dname 87 }
    if ($mB.Read(Admin,Reports,Whois) == 1) { did -c $dname 88 }
    if ($mB.Read(Admin,Reports,Fail) == 1) { did -c $dname 89 }
    if ($mB.Read(Admin,Cmds,Kill) == 1) { did -c $dname 91 }
    if ($mB.Read(Admin,Cmds,Gline) == 1) { did -c $dname 92 }
    if ($mB.Read(Admin,Cmds,Kline) == 1) { did -c $dname 93 }
    mB.Admin.AKill -l
  }
  if ($devent == close) {
    var %w = mB.Write Admin
    %w Logs SNotice $did(4).state
    %w Logs Sort $did(5).state
    %w Reports Connect $did(85).state
    %w Reports Exit $did(86).state
    %w Reports Kill $did(87).state
    %w Reports Whois $did(mB.Admin,88).state
    %w Reports Fail $did(89).state
    %w Cmds Kill $did(91).state
    %w Cmds Gline $did(92).state
    %w Cmds Kline $did(93).state
    %w AKill Status $did(73).state
    %w AKill Reason $iif($did(41) != $null,$v1,A-banned.)
  }
  if ($devent == edit) {
    if ($did == 75) { did $iif($did(75) == $null, -b, -e) $dname 76 }
    if ($did == 12) { 
      if ($did(12) == $null) { did -u $dname 20 | did -b $dname 17,19,21 }
      else { did -e $dname 17,19,21 }
    }
  }
  if ($devent == sclick) {
    if ($did == 70) {
      ; Help here...
    }
    if ($did == 72) {
      if ($didtok(74,1) == $null) { .echo -aq $input(There is nothing to clear!,oi8vg,List is already clear) | halt }
      else {
        var %Result = $input(Are you sure? $+ $crlf $+ You want to clear all the Nicks/Addresses/... from Auto Kill list?,qyvg,Clear Auto Kill List)
        if (%Result == $yes) { mB.Remove Admin List | did -r $dname 74 }
      }
    }
    if ($did == 74) && ($did(74).sel != $null) { did -e $dname 77 }
    if ($did == 76) { 
      if (* * iswm $did(75)) { beep 3 | return }
      mB.Admin.AKill -a $did(75) $iif($did(41) != $null,$v1,A-banned.)
      mB.Admin.AKill -l
    }
    if ($did == 77) && ($did(74).sel != $null) { mB.Admin.AKill -d $did(74).seltext | mB.Admin.AKill -l }
  }
}

alias mB.Admin { mDialog mB.Admin }
alias mB.Admin.Error { mDialog mB.Admin.Error }
alias mB.Admin.Login {
  var %nick = $mB.Read(Connections,$1,OperName),%pass = $mB.Read(Connections,$1,OperPassword)
  if (%nick != $null) && (%pass != $null) { oper %nick %pass }
}

alias mB.Admin.AKill {
  if ($istok(-a -d -l,$1,32)) {
    if ($1 == -a) {
      mB.Write Admin List $2 $3-
      if ($isid) { return $true }
    }
    elseif ($1 == -d) {
      if ($mB.Read(Admin,List,$2) != $null) {
        mB.Remove Admin List $2
        if ($isid) { return $true }
      }
    }
    elseif ($1 == -l) {
      if ($dialog(mB.Admin)) {
        did -r $v1 74
        var %x = 1,%y = $mB.Ini(Admin,List,0)
        while (%x <= %y) {
          var %item = $mB.Ini(Admin,List,%x)
          did -a mB.Admin 74 %item
          inc %x
        }
        did -b mB.Admin 76,77
      }
    }
  }
}

alias mB.Admin.AKill.Check {
  tokenize 32 $$1-
  if ($1) && ($2) && ($3) {
    if ($mB.Ini(Admin,List,0) > 0) {
      var %x = 1, %y = $v1
      while (%x < %y) {
        var %temp = $mB.Ini(Admin,List,%x)
        if (%temp != $null) {
          var %mask = $mask($+($1,!,$2,@,$3),5)
          if (%temp iswm %mask) {
            if (o !isincs $usermode) {
              DoLog $network [Reports] N/A %mask found in the A-Kill list, but I couldn't kill because I was not an Oper.
              return
            }
            mB.Queue h kill $1 $iif($mB.Read(Admin,List,%temp),$v1,A-banned.)
            return
          }
        }
        inc %x
      }
    }
  }
}
