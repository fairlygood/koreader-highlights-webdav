local http = require("socket.http")
local ltn12 = require("ltn12")
local mime = require("mime")
local util = require("util")

local WebDAVExporter = require("base"):new {
    name = "webdav",
    label = "WebDAV (Markdown)",
    extension = "md",
    mime = "text/markdown",
    is_remote = true,
}

function WebDAVExporter:export(booknotes)
    if not self:isEnabled() then return false end

    local md = require("template/md")
    local plugin_settings = G_reader_settings:readSetting("exporter") or {}
    local markdown_settings = plugin_settings.markdown or {}

    local lines = {}

    for _, book in ipairs(booknotes) do
        local note_tbl = md.prepareBookContent(book, markdown_settings.formatting_options, markdown_settings.highlight_formatting)
        if note_tbl and #note_tbl > 0 then
            table.insert(lines, table.concat(note_tbl, "\n"))
            table.insert(lines, "") -- blank line between books
        end
    end

    if #lines == 0 then
        return false, "No highlights to export"
    end

    local markdown = table.concat(lines, "\n")
    local filename = os.date("export-%Y%m%d-%H%M%S.md")
    local url = self.settings.url or ""
    if url == "" then
        return false, "WebDAV URL not configured"
    end
    if url:sub(-1) ~= "/" then url = url .. "/" end
    url = url .. require("util").getSafeFilename(filename)

    local mime = require("mime")
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    local response_body = {}

    local res, code, headers, status = http.request{
        url = url,
        method = "PUT",
        source = ltn12.source.string(markdown),
        headers = {
            ["Content-Type"] = "text/markdown",
            ["Content-Length"] = tostring(#markdown),
            ["Authorization"] = "Basic " .. mime.b64((self.settings.username or "") .. ":" .. (self.settings.password or ""))
        },
        sink = ltn12.sink.table(response_body)
    }

    if code == 200 or code == 201 then
        return true, "Exported to WebDAV: " .. filename
    else
        return false, "WebDAV export failed: " .. (status or code)
    end
end


function WebDAVExporter:getMenuTable()
    return {
        text = "WebDAV (Markdown)",
        checked_func = function() return self:isEnabled() end,
        sub_item_table = {
            {
                text = "Configure WebDAV",
                callback = function()
                    self:showSettingsDialog()
                end
            },
            {
                text = "Enable Exporter",
                checked_func = function() return self:isEnabled() end,
                callback = function() self:toggleEnabled() end,
            }
        }
    }
end

function WebDAVExporter:showSettingsDialog()
    local MultiInputDialog = require("ui/widget/multiinputdialog")
    local UIManager = require("ui/uimanager")

    local dialog_title = "Configure WebDAV Exporter"
    local dialog
    dialog = MultiInputDialog:new {
        title = dialog_title,
        fields = {
            {
                description = "WebDAV URL",
                hint = "https://yourserver.com/remote.php/webdav/",
                text = self.settings.url or "",
                input_type = "string"
            },
            {
                description = "Username",
                hint = "Your WebDAV username",
                text = self.settings.username or "",
                input_type = "string"
            },
            {
                description = "Password",
                hint = "Your WebDAV password",
                text = self.settings.password or "",
                input_type = "string"
            }
        },
        buttons = {
            {
                {
                    text = "Cancel",
                    callback = function()
                        UIManager:close(dialog)
                    end
                },
                {
                    text = "Save",
                    callback = function()
                        local fields = dialog:getFields()
                        self.settings.url = fields[1]
                        self.settings.username = fields[2]
                        self.settings.password = fields[3]
                        self:saveSettings()
                        UIManager:close(dialog)
                    end
                }
            }
        }
    }

    UIManager:show(dialog)
    dialog:onShowKeyboard()
end



return WebDAVExporter
