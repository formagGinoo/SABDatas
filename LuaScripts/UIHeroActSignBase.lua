local UIHeroActSignBase = class("UIHeroActShopBase", require("UI/Common/UIBase"))

function UIHeroActSignBase:AfterInit()
  UIHeroActSignBase.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(self.goBackBtnRoot, handler(self, self.OnBackClk))
  local initGridData = {
    itemClkBackFun = handler(self, self.OnSignItemClick)
  }
  self.m_luaSignItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "HeroActivity/UIActSignItem", initGridData)
end

function UIHeroActSignBase:OnActive()
  UIHeroActSignBase.super.OnActive(self)
  self.act_id = self.m_csui.m_param.main_id
  self.sub_id = self.m_csui.m_param.sub_id
  if self.m_btn_close then
    self.m_btn_close:SetActive(self.m_csui.m_param.is_pushFace)
  end
  self.goBackBtnRoot:SetActive(not self.m_csui.m_param.is_pushFace)
  self:RemoveEventListeners()
  self:BindEventListeners()
  self:FreshUI()
end

function UIHeroActSignBase:OnInactive()
  UIHeroActSignBase.super.OnInactive(self)
  self:RemoveEventListeners()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  if self.m_itemInitShowNum then
    for i = 1, self.m_itemInitShowNum do
      if self["ItemInitTimer" .. i] then
        TimeService:KillTimer(self["ItemInitTimer" .. i])
        self["ItemInitTimer" .. i] = nil
      end
    end
  end
  PushFaceManager:CheckShowNextPopPanel()
end

function UIHeroActSignBase:RemoveEventListeners()
  self:clearEventListener()
end

function UIHeroActSignBase:BindEventListeners()
  self:addEventListener("eGameEvent_ActSign_GetReward", handler(self, self.OnEventGetReward))
  self:addEventListener("eGameEvent_HeroAct_DailyReset", handler(self, self.FreshUI))
end

function UIHeroActSignBase:OnEventGetReward(iAwardedMaxDays)
  for i = 1, iAwardedMaxDays do
    self.m_luaSignItemInfinityGrid:ReBind(i)
  end
end

function UIHeroActSignBase:FreshUI()
  local sub_config = HeroActivityManager:GetSubInfoByID(self.sub_id)
  local curTimer = TimeUtil:GetServerTimeS()
  local endTime = TimeUtil:TimeStringToTimeSec2(sub_config.m_EndTime) or 0
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, self.sub_id)
  if is_corved then
    endTime = t2
  end
  local left_time = endTime - curTimer
  self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  if self.timer then
    TimeService:KillTimer(self.timer)
  end
  self.timer = TimeService:SetTimer(1, -1, function()
    left_time = left_time - 1
    if left_time <= 0 then
      TimeService:KillTimer(self.timer)
      self:CloseForm()
    end
    self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatCNStr(left_time)
  end)
  local sign_configs = HeroActivityManager:GetActSignConfigByID(self.sub_id)
  local act_data = HeroActivityManager:GetHeroActData(self.act_id)
  self.sign_data = {}
  for k, v in pairs(sign_configs) do
    if v.m_Day and v.m_Day > 0 then
      self.sign_data[v.m_Day] = {
        config = v,
        server_data = act_data.server_data.stSign
      }
    end
  end
  self:FreshSignItemList(act_data.server_data.stSign.iAwardedMaxDays)
  if self.m_csui.m_param.is_pushFace and HeroActivityManager:GetHeroActSignHaveRedFlag(self.act_id) then
    HeroActivityManager:RequestRecReward(self.act_id)
  end
end

function UIHeroActSignBase:CheckShowEnterAnim()
  local showItemList = self.m_luaSignItemInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(0.1, 1, function()
    self:ShowItemListAnim()
  end)
end

function UIHeroActSignBase:ShowItemListAnim()
  local showItemList = self.m_luaSignItemInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    tempObj:SetActive(false)
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer(i * 0.1, 1, function()
      tempObj:SetActive(true)
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
    end)
  end
end

function UIHeroActSignBase:FreshSignItemList(iAwardedMaxDays)
  self.m_luaSignItemInfinityGrid:ShowItemList(self.sign_data)
  local index = iAwardedMaxDays and 0 < iAwardedMaxDays and iAwardedMaxDays - 1 or 0
  self.m_luaSignItemInfinityGrid:LocateTo(index)
end

function UIHeroActSignBase:OnSignItemClick(index, go)
  local server_data = self.sign_data[index].server_data
  local can_get = server_data.iAwardedMaxDays < server_data.iLoginDays and index <= server_data.iLoginDays
  if can_get then
    HeroActivityManager:RequestRecReward(self.act_id)
    return
  end
end

function UIHeroActSignBase:OnBackClk()
  self:CloseForm()
end

function UIHeroActSignBase:OnBtncloseClicked()
  self:CloseForm()
end

function UIHeroActSignBase:OnBgblackClicked()
  self:CloseForm()
end

function UIHeroActSignBase:OnDestroy()
  UIHeroActSignBase.super.OnDestroy(self)
  if self.m_luaSignItemInfinityGrid then
    self.m_luaSignItemInfinityGrid:dispose()
    self.m_luaSignItemInfinityGrid = nil
  end
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

return UIHeroActSignBase
