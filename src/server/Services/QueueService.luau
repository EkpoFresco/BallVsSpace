--!strict
export type Entry = { userId: number, joined: number, practice: boolean }
local Queue = {}
local entries: { Entry } = {}
function Queue.join(userId: number, now: number, practice: boolean): boolean
	for _, e in entries do
		if e.userId == userId then
			return false
		end
	end
	table.insert(entries, { userId = userId, joined = now, practice = practice })
	return true
end
function Queue.cancel(userId: number)
	for i = #entries, 1, -1 do
		if entries[i].userId == userId then
			table.remove(entries, i)
		end
	end
end
function Queue.position(userId: number): number?
	for i, e in entries do
		if e.userId == userId then
			return i
		end
	end
	return nil
end
function Queue.take(): { Entry }?
	if #entries == 0 then
		return nil
	end
	for i, e in entries do
		if e.practice then
			table.remove(entries, i)
			return { e }
		end
	end
	if #entries < 2 then
		return nil
	end
	local a, b = table.remove(entries, 1), table.remove(entries, 1)
	assert(a and b, "Reserved queue entries missing")
	return { a, b }
end
function Queue.returnEntry(entry: Entry)
	Queue.cancel(entry.userId)
	table.insert(entries, entry)
	table.sort(entries, function(a, b)
		return a.joined < b.joined
	end)
end
return table.freeze(Queue)
