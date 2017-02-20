; ******************************************************
;          DC mBOT - Members Manager
; ******************************************************
alias MemberMgr { mDialog MemberMgr }
dialog MemberMgr {
  title "Member Manager [F3]"
  size -1 -1 226 263
  option dbu
  icon $mB.Imgs(F-Sh.ico)
  list 1, -6 -2 246 31, size
  list 2, 4 4 25 25, size
  text "Member Manager", 3, 29 3 210 15
  text "You can manage the users here. Including White/Black lists.", 4, 30 18 209 10
  tab "&White list", 5, 4 33 217 213
  box " Current user list ", 6, 8 51 210 93, tab 5
  list 7, 13 61 200 78, tab 5 size extsel
  box " Adding a new user or modify an existing one ", 9, 8 146 210 83, tab 5
  text "Mask (*!*@*):", 10, 11 159 48 10, tab 5 right
  edit "", 11, 62 158 120 10, tab 5
  text "Network:", 12, 11 173 48 10, tab 5 right
  edit "", 13, 62 172 120 10, tab 5
  check "All", 14, 185 172 30 10, tab 5
  text "Channel(s):", 15, 11 187 48 10, tab 5 right
  edit "", 16, 62 186 120 10, tab 5
  check "All", 17, 185 186 30 10, tab 5
  text "Access:", 18, 11 201 48 10, tab 5 right
  combo 19, 62 200 65 50, tab 5 size drop
  check "Ban Protected", 8, 133 200 49 10, tab 5
  text "Greet message:", 21, 11 215 48 10, tab 5 right
  edit "", 22, 62 214 120 10, tab 5
  text "(Optional)", 23, 183 215 28 10, tab 5
  button "Add", 24, 8 231 40 12, tab 5
  button "Remove", 26, 49 231 40 12, tab 5
  button "Reset form", 27, 167 231 50 12, tab 5
  check "Enable User list", 28, 6 250 65 10, tab 5
  tab "&Black list", 29
  box " Current Shit list ", 30, 8 51 210 93, tab 29
  list 31, 13 61 200 78, tab 29 size extsel
  box " Add a new or modify an existing one ", 33, 8 146 210 83, tab 29
  text "Mask (*!*@*):", 34, 11 159 48 10, tab 29 right
  edit "", 35, 62 158 120 10, tab 29
  text "Network:", 36, 11 173 48 10, tab 29 right
  edit "", 37, 62 172 120 10, tab 29
  check "All", 38, 185 172 30 10, tab 29
  text "Channel(s):", 39, 11 187 48 10, tab 29 right
  edit "", 40, 62 186 120 10, tab 29
  check "All", 41, 185 186 30 10, tab 29
  text "Action:", 42, 11 201 48 10, tab 29 right
  combo 43, 62 200 40 40, tab 29 size drop
  text "Type:", 44, 103 201 20 10, tab 29 right
  combo 45, 126 200 85 60, tab 29 size drop
  text "Kick Reason:", 46, 11 215 48 10, tab 29 right
  edit "", 47, 62 214 150 10, tab 29
  button "Add", 48, 8 231 40 12, tab 29
  button "Remove", 50, 49 231 40 12, tab 29
  button "Reset form", 51, 167 231 50 12, tab 29
  check "Enable Shit list", 52, 6 250 65 10, tab 29
  button "&Help", 53, 139 249 40 12
  button "&OK", 54, 180 249 40 12, default ok
}

on *:dialog:MemberMgr:*:*:{
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
    MDX SetFont $dname 3 +a 25 700 Ringbearer
    MDX SetFont $dname 4 +a 14 700 Arial
    did -i $dname 2 1 BmpSize 32 32
    did -i $dname 2 1 SetImage Icon Normal $noqt($mB.Imgs(F-Sh.ico))
    did -a $dname 2 +a 1 $chr(9) $+ Member Manager
    did -b $dname 1,2
    MDX SetControlMDX $dname 7,31 ListView AlignLeft RowSelect ShowSel Single Report Grid > $Views
    did -i $dname 7 1 HeaderDims 80:1 60:2 100:3 100:4 120:5
    did -i $dname 31 1 HeaderDims 80:1 100:2 100:3 60:4 70:5 150:6
    did -i $dname 7 1 HeaderText Mask $chr(9) Access $chr(9) Networks $chr(9) Channel(s) $chr(9) Greet Message
    did -i $dname 31 1 HeaderText Mask $chr(9) Server/Network $chr(9) Channel(s) $chr(9) Action $chr(9) BanType $chr(9) Reason

    if ($mB.Read(Members,Settings,WhiteList) == 1) { did -c $dname 28 }
    if ($mB.Read(Members,Settings,BlackList) == 1) { did -c $dname 52 }
    didtok $dname 19 44 Auto Op,Auto Hop,Auto Voice
    did -c $dname 19 2
    didtok MemberMgr 43 44 Kick,Ban,Kick-Ban
    did -c $dname 43 3
    var %x = 0
    while (%x < 20) { did -a MemberMgr 45 $mask(Nick!User@127-0-0-1.host.com,%x) | inc %x }
    mB.Members -br
    mB.Members -wr
    mB.Members -wl
    mB.Members -bl
  }
  elseif ($devent == sclick) {
    var %errMsg,%errDid = 0
    if ($did == 7) {
      did -a $dname 24 $iif($did(7).sel, Modify, Add)
      did $iif($did(7).sel, -e, -b) $dname 26
      if ($did(7).sel) {
        var %mask = $remove($gettok($did(7).seltext,6,32),+fs,$chr(9),$chr(32))
        var %item = $+(WL_,%mask)
        var %net = $mB.Read(Members,%item,Networks)
        var %chan = $mB.Read(Members,%item,Channels)
        var %acc = $mB.Read(Members,%item,Access)
        var %noban = $mB.Read(Members,%item,NoBan)
        var %greet = $mB.Read(Members,%item,Greet)
        did -r $dname 11,13,16,22
        did -ab $dname 11 %mask
        if (%net != $null) {
          if (%net == *) { did -c $dname 14 }
          else { did -ra $dname 13 %net }
        }
        if (%chan != $null) {
          if (%chan == *) { did -c $dname 15 }
          else { did -ra $dname 16 %chan }
        }
        did -c $dname 19 $findtok($didtok($dname,19,44),$replace(%acc,+o,Auto Op,+h,Auto Hop,+v,Auto Voice),1,44)
        did $iif(%noban == 1, -c, -u) $dname 8
        if (%greet != $null) { did -ra $dname 22 %greet }
      }
      else { mB.Members -wr }
    }
    elseif ($did == 26) && ($did(7).sel) {
      mB.Members -wd $did(11)
      mB.Members -wr
      mB.Members -wl
    }
    elseif ($did == 31) {
      did -a $dname 48 $iif($did(31).sel, Modify, Add)
      did $iif($did(31).sel, -e, -b) $dname 50
      if ($did(31).sel) {
        var %mask = $remove($gettok($did(31).seltext,6,32),+fs,$chr(9),$chr(32))
        var %item = $+(BL_,%mask)
        var %net = $mB.Read(Members,%item,Networks)
        var %chan = $mB.Read(Members,%item,Channels)
        var %act = $mB.Read(Members,%item,Action)
        var %type = $calc($mB.Read(Members,%item,Type) + 1)
        var %res = $mB.Read(Members,%item,Reason)

        if (%net != $null) {
          if (%net == *) { did -c $dname 38 }
          else { did -ra $dname 37 %net }
        }
        if (%chan != $null) {
          if (%chan == *) { did -c $dname 41 }
          else { did -ra $dname 40 %chan }
        }

        did -c $dname 43 $findtok($didtok($dname,43,44),$replace(%acc,kb,Kick-Ban),1,44)
        did -c $dname 45 $findtok($didtok($dname,43,44),$mask(Nick!User@127-0-0-1.host.com,$calc(%type - 1)),1,44)
        if (%rea != $null) { did -ra $dname 47 $v1 }
      }
      else { mB.Members -br }
    }
    elseif ($istok(14 17 38 41,$did,32)) { did $iif($did($did).state,-br,-e) $dname $calc($did - 1) }
    elseif ($did == 24) {
      if (!$did(11)) || (*!*@* !iswm $did(11)) { %errMsg = You should enter a Mask/wildcard (*!*@*) for this entry. | %errDid = 11 | goto xError }
      if (!$did(19).sel) { %errMsg = You have to select an access level for this entry. | goto xError }
      if (!$did(13)) && (!$did(14).state) { %errMsg = You need to define a Network name for this entry or mark the 'All' checkbox in front of it. | %errDid = 13 | goto xError }
      if (!$did(16)) && (!$did(17).state) { %errMsg = You need to define at least one channel name for this entry or mark the 'All' checkbox in front of it. | %errDid = 16 | goto xError }
      ; Mask = 11 -- Net = 13,14 -- Chans == 16,17 -- Acc == 19 -- Noban =  -- Greet == 22
      var %item = $did(11)
      var %net = $iif($did(14).state == 1, *, $remove($did(13),$chr(32)))
      var %chan = $iif($did(17).state == 1, *, $remove($did(16),$chr(32)))
      var %acc = $replace($did(19).seltext,Auto Op,+o,Auto Hop,+h,Auto Voice,+v)
      var %noban = $did(8).state
      var %greet = $did(22)
      mB.Members -wa %item %net %chan %acc %noban %greet
      mB.Members -wr
      mB.Members -wl
    }
    elseif ($did == 48) {
      if (!$did(35)) || (*!*@* !iswm $did(35)) { 
        if (!$did(35)) { %errMsg = You should enter a mask for the new entry. }
        else { %errMsg = The entry should be in format of Nick!Ident@Host, you can also use wildcards in it. }
        %errDid = 35
        goto xError
      }
      if (!$did(38).state) && (!$did(37)) { %errMsg = You need to define a Network name for this entry or mark the 'All' checkbox in front of it. | %errDid = 37 | goto xError }
      if (!$did(41).state) && (!$did(40)) { %errMsg = You need to define at least one channel name for this entry or mark the 'All' checkbox in front of it. | %errDid = 40 | goto xError }
      ; Mask = 35 -- Net = 37,38 -- Chan = 40,41 -- Action = 43 -- Type = 45 -- Reason = 47
      var %item = $did(35)
      var %net = $iif($did(38).state == 1, *, $remove($did(37),$chr(32))
      var %chan = $iif($did(41).state == 1, *, $remove($did(40),$chr(32))
      var %act = $replace($did(43).seltext,Kick-Ban,kb)
      var %type = $calc($did(45).sel - 1)
      var %reason = $iif($did(47) != $null, $v1, Blacklisted.)
      mB.Members -ba %item %net %chan %act %type %reason
      mB.Members -br
      mB.Members -bl
    }
    elseif ($did == 54) {
      mB.Write Members Settings WhiteList $did(28).state
      mB.Write Members Settings BlackList $did(52).state
      dialog -x $dname
    }
    elseif ($did == 27) { mB.Members -wr }
    elseif ($did == 51) { mB.Members -br }
    return
    :xError
    if (%errMsg) { Error.Show %errDid %errMsg }
  }
}

alias -l Error.Show {
  if ($1 isnum) && ($2-) {
    .noop $input($2-,wovg,Error!)
    if ($1 != 0) { did -f MemberMgr $v1 }
  }
}

alias mB.Members {
  if ($istok(-ba -bd -bl -wa -wd -wl -br -wr,$1,32)) { 
    if ($istok(-ba -wa,$1,32)) {
      var %w = mB.Write Members $+($iif($1 == -ba, BL_, WL_), $2)
      %w Networks $3
      %w Channels $4
      if ($1 == -ba) {
        %w Action $5
        %w Type $iif($6 isnum 0-19, $v1, 2)
        %w Reason $iif($7-, $v1, Blacklisted.)
        if ($isid) { return $true }
      }
      else {
        %w Access $5
        %w NoBan $6
        if ($7- != $null) { %w Greet $7- }
        if ($isid) { return $true }
      }
    }
    elseif ($istok(-bd -wd,$1,32)) {
      var %item = $+($iif($1 == -bd, BL_, WL_), $2)
      if ($mB.Read(Members,%item,Networks) != $null) {
        mB.Remove Members %item
        if ($isid) { return $true }
        return
      }
    }
    elseif ($istok(-bl -wl,$1,32)) {
      if ($dialog(MemberMgr)) {
        did -r MemberMgr $iif($1 == -wl, 7, 31)
        if ($mB.Ini(Members,0) > 0) {
          var %x = 1
          while ($mB.Ini(Members,%x)) {
            var %item = $v1
            if (%item != Settings) {
              if ($1 == -wl) && (WL_* iswm %item) {
                var %addr = $right(%item,-3)
                var %net = $mB.Read(Members,%item,Networks)
                var %chan = $mB.Read(Members,%item,Channels)
                var %acc = $mB.Read(Members,%item,Access)
                var %noban = $mB.Read(Members,%item,NoBan)
                var %greet = $mB.Read(Members,%item,Greet)

                did -a MemberMgr 7 %addr $chr(9) $replace(%acc,+o,Auto Op,+h,Auto Hop,+v,Auto Voice) $chr(9) $iif(%net == *,All,$v1) $chr(9) $iif(%chan == *,All,$v1) $chr(9) $iif(%greet != $null && %greet != 0,%greet,None)
              }
              elseif ($1 == -bl) && (BL_* iswm %item) {
                var %mask = $right(%item,-3)
                var %bnet = $mB.Read(Members,%item,Networks)
                var %bchan = $mB.Read(Members,%item,Channels)
                var %act = $mB.Read(Members,%item,Action)
                var %btype = $mB.Read(Members,%item,Type)
                var %res = $mB.Read(Members,%item,Reason)

                did -a MemberMgr 31 %mask $chr(9) $iif(%bnet == 1,All,$v1) $chr(9) $iif(%bchan == 1,All,$v1) $chr(9) $gettok(Kick Ban Kick-Ban,%act,32) $chr(9) $mask(Nick!User@127-0-0-1.host.com,%btype) $chr(9) $iif(%res,$v1,None)
              }
            }
            inc %x
          }
        }
      }
    }
    elseif ($istok(-br -wr, $1, 32)) && ($dialog(MemberMgr)) {
      if ($1 == -br) { 
        did -c MemberMgr 38,41
        did -c MemberMgr 43 3
        did -c MemberMgr 45 3
        did -b MemberMgr 50,37,40
        did -r MemberMgr 35,37,40
        did -ra MemberMgr 47 Blacklisted.
        did -a MemberMgr 48 Add
      }
      else {
        did -re MemberMgr 11,13,16,22
        did -c MemberMgr 14,17
        did -c MemberMgr 15 2
        did -b MemberMgr 13,16,26
        did -a MemberMgr 24 Add
      }
    }
  }
}

alias mB.Members.Check {
  ; $1 = $network - $2 = $chan - $3 = $event - $4 = $fulladdress
  if ($0 < 3) return
  var %x = 1
  while ($mB.Ini(Members,%x)) {
    var %item = $v1
    if (%item != Settings) {
      var %mask = $right(%item,-3)
      if (%mask iswm $4) {
        if ($3 == Join) {
          var %net = $mB.Read(Members,%item,Networks)
          var %chan = $mB.Read(Members,%item,Channels)
          if (%net == $1 || %net == *) && (%chan == $2 || %chan == *) { return %item }
        }
        elseif ($3 == NoBan) && (WL_* iswm %item) && ($mB.Read(Members,%item,NoBan) == 1) { return %item }
        elseif ($3 == CheckIdle) && (WL_* iswm %item) { return %item }
      }
    }
    inc %x
  }
  return $null
}
