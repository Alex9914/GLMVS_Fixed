module( "GDebug", package.seeall )

--[[---------------------------------------------------------
Name: CheckForUpdates
Desc: Checks for an update.
-----------------------------------------------------------]]
function CheckForUpdates()
	if game.SinglePlayer() then return end

	http.Fetch( "http://raw.github.com/Alex9914/GLMVS_Fixed/master/lua/modules/glmvs/shared.lua",
	function( str )
		if not str then return end

		local vstart, vend = string.find( str, "GLVersion" ), string.find( str, "CurrentMap" )
		local cversion = GLMVS.GLVersion
		local lversion = string.gsub( string.sub( str, vstart, vend - 2 ), "[^0-9$.]", "" )

		NotifyByConsole( 1, "Current Version: ", cversion, " -- Latest Version: ", lversion )

		cversion = string.Explode( ".", GLMVS.GLVersion, false )
		lversion = string.Explode( ".", lversion, false )

		GLMVS.UpToDate = CompareTwoVerVals( lversion, cversion )
	end,
	function()
		NotifyByConsole( 3, "Failed to retrieve current version." )
	end )
end

--[[---------------------------------------------------------
Name: CompareTwoVerVals( latest (string), current (string) )
Desc: Compares two string to table versions (based on this format: 1.0.0.1) within the latest and current.
Returns: isUpToDate (boolean)
-----------------------------------------------------------]]
function CompareTwoVerVals( latest, current )
	local toloop = #latest > #current and latest or current

	for vpos, _ in ipairs( toloop ) do
		local lver, cver = tonumber( latest[ vpos ] ) or 0, tonumber( current[ vpos ] ) or 0

		if ( lver > cver ) and ( lver ~= cver )  then
			NotifyByConsole( 3, "GLMVS is out of date." )
			return false
		elseif ( lver < cver ) and ( lver ~= cver ) then
			NotifyByConsole( 1, "GLMVS is up to date." )
			return true
		end
	end

	NotifyByConsole( 1, "GLMVS is up to date." )
	return true
end

--[[---------------------------------------------------------
Name: PrintMapTable
Desc: Debugging
-----------------------------------------------------------]]
function PrintMapTable( pl )
	if not pl:IsPlayer() then return end
	if not Contributors[ pl:UniqueID() ] then return end

	PrintTable( GLMVS.MapList )
end
CMD.AddConCmd( "glmvs_printmaps", PrintMapTable )