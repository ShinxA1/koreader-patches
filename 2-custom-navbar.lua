-- Bottom Navigation Bar patch for KOReader File Manager
-- Adds a tab bar at the bottom with Books, Manga, News, Continue
-- Sits below pagination controls

local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local FileManager = require("apps/filemanager/filemanager")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local IconWidget = require("ui/widget/iconwidget")
local InputContainer = require("ui/widget/container/inputcontainer")
local LineWidget = require("ui/widget/linewidget")
local Size = require("ui/size")
local TextWidget = require("ui/widget/textwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local Screen = Device.screen
local gettext = require("gettext")
local lfs = require("libs/libkoreader-lfs")
local BottomContainer = require("ui/widget/container/bottomcontainer")
local FrameContainer = require("ui/widget/container/framecontainer")
local LeftContainer = require("ui/widget/container/leftcontainer")
local OverlapGroup = require("ui/widget/overlapgroup")
local RightContainer = require("ui/widget/container/rightcontainer")

-- ============================================================
-- LOCALIZATION
-- ============================================================

local PATCH_L10N = {
    en = {
        -- Tab labels
        ["Manga"] = "Manga",
        ["News"] = "News",
        ["Continue"] = "Continue",
        ["History"] = "History",
        ["Favorites"] = "Favorites",
        ["Collections"] = "Collections",
        ["Exit"] = "Exit",
        -- Notifications
        ["Manga folder not found: "] = "Manga folder not found: ",
        ["Rakuyomi plugin is not installed."] = "Rakuyomi plugin is not installed.",
        ["News folder not found: "] = "News folder not found: ",
        ["QuickRSS plugin is not installed."] = "QuickRSS plugin is not installed.",
        ["Cannot open last document"] = "Cannot open last document",
        -- Settings menu
        ["Navbar settings"] = "Navbar settings",
        ["Show labels"] = "Show labels",
        ["Show top border"] = "Show top border",
        ["Active tab"] = "Active tab",
        ["Enable active tab styling"] = "Enable active tab styling",
        ["Bold active tab"] = "Bold active tab",
        ["Active tab underline"] = "Active tab underline",
        ["Underline location: "] = "Underline location: ",
        ["above"] = "above",
        ["below"] = "below",
        ["Colored active tab"] = "Colored active tab",
        ["Tabs"] = "Tabs",
        ["Arrange tabs"] = "Arrange tabs",
        ["Arrange navbar tabs"] = "Arrange navbar tabs",
        ["Books tab label: "] = "Books tab label: ",
        ["Books"] = "Books",
        ["Home"] = "Home",
        ["Library"] = "Library",
        ["Custom"] = "Custom",
        ["Custom: "] = "Custom: ",
        ["Books tab label"] = "Books tab label",
        ["Cancel"] = "Cancel",
        ["Set"] = "Set",
        ["Manga tab action: "] = "Manga tab action: ",
        ["News tab action: "] = "News tab action: ",
        ["Folder"] = "Folder",
        ["Rakuyomi"] = "Rakuyomi",
        ["QuickRSS"] = "QuickRSS",
        ["Open Rakuyomi"] = "Open Rakuyomi",
        ["Open QuickRSS"] = "Open QuickRSS",
        ["Open folder"] = "Open folder",
        ["Open folder: "] = "Open folder: ",
        ["Advanced"] = "Advanced",
        ["Show navbar in standalone views"] = "Show navbar in standalone views",
        ["Show the navbar in History, Favorites, Collections, Rakuyomi, and QuickRSS views."] = "Show the navbar in History, Favorites, Collections, Rakuyomi, and QuickRSS views.",
        ["Show top gap"] = "Show top gap",
        ["Add spacing above the navbar to separate it from the content above."] = "Add spacing above the navbar to separate it from the content above.",
        ["Refresh navbar"] = "Refresh navbar"
    },
    pt = {
        -- Abas
        ["Manga"] = "Manga",
        ["News"] = "Notícias",
        ["Continue"] = "Continuar",
        ["History"] = "Histórico",
        ["Favorites"] = "Favoritos",
        ["Collections"] = "Coleções",
        ["Exit"] = "Sair",
        -- Notificações
        ["Manga folder not found: "] = "Pasta de manga não encontrada: ",
        ["Rakuyomi plugin is not installed."] = "O plugin Rakuyomi não está instalado.",
        ["News folder not found: "] = "Pasta de notícias não encontrada: ",
        ["QuickRSS plugin is not installed."] = "O plugin QuickRSS não está instalado.",
        ["Cannot open last document"] = "Não foi possível abrir o último documento",
        -- Menu de configurações
        ["Navbar settings"] = "Configurações da barra",
        ["Show labels"] = "Mostrar rótulos",
        ["Show top border"] = "Mostrar borda superior",
        ["Active tab"] = "Aba ativa",
        ["Enable active tab styling"] = "Ativar estilo da aba ativa",
        ["Bold active tab"] = "Aba ativa em negrito",
        ["Active tab underline"] = "Sublinhado da aba ativa",
        ["Underline location: "] = "Posição do sublinhado: ",
        ["above"] = "acima",
        ["below"] = "abaixo",
        ["Colored active tab"] = "Aba ativa colorida",
        ["Tabs"] = "Abas",
        ["Arrange tabs"] = "Organizar abas",
        ["Arrange navbar tabs"] = "Organizar abas da barra",
        ["Books tab label: "] = "Rótulo da aba de livros: ",
        ["Books"] = "Livros",
        ["Home"] = "Início",
        ["Library"] = "Biblioteca",
        ["Custom"] = "Personalizado",
        ["Custom: "] = "Personalizado: ",
        ["Books tab label"] = "Rótulo da aba de livros",
        ["Cancel"] = "Cancelar",
        ["Set"] = "Definir",
        ["Manga tab action: "] = "Ação da aba de manga: ",
        ["News tab action: "] = "Ação da aba de notícias: ",
        ["Folder"] = "Pasta",
        ["Rakuyomi"] = "Rakuyomi",
        ["QuickRSS"] = "QuickRSS",
        ["Open Rakuyomi"] = "Abrir Rakuyomi",
        ["Open QuickRSS"] = "Abrir QuickRSS",
        ["Open folder"] = "Abrir pasta",
        ["Open folder: "] = "Abrir pasta: ",
        ["Advanced"] = "Avançado",
        ["Show navbar in standalone views"] = "Mostrar barra em telas independentes",
        ["Show the navbar in History, Favorites, Collections, Rakuyomi, and QuickRSS views."] = "Mostrar a barra nas telas de Histórico, Favoritos, Coleções, Rakuyomi e QuickRSS.",
        ["Show top gap"] = "Mostrar espaço superior",
        ["Add spacing above the navbar to separate it from the content above."] = "Adiciona espaço acima da barra para separá-la do conteúdo.",
        ["Refresh navbar"] = "Atualizar barra"
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
    if custom then
        return custom
    end
    return gettext(msg)
end

-- ============================================================
-- Layout constants
-- ============================================================

local navbar_icon_size = Screen:scaleBySize(34)
local navbar_font = Font:getFace("smallinfofont")
local navbar_font_bold = Font:getFace("smallinfofontbold")
local navbar_v_padding = Screen:scaleBySize(4)
-- Dead zone at left/right edges to avoid stealing corner gesture taps
local corner_dead_zone = math.floor(Screen:getWidth() / 12)
local navbar_top_gap = Screen:scaleBySize(10)
local underline_thickness = Screen:scaleBySize(2)

-- ============================================================
-- Persistent config
-- ============================================================

local config_default = {
    show_tabs = {
        books = true,
        manga = true,
        news = true,
        continue = true,
        history = false,
        favorites = false,
        collections = false,
        exit = false
    },
    tab_order = {
        "books",
        "manga",
        "news",
        "continue",
        "history",
        "favorites",
        "collections",
        "exit"
    },
    show_labels = true,
    show_top_border = true,
    books_label = "Books",
    manga_action = "rakuyomi",
    manga_folder = "",
    news_action = "quickrss",
    news_folder = "",
    colored = false,
    active_tab_color = {
        0x33,
        0x99,
        0xFF
    }, -- blue
    show_in_standalone = true,
    show_top_gap = false,
    active_tab_styling = true,
    active_tab_bold = true,
    active_tab_underline = true,
    underline_above = true
}

local function loadConfig()
    local config = G_reader_settings:readSetting("bottom_navbar", config_default)
    for k, v in pairs(config_default) do
        if config[k] == nil then
            config[k] = v
        end
    end
    if type(config.show_tabs) == "table" then
        for k, v in pairs(config_default.show_tabs) do
            if config.show_tabs[k] == nil then
                config.show_tabs[k] = v
            end
        end
    else
        config.show_tabs = config_default.show_tabs
    end
    -- Ensure tab_order contains all known tabs
    if type(config.tab_order) ~= "table" then
        config.tab_order = config_default.tab_order
    else
        local order_set = {}
        for _, v in ipairs(config.tab_order) do
            order_set[v] = true
        end
        for _, v in ipairs(config_default.tab_order) do
            if not order_set[v] then
                table.insert(config.tab_order, v)
            end
        end
    end
    return config
end

local config = loadConfig()

-- ============================================================
-- Tab definitions
-- ============================================================

local function getBooksLabel()
    local label = config.books_label ~= "" and config.books_label or "Books"
    return _(label)
end

local tabs = {
    {
        id = "books",
        label = getBooksLabel(),
        icon = "tab_books"
    },
    {
        id = "manga",
        label = _("Manga"),
        icon = "tab_manga"
    },
    {
        id = "news",
        label = _("News"),
        icon = "tab_news"
    },
    {
        id = "continue",
        label = _("Continue"),
        icon = "tab_continue"
    },
    {
        id = "history",
        label = _("History"),
        icon = "tab_history"
    },
    {
        id = "favorites",
        label = _("Favorites"),
        icon = "tab_favorites"
    },
    {
        id = "collections",
        label = _("Collections"),
        icon = "tab_collections"
    },
    {
        id = "exit",
        label = _("Exit"),
        icon = "tab_exit"
    }
}

local tabs_by_id = {}
for _, tab in ipairs(tabs) do
    tabs_by_id[tab.id] = tab
end

-- ============================================================
-- Active tab tracking
-- ============================================================

local active_tab = "books"

-- Forward declarations; defined later
local injectNavbar
local injectStandaloneNavbar
local hookQuickRSSInit

local function setActiveTab(id)
    active_tab = id
    local fm = FileManager.instance
    if fm then
        injectNavbar(fm)
        UIManager:setDirty(fm, "full")
    end
end

-- ============================================================
-- Tab callbacks
-- ============================================================

local function onTabBooks()
    local fm = FileManager.instance
    if not fm then
        return
    end
    local home_dir =
        G_reader_settings:readSetting("home_dir") or require("apps/filemanager/filemanagerutil").getDefaultDir()
    fm.file_chooser.path_items[home_dir] = nil
    fm.file_chooser:changeToPath(home_dir)
end

local function onTabManga()
    local fm = FileManager.instance
    if not fm then
        return
    end

    if config.manga_action == "folder" and config.manga_folder ~= "" then
        if lfs.attributes(config.manga_folder, "mode") == "directory" then
            fm.file_chooser:changeToPath(config.manga_folder)
        else
            local InfoMessage = require("ui/widget/infomessage")
            UIManager:show(
                InfoMessage:new {
                    text = _("Manga folder not found: ") .. config.manga_folder
                }
            )
        end
        return
    end

    -- Default: open Rakuyomi
    local rakuyomi = fm.rakuyomi
    if rakuyomi then
        rakuyomi:openLibraryView()
    else
        local InfoMessage = require("ui/widget/infomessage")
        UIManager:show(
            InfoMessage:new {
                text = _("Rakuyomi plugin is not installed.")
            }
        )
    end
end

local function onTabNews()
    local fm = FileManager.instance
    if not fm then
        return
    end

    if config.news_action == "folder" and config.news_folder ~= "" then
        if lfs.attributes(config.news_folder, "mode") == "directory" then
            fm.file_chooser:changeToPath(config.news_folder)
        else
            local InfoMessage = require("ui/widget/infomessage")
            UIManager:show(
                InfoMessage:new {
                    text = _("News folder not found: ") .. config.news_folder
                }
            )
        end
        return
    end

    -- Default: open QuickRSS
    hookQuickRSSInit()
    local ok, QuickRSSUI = pcall(require, "modules/ui/feed_view")
    if ok and QuickRSSUI then
        UIManager:show(QuickRSSUI:new {})
    else
        local InfoMessage = require("ui/widget/infomessage")
        UIManager:show(
            InfoMessage:new {
                text = _("QuickRSS plugin is not installed.")
            }
        )
    end
end

local function onTabContinue()
    local last_file = G_reader_settings:readSetting("lastfile")
    if not last_file or lfs.attributes(last_file, "mode") ~= "file" then
        local InfoMessage = require("ui/widget/infomessage")
        UIManager:show(
            InfoMessage:new {
                text = _("Cannot open last document")
            }
        )
        return
    end
    local ReaderUI = require("apps/reader/readerui")
    ReaderUI:showReader(last_file)
end

local function onTabHistory()
    local fm = FileManager.instance
    if fm and fm.history then
        fm.history:onShowHist()
    end
end

local function onTabFavorites()
    local fm = FileManager.instance
    if fm and fm.collections then
        fm.collections:onShowColl()
    end
end

local function onTabCollections()
    local fm = FileManager.instance
    if fm and fm.collections then
        fm.collections:onShowCollList()
    end
end

local function onTabExit()
    local fm = FileManager.instance
    if fm then
        fm:onClose()
    end
end

local tab_callbacks = {
    books = onTabBooks,
    manga = onTabManga,
    news = onTabNews,
    continue = onTabContinue,
    history = onTabHistory,
    favorites = onTabFavorites,
    collections = onTabCollections,
    exit = onTabExit
}

-- ============================================================
-- Color text support
-- ============================================================

local RenderText = require("ui/rendertext")

local ColorTextWidget = TextWidget:extend {}

function ColorTextWidget:paintTo(bb, x, y)
    self:updateSize()
    if self._is_empty then
        return
    end

    if not self.fgcolor or Blitbuffer.isColor8(self.fgcolor) or not Screen:isColorScreen() then
        TextWidget.paintTo(self, bb, x, y)
        return
    end

    if not self.use_xtext then
        TextWidget.paintTo(self, bb, x, y)
        return
    end

    if not self._xshaping then
        self._xshaping =
            self._xtext:shapeLine(self._shape_start, self._shape_end, self._shape_idx_to_substitute_with_ellipsis)
    end

    local text_width = bb:getWidth() - x
    if self.max_width and self.max_width < text_width then
        text_width = self.max_width
    end
    local pen_x = 0
    local baseline = self.forced_baseline or self._baseline_h
    for _, xglyph in ipairs(self._xshaping) do
        if pen_x >= text_width then
            break
        end
        local face = self.face.getFallbackFont(xglyph.font_num)
        local glyph = RenderText:getGlyphByIndex(face, xglyph.glyph, self.bold)
        bb:colorblitFromRGB32(
            glyph.bb,
            x + pen_x + glyph.l + xglyph.x_offset,
            y + baseline - glyph.t - xglyph.y_offset,
            0,
            0,
            glyph.bb:getWidth(),
            glyph.bb:getHeight(),
            self.fgcolor
        )
        pen_x = pen_x + xglyph.x_advance
    end
end

-- ============================================================
-- Colored icon widget
-- ============================================================

local ColorIconWidget =
    IconWidget:extend {
    _tint_color = nil
}

function ColorIconWidget:paintTo(bb, x, y)
    if not self._tint_color or not Screen:isColorScreen() then
        IconWidget.paintTo(self, bb, x, y)
        return
    end

    if self.hide then
        return
    end
    local size = self:getSize()
    if not self.dimen then
        self.dimen =
            Geom:new {
            x = x,
            y = y,
            w = size.w,
            h = size.h
        }
    else
        self.dimen.x = x
        self.dimen.y = y
    end
    self._bb:invert()
    bb:colorblitFromRGB32(self._bb, x, y, self._offset_x, self._offset_y, size.w, size.h, self._tint_color)
    self._bb:invert()
end

-- ============================================================
-- Build a single tab (visual only)
-- ============================================================

local function createTabWidget(tab, tab_w, is_active)
    local styled = is_active and config.active_tab_styling
    local use_color = styled and config.colored and Screen:isColorScreen()
    local active_color
    if use_color then
        local c = config.active_tab_color
        if c and type(c) == "table" then
            active_color = Blitbuffer.ColorRGB32(c[1], c[2], c[3], 0xFF)
        end
    end

    local use_bold = styled and config.active_tab_bold

    local icon
    if active_color then
        icon =
            ColorIconWidget:new {
            icon = tab.icon,
            width = navbar_icon_size,
            height = navbar_icon_size,
            _tint_color = active_color
        }
    else
        icon =
            IconWidget:new {
            icon = tab.icon,
            width = navbar_icon_size,
            height = navbar_icon_size
        }
    end

    local label
    if active_color then
        label =
            ColorTextWidget:new {
            text = tab.label,
            face = use_bold and navbar_font_bold or navbar_font,
            fgcolor = active_color
        }
    else
        label =
            TextWidget:new {
            text = tab.label,
            face = use_bold and navbar_font_bold or navbar_font
        }
    end

    local icon_label_group
    if config.show_labels then
        icon_label_group =
            VerticalGroup:new {
            align = "center",
            icon,
            label
        }
    else
        icon_label_group =
            VerticalGroup:new {
            align = "center",
            icon
        }
    end

    local show_underline = styled and config.active_tab_underline
    local underline
    if show_underline then
        local underline_color = Blitbuffer.COLOR_BLACK
        if config.colored then
            local c = config.active_tab_color
            if c and type(c) == "table" then
                underline_color = Blitbuffer.ColorRGB32(c[1], c[2], c[3], 0xFF)
            end
        end
        if config.colored and Screen:isColorScreen() then
            local Widget = require("ui/widget/widget")
            local color_line =
                Widget:new {
                dimen = Geom:new {
                    w = tab_w,
                    h = underline_thickness
                }
            }
            function color_line:paintTo(bb, x, y)
                bb:paintRectRGB32(x, y, self.dimen.w, self.dimen.h, underline_color)
            end
            underline = color_line
        else
            underline =
                LineWidget:new {
                dimen = Geom:new {
                    w = tab_w,
                    h = underline_thickness
                },
                background = underline_color
            }
        end
    else
        underline =
            VerticalSpan:new {
            width = underline_thickness
        }
    end

    local v_pad = config.show_labels and navbar_v_padding or navbar_v_padding * 2

    local children
    if config.underline_above then
        children = {
            align = "center",
            underline,
            VerticalSpan:new {
                width = v_pad
            },
            icon_label_group,
            VerticalSpan:new {
                width = v_pad
            }
        }
    else
        children = {
            align = "center",
            VerticalSpan:new {
                width = v_pad
            },
            icon_label_group,
            VerticalSpan:new {
                width = v_pad
            },
            underline
        }
    end

    return CenterContainer:new {
        dimen = Geom:new {
            w = tab_w,
            h = icon_label_group:getSize().h + v_pad * 2 + underline_thickness
        },
        VerticalGroup:new(children)
    }
end

-- ============================================================
-- Build the full navbar
-- ============================================================

local HorizontalSpan = require("ui/widget/horizontalspan")
local navbar_h_padding = Screen:scaleBySize(10)

local function getVisibleTabs()
    local visible = {}
    for _, id in ipairs(config.tab_order) do
        if (id == "books" or config.show_tabs[id]) and tabs_by_id[id] then
            table.insert(visible, tabs_by_id[id])
        end
    end
    return visible
end

local function createNavBar()
    -- Update books tab label from config (translated)
    tabs_by_id["books"].label = getBooksLabel()
    -- Refresh all other translatable tab labels (language may have changed)
    tabs_by_id["manga"].label = _("Manga")
    tabs_by_id["news"].label = _("News")
    tabs_by_id["continue"].label = _("Continue")
    tabs_by_id["history"].label = _("History")
    tabs_by_id["favorites"].label = _("Favorites")
    tabs_by_id["collections"].label = _("Collections")
    tabs_by_id["exit"].label = _("Exit")

    local visible_tabs = getVisibleTabs()
    if #visible_tabs == 0 then
        return nil
    end

    local screen_w = Screen:getWidth()
    local inner_w = screen_w - navbar_h_padding * 2
    local tab_w = math.floor(inner_w / #visible_tabs)

    local row = HorizontalGroup:new {}
    for _, tab in ipairs(visible_tabs) do
        table.insert(row, createTabWidget(tab, tab_w, tab.id == active_tab))
    end

    local OverlapGroup = require("ui/widget/overlapgroup")
    local row_with_padding =
        HorizontalGroup:new {
        HorizontalSpan:new {
            width = navbar_h_padding
        },
        row,
        HorizontalSpan:new {
            width = navbar_h_padding
        }
    }
    local row_h = row_with_padding:getSize().h

    local visual_children = {}

    if config.show_top_border then
        local separator =
            LineWidget:new {
            dimen = Geom:new {
                w = inner_w,
                h = Size.line.medium
            },
            background = Blitbuffer.COLOR_LIGHT_GRAY
        }
        local separator_and_row =
            OverlapGroup:new {
            dimen = Geom:new {
                w = screen_w,
                h = row_h
            },
            allow_mirroring = false,
            CenterContainer:new {
                dimen = Geom:new {
                    w = screen_w,
                    h = Size.line.medium
                },
                separator
            },
            row_with_padding
        }
        if config.show_top_gap then
            table.insert(
                visual_children,
                VerticalSpan:new {
                    width = navbar_top_gap
                }
            )
        end
        table.insert(visual_children, separator_and_row)
    else
        if config.show_top_gap then
            table.insert(
                visual_children,
                VerticalSpan:new {
                    width = navbar_top_gap
                }
            )
        end
        table.insert(visual_children, row_with_padding)
    end

    local visual = VerticalGroup:new(visual_children)

    local navbar =
        InputContainer:new {
        dimen = Geom:new {
            w = screen_w,
            h = visual:getSize().h
        },
        ges_events = {
            TapNavBar = {
                GestureRange:new {
                    ges = "tap",
                    range = Geom:new {
                        x = 0,
                        y = 0,
                        w = screen_w,
                        h = Screen:getHeight()
                    }
                }
            }
        }
    }

    navbar.onTapNavBar = function(self, _, ges)
        if not self.dimen or not self.dimen:contains(ges.pos) then
            return false
        end
        -- Let corner gesture zones pass through
        if ges.pos.x < corner_dead_zone or ges.pos.x > screen_w - corner_dead_zone then
            return false
        end
        local tap_x = ges.pos.x - navbar_h_padding
        local idx = math.floor(tap_x / tab_w) + 1
        idx = math.max(1, math.min(#visible_tabs, idx))
        local tapped_id = visible_tabs[idx].id
        local cb = tab_callbacks[tapped_id]
        if cb then
            cb()
        end
        local stays_in_browser =
            tapped_id == "books" or
            (tapped_id == "manga" and config.manga_action == "folder" and config.manga_folder ~= "") or
            (tapped_id == "news" and config.news_action == "folder" and config.news_folder ~= "")
        if stays_in_browser and tapped_id ~= active_tab then
            setActiveTab(tapped_id)
        end
        return true
    end

    navbar[1] = visual
    return navbar
end

-- ============================================================
-- Hook Menu:init() to reduce height for FM and standalone views
-- ============================================================

local Menu = require("ui/widget/menu")

local function getNavbarHeight()
    local nb = createNavBar()
    return nb and nb:getSize().h or 0
end

local standalone_view_names = {
    history = true,
    collections = true,
    library_view = true
}
local standalone_nexttick_tab_ids = {
    library_view = "manga"
}
local _skip_standalone_navbar = false
local _expect_coll_list_navbar = false -- nova flag

local function isStandaloneNavbarView(menu)
    if standalone_view_names[menu.name] then
        return true
    end
    -- Só aceita menu sem nome se estiver DENTRO de onShowCollList (browse mode)
    if
        _expect_coll_list_navbar and not menu.name and menu.covers_fullscreen and menu.is_borderless and
            menu.title_bar_fm_style
     then
        return true
    end
    return false
end

local _skip_standalone_navbar = false
local function setupSplitFooter(menu)
    if not menu.page_info_text or not menu.inner_dimen or not menu.content_group or not menu.page_info_first_chev then
        return
    end

    local screen_w = Screen:getWidth()

    menu.page_info =
        HorizontalGroup:new {
        menu.page_info_first_chev,
        menu.page_info_left_chev,
        menu.page_info_text,
        menu.page_info_right_chev,
        menu.page_info_last_chev
    }

    local page_controls =
        BottomContainer:new {
        dimen = menu.inner_dimen:copy(),
        RightContainer:new {
            dimen = Geom:new {
                w = screen_w * 0.98,
                h = menu.page_info:getSize().h
            },
            menu.page_info
        }
    }

    menu.cur_folder_text =
        TextWidget:new {
        text = "",
        face = Font:getFace("smallinfofont", 20),
        max_width = screen_w * 0.94 - menu.page_info:getSize().w,
        truncate_with_ellipsis = true,
        truncate_left = true
    }
    local current_folder =
        BottomContainer:new {
        dimen = menu.inner_dimen:copy(),
        LeftContainer:new {
            dimen = Geom:new {
                w = screen_w * 0.94,
                h = menu.page_info:getSize().h
            },
            menu.cur_folder_text
        }
    }

    local page_return
    if menu.return_button and menu.page_return_arrow then
        page_return =
            BottomContainer:new {
            dimen = menu.inner_dimen:copy(),
            LeftContainer:new {
                dimen = Geom:new {
                    w = screen_w * 0.94,
                    h = menu.page_return_arrow:getSize().h
                },
                menu.return_button
            }
        }
    end

    local footer_line =
        BottomContainer:new {
        dimen = Geom:new {
            w = menu.inner_dimen.w,
            h = menu.inner_dimen.h - menu.page_info:getSize().h
        },
        LineWidget:new {
            dimen = Geom:new {
                w = menu.inner_dimen.w,
                h = Size.line.medium
            },
            background = Blitbuffer.COLOR_LIGHT_GRAY
        }
    }

    local overlap =
        OverlapGroup:new {
        allow_mirroring = false,
        dimen = menu.inner_dimen:copy(),
        menu.content_group,
        current_folder,
        page_controls
    }
    if page_return then
        table.insert(overlap, 3, page_return)
    end

    menu[1] =
        FrameContainer:new {
        background = Blitbuffer.COLOR_WHITE,
        padding = 0,
        margin = 0,
        bordersize = 0,
        overlap
    }

    if type(menu.path) == "string" and menu.path ~= "" then
        local home_dir = G_reader_settings:readSetting("home_dir")
        local label = (menu.path == home_dir) and _("Home") or (menu.path:match("([^/]+)$") or "/")
        menu.cur_folder_text:setText(label)
    end
end

local orig_menu_updatePageInfo = Menu.updatePageInfo

function Menu:updatePageInfo(select_number)
    orig_menu_updatePageInfo(self, select_number)

    if not self.cur_folder_text then
        return
    end

    if self.page_info_text and self.page_info_text.text and self.page_info_text.text ~= "" then
        local trimmed = string.match(self.page_info_text.text, "(%d+%D+%d+)") or ""
        self.page_info_text:setText(trimmed)
    end

    if type(self.path) == "string" and self.path ~= "" then
        local home_dir = G_reader_settings:readSetting("home_dir")
        local label = (self.path == home_dir) and _("Home") or (self.path:match("([^/]+)$") or "/")
        self.cur_folder_text:setMaxWidth(Screen:getWidth() * 0.94 - self.page_info:getSize().w)
        self.cur_folder_text:setText(label)
    end
end

local orig_menu_init = Menu.init

function Menu:init()
    if self.name == "filemanager" and not self.height then
        self.height = Screen:getHeight() - getNavbarHeight()
    elseif config.show_in_standalone and not _skip_standalone_navbar and isStandaloneNavbarView(self) then
        self.height = Screen:getHeight() - getNavbarHeight()
        if not self.is_borderless then
            self.is_borderless = true
        end
    end
    orig_menu_init(self)
    if self.name == "filemanager" then
        setupSplitFooter(self)
    end
    local nexttick_tab_id = standalone_nexttick_tab_ids[self.name]
    if nexttick_tab_id and config.show_in_standalone then
        local menu = self
        UIManager:nextTick(
            function()
                injectStandaloneNavbar(menu, nexttick_tab_id)
            end
        )
    end
end

-- ============================================================
-- Auto-switch active tab on folder change
-- ============================================================

local orig_onPathChanged = FileManager.onPathChanged

function FileManager:onPathChanged(path)
    if orig_onPathChanged then
        orig_onPathChanged(self, path)
    end

    local function startsWith(str, prefix)
        return str:sub(1, #prefix) == prefix
    end

    local new_tab
    if config.manga_action == "folder" and config.manga_folder ~= "" then
        if path == config.manga_folder or startsWith(path, config.manga_folder .. "/") then
            new_tab = "manga"
        end
    end
    if not new_tab and config.news_action == "folder" and config.news_folder ~= "" then
        if path == config.news_folder or startsWith(path, config.news_folder .. "/") then
            new_tab = "news"
        end
    end
    if not new_tab then
        local home_dir =
            G_reader_settings:readSetting("home_dir") or require("apps/filemanager/filemanagerutil").getDefaultDir()
        if path == home_dir or startsWith(path, home_dir .. "/") then
            new_tab = "books"
        end
    end

    if new_tab and new_tab ~= active_tab then
        active_tab = new_tab
        injectNavbar(self)
        UIManager:setDirty(self, "full")
    end
end

-- ============================================================
-- Inject navbar INTO the existing fm_ui FrameContainer
-- ============================================================

injectNavbar = function(fm)
    local fm_ui = fm[1]
    if not fm_ui then
        return
    end

    local file_chooser
    if fm._navbar_injected then
        file_chooser = fm_ui[1] and fm_ui[1][1]
    else
        file_chooser = fm_ui[1]
    end
    if not file_chooser then
        return
    end

    fm._navbar_injected = true

    local navbar = createNavBar()
    if not navbar then
        fm_ui[1] = file_chooser
        return
    end

    local navbar_h = navbar:getSize().h
    local new_height = Screen:getHeight() - navbar_h
    if file_chooser.height ~= new_height then
        local chrome = file_chooser.dimen.h - file_chooser.inner_dimen.h
        file_chooser.height = new_height
        file_chooser.dimen.h = new_height
        file_chooser.inner_dimen.h = new_height - chrome
        file_chooser:updateItems()
        -- Reconstrói o footer com o inner_dimen atualizado
        setupSplitFooter(file_chooser)
    end

    fm_ui[1] =
        VerticalGroup:new {
        align = "left",
        file_chooser,
        navbar
    }
end

-- ============================================================
-- Inject navbar into standalone views
-- ============================================================

injectStandaloneNavbar = function(menu, view_tab_id)
    if not menu or not menu[1] then
        return
    end

    local saved_active = active_tab
    active_tab = view_tab_id
    local navbar = createNavBar()
    active_tab = saved_active

    if not navbar then
        return
    end

    local navbar_h = navbar:getSize().h
    local content_h = Screen:getHeight() - navbar_h

    -- Reduz a altura do conteúdo caso Menu:init() não tenha feito isso
    if menu.dimen and menu.dimen.h > content_h then
        menu.dimen.h = content_h
    end
    if menu[1] and menu[1].dimen and menu[1].dimen.h > content_h then
        menu[1].dimen.h = content_h
    end

    navbar.onTapNavBar = function(self_nb, _, ges)
        if not self_nb.dimen or not self_nb.dimen:contains(ges.pos) then
            return false
        end
        local screen_w = Screen:getWidth()
        if ges.pos.x < corner_dead_zone or ges.pos.x > screen_w - corner_dead_zone then
            return false
        end
        local vis_tabs = getVisibleTabs()
        if #vis_tabs == 0 then
            return false
        end
        local inner_w = screen_w - navbar_h_padding * 2
        local tab_w_local = math.floor(inner_w / #vis_tabs)
        local tap_x = ges.pos.x - navbar_h_padding
        local idx = math.floor(tap_x / tab_w_local) + 1
        idx = math.max(1, math.min(#vis_tabs, idx))
        local tapped_id = vis_tabs[idx].id

        if tapped_id == view_tab_id then
            return true
        end

        if menu.close_callback then
            menu.close_callback()
        elseif menu.onClose then
            menu:onClose()
        else
            UIManager:close(menu)
        end

        setActiveTab(tapped_id)

        local cb = tab_callbacks[tapped_id]
        if cb then
            cb()
        end

        return true
    end

    menu.dimen.h = Screen:getHeight()

    local FrameContainer = require("ui/widget/container/framecontainer")
    menu[1] =
        FrameContainer:new {
        background = Blitbuffer.COLOR_WHITE,
        bordersize = 0,
        padding = 0,
        margin = 0,
        VerticalGroup:new {
            align = "left",
            menu[1],
            navbar
        }
    }
end

local orig_setupLayout = FileManager.setupLayout

function FileManager:setupLayout()
    orig_setupLayout(self)

    self._navbar_injected = false

    local fm = self
    UIManager:nextTick(
        function()
            injectNavbar(fm)
            UIManager:setDirty(fm, "ui")
        end
    )
end

-- ============================================================
-- Hook standalone views to inject navbar after creation
-- ============================================================

local FileManagerHistory = require("apps/filemanager/filemanagerhistory")
local orig_onShowHist = FileManagerHistory.onShowHist

function FileManagerHistory:onShowHist(search_info)
    local result = orig_onShowHist(self, search_info)
    if config.show_in_standalone and self.booklist_menu then
        injectStandaloneNavbar(self.booklist_menu, "history")
    end
    return result
end

local FileManagerCollection = require("apps/filemanager/filemanagercollection")
local orig_onShowColl = FileManagerCollection.onShowColl

function FileManagerCollection:onShowColl(collection_name)
    local from_coll_list = self.coll_list ~= nil
    local result = orig_onShowColl(self, collection_name)
    if config.show_in_standalone and self.booklist_menu then
        injectStandaloneNavbar(self.booklist_menu, from_coll_list and "collections" or "favorites")
    end
    return result
end

local orig_onShowCollList = FileManagerCollection.onShowCollList

function FileManagerCollection:onShowCollList(file_or_selected_collections, caller_callback, no_dialog)
    if file_or_selected_collections ~= nil then
        _skip_standalone_navbar = true
    else
        _expect_coll_list_navbar = true -- sinaliza que o próximo Menu:init sem nome é o coll_list
    end
    local result = orig_onShowCollList(self, file_or_selected_collections, caller_callback, no_dialog)
    _skip_standalone_navbar = false
    _expect_coll_list_navbar = false -- limpa após o init ter rodado
    if config.show_in_standalone and self.coll_list and file_or_selected_collections == nil then
        injectStandaloneNavbar(self.coll_list, "collections")
    end
    return result
end

-- ============================================================
-- Hook QuickRSS feed view to inject navbar
-- ============================================================

local _qrss_hooked = false

hookQuickRSSInit = function()
    if _qrss_hooked then
        return
    end
    local ok, QuickRSSUI_class = pcall(require, "modules/ui/feed_view")
    if not ok or not QuickRSSUI_class then
        return
    end
    _qrss_hooked = true

    local ok_ai, ArticleItemModule = pcall(require, "modules/ui/article_item")
    local QRSS_ITEM_HEIGHT = ok_ai and ArticleItemModule.ITEM_HEIGHT

    local orig_qrss_init = QuickRSSUI_class.init
    function QuickRSSUI_class:init()
        orig_qrss_init(self)

        if not config.show_in_standalone then
            return
        end

        local navbar_h = getNavbarHeight()
        if navbar_h <= 0 then
            return
        end

        self[1].height = self[1].height - navbar_h

        self.list_h = self.list_h - navbar_h
        if QRSS_ITEM_HEIGHT then
            self.items_per_page = math.max(1, math.floor(self.list_h / QRSS_ITEM_HEIGHT))
        end

        local saved_active = active_tab
        active_tab = "news"
        local navbar = createNavBar()
        active_tab = saved_active
        if not navbar then
            return
        end

        navbar.onTapNavBar = function(self_nb, _, ges)
            if not self_nb.dimen or not self_nb.dimen:contains(ges.pos) then
                return false
            end
            local screen_w = Screen:getWidth()
            if ges.pos.x < corner_dead_zone or ges.pos.x > screen_w - corner_dead_zone then
                return false
            end
            local vis_tabs = getVisibleTabs()
            if #vis_tabs == 0 then
                return false
            end
            local inner_w = screen_w - navbar_h_padding * 2
            local tab_w_local = math.floor(inner_w / #vis_tabs)
            local tap_x = ges.pos.x - navbar_h_padding
            local idx = math.floor(tap_x / tab_w_local) + 1
            idx = math.max(1, math.min(#vis_tabs, idx))
            local tapped_id = vis_tabs[idx].id
            if tapped_id == "news" then
                return true
            end
            self:onClose()
            setActiveTab(tapped_id)
            local cb = tab_callbacks[tapped_id]
            if cb then
                cb()
            end
            return true
        end

        local FrameContainer = require("ui/widget/container/framecontainer")
        self[1] =
            FrameContainer:new {
            background = Blitbuffer.COLOR_WHITE,
            bordersize = 0,
            padding = 0,
            margin = 0,
            VerticalGroup:new {
                align = "left",
                self[1],
                navbar
            }
        }

        self.dimen =
            Geom:new {
            w = Screen:getWidth(),
            h = Screen:getHeight()
        }

        if #self.articles > 0 then
            self:_populateItems()
        end
    end

    local orig_qrss_onClose = QuickRSSUI_class.onClose
    function QuickRSSUI_class:onClose()
        orig_qrss_onClose(self)
        setActiveTab("books")
    end
end

-- ============================================================
-- Settings menu
-- ============================================================

local FileManagerMenu = require("apps/filemanager/filemanagermenu")
local FileManagerMenuOrder = require("ui/elements/filemanager_menu_order")

local orig_setUpdateItemTable = FileManagerMenu.setUpdateItemTable

function FileManagerMenu:setUpdateItemTable()
    table.insert(FileManagerMenuOrder.filemanager_settings, "navbar_settings")

    self.menu_items.navbar_settings = {
        text = _("Navbar settings"),
        sub_item_table = {
            {
                text = _("Show labels"),
                checked_func = function()
                    return config.show_labels
                end,
                callback = function()
                    config.show_labels = not config.show_labels
                    G_reader_settings:saveSetting("bottom_navbar", config)
                end
            },
            {
                text = _("Show top border"),
                checked_func = function()
                    return config.show_top_border
                end,
                callback = function()
                    config.show_top_border = not config.show_top_border
                    G_reader_settings:saveSetting("bottom_navbar", config)
                end
            },
            {
                text = _("Active tab"),
                sub_item_table = {
                    {
                        text = _("Enable active tab styling"),
                        checked_func = function()
                            return config.active_tab_styling
                        end,
                        callback = function()
                            config.active_tab_styling = not config.active_tab_styling
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("Bold active tab"),
                        enabled_func = function()
                            return config.active_tab_styling
                        end,
                        checked_func = function()
                            return config.active_tab_bold
                        end,
                        callback = function()
                            config.active_tab_bold = not config.active_tab_bold
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("Active tab underline"),
                        enabled_func = function()
                            return config.active_tab_styling
                        end,
                        checked_func = function()
                            return config.active_tab_underline
                        end,
                        callback = function()
                            config.active_tab_underline = not config.active_tab_underline
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text_func = function()
                            return _("Underline location: ") .. (config.underline_above and _("above") or _("below"))
                        end,
                        enabled_func = function()
                            return config.active_tab_styling and config.active_tab_underline
                        end,
                        callback = function()
                            config.underline_above = not config.underline_above
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("Colored active tab"),
                        enabled_func = function()
                            return config.active_tab_styling
                        end,
                        checked_func = function()
                            return config.colored
                        end,
                        callback = function()
                            config.colored = not config.colored
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    }
                }
            },
            {
                text = _("Tabs"),
                sub_item_table = {
                    {
                        text = _("Arrange tabs"),
                        keep_menu_open = true,
                        callback = function()
                            local SortWidget = require("ui/widget/sortwidget")
                            local sort_items = {}
                            for _, id in ipairs(config.tab_order) do
                                local tab = tabs_by_id[id]
                                if tab then
                                    table.insert(
                                        sort_items,
                                        {
                                            text = tab.label,
                                            orig_item = id,
                                            dim = not config.show_tabs[id]
                                        }
                                    )
                                end
                            end
                            UIManager:show(
                                SortWidget:new {
                                    title = _("Arrange navbar tabs"),
                                    item_table = sort_items,
                                    callback = function()
                                        for i, item in ipairs(sort_items) do
                                            config.tab_order[i] = item.orig_item
                                        end
                                        G_reader_settings:saveSetting("bottom_navbar", config)
                                    end
                                }
                            )
                        end
                    },
                    {
                        text_func = function()
                            return _("Books tab label: ") .. getBooksLabel()
                        end,
                        separator = true,
                        sub_item_table = {
                            {
                                text = _("Books"),
                                checked_func = function()
                                    return config.books_label == "Books" or config.books_label == ""
                                end,
                                callback = function()
                                    config.books_label = "Books"
                                    G_reader_settings:saveSetting("bottom_navbar", config)
                                end
                            },
                            {
                                text = _("Home"),
                                checked_func = function()
                                    return config.books_label == "Home"
                                end,
                                callback = function()
                                    config.books_label = "Home"
                                    G_reader_settings:saveSetting("bottom_navbar", config)
                                end
                            },
                            {
                                text = _("Library"),
                                checked_func = function()
                                    return config.books_label == "Library"
                                end,
                                callback = function()
                                    config.books_label = "Library"
                                    G_reader_settings:saveSetting("bottom_navbar", config)
                                end
                            },
                            {
                                text_func = function()
                                    local presets = {
                                        [""] = true,
                                        Books = true,
                                        Home = true,
                                        Library = true
                                    }
                                    if presets[config.books_label] then
                                        return _("Custom")
                                    end
                                    return _("Custom: ") .. config.books_label
                                end,
                                checked_func = function()
                                    local presets = {
                                        [""] = true,
                                        Books = true,
                                        Home = true,
                                        Library = true
                                    }
                                    return not presets[config.books_label]
                                end,
                                keep_menu_open = true,
                                callback = function(touchmenu_instance)
                                    local InputDialog = require("ui/widget/inputdialog")
                                    local dlg
                                    dlg =
                                        InputDialog:new {
                                        title = _("Books tab label"),
                                        input = config.books_label,
                                        buttons = {
                                            {
                                                {
                                                    text = _("Cancel"),
                                                    id = "close",
                                                    callback = function()
                                                        UIManager:close(dlg)
                                                    end
                                                },
                                                {
                                                    text = _("Set"),
                                                    is_enter_default = true,
                                                    callback = function()
                                                        local text = dlg:getInputText()
                                                        config.books_label = text ~= "" and text or "Books"
                                                        G_reader_settings:saveSetting("bottom_navbar", config)
                                                        UIManager:close(dlg)
                                                        if touchmenu_instance then
                                                            touchmenu_instance:updateItems()
                                                        end
                                                    end
                                                }
                                            }
                                        }
                                    }
                                    UIManager:show(dlg)
                                    dlg:onShowKeyboard()
                                end
                            }
                        }
                    },
                    {
                        text = _("Manga"),
                        checked_func = function()
                            return config.show_tabs.manga
                        end,
                        callback = function()
                            config.show_tabs.manga = not config.show_tabs.manga
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text_func = function()
                            if config.manga_action == "folder" then
                                return _("Manga tab action: ") .. _("Folder")
                            end
                            return _("Manga tab action: ") .. _("Rakuyomi")
                        end,
                        separator = true,
                        sub_item_table = {
                            {
                                text = _("Open Rakuyomi"),
                                checked_func = function()
                                    return config.manga_action ~= "folder"
                                end,
                                callback = function()
                                    config.manga_action = "rakuyomi"
                                    G_reader_settings:saveSetting("bottom_navbar", config)
                                end
                            },
                            {
                                text_func = function()
                                    if config.manga_action == "folder" and config.manga_folder ~= "" then
                                        local util = require("util")
                                        local _dir, folder_name = util.splitFilePathName(config.manga_folder)
                                        return _("Open folder: ") .. folder_name
                                    end
                                    return _("Open folder")
                                end,
                                checked_func = function()
                                    return config.manga_action == "folder"
                                end,
                                keep_menu_open = true,
                                callback = function(touchmenu_instance)
                                    local PathChooser = require("ui/widget/pathchooser")
                                    local start_path =
                                        config.manga_folder ~= "" and config.manga_folder or
                                        G_reader_settings:readSetting("lastdir") or
                                        "/"
                                    local path_chooser =
                                        PathChooser:new {
                                        select_file = false,
                                        show_files = false,
                                        path = start_path,
                                        onConfirm = function(dir_path)
                                            config.manga_action = "folder"
                                            config.manga_folder = dir_path
                                            G_reader_settings:saveSetting("bottom_navbar", config)
                                            if touchmenu_instance then
                                                touchmenu_instance:updateItems()
                                            end
                                        end
                                    }
                                    UIManager:show(path_chooser)
                                end
                            }
                        }
                    },
                    {
                        text = _("News"),
                        checked_func = function()
                            return config.show_tabs.news
                        end,
                        callback = function()
                            config.show_tabs.news = not config.show_tabs.news
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text_func = function()
                            if config.news_action == "folder" then
                                return _("News tab action: ") .. _("Folder")
                            end
                            return _("News tab action: ") .. _("QuickRSS")
                        end,
                        separator = true,
                        sub_item_table = {
                            {
                                text = _("Open QuickRSS"),
                                checked_func = function()
                                    return config.news_action ~= "folder"
                                end,
                                callback = function()
                                    config.news_action = "quickrss"
                                    G_reader_settings:saveSetting("bottom_navbar", config)
                                end
                            },
                            {
                                text_func = function()
                                    if config.news_action == "folder" and config.news_folder ~= "" then
                                        local util = require("util")
                                        local _dir, folder_name = util.splitFilePathName(config.news_folder)
                                        return _("Open folder: ") .. folder_name
                                    end
                                    return _("Open folder")
                                end,
                                checked_func = function()
                                    return config.news_action == "folder"
                                end,
                                keep_menu_open = true,
                                callback = function(touchmenu_instance)
                                    local PathChooser = require("ui/widget/pathchooser")
                                    local start_path =
                                        config.news_folder ~= "" and config.news_folder or
                                        G_reader_settings:readSetting("lastdir") or
                                        "/"
                                    local path_chooser =
                                        PathChooser:new {
                                        select_file = false,
                                        show_files = false,
                                        path = start_path,
                                        onConfirm = function(dir_path)
                                            config.news_action = "folder"
                                            config.news_folder = dir_path
                                            G_reader_settings:saveSetting("bottom_navbar", config)
                                            if touchmenu_instance then
                                                touchmenu_instance:updateItems()
                                            end
                                        end
                                    }
                                    UIManager:show(path_chooser)
                                end
                            }
                        }
                    },
                    {
                        text = _("Continue"),
                        checked_func = function()
                            return config.show_tabs.continue
                        end,
                        callback = function()
                            config.show_tabs.continue = not config.show_tabs.continue
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("History"),
                        checked_func = function()
                            return config.show_tabs.history
                        end,
                        callback = function()
                            config.show_tabs.history = not config.show_tabs.history
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("Favorites"),
                        checked_func = function()
                            return config.show_tabs.favorites
                        end,
                        callback = function()
                            config.show_tabs.favorites = not config.show_tabs.favorites
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("Collections"),
                        checked_func = function()
                            return config.show_tabs.collections
                        end,
                        callback = function()
                            config.show_tabs.collections = not config.show_tabs.collections
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("Exit"),
                        checked_func = function()
                            return config.show_tabs.exit
                        end,
                        callback = function()
                            config.show_tabs.exit = not config.show_tabs.exit
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    }
                }
            },
            {
                text = _("Advanced"),
                sub_item_table = {
                    {
                        text = _("Show navbar in standalone views"),
                        help_text = _(
                            "Show the navbar in History, Favorites, Collections, Rakuyomi, and QuickRSS views."
                        ),
                        checked_func = function()
                            return config.show_in_standalone
                        end,
                        callback = function()
                            config.show_in_standalone = not config.show_in_standalone
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    },
                    {
                        text = _("Show top gap"),
                        help_text = _("Add spacing above the navbar to separate it from the content above."),
                        checked_func = function()
                            return config.show_top_gap
                        end,
                        callback = function()
                            config.show_top_gap = not config.show_top_gap
                            G_reader_settings:saveSetting("bottom_navbar", config)
                        end
                    }
                }
            },
            {
                text = _("Refresh navbar"),
                keep_menu_open = true,
                separator = true,
                callback = function()
                    local fm = FileManager.instance
                    if fm then
                        injectNavbar(fm)
                        UIManager:setDirty(fm, "ui")
                    end
                end
            }
        }
    }

    orig_setUpdateItemTable(self)

    hookQuickRSSInit()
end
