alias GetWeather {
  if ($sock(Weather)) { sockclose Weather }
  HashTable Weather Network $1
  HashTable Weather Channel $2
  sockopen Weather weather.service.msn.com 80
  sockmark Weather $3-
  .timer 1 2 Weather.Close
}

;; http://www.msn.com/en-us/weather/?q=Tehran

alias Weather.Close {
  var %x = 1,%msg = $Weather.Msg
  ;var %x = 1,%msg = $iif($mB.Read(Extra,Msgs,Weather) != $null,$v1,$Weather.Msg)
  while ($hget(Weather,%x).item != $null) {
    var %m = $v1
    if (%m == Error) { %msg = $hget(Weather,Error) | break }
    else { %msg = $replace(%msg,$+(<,%m,>),$hget(Weather,%m)) }
    inc %x
  }
  if (%msg) {
    var %c = $hget(Weather,TempC),%color = $iif(%c <= 15,02,$iif(%c isnum 16-29,03,$iif(%c isnum 30-39,07,$iif(%c isnum 40-,04))))
    %msg = $replace(%msg,,$+($chr(3),%color),</c>,$chr(3))
    MultiServMsg $hget(Weather,Network) msg $hget(Weather,Channel) $iif(<Condition> isin %msg,[Weather]: Could not get any responses from MSN Weather Service.,$v2)
  }
  if ($hget(Weather)) { hfree Weather }
}

alias -l ToFahrenheit { return $round($calc(($1 * 9/5) + 32),0) }
alias -l KPH { return $replace($regsubex($1-,/([\d]+)/,$round($calc(\t * 1.609344),0)),mph,KPH)  }
alias -l ForcC { return $round($calc((5 / 9) * ($1 - 32)),0) }
alias Weather.Msg { return [Weather] <Location>: Condition <Condition> @ <TempC>°C/<TempF>°F</c> (Feels like: <FeelsLikeC>°C/<FeelsLikeF>°F</c>) with <Humidity>% humidity. [Wind: <Wind>] (Update time: <LastUpdate> - Observation Point: <ObservationPoint>) }

on *:SockOpen:Weather:{
  if ($sockerr) {
    HashTable Weather Error [Weather]: Could not open a socket, please try later.
    Weather.Close
    return
  }
  sockwrite -nt $sockname GET $+(/data.aspx?weadegreetype=C&culture=en-US&weasearchstr=,$URLEncode($sock($sockname).mark)) HTTP/1.1
  sockwrite -n $sockname Host: $sock($sockname).addr
  sockwrite -n $sockname $str($crlf,2)
}

on *:SockRead:Weather:{
  if ($sockerr) {
    HashTable Weather Error [Weather]: Socket read error, please try later.
    Weather.Close
    return
  }
  sockread %header
  while (%header != $null) { sockread %header }

  while ($sockbr) {
    if ($regex(%data,/<weatherdata\/>/i)) {
      HashTable Weather Error [Weather]: No match were found.
      Weather.Close
      return
    }
    var %data
    sockread -f %data
    if ($regex(%data,/<weather/i)) {
      if ($regex(%data,/weatherlocationname="(.*?)"/i)) { HashTable Weather Location $regml(1) }
    }
    if ($regex(%data,/<current/i)) {
      if ($regex(%data,/humidity="(.*?)"/i)) { HashTable Weather Humidity $regml(1) }
      if ($regex(%data,/winddisplay="(.*?)"/i)) { HashTable Weather Wind $upper($regml(1)) }
      if ($regex(%data,/skytext="(.*?)"/gi)) { HashTable Weather Condition $regml(1) }
      if ($regex(%data,/temperature="(.*?)"/i)) { HashTable Weather TempC $regml(1) | HashTable Weather TempF $ToFahrenheit($regml(1)) }
      if ($regex(%data,/feelslike="(.*?)"/i)) { HashTable Weather FeelsLikeC $regml(1) | HashTable Weather FeelsLikeF $ToFahrenheit($regml(1)) }
      if ($regex(%data,/observationtime="(.*?)"/i)) { HashTable Weather LastUpdate $regml(1) }
      if ($regex(%data,/observationpoint="(.*?)"/i)) { HashTable Weather ObservationPoint $regml(1) }
      sockclose $sockname
    }
  }
}

on *:SockClose:Weather:{
  if ($hget(Weather)) { Weather.Close }
}
