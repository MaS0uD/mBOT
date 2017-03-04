# mBOT
mIRC Bot

Throw an mirc.exe file into the mBOT's root directory and run it.


// Channel Commands
!Owner|q [Nick]
!Deowner|dq|deq [Nick]
!Protect|Admin|a [Nick]
!Deprotect|Deadmin|dep|da [Nick]
!Op|o [Nick]
!Deop|dop|dp [Nick]
!Hop|h [Nick]
!Dehop|deh|dh [Nick]
!Voice|vo|v [Nick]
!Devoice|dv| [Nick]
!Ban|b [Nick]
!Unban|ub [Nick|Address]
!Mode|m <Modes>
!Kick|k <Nick> [Reason]
!KickBan|kb <Nick> [Reason]
!Topic|t <Topic>
!RemLastBan|UnbanLast|rLastBan|rlb|ubl
!ClearBanList|cbl
!ClearExceptList|cel
!ClearInviteList|cil
!Invite|inv <Nick>


// Special Access
!UnsetAll
!Eval <Code>
!Nick <Nick>
!Join|j <Channel>
!Rejoin|rej
!Part|p [Channel|All]
!Quit [Message]
!SysInfo
!Chan [#Channel] [AV ADV Limit Top Weather IP Ping Seen Pro Daily]
	- AV: Adds Auto Voicer feature to the channel.
	- ADV: Adds Auto Devoicer feature to the channel.
	- Limit: Adds channel Auto Limiter feature to the channel.
	- Top: Enables Top10 and its related commands on the channel.
	- Weather: Enables Weather command for the channel.
	- IP: Enables IP Locator command for the channel.
	- Ping: Enables Ping command for the channel.
	- Seen: Enables Seen and its related command on the channel.
	- Pro: Enables Protection and its related commands for the channel.
		(You can add channel specific profiles in the Protection dialog.
		Otherwise uses the Default Profile. To use its commands you need
		to be on the mBOT's access list.) 
	- Daily: Enables Daily Statistics for the channel.
Usage:
To view current settings of a channel:	!chan [#MyChan]
To modify the attributes:		!chan [#MyChan]Top Weather IP Ping Seen Pro


!Top <merge|bind|del|clearcache|optimize|count|save> [Nick1] [Nick2]
	- Merge: Merges Nick1 with Nick2. In the end Nick2 will be deleted.
		Usage: !top merge ThisNick WithThisNick
	- Bind: Binds Nick1 to Nick2. All the stats for Nick1 will be counted for Nick2, sand taking stats from either nickname is the same.
		Usage: !top bind ThisNick ToThisNick
	- Del: Deletes the specified Nickname from Top Database.
		Usage: !top del Someone
	- ClearCache, CC: Clears the last generated and cached Top. Top updates every 10 minutes.
		Usage: !top clearcache
	- Optimize, opt: Optimizes current channel's Top Database and removes nicknames with no actual stats.
		Usage: !top optimize
	- Count: Returns the total number of entries in Top Database.
		Usage: !top count
	- Save: Saves all Top Databases.
		Usage: !top count

!Quote <add|del|rep|count> [N] [Credits] [Quote]
	- Add: Adds a new Quote.
		Usage: !quote add CreditsGoesToThisGuy Some cheesy quote message here.
	- Del: Deletes a specific item from Quotes. Each Quote has an ID (a number) associated to it.
		Usage: !quote del 1
	- Rep: Replaces Nth Quote with the new message.
		Usage: !quote rep 10 A new or a modified version of the same quote.
	- Count: Returns the total number of quotes in database.
		Usage: !quote count 



// Public (If enabled)
!Slap <Nick>
!ChanStat [Channel]
!IP <Address>
!Peak [Channel]
!Ping [Nick]
!Weather|wth|w <Location>,
!Top <10,20,...,100> [Word|Letter|Line]
!Quote [N]


!mBInfo
---------------

---------------
!Akill <Add|Del> <Address> [Reason]
	- Add: Adds the address to mBOT internal Auto-kill list.
		Usage: !akill add Some!Test@somehost.com You're not welcome!
	- Del: Deletes an item from mBOT's internal Auto-kill list.
		Usage: !akill del *@somehost.com

!Kill <Nick> [Reason]
!Gline <*@Address> [Reason]
!Kline <Nick|Address> [Reason]
---------------
Whitelist:
To add: !Members wadd <Mask> <Network|*> <Channel|*> <Aop|Hop|Vop> [(NoBan)0-1] [Greet Message]
To remove: !Members wdel <Mask>

Blacklist:
To add: !Members badd <Mask> <Network|*> <Channel|*> <Ban|Kick|KickBan> [(Type)0-19] [Reason]
To remove: !Members bdel <Mask>
---------------

This list is incomplete. More details and commands will be added later.
