local _, addon = ...;

local GameTooltip = _G.GameTooltip;

local function displayText (text)
  GameTooltip:ClearLines();

  if (type(text) == "table") then
    for _, line in ipairs(text) do
      GameTooltip:AddLine(line);
    end
  else
    GameTooltip:AddLine(text);
  end
end

local function hideGameTooltip ()
  GameTooltip:Hide();
end

local function createTooltip (parent)
  parent:HookScript('OnEnter', function ()
    GameTooltip:SetOwner(parent, 'ANCHOR_NONE');
    GameTooltip:ClearAllPoints();
    GameTooltip:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 0, 0);
    displayText(parent.text);
    GameTooltip:Show();
  end);

  parent:HookScript('OnLeave', hideGameTooltip);
end

addon.createTooltip = function (parent, text)
  parent.text = text;
  createTooltip(parent);
end
