local Form_HallBackground = class("Form_HallBackground", require("UI/UIFrames/Form_HallBackgroundUI"))

function Form_HallBackground:SetInitParam(param)
end

function Form_HallBackground:AfterInit()
  self.super.AfterInit(self)
  self.m_curShowPosData = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_HeroFashion = HeroManager:GetHeroFashion()
end

function Form_HallBackground:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_HallBackground:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
  if self.m_curMaxWaitTimer then
    TimeService:KillTimer(self.m_curMaxWaitTimer)
    self.m_curMaxWaitTimer = nil
  end
end

function Form_HallBackground:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
  if self.m_curMaxWaitTimer then
    TimeService:KillTimer(self.m_curMaxWaitTimer)
    self.m_curMaxWaitTimer = nil
  end
end

function Form_HallBackground:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_csui.m_param = nil
  end
  local serverIndex = RoleManager:GetMainBackGroundIndex()
  local heroPosData = RoleManager:GetMainBackGroundDataList()
  local tempServerData = heroPosData[serverIndex]
  self.m_curShowPosData = tempServerData
end

function Form_HallBackground:ClearCacheData()
end

function Form_HallBackground:AddEventListeners()
end

function Form_HallBackground:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HallBackground:FreshUI()
  if self.m_curShowPosData == nil or self.m_curShowPosData.iType ~= RoleManager.MainBgType.Fashion then
    self:CloseFormAndGoHall()
    return
  end
  if self.m_curMaxWaitTimer then
    TimeService:KillTimer(self.m_curMaxWaitTimer)
    self.m_curMaxWaitTimer = nil
  end
  self.m_curMaxWaitTimer = TimeService:SetTimer(self.m_uiVariables.MaxWaitTime, 1, function()
    self.m_curMaxWaitTimer = nil
    self:CloseFormAndGoHall()
  end)
  UILuaHelper.SetActive(self.m_Skip, false)
  UILuaHelper.SetActive(self.m_btnClose, true)
  local tempFashionInfo = self.m_HeroFashion:GetFashionInfoByID(self.m_curShowPosData.iId)
  if tempFashionInfo then
    self:ShowHeroSpine(tempFashionInfo.m_Spine)
  end
end

function Form_HallBackground:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HallBackground:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.MainShow
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function Form_HallBackground:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spinePlaceObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spinePlaceObj, true)
  local spineRootObj = self.m_curHeroSpineObj.spineObj
  UILuaHelper.SpineResetMatParam(spineRootObj)
  UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
  UILuaHelper.SpinePlayAnimWithBack(spineRootObj, 0, "chuchang2", false, false, function()
    self:CloseFormAndGoHall()
  end)
end

function Form_HallBackground:CloseFormAndGoHall()
  if self.m_curHeroSpineObj then
    UILuaHelper.SpineClearAnimPlayBack(self.m_curHeroSpineObj.spineObj)
  end
  self:CloseForm()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
end

function Form_HallBackground:OnBtnCloseClicked()
  UILuaHelper.SetActive(self.m_Skip, true)
  UILuaHelper.SetActive(self.m_btnClose, false)
  if self.m_curMaxWaitTimer then
    TimeService:KillTimer(self.m_curMaxWaitTimer)
    self.m_curMaxWaitTimer = nil
  end
end

function Form_HallBackground:OnSkipClicked()
  self:CloseFormAndGoHall()
end

local fullscreen = true
ActiveLuaUI("Form_HallBackground", Form_HallBackground)
return Form_HallBackground
