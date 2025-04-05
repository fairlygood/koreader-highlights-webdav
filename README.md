# KOReader WebDAV Highlights Exporter
This script expands the existing exporter options to allow export of your highlights in markdown format to a WebDAV target.

### Instructions
- Add webdav.lua to your plugins/exporter.plugin/target directory
- Update plugins/exporter.koplugin/main.lua to register the new target
  ```
  local targets = {
    html = require("target/html"),
    joplin = require("target/joplin"),
    json = require("target/json"),
    markdown = require("target/markdown"),
    my_clippings = require("target/my_clippings"),
    nextcloud = require("target/nextcloud"),
    readwise = require("target/readwise"),
    text = require("target/text"),
    xmnote = require("target/xmnote"),
    webdav = require("target/webdav"), <= ADD THIS LINE
  }
  ```
- In your settings menu, click Export Highlights / Choose formats and services / WebDAV (Markdown) / Configure WebDAV and enter your credentials.
- Enable the exporter
