local Provider = require("provider")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

local WebDavImpl = require("webdav")

local WebDAVExporter = WidgetContainer:extend{
    name = "webdav-exporter",
    is_doc_only = false,
}

function WebDAVExporter:init()
    Provider:register("exporter", "webdav", WebDavImpl)
end

return WebDAVExporter
