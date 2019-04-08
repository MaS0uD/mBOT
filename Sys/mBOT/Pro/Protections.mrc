; ******************************************************
;      DC mBOT - Channel Protections
; ******************************************************
alias mB.Pro.Write { .writeini -n $qt($+($scriptdir,$1,.chan)) $2 $3 $4- }
alias mB.Pro.Rem { .remini $qt($+($scriptdir,$1,.chan)) $2- }
alias mB.Pro.Writes { .write -c $qt($+($scriptdir,$1,.chan)) }
alias mB.Pro.Read {
  var %file = $iif($mB.Pro.File($1), $1, Default)
  return $readini($qt($+($scriptdir,%file,.chan)),n,$2,$3)
}
alias mB.Pro.Ini {
  var %file = $iif($mB.Pro.File($1), $1, Default)
  if (!$prop) && ($2 > 0) {
    if ($3) { return $ini($qt($+($scriptdir,%file,.chan)),$2,$3) }
    else { return $ini($qt($+($scriptdir,%file,.chan)),$2) }
  }
  return $ini($qt($+($scriptdir,%file,.chan)),$iif($2 > 0,$2,0),$iif($prop == Items,0))
}
alias mB.Pro.WSet { .writeini -n $qt($scriptdirSettings.ini) $1 $2 $3 }
alias mB.Pro.RSet { return $readini($qt($scriptdirSettings.ini),n,$1,$2) }
alias mB.Pro.RemSet { .remini $qt($scriptdirSettings.ini) $1 $iif($2,$v1) }
alias mB.Pro.Chks { return 11,13,14,15,16,17,19,20,21,23,25,26,27,98 }
alias mB.Pro.Edits { return 28,37,38,39,41,42,44,46,47,60,61,65,67,99 }
alias mB.Pro.No.Modes { return 3,4,6,7,29,30,31,32,33,34 }
alias mB.Pro.Logo { return $+($chr(3),$chr(50),$chr(60),$chr(3),$chr(49),$chr(52),$chr(100),$chr(31),$chr(3),$chr(52),$chr(67),$chr(31),$chr(3),$chr(49),$chr(52),$chr(112),$chr(3),$chr(50),$chr(62),$chr(15)) }
alias mB.Pro.File { return $isfile($qt($scriptdir $+ $1 $+ .chan)) }
alias mB.Pro.Error { .noop $input($1-,oghv,Error!) }
alias mB.Pro.Reason {
  var %msg = $mB.Pro.Read($3,$1,$4)
  if (%msg == $null) { return $mB.Pro.Logo }
  var %finalMsg = $replace(%msg,<Nick>,$2,<TBT>,$mB.Pro.Read($3,$1,TBT),<KBT>,$mB.Pro.Read($3,$1,KBT),<KC>,$mB.Pro.Read($3,Status,KCount), $&
    <BC>,$mB.Pro.Read($3,Status,BCount),<WC>,$mB.Pro.Read($3,Status,WCount))
  return $+(%finalMsg,$chr(15),$chr(32),$mB.Pro.Logo)
}

alias mB.Pro {
  if (!$isfile($shortfn($scriptdirDefault.chan))) { mB.Pro.Make.Def }
  mDialog mB.Pro
}

alias mB.Pro.Act {
  if (!$dialog(mB.Pro)) return
  if ($dialog(mB.Pro.Act)) { dialog -x mB.Pro.Act }
  .timer.rx 1 0 dialog -m mB.Pro.Act mB.Pro.Act $(|) mB.Pro.Act.Init $1 $2
}

alias mB.Pro.Ex {
  if (!$dialog(mB.Pro)) || ($1 == $null) return
  var %dname = mB.Pro.Ex
  mDialog %dname
  did -ra %dname 25 $1
  didtok %dname 2 44 Normal Text,Action Text,Channel Notice,Nick Change,Join,Part,Quit
  didtok %dname 4 44 Nick,Ident,Host,Message (Processing '$1-')
  didtok %dname 14 44 Kick,Ban,Kick Ban
  did -c %dname 7
  did -c %dname 14 3
  did -ra %dname 16 0
  if ($2 != $null) {
    did -ra %dname 26 $2
    var %e = $mB.Pro.Read($1,$2,Events)
    if ($istok(%e,Text,32)) { did -s %dname 2 1 }
    if ($istok(%e,Action,32)) { did -s %dname 2 2 }
    if ($istok(%e,Notice,32)) { did -s %dname 2 3 }
    if ($istok(%e,Nick,32)) { did -s %dname 2 4 }
    if ($istok(%e,Join,32)) { did -s %dname 2 5 }
    if ($istok(%e,Part,32)) { did -s %dname 2 6 }
    if ($istok(%e,Quit,32)) { did -s %dname 2 7 }

    var %c = $mB.Pro.Read($1,$2,CheckOn)
    if ($istok(%c,Nick,32)) { did -s %dname 4 1 }
    if ($istok(%c,Ident,32)) { did -s %dname 4 2 }
    if ($istok(%c,Host,32)) { did -s %dname 4 3 }
    if ($istok(%c,Message,32)) { did -s %dname 4 4 }

    did -u %dname 7-9
    did -c %dname $gettok(7 8 9,$findtok(Wildcard Token RegEx,$mB.Pro.Read($1,$2,Kind),1,32),32)

    if ($mB.Pro.Read($1,$2,Exp)) { did -ra %dname 11 $v1 }

    did -c %dname 14 $mB.Pro.Read($1,$2,Action)
    did -ra %dname 16 $iif($mB.Pro.Read($1,$2,Duration),$v1,0)
    if ($mB.Pro.Read($1,$2,Reason)) { did -ra %dname 19 $v1 }
  }
}

alias mB.Pro.Tags {
  if (!$dialog(mB.Pro)) return
  mDialog mB.Pro.Tags
}

alias mB.Pro.Save.Set {
  if ($dialog(mB.Pro)) {
    if ($1 == 10) { did -b mB.Pro 9-11 }
    var %e = did -e mB.Pro 8
    if ($did(mB.Pro,2).seltext == $null) { mB.Pro.Error Select a channel from list to apply these settings for that. | %e | return }
    if ($did(mB.Pro,16).state == 1) && ($did(mB.Pro,37) == $null || $did(mB.Pro,60) == $null) { mB.Pro.Error Somthings wrong in Nick Flood. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,17).state == 1) && ($did(mB.Pro,38) == $null || $did(mB.Pro,61) == $null) { mB.Pro.Error Somthings wrong in Join Flood. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,20).state == 1) && ($did(mB.Pro,41) == $null) { mB.Pro.Error Somthings wrong in Codes. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,21).state == 1) && ($did(mB.Pro,42) == $null || $did(mB.Pro,65) == $null) { mB.Pro.Error Somthings wrong in CTCP Flood. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,23).state == 1) && ($did(mB.Pro,44) == $null || $did(mB.Pro,67) == $null) { mB.Pro.Error Somthings wrong in Text Flood. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,23).state == 1) && ($did(mB.Pro,39) == $null || $did(mB.Pro,13) == $null) { mB.Pro.Error Somthings wrong in Text Flood. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,25).state == 1) && ($did(mB.Pro,46) == $null) { mB.Pro.Error Somthings wrong in Clone. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,26).state == 1) && ($did(mB.Pro,47) == $null) { mB.Pro.Error Somthings wrong in Caps Lock. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,27).state == 1) && ($did(mB.Pro,28) == $null) { mB.Pro.Error Somthings wrong in ASCII. Don't leave fields empty! | %e | return }
    if ($did(mB.Pro,98).state == 1) && ($did(mB.Pro,99) == $null) { mB.Pro.Error Somthings wrong in Fast Join/Part. Don't leave fields empty! | %e | return }
    else {
      var %w = mB.Pro.Write $did(mB.Pro,2).seltext
      %w NickF Status $did(mB.Pro,16).state
      %w JoinF Status $did(mB.Pro,17).state
      %w NoticeF Status $did(mB.Pro,19).state
      %w CodeF Status $did(mB.Pro,20).state
      %w CtcpF Status $did(mB.Pro,21).state
      %w TextF Status $did(mB.Pro,23).state
      %w Clone Status $did(mB.Pro,25).state
      %w Caps Status $did(mB.Pro,26).state
      %w ASCII Status $did(mB.Pro,27).state
      %w FJP Status $did(mB.Pro,98).state
      %w NickF Times $iif($did(mB.Pro,37) != $null,$v1,0)
      %w NickF Secs $iif($did(mB.Pro,60) != $null,$v1,0)
      %w JoinF Times $iif($did(mB.Pro,38) != $null,$v1,0)
      %w JoinF Secs $iif($did(mB.Pro,61) != $null,$v1,0)
      %w CodeF Max $iif($did(mB.Pro,41) != $null,$v1,0)
      %w CtcpF Times $iif($did(mB.Pro,42) != $null,$v1,0)
      %w CtcpF Secs $iif($did(mB.Pro,65) != $null,$v1,0)
      %w TextF Times $iif($did(mB.Pro,44) != $null,$v1,0)
      %w TextF Secs $iif($did(mB.Pro,67) != $null,$v1,0)
      %w TextF Bytes $iif($did(mB.Pro,39) != $null,$v1,0)
      %w TextF BSecs $iif($did(mB.Pro,13) != $null,$v1,0)
      %w Clone Max $iif($did(mB.Pro,46) != $null,$v1,0)
      %w Caps Percent $iif($did(mB.Pro,47) != $null,$v1,0)
      %w ASCII Percent $iif($did(mB.Pro,28) != $null,$v1,0)
      %w FJP Secs $iif($did(mB.Pro,99) != $null,$v1,0)
      if ($1 == 10) { .timer.DCxx 1 1 did -e mB.Pro 9-11 }
      else { dialog -c mB.Pro }
    }
  }
}

alias -l mB.Pro.CLoading {
  did -r mB.Pro 2
  didtok mB.Pro 2 32 Default
  var %i = 1
  while ($findfile($shortfn($scriptdir),*.chan,%i)) {
    var %file = $v1
    if ($nopath(%file) != Default.chan) { didtok mB.Pro 2 32 $left($nopath(%file),-5) }
    inc %i
  }
  did -c mB.Pro 2 1
  mB.Pro.Init Default
}

alias -l mB.Pro.Rem {
  var %i = 1
  while ($findfile($qt($scriptdir),*.tmp,%i)) { .remove $qt($v1) | inc %i }
}

alias -l mB.Pro.Make.Def {
  var %s = Status NickF JoinF NoticeF CodeF CtcpF TextF Clone Caps ASCII FJP
  var %x = 1,%w = mB.Pro.Write Default
  while (%x <= $numtok(%s,32)) { %w $gettok(%s,%x,32) Status 1 | inc %x }

  %w NickF Times 5
  %w NickF Secs 8
  %w NickF Act 6
  %w NickF Protects oh
  %w NickF TBT 60
  %w NickF KBT 120
  %w NickF WRes Do NOT change your Nickname again! (This is warning! Next step you will be banned!)
  %w NickF BRes You warned one time! You're banned for <TBT> seconds.
  %w NickF KRes You're not welcome! <KC>
  %w NickF Btype 10

  %w JoinF Times 3
  %w JoinF Secs 2
  %w JoinF Act 4
  %w JoinF Protects 0
  %w JoinF TBT 60
  %w JoinF KBT 120
  %w JoinF WRes Join Flood detected!
  %w JoinF BRes Join Flood detected! You're banned for <TBT> seconds.
  %w JoinF KRes Join Flood detected! <KC>
  %w JoinF Btype 4

  %w CodeF Times 6
  %w CodeF Act 3
  %w CodeF Protects oh
  %w CodeF TBT 60
  %w CodeF KBT 120
  %w CodeF Max 5
  %w CodeF WRes You used control codes (Colors, Bolds, ...) more than <LC> codes. Do NOT use control codes again! (This is warning! Next step you will be banned!)
  %w CodeF BRes Code Flood detected! You're banned for <TBT> seconds.
  %w CodeF KRes Code Flood detected! <KC>
  %w CodeF Btype 2

  %w CtcpF Times 5
  %w CtcpF Secs 2
  %w CtcpF Act 3
  %w CtcpF Protects oh
  %w CtcpF TBT 60
  %w CtcpF KBT 120
  %w CtcpF WRes Do NOT do any Channel CTCP again! (This is warning! Next step you will be banned!)
  %w CtcpF BRes CTCP Flood detected! You're banned for <TBT> seconds.
  %w CtcpF KRes CTCP Flood detected! <KC>
  %w CtcpF Btype 2

  %w TextF Times 3
  %w TextF Bytes 300
  %w TextF Secs 2
  %w TextF BSecs 10
  %w TextF Act 3
  %w TextF Protects ohv
  %w TextF TBT 60
  %w TextF KBT 120
  %w TextF WRes Stop flooding! Calm down! (This is warning! Next step you will be banned!)
  %w TextF BRes Text Flood detected! You're banned for <TBT> seconds.
  %w TextF KRes Text Flood detected! <KC>
  %w TextF Btype 2

  %w Clone Max 2
  %w Clone Act 4
  %w Clone Protects o
  %w Clone TBT 60
  %w Clone KBT 120
  %w Clone WRes Clones found in your host. Part your other Nicks from channel! (This is warning! Next step you will be banned!)
  %w Clone BRes Clones found in your host. You're banned for <TBT> seconds.
  %w Clone KRes Clones found in your host. I did warned you to part your other Nicks from channel! <KC>
  %w Clone Btype 2

  %w Caps Percents 50
  %w Caps Act 3
  %w Caps Protects oh
  %w Caps TBT 60
  %w Caps KBT 120
  %w Caps Percent 90
  %w Caps WRes Turn your Caps Lock OFF! You used more than <PCL>% Caps in your messages. (This is warning! Next step you will be banned!)
  %w Caps BRes CAPS LOCK detected! You're banned for <TBT> seconds.
  %w Caps KRes CAPS LOCK detected! I did warned you to turn OFF your Caps Lock! <KC>
  %w Caps Btype 2

  %w ASCII Act 2
  %w ASCII Protects oh
  %w ASCII TBT 60
  %w ASCII KBT 120
  %w ASCII Percent 10
  %w ASCII WRes Do NOT use ASCII characters in you message again. (This is warning! Next step you will be banned!)
  %w ASCII BRes ASCII detected! You're banned for <TBT> seconds.
  %w ASCII KRes ASCII detected! I did warned you! <KC>
  %w ASCII Btype 2

  %w FJP Secs 2
  %w FJP Act 4
  %w FJP Protects 0
  %w FJP TBT 60
  %w FJP KBT 120
  %w FJP WRes None
  %w FJP BRes None
  %w FJP KRes None
  %w FJP Btype 2

  .timer.ds 1 0 mB.Pro
}

alias -l mB.Pro.Init {
  if ($dialog(mB.Pro)) {
    var %c = did -c mB.Pro,%a = did -ra mB.Pro
    if ($mB.Pro.Read($1,NickF,Status) == 1) { %c 16 }
    if ($mB.Pro.Read($1,NickF,Times) != $null) { %a 37 $v1 }
    if ($mB.Pro.Read($1,NickF,Secs) != $null) { %a 60 $v1 }

    if ($mB.Pro.Read($1,JoinF,Status) == 1) { %c 17 }
    if ($mB.Pro.Read($1,JoinF,Secs) != $null) { %a 61 $v1 }
    if ($mB.Pro.Read($1,JoinF,Times) != $null) { %a 38 $v1 }

    if ($mB.Pro.Read($1,NoticeF,Status) == 1) { %c 19 }

    if ($mB.Pro.Read($1,TextF,Status) == 1) { %c 23 }
    if ($mB.Pro.Read($1,TextF,Times) != $null) { %a 44 $v1 }
    if ($mB.Pro.Read($1,TextF,Secs) != $null) { %a 67 $v1 }
    if ($mB.Pro.Read($1,TextF,Bytes) != $null) { %a 39 $v1 }
    if ($mB.Pro.Read($1,TextF,BSecs) != $null) { %a 13 $v1 }

    if ($mB.Pro.Read($1,Caps,Status) == 1) { %c 26 }
    if ($mB.Pro.Read($1,Caps,Percent) != $null) { %a 47 $v1 }

    if ($mB.Pro.Read($1,FJP,Status) == 1) { %c 98 }
    if ($mB.Pro.Read($1,FJP,Secs) != $null) { %a 99 $v1 }

    if ($mB.Pro.Read($1,CodeF,Status) == 1) { %c 20 }
    if ($mB.Pro.Read($1,CodeF,Max) != $null) { %a 41 $v1 }

    if ($mB.Pro.Read($1,CtcpF,Status) == 1) { %c 21 }
    if ($mB.Pro.Read($1,CtcpF,Times) != $null) { %a 42 $v1 }
    if ($mB.Pro.Read($1,CtcpF,Secs) != $null) { %a 65 $v1 }

    if ($mB.Pro.Read($1,Clone,Status) == 1) { %c 25 }
    if ($mB.Pro.Read($1,Clone,Max) != $null) { %a 46 $v1 }

    if ($mB.Pro.Read($1,ASCII,Status) == 1) { %c 27 }
    if ($mB.Pro.Read($1,ASCII,Percent) != $null) { %a 28 $v1 }  

    mB.Pro.Combo.x
    mB.Pro.LoadExpressions
  }
}

alias -l mB.Pro.Act.Init {
  if ($dialog(mB.Pro.Act)) {
    var %c = did -c mB.Pro.Act,%a = did -ra mB.Pro.Act
    if ($mB.Pro.Read($1,$2,Act)) { %c 5 $v1 }
    if ($mB.Pro.Read($1,$2,Protects) == 0) goto Jump
    if (o isin $mB.Pro.Read($1,$2,Protects)) { %c 11 }
    if (h isin $mB.Pro.Read($1,$2,Protects)) { %c 12 }
    if (v isin $mB.Pro.Read($1,$2,Protects)) { %c 13 }
    :Jump
    if ($mB.Pro.Read($1,$2,Btype)) { %c 15 $calc($v1 + 1) }
    if ($mB.Pro.Read($1,$2,TBT)) { %a 26 $v1 }  
    if ($mB.Pro.Read($1,$2,KBT)) { %a 28 $v1 }
    if ($mB.Pro.Read($1,$2,Res) == 1) { %c 35 }
    if ($mB.Pro.Read($1,$2,WRes)) { %a 20 $v1 }
    if ($mB.Pro.Read($1,$2,BRes)) { %a 21 $v1 } 
    if ($mB.Pro.Read($1,$2,KRes)) { %a 22 $v1 }

    if ($mB.Pro.Read($1,$2,MStatus) == 1) { %c 3  }
    if ($mB.Pro.Read($1,$2,MCount)) { %a 4 $v1 }
    if ($mB.Pro.Read($1,$2,MIn)) { %a 7 $v1 }
    if ($mB.Pro.Read($1,$2,MMode)) { %a 31 $v1 }
    if ($mB.Pro.Read($1,$2,MFor)) { %a 33 $v1 }

    var %x = Text Flood,Control Codes,Caps Lock,ASCII,Nick Flood,Join Flood,Clone Host,Channel Notice Guard,Channel CTCP,Fast Join/Part
    var %y = TextFlood CodeF Caps ASCII NickF JoinF Clone NoticeF CtcpF FJP
    var %title = $gettok(%x,$findtok(%y,$2,32),44)
    dialog -t mB.Pro.Act %title Actions - Channel Protections
    did -ra mB.Pro.Act 100 $2
  }
}

alias -l mB.Pro.Closed {
  if ($dialog(mB.Pro)) { dialog -x mB.Pro }
  if ($dialog(mB.Pro.Act)) { dialog -x mB.Pro.Act }
  if ($dialog(mB.Pro.Tags)) { dialog -x mB.Pro.Tags }
}

alias -l mB.Pro.Combo.x {
  did -r mB.Pro 128
  didtok mB.Pro 128 44 Select...,Text Flood,Control Codes,Caps Lock,ASCII,Nick Flood,Join Flood,Clone Host,Fast Join/Part,Channel CTCP,Channel Notice Guard
  did -c mB.Pro 128 1
}

alias mB.Pro.LoadExpressions {
  did -r mB.Pro 5
  var %chan = $did(mB.Pro,2).seltext
  var %x = 1, %y = $mB.Pro.Ini(%chan,0).Items

  while (%x <= %y) {
    var %topic = $mB.Pro.Ini(%chan,%x)
    if (Exp* iswm %topic) {
      did -a mB.Pro 5 $mB.Pro.Read(%chan,%topic,Exp) $Tab $mB.Pro.Read(%chan,%topic,Kind) $Tab %topic
    }
    inc %x
  }
}

alias mB.Pro.Ex.Del {
  if (!$1) || (!$2) return
  if ($input(Are you sure you want to remove this item?,qyvg,Confirmation) == $yes) {
    mB.Pro.Rem $1 $2
    mB.Pro.LoadExpressions
  }
}

alias -l mB.Pro.Lists {
  did -a mB.Pro.Act 5 None
  var %a = 1
  while (%a < 20) { did -a mB.Pro.Act 15 $mask(Nick!User@127-0-0-1.host.com,%a) | inc %a }
  if (%DC.Act.Section == Clone) { didtok mB.Pro.Act 5 44 Ban Host,Kick Last,Kick All,Kick Ban All | return }
  if (%DC.Act.Section == JoinF) { didtok mB.Pro.Act 5 44 Ban All,Kick All,Kick Ban All | return }
  didtok mB.Pro.Act 5 44 Warn then T-Ban,Temp Ban,Ban,Kick,Kick Ban
}

dialog mB.Pro {
  title "Channel Protections"
  size -1 -1 277 188
  option dbu
  icon $mB.Imgs(Protections.ico)
  box " Channels ", 1, 3 30 70 141
  list 2, 7 39 62 112, size vsbar
  button "A&dd", 3, 7 154 30 12
  button "&Remove", 4, 39 154 30 12
  tab "Expression", 22, 77 30 196 141
  box " Expression Area ", 117, 81 46 187 121, tab 22
  list 5, 86 57 177 90, tab 22 size
  button "Add", 6, 87 150 37 12, tab 22
  button "Modify", 7, 126 150 37 12, tab 22
  button "Remove", 8, 165 150 37 12, tab 22
  tab "... Texts", 54
  box "", 75, 81 46 187 97, tab 54
  check "Text Flood", 23, 89 56 44 10, tab 54
  edit "", 44, 147 56 22 10, tab 54 limit 2 center
  text "Lines In", 55, 171 57 24 8, tab 54 center
  edit "", 67, 197 56 25 10, tab 54 limit 3 center
  text "Seconds", 76, 224 57 25 8, tab 54 center
  text "OR", 15, 132 66 13 8, tab 54 center
  edit "", 39, 147 74 22 10, tab 54 limit 3 center
  text "Bytes In", 50, 171 75 24 8, tab 54 center
  edit "", 13, 197 74 25 10, tab 54 center
  text "Seconds", 14, 224 75 25 8, tab 54 center
  check "Control Codes", 20, 89 92 48 10, tab 54
  edit "", 41, 147 92 22 10, tab 54 limit 2 center
  text "Color/Bold/Underline/... per line", 52, 171 93 86 8, tab 54
  check "Caps Lock", 26, 89 110 39 10, tab 54
  edit "", 47, 147 110 18 10, tab 54 limit 3 center
  text "Capital letters per line", 59, 174 111 59 8, tab 54
  text "%", 58, 166 111 7 8, tab 54
  check "ASCII", 27, 89 128 30 10, tab 54
  edit "", 28, 147 128 18 10, tab 54 limit 3 center
  text "%", 29, 166 129 7 8, tab 54
  text "ASCII characters per line", 30, 174 129 68 8, tab 54
  tab "Flood", 89
  box "", 124, 81 46 187 60, tab 89
  check "Nick Flood", 16, 89 55 39 10, tab 89
  edit "", 37, 147 55 22 10, tab 89 limit 2 center
  text "Changes In", 48, 170 56 32 8, tab 89 center
  edit "", 60, 203 55 25 10, tab 89 limit 3 center
  text "Seconds", 69, 231 56 23 8, tab 89
  check "Join Flood", 17, 89 67 39 10, tab 89
  edit "", 38, 147 67 22 10, tab 89 limit 2 center
  text "Joins In", 49, 170 68 32 8, tab 89 center
  edit "", 61, 203 67 25 10, tab 89 limit 3 center
  text "Seconds", 70, 231 68 23 8, tab 89
  check "Clone", 25, 89 79 30 10, tab 89
  edit "", 46, 147 79 22 10, tab 89 limit 2 center
  text "Nicknames per host allowed", 57, 173 80 75 8, tab 89
  check "Fast Join/Part (Or Quit) In", 98, 89 91 65 10, tab 89
  edit "", 99, 203 91 25 10, tab 89 limit 1 center
  text "Seconds", 100, 231 92 23 8, tab 89
  box "", 125, 81 107 187 36, tab 89
  check "Channel CTCP", 21, 89 115 49 10, tab 89
  edit "", 42, 147 115 22 10, tab 89 limit 2 center
  text "CTCPs In", 53, 170 116 32 8, tab 89 center
  edit "", 65, 203 115 25 10, tab 89 limit 3 center
  text "Seconds", 74, 231 115 23 8, tab 89    
  check "Channel Notice Guard", 19, 89 127 69 10, tab 89
  box " Actions ", 126, 81 144 187 23
  text "Select a section:", 127, 85 153 44 8
  combo 128, 130 152 97 60, size drop
  button "&Modify", 129, 229 151 33 12
  list 200, -6 -1 290 30, size
  list 201, 4 3 25 25, size
  text "Channel Protections", 202, 29 3 253 15
  text "Now it's time to keep your channel(s) safe! :)", 203, 30 18 252 10
  ;button "&Help", 12, 111 173 35 12
  button "&OK", 9, 148 173 40 12
  button "&Apply", 10, 190 173 40 12
  button "&Close", 11, 232 173 40 12, cancel
}

dialog mB.Pro.Act {
  title "Actions - Channel Protections"
  size -1 -1 203 175
  option dbu
  icon $mB.Imgs(Protections.ico), 0
  box " Action ", 1, 2 2 90 51
  text "Action:", 2, 7 13 18 10
  combo 5, 28 12 60 50, size drop
  box " Auto Modes/Locks ", 8, 2 55 199 35
  text "Temp Bantime:", 9, 7 27 38 10
  edit "", 26, 58 26 30 10, limit 3 center
  text "Kick Bantime:", 27, 7 39 37 10
  edit "", 28, 58 38 30 10, limit 3 center
  box " Protected Users ", 10, 94 2 107 25
  check "Ops", 11, 101 12 28 10
  check "Hops", 12, 136 12 28 10
  check "Voices", 13, 169 12 29 10
  box " Bantype ", 14, 94 29 107 24
  combo 15, 97 38 99 55, size drop
  box " Reason ", 16, 2 92 199 65
  text "Warn:", 17, 5 118 17 10, right
  text "Ban:", 18, 5 130 17 10, right
  text "Kick:", 19, 5 142 17 10, right
  edit "", 20, 24 117 172 10, autohs
  edit "", 21, 24 129 172 10, autohs
  edit "", 22, 24 141 172 10, autohs
  button "&Done", 23, 117 160 40 12
  button "&Cancel", 24, 160 160 40 12, cancel
  check "After", 3, 6 64 23 10
  edit "", 4, 30 64 16 10, limit 1 center
  text "Bans In", 6, 47 65 22 10, center
  edit "", 7, 70 64 25 10, limit 3 center
  text "Seconds Of This Section Automatically-", 29, 96 65 96 10, center
  text "Change Channel Mode To", 30, 6 77 64 10
  edit "", 31, 70 76 25 10, center
  text "For", 32, 96 77 12 10, center
  edit "", 33, 109 76 25 10, limit 3 center
  text "Seconds.", 34, 137 77 26 10
  button "&Tags", 25, 3 160 40 12
  check "Send a reason to Kicked or Banned nick via notice", 35, 6 102 130 10
  text "", 100, -50 -50 10 10, hide disable
}


dialog mB.Pro.Ex {
  title "Expression Area - Channel Protections"
  size -1 -1 183 201
  option dbu
  icon $mB.Imgs(Protections.ico)
  box " Events ", 1, 3 1 87 65
  list 2, 7 11 79 50, size check
  box " Check on ", 3, 94 1 87 65
  list 4, 98 11 79 50, size check
  box " Expression ", 5, 3 68 178 59
  text "What kind of expression is it?", 6, 10 79 85 10
  radio "Wildcard", 7, 17 89 40 10, group
  radio "Token", 8, 65 89 40 10
  radio "RegEx", 9, 114 89 63 10
  text "The expression: (Tags: <Nick> - <Ident> - <Host> - <Line>)", 10, 10 102 150 10
  edit "", 11, 19 112 155 10, autohs
  box " Action ", 12, 3 129 178 54
  text "Type of Action:", 13, 10 140 40 10
  combo 14, 51 139 85 45, size drop
  text "Ban duration:", 15, 10 154 40 10
  edit "", 16, 51 153 20 10, autohs limit 3 center
  text "mins. (Note: 0 means permanent ban)", 17, 74 154 100 10
  text "Reason:", 18, 10 168 40 10
  edit "", 19, 51 167 123 10, autohs
  button "Add/Update", 20, 95 186 47 12
  button "&Close", 21, 143 186 37 12, cancel
  text "", 25, -20 -20 1 1, disable hide
  text "", 26, -30 -30 1 1, disable hide
}

dialog mB.Pro.Tags {
  title "Tags - Channel Protections"
  size -1 -1 190 98
  option dbu
  icon $mB.Imgs(Protections.ico)
  list 1, 1 1 186 80, size
  button "&Close", 2, 142 84 45 12, cancel
}

on *:dialog:mB.Pro:*:*:{
  if ($devent == close) { mB.Pro.Closed }
  elseif ($devent == init) {
    hOS EnableCloseBox $dialog($dname).hwnd true
    MDX MarkDialog $dname
    MDX SetMircVersion $version
    MDX SetBorderStyle $dname 200,201 Simple
    MDX SetControlMDX $dname 201 Toolbar Flat NoDivider Wrap List Arrows > $Bars
    MDX SetColor $dname 200,201,202,203 background $rgb(199,199,199)
    MDX SetColor $dname 200,201,202,203 textbg $rgb(199,199,199)
    MDX SetColor $dname 202 text $rgb(65,141,255)
    MDX SetColor $dname 203 text $rgb(0,0,0)
    MDX SetFont $dname 202 +a 25 700 Arial
    MDX SetFont $dname 203 +a 14 700 Arial
    did -i $dname 201 1 BmpSize 32 32
    did -i $dname 201 1 SetImage Icon Normal $noqt($mB.Imgs(Protections.ico))
    did -a $dname 201 +a 1 $chr(9) $+ Protections
    did -b $dname 200,201
    MDX SetControlMDX $dname 5 ListView AlignLeft RowSelect ShowSel Single Report Grid > $Views
    did -i $dname 5 1 HeaderDims 268:1 80:2 1:3
    did -i $dname 5 1 HeaderText Expression (Match text) $chr(9) Type $chr(9) ID
    did -hb $dname 126-129
    mB.Pro.CLoading
  }
  elseif ($devent == edit) {
    var %dids = 37 38 39 41 42 44 46 47 60 61 65 67 99
    if ($istok(%dids,$did,32)) {
      if ($did($did) !isnum) { did -r $dname $did }
    }
  }
  elseif ($devent == dclick) {
    if ($did == 5) { mB.Pro.Ex $$did(2).seltext $matchtok($did(5).seltext,Exp,1,32) }
  }
  elseif ($devent == sclick) {
    if ($istok(22 54 89,$did,32)) {
      if ($did != 22) { did -c $dname 128 1 }
      did $iif($did == 22,-hb,-ve) $dname 126-129 
    }
    elseif ($did == 2) {
      did -r $dname $mB.Pro.Edits
      did -u $dname $mB.Pro.Chks
      mB.Pro.Init $did(2).seltext
    }
    elseif ($did == 3) {
      var %n = #$$?="Enter A Channel"
      if (%n == $null) || (%n == $chr(35)) { mB.Pro.Error You should enter a Channel name to add it to list. | return }
      var %Result = $input(Do you want to make a clear settings OR $+ $crlf $+ copy the settings from Default? $+ $crlf $+ Click NO to make a Clear/New settings.,qyvg,Add A Channel)
      if (%Result == $yes) { .copy -o $qt($+($scriptdir,Default.chan)) $qt($+($scriptdir,%n,.chan)) }
      if (%Result == $no) { mB.Pro.Writes %n }
      mB.Pro.CLoading
    }
    elseif ($did == 4) {
      if ($did(2).seltext == $null) { mB.Pro.Error You should select a channel to remove it! | return }
      if ($did(2).seltext == Default) { mB.Pro.Error You can NOT remove default settings! | return }
      var %Result = $input(Are you sure? $+ $crlf $+ You want to remove selected channel settings?,qyvg,Removing A Channel)
      if (%Result == $yes) { .remove $qt($+($scriptdir,$did(2).seltext,.chan)) | mB.Pro.Error $did(2).seltext channel settings have been removed! }
      if (%Result == $no) return
      mB.Pro.CLoading
    }
    elseif ($istok(6 7 8,$did,32)) { 
      if ($did == 6) { mB.Pro.Ex $$did(2).seltext }
      if ($did(5).sel) {
        if ($did == 7) { mB.Pro.Ex $$did(2).seltext $matchtok($did(5).seltext,Exp,1,32) }
        elseif ($did == 8) { mB.Pro.Ex.Del $$did(2).seltext $matchtok($did(5).seltext,Exp,1,32) }
      }
    }
    elseif ($istok(9 10,$did,32)) { mB.Pro.Save.Set $did }
    elseif ($did == 120) {
      if (Select isin $did(120).seltext) { did -c $dname 120 $calc($did(120).sel + 1) }
    }
    elseif ($did == 129) && ($did(128).sel > 1) {
      var %x = Text Flood,Control Codes,Caps Lock,ASCII,Nick Flood,Join Flood,Clone Host,Channel Notice Guard,Channel CTCP,Fast Join/Part
      var %y = TextF CodeF Caps ASCII NickF JoinF Clone NoticeF CtcpF FJP
      mB.Pro.Act $did(2).seltext $gettok(%y,$findtok(%x,$did(128).seltext,44),32)
    }
  }
}

on *:dialog:mB.Pro.Act:*:*:{
  if ($devent == init) { mB.Pro.Lists }
  elseif ($devent == sclick) {
    if ($did == 23) {
      var %w = mB.Pro.Write $did(mB.Pro,2).seltext $did(100)
      %w Act $did(5).sel
      var %m = $+($iif($did(11).state == 1,o),$iif($did(12).state == 1,h),$iif($did(13).state == 1,v))
      %w Protects $iif(%m != $null,$v1,0)
      %w BTime $iif($did(26) != $null,$v1,60)
      %w KBTime $iif($did(28) != $null,$v1,90)
      %w Res $did(35).state
      %w WRes $iif($did(20) != $null,$v1,No reason specified.)
      %w BRes $iif($did(21) != $null,$v1,No reason specified.)
      %w KRes $iif($did(22) != $null,$v1,No reason specified.)
      %w Btype $calc($did(15).sel - 1)
      %w MStatus $did(3).state
      %w MCount $iif($did(4) != $null,$v1,4)
      %w MIn $iif($did(7) != $null,$v1,60)
      %w MMode $iif($did(31) != $null,$v1,-)
      %w MFor $iif($did(33) != $null,$v1,240)
      dialog -x $dname
    }
    elseif ($did == 25) { mB.Pro.Tags }
  }
}

on *:dialog:mB.Pro.Ex:*:*:{
  if ($devent == sclick) {
    if ($did == 20) {
      if ($remove($did(11),$chr(32),$chr(9)) == $null) { beep | return }

      var %x = 1,%e
      while ($did(2,%x)) {
        if ($did(2,%x).cstate) {
          %e = %e $gettok(Text Action Notice Nick Join Part Quit,$findtok(Normal Text-Action Text-Channel Notice-Nick Change-Join-Part-Quit,$did(2,%x),1,45),32)
        }
        inc %x
      }

      if ($remove(%e,$chr(32)) == $null) { beep | return }

      var %y = 1,%c
      while ($did(4,%y)) {
        if ($did(4,%y).cstate) { %c = %c $gettok($did(4,%y),1,32) }
        inc %y
      }

      if ($remove(%c,$chr(32)) == $null) { beep | return }

      var %k = $+($iif($did(7).state,Wildcard),$iif($did(8).state,Token),$iif($did(9).state,RegEx))

      var %id
      if ($did(26) != $null) { %id = $v1 }
      else { 
        var %i = 1
        while (%i) {
          if ($mB.Pro.Read($did(25),$+(Exp,%i),Exp) == $null) { %id = $+(Exp,%i) | break }
          inc %i
        }
      }

      var %w = mB.Pro.Write $did(25).text %id
      %w Events %e
      %w CheckOn %c
      %w Kind %k
      %w Exp $did(11)
      %w Action $did(14).sel
      %w Duration $iif($did(16),$v1,0)
      %w Reason $iif($did(19),$v1,No reason specified.)
      dialog -c $dname
      mB.Pro.LoadExpressions
    }
  }
}

on *:dialog:mB.Pro.Tags:init:*:{
  MDX SetMircVersion $version
  MDX MarkDialog $dname
  MDX SetBorderStyle 1 border
  MDX SetControlMDX $dname 1 ListView ExtSel Report RowSelect ShowSel Single Grid > $Views
  did -i $dname 1 1 HeaderDims 60 290
  did -i $dname 1 1 HeaderText Tags $chr(9) Descriptions
  did -a $dname 1 <TBT> $chr(9) Returns Temp Ban duration.
  did -a $dname 1 <KBT> $chr(9) Returns Kick/Ban duration.
  did -a $dname 1 <KC> $chr(9) Returns Kick Counter of the Channel.
  did -a $dname 1 <BC> $chr(9) Returns Ban Counter of the Channel.
  ;did -a $dname 1 <BW> $chr(9) Returns current Badword.
  ;did -a $dname 1 <Bi> $chr(9) Returns current Bad Ident.
  ;did -a $dname 1 <LC> $chr(9) Returns Limited Codes.
  ;did -a $dname 1 <TL> $chr(9) Returns Text limit.
  ;did -a $dname 1 <PCL> $chr(9) Returns Limited Percentage of CapsLock.
}

alias -l mB.Pro.ASCIICheck {
  if ($1) && ($len($2-) > 0) {
    var %a = 1,%b = 0,%c = $len($2-)
    while (%a <= %c) {
      var %x = $mid($2-,%a,1)
      if (%x) && (%x != $chr(32)) && (%x !isalpha) { inc %b }
      inc %a
    }
    return $iif($mB.Pro.ToPercent(%b,%c,0) >= $mB.Pro.Read($1,ASCII,Percent),$true,$false)
  }
}

alias mB.Pro.CapsCheck {
  if ($1 != $null) && ($len($2-) > 8) {
    var %a = 1,%b = 0,%c = $len($2-)
    while (%a <= %c) {
      var %x = $mid($2-,%a,1)
      if (%x isalpha) && ($isupper(%x)) { inc %b }
      inc %a
    }
    return $iif($mB.Pro.ToPercent(%b,%c,0) >= $mB.Pro.Read($1,Caps,Percent),$true,$false)

    ;var %data = $regsubex($2-,/\W/g,)
    ;var %caps = $round($calc(100 * $regex($2-,/[A-Z]/g) / $len(%data)),1)
    ;return $iif(%caps > $mB.Pro.Read($1,Caps,Percent),$true,$false)
  }
}

alias -l mB.Pro.ToPercent {
  if ($1 isnum) && ($2 isnum) { var %result = $round($calc($calc($2 / $1) * 100),$iif($3 != $null && $3 isnum,$3,0)) }
  return $iif(%result,$v1,0)
}

alias -l mB.Pro.CodesCheck { return $count($1-,$chr(2),$chr(3),$chr(15),$chr(22),$chr(29),$chr(31)) }

alias -l mB.Pro.SaveCount {
  if ($1) && ($2) && ($3 isnum) {
    var %file = $iif($mB.Pro.File($1), $1, Default),%c = $mB.Pro.Read(%file,Status,$2)
    mB.Pro.Write %file Status $2 $iif(%c && %c isnum,$calc(%c + $3),$3)
  }
}

alias -l mB.Pro.BadwordSen {
  if ($len($1) == 1) { return $chr(42) }
  elseif ($len($1) == 2) { return $+($left($1,1),$chr(42)) }
  else {
    if ($len($1) <= 3) { var %x = 1 | goto M }
    elseif ($len($1) >= 4) && ($len($1) <= 6) { var %x = 2 | goto M }
    else { var %x = 3 }
    :M
    if ($len($1) >= 10) { var %x = 5 }
    if ($calc($calc($len($1) - %x) % 2) == 0) { var %r = $calc($calc($len($1) - %x) / 2) | var %l = %r }
    elseif ($calc($calc($len($1) - %x) % 2) != 0) { var %l = $calc($calc($len($1) - %x - 1) / 2) | var %r = $calc(%l + 1) }
    return $+($left($1,%r),$str($chr(42),%x),$right($1,%l))
  }
}

alias mB.Pro.ExpCheck {
  if ($0 > 6) {
    ; $1 = event - $2 = network - $3 = chan - $4 = nick - $5 = ident - $6 = ip - $7- = line
    var %x = $mB.Pro.Ini($3,0).Items
    while (%x) {
      var %item = $mB.Pro.Ini($3,%x)
      if (Exp* iswm %item) {
        if ($istok($mB.Pro.Read($3, %item, Events), $1, 32)) {
          var %c = $mB.Pro.Read($3, %item, CheckOn)
          var %kind = $mB.Pro.Read($3, %item, Kind)
          var %exp = $replace($mB.Pro.Read($3, %item, Exp), <Nick>, $4, <Ident>, $5, <Host>, $6, <Line>, $7-)
          if (%kind == Wildcard) {
            if ($istok(%c, Nick, 32)) && (%exp iswm $4) { return $true }
            elseif ($istok(%c, Ident, 32)) && (%exp iswm $5) { return $true }
            elseif ($istok(%c, Host, 32)) && (%exp iswm $6) { return $true }
            elseif ($istok(%c, Message, 32)) && (%exp iswm $7-) { return $true }
          }
          elseif (%kind == Token) {
            if ($istok(%c, Nick, 32)) && ($istok(%exp, $4, 32)) { return $true }
            elseif ($istok(%c, Ident, 32)) && ($istok(%exp, $5, 32)) { return $true }
            elseif ($istok(%c, Host, 32)) && ($istok(%exp, $6, 32)) { return $true }
            elseif ($istok(%c, Message, 32)) && ($istok(%exp, $7-, 32)) { return $true }
          }
          elseif (%kind == RegEx) { }
        }
      }
      dec %x
    }
  }
  return $false
}

alias mB.Pro.Parse {
  var %event = $1,%net = $2,%chan = $3,%addr = $4,%nick = $gettok($4,1,33),%ident = $gettok($gettok($4,2,33),1,64),%ip = $gettok($4,2,64),%line = $5-
  if ($mB.Members.Check(%net,%chan,NoBan,%addr) != $null) return
  if ($mB.Pro.ExpCheck(%event, %net, %chan, %nick, %ident, %ip, %line)) { 
    ; Positive match found, Need to do some stuff to ban the user 
    return
  }
  if ($istok(NickServ ChanServ OperServ MemoServ HostServ GameServ SeenServ HelpServ,%nick,32)) || (*.* iswm %nick) return
  if (%event == Notice) {
    if ($mB.Pro.Read(%chan,Status,Status) == 1) && ($mB.Pro.Read(%chan,NoticeF,Status) == 1) { mB.Pro.Actions NoticeF %nick %chan | return }
  }
  if ($istok(Action Text,%event,32)) {
    if ($mB.Pro.Read(%chan,Status,Status) == 1) {
      if ($mB.Pro.Read(%chan,Spam,Status) == 1) {
        var %x = $mB.Pro.Read(%chan,Spam,Words)
        if ($wildtok(%x,%line,0,44)) { mB.Pro.Actions Spam %nick %chan $wildtok(%x,%line,1,44) | return }
      }

      if ($mB.Pro.Read(%chan,CodeF,Status) == 1) {
        if ($mB.Pro.CodesCheck(%chan,%line) >= $mB.Pro.Read(%chan,CodeF,Max)) { mB.Pro.Actions CodeF %nick %chan | return }
      }
      if ($mB.Pro.Read(%chan,ASCII,Status) == 1) {
        if ($mB.Pro.ASCIICheck(%line)) { mB.Pro.Actions ASCII %nick %chan }
      }
      if ($mB.Pro.Read(%chan,Caps,Status) == 1) {
        if ($mB.Pro.CapsCheck(%chan,%line)) { mB.Pro.Actions Caps %nick %chan | return }
      }
      if ($mB.Pro.Read(%chan,TextF,Status) == 1) {
        if ($+(%,DC.Suspect.,%net,.,%chan,.,%nick) == %line) { inc $+(%,DC.SuspectZ.,%net,.,%chan,.,%nick) }
        if ($+(!%,DC.Suspect.,%net,.,%chan,.,%nick)) {
          set $+(-u,$mB.Pro.Read(%chan,TextF,Secs)) $+(%,DC.Suspect.,%net,.,%chan,.,%nick) %line
          inc $+(-u,$mB.Pro.Read(%chan,TextF,Secs)) $+(%,DC.SuspectZ.,%net,.,%chan,.,%nick)
        }
        if ($($+(%,DC.Suspect.,%net,.,%chan,.,%nick),2) != %line) {
          set $+(-u,$mB.Pro.Read(%chan,TextF,Secs)) $+(%,DC.Suspect.,%net,.,%chan,.,%nick) %line
          set $+(-u,$mB.Pro.Read(%chan,TextF,Secs)) $+(%,DC.SuspectZ.,%net,.,%chan,.,%nick) 1
        }
        if ($($+(%,DC.SuspectZ.,%net,.,%chan,.,%nick),2) >= $mB.Pro.Read(%chan,TextF,Times)) {
          unset $+(%,DC.Suspect.,%net,.,%chan,.,%nick)
          unset $+(%,DC.SuspectZ.,%net,.,%chan,.,%nick)
          mB.Pro.Actions TextF %nick %chan
          return
        }
      }
    }
  }
  elseif ($istok(Part Quit Join,%event,32)) {
    if ($mB.Pro.Read(%chan,Status,Status) == 1) {
      if ($mB.Pro.Read(%chan,FJP,Status) == 1) && ($istok(Part Join Quit,%event,32)) {
        if ($($+(%,DC.FJP.,%net,.,%chan,.,%nick),2) == Go) { unset $+(%,DC.JP.,%net,.,%chan,.,%nick) | mB.Pro.Actions FJP %nick %chan }
        else { set $+(-u,$mB.Pro.Read(%chan,FJP,Secs)) $+(%,DC.FJP.,%net,.,%chan,.,%nick) Go }
      }
      if ($mB.Pro.Read(%chan,JoinF,Status) == 1) {
        if ($($+(%,DC.JoinF.,%net,.,%chan),2) == $null) { set $+(-u,$mB.Pro.Read(%chan,JoinF,Secs)) $+(%,DC.JoinF.,%net,.,%chan) 1 }
        else { inc $+(%,DC.JoinF.,%net,.,%chan) }
        set $+(-u,$mB.Pro.Read(%chan,JoinF,Secs)) $+(%,DC.JoinF.,%net,.,%chan,.,%nick) 1
        if ($($+(%,DC.JoinF.,%net,.,%chan),2) >= $mB.Pro.Read(%chan,JoinF,Times)) {
          unset $+(%,DC.JoinF.,$network,.,$chan)
          mB.Pro.Actions JoinF %nick %chan
          return
        }
      }
    }
  }

  elseif (%event == CTCP) {
    if ($mB.Pro.Read($chan,CtcpF,Status) == 1) {
      if ($mB.Pro.Read(%chan,Spam,Status) == 1) {
        var %x = $mB.Pro.Read(%chan,Spam,Words)
        if ($wildtok(%x,%line,0,44)) { mB.Pro.Actions Spam %nick %chan $wildtok(%x,%line,1,44) | return }
      }
      if ($($+(!%,DC.CtcpF.,%net,.,%chan),2)) { set $+(-u,$mB.Pro.Read(%chan,CtcpF,Secs)) $+(%,DC.CtcpF.,%net,.,%chan) 1 }
      else { inc $+(%,DC.CtcpF.,%net,.,%chan) }
      set $+(-u,$mB.Pro.Read(%chan,CtcpF,Secs)) $+(%,DC.CtcpF.,%net,.,%chan,.,%nick) 1
      if ($+(%,DC.CtcpF.,$network,.,%chan) >= $mB.Pro.Read($chan,CtcpF,Times)) {
        unset $+(%,DC.CtcpF.,%net,.,%chan)
        mB.Pro.Actions CtcpF %nick %chan
        return
      }
    }
  }

  elseif (%event == Nick) {
    if ($mB.Pro.Read(%chan,NickF,Status) == 1) {
      var %c = 1
      while ($comchan($newnick,%c)) {
        var %_chan = $v1
        if (!$Pro.CheckUp(%_chan)) { inc %c | continue }
        if ($+(%,DC.NickF.,%net,.,%_chan) == $null) {
          set $+(-u,$mB.Pro.Read(%_chan,NickF,Secs)) $+(%,DC.NickF.,%net,.,%_chan) 1
          set $+(-u,$mB.Pro.Read(%_chan,NickF,Secs)) $+(%,DC.NickF.,%net,.,%_chan,.,$newnick) 1
          unset $+(%,DC.NickF.,%net,.,%_chan,.,%nick)
        }
        else {
          inc $+(%,DC.NickF.,%net,.,%_chan)
          if ($($+(%,DC.NickF.,%net,.,%_chan),2) >= $mB.Pro.Read(%_chan,NickF,Times)) {
            unset $+(%,DC.NickF.,%net,.,%_chan)
            mB.Pro.Actions NickF $newnick %_chan
          }
        }
        inc %c
      }
    }
  }
}

alias mB.Pro.Actions {
  ; $1 = Section - $2 = $nick - $3 = $chan
  if ($me isop $3) {
    if ($($+(%,DC.Ban.,$network,.,$3,.,$2),2) == $null) {
      if ($mB.Pro.Read($3,$1,Act) == 1) { unset $+(%,DC.Ban.,$network,.,$3,.,$2) | return }
      var %m
      if ($2 isop $3) { %m = $+(%m,o) }
      if ($2 ishop $3) { %m = $+(%m,h) }
      if ($2 isvoice $3) { %m = $+(%m,v) }
      if ($len(%m) > 0) { mB.Queue -a h mode $3 $+(-,%m) $str($2 $+ $chr(32),$v1) }
      var %o = Spam NickF NoticeF CodeF CtcpF TextF Caps ASCII FJP
      if ($istok(%o,$1,32)) {
        if ($mB.Pro.Read($3,$1,Act) == 2) {
          if ($+(%,DC.Warn.,$network,.,$3,.,$1) == $null) { set $+(%,DC.Warn.,$network,.,$3,.,$1) Warned | inc %w | goto end }
          elseif ($+(%,DC.Warn.,$network,.,$3,.,$1) == Warned) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,$1,TBT)) $3 $2 $mB.Pro.Read($3,$1,Btype) | inc %b | goto end }
        }
        elseif ($mB.Pro.Read($3,$1,Act) == 3) || ($mB.Pro.Read($3,$1,Act) == 4) {
          if ($mB.Pro.Read($3,$1,Btype) isnum 0-9) {
            if ($mB.Pro.Read($3,$1,Act) == 3) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,$1,TBT)) $3 $2 $mB.Pro.Read($3,$1,Btype) }
            else { mB.Queue -a ban $3 $2 $mB.Pro.Read($3,$1,Btype) }
            inc %b
            goto end
          }
          else {
            if ($mB.Pro.Read($3,$1,Btype) == 10) {
              if ($mB.Pro.Read($3,$1,Act) == 3) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,$1,TBT)) $3 $+($2,!*@*) }
              else { ban $3 $+($2,!*@*) }
              inc %b
              goto end
            }
            if ($mB.Pro.Read($3,$1,Btype) == 11) {
              if ($mB.Pro.Read($3,$1,Act) == 3) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,$1,TBT)) $3 $4 }
              else { ban $3 $4 }
              inc %b
              goto end
            }
          }
        }
        elseif ($mB.Pro.Read($3,$1,Act) == 5) goto Kick
        elseif ($mB.Pro.Read($3,$1,Act) == 6) {
          if ($mB.Pro.Read($3,$1,Btype) isnum 0-9) { 
            if ($mB.Pro.Read($3,$1,Act) == 3) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,$1,KBT)) $3 $2 $mB.Pro.Read($3,$1,Btype) }
            else { mB.Queue -a h ban $3 $2 $mB.Pro.Read($3,$1,Btype) }
            inc %b
            goto Kick
          }
          else {
            if ($mB.Pro.Read($3,$1,Btype) == 10) {
              if ($mB.Pro.Read($3,$1,Act) == 3) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,$1,TBT)) $3 $+($2,*!*@*) }
              else { ban $3 $+($2,*!*@*) }
              inc %b
              goto Kick
            }
            if ($mB.Pro.Read($3,$1,Btype) == 11) {
              if ($mB.Pro.Read($3,$1,Act) == 3) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,$1,TBT)) $3 $4 | goto end }
              if ($mB.Pro.Read($3,$1,Act) == 4) || ($mB.Pro.Read($3,$1,Act) == 6) { mB.Queue -a h ban $3 $4 $GetIdent($address($2,5)) | inc %b }
              if ($mB.Pro.Read($3,$1,Act) == 5) || ($mB.Pro.Read($3,$1,Act) == 6) goto Kick
              goto end
            }
          }
        }
      }
      elseif ($1 == JoinF) { }
      elseif ($1 == Clone) {
        if ($mB.Pro.Read($3,$1,Act) == 2) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,Clone,KBT)) $3 $address($2,2) | inc %b | goto end }
        elseif ($mB.Pro.Read($3,$1,Act) == 3) { mB.Queue -a h ban $+(-u,$mB.Pro.Read($3,Clone,KBT)) $3 $address($2,7) | goto kick }
        elseif ($istok(4 5, $mB.Pro.Read($3,$1,Act), 32)) { DC.Clone.KA $iif($mB.Pro.Read($3,$1,Act) == 5,-b) $3 $address($2,2) | inc %b | goto end }
      }
      :Kick
      kick $3 $2 $DC.Reason($1,$2,$3,KRes)
      inc %k
      :end
      if ($Logger) { 
        var %names = Spamming, Nick Flood, Notice Flood, Excessive use of Control Codes, CTCP Flood, Text Flood (Repeating or Large messages.), Excessive use of Caps Lock, Excessive use of ASCII Codes, Fast Join/Part (Or Quit)
        DoLog $network $3 $2 was banned for $gettok(%names,$findtok(%o,$1,1,32),44) $+ .
      }
      set -u10 $+(%,DC.Ban.,$network,.,$3,.,$2) 1
      if ($mB.Pro.Read($3,$1,Res) == 1) {
        if (%WRes) { mB.Queue -a notice $2 $DC.Reason($1,$2,$3,WRes,$iif($4, $4)) | unset %WRes }
        else { mB.Queue -a notice $2 $DC.Reason($1,$2,$3,BRes,$iif($4, $4)) }
      }
      if (%w) { mB.Pro.SaveCount $3 WCount %w | unset %w }
      if (%b) { mB.Pro.SaveCount $3 BCount %b | unset %b }
      if (%k) { mB.Pro.SaveCount $3 KCount %k | unset %k }
    }
  }
}
