alias Top.Msg {
  if ($istok(Top TStat Stat TopDaily OverallStat,$1,32)) && ($isid) {
    var %Top = Top <From>-<To> Chatters on <Channel> [Counted by <Method>]: <Output>
    var %TStat = Today's total activities on <Channel>: <Output>
    var %Stat = <Nick>'s stats on <Channel>: <Output>
    var %TopDaily = Today's total activities on <Channel>: <Output>
    var %OverallStat = 01Currently Stats for02 <Channel>01 on02 <Net> 01IRC Network are: [02Total Joins01:04 <JC> 01- 02Total Parts/Quits01:04 <PC> 01- 02Total Bans01:04 <BC> 01-02 Total Kicks01:04 <KC> 01-02 Total Net Splits:04 <SC>01] - [02Since01:04 <Date> <Time> <GMT> GMT01] - [02Total Networks in my Database01:04 <dbC>01]
    if ($mB.Read(Extra,Msgs,$1) != $null) { return $v1 }
    else { return $eval($+(%,$1),2) }
  }
}

alias Top.Recovery {
  var %file = $qt($3-),%x = 1,%lines = $lines(%file)
  if ($fopen(Recovery)) { .fclose Recovery }
  .fopen Recovery %file
  while ($fopen(Recovery).pos < $file(%file).size) {
    WhileFix
    var %data = $Top.Parse($strip($fread(Recovery)))
    if (%data != $null) { Top.Write $1 $2 %data }
  }
  if ($fopen(Recovery)) { .fclose Recovery }
}

alias -l Top.GetNick { return $iif($remove($strip($1-),<,>,+,@,&,!,~,$chr(37),$chr(42)) != $null,$v1,$null) }
alias Top.Parse {
  if (!$1) return $null
  var %x = $2-
  if (-*- iswm $gettok(%x,1,32)) return $null
  var %join = has joined,%part = has left,%mode = sets mode:,%kick = was kicked by
  if ($gettok(%x,1,32) == $chr(42)) {
    var %nick = $Top.GetNick($gettok(%x,2,32))
    if ($istok(Topic ChanServ NickServ OperServ $server $network,%nick,32)) || (%nick == $null) || (!$Top.IsValid(%nick)) return $null
    if ($gettok(%x,4-5,32) == %join) { return %nick J 1 }
    elseif ($gettok(%x,4-5,32) == %part) { return %nick P 1 }
    elseif ($gettok(%x,4,32) == Quit) { return %nick Q 1 }
    elseif ($gettok(%x,3-5,32) == %kick) { return %nick K 1 }
    elseif ($gettok(%x,3-4,32) != %mode) {
      var %y = $gettok(%x,3-,32)
      return %nick W,T,L,A $+($numtok(%y,32),$chr(44),$len($remove(%y,$chr(32))),$chr(44),1,$chr(44),1)
    }
    else { return $null }
  }
  elseif (<*> iswm $gettok(%x,1,32)) {
    var %nick = $Top.GetNick($v2),%y = $gettok(%x,2-,32)
    if (%nick == $null) || (!$Top.IsValid(%nick)) return $null
    return %nick W,T,L $+($numtok(%y,32),$chr(44),$len($remove(%y,$chr(32))),$chr(44),1)
  }
  else { return $null }
}

alias Top.GetPeak {
  ; $1 = $network - $2 = $chan
  var %table = $+(Top.,$1,.,$2),%item = $+($1,.,$2,.All)
  if ($hget(%table)) {
    var %x = $wildtok($hget(%table,%item), E:*, 1, 32)
    if ($gettok(%x,2,58) isnum) { return $v1 }
  }
  return N/A
}

alias Top.SetPeak {
  ; $1 = $network - $2 = $chan - $3 = Peak
  var %table = $+(Top.,$1,.,$2),%item = $+($1,.,$2,.All)
  if ($hget(%table)) {
    var %data = $hget(%table,%item)
    var %x = $wildtok(%data, E:*, 1, 32)
    var %peak = $iif($gettok(%x,2,58) != $null, $v1, 0)
    if (%peak != null) && (%peak isnum 0-) && ($3 > %peak) { hadd -m %table %item $reptok(%data,$findtok(%data,E:,1,32),$+(E:,%peak),1,32) }
  }
}

alias Top.Write {
  tokenize 32 $1-
  ; $1 = $network - $2 = $chan - $3 = $nick - $4 = Section(s) - $5 = Value(s)
  ; Words - Letters - Total Lines - Actions - Joins - Parts - Quits - Bans - Kicks
  if ($1-5) {
    var %table = $+(Top.,$1,.,$2),%tItem = $+($1,.,$2,.T),%user
    if (!$hget(%table)) {
      .hmake %table
      hadd -m %table $+($1,.,$2,.All) W:0 T:0 A:0 L:0 J:0 P:0 Q:0 B:0 K:0 S:0 E:0 $+(+Since:,$fulldate)
    }
    if ($Top.Bound(%table,$3) != $null) { %user = $v1 | goto Go }
    elseif ($hfind(%table,$3,1)) { %user = $ifmatch | goto Go }
    elseif ($Top.Ident(%table,$3)) {
      %user = $ifmatch
      if ($hget(%table,%user)) { hadd -m %table $3 $v1 | hdel %table %user }
    }
    %user = $3
    :Go
    var %new = $+(W:0 T:0 A:0 L:0 J:0 P:0 Q:0 B:0 K:0 +Since:,$fulldate),%value = $iif($hget(%table,%user),$v1,%new)
    var %newT = W:0 T:0 A:0 L:0 J:0 P:0 Q:0 B:0 K:0 S:0,%tValue = $iif($hget(%table,%tItem),$v1,%newT),%x = 1
    while (%x <= $numtok($4,44)) {
      var %y = $gettok($4,%x,44),%w = $wildtok(%value,%y $+ :*,1,32),%wt = $wildtok(%tValue,%y $+ :*,1,32)
      %value = $reptok(%value,%w, $+(%y,:,$calc($gettok(%w,2,58) + $gettok($5,%x,44))),1,32)
      %tValue = $reptok(%tValue,%wt, $+(%y,:,$calc($gettok(%wt,2,58) + $gettok($5,%x,44))),1,32)
      inc %x
    }
    hadd -m %table %user %value
    hadd -m %table %tItem %tValue
  }
}

alias Top.Ident { return $iif($hfind($1,$2,1),$v1,$null) }
alias Top.Make {
  if ($1) && ($istok(10 20 30 40 50 60 70 80 90 100,$2,32)) {
    var %output
    if (!$hget($1)) { return There are no data in database about $gettok($1,3,46) yet. }
    if ($eval($+(%,Recent.,$1,.,$2,.,$3),2) != $null) { return $v1 }
    else {
      if ($window(@Top,state)) { window -c @Top }
      window -h @Top
      clear @Top
      var %a = 1
      while ($hget($1,%a).item) {
        var %z = $hget($1,$hget($1,%a).item),%u = $hget($1,%a).item
        if (%z != $null) && (%u != $+($gettok($1,2-,46),.T) && %u != $+($gettok($1,2-,46),.All)) {
          var %by
          if ($3 == $null) || ($3 == word) { %by = 1 words }
          elseif ($3 == letter) { %by = 2 letters }
          elseif ($3 == line) { %by = 4 lines }
          var %x = $gettok($gettok(%z,$gettok(%by,1,32),32),2,58)
          if (%x isnum 1-) { aline @Top %x $hget($1,%a).item }
        }
        inc %a
      }
      filter -wwucte 1 32 @Top @Top *
      var %c = $iif($2 == 10,1,$calc($2 - 10)),%x
      %x = %c
      if (%c > 10) { %c = $calc(%c + 1) }
      while (%c <= $2) {
        if ($line(@Top,%c)) { %output = $addtok(%output,$+($ord(%c),:,$chr(32),$gettok($v1,2,32),$chr(32),$chr(40),$gettok($v1,1,32),$chr(41)),64) }
        inc %c
      }
      if ($remove(%output,$chr(32)) != $null) {
        var %msg = $iif($mB.Read(Extra,Msgs,Top) != $null,$v1,$Top.Msg(Top))
        %msg = $replace(%msg,<From>,$iif(%x == 1,1,$calc(%x + 1)),<To>,$2,<Channel>,$gettok($1,3,46),<Method>,$gettok(%by,2,32),<Output>,$replace(%output,$chr(64),$chr(32) $+ - $+ $chr(32)))
        %output = %msg
      }
      window -c @Top
      set -u300 $+(%,Recent.,$1,.,$2,.,$3) %output
      return %output
    }
  }
  Top.Save
}

alias Top.ResetTotalStats {
  var %x = 1
  while ($hget(%x)) {
    var %table = $hget(%x)
    if (Top.* iswm %table) {
      var %m = $+($gettok(%table,2-,46),.T),%item = $hget(%table,%m),%all = $+($gettok(%table,2-,46),.All)
      if (%item != $null) {
        var %y = 1,%old = $hget(%table,%all),%out
        while ($gettok(%item,%y,32)) {
          if ($hget(%table,%all) == $null) || ($count(%item,0) == 10) { %out = %item $iif($hget(%table,%all) == $null,$+(+Since:,$fulldate)) | break }
          var %t = $gettok(W: T: A: L: J: P: Q: B: K: S:,%y,32)
          var %o = $gettok($gettok(%old,$wildtok(%old,$+(%t,*),1,32),32),2,58),%n = $gettok($gettok(%item,$wildtok(%item,$+(%t,*),1,32),32),2,58)
          %out = $puttok(%old,$+(%t,:,$calc(%o + %n)),$wildtok(%old,$+(%t,*),1,32),32)
          inc %y
        }
        hadd -m %table %all %out
        var %net = $gettok(%table,2,46),%chan = $gettok(%table,3,46)
        if ($mB.Channels(%net,%chan).Top) {
          var %mc = msg %chan
          var %dc = describe %chan
          var %nc = .notice %chan

          var %msg = $Top.Msg(TopDaily)
          var %output = $Top.GetStats(%net,%chan,%m).Today
          var %method = $mB.Read(Extra,Msgs,TopDailyM)
          var %ss = $replace(%msg,<Network>,%net,<Channel>,%chan,<Joins>,$Top.Find(J,%s),<Parts>,$Top.Find(P,%s),<Quits>,$Top.Find(Q,%s),<Bans>,$Top.Find(B,%s),<Kicks>,$Top.Find(K,%s),<Words>,$Top.Find(W,%s),<Letters>,$Top.Find(T,%s),<Actions>,$Top.Find(A,%s),<Lines>,$Top.Find(L,%s),<Splits>,$Top.Find(S,%s))
          var %do = $eval($+(%,$gettok(MsgChan DescribeChan NoticeChan,$iif(%method != $null && %method isnum 1-3,%method,1),32)),2)
          MultiServMsg %net %do $replace(%msg,<Channel>,%chan,<Output>,%output)

          if ($mB.Channels(%net,%chan).Daily) {
            var %overall = $Top.GetStats(%net,%chan,%all).OverallStat
            var %methodAll = $mB.Read(Extra,Msgs,DailyM)
            var %overallMsg = $Top.Msg(OverallStat)
            var %s = $hget(%table,$+(%net,.,%chan,.All))
            var %mm = $replace(%overallMsg,<Network>,%net,<Channel>,%chan,<Joins>,$Top.Find(J,%s),<Parts>,$Top.Find(P,%s),<Quits>,$Top.Find(Q,%s),<Bans>,$Top.Find(B,%s),<Kicks>,$Top.Find(K,%s),<Words>,$Top.Find(W,%s),<Letters>,$Top.Find(T,%s),<Actions>,$Top.Find(A,%s),<Lines>,$Top.Find(L,%s),<Splits>,$Top.Find(S,%s),<FullDate>,$gettok($gettok(%s,2,43),2-,58))
            var %doo = %net $eval($+(%,$gettok(mc dc nc,$iif(%method != $null && %method isnum 1-3,%method,1),32)),2)
            MultiServMsg %net %doo %mm
          }
        }
        hdel %table %m
      }
    }
    inc %x
  }
  .timer.MidnightPassed 1 62 DailyStuff.Init
  Top.Save
}

alias Top.GetStats {
  var %table = $+(Top.,$1,.,$2),%user = $iif($Top.Bound(%table,$3) != $null,$v1,$3)
  if (!$hget(%table)) || (!$hget(%table,%user)) { return No match were found. }
  else {
    var %x = $hget(%table,%user),%chan = $2
    tokenize 32 %x
    return Words: $gettok($1,2,58) - Letters: $gettok($2,2,58) - Actions: $gettok($3,2,58) - Lines: $gettok($4,2,58) - Joins: $gettok($5,2,58) $&
      $+($chr(32),-) Parts: $gettok($6,2,58) - Quits: $gettok($7,2,58) - Bans: $gettok($8,2,58) - Kicks: $gettok($9,2,58) $&
      $iif($prop != Today,$+($chr(32),$chr(40),Since:,$chr(32),$gettok($gettok($1-,2,43),2-,58),$chr(41)))
  }
}

alias Top.Find { return $gettok($wildtok($2-,$1 $+ :*,1,32),2,58) }

alias Top.Merge {
  var %a = $+(Top.,$1,.),%x = 1
  while ($hget(%x)) {
    if ($+(%a,*) iswm $v1) {
      var %table = $hget(%x),%y = 1
      if ($hget(%table,$4)) {
        var %z = $v1,%chan = $gettok(%table,3,46)
        Top.Write $1 %chan $3 W,T,A,L,J,P,Q,B,K $+($Top.Find(W,%z),$chr(44),$Top.Find(T,%z),$chr(44),$Top.Find(A,%z),$chr(44),$Top.Find(L,%z),$chr(44),$Top.Find(J,%z),$chr(44),$Top.Find(P,%z),$chr(44),$Top.Find(Q,%z),$chr(44),$Top.Find(B,%z),$chr(44),$Top.Find(K,%z))
        hdel %table $4
      }
    }
    inc %x
  }
  return Operation completed. $3 has been merged with $4 successfully.
}

alias Top.Bound {
  var %x = $hget($1,$2)
  if ($gettok(%x,1,32) == Bound) && ($gettok(%x,2,32) != $null) { return $gettok(%x,2,32) }
  else { return $null }
}

alias Top.Bind {
  var %a = $+(Top.,$1,.),%x = 1
  noop $Top.Merge($1,$2,$4,$3)
  while ($hget(%x)) {
    if ($+(%a,*) iswm $v1) {
      var %table = $hget(%x)
      if ($Top.Bound(%table,$3) != $4) { hadd -m %table $3 Bound $4 }
    }
    inc %x
  }
  return Operation completed. $3 is now bound to $4 $+ .
}

alias Top.IsValid {
  if (!$1) return $false
  var %x = 1,%excepts = $mB.Read(Extra,Top,Ignore),%item
  while ($gettok(%excepts,%x,32)) {
    %item = $v1
    if (%item == $1) || (%item iswm $1) { return $false }
    inc %x
  }
  return $true
}

alias Top.Save {
  var %x = 1
  while ($hget(%x)) {
    if (Top.* iswm $hget(%x)) {
      var %y = $v2
      .write -c $mB.Top($+(%y,.mtdb))
      .hsave -i %y $mB.Top($+(%y,.mtdb))
    }
    inc %x
  }
}

alias Top.Load {
  var %x = $findfile($mB.Top,Top.*.mtdb,0)
  while (%x) {
    var %file = $findfile($mB.Top,Top.*.mtdb,%x)
    var %table = $gettok($nopath($noqt($longfn(%file))),1- $+ $calc($numtok($nopath($noqt($longfn(%file))),46) - 1),46)
    if (!$hget(%table)) { .hmake %table }
    if (!$isdir($mB.Top(Old\))) { .mkdir $mB.Top(Old\) }
    if (\Old\ !isin %file) {
      .hload -i %table $qt(%file)
      .copy -o $qt($longfn(%file)) $qt($longfn($+($mB.Top(Old\),%table,.mtdb)))
      ;.remove $qt($longfn(%file))
    }
    dec %x
  }
}

alias Top.Revalidate {
  var %x = 1,%result = 0
  while ($hget(%x)) {
    if (Top.* iswm $hget(%x)) {
      var %y = 1
      while ($hget(%x,%y).item) {
        var %item = $v1
        if (!$Top.IsValid(%item)) || ($istok(< > + @ & ! ~ $chr(37) $chr(42),$left(%item,1),32)) { .hdel $hget(%x) %item | inc %result }
        inc %y
      }
    }
    inc %x
  }
  echo -a Done! Resutls: %result
}

alias Top.EmptyItem {
  if ($isid) && ($1-2) {
    var %a = $hget($1,$2)
    if (Bind isin %a) return $false
    else {
      var %w = $gettok($wildtok(%a,W:*,1,32),2,58),%t = $gettok($wildtok(%a,T:*,1,32),2,58)
      return $iif($calc($iif(%w isnum 1-,$v1,0) + $iif(%t isnum 1-,$v1,0)) > 0,$false,$true)
    }
  }
}

alias Top.OptimizeAll {
  if ($dialog(Extra)) && ($input(Are you sure?,qyvg,Confirmation) != $yes) halt
  var %x = 1,%dbs = 0,%items = 0
  while ($hget(%x)) {
    WhileFix
    if (Top.* iswm $hget(%x)) {
      var %table = $v2
      while ($Top.Optimize(%table)) { %items = $calc(%items + $v1) }
      inc %dbs
    }
    inc %x
  }
  if ($isid) { return %dbs %items }
}

alias Top.Optimize {
  if ($hget($1)) {
    var %x = 1,%y = 0
    while ($hget($1,%x).item) {
      WhileFix
      var %item = $hget($1,%x).item
      if ($Top.EmptyItem($1,%item)) { hdel $1 %item | inc %y }
      inc %x
    }
  }
  if ($isid) { return %y }
}

; [Events...]
on !*:Nick:{
  if ($mB.Channels($network,$chan).Top) {
    ; Here should be edited!
    return
    if (!$Top.IsValid($newnick)) return
    var %x = 1
    while ($comchan($newnick,%x)) {
      var %table = $+(Top.,$network,.,$v1)
      if ($hget(%table,$nick)) { hadd -m %table $newnick $v1 | hdel %table $nick }
      inc %x
    }
  }
}
