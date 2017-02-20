; ******************************************************
;           DC mBOT - Popup Menus
; ******************************************************
menu Menubar {
  -
  Main Settings $+ $chr(9) $+ F1:mBOT
  -
  Protections $+ $chr(9) $+ F2:mB.Pro
  -
  Members $+ $chr(9) $+ F3:MemberMgr
  -
  Extra Settings $+ $chr(9) $+ F4:mB.Extra
  -
  Seen System $+ $chr(9) $+ F5:xSeen
  -
  IRCOp Settings $+ $chr(9) $+ F6:mB.Admin
  -
  Connection Manager $+ $chr(9) $+ F7:ConMgr
  -
  Help $+ $chr(9) $+ F11:Start_Help
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
  .Main Settings:mBOT
  .-
  .Protections:mB.Pro
  .-
  .Extra:mB.Extra
  .-
  .Members:MemberMgr
  .-
  .Channel Manager:mB.CManager
  .-
  .Seen System:xSeen
  .-
  .IRCOp Settings:mB.Admin
  .-
  .Connection Manager:ConMgr
  .-
  Directories
  .Script Dir:.run $qt($mircdir)
  .-
  .Logs Dir:.run $qt($logdir)
  -
  Help::
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
