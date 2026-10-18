--!strict
export type Kit = {
	id: string,
	speed: number,
	brushRadius: number,
	firstReadyTick: number,
	cooldownTicks: number,
	durationTicks: number,
	previewSeconds: number,
	role: string,
	description: string,
}
-- M1 intentionally exposes only the two kits allowed before its human gate.
local kits: { [string]: Kit } = {
	Drift = {
		id = "Drift",
		speed = 18,
		brushRadius = 4,
		firstReadyTick = 360,
		cooldownTicks = 360,
		durationTicks = 0,
		previewSeconds = 0.4,
		role = "Balanced opener",
		description = "Every 6s, a strong pulse takes nearby cells.",
	},
	Anchor = {
		id = "Anchor",
		speed = 13,
		brushRadius = 4.5,
		firstReadyTick = 360,
		cooldownTicks = 480,
		durationTicks = 120,
		previewSeconds = 0.5,
		role = "Hold your ground",
		description = "Every 8s, widen your brush for 2s. First at 6s.",
	},
}
for _, kit in kits do
	table.freeze(kit)
end
local BallCatalog = { kits = table.freeze(kits), ids = table.freeze({ "Anchor", "Drift" }) }
return table.freeze(BallCatalog)
