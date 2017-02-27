; ******************************************************
;           DC mBOT - Popup Menus
; ******************************************************
menu Menubar {
  -
  Main Settings $+ $chr(9) $+ F1:mBOT
  -
  Protections $+ $chr(9) $+ F2:mB.Pro
  -
  Members $+ $chr(9) $+ F3:mB.MemberMgr
  -
  Extra Settings $+ $chr(9) $+ F4:mB.Extra
  -
  Seen System $+ $chr(9) $+ F5:xSeen
  -
  IRCOp Settings $+ $chr(9) $+ F6:mB.Admin
  -
  Connection Manager $+ $chr(9) $+ F7:mB.ConMgr
  -
  Channel Manager $+ $chr(9) $+ F8:mB.ChanMgr
  -
  Help $+ $chr(9) $+ F11::
  -
  About $+ $chr(9) $+ F12:mB.About
  -
  Otherz
  .Create Shortcut:AskForShortcut UserRequested
  -
}

menu Channel,Status {
  -
  $iif($active == Status Window,$iif($server,Disconnect,Connect)):$iif($server,quit,server)
  -
  &Settings
  .Main:mBOT
  .-
  .Extra:mB.Extra
  .-
  .Protections:mB.Pro
  .-
  .Members:mB.MemberMgr
  .-
  .Seen:xSeen
  .-
  .IRCOp:mB.Admin
  .-
  .Connection:mB.ConMgr
  .-
  .Channel:mB.ChanMgr
  .-
  Directories
  .Root:.run $qt($mircdir)
  .-
  .Logs:.run $qt($logdir)
  -
  Help::
  -
  Clear:clear -a
  -
}

menu @ASCII {
  To Clip&board
  .$submenu($ASCIIMenu($1))
  -
  &Close:window -c @ASCII
}


menu @SNotice {
  dclick:mB.Admin
  &IRCOp Settings:mB.Admin
  -
  &Log Directory:run $mB.Dir(mBOT\SNotices)
  -
  &Clear Window:clear @SNotice
}

menu @Log {
  Clear:close -@ @Log | DoLog | window -a @Log
}
