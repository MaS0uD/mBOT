; ******************************************************
;             DC mBOT - Extra Settings
; ******************************************************
alias mB.Extra { mDialog mB.Extra }
dialog mB.Extra {
  title "Extra Features - mBOT [F4]"
  size -1 -1 215 204
  option dbu
  icon $mB.Imgs(Extra.ico), 0
  list 1, -6 -1 225 30, size
  list 2, 4 4 25 25, size
  text "Extra Settings", 3, 29 3 188 15
  text "Use Channel Manager to add/remove them to your channels.", 4, 30 17 187 10
  button "&OK", 6, 89 189 40 12, default
  button "&Apply", 7, 171 189 40 12
  button "&Cancel", 8, 130 189 40 12, cancel
  tab "Auto Voice", 9, 4 33 208 153
  box " Auto Voicer ", 10, 9 51 198 43, tab 9
  text "Give voice to chatters when they talked over:", 11, 16 62 122 10, tab 9
  edit "", 12, 26 76 22 10, tab 9 limit 4 center
  combo 13, 50 76 36 30, tab 9 size drop
  edit "", 14, 88 76 22 10, tab 9 limit 3 center
  text "Minutes", 15, 112 77 25 10, tab 9
  box " Auto Devoicer ", 16, 9 100 198 45, tab 9
  text "Auto devoice users if they had over", 17, 16 111 90 10, tab 9
  edit "", 18, 107 111 22 10, tab 9 limit 3 center
  text "Minutes idle on channel", 19, 131 112 61 10, tab 9
  text "Check user's idle every", 20, 16 129 60 10, tab 9
  edit "", 21, 77 128 22 10, tab 9 limit 3 center
  text "Seconds", 22, 101 129 25 10, tab 9
  box " No Voice List ", 23, 9 152 198 30, tab 9
  combo 24, 16 165 120 40, tab 9 size drop
  button "+", 25, 139 164 12 12, tab 9
  button "-", 26, 153 164 12 12, tab 9
  tab "Limiter && Top10", 27
  box " Channel Limiter ", 28, 9 51 198 54, tab 27
  text "Offset:", 30, 16 63 25 10, tab 27
  edit "", 31, 44 62 22 10, tab 27 limit 1 center
  text "Method:", 32, 16 79 25 10, tab 27
  radio "Check upon user's Join/Part (Not recommended.)", 33, 44 78 136 10, group tab 27
  radio "Check by Timer, every", 34, 44 90 66 10, tab 27
  edit "", 35, 111 90 22 10, tab 27 limit 2 center
  text "Minutes", 36, 136 91 25 10, tab 27
  box " Top10 Data Management ", 37, 9 107 198 75, tab 27
  text "Current databases:", 38, 16 119 51 10, tab 27
  combo 39, 69 118 107 50, tab 27 size drop
  button "-", 40, 178 117 12 12, tab 27
  text "Optimize every database and remove useless items >", 41, 16 151 131 10, tab 27
  button "Optimize now!", 42, 150 149 54 12, tab 27
  text "Purge all databases and start over >", 43, 16 166 131 10, tab 27
  button "Purge now!", 44, 150 164 54 12, tab 27
  text "Ignore these nicks:", 75, 16 135 51 8, tab 27
  combo 76, 69 134 107 50, tab 27 size drop
  button "+", 78, 192 133 12 12, tab 27
  button "-", 77, 178 133 12 12, tab 27
  tab "Output Msgs.", 45
  box "", 46, 9 51 198 131, tab 45
  text "Weather:", 50, 14 62 31 8, tab 45
  edit "", 51, 23 71 132 10, tab 45 autohs
  combo 52, 157 71 45 42, tab 45 size drop
  text "IP Locator:", 53, 14 85 36 8, tab 45
  edit "", 54, 23 94 132 10, tab 45 autohs
  combo 55, 157 94 45 42, tab 45 size drop
  text "Ping Replyer:", 56, 14 108 40 8, tab 45
  edit "", 57, 23 117 132 10, tab 45 autohs
  combo 58, 157 117 45 42, tab 45 size drop
  text "System Info:", 59, 14 131 41 8, tab 45
  edit "", 60, 23 140 132 10, tab 45 autohs
  combo 61, 157 140 45 42, tab 45 size drop
  text "Quote:", 80, 14 155 27 8, tab 45
  edit "", 79, 23 164 132 10, autohs tab 45
  combo 29, 157 164 45 42, size drop tab 45
  tab "Top10 Output Msgs.", 5
  box "", 62, 9 51 198 131, tab 5
  text "Top 10-100:", 63, 14 62 42 8, tab 5
  edit "", 64, 23 72 132 10, tab 5 autohs
  combo 65, 157 72 45 42, tab 5 size drop
  text "Today statistics:", 66, 14 108 47 8, tab 5
  edit "", 67, 23 117 132 10, tab 5 autohs
  combo 68, 157 117 45 42, tab 5 size drop
  text "Individual person stats:", 69, 14 85 63 8, tab 5
  edit "", 70, 23 94 132 10, tab 5
  combo 71, 157 94 45 42, tab 5 size drop
  text "Daily statistics:", 72, 14 131 47 8, tab 5
  edit "", 73, 23 140 132 10, tab 5
  combo 74, 157 140 45 42, tab 5 size drop
  text "Overall statistics:", 47, 14 154 49 8, tab 5
  edit "", 48, 23 163 132 10, tab 5 autohs
  combo 49, 157 163 45 42, tab 5 size drop
}

on *:dialog:mB.Extra:*:*:{
  if ($devent == init) {
    MDX MarkDialog $dname
    MDX SetMircVersion $version
    MDX SetBorderStyle $dname 1,2 simple
    MDX SetControlMDX $dname 2 Toolbar flat nodivider wrap list arrows > $Bars
    MDX SetColor $dname 1,2,3,4 background $rgb(199,199,199)
    MDX SetColor $dname 1,2,3,4 textbg $rgb(199,199,199)
    MDX SetColor $dname 1,3 text $rgb(65,141,255)
    MDX SetColor $dname 4 text $rgb(0,0,0)
    MDX SetFont $dname 3 +a 25 700 Arial
    MDX SetFont $dname 4 +a 14 700 Arial
    did -i $dname 2 1 bmpsize 32 32
    did -i $dname 2 1 setimage icon normal $noqt($mB.Imgs(Extra.ico))
    did -a $dname 2 +a 1 $chr(9) $+ Extra Settings
    did -b $dname 1,2
    didtok $dname 13 44 Words,Letters
    didtok $dname 29,52,55,58,61,65,68,71 44 Notice Nick,Msg Nick,Msg Channel,Describe Channel
    didtok $dname 49,74 44 Msg Channel,Describe Channel,Notice Channel
    mB.Extra.Init
  }
  if ($devent == sclick) {
    if ($istok(6 7,$did,32)) { 
      if ($did == 7) { did -b $dname $did }
      var %x = mB.Write Extra,%b = $iif($did(13).sel == 1,W,L)
      %x Voice AVMethod $did(13).sel
      if ($did(12) != $null) { %x Voice $+(AVCount,%b) $v1 }
      if ($did(14) != $null) { %x Voice $+(AVTime,%b) $v1 }
      if ($did(18) != $null) { %x Voice ADVIdle $v1 }
      if ($did(21) != $null) { %x Voice ADVCheck $v1 }
      var %a = 1,%nv
      while ($did(24,%a)) { %nv = $addtok(%nv,$did(24,%a),32) | inc %a }
      if (%nv != $null) { %x Voice NoVoice $v1 }
      else { mB.Remove Extra Voice NoVoice }
      if ($did(31) != $null) { %x Limiter OffSet $v1 }
      %x Limiter Method $iif($did(33).state,1,2)
      if ($did(35) != $null) { %x Limiter Every $v1 }
      if ($did(48) != $null) { %x Msgs OverallStat $v1 }
      %x Msgs OverallStatM $did(49).sel
      if ($did(51) != $null) { %x Msgs Weather $v1 }
      %x Msgs WeatherM $did(52).sel
      if ($did(54) != $null) { %x Msgs IP $v1 }
      %x Msgs IPM $did(55).sel
      if ($did(57) != $null) { %x Msgs Ping $v1 }
      %x Msgs PingM $did(58).sel
      if ($did(60) != $null) { %x Msgs SysInfo $v1 }
      %x Msgs SysInfoM $did(61).sel
      if ($did(79) != $null) { %x Msgs Quote $v1 }
      %x Msgs QuoteM $did(29).sel
      if ($did(64) != $null) { %x Msgs Top $v1 }
      %x Msgs TopM $did(65).sel
      if ($did(67) != $null) { %x Msgs TStat $v1 }
      %x Msgs TStatM $did(68).sel
      if ($did(70) != $null) { %x Msgs Stat $v1 }
      %x Msgs StatM $did(71).sel
      if ($did(73) != $null) { %x Msgs TopDaily $v1 }
      %x Msgs TopDailyM $did(74).sel

      if ($did == 7) { did -e $dname $did }
      else { dialog -c $dname }
    }
    elseif ($did == 25) {
      var %msg = You can use ? and * for wildcard match. You can also specify a channel by using an @. (Examples: Nick - Nick* - Nick???@#MyChannel ...)
      var %input = $remove($$?=" %msg ",$chr(32))
      if (%input != $null) {
        if ($istok($didtok($dname,24,32),%input,32)) { .noop $input($qt(%input) already exists in the list.,hdogk30,Duplicated item) | return }
        else { did -a $dname 24 %input }
      }
    }
    elseif ($did == 26) {
      if ($did(24).seltext != $null) { did -d $dname 24 $did(24).sel }
    }
    elseif ($did == 40) {
      if ($did(39).sel) { 
        if ($input(Are you sure? You want to DELETE $+(',$gettok($did(39).seltext,1,32),'?),wyvg,Confirmation) == $yes) {
          .hfree -w $+(Top.,$gettok($did(39).seltext,1,32))
          var %file = $mB.Top($+(Top.,$gettok($did(39).seltext,1,32),.db))
          if ($exists(%file)) { .remove %file }
          did -d $dname 39 $did(39).sel
        }
      }
    }
    elseif ($did == 42) {
      did -b $dname $did
      var %output = $Top.OptimizeAll,%msg = Optimization completed. $+ $crlf $+ $gettok(%output,2,32) useless items has been removed from $gettok(%output,1,32) databases.
      .noop $input(%msg,iog,Operation successful)
      did -r $dname 39
      var %x = 1
      while ($hget(%x)) {
        WhileFix
        if (Top.* iswm $hget(%x)) { did -a $dname 39 $gettok($v2,2-,46) $+($chr(40),$hget(%x,0).item,$chr(41)) }
        inc %x
      }
      did -e $dname $did
    }
    elseif ($did == 44) {
      if ($input(Are you sure? You want to DELETE ALL the top10 databses?,wyvg,Confirmation) == $yes) {
        .hfree -w Top.*
        did -r $dname 39
      }
    }
  }
}

alias mB.Extra.Init {
  var %c = did -c mB.Extra,%a = did -a mB.Extra

  if ($mB.Read(Extra,Voice,AVMethod) != $null) {
    var %y = $v1,%b = $iif(%y == 1,W,L)
    %c 13 %y
    if ($mB.Read(Extra,Voice,$+(AVCount,%b)) != $null) { %a 12 $v1 }
    if ($mB.Read(Extra,Voice,$+(AVTime,%b)) != $null) { %a 14 $v1 }
  }
  if ($mB.Read(Extra,Voice,ADVIdle) != $null) { %a 18 $v1 }
  if ($mB.Read(Extra,Voice,ADVCheck) != $null) { %a 21 $v1 }
  if ($mB.Read(Extra,Voice,NoVoice) != $null) { didtok mB.Extra 24 32 $v1 }
  if ($mB.Read(Extra,Limiter,OffSet)) { %a 31 $v1 }
  %c $iif($mB.Read(Extra,Limiter,Method) == 1,33,34)
  if ($mB.Read(Extra,Limiter,Every) != $null) { %a 35 $v1 }
  if ($mB.Read(Extra,Msgs,OverallStat) != $null) { %a 48 $v1 }
  %c 49 $iif($mB.Read(Extra,Msgs,OverallStatM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,Weather) != $null) { %a 51 $v1 }
  %c 52 $iif($mB.Read(Extra,Msgs,WeatherM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,IP) != $null) { %a 54 $v1 }
  %c 55 $iif($mB.Read(Extra,Msgs,IPM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,Ping) != $null) { %a 57 $v1 }
  %c 58 $iif($mB.Read(Extra,Msgs,PingM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,SysInfo) != $null) { %a 60 $v1 }
  %c 61 $iif($mB.Read(Extra,Msgs,SysInfoM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,Quote) != $null) { %a 79 $v1 }
  %c 29 $iif($mB.Read(Extra,Msgs,QuoteM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,Top) != $null) { %a 64 $v1 }
  %c 65 $iif($mB.Read(Extra,Msgs,TopM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,TStat) != $null) { %a 67 $v1 }
  %c 68 $iif($mB.Read(Extra,Msgs,TStatM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,Stat) != $null) { %a 70 $v1 }
  %c 71 $iif($mB.Read(Extra,Msgs,StatM) != $null,$v1,1)
  if ($mB.Read(Extra,Msgs,TopDaily) != $null) { %a 73 $v1 }
  %c 74 $iif($mB.Read(Extra,Msgs,TopDailyM) != $null,$v1,1)

  did -r mB.Extra 39
  var %x = 1
  while ($hget(%x)) {
    WhileFix
    if (Top.* iswm $hget(%x)) { %a 39 $gettok($v2,2-,46) $+($chr(40),$hget(%x,0).item,$chr(41)) }
    inc %x
  }
}

;-------------------------------

; [Auto Voice/Devoice and Limiter]
alias mB.Voice {
  if ($1-4) {
    var %x = $+(AV,.,$1,.,$2)
    if (!$hget(%x)) { .hmake %x 1000 }
    if (!$hget(%x,$3).item) {
      var %time = $calc($iif($mB.Read(Extra,Voice,AVMethod) == 1,$mB.Read(Extra,Voice,AVTimeL),$mB.Read(Extra,Voice,AVTimeW)) * 60)
      hadd $+(-mu,%time) %x $3 $iif($4 isnum,$4,0)
      return
    }
    hinc -m %x $3 $iif($4 isnum,$4,0)
    var %len = $iif($mB.Read(Extra,Voice,AVMethod) == 1,$mB.Read(Extra,Voice,AVCountL),$mB.Read(Extra,Voice,AVCountW))
    if ($hget(%x,$3) >= %len) {
      if ($3 !isreg $2) { .hdel %x $3 | return }
      if ($me isop $2) { mB.Queue -a h mode $2 +v $3 }
      .hdel %x $3
    }
  }
}

alias mB.NoVoice {
  if (!$1) return $false
  var %x = 1,%nv = $mB.Read(Extra,Voice,NoVoice)
  while ($gettok(%nv,%x,32)) {
    var %t = $v1
    if ($numtok(%t,64) == 1) && (%t iswm $1) return $true
    elseif ($numtok(%t,64) == 2) && ($gettok(%t,1,64) iswm $1) && ($gettok(%t,2,64) == $2) return $true
    inc %x
  }
  return $false
}

alias mB.CheckIdle {
  var %i = $iif($mB.Read(Extra,Voice,ADVIdle) != $null,$v1,30)
  var %idle = $calc(%i * 60),%x = $chan(0)
  while (%x) {
    var %c = $chan(%x)
    if ($mB.Channels($network,%c).ADV) {
      var %y = $nick(%c,0,v),%nicks
      while (%y) {
        var %ex = $mB.Members.Check($network,%c,CheckIdle,$address($nick(%c,%y,v),5))
        if ($mB.Read(Members,%ex,Access) == +v) { dec %y | continue }
        if ($nick(%c,%y,v).idle >= %idle) && ($nick(%c,%y,v) isvoice %c) && ($me isop %c) && ($nick(%c,%y,v) != $me) {
          %nicks = $addtok(%nicks,$nick(%c,%y,v),32)
        }
        dec %y
      }
      if ($numtok(%nicks,32) > 0) {
        while ($gettok(%nicks,1,32)) {
          mB.Queue -a h mode %c $+(-,$str(v,$modespl)) %nicks
          %nicks = $deltok(%nicks,1- $+ $modespl,32)
        }
      }
    }
    dec %x
  }
}

alias mB.Limiter.Timer {
  if ($1) {
    mB.Limiter $1
    if (!$timer(.Limit. $+ $1)) { $+(.timer.Limit.,$1) 0 $calc($mB.Read(Extra,Limiter,Every) * 60) mB.Limiter.Timer $1 }
  }
}

alias mB.Limiter {
  if ($1) {
    var %x = $chan(0)
    while (%x) {
      var %c = $chan(%x)
      if ($mB.Channels($network,%c).Limit) {
        var %offset = $iif($mB.Read(Extra,Limiter,Offset) isnum 1-, %offset, 5)
        if ($server) && ($me isop %c) && ($network == $1) {
          if (l !isincs $gettok($chan(%c).mode,1,32)) || (l isincs $gettok($chan(%c).mode,1,32) && $calc($chan(%c).limit - $nick(%c,0)) <= $int(%offset / 2)) {
            if ($chan(%c).limit != $calc($nick(%c,0) + %offset)) { mB.Queue -a h mode %c +l $calc($nick(%c,0) + %offset) }
          }
        }
      }
      dec %x
    }
  }
}


alias mB.Quotes.NewID {
  if (!$hget($1)) { hmake $1 }
  if ($mB.Read(Extra, Quotes, DynamicID) == 1) {
    var %x = 1,%y = $hget($1, 0).item
    while (%x <= %y) {
      if ($hget($1, %x).data == $null) { return %x }
      inc %x
    }
    if (%x >= %y) { return $calc(%y + 1) }
  }
  else {
    var %x = $calc($hget($1, 0).item + 1)
    while (1) {
      if ($hget($1, %x).data == $null) break
      inc %x
    }
    return %x
  }
}

; Items: $ctime AddedBy SaidBy HasBeenHit Quote
alias mB.Quotes {
  if ($istok(Add Del Rep Get,$prop,32)) {
    var %table = Quotes.Global
    var %p = $prop
    if (!$hget(%table)) { hmake %table }
    if (%p == Add) {
      ; $1 = Added by - $2 = Said by - $3- = Quote
      var %q = $gettok($remove($strip($3-),$chr(9)),1-,32)
      hadd -m %table $mB.Quotes.NewID(%table) $ctime $1 $2 0 %q
      if ($isid) return $true
    }
    elseif (%p == Del) {
      if ($1 isnum 1-) && ($hget(%table, $1) != $null) {
        ; $1 = Quote ID
        hdel %table $hget(%table, $1).item
        if ($isid) return $true
      }
    }
    elseif (%p == Rep) {
      if ($1 isnum 1-) && ($2 != $null) {
        ; $1 = Quote ID - $2- = Quote
        hadd -m %table $hget(%table, $1).item $2-
        if ($isid) return $true
      }
    }
    elseif (%p == Save) {
      Quotes.Save
      if ($isid) return $true
    }
    elseif (%p == Get) {
      var %x = $iif($1 isnum 1-, $1, $rand(1, $hget(%table, 0).item))
      if ($hget(%table,0).item > 0) {
        var %item = $hget(%table,%x)
        if (%item != $null) {
          tokenize 32 %item
          var %q = $5-,%qn = $hget(%table,%x).item, %by = $3, %date = $asctime($1), %add = $2, %hit = $4, %time = $asctime($1,HH:nn:ss), %date = $asctime($1,dd/mm/yyyy)
          var %msg = $iif($mB.Read(Extra, Quotes, Quote) != $null, $v1, $Quote.Msg)
          var %x = 1, %l = <Quote> <QNumber> <By> <Date> <Time> <DateTime> <AddedBy> <Hit>, %v = q qn by date time dt add hit
          inc %hit
          while (%x <= $numtok(%l, 32)) {
            %msg = $replace(%msg, $gettok(%l, %x, 32), $eval($+(%,$gettok(%v , %x, 32)),2))
            inc %x
          }
          hadd -m %table %qn $1-3 %hit $5-
          return %msg
        }
      }
      else { return There are no Quotes saved. }
    }
  }
}
alias Quote.Msg { return Quote #<QNumber>: <Quote> [by <By> - Date: <Date> - Hit: <Hit> time(s)] }

alias Quote.Save { .hsave -i Quotes.Global Quotes.Global.hsh }
alias Quote.Load { .hload -i Quotes.Global Quotes.Global.hsh }
