--[[
    Userpatch: Project Title-style dual footer
    File: koreader/patches/2-browser-footer.lua

    Adds a PT-style footer to all KOReader list menus (FileManager, History,
    Collections, FileSearcher, reader menus like TOC and bookmarks).

    Layout:
      Left  → current folder name (or context name for History/Collections)
      Right → page controls condensed to "X / Y"

    Works independently of the Project Title plugin. If PT is active,
    this patch does nothing (PT already handles this via Menu.init).

    Place this file in:  koreader/patches/2-browser-footer.lua
--]]
-- ============================================================
-- Guard: skip if Project Title is active (it handles its own footer)
-- ============================================================
do
    local lfs = require("libs/libkoreader-lfs")
    if lfs.attributes("plugins/coverbrowser.koplugin/ptutil.lua", "mode") == "file" then
        return
    end
end

-- ============================================================
-- Dependencies
-- ============================================================
local Blitbuffer = require("ffi/blitbuffer")
local BottomContainer = require("ui/widget/container/bottomcontainer")
local Device = require("device")
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local LeftContainer = require("ui/widget/container/leftcontainer")
local Menu = require("ui/widget/menu")
local OverlapGroup = require("ui/widget/overlapgroup")
local RightContainer = require("ui/widget/container/rightcontainer")
local TextWidget = require("ui/widget/textwidget")
local Screen = Device.screen
local gettext = require("gettext")

-- ============================================================
-- LOCALIZATION
-- ============================================================

local PATCH_L10N = {
    en = {
        ["Home"] = "Home",
    },
    pt = {
        ["Home"] = "Início",
    }
}

local function l10nLookup(msg)
    local lang = "en"
    if G_reader_settings and G_reader_settings.readSetting then
        lang = G_reader_settings:readSetting("language") or "en"
    end
    local lang_base = lang:match("^([a-z]+)") or lang
    local map = PATCH_L10N[lang] or PATCH_L10N[lang_base] or PATCH_L10N.en or {}
    return map[msg]
end

local function _(msg)
    local custom = l10nLookup(msg)
    if custom then return custom end
    return gettext(msg)
end

-- ============================================================
-- Font: use Source Sans if available (left by PT install),
-- otherwise fall back to a native KOReader sans-serif font.
-- ============================================================
local function sourceFont(relpath)
    local lfs = require("libs/libkoreader-lfs")
    local DataStorage = require("datastorage")
    local full = DataStorage:getDataDir() .. "/fonts/" .. relpath
    return lfs.attributes(full, "mode") == "file" and relpath or nil
end
local FOOTER_FONT_FACE = sourceFont("source/SourceSans3-Regular.ttf") or "Noto Sans"
local FOOTER_FONT_SIZE = 20

-- ============================================================
-- Save original Menu methods
-- ============================================================
local _Menu_init_orig = Menu.init
local _Menu_updatePageInfo_orig = Menu.updatePageInfo

-- ============================================================
-- Helper: should this menu instance get the PT footer?
-- We want file-browser style menus, not small popup menus.
-- A reliable signal: menus with no_title==false and is_borderless==true
-- (FileChooser sets both), OR menus that are history/collections booklists.
-- We conservatively skip menus that have a non-empty title (PathChooser,
-- reader TOC, etc.) — they already have context in the title bar.
-- ============================================================
local function wantsPTFooter(self)
    -- Must have been fully initialised with a page_info group
    if not self.page_info then
        return false
    end
    -- Must have inner_dimen
    if not self.inner_dimen then
        return false
    end
    -- Skip tiny popup menus (they don't have content_group)
    if not self.content_group then
        return false
    end
    return true
end

-- ============================================================
-- Helper: derive the display text for the left side of the footer
-- ============================================================
local function getFooterLeftText(self)
    if self._manager and type(self._manager.name) == "string" then
        return ""
    end

    local path = self.path
    if type(path) ~= "string" or path == "" then
        return ""
    end

    -- Show "Home" when at the configured home directory
    local ok_fmu, filemanagerutil = pcall(require, "apps/filemanager/filemanagerutil")
    if ok_fmu then
        local default_dir = filemanagerutil.getDefaultDir()
        local home_dir = G_reader_settings:readSetting("home_dir")
        if (path == default_dir or path == home_dir) and G_reader_settings:nilOrTrue("shorten_home_dir") then
            return _("Home")
        end
    end

    -- Show only the last folder component
    local crumbs = {}
    for crumb in path:gmatch("[^/]+") do
        table.insert(crumbs, crumb)
    end
    if #crumbs == 0 then
        return "/"
    end
    local folder_name = crumbs[#crumbs]

    -- Add star if folder is in shortcuts
    local ok_fms, FileManagerShortcuts = pcall(require, "apps/filemanager/filemanagershortcuts")
    if ok_fms and FileManagerShortcuts.hasFolderShortcut and FileManagerShortcuts:hasFolderShortcut(path) then
        folder_name = "★ " .. folder_name
    end

    return folder_name
end

-- ============================================================
-- Patched Menu.init
-- Runs the original init, then rebuilds the footer to add the
-- folder name on the left and compact pagination on the right.
-- ============================================================
function Menu:init()
    -- Run the original initialisation first
    _Menu_init_orig(self)

    if not wantsPTFooter(self) then
        return
    end

    -- --------------------------------------------------------
    -- Rebuild page_info: keep the chevrons but pack them into
    -- a single HorizontalGroup (same as PT does).
    -- --------------------------------------------------------
    self.page_info =
        HorizontalGroup:new {
        self.page_info_first_chev,
        self.page_info_left_chev,
        self.page_info_text,
        self.page_info_right_chev,
        self.page_info_last_chev
    }

    local footer_h = self.page_info:getSize().h
    local screen_w = self.screen_w or Screen:getWidth()
    local inner_w = self.inner_dimen.w

    -- --------------------------------------------------------
    -- Right side: pagination controls (98% width for chevron whitespace)
    -- --------------------------------------------------------
    local page_info_container =
        RightContainer:new {
        dimen = Geom:new {w = screen_w * 0.99, h = footer_h},
        self.page_info
    }
    local page_controls =
        BottomContainer:new {
        dimen = self.inner_dimen:copy(),
        page_info_container
    }

    -- --------------------------------------------------------
    -- Left side: current folder / context name
    -- --------------------------------------------------------
    local pagination_w = self.page_info:getSize().w
    self.cur_folder_text =
        TextWidget:new {
        text = "", -- filled in by updatePageInfo
        face = Font:getFace(FOOTER_FONT_FACE, FOOTER_FONT_SIZE),
        max_width = (screen_w * 0.94) - pagination_w,
        truncate_with_ellipsis = true,
        truncate_left = true
    }
    local cur_folder_container =
        LeftContainer:new {
        dimen = Geom:new {w = screen_w * 0.96, h = footer_h},
        self.cur_folder_text
    }
    local current_folder =
        BottomContainer:new {
        dimen = self.inner_dimen:copy(),
        cur_folder_container
    }

    -- --------------------------------------------------------
    -- "Return" arrow (back button) — kept from original layout
    -- --------------------------------------------------------
    local page_return
    if self.return_button and self.page_return_arrow then
        local return_geom =
            Geom:new {
            x = 0,
            y = 0,
            w = screen_w * 1,
            h = self.page_return_arrow:getSize().h
        }
        page_return =
            BottomContainer:new {
            dimen = self.inner_dimen:copy(),
            LeftContainer:new {
                dimen = return_geom,
                self.return_button
            }
        }
    end

    -- --------------------------------------------------------
    -- Assemble footer with OverlapGroup
    -- --------------------------------------------------------
    local footer_parts = {
        allow_mirroring = false,
        dimen = self.inner_dimen:copy(),
        self.content_group,
        current_folder,
        page_controls
    }
    if page_return then
        table.insert(footer_parts, 4, page_return)
    end
    local footer = OverlapGroup:new(footer_parts)

    self[1] =
        FrameContainer:new {
        background = Blitbuffer.COLOR_WHITE,
        padding = 0,
        margin = 0,
        bordersize = 0,
        footer
    }

    -- Trigger an initial text fill
    if self.item_table then
        self:updatePageInfo(1)
    end
end

-- ============================================================
-- Patched Menu.updatePageInfo
-- Calls original (updates chevrons and page text), then:
--   1. Strips page text to just "X / Y"
--   2. Updates cur_folder_text with the left-side label
-- ============================================================
function Menu:updatePageInfo(select_number)
    _Menu_updatePageInfo_orig(self, select_number)

    -- Strip page info text to just the numbers (remove extra wording)
    if self.page_info_text and self.page_info_text.text and self.page_info_text.text ~= "" then
        local compact = self.page_info_text.text:match("(%d+%D+%d+)") or ""
        self.page_info_text:setText(compact)
    end

    -- Update folder name on the left
    if self.cur_folder_text then
        -- Recalculate max width in case pagination width changed
        if self.page_info then
            local screen_w = self.screen_w or Screen:getWidth()
            self.cur_folder_text:setMaxWidth(screen_w * 0.94 - self.page_info:getSize().w)
        end
        self.cur_folder_text:setText(getFooterLeftText(self))
    end
end
