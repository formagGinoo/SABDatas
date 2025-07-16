local Form_ActivityDayTaskChoose = class("Form_ActivityDayTaskChoose", require("UI/UIFrames/Form_ActivityDayTaskChooseUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function Form_ActivityDayTaskChoose:SetInitParam(param)
end

function Form_ActivityDayTaskChoose:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_infoItemList = {}
  self.m_infoItemList[#self.m_infoItemList + 1] = self.m_character_01
  self.m_infoItemList[#self.m_infoItemList + 1] = self.m_character_02
  self.m_infoItemList[#self.m_infoItemList + 1] = self.m_character_03
  self.m_infoItemList[#self.m_infoItemList + 1] = self.m_character_04
  self.m_infoItemList[#self.m_infoItemList + 1] = self.m_character_05
  self.m_ui_common_btn_light_a_Button.onClick:RemoveAllListeners()
  self.m_ui_common_btn_light_a_Button.onClick:AddListener(handler(self, self.OnBtnuicommonbtnlighta))
  self:addEventListener("eGameEvent_Activity_LoginSelectReward", handler(self, self.OnLoginSelectReward))
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_ActivityDayTaskChoose:OnLoginSelectReward()
  self:RefreshUI()
end

function Form_ActivityDayTaskChoose:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
end

function Form_ActivityDayTaskChoose:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityDayTaskChoose:OnUpdate(dt)
  self.m_dt = self.m_dt + dt
  if self.m_dt >= 1 then
    self.m_dt = 0
    self:RefreshRemainTime()
  end
end

function Form_ActivityDayTaskChoose:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityDayTaskChoose:RefreshUI()
  self.m_dt = 0
  self.m_stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_LoginSelect)
  if self.m_stActivity == nil then
    self:CloseForm()
    return
  end
  self.m_stActivityStatus = self.m_stActivity:getStatusData()
  local iNeedLoginDay = self.m_stActivity:getConfigParamIntValue("iNeedLogin")
  local str = ConfigManager:GetCommonTextById(100039)
  self.m_txt_days_descrption_Text.text = string.format(str, iNeedLoginDay)
  self:RefreshReceivePanel()
  self:RefreshRemainTime()
  self:RefreshRewardPanel()
  self:RefreshGetPanel()
  self:SelectIndex(self.m_stActivityStatus.iSelectIndex == 0 and 1 or self.m_stActivityStatus.iSelectIndex)
end

function Form_ActivityDayTaskChoose:RefreshGetPanel()
  if self.m_stActivityStatus.iSelectIndex > 0 then
    self["m_bg_get_" .. string.format("%02d", self.m_stActivityStatus.iSelectIndex)]:SetActive(true)
  end
end

function Form_ActivityDayTaskChoose:RefreshRewardPanel()
  local infoList = self.m_stActivity:GetInfoList()
  self.m_infoList = infoList
  for k, v in ipairs(self.m_infoItemList) do
    v:SetActive(false)
  end
  for k, v in ipairs(infoList) do
    local item = self.m_infoItemList[k]
    if item then
      item:SetActive(true)
      UILuaHelper.SetAtlasSprite(self["m_imagePortrait_" .. string.format("%02d", k) .. "_Image"], v.sRewardPicture)
    end
  end
end

function Form_ActivityDayTaskChoose:SelectIndex(index)
  if index == self.m_lastSelectIndex then
    if self.m_curShowSpine == nil then
      local heroCfg = CharacterInfoIns:GetValue_ByHeroID(self.m_infoList[index].heroID)
      self:ShowHeroSpine(heroCfg.m_Spine)
    end
    return
  end
  if self.m_lastSelectIndex then
    self["m_bg_pick_" .. string.format("%02d", self.m_lastSelectIndex)]:SetActive(false)
  end
  self.m_lastSelectIndex = index
  self["m_bg_pick_" .. string.format("%02d", index)]:SetActive(true)
  local heroCfg = CharacterInfoIns:GetValue_ByHeroID(self.m_infoList[index].heroID)
  self:ShowHeroSpine(heroCfg.m_Spine)
end

function Form_ActivityDayTaskChoose:OnBtnuicommonbtnlighta()
  self.m_stActivity:RequestGetReward(self.m_lastSelectIndex)
end

function Form_ActivityDayTaskChoose:OnBtncharacter01Clicked()
  if self.m_stActivityStatus.iSelectIndex > 0 then
    return
  end
  self:SelectIndex(1)
end

function Form_ActivityDayTaskChoose:OnBtncharacter01Clicked()
  self:SelectIndex(1)
end

function Form_ActivityDayTaskChoose:OnBtncharacter02Clicked()
  self:SelectIndex(2)
end

function Form_ActivityDayTaskChoose:OnBtncharacter03Clicked()
  self:SelectIndex(3)
end

function Form_ActivityDayTaskChoose:OnBtncharacter04Clicked()
  self:SelectIndex(4)
end

function Form_ActivityDayTaskChoose:OnBtncharacter05Clicked()
  self:SelectIndex(5)
end

function Form_ActivityDayTaskChoose:OnBtnherocheckClicked()
  utils.openItemDetailPop({
    iID = self.m_infoList[self.m_lastSelectIndex].heroID,
    iNum = 1
  })
end

function Form_ActivityDayTaskChoose:RefreshReceivePanel()
  local iCurLoginDay = self.m_stActivityStatus.iLoginNum
  local iNeedLoginDay = self.m_stActivity:getConfigParamIntValue("iNeedLogin")
  if iCurLoginDay >= iNeedLoginDay then
    self.m_txt_receive_descrption:SetActive(false)
    if self.m_stActivityStatus.iSelectIndex == 0 then
      self.m_panel_ui_common_btn_light_a:SetActive(true)
      self.m_panel_ui_common_btn_gray:SetActive(false)
      self.m_panel_ui_common_btn_got:SetActive(false)
    else
      self.m_panel_ui_common_btn_light_a:SetActive(false)
      self.m_panel_ui_common_btn_gray:SetActive(false)
      self.m_panel_ui_common_btn_got:SetActive(true)
    end
  else
    self.m_txt_receive_descrption:SetActive(true)
    local str = ConfigManager:GetCommonTextById(100038)
    str = string.format(str, iCurLoginDay .. "/" .. iNeedLoginDay)
    self.m_txt_receive_descrption_Text.text = str
    self.m_panel_ui_common_btn_light_a:SetActive(false)
    self.m_panel_ui_common_btn_gray:SetActive(true)
    self.m_panel_ui_common_btn_got:SetActive(false)
  end
end

function Form_ActivityDayTaskChoose:RefreshRemainTime()
  self.m_txt_countdown_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_stActivity:getActivityRemainTime())
end

function Form_ActivityDayTaskChoose:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  if self.m_curHeroSpineObj then
    self:RecycleSpineObj()
  end
  local typeStr = SpinePlaceCfg.HeroDetail
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(heroSpineObj)
    self:RecycleSpineObj()
    self.m_curHeroSpineObj = heroSpineObj
  end)
end

function Form_ActivityDayTaskChoose:RecycleSpineObj()
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  if not self.m_curHeroSpineObj then
    return
  end
  UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
  self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
  self.m_curHeroSpineObj = nil
end

function Form_ActivityDayTaskChoose:OnBackClk()
  self:RecycleSpineObj()
  self.m_curShowSpine = nil
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_ActivityDayTaskChoose", Form_ActivityDayTaskChoose)
return Form_ActivityDayTaskChoose
