--!strict
-- M1 fake adapter only. Never accesses DataStore or claims a durable save.
export type Profile = {
	userId: number,
	activeMatchId: string?,
	applied: { [string]: boolean },
	matches: number,
}
local profiles: { [number]: Profile } = {}
local Profiles = {}
function Profiles.load(userId: number): Profile
	local existing = profiles[userId]
	if existing then
		return existing
	end
	local profile: Profile = { userId = userId, activeMatchId = nil, applied = {}, matches = 0 }
	profiles[userId] = profile
	return profile
end
function Profiles.prepare(userId: number, matchId: string): boolean
	local p = Profiles.load(userId)
	if p.activeMatchId ~= nil then
		return false
	end
	p.activeMatchId = matchId
	return true
end
function Profiles.complete(userId: number, matchId: string)
	local p = Profiles.load(userId)
	if p.applied[matchId] then
		return
	end
	if p.activeMatchId ~= matchId then
		return
	end
	p.applied[matchId] = true
	p.matches += 1
	p.activeMatchId = nil
end
function Profiles.release(userId: number)
	profiles[userId] = nil
end
return table.freeze(Profiles)
