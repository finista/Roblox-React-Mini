--!strict
local util = {}

function util.deepEqual(table1: any?, table2: any?)
	if table1 == table2 then
		return true
	end

	if type(table1) ~= "table" or type(table2) ~= "table" then
		return false
	end

	for key, value in pairs(table1) do
		if not util.deepEqual(value, table2[key]) then
			return false
		end
	end

	for key, value in pairs(table2) do
		if not table1[key] then
			return false
		end
	end

	return true
end


return util
