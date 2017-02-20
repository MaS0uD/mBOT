; ******************************************************
;           DC mBOT - Channel Manager
; ******************************************************
alias CManager { mDialog mB.CManager }
dialog mB.CManager {
  title "Channel Manager"
  size -1 -1 232 193
  option dbu
  icon $mB.Imgs(Channel.ico)
  list 1, -6 -1 252 30, size
  list 2, 4 4 25 25, size
  text "Channel Manager", 3, 29 3 215 15
  text "Add or remove channels with their own settings", 4, 30 18 214 10
  box " Current channels ", 5, 3 32 98 144
  list 6, 7 42 90 115, size
  button "&Remove", 7, 58 159 37 12
  box " Add or modify a channel ", 8, 105 32 124 144
  text "Chann&el:", 9, 107 56 30 10, right
  edit "", 10, 139 55 84 10
  text "Net&work:", 11, 107 43 30 10, right
  combo 12, 139 42 84 35, edit drop
  text "&Features:", 13, 107 82 30 10, right
  list 14, 139 81 85 76, size vsbar check
  button "&Reset", 15, 182 159 40 12
  button "&Save", 16, 140 159 40 12
  button "&Close", 17, 188 178 40 12, cancel
  button "&Help", 18, 146 178 40 12
  text "Trigger:", 19, 107 69 30 10, right
  edit "", 20, 139 68 22 10, limit 1 center
  check "Bot's nick as trigger", 21, 164 68 62 10
}

on *:dialog:mB.CManager:*:*:{
  if ($devent == init) {
    hOS EnableCloseBox $dialog($dname).hwnd false
    MDX MarkDialog $dname
    MDX SetMircVersion $version
    MDX SetBorderStyle $dname 1,2 simple
    MDX SetControlMDX $dname 2 Toolbar flat nodivider wrap list arrows > $Bars
    MDX SetColor $dname 1,2,3,4 background $rgb(199,199,199)
    MDX SetColor $dname 1,2,3,4 textbg $rgb(199,199,199)
    MDX SetColor $dname 1,3 text $rgb(65,141,255)
    MDX SetColor $dname 4 text $rgb(0,0,0)
    MDX SetFont $dname 3 +a 25 700 Ringbearer
    MDX SetFont $dname 4 +a 14 700 Arial
    did -i $dname 2 1 bmpsize 32 32
    did -i $dname 2 1 setimage icon normal $noqt($mB.Imgs(Channel.ico))
    did -a $dname 2 +a 1 $chr(9) $+ Channel Manager
    did -b $dname 1,2
    MDX SetControlMDX $dname 6 ListView AlignLeft RowSelect ShowSel Single Report Grid > $Views
    did -i $dname 6 1 HeaderDims 87:1 87:2
    did -i $dname 6 1 HeaderText Network $chr(9) Channel
    didtok $dname 14 44 Auto Voicer,Auto Devoicer,Channel Limiter,Top10,Weather,IP Locator,Quotes,Ping Replyer,Seen,Channel Protections,Overall Statistics
    mB.Channels -l
    did -ra mB.CManager 20 $mB.Read(Managers,Config,Trigger)
  }
  if ($devent == sclick) {
    if ($did == 6) {
      if ($did(6).seltext) {
        tokenize 32 $CManager.GetItem($did(6).seltext)
        did -ra $dname 10 $2
        var %y = 1
        while ($did(12,%y)) {
          if ($v1 == $1) { did -c $dname 12 %y | break }
          inc %y
        }
        var %data = $mB.Read(Channels,$1,$2)
        if (%data != $null) {
          if ($istok(%data,NickTr,32)) { did -c $dname 21 | did -rb $dname 20 }
          else { did -u $dname 21 | did -era $dname 20 $Trigger($1,$2) }
          var %x = 1,%items = AV ADV Limit Top Weather IP Quote Ping Seen Pro Daily
          while (%x < 11) {
            did $iif($istok(%data,$gettok(%items,%x,32),32),-s,-l) $dname 14 %x
            inc %x
          }
        }
      }
      else { CManager.NewForm }
    }
    elseif ($did == 7) && ($did(6).seltext) {
      if ($input(Are you sure? You want to delete this channel?,wyvg,Confirmation) == $yes) {
        mB.Channels -d $CManager.GetItem($did(6).seltext)
        did -d $dname 6 $did(6).sel
      }
    }
    elseif ($did == 15) { CManager.NewForm }
    elseif ($did == 16) {
      if ($did(10) == $null) || (* * iswm $did(10)) { beep 2 | did -f $dname 10 | halt }
      if ($did(11) == $null) || (* * iswm $did(11)) { beep 2 | did -f $dname 11 | halt }
      if ($did(20) == $null) && ($did(21).state == 0) { beep 2 | did -f $dname 20 | halt }
      var %x = 1,%items = AV ADV Limit Top Weather IP Quote Ping Seen Pro Daily ,%flags
      while ($did(14,%x)) {
        if ($did(14,%x).cstate) { %flags = $addtok(%flags,$gettok(%items,%x,32),32) }
        inc %x
      }
      if ($numtok(%flags,32) == 0) { beep 2 | return }
      if ($did(21).state == 1) { %flags = %flags NickTr }
      if ($did(20) != $null) { %flags = %flags $+(Trigger|,$did(20)) }
      mB.Channels -a $did(12) $did(10) $iif(%flags,$v1,None)
      mB.Channels -l
    }
    elseif ($did == 18) { mB.Help CManager }
    elseif ($did == 21) { did $iif($did($did).state == 1,-b,-e) $dname 20 }
  }
}

alias CManager.GetItem { return $remove($1-,0,$chr(9),+fs) }

alias CManager.NewForm {
  if ($dialog(mB.CManager)) {
    did -r mB.CManager 10,20
    did -u mB.CManager 21
    var %x = 1
    while ($did(mB.CManager,14,%x)) { did -s mB.CManager 14 %x | inc %x }
  }
}

alias mB.Channels {
  if ($isid) {
    if ($0 >= 2) {
      if ($prop == IsInList) { return $iif($mB.Read(Channels,$1,$2) == $null,$false,$true) }
      elseif ($istok(AV ADV Limit Top Weather IP Quotes Ping Seen Pro Daily Quote NickTr,$prop,32)) { return $istok($mB.Read(Channels,$1,$2),$prop,32) }
    }
    return $false
  }
  else {
    if ($1 == -l) {
      if ($dialog(mB.CManager)) {
        did -r mB.CManager 6,12
        var %x = 1
        while ($mB.Ini(Channels,%x)) {
          var %topic = $v1,%y = 1
          did -a mB.CManager 12 %topic
          while ($mB.Ini(Channels,%topic,%y)) { did -a mB.CManager 6 %topic $chr(9) $v1 | inc %y }
          inc %x
        }
      }
    }
    if ($istok(-a -d,$1,32)) && ($0 >= 3) {
      if ($1 == -a) { mB.Write Channels $2 $3 $4- }
      elseif ($1 == -d) { mB.Remove Channels $2 $3 }
    }
    CManager.NewForm
  }
}