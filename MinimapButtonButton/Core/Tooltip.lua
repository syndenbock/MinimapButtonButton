local _, addon = ...;

local module = addon.export('Core/Tooltip', {});

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

function module.createTooltip (parent, text)
  parent:SetScript('OnEnter', function ()
    GameTooltip:SetOwner(parent, 'ANCHOR_NONE');
    GameTooltip:ClearAllPoints();
    GameTooltip:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 0, 0);
    displayText(text);
    GameTooltip:Show();
  end);

  parent:SetScript('OnLeave', hideGameTooltip);
  parent.hasTooltip = true;
end

function module.removeTooltip (parent)
  parent:SetScript('OnEnter', nil);
  parent:SetScript('OnLeave', nil);
  parent.hasTooltip = nil;
end
