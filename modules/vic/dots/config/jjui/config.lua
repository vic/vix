local dynamic_theme = require("plugins.dymanic_theme")

function first_hunk_new_lineno(git_diff)
	for line in git_diff:gmatch("[^\n]+") do
		if line:sub(1, 3) == "@@ " then
			local new_start = line:match("%+(%d+)")
			if new_start then
				return tonumber(new_start)
			end
		end
	end
	return nil
end

function edit_from_details()
	local diff = jj("diff", "--git", "-r", context.change_id(), context.file())
	local line_number = first_hunk_new_lineno(diff)
	exec_shell(string.format("nvim +%q %q", line_number, context.file()))
end

function diffpipe(tool)
	return function()
		local change_id = context.change_id()
		if not change_id or change_id == "" then
			flash({ text = "No revision selected", error = true })
			return
		end
		exec_shell(string.format("jj diff -r %q --git --color always | " .. tool, change_id))
	end
end

function diff_details_file(tool)
	return function()
		local change_id = context.change_id()
		if not change_id or change_id == "" then
			flash({ text = "No revision selected", error = true })
			return
		end
		local path = context.file()
		if not path or path == "" then
			flash({ text = "No path selected", error = true })
			return
		end
		exec_shell(string.format("jj diff -r %q %q --git --color always | " .. tool, change_id, path))
	end
end

function expand_revset()
	local change_id = revisions.current()
	if not change_id then
		return
	end

	local current = revset.current()
	local bumped = false
	local updated = current:gsub("ancestors%(" .. change_id .. "%s*,%s*(%d+)%)", function(n)
		bumped = true
		return "ancestors(" .. change_id .. ", " .. (tonumber(n) + 1) .. ")"
	end, 1)

	if not bumped then
		updated = current .. " | ancestors(" .. change_id .. ", 2)"
	end

	revset.set(updated)
end

-- ~/.config/jjui/config.lua
function setup(config)
	-- dynamic_theme.setup("#663399", config)
	config.ui = config.ui or {}
	config.ui.theme = { "base64-wombat" }

	config.action(
		"show diff in diffnav",
		diffpipe("diffnav"),
		{ desc = "diffnav diff", key = "=", scope = "revisions" }
	)

	config.action(
		"show diff in delta",
		diffpipe("delta --paging always"),
		{ desc = "delta diff", key = "d", scope = "revisions" }
	)

	config.action("edit file", edit_from_details, { desc = "edit file", scope = "revisions.details", key = "e" })

	config.action(
		"diff file",
		diff_details_file("delta --paging always"),
		{ desc = "diff file", scope = "revisions.details", key = "d" }
	)

	config.action("expand revset", expand_revset, { desc = "expand revset", scope = "revisions", key = "]" })
end
