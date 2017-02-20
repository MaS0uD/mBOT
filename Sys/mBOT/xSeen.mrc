; ******************************************************
;                   xSeen System v3.9
; ******************************************************
On *:START: {
  if ( !$hget(xSeen) ) hmake xSeen 100
  if ( !$hget(xSeen.msgs) ) hmake xSeen.msgs 10
  if ( $isfile($_seen.log) ) hload xSeen $_seen.log
  if ( $isfile($_seenmsgs.log) ) hload xSeen.msgs $_seenmsgs.log
  if ( $hget(xSeen.fld) ) hfree xSeen.fld
  if (%Extra-Set == OFF) { .writeini $_seen.file settings status 0 }
}

on *:CONNECT: { 
  if ( !$ini($_seen.file,$_net,0) ) seen.default $_net
  seen.default.check $_net
  if ( $readini($_seen.file,settings,auto.delete) ) && ( !$timer(xSeen.autodelete) ) .timerxSeen.autodelete -o 0 $calc($readini($_seen.file,settings,auto.delete.every) * 3600) seen.delold ALL $readini($_seen.file,settings,auto.delete.old) 1
}

On *:EXIT:if ($hget(xSeen)) xseen.save
On *:DISCONNECT:if ($hget(xSeen)) xseen.save
ON ^*:OPEN:?:*: {
  if ($readini($_seen.file,$_net,status) == 1) && ($readini($_seen.file,settings,status) == 1) && ($readini($_seen.file,$_net,private)) {
    var %xt = $Trigger, %xf = $seen.format($_net)
    if ($1 == $+(%xt,seen)) {
      if ($2) {
        floodcheck $_net $wildsite
        if ( $2 == $me ) %xf $seenmsg.me($nick)
        elseif ( $2 == $nick ) %xf $seenmsg.self($nick)
        else %xf $seenpar($nick,$+(seen:,$iif($readini($_seen.file,settings,multiserver),*,$_net),:,$2),$+(nseen:,$_net,:,$2,:,$nick) $nick $ctime private $address)
      }
      else %xf ** Syntax: $+(%xf,seen) <NICK>
      haltdef
    }
    elseif ( $1 == $+(%xt,seenstats) ) { 
      floodcheck $_net $wildsite
      %xf $seen.stats($nick,$_net)
      haltdef
    }
    elseif ( $1 == $+(%xt,lastspoke) ) {
      floodcheck $_net $wildsite
      if ( $2 == $null ) %xf ** Syntax: $+(%xt,lastspoke) <NICK>
      else %xf $seen.lastspoke($nick,$iif($readini($_seen.file,settings,multiserver),*,$_net),*,$2)
      haltdef
    }
    close -m $nick
  }
}

ON *:TEXT:*:*: {
  if ( $readini($_seen.file,$_net,status) ) && ($readini($_seen.file,settings,status) == 1) {
    if ( $readini($_seen.file,settings,events.texts) ) || ( $readini($_seen.file,settings,events.querys) ) { 
      if ( $istok($readini($_seen.file,$_net,chans.nosave),$chan,44) ) return
      if ( $address($nick,5) ) xseen.add $+(seen:,$_net,:,$address($nick,5)) $iif($chan,text,private) $ctime $chan
      else gethost.buffer $sc($_net) $nick private $ctime $1-
    }
    if (!$istok($readini($_seen.file,$_net,chans.notrigger),$chan,44)) && ($mB.Channels($network,$chan).Seen) {
      var %xt = $Trigger($network,$chan), %xf = $seen.format($_net,$chan)
      if ($1 == $+(%xt,seen)) && ( $$2 ) {
        floodcheck $_net $wildsite
        if ( $2 == $me ) %xf $seenmsg.me($nick)
        elseif ( $2 == $nick ) %xf $seenmsg.self($nick)
        elseif ($2 ison $chan) %xf $seenmsg.here($nick,$2)
        else %xf $seenpar($nick,$+(seen:,$iif($readini($_seen.file,settings,multiserver),*,$_net),:,$2),$+(nseen:,$_net,:,$2,:,$nick) $nick $ctime $iif(#,#,private) $address)
      }
      elseif ( $1 == $+(%xt,seenstats) ) { 
        floodcheck $_net $wildsite
        %xf $seen.stats($nick,$_net)
      }
      elseif ( $1 == $+(%xt,lastspoke) ) {
        floodcheck $_net $wildsite
        if ( $2 == $null ) && ( !$chan ) %xf ** Syntax: $+(%xt,lastspoke) <NICK>
        else %xf $seen.lastspoke($nick,$iif($readini($_seen.file,settings,multiserver),*,$_net),$iif(#,#,*),$2)
      }
    }
    if ( $readini($_seen.file,settings,events.texts) ) || ( $readini($_seen.file,settings,events.querys) ) { 
      if ( $istok($readini($_seen.file,$_net,chans.nosave),$chan,44) ) return
      if ( $address($nick,5) ) xseen.add $+(seenspoke:,$_net,:,$iif(#,#,private),:,$address($nick,5)) $iif(#,#,private) $ctime $xseen.cutlen($1-)
    }
  }
}

ON *:ACTION:*:*: {
  if ( $readini($_seen.file,$_net,status) ) && ($mB.Channels($network,$chan).Seen) {
    if ( $readini($_seen.file,settings,events.actions) ) || ( $readini($_seen.file,settings,events.querys) ) { 
      if ( $istok($readini($_seen.file,$_net,chans.nosave),$chan,44) ) return
      if ( $address($nick,5) ) { 
        xseen.add $+(seen:,$_net,:,$address($nick,5)) act $ctime $iif(#,#,private)
        xseen.add $+(seenspoke:,$_net,:,$iif(#,#,private),:,$address($nick,5)) $iif(#,#,private) $ctime $xseen.cutlen($1-)
      }
      else gethost.buffer $sc($_net) $nick act $ctime private $1-
    }
  }
}

ON *:QUIT: { 
  if ( $readini($_seen.file,$_net,status) ) && ($mB.Channels($network,$chan).Seen) && ( $readini($_seen.file,settings,events.quits) ) { 
    var %cc = $comchan($nick,$comchan($nick,0))
    if ( $istok($readini($_seen.file,$_net,chans.nosave),%cc,44) ) return
    if ( $address($nick,5) ) xseen.add $+(seen:,$_net,:,$address($nick,5)) quit $ctime %cc $1-
    var %c = 1, %ch
    while $comchan($nick,%c) {
      %ch = $v1
      if ( $hget(xSeen,$+(seendur:,$_net,:,%ch,:,$nick)) ) { 
        tokenize 32 $v1
        xseen.add $+(seendur:,$_net,:,%ch,:,$nick) $calc($ctime - $1) $2
      }
      inc %c
    }
  }
}

on *:PART:#: {
  if ( $readini($_seen.file,$_net,status) ) && ($mB.Channels($network,$chan).Seen) && ( $readini($_seen.file,settings,events.parts) ) && ( !$istok($readini($_seen.file,$_net,chans.nosave),$chan,44) ) { 
    if ( $address($nick,5) ) xseen.add $+(seen:,$_net,:,$address($nick,5)) part $ctime $chan $1-
    if ( $hget(xSeen,$+(seendur:,$_net,:,$chan,:,$nick)) ) { 
      tokenize 32 $v1
      xseen.add $+(seendur:,$_net,:,$chan,:,$nick) $calc($ctime - $1) $2
    }
  }
}

on *:JOIN:#: {
  if ( $readini($_seen.file,$_net,status) ) && ($mB.Channels($network,$chan).Seen) {
    if ( $nick == $me ) && ( $readini($_seen.file,settings,add.nicks.onjoin) ) {
      joinchans.buffer $sc($_net) $chan
    }
    if ( $readini($_seen.file,settings,events.joins) ) && ( !$istok($readini($_seen.file,$_net,chans.nosave),$chan,44) ) { 
      xseen.add $+(seen:,$_net,:,$address($nick,5)) join $ctime $chan $1-
      xseen.add $+(seendur:,$_net,:,$chan,:,$nick) $ctime $ctime
    }
    if ( !$istok($readini($_seen.file,$_net,chans.nonotify),$chan,44) ) $+(.timerxSeennseen.,$cid,.,$chan) 1 2 nseen $+($_net,:,$nick) $chan
  }
}

ON *:NICK: {
  if ( $readini($_seen.file,$_net,status) ) && ($mB.Channels($network,$chan).Seen) {
    var %c = 1, %d
    while $comchan($newnick,%c) {
      %d = $v1
      if ( $readini($_seen.file,settings,events.nickchange) ) && ( !$istok($readini($_seen.file,$_net,chans.nosave),%d,44) ) { 
        xseen.add $+(seen:,$_net,:,$nick,!,$address) nick $ctime %d $newnick
        if ( $hget(xSeen,$+(seendur:,$_net,:,%d,:,$nick)) ) { 
          tokenize 32 $v1
          xseen.add $+(seendur:,$_net,:,%d,:,$newnick) $calc($ctime - $1) $2
        }
      }
      if ( !$istok($readini($_seen.file,$_net,chans.nonotify),%d,44) ) $+(.timerxSeennseen.,$cid,.,%d) 1 2 nseen $+($_net,:,$newnick) %d
      inc %c
    }
  }
}

ON *:KICK:#: {
  if ( $readini($_seen.file,$_net,status) ) && ($mB.Channels($network,$chan).Seen) && ( $readini($_seen.file,settings,events.kicks) ) && ( !$istok($readini($_seen.file,$_net,chans.nosave),$chan,44) ) {
    if ( $address($nick,5) )  xseen.add $+(seen:,$_net,:,$address($nick,5)) kicking $ctime $chan $knick $1-
    if ( $address($knick,5) )  xseen.add $+(seen:,$_net,:,$address($knick,5)) kick $ctime $chan $nick $1-
  }
}

alias -l _writeini { .writeini -n $_seen.file $1- }
alias -l _net return $iif($network,$v1,$server)
alias -l xseen.add { 
  if ( $hfind(xSeen,$+($deltok($1,2,33),!*),1,w) ) { 
    if ( $v1 != $1 ) hdel xSeen $v1
  }
  hadd -m xSeen $1-
  xseen.save
}
alias -l nseen {
  var %n3 = $1, %n = $hfind(xSeen,$+(nseen:,$1,:,*),0,w), %n2, %n4 = 1, %chan = $2, %t = 0
  while %n { 
    %n2 = $hfind(xSeen,$+(nseen:,%n3,:,*),%n,w)
    tokenize 32 $hget(xSeen,%n2)
    inc %t
    $+(.timerxSeennotify,.,$gettok(%n3,2,58),.,%t) 1 $calc(%t * 2) $nseen.format($_net) $gettok(%n3,2,58) $seenmsg.nseen($1,$4,$3,$seentime( $2 ),$seendate( $2 ),$5)
    hdel xSeen %n2
    inc %n4
    dec %n
  }
}

alias -l seenpar {
  if ( $count($2,*,?) ) { 
    if ( !$readini($_seen.file,settings,wildcards) ) && ( $count($gettok($2,3,58),*,?) ) return $seenmsg.nowildcards($1)
    elseif ( !$count($gettok($2,3,58),*) ) return $seenparse2($1,$+($2,!*@*),$iif($3,$3-)) 
    else return $seenparse2($1,$2,$iif($3,$3-)) 
  }
  if ( $len($gettok($2,3,58)) > $readini($_seen.file,$gettok($2,2,58),nicklen) ) return $seenmsg.longnick($1)
  elseif ( $readini($_seen.file,settings,smart) ) return $seenparse3($1,$2,$3-)
  else return $seenparse($1,$2,$3-)
}

alias -l seenparse {
  ;last data parsing
  var %nick = $1
  tokenize 32 $2-
  var %y = $hfind(xSeen,$+($1,!*),1,w), %x = $hget(xSeen,%y), %n = $deltok($gettok(%y,3,58),2,33), %m = $gettok(%y,2,33), %sl = $iif(($gettok(%y,2,58) != $iif($dialog(xSeen),$did(xSeen,77),$_net)),$gettok(%y,2,58)), %xs.net = $gettok(%y,2,58)
  if (!%x) return $seenmsg.notseen(%nick,$deltok($gettok($1,3,58),2,32))
  if ( %n == $me ) return $seenmsg.me(%nick)
  if ( %nick == $gettok($1,3,58) ) return $seenmsg.self(%nick)
  if ( %n ison $gettok($2-,4,32) ) return $seenmsg.here(%nick,%n)
  if ( $2 ) && ( $readini($_seen.file,$gettok(%y,2,58),notify) ) { 
    xseen.add $reptok($2-,$gettok($2,2,58),$gettok(%y,2,58),58) $gettok($2,2,58)
  }
  tokenize 32 %x
  if ($1 == text) return $seenmsg.text(%nick,%n ,%m,$3,$seentime($2),$seendate($2),$seen.onchan(%n,$3)) $iif(%sl,$+([,%sl,]))
  if ($1 == act) return $seenmsg.act(%nick,%n,%m,$3,$seentime($2),$seendate($2),$seen.onchan(%n,$3)) $iif(%sl,$+([,%sl,]))
  if ($1 == quit) return $seenmsg.quit(%nick,%n,%m,$3,$seentime($2),$seendate($2),$4-) $iif($readini($_seen.file,settings,duration),$seen.dur(%n,$3,%xs.net)) $iif(%sl,$+([,%sl,])) 
  if ($1 == part) return $seenmsg.part(%nick,%n,%m,$3,$seentime($2),$seendate($2),$4-) $iif($readini($_seen.file,settings,duration),$seen.dur(%n,$3,%xs.net)) $iif(%sl,$+([,%sl,])) 
  if ($1 == join) return $seenmsg.join(%nick,%n,%m,$3,$seentime($2),$seendate($2),$seen.onchan(%n,$3)) $iif(%sl,$+([,%sl,]))
  if ($1 == nick) return $seenmsg.nick(%nick,%n,%m,$3,$4,$seentime($2),$seendate($2),$seen.onchan($4,$3)) $iif(%sl,$+([,%sl,]))
  if ($1 == kicking) return $seenmsg.kicking(%nick,%n,%m,$4,$3,$seentime($2),$seendate($2),$5-,$seen.onchan(%n,$3)) $iif(%sl,$+([,%sl,]))
  if ($1 == kick) return $seenmsg.kick(%nick,%n,%m,$3,$4,$seentime($2),$seendate($2),$5-) $iif(%sl,$+([,%sl,]))
  if ($1 == load) return $seenmsg.load(%nick,%n,%m,$seentime($2),$seendate($2),$3) $iif(%sl,$+([,%sl,]))
  if ($1 == joined) return $seenmsg.joined(%nick,%n,%m,$seentime($2),$seendate($2),$3) $iif(%sl,$+([,%sl,]))
  if ($1 == private) return $seenmsg.query(%nick,%n,%m,$seentime($2),$seendate($2)) $iif(%sl,$+([,%sl,]))
}

alias -l seenparse2 {
  ;with wildcard parsing
  var %nick = $1
  tokenize 32 $2-
  var %s3 = $1, %s = $hfind(xSeen,$1,0,w), %s2 = $deltok($hfind(xSeen,$1,1,w),2,33)
  if ( !%s ) return $seenmsg.nomatch(%nick)
  elseif ( %s == 1 ) { 
    var %sp3 = $iif($count($2-,*,?),$puttok($2-,$gettok(%s2,3,58),3,58),$2-)
    if ( $readini($_seen.file,settings,smart) ) return $seenparse3(%nick,%s2,%sp3)
    else return $seenparse(%nick,%s2,%sp3)
  }
  elseif ( %s < 100 ) { 
    return $seenparse.filter(%nick,$+(%s,:,%s3),$2-)
  }
  else return $seenmsg.manymatch(%nick,$bytes(%s,b))
}

alias -l seenparse3 {
  ;smart seen parsing
  var %nick = $1
  tokenize 32 $2-
  var %g5 = $1-, %r = $hfind(xSeen,$+($1,!*),1,w), %g3 = $+($gettok(%r,1-2,58),:,$+(*!,$deltok($gettok(%r,2-,33),2,64),@*))
  var %g = $hfind(xSeen,%g3,0,w)
  if ( %g == 1 ) || ( !%r ) return $seenparse(%nick,%g5)
  elseif ( %g < 100 ) { 
    return $seenparse.filter(%nick,$+(%g,:,%g3),$2-)
  }
  else return $seenmsg.manymatch(%nick,$bytes(%g,b))
}

alias -l seenparse.filter {
  var %nick = $1
  tokenize 32 $2-
  var %j = $gettok($1,1,58), %j3 = $deltok($gettok($1,2-,58),2,32), %fwin = @seenfilter, %j2, %j9 = 0, %j4, %nnick, %snet = $gettok($1,3,58)
  window -hn %fwin
  clear %fwin
  while %j {
    %j2 = $hfind(xSeen,%j3,%j,w)
    aline %fwin $deltok($gettok(%j2,3,58),2,33) $gettok($hget(xSeen,%j2),2,32) %j2
    dec %j
    inc %j9
  }
  filter -cteuww 2 32 %fwin %fwin
  var %k = 1, %k1, %sp
  while (%k <= 5) && ($line(%fwin,%k)) {
    %k1 = $addtok(%k1,$gettok($v1,1,32),32)
    inc %k
  }
  %j4 = $gettok(%k1,1,32)
  %snet = $gettok($gettok($line(%fwin,1),3,32),2,58)
  %nnick = $deltok($gettok($2,3-,58),-1,58)
  %sp = $seenparse(%nick,$+(seen:,%snet,:,%j4),$iif($2,$iif(!$count(%nnick,*,?),$reptok($2-,%nnick,%j4,1,58),$replace($2-,%nnick,%j4)))) 
  if (%j9 >= 2) return $seenmsg.found(%j9,$iif(%j9 >= 5,5,$v1),%k1,%sp) 
  else return %sp 
}
alias seen { 
  if ($isid) return
  if (!$mB.Channels($network,$chan).Seen) return
  if ($1 != $null) { 
    if ( $len($1) > $readini($_seen.file,$_net,nicklen) ) echo $colour(info) -a * $seenmsg.longnick($me)
    else echo $colour(info) -a *** $seenpar($me,$+(seen:,$iif($readini($_seen.file,settings,multiserver),*,$_net),:,$1))
  }
  else echo $colour(info) -a * /seen: insufficient parameters
}
alias -l seen.version return 3.9
alias _seen.file return $mB.Dir(mBOT\xSeen.ini)
alias _seen.log return $mB.Dir(mBOT\xSeen.dat)
alias _seenmsgs.log return $mB.Dir(mBOT\xSeenmsgs.dat)
alias _seen.bak return $mB.Dir(mBOT\xSeen.bak)
alias seen.dur { if ( $hget(xSeen,$+(seendur:,$3,:,$2,:,$1)) ) { 
    tokenize 32 $v1 
    if ( $1 >= $2 ) return $seenmsg.duration2
  else return $seenmsg.duration($st_rep($duration($1,2))) }
}
alias -l seentime { 
  var %d = $duration($calc($ctime - $1),2)
  return $st_rep(%d)
}
alias -l st_rep return $replace($1,Wk,$st2(Week),Day,$st2(Day),Hr,$st2(Hour),Min,$st2(Minute),Sec,$st2(Second))
alias -l st2 return $+($chr(160),$1)
alias -l seendate return $asctime($1,m.dd HH:nn)
alias -l seen.delold {
  var %d = $iif($1 == ALL,$hget(xSeen,0).item,$hfind(xSeen,$+(seen*:,$1,:*),0,w)), %e = 0, %eh = $2
  if ( %eh ) { 
    if ( %eh isnum ) {
      if ( %eh > 1 ) {
        var %f = $calc(86400 * %eh)
        while %d {
          if ( $calc($ctime - $gettok($iif($1 == ALL,$hget(xSeen,%d).data,$hget(xSeen,$hfind(xSeen,$+(seen*:,$1,:*),%d,w))),2,32)) > %f ) {
            inc %e
            hdel xSeen $iif($1 == ALL,$hget(xSeen,%d).item,$hfind(xSeen,$+(seen*:,$1,:,*),%d,w))
          }
          dec %d
        }
        if ( !$3 ) .timerxSeen.deletedentries 1 0 _blankinput Deleted %e seen entries $iif($1 != ALL,for $1)
      }
      else .timerxSeenerrornumlow 1 0 _blankinputerror Number should be higher than 1.
    }
    else .timerxSeenerrornotnum 1 0 _blankinputerror %eh is not a number.
  }
  else .timerxSeenerrornumlow 1 0 _blankinputerror You must enter a number, should be higher than 1.
}

alias -l seen.stats { 
  var %s = $+(seen:,$2,:*), %t = $hfind(xSeen,%s,0,w)
  if ( $2 != ALL ) {
    var %o = $hfind(xSeen,%s,0,w), %p = $ctime, %p1
    while %o {
      if ( %p  > $gettok($hget(xSeen,$hfind(xSeen,%s,%o,w)),2,32) ) {
        %p = $v2
        %p1 = $hfind(xSeen,%s,%o,w)
      }
      dec %o
    }
    return $1 $+ , I Have A Total Of $bytes(%t,b) Entries For $2 $+ . $iif(%t,The Oldest Entry For $2 is $deltok($gettok(%p1,3,58),2,33) $+ $chr(44) Which Is From $seentime(%p) ago.)
  }
  else return $1 $+ , I Have A Total Of $bytes($hfind(xSeen,$+(seen:*),0,w),b) Entries In My Database.
}

alias lastspoke {
  if ($isid) return
  if (!$mB.Channels($network,$chan).Seen) return 
  if ($1 != $null) echo $colour(info) -a *** $seen.lastspoke($me,$iif($readini($_seen.file,settings,multiserver),*,$_net),:*:,$1)
  else { echo $colour(info) -a * /lastspoke: insufficient parameters }
}

alias -l seen.lastspoke {
  if ( !$readini($_seen.file,settings,wildcards) ) && ( $count($4,*,?) ) return $seenmsg.nowildcards($1)
  var %s = $+(seenspoke:,$2,:,$iif($4,*,$3),:,$iif($4,$iif($count($4,*,?),$4,$4 $+ !*@*),*)), %t = $hfind(xSeen,%s,0,w)
  if ( %t == 1 ) { 
    var %z = $hfind(xSeen,%s,1,w), %st = $gettok($hget(xSeen,%z),2,32),  %sl = $iif(($gettok(%z,2,58) != $iif($dialog(xSeen),$did(xSeen,77),$_net)),$gettok(%z,2,58) )
    return $seenmsg.lastspoke($1,$gettok($gettok(%z,4,58),1,33),$gettok(%z,3,58),$seentime(%st),$asctime(%st,m.dd HH:nn),$gettok($hget(xSeen,%z),3-,32)) $iif(%sl,$+([,%sl,])) 
  }
  elseif ( %t > 1 ) {
    if ( %t > 100 )  return $seenmsg.manymatch($1,$bytes(%t,b))
    var %w = @seen.ls, %h, %fn = %t
    window -hn %w
    clear %w
    while %t {
      %h = $hfind(xSeen,%s,%t,w)
      aline %w %h $gettok($hget(xSeen,%h),2,32)
      dec %t
    }
    filter -cteuww 2 32 %w %w
    var %ty = $gettok($line(%w,1),1,32), %ct = $gettok($hget(xSeen,%ty),2,32), %sg = $iif(($gettok(%ty,2,58) != $iif($dialog(xSeen),$did(xSeen,77),$_net)),$gettok(%ty,2,58))
    window -c %w
    return $seenmsg.lastspoke($1,$gettok($gettok(%ty,4,58),1,33),$gettok(%ty,3,58),$seentime(%ct),$asctime(%ct,m.dd HH:nn),$gettok($hget(xSeen,%ty),3-,32)) $iif(%sg,$+([,%sg,])) 
  }
  elseif ( $4 == $null ) return $seenmsg.noonespoke($1)
  else return $seenmsg.hasnotspoke($1,$4)
  ;return $seenmsg.lastspoke($replace(%y,$chr(32),$chr(44)))
}

alias -l seen.default {
  _writeini $1 status 1
  _writeini $1 format Notice
  _writeini $1 target Nick
  _writeini $1 notify 1
  _writeini $1 trigger %Trigger
  _writeini $1 private 1
  _writeini $1 format2 Msg
  _writeini $1 format3 Notice
  if ( $2 ) echo $colour(info) -a ** xSeen $seen.version $+ : Default Seen Settings Has Been Set For $1 $+ .
}

alias -l seen.default.check {
  if ( !$readini($_seen.file,$1,status) ) _writeini $1 status 1
  if ( !$readini($_seen.file,$1,format) ) _writeini $1 format Msg
  if ( !$readini($_seen.file,$1,target) ) _writeini $1 target Chan
  if ( !$readini($_seen.file,$1,notify) ) _writeini $1 notify 1
  if ( !$readini($_seen.file,$1,trigger) ) _writeini $1 trigger $Trigger
  if ( !$readini($_seen.file,$1,private) ) _writeini $1 private 1
  if ( !$readini($_seen.file,$1,format2) ) _writeini $1 format2 Msg
  if ( !$readini($_seen.file,$1,format3) ) _writeini $1 format3 Notice
}

alias -l seen.format { 
  if ( $2 ) {
    var %sf = $readini($_seen.file,$1,format) $readini($_seen.file,$1,target)
    tokenize 32 %sf
    return $replace(%sf,$iif($2 == nick,msg),$iif($2 == nick,.msg),chan,$chan,notice,.notice,nick,$nick) 
  }
  else return . $+ $readini($_seen.file,$1,format2) $nick
}

alias -l nseen.format return . $+ $readini($_seen.file,$1,format3)

alias -l floodcheck {
  if ( $readini($_seen.file,settings,flood.pro) )  {
    var %h = $readini($_seen.file,settings,flood.time)
    var %j = $readini($_seen.file,settings,flood.lines)
    var %i = $readini($_seen.file,settings,flood.ignore)
    inc $iif(!$($+(%,xseenflood,.,$1,.,$2),2),$+(-u,%h)) $+(%,xseenflood,.,$1,.,$2)
    if ( $($+(%,xseenflood,.,$1,.,$2),2) >= %j ) { 
      .ignore $+(-u,$calc(60 * %i)) $2
      echo 04 -s ** xSeen: Flood Detected From $2 On $1 $+ ... Ignoring For %i minutes.
    }
  }
}

alias -l defoutputcheck {
  var %uc = $input(Do You Really Want To Set Default Outputs $iif($1, for $+(",$1-,")) $+ ?,uy, xSeen Default Outputs)
  if ( $! ) {
    if ( $1 ) {
      var %w = $remove($1-,$chr(32))
      hadd -m xSeen.msgs %w $($+($,xseenmsg.,%w),2)
      did -ram xSeen 93 $hget(xSeen.msgs,%w)
      did -ra xSeen 96 $count93
      did -ue xSeen 94
    }
    else {
      def_output 1 1
      refresh_output
    }
  }
}

alias -l resetdatacheck {
  var %uc = $input(Do You Really Want To Reset The Data? Backup File Would Be Reset Too.,uyw,xSeen Reset)
  if ( $! ) {
    if ( $hget(xSeen) ) hfree xSeen
    .hmake xSeen 100
    .timerxSeen.resetdatadone 1 0 _blankinput All data has been cleared!
  }
}

alias -l backupcheck {
  if ( $isfile($_seen.bak) ) {
    var %bc = $input(Do You Also Want To Delete The Backup Seen Data?,uy,xSeen Backup)
    if ( $! ) _del.bak
  }
  .timerxSeen.outputcheck 1 0 outputcheck
}

alias -l outputcheck {
  if ( $isfile($_seenmsgs.log) ) {
    var %bc = $input(Do You Also Want To Delete The Output Messages?,uy,xSeen Outputs)
    if ( $! ) _del.output
  }
}

alias -l autoloadbak.check {
  var %al = $input(Do You Want To Load The Backup Seen Data?,uy,Found xSeen Backup Log)
  if ( $! ) { 
    if ( !$hget(xSeen) ) hmake xSeen 100
    hload xSeen $_seen.bak
  }
}

alias -l outputreset.check {
  if ( $var(%xseen*,0) ) || ( $isfile($_seenmsgs.log) ) {
    var %al = $input(Do you want to reset Previous Outputs?,uy,Found previous xSeen outputs)
    if ( $! ) def_output 1
    else def_output
  }
  else def_output 1
}

alias -l _blankinput {
  var %bi = $input($1-,uio,xSeen)
}

alias -l _blankinputerror {
  var %bi = $input($1-,uwo,xSeen Error)
}

alias -l _del.bak .remove $_seen.bak
alias -l _del.output { hfree xSeen.msgs | .remove $_seenmsgs.log }

alias -l xSeen.init {
  if ( !$hget(xSeen) ) hmake xSeen 100
  if ( $isfile($_seen.bak) ) .timerxSeen.autoloadbak 1 0 autoloadbak.check 
  .timerxSeen.outputreset 1 0 outputreset.check
  _writeini settings status 1
  _writeini settings flood.lines 3
  _writeini settings flood.time 60
  _writeini settings flood.ignore 3
  _writeini settings auto.delete 0
  _writeini settings auto.delete.every 3
  _writeini settings auto.delete.old 30
  _writeini settings auto.save 0
  _writeini settings auto.save.every 3
  _writeini settings smart 1
  _writeini settings flood.pro 1
  _writeini settings events.texts 1
  _writeini settings events.actions 1
  _writeini settings events.querys 1
  _writeini settings events.joins 1
  _writeini settings events.parts 1
  _writeini settings events.quits 1
  _writeini settings events.kicks 1
  _writeini settings events.nickchange 1
  _writeini settings add.nicks.onjoin 1
  _writeini settings multiserver 1
  _writeini settings duration 1
  _writeini settings wildcards 1
  var %scon = $scon(0)
  .scon -at1 .version
  while %scon {
    .scon $v1
    if ( $_net ) {
      seen.default $v1
      var %ial = $ial(*,0)
      while %ial {
        var %ii = $ial(*,%ial)
        xseen.add $+(seen:,$_net,:,%ii) load $ctime $comchan($gettok(%ii,1,33),1)
        dec %ial
      }
      .scon -r
    }
    dec %scon
  }
}

alias xseen.save {
  hsave -o xSeen $_seen.log
  hsave -o xSeen $_seen.bak
}
alias -l dialog_init {
  did -b xSeen 8,9,10,45,49,50,51,52,68,69,73,110,111,112
  did -h xSeen 13,14,15,16,17,18,19,20,24,25,27,28,57,59,60,61,62,63,64,65,66,82,85,77,78,79,80,86,87,88,90,100,101,102,103,104,105,106,107,108,109,115,116,117,118,119,121,122
  if ( !$readini($_seen.file,settings,flood.pro) ) did -b xSeen 39,40,48
  if ( !$istok($didtok(xSeen,11,44),xSeen,44) ) did -ac xSeen 11 xSeen
  if ( !$istok($didtok(xSeen,26,44),ALL,44) ) did -ac xSeen 26 ALL
  if ( !$istok($didtok(xSeen,98,44),Status Window,44) ) {
    did -ac xSeen 98 Status Window
    did -a xSeen 98 Active Window
  }
  var %k = 1, %se
  while $scon(%k) { 
    %se = $iif($scon(%k).network,$v1,$scon(%k).server)
    if ( !$istok($didtok(xSeen,11,44),%se,44) ) && ( $scon(%k).status == connected ) { 
      did -a xSeen 11,26 %se
      did -ac xSeen 12 %se
    }
    inc %k   
  }
  did -ra xSeen 39 $readini($_seen.file,settings,flood.lines)
  did -ra xSeen 40 $readini($_seen.file,settings,flood.time)
  did -ra xSeen 48 $readini($_seen.file,settings,flood.ignore)
  if ( $readini($_seen.file,settings,flood.pro) ) did -c xSeen 67 
  if ( !$istok($didtok(xSeen,73,44),No Saving,44) ) { 
    did -ac xSeen 73 No Saving
    didtok xSeen 73 44 No Notification,No Trigger
  }
  if ( !$istok($didtok(xSeen,120,44),All,44) ) { 
    did -a xSeen 120 All
    did -ac xSeen 120 Current
  }
  if ( !$istok($didtok(xSeen,121,44),Seen,44) ) { 
    did -ac xSeen 121 Seen
    did -a xSeen 121 Lastspoke
  }
  did -c xSeen 84
  did -e xSeen 73
  did11
  did26
  did73
  refresh_output
  did -ra xSeen 96 $count93
}

alias -l did11 {  
  if ( $did(11) != xSeen ) {
    var %d11 = $did(11)
    did -uev xSeen 13,14,15,16,17,18,19,20,24,25,27,28,59,60,61,62,63,64,65,115
    did -h xSeen 66,82,100,101,102,103,104,105,106,107,108,109,116,117,118
    did -r xSeen 18,27,64,65
    did -b xSeen 13,14,17,28
    var %d11_18 = $readini($_seen.file,%d11,format)
    did -ac xSeen 18 %d11_18
    did -a xSeen 18 $iif(%d11_18 == Msg,Notice,$v2)
    var %d11_64 = $readini($_seen.file,%d11,target)
    did -ac xSeen 64 %d11_64
    did -a xSeen 64 $iif(%d11_64 == Chan,Nick,$v2)
    var %d11_65 = $readini($_seen.file,%d11,format3)
    did -ac xSeen 65 %d11_65
    did -a xSeen 65 $iif(%d11_65 == Msg,Notice,$v2)
    var %d11_27 = $readini($_seen.file,%d11,format2)
    did -ac xSeen 27 %d11_27
    did -a xSeen 27 $iif(%d11_27 == Msg,Notice,$v2)
    did -c xSeen $iif($readini($_seen.file,%d11,status),15,16)
    if ( $readini($_seen.file,%d11,notify) ) did -c xSeen 59
    did -era xSeen 19 $readini($_seen.file,%d11,trigger)
    if ( $readini($_seen.file,%d11,private) ) { 
      did -e xSeen 63,64,65
      did -c xSeen 62
    }
  }
  else {
    did -uev xSeen 15,16,24,66,82,100,101,102,103,104,105,106,107,108,109,116,117,118
    did -c xSeen $iif($readini($_seen.file,settings,status),15,16)
    if ( $readini($_seen.file,settings,smart) ) did -c xSeen 66
    if ( $readini($_seen.file,settings,wildcards) ) did -c xSeen 82
    if ( $readini($_seen.file,settings,events.texts) ) did -c xSeen 101
    if ( $readini($_seen.file,settings,events.actions) ) did -c xSeen 102
    if ( $readini($_seen.file,settings,events.querys) ) did -c xSeen 103
    if ( $readini($_seen.file,settings,events.joins) ) did -c xSeen 104
    if ( $readini($_seen.file,settings,events.parts) ) did -c xSeen 105
    if ( $readini($_seen.file,settings,events.quits) ) did -c xSeen 106
    if ( $readini($_seen.file,settings,events.kicks) ) did -c xSeen 107
    if ( $readini($_seen.file,settings,events.nickchange) ) did -c xSeen 108
    if ( $readini($_seen.file,settings,add.nicks.onjoin) ) did -c xSeen 116
    if ( $readini($_seen.file,settings,multiserver) ) did -c xSeen 117
    if ( $readini($_seen.file,settings,duration) ) did -c xSeen 118
    did -h xSeen 13,14,17,18,19,20,25,27,28,59,60,61,62,63,64,65,115
    did -b xSeen 109,100
  }
}

alias -l did26 {
  did -e xSeen 9,10
  if ( $did(26) == ALL ) { 
    did -e xSeen 8,9,10,68
    did $+(-e,$iif($readini($_seen.file,settings,auto.delete),c)) xSeen 45
    did -b xSeen 49,50,51,52
    if ( $readini($_seen.file,settings,auto.delete) ) {
      did -e xSeen 51,52
      did -era xSeen 49 $readini($_seen.file,settings,auto.delete.every)
      did -era xSeen 50 $readini($_seen.file,settings,auto.delete.old)
    }
  }
  else { 
    did -b xSeen 8,51,52,68
    did -ub xSeen 45
    did -rb xSeen 49,50
  }
}

alias -l did73 {
  var %d12 = $did(12), %do = $replace($did(73),No Saving, chans.nosave,No Notification,chans.nonotify,No Trigger,chans.notrigger)
  did -e xSeen 70,71,72
  did -er xSeen 69
  if ( $readini($_seen.file,%d12,%do) ) didtok xSeen 69 44 $v1
}

alias -l did93 {
  var %l = 1,%s
  while $did(xSeen,93,%l) {
    %s = %s $+ $v1 $+ $chr(32)
    inc %l
  }
  return %s
}

alias -l count93 {
  var %l = 1,%s = 0, %t
  while $did(xSeen,93,%l).len {
    inc %s $v1
    inc %l
  }
  %s = 200 - %s
  return %s
} 

alias -l xoutputs return Talking,Acting,Quitting,Parting,Joined,Joining,Nick Change,Kicking,Kicked,Many Matches,Not Seen,No Wildcards,Me,Self,Here,Nseen,On Chan,Not On Chan,Load,Long Nick,Found,Query,Duration,Duration2,No Match,Last Spoke,Has not spoke,No one spoke

alias -l refresh_output { 
  if ( !$1 ) { 
    did -r xSeen 92
    didtok xSeen 92 44 $xoutputs
    did -kc xSeen 92 1
    did -ram xSeen 93 $hget(xSeen.msgs,$remove($did(xSeen,92,1),$chr(32)))
  }
}

;alias set defaults
alias -l def_output {
  var %o = $remove($xoutputs,$chr(32)), %t = 1, %l = $numtok(%o,44)
  while %t <= %l {
    if ( $1 ) && ( $($+(%,xseenmsg.,$gettok(%o,%t,44)),2) ) hadd -m xSeen.msgs $gettok(%o,%t,44) $($+(%,xseenmsg.,$gettok(%o,%t,44)),2)
    elseif ( $1 ) || (( !$1 ) && ( !$hget(xSeen.msgs,$gettok(%o,%t,44)) )) hadd -m xSeen.msgs $gettok(%o,%t,44) $($+($,xseenmsg.,$gettok(%o,%t,44)),2)
    inc %t
  }
  hsave -o xSeen.msgs $_seenmsgs.log
  unset %xseenmsg.*
  if ( $2 ) .timerxSeen.setdefoutputs 1 0 _blankinput Loaded Default Outputs!
}

alias -l xSeen.about {
  noop $input(Project: xSeen $crlf $crlf Version: $seen.version $crlf $crlf Written by: xDaeMoN $crlf $crlf Email: xDaemon@xDaemon.us $crlf $crlf Description: A Multi-Server Seen System that has seen notification and more. $crlf $crlf Credits: $crlf $crlf Tye (for his Simple Seen System) and to the authors of Gseen and Bseen tcls.,guo,About xSeen)
}

alias -l xseen.cutlen return $iif($len($1-) > 100,$mid($1-,1,100) $+ ,$1-)

alias -l joinchans.buffer {
  var %w = @JoinChans.buffer
  window -hn %w
  if ( $2 ) aline %w $1- 
  if ( !$timer(xSeen.jcb) ) || ( !$group(#xsWHO) ) .timerxSeen.jcb 1 2 if ( $!line( %w ,1) ) getchan.buff $!v1
}

alias -l getchan.buff {
  var %w = @JoinChans.buffer
  if ($group(#xsWHO) == off) { .enable #xsWHO }
  scon $1 who $2 
  if ($window(%w)) dline %w 1
}

alias -l gethost.buffer {
  var %w = @GetHost.buffer
  window -hn %w
  if ( $4 ) { 
    if ( $fline(%w,$1-2 *,0) > 1 ) {
      var %a = $v1
      while %a {
        dline %w $fline(%w,$1-2 *,%a)
        dec %a
      }
    }
    aline %w $1- 
  }
  if ( !$timer(xSeen.ghb) ) || ( !$group(#xseen.gethost) ) .timerxSeen.ghb 1 2 if ( $!line( %w ,1) ) gethost.buff $!v1
}

alias -l gethost.buff {
  var %w = @GetHost.buffer
  if ( $group(#xseen.gethost) == off ) .enable #xseen.gethost
  scon $1 .userhost $2 
}

alias -l sc {
  if ( $1 == $null ) return 
  var %o = $scon(0)
  while %o {
    if ( $istok($scon(%o).network $scon(%o).server,$1,32) ) return %o
    dec %o
  }
  inc %o
}

raw 005:*: {
  if ( $wildtok($1-,*NICKLEN=*,1,32) ) _writeini $_net nicklen $gettok($wildtok($1-,*NICKLEN=*,1,32),2,61)
}

#xseen.gethost off
raw 302:*: {
  if ( $2 ) {
    var %w = @GetHost.buffer, %poa = $iif($gettok($line(%w,1),3,32) == act,6-,5-)
    tokenize 61 $2-
    xseen.add $+(seen:,$_net,:,$+($1,!,$right($2,-1))) $gettok($line(%w,1),3-5,32)
    xseen.add $+(seenspoke:,$_net,:private:,$+($1,!,$right($2,-1))) private $gettok($line(%w,1),4,32) $xseen.cutlen($gettok($line(%w,1),%poa,32))
    .disable #xseen.gethost
  }
  if ( $window(%w) ) dline %w 1
  halt
}
#xseen.gethost end

#xsWHO off
raw *:*: { 
  if ( $istok(353.366.324.329,$numeric,46) ) halt 
  elseif ( $numeric == 352 ) { 
    xseen.add $+(seen:,$_net,:,$+($6,!,$3,@,$4)) joined $ctime $2 
    xseen.add $+(seendur:,$_net,:,$2,:,$6) $ctime $ctime
    halt
  }
  elseif ( $numeric == 315 ) { 
    .disable #xsWHO 
    joinchans.buffer
    halt 
  }
}
#xsWHO end
alias xSeen { mDialog xSeen }

dialog xSeen {
  title xSeen v $+ $seen.version Settings [F5]
  size -1 -1 155 147
  option dbu
  icon $mB.Imgs(Seen.ico)
  tab "Settings", 1, 0 0 155 130
  tab "Channels", 2
  tab "Data", 3
  tab "Flood", 4
  tab "Messages", 76
  box "", 5, 5 15 145 110
  box "Search", 85, 5 0 145 64
  box "Options", 109, 5 49 145 76, tab 1 disable
  box "Select Events To Log", 100, 5 85 145 40, tab 1
  box "Search Results:", 88, 5 60 145 71
  box "Public", 13, 5 50 73 42, tab 1
  box "Private", 14, 77 50 73 42, tab 1
  box "Notification", 17, 5 88 73 37, tab 1
  box "Trigger", 28, 77 88 73 37, tab 1
  box "Messages", 90, 5 0 145 130
  box "Options", 110, 5 39 61 86, tab 3
  box "Delete Old Entries", 111, 65 39 85 86, tab 3
  box "Auto-Delete Entries", 112, 65 80 85 45, tab 3
  button "Close", 56, 115 133 35 12, ok
  button "Delete", 9, 70 66 75 12, tab 3
  button "Save", 8, 10 68 50 12, tab 3
  button "Statistics", 10, 10 53 50 12, tab 3
  button "Save", 6, 76 133 35 12, default
  button "Load", 68, 10 83 50 12, tab 3
  button "Add", 71, 95 66 50 12, tab 2
  button "Delete", 72, 95 79 50 12, tab 2
  button "Go", 87, 120 46 25 12
  button "Go", 95, 120 110 25 12, tab 76
  button "Preview", 99, 10 110 25 12, tab 76
  button "Reset Data", 54, 10 98 50 12, tab 3
  combo 11, 43 25 102 80, tab 1 drop
  combo 12, 43 25 102 80, tab 2 drop
  combo 26, 43 25 102 80, tab 3 drop
  combo 73, 95 52 50 80, tab 2 drop
  combo 77, 65 15 80 80, drop sort
  combo 18, 37 59 35 80, tab 1 drop
  combo 64, 37 73 35 80, tab 1 drop
  combo 65, 37 110 35 80, tab 1 drop
  combo 27, 110 73 35 80, tab 1 drop
  combo 92, 43 25 102 80, tab 76 drop sort
  combo 98, 10 96 50 40, tab 76 drop sort
  combo 120, 106 96 40 40, tab 76 drop sort
  combo 121, 75 46 43 40, drop sort
  check "Enable Auto Delete Data", 45, 70 88 70 10, tab 3
  check "Enable private trigger", 62, 81 59 65 10, tab 1
  check "Smart xSeen", 66, 10 59 45 10, tab 1
  check "Enable Trigger Flood Protection", 67, 15 105 90 10, tab 4
  check "Wildcards", 82, 10 72 40 10, tab 1
  check "Enable Notification", 59, 10 98 65 10, tab 1
  check "Edit Selected Output", 94, 10 77 75 10, tab 76
  check "Texts", 101, 10 95 28 10, tab 1
  check "Actions", 102, 10 108 28 10, tab 1
  check "Queries", 103, 43 95 30 10, tab 1
  check "Joins", 104, 43 108 25 10, tab 1
  check "Parts", 105, 76 95 25 10, tab 1
  check "Quits", 106, 76 108 25 10, tab 1
  check "Kicks", 107, 104 95 25 10, tab 1
  check "Nick Changes", 108, 104 108 44 10, tab 1
  check "Add Nicks On Join", 116, 58 72 55 10, tab 1
  check "Multi Server", 117, 58 59 40 10, tab 1
  check "Duration", 118, 104 59 40 10, tab 1
  radio "Enable", 15, 43 40 30 10, tab 1 group
  radio "Disable", 16, 76 40 30 10, tab 1
  edit "", 19, 81 110 15 10, tab 1 center,limit 1
  edit "", 39, 30 56 20 10, tab 4 center limit 3
  edit "", 40, 90 56 20 10, tab 4 center limit 4
  edit "", 48, 105 80 20 10, tab 4 center limit 4
  edit "", 49, 130 100 15 10, tab 3 center limit 2
  edit "", 50, 130 112 15 10, tab 3 center limit 3
  edit "", 70, 10 52 77 10, tab 2 autohs
  edit "", 79, 10 46 56 11, autohs
  edit "", 80, 10 68 136 60, multi vsbar
  edit "", 93, 10 40 136 36, multi vsbar limit 200 tab 76
  edit "", 96, 115 77 18 10, tab 76 read 
  edit "", 113, 130 48 15 10, tab 3 center limit 3
  list 69, 10 66 77 65, tab 2 sort vsbar hsbar
  menu "View", 81
  item "Settings", 84
  item break, 1000
  item "Search", 83
  text "Select:", 22, 10 27 18 10, tab 1
  text "Select:", 23, 10 27 18 10, tab 2
  text "Status:", 24, 10 41 20 10, tab 1
  text "Format:", 25, 10 60 21 10, tab 1
  text "Target:", 61, 10 74 20 10, tab 1
  text "Format:", 63, 81 74 21 10, tab 1
  text "Format:", 60, 10 111 21 10, tab 1
  text "Trigger Flood Protection", 41, 15 25 125 10, tab 4 center
  text "Set The Number Of Times The Trigger Can Only Be Used By Users Within A Certain Time:", 42, 15 35 125 20, tab 4
  text "Times Within", 43, 55 57 33 10, tab 4
  text "Seconds", 44, 115 57 23 10, tab 4
  text "Select:", 46, 10 27 18 10, tab 3
  text "Amount Of Time To Ignore (Minutes):", 47, 15 81 90 10, tab 4
  text "Every (Hours)?", 51, 70 100 38 10, tab 3
  text "Older Than (Days)?", 52, 70 112 47 10, tab 3
  text "Saving . . .", 57, 10 135 30 10
  text "Select Option:", 74, 96 42 50 10, tab 2
  text "Enter Channel Name:", 75, 10 42 60 10, tab 2
  text "Select Network:", 78, 10 16 40 10
  text "Seen / Lastspoke", 20, 100 111 50 10, tab 1
  text "Select:", 91, 10 27 18 10, tab 76
  text "Left", 97, 136 78 10 10, tab 76
  text "Enter Nick Or Wildcard:",86, 10 36 80 7
  text "Delete Seen Entries Older Than (Days):",114, 70 48 55 15, Tab 3
  text "Enter Trigger Character:",115, 81 98 70 10, Tab 1
  text "Reset :",119, 86 101 20 10, tab 76
  text "@",122, 67 47 6 11
}

On *:DIALOG:xSeen:*:*: {
  if ( $devent == init ) { 
    hOS EnableCloseBox $dialog(xSeen).hwnd false
    dialog_init
  }
  elseif ( $devent == sclick ) {
    if ( $did == 6 ) { 
      did -v $dname 57   
      did -b $dname 6
      .timerxSeen.hidesave 1 2 if ( $!dialog(xSeen) ) $({, ) did -h $dname 57 $(|, ) did -e $dname 6 $(}, )
      if ( $did(11) ) {
        if ( $v1 != xSeen ) {
          var %d11 = $did(11)
          _writeini %d11 status $did(15).state
          _writeini %d11 notify $did(17).state
          _writeini %d11 format $did(18)
          _writeini %d11 target $did(64)
          _writeini %d11 format2 $did(27)
          _writeini %d11 format3 $did(65)
          if ( $did(19) ) _writeini %d11 trigger $v1
          _writeini %d11 private $did(62).state
          _writeini %d11 notify $did(59).state
        }
        else _writeini settings status $did(15).state
        _writeini settings smart $did(66).state
        _writeini settings wildcards $did(82).state
        _writeini settings events.texts $did(101).state
        _writeini settings events.actions $did(102).state
        _writeini settings events.querys $did(103).state
        _writeini settings events.joins $did(104).state
        _writeini settings events.parts $did(105).state
        _writeini settings events.quits $did(106).state
        _writeini settings events.kicks $did(107).state
        _writeini settings events.nickchange $did(108).state
        _writeini settings add.nicks.onjoin $did(116).state
        _writeini settings multiserver $did(117).state
        _writeini settings duration $did(118).state
      }
      if ( $did(12) ) && ( $did(73) ) {
        var %d12 = $did(12), %do = $replace($did(73),No Saving, chans.nosave,No Notification,chans.nonotify,No Trigger,chans.notrigger)
        $iif($didtok($dname,69,44),writeini,remini) $_seen.file %d12 %do $v1
      }
      if ( $did(26) == ALL ) {
        if ( $did(49) ) {
          if ( $v1 isnum 1-1000 ) _writeini settings auto.delete.every $v1
          else did -ra $dname 49 $readini($_seen.file,settings,auto.delete.every)
        }
        if ( $did(50) ) {
          if ( $v1 isnum 1-1000 ) _writeini settings auto.delete.old $v1
          else did -ra $dname 50 $readini($_seen.file,settings,auto.delete.old)
        }
        _writeini settings auto.delete $did(45).state
        .timerxSeen.autodelete $iif($did(45).state,-o 0 $calc($iif($did(49) isnum 1-1000,$v1,$readini($_seen.file,ALL,auto.delete.every)) * 3600) seen.delold ALL $iif($did(50) isnum 1-1000,$v1,$readini($_seen.file,ALL,auto.save.old)),off) 1
      }
      if ( $did(39) ) {
        if ( $v1 isnum 1-100 ) _writeini settings flood.lines $v1
        else did -ra $dname 39 $readini($_seen.file,settings,flood.lines)
      }
      if ( $did(40) ) {
        if ( $v1 isnum 1-1000 ) _writeini settings flood.time $v1
        else did -ra $dname 40 $readini($_seen.file,settings,flood.time)
      }
      if ( $did(48) ) {
        if ( $v1 isnum 1-1000 ) _writeini settings flood.ignore $v1
        else did -ra $dname 48 $readini($_seen.file,settings,flood.ignore)
      }
      _writeini settings flood.pro $did(67).state
      if ( $did(92) )  hadd xSeen.msgs $remove($did(92),$chr(32)) $did93
    }
    elseif ( $did == 8 ) { 
      xseen.save
      .timerxSeen.savedata 1 0 _blankinput Data Saved!
    }
    elseif ( $did == 9 ) { 
      seen.delold $did(26) $did(113)
      did -r $dname 113
    }
    elseif ( $did == 10 ) { 
      .timerxSeen.seenstats 1 0 _blankinput $seen.stats($me,$did(26))
    }
    elseif ( $did == 11 ) {
      did11
    }
    elseif ( $did == 12 ) {
      var %d12 = $did(12)
      did -e $dname 73
    }
    elseif ( $did == 26 ) {
      did26
    }
    elseif ( $did == 45 )  { 
      did $iif($did(45).state,-e,-b) $dname 51,52
      did $iif($did(45).state,-era,-br) $dname 49 $readini($_seen.file,settings,auto.delete.every)
      did $iif($did(45).state,-era,-br) $dname 50 $readini($_seen.file,settings,auto.delete.old)
    }
    elseif ( $did == 54 )  .timerxSeenresetdatacheck 1 0 resetdatacheck
    elseif ( $did == 67 ) {
      if ( $did(67).state ) {
        did -e $dname 39,40,48
      }
      else did -b $dname 39,40,48
    }
    elseif ( $did == 68 ) {
      var %ee = $sfile(*.bak,Load xSeen Data,Load)
      if ( $istok($nopath($_seen.log) $nopath($_seen.bak),$nopath(%ee),32) )  { 
        if ( !$hget(xSeen) ) hmake xSeen 100
        hload xSeen $+(",%ee,")
        .timerxSeen.loaddata 1 0 _blankinput Loaded $hget(xSeen,0).item entries from $nopath(%ee)
      }
      elseif ( !%ee ) return
      else .timerxSeenerrorinvalidfile 1 0 _blankinputerror Could not load $+(",$nopath(%ee),",$chr(44)) not a valid xSeen file.
    }
    elseif ( $did == 71 ) {
      if ( $did(70) ) && ( $did(12) ) { 
        var %d70 = $gettok($did(70),1,32)
        if ( $chr(35) != $left(%d70,1) ) %d70 = $+($v1,%d70)
        if ( !$istok($didtok($dname,69,44),%d70,44) ) did -az $dname 69 %d70
        did -r $dname 70
      }
    }
    elseif ( $did == 72 ) {
      if ( $did(69).seltext ) { 
        did -d $dname 69 $did(69).sel
      }
    }
    elseif ( $did == 73 ) {
      did73
    }
    elseif ( $did == 87 )   { 
      if ( $did(79) ) {
        did -b $dname 87
        .timerxSeen.hidesearch 1 2 if ( $!dialog(xSeen) ) $({, ) did -e $dname 87 $(}, )
        if ( $did(121) == Seen ) did -ra $dname 80 $strip($seenpar($me,$+(seen:,$iif($did(77) == All,*,$v1),:,$did(79)))) 
        else did -ra $dname 80 $strip($seen.lastspoke($me,$iif($did(77) == All,*,$v1),:*:,$did(79)))
        did -rf $dname 79
      }
    }
    elseif ( $did == 92 ) { 
      did -ram $dname 93 $hget(xSeen.msgs,$remove($did($dname,92),$chr(32)))
      did -ue $dname 94
      did -ra $dname 96 $count93
      did -v $dname 96,97,98,99
    }
    elseif ( $did == 94 ) did $iif($did(94).state,-n,-m) $dname 93
    elseif ( $did == 95 ) { 
      if ( $did(120) ) {
        if ( $v1 == Current ) {
          if ( $did(92) ) .timerxSeendefoutput_check 1 0 defoutputcheck $v1
          else .timerxSeen.nooutputselected 1 0 _blankinput Please select an output to reset.
        }
        else .timerxSeendefoutput_check 1 0 defoutputcheck
      }
    }
    elseif ( $did == 99 ) && ( $did(92) ) echo $+(-,$lower($left($did(98),1))) 3Output Preview: $did93
  }
  elseif ( $devent == edit ) {
    if ( $did == 79 ) did -t $dname 87
    elseif ( $did == 113 ) did -t $dname 9
    elseif ( $did == 93 ) did -ra $dname 96 $count93
  }
  elseif ($devent == menu) {
    if ( $did == 83 ) { 
      did -h $dname $_ids
      did -h $dname 90,97,119
      did -v $dname 77,78,79,80,85,86,87,88,121,122
      did -b $dname 85,88
      did -c $dname 83
      did -u $dname 84
      did -m $dname 80
      did -f $dname 79
      var %k = 1, %se
      while $ini($_seen.file,%k) { 
        %se = $v1
        if ( !$istok($didtok($dname,77,44),%se,44) ) && ( %se != settings ) did -a $dname 77 %se
        inc %k   
      }
      if ( !$istok($didtok($dname,77,44),ALL,44) ) did -ac $dname 77 ALL
    }
    elseif ( $did == 84 ) { 
      did -v $dname $_ids
      did -u $dname 83
      dialog_init
    }
    elseif ( $did == 89 ) {
      did -c $dname 89
      did -u $dname 83,84
      did -h $dname $_ids
      did -h $dname 77,78,79,80,85,86,87,88,121,122
      did -v $dname 6,91,92,93,94,95,96,97,98,99,119,120
      did -bv $dname 90
    }
  }
}
alias -l _ids return 1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,22,23,24,25,26,27,28,39,40,41,42,43,44,45,46,47,48,49,50,51,52,57,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,100,101,102,103,104,105,106,107,108,109,115
alias -l seenmsg.text return $replace($hget(xSeen.msgs,talking),<nick>,$1,<seen_nick>,$2,<address>,$3,<channel>,$4,<time>,$5,<date>,$6,<on_chan>,$7)
alias -l seenmsg.act return $replace($hget(xSeen.msgs,acting),<nick>,$1,<seen_nick>,$2,<address>,$3,<channel>,$4,<time>,$5,<date>,$6,<on_chan>,$7)
alias -l seenmsg.quit return $replace($hget(xSeen.msgs,quitting),<nick>,$1,<seen_nick>,$2,<address>,$3,<channel>,$4,<time>,$5,<date>,$6,<quit_msg>,$7)
alias -l seenmsg.part return $replace($hget(xSeen.msgs,parting),<nick>,$1,<seen_nick>,$2,<address>,$3,<channel>,$4,<time>,$5,<date>,$6,<part_msg>,$7)
alias -l seenmsg.join return $replace($hget(xSeen.msgs,joining),<nick>,$1,<seen_nick>,$2,<address>,$3,<channel>,$4,<time>,$5,<date>,$6,<on_chan>,$7)
alias -l seenmsg.nick return $replace($hget(xSeen.msgs,nickchange),<nick>,$1,<seen_nick>,$2,<address>,$3,<channel>,$4,<newnick>,$5,<time>,$6,<date>,$7,<on_chan>,$8)
alias -l seenmsg.kicking return $replace($hget(xSeen.msgs,kicking),<nick>,$1,<seen_nick>,$2,<address>,$3,<knick>,$4,<channel>,$5,<time>,$6,<date>,$7,<kick_msg>,$8,<on_chan>,$9)
alias -l seenmsg.kick return $replace($hget(xSeen.msgs,kicked),<nick>,$1,<seen_nick>,$2,<address>,$3,<channel>,$4,<kickedby>,$5,<time>,$6,<date>,$7,<kick_msg>,$8)
alias -l seenmsg.manymatch return $replace($hget(xSeen.msgs,manymatches),<nick>,$1,<number>,$2)
alias -l seenmsg.nomatch return $replace($hget(xSeen.msgs,nomatch),<nick>,$1)
alias -l seenmsg.notseen return $replace($hget(xSeen.msgs,notseen),<nick>,$1,<seen_nick>,$2)
alias -l seenmsg.me return $replace($hget(xSeen.msgs,me),<nick>,$1)
alias -l seenmsg.self return $replace($hget(xSeen.msgs,self),<nick>,$1)
alias -l seenmsg.here return $replace($hget(xSeen.msgs,here),<nick>,$1,<seen_nick>,$2)
alias -l seenmsg.nseen return $replace($hget(xSeen.msgs,nseen),<nick>,$1,<address>,$2,<channel>,$3,<time>,$4,<date>,$5,<network>,$6)
alias -l seen.onchan { return $replace($iif($1 ison $2,$hget(xSeen.msgs,onchan),$hget(xSeen.msgs,notonchan)),<seen_nick>,$1) }
alias -l seenmsg.load return $replace($hget(xSeen.msgs,load),<nick>,$1,<seen_nick>,$2,<address>,$3,<time>,$4,<date>,$5)
alias -l seenmsg.joined return $replace($hget(xSeen.msgs,joined),<nick>,$1,<seen_nick>,$2,<address>,$3,<time>,$4,<date>,$5,<channel>,$6)
alias -l seenmsg.longnick return $replace($hget(xSeen.msgs,longnick),<nick>,$1)
alias -l seenmsg.nowildcards return $replace($hget(xSeen.msgs,nowildcards),<nick>,$1)
alias -l seenmsg.found return $replace($hget(xSeen.msgs,found),<number>,$1,<number2>,$2,<seen_nicks>,$3,<seen_msg>,$4-)
alias -l seenmsg.query return $replace($hget(xSeen.msgs,query),<nick>,$1,<seen_nick>,$2,<address>,$3,<time>,$4,<date>,$5)
alias -l seenmsg.duration return $replace($hget(xSeen.msgs,duration),<time>,$1)
alias -l seenmsg.duration2 return $hget(xSeen.msgs,duration2)
alias -l seenmsg.lastspoke return $replace($hget(xSeen.msgs,lastspoke),<nick>,$1,<seen_nick>,$2,<channel>,$3,<time>,$4,<date>,$5,<message>,$6)
alias -l seenmsg.hasnotspoke return $replace($hget(xSeen.msgs,hasnotspoke),<nick>,$1,<seen_nick>,$2)
alias -l seenmsg.noonespoke return $replace($hget(xSeen.msgs,noonespoke),<nick>,$1,<channel>,$2)
alias -l xseenmsg.joining return <nick>, <seen_nick> (<address>) was last seen Joining <channel> <time> ago (<date>). <on_chan>
alias -l xseenmsg.talking return <nick>, <seen_nick> (<address>) was last seen Talking on <channel> <time> ago (<date>). <on_chan>
alias -l xseenmsg.acting return <nick>, <seen_nick> (<address>) was last seen Acting on <channel> <time> ago (<date>). <on_chan>
alias -l xseenmsg.quitting return <nick>, <seen_nick> (<address>) was last seen Quiting on <channel> <time> ago (<date>) Stating: (<quit_msg>)
alias -l xseenmsg.parting return <nick>, <seen_nick> (<address>) was last seen Leaving <channel> <time> ago (<date>) stating: (<part_msg>)
alias -l xseenmsg.nickchange return <nick>, <seen_nick> (<address>) was last seen changing Nick on <channel> to <newnick> <time> ago (<date>) <on_chan>
alias -l xseenmsg.kicking return <nick>, <seen_nick> (<address>) was last seen kicking <knick> from <channel> <time> ago (<date>) with the Reason: (<kick_msg>) <on_chan>
alias -l xseenmsg.kicked return <nick>, <seen_nick> (<address>) was last seen kicked from <channel> by <kickedby> <time> ago (<date>) with the Reason: (<kick_msg>)
alias -l xseenmsg.manymatches return <nick>, I found <number> matches to your query; Please refine it to see any output.
alias -l xseenmsg.nomatch return <nick>, No matches were found.
alias -l xseenmsg.notseen return <nick>, I have not seen <seen_nick>.
alias -l xseenmsg.me return <nick>, You found me!
alias -l xseenmsg.self return <nick>, Looking for yourself, Eh?!
alias -l xseenmsg.here return <nick>, <seen_nick> is right here!
alias -l xseenmsg.nseen return <nick> (<address>) was looking for you on <channel> <time> ago (<date>). (<network>)
alias -l xseenmsg.onchan  return <seen_nick> is still there. 
alias -l xseenmsg.notonchan  return <seen_nick> is not there anymore though...
alias -l xseenmsg.joined return <nick>, <seen_nick> (<address>) was last seen <time> ago (<date>) when I joined <channel>.
alias -l xseenmsg.load return <nick>, <seen_nick> (<address>) was last seen <time> ago (<date>) when I loaded this script.
alias -l xseenmsg.longnick return <nick>, That Nick is too long. Nick length is limited in this Network.
alias -l xseenmsg.nowildcards return <nick>, Wildcards are not allowed.
alias -l xseenmsg.found return I Found <number> Matches to your query. Here are the <number2> most recent (sorted): <seen_nicks>. <seen_msg>
alias -l xseenmsg.query return <nick>, <seen_nick> (<address>) was last seen sending me a private message <time> ago (<date>).
alias -l xseenmsg.duration return after spending <time> there.
alias -l xseenmsg.duration2 return after spending some time there.
alias -l xseenmsg.lastspoke return <seen_nick> last spoke on <channel> <time> ago (<date>) saying: <message>
alias -l xseenmsg.hasnotspoke return <seen_nick> has not uttered a word yet.
alias -l xseenmsg.noonespoke return No one has uttered a word yet here.
