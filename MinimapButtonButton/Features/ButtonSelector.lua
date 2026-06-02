local addonName, addon = ...;

local CreateFrame = _G.CreateFrame;
local UIParent = _G.UIParent;
local ReloadUI = _G.ReloadUI;
local table = _G.table;
local string = _G.string;
local pairs = _G.pairs;
local ipairs = _G.ipairs;

local Main = addon.import('Logic/Main');
local Options = addon.import('Logic/Options');
local Utils = addon.import('Core/Utils');

local ButtonSelector = addon.export('Features/ButtonSelector', {});

local frame = nil;
local scrollFrame = nil;
local scrollChild = nil;
local rows = {};
local initialBlacklist = {};

local function cloneTable(t)
  local copy = {};
  for k, v in pairs(t) do
    copy[k] = v;
  end
  return copy;
end

local function FindIconTexture(frame)
  if not frame then return nil; end
  if frame.icon and type(frame.icon) == "table" and frame.icon.GetTexture then
    return frame.icon:GetTexture();
  end
  if frame.GetRegions then
    for _, region in ipairs({frame:GetRegions()}) do
      if region.IsObjectType and region:IsObjectType("Texture") then
        local tex = region:GetTexture();
        if tex and (type(tex) == "string" or type(tex) == "number") then
          local strTex = string.lower(tostring(tex));
          if not string.find(strTex, "border") and not string.find(strTex, "background") then
            return tex;
          end
        end
      end
    end
    -- Fallback to first texture
    for _, region in ipairs({frame:GetRegions()}) do
      if region.IsObjectType and region:IsObjectType("Texture") then
        local tex = region:GetTexture();
        if tex then return tex; end
      end
    end
  end
  return nil;
end

local function GetFrameByName(name)
  for _, btn in ipairs(Main.collectedButtons) do
    if Utils.getFrameName(btn) == name then
      return btn;
    end
  end
  return nil;
end

local function UpdateList()
  if not frame then return; end

  local options = Options.getAll();
  local collected = Main.collectedButtons;

  local buttonMap = {};
  for _, btn in ipairs(collected) do
    local name = Utils.getFrameName(btn);
    if name then
      buttonMap[name] = true;
    end
  end

  for name in pairs(options.blacklist) do
    buttonMap[name] = false;
  end

  local buttons = {};
  for name, isIncluded in pairs(buttonMap) do
    table.insert(buttons, { name = name, isIncluded = isIncluded });
  end

  table.sort(buttons, function(a, b)
    return string.lower(a.name) < string.lower(b.name);
  end);

  -- Check if reload is needed
  local reloadNeeded = false;
  for name in pairs(options.blacklist) do
    if not initialBlacklist[name] then
      reloadNeeded = true;
      break;
    end
  end

  if reloadNeeded then
    frame.reloadBtn:Enable();
    frame.warningText:Show();
    frame.reloadBtn:SetText("Apply & Reload");
  else
    frame.reloadBtn:Disable();
    frame.warningText:Hide();
    frame.reloadBtn:SetText("Reload UI");
  end

  local rowHeight = 26;
  for _, r in ipairs(rows) do
    r:Hide();
  end

  for i, btnData in ipairs(buttons) do
    local row = rows[i];
    if not row then
      row = CreateFrame("Frame", nil, scrollChild, _G.BackdropTemplateMixin and "BackdropTemplate");
      row:SetHeight(rowHeight);
      row:SetPoint("LEFT", scrollChild, "LEFT", 0, 0);
      row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0);

      local highlight = row:CreateTexture(nil, "BACKGROUND");
      highlight:SetAllPoints(row);
      highlight:SetColorTexture(1, 1, 1, 0.05);
      highlight:Hide();
      row.highlight = highlight;

      row:SetScript("OnEnter", function() highlight:Show(); end);
      row:SetScript("OnLeave", function() highlight:Hide(); end);

      local icon = row:CreateTexture(nil, "ARTWORK");
      icon:SetSize(16, 16);
      icon:SetPoint("LEFT", row, "LEFT", 8, 0);
      row.icon = icon;

      local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
      nameText:SetPoint("LEFT", row, "LEFT", 30, 0);
      nameText:SetPoint("RIGHT", row, "RIGHT", -36, 0);
      nameText:SetJustifyH("LEFT");
      row.nameText = nameText;

      local chk = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
      chk:SetSize(20, 20);
      chk:SetPoint("RIGHT", row, "RIGHT", -8, 0);
      chk:SetScale(0.9);
      row.chk = chk;

      rows[i] = row;
    end

    row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i-1) * rowHeight);
    row:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -(i-1) * rowHeight);
    row.nameText:SetText(btnData.name);
    row.chk:SetChecked(btnData.isIncluded);

    local btnFrame = GetFrameByName(btnData.name);
    local tex = FindIconTexture(btnFrame);
    if tex then
      row.icon:SetTexture(tex);
      row.icon:SetTexCoord(0, 1, 0, 1);
    else
      row.icon:SetTexture('Interface\\AddOns\\' .. addonName .. '\\Media\\Logo.blp');
      row.icon:SetTexCoord(0, 1, 0, 1);
    end

    row.chk:SetScript("OnClick", function(self)
      local checked = self:GetChecked();
      if checked then
        options.blacklist[btnData.name] = nil;
        Main.collectMinimapButtonsAndUpdateLayout();
      else
        options.blacklist[btnData.name] = true;
        Utils.printReloadMessage(string.format('Button "%s" is now being ignored.', btnData.name));
      end
      UpdateList();
    end);

    row:Show();
  end

  local totalHeight = #buttons * rowHeight;
  scrollChild:SetHeight(totalHeight > 0 and totalHeight or 1);
end

local function CreateSelectorFrame()
  if frame then return frame; end

  frame = CreateFrame("Frame", addonName .. "SelectorFrame", UIParent,
    _G.BackdropTemplateMixin and "BackdropTemplate");
  frame:SetSize(320, 420);
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
  frame:SetFrameStrata("HIGH");
  frame:SetFrameLevel(10);
  frame:SetMovable(true);
  frame:EnableMouse(true);
  frame:RegisterForDrag("LeftButton");
  frame:SetScript("OnDragStart", frame.StartMoving);
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing);

  local edgeInset = 4;
  frame:SetBackdrop({
    bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
    edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
    edgeSize = 16,
    insets = {
      left = edgeInset,
      right = edgeInset,
      top = edgeInset,
      bottom = edgeInset,
    },
  });
  frame:SetBackdropColor(0.08, 0.08, 0.1, 0.95);
  local r, g, b = Utils.getPlayerColor();
  frame:SetBackdropBorderColor(r, g, b, 0.8);

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  title:SetPoint("TOP", frame, "TOP", 0, -16);
  title:SetText("Minimap Buttons");
  title:SetTextColor(1, 1, 1);

  local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
  closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4);
  closeBtn:SetScript("OnClick", function()
    frame:Hide();
  end);

  local listBg = CreateFrame("Frame", nil, frame, _G.BackdropTemplateMixin and "BackdropTemplate");
  listBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -45);
  listBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 65);
  listBg:SetBackdrop({
    bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
    edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  });
  listBg:SetBackdropColor(0.04, 0.04, 0.05, 0.6);
  listBg:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5);

  scrollFrame = CreateFrame("ScrollFrame", addonName .. "SelectorScrollFrame", listBg, "UIPanelScrollFrameTemplate");
  scrollFrame:SetPoint("TOPLEFT", listBg, "TOPLEFT", 6, -6);
  scrollFrame:SetPoint("BOTTOMRIGHT", listBg, "BOTTOMRIGHT", -26, 6);

  scrollChild = CreateFrame("Frame", nil, scrollFrame);
  scrollChild:SetSize(260, 1);
  scrollFrame:SetScrollChild(scrollChild);

  local reloadBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate");
  reloadBtn:SetSize(140, 30);
  reloadBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15);
  reloadBtn:SetText("Reload UI");
  reloadBtn:SetScript("OnClick", function()
    ReloadUI();
  end);
  frame.reloadBtn = reloadBtn;

  local warning = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  warning:SetPoint("BOTTOM", reloadBtn, "TOP", 0, 6);
  warning:SetText("* Reload required to exclude buttons.");
  warning:SetTextColor(1, 0.3, 0.3);
  frame.warningText = warning;

  frame:Hide();
  return frame;
end

local function InitializeInitialBlacklist()
  if next(initialBlacklist) == nil then
    local options = Options.getAll();
    initialBlacklist = cloneTable(options.blacklist);
  end
end

function ButtonSelector.ToggleWindow()
  local f = CreateSelectorFrame();
  if f:IsShown() then
    f:Hide();
  else
    InitializeInitialBlacklist();
    f:Show();
    UpdateList();
  end
end
