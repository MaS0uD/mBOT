; ******************************************************
; About DC mBOT and Check for update
; ******************************************************
alias mB.About { mDialog mB.About }
alias mBUpdate { mDialog mBUpdate }
dialog mB.About {
  title "About DC mBOT"
  size -1 -1 236 249
  option dbu
  icon $mB.Imgs(MB.ico)
  list 1, -6 -1 253 30, disable size
  list 2, 4 4 25 25, disable size
  text "About DC mBOT", 3, 29 3 216 15
  text "Let's know the Author and some information about this script...", 4, 30 17 215 10
  tab "General", 5, 3 31 230 202
  box "What is DC mBOT?", 6, 8 49 220 30, tab 5
  text "-    It's an Internet Relay Chat (IRC) Bot Script which works under mIRC product (Written by Khaled Mardam-Bey) and its powerful Scripting Language (mSL).", 7, 14 59 207 15, tab 5
  box "About", 8, 8 80 220 57, tab 5
  text "Author:", 9, 11 90 45 8, tab 5 right
  text "", 10, 59 90 80 8, tab 5
  text "Version:", 11, 11 101 45 8, tab 5 right
  text "", 12, 59 101 80 8, tab 5
  text "Published At:", 13, 11 112 45 8, tab 5 right
  text "", 14, 59 112 80 8, tab 5
  text "Initial Release:", 15, 11 123 45 8, tab 5 right
  text "", 16, 59 123 80 8, tab 5
  icon 17, 179 88 42 42,  $mB.Imgs(DC_.png), 0, tab 5
  box "Contacts", 18, 8 138 220 65, tab 5
  text "-    You can contact me via E-mail or visit me at mentioned IRC Networks below. Also you can visit my Website.", 19, 14 148 207 16, tab 5
  text "Website:", 20, 11 168 45 8, tab 5 right
  link "Http://DeadCeLL.eu5.org/", 21, 59 168 85 8, tab 5
  text "Facebook:", 22, 11 179 45 8, tab 5 right
  link "Https://Facebook.com/DCmBOT", 23, 59 179 85 8, tab 5
  text "IRC Networks:", 24, 11 190 45 8, tab 5 right
  link "DAL.net", 25, 59 190 27 8, tab 5
  link "Freenode.net", 26, 90 190 40 8, tab 5
  link "Bedehi.com", 27, 135 190 34 8, tab 5
  box "Update", 28, 8 204 220 24, tab 5
  text "-    Looking for updates?", 29, 14 214 60 8, tab 5
  link "Click here", 30, 77 214 30 8, tab 5
  tab "Credits", 31
  box "Notes", 32, 8 49 220 98, tab 31
  text "-    Please read the 'Help files' before contacting me.", 33, 14 60 206 16, tab 31
  text "-    If you've found any kind of Bugs and/or Errors in DC mBOT; Please contact me via my E-mail or any other ways which I've mentioned for you. If you're using this script and you like it or even you don't; Please let me know what is/was your opinion about it. All suggestions are welcome...", 34, 14 80 206 30, tab 31
  text "-    If you want to be a Beta tester of this script just send me an E-mail and then we can talk about it.", 35, 14 114 206 16, tab 31
  text "-    Thank you for choosing DC mBOT. :)", 36, 14 133 206 8, tab 31
  box "Credits", 37, 8 148 220 80, tab 31
  text "-    Other people... (Accept my apology if I've forgotten anyone.)", 38, 14 158 206 24, tab 31
  text "Choose &one:", 39, 10 187 36 8, tab 31 right
  combo 40, 48 186 85 50, tab 31 size drop
  text "", 41, 48 198 173 26, tab 31
  button "&Help Centre", 42, 3 235 50 12
  button "&Continue...", 43, 183 235 50 12, cancel
}

on *:dialog:mB.About:*:*:{
  if ($devent == close) { unset %DC.Clicked }
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
    did -i $dname 2 1 setimage icon normal $noqt($mB.Imgs(About.ico))
    did -a $dname 2 +a 1 $chr(9) $+ About DC mBOT
    did -b $dname 1,2
    did -ra $dname 3 About DC mBOT $mB.Ver
    did -ra $dname 10 $mB.Author
    did -ra $dname 12 $right($mB.Ver,-1)
    did -ra $dname 14 $mB.Release
    did -ra $dname 16 $mB.InitialRelease
    didtok $dname 40 44 DragonZap,xDaeMoN,}|-|yRoN{,Suchorski,YOU!
    did -c $dname 40 1
    did -ra $dname 41 $DC.Credits(1)
    unset %DC.Clicked
  }
  if ($devent == sclick) {
    if ($did == 17) {
      if (%DC.Clicked) { did -g $dname 17 $mB.Imgs(DC_.png) | unset %DC.Clicked }
      else { did -g $dname 17 $mB.Imgs(DC.png) | set %DC.Clicked . }
    }
    if ($istok(21 23, $did,32)) { .run $did($did).text }
    if ($istok(25 26 27,$did,32)) {
      var %servs = IRC.DAL.net IRC.Freenode.net IRC.Bedehi.com
      var %chans = #HelpDesk ##mIRC #mIRC
      !server $iif($scid($activecid).status != Disconnected,-m) $+($gettok(%servs,$calc($did - 24),32),:,6667) -j $gettok(%chans, $calc($did - 24),32)
    }
    if ($did == 30) { .run http://DeadCeLL.eu5.org/?p=mbot }
    if ($did == 40) && ($did(40).sel) { did -ra $dname 41 $DC.Credits($did(40).sel) }
    if ($did == 42) {  }
  }
}

alias -l DC.Credits {
  if ($1 isnum 1-) {
    goto $1
    :1 | return For MDX.DLL
    :2 | return For xSeen v3.9
    :3 | return For hOS.dll
    :4 | return For ProcessBar window.
    :5 | return Here we are, Thank you my dear users for downloading and/or using and/or supporting DC mBOT :)
  }
}
