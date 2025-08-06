local PackGiftPoint = class("PackGiftPoint")
local ItemIns = ConfigManager:GetConfigInsByName("Item")

function PackGiftPoint:ctor(goRoot, params)
  self.m_goRoot = goRoot
  self.m_goRootTrans = self.m_goRoot.transform
  self.m_btn_tips = self.m_goRootTrans:Find("c_btn_rule"):GetComponent(T_Button)
  self.m_pnl_icon = self.m_goRootTrans:Find("c_btn_rule/pnl_icon")
  if self.m_pnl_icon then
    self.m_point_icon_Image = self.m_pnl_icon.transform:Find("c_point_icon"):GetComponent(T_Image)
  end
  self.m_txt_num = self.m_goRootTrans:Find("c_btn_rule/c_txt_num")
  if self.m_txt_num then
    self.m_txt_num_Text = self.m_txt_num:GetComponent(T_TextMeshProUGUI)
  end
  self.m_pnl_Tips = self.m_goRootTrans:Find("c_btn_rule/c_pnl_rule")
  self:FreshUI(params)
end

function PackGiftPoint:FreshUI(params)
  if not params then
    log.error("PackGiftPoint:FreshUI params  error")
    return
  end
  local itemId
  local itemNum = 0
  local isShowTips = params.isShowTips or false
  if params.pointReward and params.pointReward.iNum then
    itemNum = params.pointReward.iNum
  end
  if params.pointReward and params.pointReward.iID then
    itemId = params.pointReward.iID
  end
  if not itemId or itemNum == 0 then
    if utils.isNull(self.m_goRoot) then
      UILuaHelper.SetActive(self.m_goRoot, false)
    end
    log.error("PackGiftPoint:FreshUI params iD error")
    return
  end
  if not utils.isNull(self.m_pnl_Tips) and not utils.isNull(self.m_btn_tips) then
    local tipsId
    UILuaHelper.SetActive(self.m_pnl_Tips, false)
    local act = ActivityManager:GetActivityByType(MTTD.ActivityType_ConsumeReward)
    if act and act:checkCondition() then
      tipsId = act:GetTipsId()
    end
    if isShowTips and tipsId then
      UILuaHelper.SetActive(self.m_pnl_Tips, true)
      UILuaHelper.BindButtonClickManual(self, self.m_btn_tips, function()
        utils.popUpDirectionsUI({tipsID = tipsId})
      end)
    end
  end
  if not utils.isNull(self.m_point_icon_Image) and itemId then
    local itemCfg = ItemIns:GetValue_ByItemID(itemId)
    if not itemCfg:GetError() then
      UILuaHelper.SetAtlasSprite(self.m_point_icon_Image, "Atlas_Item/" .. itemCfg.m_IconPath)
      if not utils.isNull(self.m_txt_num_Text) and itemNum then
        local itemName = itemCfg.m_mItemName
        self.m_txt_num_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(220023), tostring(itemName), tostring(itemNum))
      end
    end
  end
  UILuaHelper.BindButtonClickManual(self, self.m_btn_tips, function()
    local act = ActivityManager:GetActivityByType(MTTD.ActivityType_ConsumeReward)
    if act and act:checkCondition() then
      local id = act:GetPointItemId()
      local iNum = act:GetCurPoint()
      utils.openItemDetailPop({iID = id, iNum = iNum})
    end
  end)
end

function PackGiftPoint:SetFreshInfo(itemId, point)
  self:FreshUI(itemId, point)
end

function PackGiftPoint:GetRootTrans()
  return self.m_goRoot.transform
end

function PackGiftPoint:OnDestroy()
end

return PackGiftPoint
