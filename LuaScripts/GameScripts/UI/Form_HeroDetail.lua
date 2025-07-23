local Form_HeroDetail = class("Form_HeroDetail", require("UI/UIFrames/Form_HeroDetailUI"))
local SubPanelManager = _ENV.SubPanelManager
local DragLimitNum = 200
local DefaultChooseTab = 1
local HeroTagCfg = {
  Base = 1,
  Equip = 3,
  Skill = 4,
  Legacy = 5
}
local TagCfg = {
  [HeroTagCfg.Base] = {explainID = 1101},
  [HeroTagCfg.Skill] = {explainID = 1112},
  [HeroTagCfg.Equip] = {explainID = 1109},
  [HeroTagCfg.Legacy] = {explainID = 1116}
}
local ShowTabHeroPos = {
  [HeroTagCfg.Base] = {
    isTransParent = false,
    isStopSpineAnim = false,
    isMaskAndGray = false,
    position = {
      -300,
      0,
      0
    },
    scale = {
      1,
      1,
      1
    },
    posTime = 0.01,
    scaleTime = 0.1,
    posTween = nil,
    scaleTween = nil
  },
  [HeroTagCfg.Skill] = {
    isTransParent = false,
    isStopSpineAnim = true,
    isMaskAndGray = true,
    position = {
      -300,
      0,
      0
    },
    scale = {
      1,
      1,
      1
    },
    posTime = 0.01,
    scaleTime = 0.1,
    posTween = nil,
    scaleTween = nil
  },
  [HeroTagCfg.Equip] = {
    isTransParent = false,
    isStopSpineAnim = false,
    isMaskAndGray = false,
    position = {
      0,
      -123,
      0
    },
    scale = {
      1,
      1,
      1
    },
    posTime = 0.01,
    scaleTime = 0.1,
    posTween = nil,
    scaleTween = nil
  },
  [HeroTagCfg.Legacy] = {
    isTransParent = true,
    isStopSpineAnim = true,
    isMaskAndGray = false,
    position = {
      0,
      100,
      0
    },
    scale = {
      1,
      1,
      1
    },
    posTime = 0.01,
    scaleTime = 0.1,
    posTween = nil,
    scaleTween = nil
  }
}
local MaxDragDeltaNum = 800
local NameCardShowAnim = "namecard_in"
local idleAnimStr = "idle"
local touchAnimStr = "touch"
local EnterAnimStr = "hero_detail_in"
local actions = {idleAnimStr, touchAnimStr}
local heroVoiceDuring = "CharacterIdleVoicesRange"
local GlobalCfgIns = ConfigManager:GetConfigInsByName("GlobalSettings")

function Form_HeroDetail:SetInitParam(param)
end

function Form_HeroDetail:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/panel_detail_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1101)
  self.m_subPanelData = {
    [HeroTagCfg.Base] = {
      panelRoot = self.m_base_panel_root,
      nodeSelect = self.m_tab_base_select,
      nodeUnSelect = self.m_tab_base_unselect,
      subPanelName = "HeroBaseSubPanel",
      subPanelLua = nil,
      backFun = function()
        self:OnBaseSkillClk()
      end
    },
    [HeroTagCfg.Equip] = {
      panelRoot = self.m_equipment_panel_root,
      nodeSelect = self.m_tab_equip_select,
      nodeUnSelect = self.m_tab_equip_unselect,
      subPanelName = "HeroEquipSubPanel",
      subPanelLua = nil,
      backFun = function()
        self:OnBaseEquipClk()
      end
    },
    [HeroTagCfg.Skill] = {
      panelRoot = self.m_skill_panel_root,
      nodeSelect = self.m_tab_skill_select,
      nodeUnSelect = self.m_tab_skill_unselect,
      subPanelName = "HeroSkillSubPanel",
      subPanelLua = nil,
      backFun = nil
    },
    [HeroTagCfg.Legacy] = {
      panelRoot = self.m_legacy_panel_root,
      nodeSelect = self.m_tab_legacy_select,
      nodeUnSelect = self.m_tab_legacy_unselect,
      subPanelName = "HeroLegacySubPanel",
      subPanelLua = nil,
      backFun = nil
    }
  }
  self.m_root_hero_BtnEx = self.m_root_hero:GetComponent("ButtonExtensions")
  if self.m_root_hero_BtnEx then
    self.m_root_hero_BtnEx.BeginDrag = handler(self, self.OnImgBeginDrag)
    self.m_root_hero_BtnEx.Drag = handler(self, self.OnImgDrag)
    self.m_root_hero_BtnEx.EndDrag = handler(self, self.OnImgEndBDrag)
  end
  self.m_pnl_attract_touch_exp:SetActive(false)
  self.m_iAttractTouchReward = tonumber(GlobalCfgIns:GetValue_ByName("AttractTouchReward").m_Value)
  self.m_iAttractTouchLimit = tonumber(GlobalCfgIns:GetValue_ByName("AttractTouchLimit").m_Value)
  self.m_totalTouchCount = 0
  self.m_totalExp = 0
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
  self.m_curChooseHeroIndex = nil
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_curChooseTab = HeroTagCfg.Base
  self.m_curHeroSpineObj = nil
  self.m_isJustOne = false
  self.m_dragTween = nil
  self.m_dragTimer = nil
  self.m_dragEndTimer = nil
  local during = GlobalCfgIns:GetValue_ByName(heroVoiceDuring).m_Value
  self.duringHeroVoice = string.split(during, ";")
  self.voiceLimit = tonumber(self.duringHeroVoice[1]) or 0
  self.voiceUpper = tonumber(self.duringHeroVoice[2]) or 0
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_HeroFashion = HeroManager:GetHeroFashion()
end

function Form_HeroDetail:OnOpen()
  self:FreshData()
  self:FreshUI()
  self:CheckShowEnterAnim()
end

function Form_HeroDetail:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  if self.m_curShowHeroData then
    local heroCfg = self.m_curShowHeroData.characterCfg
    if heroCfg.m_HeroID == 0 then
      return
    end
    self:StopCurDisPlayPlayingVoice()
    self:PlayHeroDisPlayVoice()
  end
end

function Form_HeroDetail:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleCurSpine(true)
  self.m_doActive = false
  self:RemoveAllEventListeners()
  self:ClearData()
  self:PlayTouchDisappearAnimation()
  if self.m_spineClick then
    self.m_spineClick:DestroyFollowerList()
  end
  self:StopCurDisPlayPlayingVoice()
  self:KillVoiceTimer()
end

function Form_HeroDetail:OnUncoverd()
  local heroTabNum = self.m_curChooseTab or DefaultChooseTab
  TimeService:SetTimer(0.06, 1, function()
    self:FreshUI(heroTabNum)
  end)
end

function Form_HeroDetail:OnUpdate(dt)
  for i, v in pairs(self.m_subPanelData) do
    if v.subPanelLua and v.subPanelLua.OnUpdate then
      v.subPanelLua:OnUpdate(dt)
    end
  end
end

function Form_HeroDetail:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleCurSpine(true)
  for i, panelData in pairs(self.m_subPanelData) do
    if panelData.subPanelLua ~= nil then
      panelData.subPanelLua:dispose()
      panelData.subPanelLua = nil
    end
  end
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  if self.m_dragEndTimer then
    TimeService:KillTimer(self.m_dragEndTimer)
    self.m_dragEndTimer = nil
  end
end

function Form_HeroDetail:AddEventListeners()
  self:addEventListener("eGameEvent_Equip_InstallEquip", handler(self, self.OnEventRefreshPower))
  self:addEventListener("eGameEvent_Equip_UnInstallEquip", handler(self, self.OnEventRefreshPower))
  self:addEventListener("eGameEvent_Hero_SetHeroData", handler(self, self.OnSetHeroData))
  self:addEventListener("eGameEvent_Hero_SetHeroDataList", handler(self, self.OnSetHeroDataList))
  self:addEventListener("eGameEvent_Hero_EnterUpgrade", handler(self, self.OnShowHeroUpgrade))
  self:addEventListener("eGameEvent_Hero_RefreshSpine", handler(self, self.OnRefreshHeroSpine))
  self:addEventListener("eGameEvent_Hero_Jump", handler(self, self.OnBackClk))
end

function Form_HeroDetail:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroDetail:OnSetHeroData(param)
  if not param then
    return
  end
  local heroServerData = param.heroServerData
  if heroServerData.iHeroId == self.m_curShowHeroData.serverData.iHeroId then
    self:OnEventRefreshPower()
    self:FreshCurTabSubPanelInfo(true)
  end
end

function Form_HeroDetail:OnSetHeroDataList(heroServerDataList)
  if not heroServerDataList then
    return
  end
  for i, v in ipairs(heroServerDataList) do
    if v.iHeroId == self.m_curShowHeroData.serverData.iHeroId then
      self:OnEventRefreshPower()
      self:FreshCurTabSubPanelInfo(true)
    end
  end
end

function Form_HeroDetail:OnShowHeroUpgrade(param)
  if not param then
    return
  end
  local showHeroList = self:FilterInheritHero(param.heroDataList)
  local heroID = param.heroDataList[param.chooseHeroIndex].serverData.iHeroId
  StackFlow:Push(UIDefines.ID_FORM_HEROUPGRADE, {
    heroDataList = showHeroList,
    heroID = heroID,
    closeBackFun = function(backHeroID)
      self:OnUpgradeCloseBack(backHeroID)
    end
  })
end

function Form_HeroDetail:ClearData()
end

function Form_HeroDetail:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_allHeroList = tParam.heroDataList
    self.m_curChooseHeroIndex = tParam.chooseHeroIndex
    self.m_curShowHeroData = self.m_allHeroList[self.m_curChooseHeroIndex]
    self.m_isJustOne = tParam.isJustOne
    self.m_inheritLvUp = tParam.inheritLvUp
    self.m_csui.m_param = nil
  end
end

function Form_HeroDetail:GetAllHeroIndex(heroID)
  if not heroID then
    return
  end
  for i, v in ipairs(self.m_allHeroList) do
    if v.serverData.iHeroId == heroID then
      return i
    end
  end
end

function Form_HeroDetail:GetCurrentTypePos()
  if not self.m_curChooseTab then
    return
  end
  local heroPosTab = ShowTabHeroPos[self.m_curChooseTab]
  if not heroPosTab then
    return
  end
  return heroPosTab.position
end

function Form_HeroDetail:FilterInheritHero(heroList)
  if not heroList then
    return
  end
  local showHeroList = {}
  for _, v in ipairs(heroList) do
    if v.serverData.iOriLevel == 0 then
      showHeroList[#showHeroList + 1] = v
    end
  end
  return showHeroList
end

function Form_HeroDetail:CheckFreshRedDot()
  if not self.m_curShowHeroData then
    return
  end
  local iHeroId = self.m_curShowHeroData.serverData.iHeroId
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base, RedDotDefine.ModuleType.HeroBaseInfoTab, iHeroId)
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base2, RedDotDefine.ModuleType.HeroEquipped, iHeroId)
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_skin, RedDotDefine.ModuleType.HeroFashion, iHeroId)
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base3, RedDotDefine.ModuleType.HeroSkillLevelUp, iHeroId)
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_attract, RedDotDefine.ModuleType.HeroAttractEntry, iHeroId)
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base4, RedDotDefine.ModuleType.HeroLegacyTab, iHeroId)
end

function Form_HeroDetail:FreshUI(showTabNum)
  if not self.m_curShowHeroData then
    return
  end
  local showHeroTab = showTabNum or DefaultChooseTab
  self:FreshChangeHeroTab(showHeroTab)
  self:FreshAttractHeroInfo()
  self:FreshShowHeroInfo(true)
  self:FreshHeroAttract(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate, self.m_curShowHeroData.serverData.iAttractRank)
  self:FreshShowJustOneShow()
  self:ShowDetailTab()
end

function Form_HeroDetail:ShowDetailTab()
  self.m_pnl_detail:SetActive(not self.m_inheritLvUp)
  if self.m_inheritLvUp then
    local lastSubPanelData = self.m_subPanelData[HeroTagCfg.Base]
    if lastSubPanelData.subPanelLua then
      lastSubPanelData.subPanelLua:SetActive(true)
    end
  end
end

function Form_HeroDetail:FreshChangeHeroTab(index)
  local lastHeroTab = self.m_curChooseTab
  if lastHeroTab then
    local lastSubPanelData = self.m_subPanelData[lastHeroTab]
    if lastSubPanelData.subPanelLua then
      lastSubPanelData.subPanelLua:SetActive(false)
      if lastSubPanelData.subPanelLua.OnHidePanel then
        lastSubPanelData.subPanelLua:OnHidePanel()
      end
    end
    UILuaHelper.SetActive(lastSubPanelData.nodeSelect, false)
    UILuaHelper.SetActive(lastSubPanelData.nodeUnSelect, true)
  end
  if index then
    if index == HeroTagCfg.Base then
      local heroId = self.m_curShowHeroData.characterCfg.m_HeroID
      local fashionID = self.m_curShowHeroData.serverData.iFashion
      self:GetRandomTimerPlayVoice(self.voiceLimit, self.voiceUpper, heroId, fashionID)
    else
      self:KillVoiceTimer()
    end
    self.m_widgetBtnBack:SetExplainID(TagCfg[index].explainID)
    self.m_curChooseTab = index
    local curSubPanelData = self.m_subPanelData[index]
    UILuaHelper.SetActive(curSubPanelData.nodeSelect, true)
    UILuaHelper.SetActive(curSubPanelData.nodeUnSelect, false)
    if curSubPanelData then
      if curSubPanelData.subPanelLua == nil then
        local chooseTab = self.m_inheritLvUp == true and HeroManager.HeroBaseTab.LvUpgrade or nil
        local initData = curSubPanelData.backFun and {
          backFun = curSubPanelData.backFun
        } or nil
        SubPanelManager:LoadSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, initData, {
          heroData = self.m_curShowHeroData,
          allHeroList = self.m_allHeroList,
          chooseIndex = self.m_curChooseHeroIndex,
          initData = initData,
          chooseTab = chooseTab
        }, function(subPanelLua)
          if subPanelLua then
            curSubPanelData.subPanelLua = subPanelLua
            if curSubPanelData.isNeedShowEnterAnim and subPanelLua.ShowEnterInAnim then
              subPanelLua:ShowEnterInAnim()
              curSubPanelData.isNeedShowEnterAnim = false
            end
            if curSubPanelData.isNeedShowTabAnim and subPanelLua.ShowTabInAnim then
              subPanelLua:ShowTabInAnim()
              curSubPanelData.isNeedShowTabAnim = false
            end
            if subPanelLua.OnActivePanel then
              subPanelLua:OnActivePanel()
            end
          end
        end)
      else
        self:FreshCurTabSubPanelInfo()
      end
    end
  end
  if self.m_isJustOne ~= true then
    if self.m_curChooseTab == HeroTagCfg.Equip then
      UILuaHelper.SetActive(self.m_changehero_equip, true)
      UILuaHelper.SetActive(self.m_pnl_equip_bg, true)
      UILuaHelper.SetActive(self.m_changehero, false)
      UILuaHelper.SetActive(self.m_namecard, false)
    else
      UILuaHelper.SetActive(self.m_changehero, true)
      UILuaHelper.SetActive(self.m_namecard, true)
      UILuaHelper.SetActive(self.m_changehero_equip, false)
      UILuaHelper.SetActive(self.m_pnl_equip_bg, false)
    end
  end
  local isFashionBtnShow = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HeroFashion)
  UILuaHelper.SetActive(self.m_btn_skin, isFashionBtnShow == true and self.m_curChooseTab == HeroTagCfg.Base)
  self.m_blood_bg:SetActive(self.m_curChooseTab == HeroTagCfg.Base)
  self.m_btn_clothe:SetActive(self.m_curChooseTab == HeroTagCfg.Base)
  self.m_btn_attract:SetActive(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate > 0 and self.m_curChooseTab == HeroTagCfg.Base)
  UILuaHelper.SetActive(self.m_legacy_img_shadow, self.m_curChooseTab == HeroTagCfg.Legacy)
  UILuaHelper.SetActive(self.m_img_legacybk_top, self.m_curChooseTab == HeroTagCfg.Legacy)
end

function Form_HeroDetail:FreshShowJustOneShow()
  if self.m_isJustOne == true then
    UILuaHelper.SetActive(self.m_changehero_equip, false)
    UILuaHelper.SetActive(self.m_pnl_equip_bg, false)
    UILuaHelper.SetActive(self.m_changehero, false)
    UILuaHelper.SetActive(self.m_namecard, true)
    self.m_widgetBtnBack:SetBackHomeActive(false)
  else
    self.m_widgetBtnBack:SetBackHomeActive(true)
  end
end

function Form_HeroDetail:FreshShowHeroInfo(isEnterFresh)
  self:PlayTouchDisappearAnimation()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  if heroCfg.m_HeroID == 0 then
    return
  end
  self.m_txt_power_value_Text.text = BigNumFormat(self.m_curShowHeroData.serverData.iPower)
  self.m_txt_power_value2_Text.text = BigNumFormat(self.m_curShowHeroData.serverData.iPower)
  local fashionID = self.m_curShowHeroData.serverData.iFashion
  local heroFashionSpine = self.m_HeroFashion:GetHeroSpineByHeroFashionID(heroCfg.m_HeroID, fashionID)
  if not heroFashionSpine then
    return
  end
  self:ShowHeroSpine(heroFashionSpine, isEnterFresh)
  self:FreshShowHeroIndex()
  self:CheckFreshRedDot()
end

function Form_HeroDetail:PlayHeroDisPlayVoice()
  if not self.m_curShowHeroData then
    return
  end
  local heroID = self.m_curShowHeroData.serverData.iHeroId
  local fashionID = self.m_curShowHeroData.serverData.iFashion
  local fashionInfoCfg = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroID, fashionID)
  if not fashionInfoCfg then
    return
  end
  local m_PerformanceID = fashionInfoCfg.m_PerformanceID[0]
  if not m_PerformanceID then
    return
  end
  local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  if not presentationData.m_GainVoice then
    return
  end
  UILuaHelper.StartPlaySFX(presentationData.m_CharDisplayVoice, nil, function(playingDisplayId)
    self.m_playingDisplayId = playingDisplayId
  end, function()
    self.m_playingDisplayId = nil
  end)
  UILuaHelper.StartPlaySFX(presentationData.m_GainVoiceEvent, nil, function(playingDisplayId)
    self.m_playingDisplayId3 = playingDisplayId
  end, function()
    self.m_playingDisplayId3 = nil
  end)
end

function Form_HeroDetail:StopCurDisPlayPlayingVoice()
  if self.m_playingDisplayId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId)
  end
  if self.m_playingDisplayId2 then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId2)
  end
  if self.m_playingDisplayId3 then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingDisplayId3)
  end
end

function Form_HeroDetail:FreshHeroAttract(iAttractRankTemplate, iAttractRank)
  if 0 < iAttractRankTemplate and self.m_curChooseTab == HeroTagCfg.Base then
    self.m_txt_attract_level_Text.text = iAttractRank
    self.m_btn_attract:SetActive(true)
  else
    self.m_btn_attract:SetActive(false)
  end
end

function Form_HeroDetail:OnEventRefreshPower()
  self.m_txt_power_value_Text.text = BigNumFormat(self.m_curShowHeroData.serverData.iPower)
  self.m_txt_power_value2_Text.text = BigNumFormat(self.m_curShowHeroData.serverData.iPower)
end

function Form_HeroDetail:OnRefreshHeroSpine()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  if heroCfg.m_HeroID == 0 then
    return
  end
  local fashionID = self.m_curShowHeroData.serverData.iFashion
  local heroFashionSpine = self.m_HeroFashion:GetHeroSpineByHeroFashionID(heroCfg.m_HeroID, fashionID)
  if not heroFashionSpine then
    return
  end
  self:ShowHeroSpine(heroFashionSpine)
end

function Form_HeroDetail:ShowHeroSpine(heroSpinePathStr, isEnterFresh)
  self.m_heroShowRandomAnim = false
  local typeStr = self.m_curChooseTab == HeroTagCfg.Equip and SpinePlaceCfg.HeroEquipMain or SpinePlaceCfg.HeroDetail
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleCurSpine()
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleCurSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack(isEnterFresh)
    if self.m_spineClick then
      local spineStr = self.m_curHeroSpineObj.assetSpineStr
      self.m_spineClick:BindingSpine("hero_place_" .. spineStr .. "," .. typeStr .. "," .. spineStr)
    end
  end)
end

function Form_HeroDetail:OnLoadSpineBack(isEnterFresh)
  if not self.m_curHeroSpineObj then
    return
  end
  self:KillVoiceTimer()
  local heroCfg = self.m_curShowHeroData.characterCfg
  if heroCfg.m_HeroID and heroCfg.m_HeroID ~= 0 then
    self:GetRandomTimerPlayVoice(self.voiceLimit, self.voiceUpper, heroCfg.m_HeroID)
  end
  local spineObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spineObj, true)
  local spineRootTrans = self.m_curHeroSpineObj.spineTrans
  self.m_spineDitherExtension = spineRootTrans:GetComponent("SpineDitherExtension")
  if self.m_dragEndTimer then
    local leftTime = TimeService:GetTimerLeftTime(self.m_dragEndTimer)
    if leftTime and 0 < leftTime then
      self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
      self.m_spineDitherExtension:SetToDither(1.0, 0.0, leftTime)
      if self.m_dragEndTimer then
        TimeService:KillTimer(self.m_dragEndTimer)
        self.m_dragEndTimer = nil
      end
      self.m_dragEndTimer = TimeService:SetTimer(leftTime, 1, function()
        self:CheckKillDragDoTween()
        self.m_dragEndTimer = nil
      end)
    else
      self.m_spineDitherExtension:StopToDither(true)
      self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
    end
  else
    self.m_spineDitherExtension:StopToDither(true)
    self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
  end
  self:CheckShowSpineEnterAnim(isEnterFresh)
  self:FreshShowSpineMaskAndGray()
end

function Form_HeroDetail:CheckShowSpineEnterAnim(isEnterFresh)
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpineTrans = self.m_curHeroSpineObj.spineTrans
  if not heroSpineTrans then
    return
  end
  UILuaHelper.SpineResetInit(heroSpineTrans)
  if heroSpineTrans:GetComponent("SpineSkeletonPosControl") then
    heroSpineTrans:GetComponent("SpineSkeletonPosControl"):OnResetInit()
  end
  if isEnterFresh then
    UILuaHelper.SpinePlayAnimWithBack(heroSpineTrans, 0, "chuchang2", false, false, function()
      self:SpinePlayRandomAnim()
    end)
  else
    self:SpinePlayRandomAnim()
  end
end

function Form_HeroDetail:SpinePlayRandomAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpine = self.m_curHeroSpineObj.spineObj
  if not heroSpine or UILuaHelper.IsNull(heroSpine) then
    return
  end
  self.m_heroShowRandomAnim = true
  local actions = {idleAnimStr, touchAnimStr}
  local action = actions[math.random(1, 2)]
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, idleAnimStr, false, false, function()
    if UILuaHelper.IsNull(heroSpine) then
      return
    end
    UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, action, false, false, function()
      self:SpinePlayRandomAnim()
    end)
  end)
end

function Form_HeroDetail:FreshCurTabSubPanelInfo(isJustFreshData)
  if not self.m_curChooseTab then
    return
  end
  if not self.m_curShowHeroData then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  local subPanelLua = curSubPanelData.subPanelLua
  if subPanelLua then
    subPanelLua:SetActive(true)
    subPanelLua:FreshData({
      heroData = self.m_curShowHeroData,
      allHeroList = self.m_allHeroList,
      chooseIndex = self.m_curChooseHeroIndex,
      isJustFreshData = isJustFreshData
    })
    if subPanelLua.OnActivePanel then
      subPanelLua:OnActivePanel()
    end
  end
end

function Form_HeroDetail:FreshShowHeroIndex()
  if not self.m_curChooseHeroIndex then
    return
  end
  self.m_txt_hero_num_Text.text = string.format("%d/%d", self.m_curChooseHeroIndex, #self.m_allHeroList)
end

function Form_HeroDetail:CheckKillHeroPosDoTween()
  for key, v in pairs(ShowTabHeroPos) do
    if v.posTween then
      if v.posTween:IsPlaying() then
        v.posTween:Kill()
      end
      v.posTween = nil
    end
    if v.scaleTween then
      if v.scaleTween:IsPlaying() then
        v.scaleTween:Kill()
      end
      v.scaleTween = nil
    end
  end
end

function Form_HeroDetail:CheckShowHeroTabInAim()
  if not self.m_curChooseTab then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local subPanelLua = curSubPanelData.subPanelLua
    if subPanelLua then
      if subPanelLua.ShowTabInAnim then
        subPanelLua:ShowTabInAnim()
      end
    else
      curSubPanelData.isNeedShowTabAnim = true
    end
    local tempHeroPos = ShowTabHeroPos[self.m_curChooseTab]
    if tempHeroPos then
      self:CheckKillHeroPosDoTween()
      local changePos = {
        x = tempHeroPos.position[1],
        y = tempHeroPos.position[2],
        z = tempHeroPos.position[3]
      }
      tempHeroPos.posTween = self.m_root_hero.transform:DOLocalMove(changePos, tempHeroPos.posTime)
      tempHeroPos.posTween:PlayForward()
      local changeScale = {
        x = tempHeroPos.scale[1],
        y = tempHeroPos.scale[2],
        z = tempHeroPos.scale[3]
      }
      tempHeroPos.scaleTween = self.m_root_hero.transform:DOScale(changeScale, tempHeroPos.scaleTime)
      tempHeroPos.scaleTween:PlayForward()
      self:FreshShowSpineMaskAndGray()
    end
  end
end

function Form_HeroDetail:ChangeRootSpineParent()
  if not self.m_curShowHeroData then
    return
  end
  if not self.m_curHeroSpineObj then
    return
  end
  local typeStr = self.m_curChooseTab == HeroTagCfg.Equip and SpinePlaceCfg.HeroEquipMain or SpinePlaceCfg.HeroDetail
  self.m_HeroSpineDynamicLoader:SetSpineInPos(self.m_curHeroSpineObj, typeStr, self.m_root_hero, true)
end

function Form_HeroDetail:FreshShowSpineMaskAndGray()
  local tempTabSpinCfg = ShowTabHeroPos[self.m_curChooseTab]
  if not tempTabSpinCfg then
    return
  end
  UILuaHelper.SetActive(self.m_root_hero, true)
  local isMaskAndGray = tempTabSpinCfg.isMaskAndGray
  local isStopSpineAnim = tempTabSpinCfg.isStopSpineAnim
  if self.m_spineDitherExtension and not UILuaHelper.IsNull(self.m_spineDitherExtension) and isMaskAndGray ~= nil then
    self.m_spineDitherExtension:SetSpineMaskAndGray(isMaskAndGray)
    local isTransParent = tempTabSpinCfg.isTransParent
    if isTransParent ~= nil then
      self.m_spineDitherExtension:SetTransparentToggle(isTransParent)
    end
    if self.m_curHeroSpineObj then
      local spineObj = self.m_curHeroSpineObj.spineObj
      if spineObj then
        if isStopSpineAnim then
          UILuaHelper.SpineResetInit(spineObj)
          UILuaHelper.SetSpineTimeScale(spineObj, 0)
          if spineObj.transform:GetComponent("SpineSkeletonPosControl") then
            spineObj.transform:GetComponent("SpineSkeletonPosControl"):OnResetInit()
          end
        else
          UILuaHelper.SetSpineTimeScale(spineObj, 1)
        end
      end
    end
  end
end

function Form_HeroDetail:CheckShowEnterAnim()
  if not self.m_curChooseTab then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local subPanelLua = curSubPanelData.subPanelLua
    if subPanelLua then
      if subPanelLua.ShowEnterInAnim then
        subPanelLua:ShowEnterInAnim()
      end
    else
      curSubPanelData.isNeedShowEnterAnim = true
    end
  end
  local tempHeroPos = ShowTabHeroPos[self.m_curChooseTab]
  if tempHeroPos then
    UILuaHelper.SetLocalPosition(self.m_root_hero, table.unpack(tempHeroPos.position))
    UILuaHelper.SetLocalScale(self.m_root_hero, table.unpack(tempHeroPos.scale))
    self:FreshShowSpineMaskAndGray()
  end
  self:ShowFormEnterAnim()
end

function Form_HeroDetail:ShowFormEnterAnim()
  if not self.m_curChooseTab then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, EnterAnimStr)
end

function Form_HeroDetail:CheckRecycleCurSpine(isResetParam)
  if not self.m_curHeroSpineObj then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  if isResetParam then
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
  end
  self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
  self.m_curHeroSpineObj = nil
end

function Form_HeroDetail:OnUpgradeCloseBack(heroID)
  local heroIndex = self:GetAllHeroIndex(heroID)
  if not heroIndex then
    return
  end
  local tempHeroData = self.m_allHeroList[heroIndex]
  if not tempHeroData then
    return
  end
  self.m_curChooseHeroIndex = heroIndex
  self.m_curShowHeroData = tempHeroData
end

function Form_HeroDetail:OnBackClk()
  self:CheckKillHeroPosDoTween()
  self:CheckRecycleCurSpine(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HERODETAIL)
end

function Form_HeroDetail:OnBackHome()
  self:CheckRecycleCurSpine(true)
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_HeroDetail:OnImgBeginDrag(pointerEventData)
  self.m_isDrag = true
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
  self.m_startDragUIPosX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, startPos.x, startPos.y, self.m_groupCam)
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
  end
end

function Form_HeroDetail:OnImgEndBDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_startDragPos.x
  local absDeltaNum = math.abs(deltaNum)
  if absDeltaNum < DragLimitNum then
    self:CheckShowDragBackTween()
    return
  end
  if 0 < deltaNum then
    self:CheckShowLastHero()
  else
    self:CheckShowNextHero()
  end
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
end

function Form_HeroDetail:OnImgDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragUIPosX then
    return
  end
  local dragPos = pointerEventData.position
  local curTypePos = self:GetCurrentTypePos()
  local startDragUIPosX = self.m_startDragUIPosX
  local localX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, dragPos.x, dragPos.y, self.m_groupCam)
  local deltaX = localX - startDragUIPosX
  local deltaAbsNum = math.abs(deltaX)
  if deltaAbsNum > self.m_uiVariables.MaxDragDeltaNum then
    return
  end
  local lerpRate = deltaAbsNum / self.m_uiVariables.MaxDragDeltaNum
  local paiRateNum = lerpRate * 3.1415 / 2
  local sinRateNum = math.sin(paiRateNum)
  local inputDeltaNum = sinRateNum * self.m_uiVariables.MaxDragDeltaNum
  if deltaX < 0 then
    inputDeltaNum = -inputDeltaNum
  end
  UILuaHelper.SetLocalPosition(self.m_root_hero, curTypePos[1] + inputDeltaNum, curTypePos[2], 0)
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension.DitherNum = lerpRate
  end
end

function Form_HeroDetail:TryChangeCurHero(toHeroIndex)
  self:StopCurDisPlayPlayingVoice()
  local curShowHeroData = self.m_allHeroList[toHeroIndex]
  if curShowHeroData == nil then
    return
  end
  
  local function OnDownloadComplete(ret)
    log.info(string.format("Download HeroDetail ChangeCurHero %s,%s Complete: %s", tostring(levelType), tostring(levelID), tostring(ret)))
    self.m_curChooseHeroIndex = toHeroIndex
    self.m_curShowHeroData = self.m_allHeroList[self.m_curChooseHeroIndex]
    self:FreshAttractHeroInfo()
    self:FreshShowHeroInfo()
    self:FreshCurTabSubPanelInfo(true)
    self:FreshHeroAttract(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate, self.m_curShowHeroData.serverData.iAttractRank)
    self:CheckShowHeroTabInAim()
  end
  
  local vPackage = {}
  vPackage[#vPackage + 1] = {
    sName = tostring(curShowHeroData.characterCfg.m_HeroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  DownloadManager:DownloadResourceWithUI(vPackage, nil, "UI_Form_HeroDetail_ChangeHero_" .. tostring(curShowHeroData.characterCfg.m_HeroID), nil, nil, OnDownloadComplete)
end

function Form_HeroDetail:CheckShowLastHero()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(false, function()
    local toHeroIndex = self.m_curChooseHeroIndex - 1
    if toHeroIndex <= 0 then
      toHeroIndex = #self.m_allHeroList
    end
    self:TryChangeCurHero(toHeroIndex)
  end)
end

function Form_HeroDetail:CheckShowNextHero()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(true, function()
    local toHeroIndex = self.m_curChooseHeroIndex + 1
    if toHeroIndex > #self.m_allHeroList then
      toHeroIndex = 1
    end
    self:TryChangeCurHero(toHeroIndex)
  end)
end

function Form_HeroDetail:CheckKillDragDoTween(isJustKillTween)
  if self.m_dragTween and self.m_dragTween:IsPlaying() then
    self.m_dragTween:Kill()
  end
  self.m_dragTween = nil
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
  if not isJustKillTween then
    local typePos = self:GetCurrentTypePos()
    UILuaHelper.SetLocalPosition(self.m_root_hero, typePos[1], typePos[2], typePos[3])
    if self.m_spineDitherExtension then
      self.m_spineDitherExtension.DitherNum = 0
      self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
    end
  end
end

function Form_HeroDetail:CheckShowDragTween(isLeft, midBackFun)
  if not self.m_curChooseTab then
    return
  end
  local dragPosX = isLeft and self.m_uiVariables.DragLeftPosNum or self.m_uiVariables.DragRightPosNum
  local typePos = self:GetCurrentTypePos()
  local changePos = {
    x = dragPosX,
    y = typePos[2],
    z = 0
  }
  local toTween = self.m_root_hero.transform:DOLocalMove(changePos, self.m_uiVariables.DragTweenTime)
  local backPos = {
    x = typePos[1],
    y = typePos[2],
    z = typePos[3]
  }
  local backTween = self.m_root_hero.transform:DOLocalMove(backPos, self.m_uiVariables.DragTweenBackTime)
  self.m_dragTween = CS.DG.Tweening.DOTween.Sequence()
  self.m_dragTween:Append(toTween)
  self.m_dragTween:Append(backTween)
  self.m_dragTween:PlayForward()
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
    self.m_spineDitherExtension:SetToDither(self.m_spineDitherExtension.DitherNum, 1, self.m_uiVariables.DragTweenTime)
  end
  self.m_dragTween:PlayForward()
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  self.m_UILockID = UILockIns:Lock(self.m_uiVariables.DragTweenTime + self.m_uiVariables.DragTweenBackTime)
  self.m_dragTimer = TimeService:SetTimer(self.m_uiVariables.DragTweenTime, 1, function()
    self.m_dragTimer = nil
    if midBackFun then
      midBackFun()
    end
  end)
  if self.m_dragEndTimer then
    TimeService:KillTimer(self.m_dragEndTimer)
    self.m_dragEndTimer = nil
  end
  self.m_dragEndTimer = TimeService:SetTimer(self.m_uiVariables.DragTweenTime + self.m_uiVariables.DragTweenBackTime, 1, function()
    self:CheckKillDragDoTween()
    self.m_dragEndTimer = nil
  end)
end

function Form_HeroDetail:CheckShowDragBackTween()
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  self.m_UILockID = UILockIns:Lock(self.m_uiVariables.DragTweenTime)
  local typePos = self:GetCurrentTypePos()
  local backPos = {
    x = typePos[1],
    y = typePos[2],
    z = typePos[3]
  }
  self.m_dragTween = self.m_root_hero.transform:DOLocalMove(backPos, self.m_uiVariables.DragTweenBackTime)
  self.m_dragTween:PlayForward()
  self.m_dragTimer = TimeService:SetTimer(self.m_uiVariables.DragTweenTime, 1, function()
    self.m_dragTimer = nil
    self:CheckKillDragDoTween()
  end)
end

function Form_HeroDetail:CheckShowSpineTouchAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpine = self.m_curHeroSpineObj.spineObj
  if not heroSpine then
    return
  end
  local action = actions[math.random(1, 2)]
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, action, false, false, function()
    UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, idleAnimStr, true, false)
  end)
end

function Form_HeroDetail:OnImgClick()
end

function Form_HeroDetail:OnBtnnextClicked()
  self:CheckShowNextHero()
end

function Form_HeroDetail:OnBtnpreviousClicked()
  self:CheckShowLastHero()
end

function Form_HeroDetail:OnBtnnext2Clicked()
  self:CheckShowNextHero()
end

function Form_HeroDetail:OnBtnprevious2Clicked()
  self:CheckShowLastHero()
end

function Form_HeroDetail:OnBtnattractClicked()
  if not UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.Attract, true) then
    return
  end
  AttractManager:LoadFavorabilityScene(nil, {
    hero_id = self.m_curShowHeroData.serverData.iHeroId
  })
end

function Form_HeroDetail:OnHeroTabClk(index)
  if not index then
    return
  end
  if index == self.m_curChooseTab then
    return
  end
  self:FreshChangeHeroTab(index)
  UILuaHelper.PlayAnimationByName(self.m_namecard, NameCardShowAnim)
  self:CheckShowHeroTabInAim()
  self:ChangeRootSpineParent()
  if self.m_curChooseTab == HeroTagCfg.Equip then
    local curAnimStr = ""
    if self.m_curHeroSpineObj then
      curAnimStr = UILuaHelper.SpineGetCurAnimStr(self.m_curHeroSpineObj.spineObj, 0)
    end
    if curAnimStr ~= idleAnimStr and curAnimStr ~= touchAnimStr then
      self:SpinePlayRandomAnim()
    end
  end
end

function Form_HeroDetail:OnTabbaseClicked()
  self:OnHeroTabClk(HeroTagCfg.Base)
end

function Form_HeroDetail:OnTabskillClicked()
  local openFlag, tipsId = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.SkillLevelUp)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tipsId)
    return
  end
  self:OnHeroTabClk(HeroTagCfg.Skill)
end

function Form_HeroDetail:OnBaseSkillClk()
  if self.m_curChooseTab == HeroTagCfg.Base then
    self:OnHeroTabClk(HeroTagCfg.Skill)
  end
end

function Form_HeroDetail:OnBaseEquipClk()
  if self.m_curChooseTab == HeroTagCfg.Equip then
    self:OnHeroTabClk(HeroTagCfg.Equip)
  end
end

function Form_HeroDetail:OnTabequipClicked()
  local openFlag, tipsId = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Equip)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tipsId)
    return
  end
  self:OnHeroTabClk(HeroTagCfg.Equip)
end

function Form_HeroDetail:OnTablegacyClicked()
  local openFlag, tipsId = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Legacy)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tipsId)
    return
  end
  self:OnHeroTabClk(HeroTagCfg.Legacy)
end

function Form_HeroDetail:OnBtncampClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  StackFlow:Push(UIDefines.ID_FORM_HEROCAMPDETAIL, {heroCfg = heroCfg})
end

function Form_HeroDetail:OnBtnskinClicked()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  local fashionID = self.m_curShowHeroData.serverData.iFashion
  StackFlow:Push(UIDefines.ID_FORM_FASHION, {
    heroID = heroCfg.m_HeroID,
    fashionID = fashionID
  })
end

function Form_HeroDetail:IsFullScreen()
  return true
end

function Form_HeroDetail:GetDownloadResourceExtra(tParam)
  local vSubPanelName = {
    "HeroBaseSubPanel",
    "HeroEquipSubPanel",
    "HeroSkillSubPanel",
    "HeroLegacySubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "RTCanvasObj",
    eType = DownloadManager.ResourceType.UI
  }
  local vAllHeroList = tParam.heroDataList
  local iCurChooseHeroIndex = tParam.chooseHeroIndex
  local heroID = vAllHeroList[iCurChooseHeroIndex].characterCfg.m_HeroID
  vPackage[#vPackage + 1] = {
    sName = tostring(heroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  vPackage[#vPackage + 1] = {
    sName = "Form_GameSceneLoading",
    eType = DownloadManager.ResourcePackageType.UI
  }
  local stGameSceneConfig = ConfigManager:GetConfigInsByName("GameScene"):GetValue_ByID(GameSceneManager.SceneID.Favorability)
  vResourceExtra[#vResourceExtra + 1] = {
    sName = stGameSceneConfig.m_LoadingImg,
    eType = DownloadManager.ResourceType.UITexture
  }
  return vPackage, vResourceExtra
end

function Form_HeroDetail:GetCurrentHeroLevel()
  if not self.m_curShowHeroData then
    return 0
  end
  return self.m_curShowHeroData.serverData.iLevel
end

function Form_HeroDetail:GetCurrentHeroQuality()
  if not self.m_curShowHeroData then
    return 0
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  if not heroCfg then
    return 0
  end
  return heroCfg.m_Quality
end

function Form_HeroDetail:GetGuideConditionIsOpen(conditionType, conditionParam)
  if conditionType == 17 then
    if not self.m_curShowHeroData then
      return false
    end
    local heroCfg = self.m_curShowHeroData.characterCfg
    if not heroCfg then
      return false
    end
    return heroCfg.m_AttractArchiveIsOpen == 1
  end
  local quality = self:GetCurrentHeroQuality()
  local ret = false
  if quality >= tonumber(conditionParam) then
    ret = true
  end
  return ret
end

function Form_HeroDetail:FreshAttractHeroInfo()
  if self.m_curShowHeroData.characterCfg.m_AttractRankTemplate == 0 then
    return
  end
  self.m_attractInfo = AttractManager:GetHeroAttractById(self.m_curShowHeroData.serverData.iHeroId) or {}
  self.m_expList = AttractManager:GetExpList(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate)
  self.m_oldRank = self.m_curShowHeroData.serverData.iAttractRank
  self:FreshAttractRankInfo()
end

function Form_HeroDetail:FreshAttractRankInfo()
  local serverData = self.m_curShowHeroData.serverData
  local baseExpInfo = self.m_expList[serverData.iAttractRank]
  local baseExp = baseExpInfo.exp
  self.m_baseRankExp = baseExp
  local curExp = self.m_attractInfo.iAttractExp or 0
  self.m_curRankExp = curExp
  local nextExpInfo = self.m_expList[serverData.iAttractRank + 1]
  if nextExpInfo == nil or 0 < nextExpInfo.breakCondition and serverData.iBreak < nextExpInfo.breakCondition then
    self.m_nextRankExp = nil
    return
  end
  local nextExp = nextExpInfo.exp
  self.m_nextRankExp = nextExp
end

function Form_HeroDetail:TriggerHeroTouchImmediately()
  if self.m_touchTimer then
    TimeService:KillTimer(self.m_touchTimer)
    self.m_touchTimer = nil
  end
  if self.m_totalTouchCount > 0 then
  end
end

function Form_HeroDetail:ReqHeroTouch()
  AttractManager:ReqHeroTouch(self.m_curShowHeroData.serverData.iHeroId, self.m_totalTouchCount, function(bRankChange)
    self.m_attractInfo = AttractManager:GetHeroAttractById(self.m_curShowHeroData.serverData.iHeroId) or {}
    if bRankChange then
      self:ShowAttractLevelUp()
      self:FreshAttractRankInfo()
      self:FreshHeroAttract(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate, self.m_curShowHeroData.serverData.iAttractRank)
    end
  end)
  self.m_totalTouchCount = 0
  self.m_totalExp = 0
end

function Form_HeroDetail:PlayTouchDisappearAnimation()
  if self.m_prevTouchExp then
    GameObject.Destroy(self.m_prevTouchExp)
    self.m_prevTouchExp = nil
  end
end

function Form_HeroDetail:CheckHeroTouch()
  if self.m_nextRankExp == nil then
    return false
  end
  if (self.m_attractInfo.iTouchTimes or 0) + self.m_totalTouchCount + 1 > self.m_iAttractTouchLimit then
    return false
  end
  self.m_totalTouchCount = self.m_totalTouchCount + 1
  self.m_totalExp = self.m_totalExp + self.m_iAttractTouchReward
  if self.m_curRankExp + self.m_totalExp >= self.m_nextRankExp then
    return false
  else
  end
  return true
end

function Form_HeroDetail:ShowAttractLevelUp()
  local newRank = self.m_curShowHeroData.serverData.iAttractRank
  self.m_ShowLevelUp = true
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTLEVELUP, {
    curShowHeroData = self.m_curShowHeroData,
    iOldRank = self.m_oldRank,
    iNewRank = newRank
  })
  self.m_oldRank = self.m_curShowHeroData.serverData.iAttractRank
end

function Form_HeroDetail:GetRandomTimerPlayVoice(limit, upper, heroID, fashionID)
  local during = self:GetRanomTime(limit, upper)
  if during then
    self.voiceTimer = TimeService:SetTimer(during, 1, function()
      local voice = HeroManager:GetHeroVoice():GetHeroIdleVoice(heroID, fashionID)
      if voice and voice ~= "" then
        CS.UI.UILuaHelper.StartPlaySFX(voice, nil, function(playingDisplayId)
          self.m_playingDisplayId2 = playingDisplayId
        end, function()
          self.m_playingDisplayId2 = nil
        end)
      end
    end)
  end
end

function Form_HeroDetail:GetRanomTime(limit, upper)
  if limit and upper and limit < upper then
    return math.random(limit, upper)
  end
end

function Form_HeroDetail:KillVoiceTimer()
  if self.voiceTimer then
    TimeService:KillTimer(self.voiceTimer)
    self.voiceTimer = nil
  end
end

local fullscreen = true
ActiveLuaUI("Form_HeroDetail", Form_HeroDetail)
return Form_HeroDetail
