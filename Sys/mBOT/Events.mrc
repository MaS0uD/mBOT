; ******************************************************
;           DC mBOT - Events
; ******************************************************
on *:Text:*:#:{
  if ($mB.Status == 1) {
    if ($mB.Channels($network,$chan).IsInList) {
      var %line = $1-
      tokenize 32 $strip($1-)
      var %tr = $Trigger($network,$chan)
      if (%tr == $me && $1 == $me) || (%tr == $left($1,1)) {
        var %cmd = $iif(%tr == $me && $1 == $me,$2,$right($1,-1))
        var %rest = $iif($1 == $me,$3-,$2-)
        if (%cmd != $null) && ($IsCmd(%cmd)) {
          %cmd = $GetRootCmd(%cmd)
          if ($RequiresOp(%cmd)) && ($me !isop $chan) return
          if ($TriggerFlood($network,$fulladdress)) goto Pro
          if ($AccessList($network,$chan,$fulladdress,%cmd).Granted) {
            var %send = msg $chan
            var %do = DoOperation $chan $nick
            tokenize 32 %rest
            goto %cmd

            :Chan
            if (%cmd == Chan) {
              var %cmds = AV ADV Limit Top Weather IP Ping Seen Pro Daily
              var %c = $iif($1 ischan, $1, $chan)
              var %l = $iif(%c == $chan,$1-,$2-)
              if (%l == $null) {
                mB.Queue -a .notice $nick Current settings for %c is: $iif($mB.Read(Channels,$network,$chan) != $null, $v1, None.) (Possible settings: %cmds $+ )
                return
              }

              var %x = 1,%set
              while ($gettok(%l, %x, 32) != $null) {
                var %this = $v1
                if ($istok(%cmds,%this,32)) || (Trigger|?* iswm %this) { %set = %set %this }
                inc %x
              }
              if (%set != $null) {
                mB.Write Channels $network %c %set
                mB.Queue -a .notice $nick $+(%c,'s) settings have been set to: %set
                if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              }
              return
            }

            :Akill
            if (%cmd == Akill) {
              if ($1 == $null) { mB.Queue -a .notice $nick $+($Trigger($network,$chan),%cmd) <-a|-r> <Ident@Address> [Reason] }
              if ($istok(-a -r,$1,32)) && (*@* iswm $2) {
                if ($mB.Admin.AKill($2, $iif($3- != $null,$v1,A-banned.))) { mB.Queue -a .notice $nick $1 has been successfully $iif($1 == -a,added to,removed from) Akill list. }
                else {
                  if ($1 == -r) { mB.Queue -a .notice $nick $1 No such item. }
                  else { mB.Queue -a .notice $nick An error occured while adding $1 to the Whitelist. Please check the parameters and try again. }
                  return
                }
                if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              }
              return
            }

            :Kill
            if (%cmd == Kill) && ($mB.Read(Admin,Cmds,Kill) == 1) {
              if ($OperStatus) {
                mB.Queue -a kill $1 $iif($2-, $v1, No reason supplied.)
                if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              }
              return
            }

            :Gline
            if (%cmd == Gline) && ($mB.Read(Admin,Cmds,Gline) == 1) {
              if ($OperStatus) && (*.*.*.*.* iswm $1) {
                if (* $+ $1 $+ * iswm $address($me,5)) return
                .gline $+(*@,$1) $iif($2- != $null, $v1, $mB.Read(Admin,AKill,Reason))
                if ($Logger) { DoLog $network [Reports] $1 added $qt($1) G-lined. }
              }
            }

            :Kline
            if (%cmd == Kline) && ($mB.Read(Admin,Cmds,Kline) == 1) {
              if ($OperStatus) { mB.Queue -a kline $1 $iif($2-, $v1, No reason supplied.) }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Members
            if (%cmd == Members) {
              if ($1 == $null) { mB.Queue -a .notice $nick $+($Trigger($network,$chan),%cmd) <-wa|-ba|-wr|-br> for more info. (-wa = Whitelist Add, -ba = Blacklist Add, -wr = Whitelist Remove, -br = Blacklist Remove) }
              else {
                if ($istok(-wa -ba -wr -br,$1,32)) {
                  if ($2 == $null) { 
                    if ($1 == -wa) { mB.Queue -a .notice $nick $+($Trigger($network,$chan),%cmd) $1 <Mask> <Network|*> <Channel|*> <Aop|Hop|Vop|NoBan> [Greet Message] }
                    elseif ($1 == -ba) { mB.Queue -a .notice $nick $+($Trigger($network,$chan),%cmd) $1 <Mask> <Network|*> <Channel|*> <Ban|Kick|KickBan> [(Type)0-19] [Reason] }
                    elseif ($istok(-wr -br, $1, 32)) { mB.Queue -a .notice $nick $+($Trigger($network,$chan),%cmd) $1 <Mask> }
                    return
                  }
                  if ($1 == -wa) && (*!*@* iswm $2) && ($0 > 5) && ($istok(Aop Hop Vop, $5, 32)) {
                    var %mask = $2
                    var %net = $3
                    var %chan = $4
                    var %acc = $5
                    var %noBan = $iif($6 isnum 0-1, $v1)
                    var %greet = $7-
                    if ($mB.Members(-wa, %mask, %net, %chan, %acc, %noBan, %greet)) { mB.Queue -a .notice $nick %mask has been successfully added to Whitelist. }
                    else { mB.Queue -a .notice $nick An error occured while adding %mask to the Whitelist. Please check the parameters and try again. }
                  }
                  elseif ($1 == -ba) && (*!*@* iswm $2) && ($0 > 5) && ($istok(Ban Kick KickBan, $5, 32)) {
                    var %mask = $2
                    var %net = $3
                    var %chan = $4
                    var %act = $5
                    var %type = $iif($6 isnum 0-19, $v1)
                    var %rea = $7-
                    if ($mB.Members(-ba, %mask, %net, %chan, %act, %type, %res)) { mB.Queue -a .notice $nick %mask has been successfully added to Blacklist. }
                    else { mB.Queue -a .notice $nick An error occured while adding %mask to the Blacklist. Please check the parameters and try again. }
                  }
                  elseif ($1 == -wr) && ($2 != $null) && (*!*@* iswm $2) {
                    if ($mB.Members(-wd, $2)) { mB.Queue -a .notice $nick $2 has been successfully removed from Whitelist. }
                    else { mB.Queue -a .notice $nick $2 No such item found in Whitelist. }
                  }
                  elseif ($1 == -br) && ($2 != $null) && (*!*@* iswm $2) {
                    if ($mB.Members(-bd, $2)) { mB.Queue -a .notice $nick $2 has been successfully removed from Blacklist. }
                    else { mB.Queue -a .notice $nick $2 No such item found in Blacklist. }
                  }
                }
                if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
                return
              }
            }

            :Owner
            if (%cmd == Owner) {
              if (q isincs $nickmode) { %do +q $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :DeOwner
            if (%cmd == DeOwner) {
              if (q isincs $nickmode) { %do -q $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Protect
            if (%cmd == Protect) {
              if (a isincs $nickmode) { %do +a $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :DeProtect
            if (%cmd == DeProtect) {
              if (a isincs $nickmode) { %do -a $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Op
            if (%cmd == Op) {
              if (o isincs $nickmode) { %do +o $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :DeOp
            if (%cmd == DeOp) {
              if (o isincs $nickmode) { %do -o $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Hop
            if (%cmd == Hop) {
              if (h isincs $nickmode) { %do +h $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :DeHop
            if (%cmd == DeHop) {
              if (h isincs $nickmode) { %do -h $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Voice
            if (%cmd == Voice) {
              if (v isincs $nickmode) { %do +v $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :DeVoice
            if (%cmd == DeVoice) {
              if (v isincs $nickmode) { %do -v $1- }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Ban
            if (%cmd == Ban) {
              if ($1 == $me) || ($1 == $null) return
              if (*!*@* iswm $1) { mode $chan +b $1 }
              else { mB.Queue -a h mode $chan -hv+b $1 $1 $address($1,$iif($mB.Read(Managers,Config,BT) isnum 0-19,$v1,2)) }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :UnBan
            if (%cmd == UnBan) {
              if ($ibl($chan,0) < 1) || ($1 == $null) return
              var %a = 1
              while ($ibl($chan,%a)) {
                var %item = $v1
                if (*!*@* iswm $1) {
                  if (%item == $1) { mB.Queue -a h mode $chan -b %item | break }
                }
                else {
                  if (%item iswm $address($1,5)) { mB.Queue -a h mode $chan -b %item | break }
                }
                inc %a
              }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Kick
            if (%cmd == Kick) {
              if ($1 == $null) || ($1 !ison $chan) return
              mB.Queue -a h kick $chan $1 $iif($2-,$v1,01No reason specified. $+ $chr(15))
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :KickBan
            if (%cmd == KickBan) {
              if ($1 == $null) || ($1 !ison $chan) return
              mB.Queue -a h ban -k $chan $1 $iif($mB.Read(Managers,Config,BT) isnum 0-19,$v1,2) $iif($2-,$v1,01No reason specified. $+ $chr(15))
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Mode
            if (%cmd == Mode) {
              if ($1 == $null) return
              mB.Queue -a h mode $chan $1-
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :RemLastBan
            if (%cmd == RemLastBan) {
              if ($eval($+(%,LastBan,$network,$chan),2) != $null) { mB.Queue -a h mode $chan -b $v1 }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :ClearBanList
            if (%cmd == ClearBanList) {
              ClearCentralList b $chan
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :ClearExceptList
            if (%cmd == ClearBanList) {
              ClearCentralList e $chan
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :ClearInviteList
            if (%cmd == ClearBanList) {
              ClearCentralList I $chan
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Topic
            if (%cmd == Topic) {
              if ($gettok(%line,2-,32) != $null) { mB.Queue -a topic $chan $+($gettok(%line,2-,32),$chr(15)) }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Join
            if (%cmd == Join) {
              if ($1 == $null) || ($chr(36) isin $1-) return
              if ($chr(44) !isin $1-) {
                if ($me ison $1) { .notice $nick Open your eyes, I'm already there. | return }
                else {
                  set -u15 $+(%,CmdJoin.,$1) $nick I successfully joined $1
                  $+(.timer.CmdJoin.,$1) 1 10 .notice $nick I tried to join $1 but I couldn't. Something's wrong.
                  mB.Queue -a raw join $1
                }
              }
              else { mB.Queue -a raw join $Safe($$1-) }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Rejoin
            if (%cmd == Rejoin) {
              if ($1 == All) { RejoinAll $nick }
              else { Rejoin $iif($1,$1,$chan) }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Part
            if (%cmd == Part) {
              var %res = 02Requested by01 $nick $+ $chr(15)
              if ($1 == $null) { !part $chan %res }
              else {
                if ($1 == All) { !partall %res }
                elseif ($1 ischan) { !part $1 %res }
              }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Nick
            if (%cmd == Nick) {
              if ($1 == $null) return
              .nick $$1
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Quit
            if (%cmd == Quit) {
              if ($1 == All) { scon -at1 !quit $iif($2-,$2-,$mB.QuitMsg) $+ $chr(15) }
              else { !quit $iif($1-,$1-,$mB.QuitMsg) $+ $chr(15) }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Eval
            if (%cmd == Eval) {
              var %x = *$??code(?*)*
              if (%x iswm $1-) {
                if ($Logger) { DoLog $+(04,$time) $network $chan $nick Tried to exploit the EVAL command by using $qt(%line) $+ . (Could be a false-positive alert.) }
                return
              }
              mB.Queue -a msg $chan [Eval]: $+(02,$1-,) 04== $+(02,$iif($($1-,2) != $null,$v1,$!null),)
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return          
            }

            :UnsetAll
            if (%cmd == UnsetAll) {
              if ($IsOwner($network,$chan,$fulladdress)) { unsetall }
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return          
            }

            :SysInfo
            if (%cmd == SysInfo) {
              mB.Queue -a %send $mB.SysInfo
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }
            ; Note to self:
            ; Write down all the commands here...

            :Invite
            if (%cmd == Invite) {
              if ($1 != $null) && ($1 !ison $chan) {
                mB.Queue -a cs invite $1 $chan
                if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
                return
              }
            }
            :Peak
            if (%cmd == Peak) {
              var %c = $iif($1 ischan, $1, $chan)
              mB.Queue -a %send $+(%c,'s) Peak:04 $Top.GetPeak($network, %c)
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Quote
            if (%cmd == Quote) {
              if ($1 == $null) || ($1 isnum 1-) { 
                var %quote = $mB.Quotes($iif($1 isnum 1-, $1, $null)).Get
                if (%quote != $null) { mB.Queue -a %send %quote }
                return
              }
              elseif ($istok(-a -d -r count, $1, 32)) {
                if ($1 == -a) {
                }
                elseif ($1 == count) {  }
                if ($istok(-d -r, $1, 32)) && ($2 isnum 1-) {
                  var %result = $($+($,mB.Quote($2).,$iif($1 == -d, Del, Rep)),2)
                  if (%result) { mB.Queue -a .notice $nick Item has been successfully $iif($1 == -d, deleted., replaced.) }
                }
                else { mB.Queue -a .notice $nick Could not find the item. }
              }
              return
            }

            :mBInfo
            if (%cmd == mBInfo) {
              %send $mB.mBInfo
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :IP
            if (%cmd == IP) {
              if ($1 == $null) return
              Locate $network $chan $nick $1
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Weather
            if (%cmd == Weather) {
              if ($1 == $null) return
              GetWeather $network $chan $1-
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Ping
            if (%cmd == Ping) {
              if ($2) && ($2 !ison $chan) { .notice $nick No such a nickname like $2 is on $+($chan,.) | return }
              else { var %x = $iif($2 != $null, $v1, $nick) | set -u60 $+(%,Ping.,$network,.,%x) $nick $ticks | .ctcp %x ping }
            }

            :ChanStat
            if (%cmd == ChanStat) {
              mB.Queue -a %send $GetChanStat($iif($1 ischan, $1, $chan))
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Slap
            if (%cmd == Slap) {
              if ($1 == $null) return
              mB.Queue -a describe $chan Slaps $iif($1 == $me,$nick,$1) around a bit with a large trout!
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              return
            }

            :Top
            if ($mB.Channels($network,$chan).Top) {
              var %cmdx = $gettok($right($strip(%line),- $+ $iif(%tr == $me,$calc($len(%tr) + 1),$len(%tr))),1,32)
              var %MsgChan = msg $chan
              var %MsgNick = msg $nick
              var %NoticeNick = .notice $nick
              var %DescribeChan = describe $chan
              if ($Logger) { DoLog $network $chan $nick used $qt(%line) }
              if ($1 == help) { .notice $nick $+($Trigger($network,$chan),$iif(%tr == $me,$chr(32)),Top) <10|20|30|40|50|60|70|80|90|100|merge|bind|del|clearcache/cc|optimize/opt|count/?|save> [[Word|Letter|Line] [FirstNick] [SecondNick]] | return }
              elseif ($istok(stats stat,%cmdx,32)) {
                var %target = $iif($1 != $null,$1,$nick)
                var %output = $Top.GetStats($network,$chan,%target)
                var %msg = $Top.Msg(Stat)
                mB.Queue -a $eval($+(%,$GetMethod(Stat)),2) $replace(%msg,<Nick>,%target,<Channel>,$chan,<Output>,%output)
                return
              }
              elseif ($istok(tstats tstat,%cmdx,32)) {
                var %table = $+(Top.,$network,.,$chan),%tItem = $+($network,.,$chan,.T)
                if ($count($hget(%table,%tItem),0) == 9) return
                var %msg = $Top.Msg(TStat),%output = $Top.GetStats($network,$chan,%tItem).Today
                mB.Queue -a $eval($+(%,$GetMethod(TStat)),2) $replace(%msg,<Channel>,$chan,<Output>,%output)
                return
              }
              elseif (%cmd == Top) {
                if ($istok(10 20 30 40 50 60 70 80 90 100,$1,32)) {
                  var %output = $iif($Top.Make($+(Top.,$network,.,$chan),$1,$iif($istok(word letter line,$2,32),$2,word)) != $null,$v1,Couldn't find any matches in database.)
                  mB.Queue -a $eval($+(%,$GetMethod(Top)),2) %output
                  return
                }
                elseif ($istok($chr(63) count,$1,32)) {
                  var %count = $hget($+(Top.,$network,.,$chan),0).item
                  if (%count > 2) { %count = $calc(%count - 2) }
                  mB.Queue -a .notice $nick There $iif(%count == 1,is,are) %count unique $+(item,$iif(%count != 1,s)) in $+($chan,.)
                  return
                }
                var %hasAcc = $HasAcc($network,$chan,$fulladdress,Top)
                if (%hasAcc) {
                  if ($istok(opt optimize,$1,32)) {
                    var %ticks = $ticks,%olditems = $hget($+(Top.,$network,.,$chan),0).item,%items = $Top.Optimize($+(Top.,$network,.,$chan))
                    if (%items isnum) {
                      mB.Queue -a .notice $nick Optimization completed in $+($calc(($ticks - %ticks) / 1000),ms.) From a total items of $&
                        %olditems in $+($chan,'s) Top10 database, %items useless $iif(%items > 1,items,item) has been removed. Remaining items: $calc(%olditems - %items)
                      return
                    }
                  }
                  elseif ($1 == save) { Top.Save | .notice $nick Top10 databases saved successfully. | return }
                  elseif ($istok(merge bind del delete clearcache cc help,$1,32)) {
                    if ($1 == merge) {
                      if ($2 == $null) && ($3 == $null) { mB.Queue -a .notice $nick Syntax: $+($Trigger($network,$chan),Top) Merge <ThisNick> <WithThisNick> }
                      else  { mB.Queue -a .notice $nick $Top.Merge($network,$chan,$2,$3-) }
                      return
                    }
                    elseif ($1 == bind) {
                      if ($2 == $null) && ($3 == $null) { mB.Queue -a .notice $nick Syntax: $+($Trigger($network,$chan),Top) Bind <ThisNick> <ToThisNick> }
                      else { mB.Queue -a .notice $nick $Top.Bind($network,$chan,$2,$3-) }
                      return
                    }
                    elseif ($istok(del delete,$1,32)) {
                      var %table = $+(Top.,$network,.,$chan)
                      if ($hget(%table,$2)) { hdel %table $2 | .notice $nick $2 has been removed from $chan Top10. }
                      return
                    }
                    elseif ($istok(clearcache cc,$1,32)) {
                      unset $eval($+(%,Recent.Top.,$network,$chan,.*),1)
                      mB.Queue -a .notice $nick $+($chan,'s) Top10 caches has been removed.
                      return
                    }
                  }
                }
              }
            }
          }
        }
      }
      ; Checking for possible crimes :P
      :Pro
      var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
      if (%noBan) goto DontCheck
      if ($mB.Channels($network, $chan).Pro) {
        if ($mB.Pro.Parse($event,$network,$chan,$fulladdress,%line)) return
      }
      :DontCheck
      ; No? Good then, doing some other stuff...

      ; Auto voicer
      if ($mB.Channels($network,$chan).AV) && (!$mB.NoVoice($nick,$chan)) {
        if ($nick !isreg $chan) return
        mB.Voice $network $chan $nick $iif($mB.Read(Extra,Voice,AVMethod) == 1,$len($strip(%line)),$0)
      }

      ; Top10 stuff
      if ($mB.Channels($network,$chan).Top) {
        if ($Top.IsValid($nick)) {
          var %x = 1,%y = $strip(%line)
          while ($wildtok(%y,*?://*,%x,32)) { %y = $remtok(%y,$v1,1,32) | inc %x }
          Top.Write $network $chan $nick W,T,L $+($numtok(%y,32),$chr(44),$len($remove(%y,$chr(32))),$chr(44),1)
        }
      }
    }
    return

    :Error
    if ($Logger) { DoLog $network $chan [Error] Something went wrong: $error }
    ResetError
  }
}

on *:Text:*:?:{
  tokenize 32 $1-
  if ($1 == Login) && ($2 != $null) { noop $AccessList($fulladdress, $2-).Login }
  elseif ($1 == Logout) { noop $AccessList($nick).Logout }
  elseif ($1 == Help) { }
}

on *:Action:*:#:{
  var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
  if (%noBan) goto DontCheck
  if (!$Pro.CheckUp($chan)) return  

  ; Checking for possible crimes :P
  if ($mB.Pro.Parse($event,$network,$chan,$fulladdress,$1-)) return

  :DontCheck
  tokenize 32 $strip($1-)

  ; Auto voicer
  if ($mB.Channels($network,$chan).AV) && (!$mB.NoVoice($nick,$chan)) {
    if ($nick !isreg $chan) return
    mB.Voice $network $chan $nick $iif($mB.Read(Extra,Voice,AVMethod) == 1,$len($1-),$0)
  }

  ; Top10 stuff
  if ($mB.Channels($network,$chan).Top) && ($Top.IsValid($nick)) {
    var %x = 1,%y = $1-
    while ($wildtok(%y,*?://*,%x,32)) { %y = $remtok(%y,$v1,1,32) | inc %x }
    Top.Write $network $chan $nick W,T,L,A $+($numtok(%y,32),$chr(44),$len($remove(%y,$chr(32))),$chr(44),1,$chr(44),1)
  }
}

on @*:Notice:*:#:{
  if (!$Pro.CheckUp($chan)) return
  var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
  if (%noBan) return
  noop $mB.Pro.Parse($event,$network,$chan,$fulladdress,$1-)

}

on *:Invite:#:{
  if ($IsOwner($network,$chan,$fulladdress) != $null) { .join $chan }
}

on *:Join:#:{
  if ($nick == $me) {
    mode $chan b $+ $crlf $+ mode $chan e $+ $crlf $+ mode $chan I
    if ($eval($+(%,CmdJoin.,$chan),2) != $null) {
      .notice $v1
      unset $+(%,CmdJoin.,$chan)
      $+(.timer.CmdJoin.,$chan) off
    }
    if ($mB.Channels($network,$chan).ADV) {
      if (!$timer(.DV. $+ $network)) {
        $+(.timer.DV.,$network) 0 $iif($mB.Read(Extra,Voice,ADVCheck) != $null,$v1,60) mB.CheckIdle $network
      }
    }
  }
  else {
    if ($($+(%,NS.,$network,$chan,$address),2) != $null) goto Jump
    var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
    if (%noBan) goto DontCheck
    if ($mB.Pro.Parse($event,$network,$chan,$fulladdress)) return

    :DontCheck
    if ($mB.Channels($network,$chan).Top) {
      Top.Write $network $chan $nick J 1
      Top.SetPeak $network $chan $nick($chan,0)
    }
    :Jump
    if ($mB.Channels($network,$chan).Limit) && ($mB.Read(Extra,Limiter,Method) == 1) { mB.Limiter $network $chan }
    if ($me isop $chan) {
      if ($mB.Read(Members,Settings,WhiteList) == 1) {
        if ($mB.Members.Check($network,$chan,Join,$fulladdress) != $null) {
          var %item = $v1,%acc = $mB.Read(Members,%item,Access)
          if (WL_* iswm %item) {
            if ($mB.Read(Members,%item,Greet)) && ($($+(%,GreetSent.,$network,.,$nick),2) != 1) {
              mB.Queue -a .notice $nick $mB.Read(Members,%item,Greet)
              set -u1000 $+(%,GreetSent.,$network,.,$nick) 1
            }
            if ($istok(+o +h +v,%acc,32)) {
              if (%acc == +h) { mB.Queue -a $+(.timer.x,$chan,.,$nick) 1 2 $iif($nick !ishop $chan,mode $chan %acc $nick,noop) }
              else { mB.Queue -a $iif(%acc == +o,pop,pvoice) 2 $chan $nick }
            }
            return
          }
          else {
            var %res = $iif($mB.Read(Members,%item,Reason), $v1, Blacklisted.)
            var %act = $iif($mB.Read(Members,%item,Action), $v1, kb)
            var %btype = $iif($mB.Read(Members,%item,Type), $v1, 2)
            mB.Queue -a h $iif($istok(b kb, %act, 32), ban, kick) $iif(%act == kb, -k) $chan $nick $iif($istok(b kb, %act, 32), %btype) $+(%reason,$chr(15))
            return
          }
        }
      }
    }
  }
}

on *:Part:#:{
  if ($nick == $me) {
    if ($hget($+(AV.,$network,.,$chan))) { .hfree $v1 }
    mB.Queue.Close $network $chan
  }
  else {
    if (!$Pro.CheckUp($chan)) return
    var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
    if (%noBan) goto DontCheck

    if ($mB.Pro.Parse($event,$network,$chan,$fulladdress,$1-)) return

    :DontCheck
    if ($hget(%x,$nick)) { .hdel %x $nick }
    if ($mB.Channels($network,$chan).Top) { Top.Write $network $chan $nick P 1 }
    if ($mB.Channels($network,$chan).Limit) && ($mB.Read(Extra,Limiter,Method) == 1) { mB.Limiter $network $chan }
  }
}

on *:Kick:#:{
  if ($knick != $me) {
    if ($mB.Channels($network,$chan).Top) { Top.Write $network $chan $knick K 1 }
    var %x = $+(AV.,$network,.,$chan)
    if ($hget(%x,$knick)) { .hdel %x $knick }
    if ($mB.Channels($network,$chan).Limit) && ($mB.Read(Extra,Limiter,Method) == 1) { mB.Limiter $network $chan }
  }
}

on *:Ban:#:{
  set $+(%,LastBan,$network,$chan) $banmask
  if ($bnick != $me) {
    var %x = $+(AV.,$network,.,$chan)
    if ($hget(%x,$bnick)) { .hdel %x $bnick }
    if ($mB.Members.Check($network,$chan,NoBan,$fulladdress) != $null) { mode $chan -b $banmask }
  }
  if (!$Pro.CheckUp($chan)) return

  var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
  if (%noBan) { mode $chan -b $banmask | goto DontCheck }

  if ($mB.Pro.Parse($event,$network,$chan)) return

  :DontCheck
  if ($mB.Channels($network,$chan).Top) {
    var %x = $nick($chan,0)
    while (%x) {
      if ($banmask iswm $address($nick($chan,%x),5)) { Top.Write $network $chan $nick($chan,%x) B 1 }
      dec %x
    }
  }
}

on *:Op:#:{
  var %x = $+(AV.,$network,.,$chan)
  if ($hget(%x,$opnick)) { .hdel %x $opnick }
  if ($opnick == $me) && ($mB.Channels($network,$chan).Limit) {
    $iif($mB.Read(Extra,Limiter,Method) == 1,mB.Limiter,mB.Limiter.Timer) $network $chan
  }
}

on *:Voice:#:{
  var %x = $+(AV.,$network,.,$chan)
  if ($hget(%x,$vnick)) { .hdel %x $vnick }
}

on *:Quit:{
  if ($nick == $me) {
    .hfree -w $+(AV.,$network,.*)
    $+(.timer.DV.,$network) off
    $+(.timer.Limit.,$network) off
    Statusbar -r
  }
  else { 
    var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
    if (%noBan) goto DontCheck
    if ($mB.Pro.Parse($event,$network,$chan,$fulladdress,$1-)) return

    :DontCheck
    noop $AccessList($nick).Logout

    var %x = 1
    while ($comchan($nick,%x)) {
      var %chan = $v1,%table = $+(AV.,$network,.,%chan)
      if ($hget(%table,$nick)) { .hdel %table $nick }
      if ($mB.Channels($network,%chan).Limit) && ($mB.Read(Extra,Limiter,Method) == 1) { mB.Limiter $network %chan }
      if (. isin $1) && (. isin $2) {
        set -u900 $+(%,NS.,$network,%chan,$address) 1
        if ($mB.Channels($network,%chan).Top) {
          if ($eval($+(%,NetSplit.,$network,.,%chan),2) == $null) {
            Top.Write $network %chan $nick S 1
            set -u60 $+(%,NetSplit.,$network,.,%chan) 1
          }
        }
        if ($eval($+(%,NetSplit.,$network),2) == $null) {
          mB.Queue -a $+(.timer.NS,$network) 1 2 amsg Net split detected: $1 <> $2
          set -u60 $+(%,NetSplit.,$network) 1
        }
      }
      else {
        if ($mB.Channels($network,%chan).Top) { Top.Write $network %chan $nick Q 1 }
      }
      inc %x
    }
  }
}

on *:Nick:{
  if (!$istok($nick $newnick,$me,32)) return
  var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
  if (%noBan) return

  noop $mB.Pro.Parse($event,$network,$chan,$fulladdress, $nick $newnick)
}

Ctcp *:*:#:{
  if ($nick == $me) || (!$Pro.CheckUp($chan)) return
  var %noBan = $HasAcc($network,$chan,$fulladdress,NoKickBan)
  if (%noBan) return
  noop $mB.Pro.Parse($event,$network,$chan,$fulladdress,$1-)
}

on !*:RawMode:*:{
  if ($mB.Channels($network,$chan).Limit) && ($mB.Read(Extra,Limiter,OnlyMe) == 1) {
    if (l isincs $1) { mB.Limiter $network $chan }
  }
}

on !*:Mode:*:{
  if ($mB.Channels($network,$chan).Limit) && ($mB.Read(Extra,Limiter,OnlyMe) == 1) {
    if (l isincs $1) { mB.Limiter $network $chan }
  }
}

on !*:ServerMode:*:{
  if ($mB.Channels($network,$chan).Limit) && ($mB.Read(Extra,Limiter,OnlyMe) == 1) {
    if (l isincs $1) { mB.Limiter $network $chan }
  }
}

on ^1:SNotice:*:{
  if (*Looking up your* iswm $1-) return
  if (*Couldn't*your hostname* iswm $1-) return
  if (*Found your hostname* iswm $1-) return
  if (*Checking Ident* iswm $1-) return
  if (*Got Ident response* iswm $1-) return
  if (*motd was last changed* iswm $1-) return
  if (*Server flood protection* iswm $1-) return
  if (*No ident response* iswm $1-) || (*username prefixed* iswm $1-) return
  if (*Ident broken or* iswm $1-) return
  if (*Received identd response* iswm $1-) return
  if (*Client Connecting* iswm $1-) { 
    if ($mB.Read(Admin,Reports,Connect) == 1) { DoLog $network [Reports] $9 $1- }
    if ($mB.Read(Admin,AKill,Status) == 1) { mB.Admin.AKill.Check $9 $replace($remove($10,$chr(40),$chr(41)),$chr(64),$chr(32)) }
  }
  if ($mB.Read(Admin,Logs,SNotice) == 1) {
    if ($window(@SNotice,state) == 0) { window -k0Bnz @SNotice 0 0 450 160 }
    aline -hp @SNotice $timestamp $chr(91) $+ $network $+ $chr(93) $+ : $1-
  }
  if ($mB.Read(Admin,Logs,Sort) == 0) { .write $mB.Dir(mBOT\SNotices\All.txt).qt $timestamp $network $1- }
  else {
    var %Log.Date = $replace($date,$chr(32),$chr(45),$chr(46),$chr(45),$chr(95),$chr(45),$chr(47),$chr(45),$chr(92),$chr(45))
    var %file = $mB.Dir($+(mBOT\SNotices\,%Log.Date,.txt)).qt
    if (!$exists(%file)) {
      .write -c $qt(%file)
      .write $qt(%file) Server Notice logfile created at: $date - $time
      .write $qt(%file) $str($chr(61),30)
      .write $qt(%file) $timestamp $network $1-
    }
    else { .write $qt(%file) $timestamp $network $1- }
  }
  if (*did a /whois* iswm $1-) && ($mB.Read(Admin,Reports,Whois) == 1) { DoLog $network [Reports] N/A $1- }
  if (*Client Exiting* iswm $1-) && (*Kill* iswm $1- || *Banned* iswm $1-) && ($mB.Read(Admin,Reports,Kill) == 1) { DoLog $network [Reports] N/A $1- }
  if (*Client Exiting* iswm $1-) && ($mB.Read(Admin,Reports,Exit) == 1) { DoLog $network [Reports] N/A $1- }
  if (*Failed* iswm $1- && *OPER* iswm $1-) && ($mB.Read(Admin,Reports,Fail) == 1) { DoLog $network [Reports] N/A $1- }
  if ($mB.Read(Admin,Logs,SNotice) == 1) { halt }
}

on *:Connect:{
  NewConnectionStuff $network
  if ($mB.Read(Connections,$network,UsernameState) == 1) {
    var %nick = $mB.Read(Connections,$network,Nickname),%pass = $mB.Read(Connections,$network,Password)
    var %user = $mB.Read(Connections,$network,Username),%cmd = $mB.Read(Connections,$network,NickServ)
    if (%user != $null) && (%pass != $null) { $($replace(%cmd,<Nick>,%nick,<Password>,%pass,<Username>,%user),2) }
  }
  Statusbar
}

on *:Disconnect:{
  .hfree -w $+(AV.,$network,.*)
  $+(.timer.DV.,$network) off
  $+(.timer.Limit.,$network) off
  $+(.timer.Queue.,$network) off
  Statusbar -r
  mB.Toolbar
  unset $+(%,*,$network,*)
  mB.Queue.Close $network
}

on *:Active:*:{
  .titlebar [mBOT $mB.Ver by $mB.Author $+ ]
  mB.Toolbar
  Statusbar
}

on *:Start:{ mB.Startup }
on *:Exit: { mB.CleanUp }

raw 381:*:{
  if ($mB.Read(Connections,$network,OperMode) != $null) { mode $me $v1 }
}

on *:CtcpReply:*Ping*: {
  if ($($+(%,Ping.,$network,.,$nick),2) != $null) {
    var %content = $v1
    var %nick = $gettok(%content,1,32),%ticks = $gettok(%content,2,32)
    var %Pinger = $calc($calc($ticks - %ticks) / 1000),%x
    if (%Pinger <= 2) { %x = 03 }
    elseif (%Pinger > 2) && (%Pinger <= 9) { %x = 07 }
    elseif (%Pinger > 9) && (%Pinger <= 17) { %x = 05 }
    elseif (%Pinger > 17) { %x = 04 }
    var %msg = $mB.Read(Extra,Msgs,Ping)
    mB.Queue -a .notice %nick $replace(%msg,<Network>,$network,<Server>,$server,<Nick>,$nick,<Delay>,$+($chr(3),%x,%Pinger,ms,$chr(15)))
    unset $+(%,Ping.,$network,.,$nick)
    haltdef
  }
}
