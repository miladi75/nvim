-- VHDL Style Guide (vsg) rule-file discovery shared by conform (format) and
-- nvim-lint (diagnostics). The firmware repo keeps its rules in the CI tree,
-- which vsg's own lookup does not know about.
local M = {}

local repo_rule_files = {
    "buildscripts/gitlab_pipeline/lint/vsg_rules.yml",
    "buildscripts/gitlab_pipeline/compile/vsg_rules.yml", -- older branches
    "vsg_config.yaml",
    "vsg_config.yml",
    "vsg_config.json",
    ".vsg_config.yaml",
    ".vsg_config.yml",
}

--- Rule file for a VHDL file in `dir`, or nil to let vsg use its defaults.
---@param dir string directory of the file being checked
---@return string?
function M.config_for(dir)
    local root = vim.fs.root(dir, { ".git" })
    if root then
        for _, rel in ipairs(repo_rule_files) do
            local candidate = vim.fs.joinpath(root, rel)
            if vim.uv.fs_stat(candidate) then
                return candidate
            end
        end
    end
    return vim.fs.find({ "vsg_config.yaml", "vsg_config.yml", "vsg_config.json" }, {
        path = dir,
        upward = true,
    })[1]
end

--- Extra vsg CLI args selecting the rule file, or an empty list.
---@param dir string
---@return string[]
function M.config_args(dir)
    local cfg = M.config_for(dir)
    return cfg and { "-c", cfg } or {}
end

return M
