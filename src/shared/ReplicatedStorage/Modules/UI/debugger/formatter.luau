-- todo
local formatter = {}
function formatter:tableToString(tbl: { [any]: any }, indent: string | nil)
	local str = "{\n"
	indent = indent or "  "

	for k, v in pairs(tbl) do
		local key = tostring(k)
		local value = "FAIL"

		if type(v) == "table" then
			value = self:tableToString(v, indent .. "  ")
		elseif type(v) == "userdata" and typeof(v) == "Instance" then
			value = v:GetFullName() or tostring(v)
		else
			value = tostring(v)
		end

		str = `{str}{indent}{key}: {value}\n`
	end

	return `{str}{string.sub(indent, 3)}}`
end

return formatter
