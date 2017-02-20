; ******************************************************
;           DC mBOT - IP Locator
; ******************************************************
alias Locate {
  if ($0 == 4) && (!$sock(Locator)) {
    if ($sock(Locator)) { sockclose Locator }
    if ($hget(Locator)) { hfree Locator }
    HashTable Locator Network $1
    HashTable Locator Channel $2
    HashTable Locator Nick $3
    if ($remove($4,$chr(46)) isnum) { Locator.Open $4 | HashTable Locator IP $4 }
    else { HashTable Locator Address $4 | .dns $4 }
  }
}

alias Locator.Open {
  if ($1 != $null) {
    if ($sock(Locator)) { sockclose Locator }
    if ($remove($1,$chr(46)) !isnum) { .dns $1 }
    sockopen Locator melissadata.com 80
    sockmark Locator $1
  }
}

alias -l Locator.GetValue { return $iif($hget(Locator,$1) != $null,$ToPascal($v1),-) }
alias Locator.Msg {
  var %x = 01[IP Locator] Results for '<IP>':02 Country:03 <Country> 04||02 City:03 <City> 04||02 State/Region:03 <State> 04||02 ISP:03 <ISP> 04||02 Domain:03 <Domain> 04||02 DNS resolved to:03 <MAddress>
  return $iif($mB.Read(Extra,Msgs,IP) != $null,$v1,%x)
}

alias Locator.Close {
  if ($sock(Locator)) { sockclose Locator }
  var %chan = $Locator.GetValue(Channel),%network = $Locator.GetValue(Network),%nick = $Locator.GetValue(Nick)
  if ($Locator.GetValue(Error) != $null) && ($Locator.GetValue(Error) != -) {
    MultiServMsg %network $iif($mB.Read(Extra,Msgs,IPM) == 1,notice %nick,msg %chan) $Locator.GetValue(Error)
    return
  }
  var %ip = $Locator.GetValue(IP),%city = $Locator.GetValue(City),%country = $Locator.GetValue(Country),%state = $Locator.GetValue(State),%dns = $Locator.GetValue(DNS),%domain = $Locator.GetValue(Domain),%isp = $Locator.GetValue(ISP)
  var %msg = $replace($Locator.Msg,<IP>,%ip,<Country>,%country,<City>,%city,<State>,%state,<MAddress>,%dns,<Domain>,%domain,<ISP>,%isp)
  MultiServMsg %network $iif($mB.Read(Extra,Msgs,IPM) == 1,notice %nick,msg %chan) %msg
  if ($hget(Locator)) { hfree Locator }
}

on *:SockOpen:Locator:{
  if ($sockerr > 0) {
    HashTable Locator Error [IP Locator] Could not open a socket, please try later.
    Locator.Close
    return
  }
  var %w = sockwrite -n $sockname
  %w GET /lookups/iplocation.asp HTTP/1.1
  %w User-Agent: Mozilla/5.0 (Windows NT 6.1; rv:33.0) Gecko/20100101 Firefox/33.0
  %w Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
  %w Accept-Language: en-US,en;q=0.5
  %w DNT: 1
  %w Referer: http://www.melissadata.com/lookups/iplocation.asp
  %w Cookie: u=n=&e=&l=U&s=&a=&v=E&x=&ipc=1&i=&p=NO&d=11%2F29%2F2014&r=NO; ASPSESSIONIDCARSCBDC=JEODGBOACAPDIIGCMPBMBECL; ASPSESSIONIDAASTBBDD=LGDBLIOADNFNHJNGMCPFDFJN; ASPSESSIONIDAQSQBDAD=EICFGONACJDPEBGACHNNBDJM; ASPSESSIONIDCQSQACAD=KNGEGOLAFKLDLMMPLDAOAMBE  
  %w Content-Length: $len($+(ipaddress=,$sock($sockname).mark))
  %w Connection: Close
  %w Content-Type: application/x-www-form-urlencoded
  %w Host: $+(www.melissadata.com,$str($crlf,2))
  %w $+(ipaddress=,$sock($sockname).mark)
}

on *:SockRead:Locator:{
  if ($sockerr > 0) {
    HashTable Locator Error [IP Locator] Socket read error, please try later.
    Locator.Close
    return
  }
  var %q
  sockread %q
  tokenize 32 $StripHTML(%q)
  if (*is not valid* iswm $1-) { HashTable Locator Error [IP Locator] Syntax is not valid! Syntax: $+($Trigger,ip) 127.0.0.1 | return }
  if (*Not*Found* iswm $1-) { HashTable Locator Error [IP Locator] No match were found. | Locator.Close | return }
  else {
    if (*Location of IP Address *.*.*.* iswm $1-) { HashTable Locator IP $5 }
    if (*City* iswm $1-) && (*Protocol* !iswm $1-) { HashTable Locator City $right($remove($1-,$chr(9)),-5) }
    if (*State or Region* iswm $1-) && (*Protocol* !iswm $1-) { HashTable Locator State $remove($1-,State or Region,$chr(9)) }
    if (*Country* iswm $1-) && (*Protocol* !iswm $1-) { HashTable Locator Country $remove($1-,Country,$chr(9)) }
    if (*ISP* iswm $1-) && (*(ISP)* !iswm $1-) && (*Protocol* !iswm $1-) && ($left($1-,2) == $+($chr(9),$chr(9))) { HashTable Locator ISP $remove($1-,ISP,$chr(9)) }
    if (*Domain* iswmcs $1-) && (*Identify the ISP and Domain Name* !iswm $1-) && (*Hosting Internet Service Provider* !iswm $1-) {
      HashTable Locator Domain $ToPascal($remove($1-,Domain,$chr(9)))
    }
  }
}

on *:SockClose:Locator:{
  if ($hget(Locator)) { Locator.Close }
}

on *:DNS: { 
  if ($hget(Locator)) && ($raddress != $null) {
    if ($hget(Locator,Address) == $naddress) && ($eval($+(%,Tmp.,$naddress),2) == $null) {
      set -u5 $+(%,Tmp.,$naddress) 1
      Locator.Open $raddress
    }
    HashTable Locator DNS $iif($raddress,$v1,Unable to resolve)
  }
  elseif ($raddress == $null) && ($hget(Locator,Address) != $null) {
    HashTable Locator Error [IP Locator] Unable to resovle.
    Locator.Close
  }
  halt
}
