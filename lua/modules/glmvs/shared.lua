module( "GLMVS", package.seeall )

-- Shared Global Vars
Maplist			= {}
Maplib			= {}
MapIncludes		= {}
Gamemodes		= {}

-- Shared Setting Vars
GLVersion		= "1.0.2.1"
CurrentMap		= string.lower( game.GetMap() )

NotifyUsergroup	= {
	["serverowner"] = true, ["owner"] = true, ["serveradmin"] = true, ["superadmin"] = true,
	["admin"] = true, ["tadmin"] = true, ["trialadmin"] = true, ["manager"] = true,
	["mod"] = true, ["moderator"] = true, ["trialmod"] = true, ["tmod"] = true,
	["donator"] = true, ["donators"] = true, ["respected"] = true, ["user"] = false,
}

--[[---------------------------------------------------------
Name: AddMap( map (string), plnum (int) )
Desc: Adds a map shared-like for both client and server.
-----------------------------------------------------------]]
function AddMap( map, plnum )
	local CurGamemode = GetGamemode()
	local MapName = string.lower( map )
	local MapLibrary = Maplib[ MapName ] || {}

	-- Do some checks and shit.
	if MapIncludes[ MapName ] then
		GDebug.NotifyByConsole( 2, MapName, " is already added! Not included." )
		return
	elseif CurGamemode && !AllowNonGMRelatedMaps && !table.HasValue( CurGamemode.MapPrefix, string.Explode( "_", MapName )[1] ) then
		GDebug.NotifyByConsole( 2, MapName, " isn't part of this gamemode. Not listed." )
		return
	end

	-- Now add the map SHARED-ey
	if SERVER then
		table.insert( Maplist, {
			Map = string.lower( MapName ), Votes = 0,
			Name = MapLibrary.Name || nil,
			MinPlayers = plnum, Locked = 0, Removed = 0
		} )
	end

	if CLIENT then
		table.insert( Maplist, {
			Map = string.lower( MapName ), Votes = 0, TotalVotes = 0, NextVote = 0,
			Name = MapLibrary.Name || nil, Author = MapLibrary.Author || nil, Description = MapLibrary.Description || nil, MinPlayers = plnum,
			Image = Material( util.IsValidImage( MapName ), "nocull" ), Locked = 0, Removed = 0
		} )
	end

	MapIncludes[ map ] = true
end

--[[---------------------------------------------------------
Name: AddToLibrary( map (string), { realname (string), author (string), description (string) } (table) )
Desc: Adds a map to the library.
-----------------------------------------------------------]]
function AddToLibrary( mlib, infolib )
	if !istable(infolib) then GDebug.NotifyByConsole( 3, mlib, " doesn't have it as a table entry! Remove from the library!" ) return end
	if !infolib[1] then GDebug.NotifyByConsole( 3, mlib, " doesn't have a name entry in the table! Remove from the library!" ) return end

	if SERVER then
		Maplib[ mlib ] = {
			Name = infolib[1]
		}
	end

	if CLIENT then
		Maplib[ mlib ] = {
			Name = infolib[1],
			Author = infolib[2] || nil,
			Description = infolib[3] || nil,
		}
	end
end

--[[---------------------------------------------------------
Name: SortMaps( a (table), b (table) )
Desc: Sorts the maps within a specified order.
Returns: shouldSort (bool)
-----------------------------------------------------------]]
function SortMaps(a, b)
	if ( !a || !b ) then return false end

	local aname = string.lower( a.Name || a.Map )
	local bname = string.lower( b.Name || b.Map )

	if ( a.Removed ~= b.Removed ) then
		return a.Removed < b.Removed
	end

	if ( a.Locked ~= b.Locked ) then
		return a.Locked < b.Locked
	end

	return aname < bname
end

--[[---------------------------------------------------------
Name: GetGamemode
Desc: Finds the current gamemode within the specified order.
Returns: GMData (table)
-----------------------------------------------------------]]
function GetGamemode()
	local gameconvar = string.lower( GetConVar("gamemode"):GetString() )

	-- Checking if GAMEMODE has it.
	if ( GAMEMODE && GAMEMODE.Name && Gamemodes[ GAMEMODE.Name ] ) then
		return Gamemodes[ GAMEMODE.Name ]
	end

	-- Maybe it was loaded in GM?
	if ( GM && GM.Name && Gamemodes[ GM.Name ] ) then
		return Gamemodes[ GM.Name ]
	end

	-- Check if the convar has the gamemode...
	if ( gameconvar && Gamemodes[ gameconvar ] ) then
		return Gamemodes[ gameconvar ]
	end

	return nil
end