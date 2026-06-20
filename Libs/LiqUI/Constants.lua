---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

local defaultBackdropTexture = "Interface/BUTTONS/WHITE8X8"

local colors = {
  blue = CreateColorFromHexString("FF1A4A6B"),
  blueHover = CreateColorFromHexString("FF2A5A7B"),
  blueDark = CreateColorFromHexString("FF16405C"),
  blueFocus = CreateColorFromHexString("FF5980BF"),
  white = CreateColorFromHexString("FFFFFFFF"),
  grayLight = CreateColorFromHexString("FFD9D9D9"),
  grayMuted = CreateColorFromHexString("FF999999"),
  grayDark = CreateColorFromHexString("FF2E2E33"),
  grayDarker = CreateColorFromHexString("FF232B31"),
  grayBorder = CreateColorFromHexString("FF595966"),
  grayBorderLight = CreateColorFromHexString("FF73737F"),
  grayHover = CreateColorFromHexString("FF474752"),
  grayRow = CreateColorFromHexString("FF29292E"),
  grayRowHover = CreateColorFromHexString("FF47474D"),
  grayPageHover = CreateColorFromHexString("FF525257"),
  white05 = CreateColorFromHexString("05FFFFFF"),
  white10 = CreateColorFromHexString("1AFFFFFF"),
  white20 = CreateColorFromHexString("33FFFFFF"),
  white30 = CreateColorFromHexString("4DFFFFFF"),
  white40 = CreateColorFromHexString("66FFFFFF"),
  white50 = CreateColorFromHexString("80FFFFFF"),
  white60 = CreateColorFromHexString("99FFFFFF"),
  white70 = CreateColorFromHexString("B3FFFFFF"),
  white80 = CreateColorFromHexString("CCFFFFFF"),
  white90 = CreateColorFromHexString("E6FFFFFF"),
}

---@class LiqUI_Constants
local Constants = {}
LiqUI.Constants = Constants

Constants.shared = {
  backdropTexture = defaultBackdropTexture,
}

Constants.control = {
  backgroundColor = colors.grayDark,
  backgroundColorHover = colors.grayHover,
  backgroundColorPressed = colors.grayDarker,
  borderColor = colors.grayLight,
  borderColorHighlight = colors.white,
  borderColorFocus = colors.blueFocus,
  backdrop = {
    bgFile = defaultBackdropTexture,
    edgeFile = defaultBackdropTexture,
    tile = true,
    tileSize = 8,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  },
  backdropNoBorder = {
    bgFile = defaultBackdropTexture,
    tile = true,
    tileSize = 8,
  },
  padding = 4,
  height = 24,
  checkSize = 24,
  checkSizeSmall = 14,
  dropdownItemHeight = 22,
  dropdownListMaxHeight = 200,
  colorPickerSwatchSize = 24,
  editBoxWidth = 180,
  buttonWidth = 120,
  dropdownWidth = 180,
  editBoxTextPaddingH = 6,
}

Constants.primary = {
  defaultColor = colors.blue,
  hoverColor = colors.blueHover,
  pressedColor = colors.blueDark,
}

Constants.text = {
  defaultColor = colors.white,
  mutedColor = colors.grayLight,
  placeholderColor = colors.grayMuted,
}

Constants.menu = {
  backgroundColor = colors.grayDarker,
  rowBackgroundColor = colors.grayRow,
  rowBackgroundColorHover = colors.white05,
  pageSelectedColor = colors.blue,
  pageBackgroundColorHover = colors.grayPageHover,
}

Constants.form = {
  headerLineColor = colors.grayBorder,
  rowGap = 12,
  labelDescGap = 4,
  labelOffsetY = -2,
}

Constants.window = {
  titlebarHeight = 30,
  padding = 8,
  titlebarIconLeft = 6,
  titlebarIconSize = 20,
  closeButtonIconSize = 10,
  closeButtonIconColor = { 0.7, 0.7, 0.7, 1 },
  iconCloseTexture = "Interface/AddOns/LiqUI/Media/Icon_Close.blp",
  maxWindowWidthMargin = 100,
}

Constants.layout = {
  sizes = {
    padding = 8,
    row = 22,
    header = 30,
    column = 100,
    border = 4,
    titlebar = {
      height = 30,
    },
    scrollbar = {
      thickness = 10,
      horizontalWheelPanExtent = 10,
      overflowTolerance = 2,
    },
    maxWindowWidthMargin = 100,
  },
  media = {
    whiteSquare = "Interface/BUTTONS/WHITE8X8",
    iconClose = "Interface/AddOns/LiqUI/Media/Icon_Close.blp",
    iconSettings = "Interface/AddOns/LiqUI/Media/Icon_Settings.blp",
  },
  colors = {
    primary = { r = 0.2, g = 0.6, b = 1.0, a = 1.0 },
    header = { r = 0, g = 0, b = 0, a = 0.3 },
  },
  defaultWindowColor = { r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1 },
}

Constants.settings = {
  windowWidth = 800,
  windowHeight = 500,
  menu = {
    width = 200,
    padding = 12,
    itemHeight = 24,
    pageIndent = 12,
    iconSize = 16,
    arrowWidth = 14,
    arrowHeight = 20,
    arrowAtlas = "shop-header-arrow",
    arrowAtlasDisabled = "shop-header-arrow-disabled",
    arrowAtlasHover = "shop-header-arrow-hover",
    arrowRotationDown = math.pi / 2,
    arrowRotationRight = math.pi,
  },
  form = {
    padding = 20,
    rowSpacingDefault = 20,
    rowSpacingAfterHeader = 4,
    rowSpacingAfterDescription = 10,
  },
}
