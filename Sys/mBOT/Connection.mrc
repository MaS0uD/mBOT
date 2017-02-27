; ******************************************************
;       DC mBOT - Connection Manager
; ******************************************************
alias mB.ConMgr { mDialog ConnectionManager }
alias NewConnection { server $$1- }
alias NewConnectionStuff {
  if ($1) {
    mB.Admin.Login $1
    if ($mB.Read(Connections,$1,Nickname) != $null) {
      if ($mB.Read(Connections,$1,Nickname) != $me) { .nick $v1 }
      if ($mB.Read(Connections,$1,Password)) { $($replace($mB.Read(Connections,$1,NickServ),<Password>,$mB.Read(Connections,$1,Password)),2) }
    }
    var %x = 1,%chans = $mB.Read(Connections,$1,Channels),%chanz,%this
    if (%chans) {
      while ($gettok(%chans,%x,44)) {
        %this = $v1
        if ($gettok(%this,2,58) != $null) {
          $($replace($mB.Read(Connections,$1,ChanServ),<Channel>,$gettok(%this,1,58),<Password>,$gettok(%this,2,58)),2)
          %chanz = $addtok(%chanz,$gettok(%this,1,58),44)
        }
        else { %chanz = $addtok(%chanz,%this,44) }
        inc %x
      }
      if (%chanz) { join -n %chanz }
    }
  }
}

alias ConnectionsOnOpen {
  if ($mB.Ini(Connections,0) > 0) {
    var %x = 1,%y = $true
    while ($mB.Ini(Connections,%x)) {
      var %net = $v1
      if ($mB.Read(Connections,%net,Auto) == 1) {
        if ($mB.Read(Connections,%net,Server) != $null) {
          !server $iif(!%y,-m) $+($mB.Read(Connections,%net,Server),:,$iif($mB.Read(Connections,%net,Port),$v1,6667)) $&
            $iif($mB.Read(Connections,%net,BNCPassword),$v1)
          %y = $false
        }
      }
      inc %x
    }
  }
}

on $*:Notice:/NickServ IDENTIFY password/Si:*:{
  var %nick = $mB.Read(Connections,$network,Nickname),%pass = $mB.Read(Connections,$network,Password)
  if ($nick == NickServ) && ($me == %nick) {
    if (%pass != $null) {
      var %cmd = $mB.Read(Connections,$network,NickServ)
      $replace(%cmd,<Nick>,%nick,<Password>,%pass)
    }
  }
}

alias ServerManager {
  if (!$dialog(ConnectionManager)) return
  mDialog ServerManager
  var %ra = did -ra ServerManager
  if ($1) {
    did -b ServerManager 4
    %ra 4 $1
    %ra 6 $mB.Read(Connections,$1,Server)
    %ra 8 $iif($mB.Read(Connections,$1,Port) != $null,$v1,6667)
    if ($mB.Read(Connections,$1,Channels) != $null) { %ra 10 $v1 }
    if ($mB.Read(Connections,$1,Nickname) != $null) { %ra 12 $v1 }
    if ($mB.Read(Connections,$1,Password) != $null) { %ra 14 $v1 }
    if ($mB.Read(Connections,$1,Ident) != $null) { %ra 16 $v1 }
    if ($mB.Read(Connections,$1,BNCPassword) != $null) { %ra 18 $v1 }
    if ($mB.Read(Connections,$1,Auto) == 1) { did -c ServerManager 19 }
    if ($mB.Read(Connections,$1,ChanServ) != $null) { %ra 22 $v1 }
    if ($mB.Read(Connections,$1,NickServ) != $null) { %ra 24 $v1 }
    if ($mB.Read(Connections,$1,OperName) != $null) { %ra 35 $v1 }
    if ($mB.Read(Connections,$1,OperPassword) != $null) { %ra 37 $v1 }
    if ($mB.Read(Connections,$1,OperMode) != $null) { %ra 39 $v1 }
    dialog -t ServerManager Edit an existing Server...
    %ra 28 &Edit
  }
  else {
    %ra 8 6667
    %ra 16 $readini($qt($mircini),ident,userid)
    %ra 22 ChanServ identify <Channel> <Password>
    %ra 24 NickServ identify <Password>
  }
}

alias ServersLoader {
  if ($dialog(ConnectionManager)) {
    did -r ConnectionManager 2
    did -b ConnectionManager 4,5,10
    if (!$isfile($mB.Dir(mBOT\Connections.ini))) return

    if ($mB.Ini(Connections,0) > 0) {
      var %x = 1
      while ($mB.Ini(Connections,%x)) {
        var %net = $v1
        var %serv = $mB.Read(Connections,%net,Server)
        var %port = $mB.Read(Connections,%net,Port)
        var %chan = $mB.Read(Connections,%net,Channels)
        var %nick = $mB.Read(Connections,%net,Nickname)
        var %auto = $iif($mB.Read(Connections,%net,Auto) == 1,Yes,No)
        did -a ConnectionManager 2 1 %net $Tab $+(%serv,:,%port) $Tab %chan $Tab %nick $Tab %auto
        inc %x
      }
    }
  }
}

dialog ConnectionManager {
  title "Connection Manager [F7]"
  size -1 -1 257 190
  option dbu
  icon $mB.Imgs(Connection.ico)
  box "", 1, 3 30 250 142
  list 2, 6 36 243 117, size extsel
  button "+", 3, 6 156 15 12
  button "-", 4, 22 156 15 12
  button "&Edit", 5, 38 156 35 12
  button "Co&nnect", 10, 74 156 35 12
  button "Clear &All", 6, 208 156 40 12
  button "&Refresh", 7, 167 156 40 12
  button "&Close", 8, 208 175 45 12, cancel
  button "&Help", 9, 172 175 35 12
  list 11, -6 -1 270 30, size
  list 12, 4 4 25 25, size
  text "Connection Manager", 13, 29 3 234 15
  text "Manage each of your Servers, Nicknames, Channels and passwords...", 14, 30 18 233 10
}

on *:Dialog:ConnectionManager:*:*:{
  if ($devent == init) {
    hOS EnableCloseBox $dialog($dname).hwnd true
    MDX MarkDialog $dname
    MDX SetMircVersion $version
    MDX SetBorderStyle $dname 11,12 simple
    MDX SetControlMDX $dname 12 Toolbar flat nodivider wrap list arrows > $Bars
    MDX SetColor $dname 11,12,13,14 background $rgb(199,199,199)
    MDX SetColor $dname 11,12,13,14 textbg $rgb(199,199,199)
    MDX SetColor $dname 11,13 text $rgb(65,141,255)
    MDX SetColor $dname 14 text $rgb(0,0,0)
    MDX SetFont $dname 13 +a 25 700 Ringbearer
    MDX SetFont $dname 14 +a 14 700 Arial
    did -i $dname 12 1 bmpsize 32 32
    did -i $dname 12 1 setimage icon normal $noqt($mB.Imgs(ConSetting.ico))
    did -a $dname 12 +a 1 $chr(9) $+ Connection Manager
    did -b $dname 11,12
    MDX SetControlMDX $dname 2 ListView single report grid rowselect showsel > $Views
    did -i $dname 2 1 HeaderDims 110 135 120 70 45
    did -i $dname 2 1 HeaderText Network $chr(9) Server:Port $chr(9) Channels $chr(9) Nickname $chr(9) Auto?
    ServersLoader
  }
  if ($devent == dclick) {
    if ($did == 2) && ($did(2).sel) { ServerManager $remove($gettok($did(2).seltext,6,32),+fs,$chr(9)) }
  }
  if ($devent == sclick) {
    if ($did == 2) { did $iif(!$did(2).sel,-b,-e) $dname 4,5,10 }
    if ($did == 3) { ServerManager }
    if ($did == 4 && $did(2).sel) {
      var %Result = $input(Are you sure? $+ $crlf $+ You want to remove the selected connection?,wyvg,Confirmation)
      if (%Result == $yes) { mB.Remove Connections $remove($gettok($did(2).seltext,6,32),+fs,$chr(9)) | ServersLoader }
      else { return }
    }
    if ($did == 5 && $did(2).sel) { ServerManager $remove($gettok($did(2).seltext,6,32),+fs,$chr(9)) }
    if ($did == 6) {
      var %Result = $input(Are you sure? $+ $crlf $+ You want to remove all of the connections?,wyvg,Confirmation)
      if (%Result == $yes) { .write -c $mB.Dir(mBOT\Connections.ini) | ServersLoader }
      else { return }
    }
    if ($did == 7) { ServersLoader }
    if ($did == 9) { set %HFile ConMgr | Run_Help }
    if ($did == 10) {
      var %serv = $remove($gettok($did(2).seltext,11,32),+fs,$chr(9))
      var %net = $remove($gettok($did(2).seltext,6,32),+fs,$chr(9))
      set $+(%,TempConnection.,%net) Yes
      if ($server) { var %Result = $input(Connect on active window?,qnvg,Confirmation) }
      if (%Result == $yes) && ($server) { !disconnect }
      NewConnection $iif(%Result == $no,-m) %serv $iif($mB.Read(Connections,%net,BNCPassword),$v1)
    }
  }
}

dialog ServerManager {
  title "Add a new Connection"
  size -1 -1 218 215
  option dbu
  icon $mB.Imgs(Favorites.ico), 0
  box " Connection ", 2, 4 2 210 94
  text "&Network:", 3, 9 12 32 8
  edit "", 4, 49 11 90 10, autohs
  text "&Server:", 5, 9 26 32 8
  edit "", 6, 49 25 93 10, autohs
  text "P&ort:", 7, 146 26 20 8, right
  edit "", 8, 168 25 40 10, autohs
  text "Channe&l(s):", 9, 9 40 32 8
  edit "", 10, 49 39 159 10, autohs
  text "Nic&kname:", 11, 9 54 32 8
  edit "", 12, 49 53 65 10, autohs
  text "Pa&ssword:", 13, 121 54 30 8, right
  edit "", 14, 153 53 55 10, autohs
  text "I&dent:", 15, 9 68 32 8
  edit "", 16, 49 67 58 10, autohs
  text "&psyBNC Pass.:", 17, 111 68 40 8, right
  edit "", 18, 153 67 55 10, autohs
  check "&Username:", 1, 9 81 40 10
  edit "", 25, 49 81 58 10, autohs
  text "(For UnderNet/QuakeNet alike services.)", 26, 110 82 101 8
  box " Identification Commands ", 20, 4 98 210 60
  text "Channel:", 21, 9 110 32 8
  edit "", 22, 48 109 161 10, autohs
  text "Nickname:", 23, 9 124 32 8
  edit "", 24, 48 123 161 10, autohs
  text "** Tags: <Channel>, <Username>, <Nick> && <Password>. Read the help section for more information...", 27, 11 139 197 16
  check "A&uto Connect on Startup", 19, 6 201 76 10
  button "&Add", 28, 122 200 45 12, default
  button "&Cancel", 29, 168 200 45 12, cancel
  box " Oper Status ", 30, 4 159 210 39
  text "Username:", 34, 10 171 32 8
  edit "", 35, 48 170 65 10, autohs
  text "Password:", 36, 121 169 30 8, right
  edit "", 37, 153 168 55 10, autohs
  text "Usermode:", 38, 10 184 32 8
  edit "", 39, 48 183 40 10, autohs
  text "(This will be set upon oper login.)", 40, 91 184 86 8
}

on *:Dialog:ServerManager:sclick:*:{
  if ($did == 28) {
    if ($mB.Ini(Connections,$did(4)) > 0) && ($did(28) != &Edit) { beep 3 | return }
    if ($did(4) == $null) || ($did(6) == $null) { beep 3 | return }
    if (* * iswm $did(4) || * * iswm $did(6) || * * iswm $did(8)) { beep 3 | return }
    if ($did(1).state) && (* * iswm $did(25) || $did(5) == $null) { beep 3 | return }
    var %w = mB.Write Connections $did(4)
    %w Server $did(6)
    %w Port $remove($iif($did(8) != $null,$v1,6667),$chr(32))
    %w Channels $iif($did(10) != $null,$v1)
    if ($did(12) != $null) { %w Nickname $v1 }
    if ($did(14) != $null) { %w Password $v1 }
    if ($did(16) != $null) { %w Ident $v1 }
    if ($did(18) != $null) { %w BNCPassword $v1 }
    if ($did(25) != $null) { %w Username $v1 }
    if ($did(35) != $null) { %w OperName $v1 }
    if ($did(37) != $null) { %w OperPassword $v1 }
    if ($did(39) != $null) { %w OperMode $v1 }
    %w UsernameState $did(1).state
    %w ChanServ $iif($did(22) != $null,$v1,ChanServ identify <Password>)
    %w NickServ $iif($did(24) != $null,$v1,NickServ identify <Password>)
    %w Auto $did(19).state
    dialog -c $dname
    if ($dialog(ConnectionManager)) { ServersLoader }
  }
}
