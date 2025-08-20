local UIHeroActSignBase = class("UIHeroActShopBase", require("UI/Common/UIBase"))
local fLockTime = 0.6

function UIHeroActSignBase:AfterInit()
  UIHeroActSignBase.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(self.goBackBtnRoot, handler(self, self.OnBackClk))
  local initGridData = {
    itemClkBackFun = handler(self, self.OnSignItemClick)
  }
  self.m_luaSignItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "HeroActivity/UIActSignItem", initGridData)
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.fDelayShowItemListAnim = 0.1
  self.fDelayShowItem = 0.1
end

function UIHeroActSignBase:OnActive()
  UIHeroActSignBase.super.OnActive(self)
  self.act_id = self.m_csui.m_param.main_id
  self.sub_id = self.m_csui.m_param.sub_id
  if self.m_btn_close then
    self.m_btn_close:SetActive(self.m_csui.m_param.is_pushFace)
  end
  self.goBackBtnRoot:SetActive(not self.m_csui.m_param.is_pushFace)
  if not utils.isNull(self.m_common_click) then
    self.m_common_click:SetActive(self.m_csui.m_param.is_pushFace)
  end
  self:RemoveEventListeners()
  self:BindEventListeners()
  self:FreshUI()
  local cfg = HeroActivityManager:GetMainInfoByActID(self.act_id)
  if cfg and cfg.m_SigninSpine and cfg.m_SigninSpine ~= "" then
    self.m_signinSpineName = cfg.m_SigninSpine
    self:LoadShowSpine()
  else
    self.m_signinSpineName = nil
  end
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
  self:CheckRecycleSpine(true)
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
    self.lockId = UILockIns:Lock(fLockTime)
    TimeService:SetTimer(fLockTime, 1, function()
      if HeroActivityManager:GetHeroActSignHaveRedFlag(self.act_id) then
        HeroActivityManager:RequestRecReward(self.act_id)
      end
    end)
  end
end

function UIHeroActSignBase:CheckShowEnterAnim()
  TimeService:SetTimer(self.fDelayShowItemListAnim, 1, function()
    self:ShowItemListAnim()
  end)
end

function UIHeroActSignBase:ShowItemListAnim()
  if utils.isNull(self.m_luaSignItemInfinityGrid) then
    return
  end
  if utils.isNull(self.m_reward_list) then
    return
  end
  self.m_reward_list:SetActive(true)
  local showItemList = self.m_luaSignItemInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    tempItem:SetActive(false)
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer((i - 1) * self.fDelayShowItem, 1, function()
      if utils.isNull(tempObj) then
        return
      end
      tempItem:SetActive(true)
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

function UIHeroActSignBase:LoadShowSpine()
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  if not self.m_signinSpineName then
    return
  end
  self:CheckRecycleSpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(self.m_signinSpineName, function(nameStr, object)
    self:CheckRecycleSpine()
    UILuaHelper.SetParent(object, self.m_root_hero, true)
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SpineResetMatParam(object)
    self.m_curHeroSpineObj = object
  end)
end

function UIHeroActSignBase:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end
    if not self.m_signinSpineName then
      self.m_curHeroSpineObj = nil
      return
    end
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(self.m_signinSpineName, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
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
  self:CheckRecycleSpine(true)
end

function UIHeroActSignBase:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local str
  if tParam then
    local iActId = tParam.main_id
    local cfg = HeroActivityManager:GetMainInfoByActID(iActId)
    if cfg and cfg.m_SigninSpine and cfg.m_SigninSpine ~= "" then
      str = cfg.m_SigninSpine
    end
  end
  if str then
    vResourceExtra[#vResourceExtra + 1] = {
      sName = str,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

return UIHeroActSignBase
