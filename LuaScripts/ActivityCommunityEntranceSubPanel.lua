local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivityCommunityEntranceSubPanel = class("ActivityCommunityEntranceSubPanel", UISubPanelBase)

function ActivityCommunityEntranceSubPanel:OnInit()
  self.m_stActivity = nil
  self.m_stActivityInfoList = nil
  self.m_scrollView_InfinityGrid:RegisterBindCallback(handler(self, self.OnIconItemBind))
end

function ActivityCommunityEntranceSubPanel:OnFreshData()
  local activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if not self.m_stActivity then
    return
  end
  self:RefreshUI()
end

function ActivityCommunityEntranceSubPanel:RefreshUI()
  self.m_stActivity = self.m_panelData.activity
  if self.m_stActivity == nil then
    return
  end
  self.m_stActivityInfoList = self.m_stActivity:GetCommunityCfg()
  if not self.m_stActivityInfoList then
    return
  end
  table.sort(self.m_stActivityInfoList, function(a, b)
    return a.iWeight > b.iWeight
  end)
  self:RefreshContent()
end

function ActivityCommunityEntranceSubPanel:RefreshContent()
  self.m_scrollView_InfinityGrid:Clear()
  self.m_scrollView_InfinityGrid.TotalItemCount = #self.m_stActivityInfoList
end

function ActivityCommunityEntranceSubPanel:OnIconItemBind(templateCache, gameObject, index)
  local itemIndex = index + 1
  gameObject.name = itemIndex
  if not itemIndex then
    return
  end
  local showItem = self.m_stActivityInfoList[itemIndex]
  if showItem then
    local iconImg = templateCache:GameObject("c_img_icon"):GetComponent("Image")
    UILuaHelper.SetAtlasSprite(iconImg, showItem.sJumpPic)
    templateCache:TMPPro("c_txt_name").text = showItem.sButtonName
    templateCache:TMPPro("c_txt_click").text = showItem.sJumpContent
    local btn = templateCache:GetComponent("Button")
    if btn then
      btn.onClick:RemoveAllListeners()
      btn.onClick:AddListener(function()
        local urlString = showItem.sJumpUrl
        CS.DeviceUtil.OpenURLNew(urlString)
      end)
    end
  end
end

return ActivityCommunityEntranceSubPanel
