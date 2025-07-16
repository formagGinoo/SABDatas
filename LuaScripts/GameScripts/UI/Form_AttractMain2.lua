local Form_AttractMain2 = class("Form_AttractMain2", require("UI/UIFrames/Form_AttractMain2UI"))

function Form_AttractMain2:SetInitParam(param)
end

function Form_AttractMain2:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1121)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaHeroListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "Attract/AttractHeroListItem", initGridData)
end

function Form_AttractMain2:OnActive()
  self.super.OnActive(self)
  AttractManager:SetFavorabilityCameraInit(true)
  local manager = AttractManager:GetAttractRoomManager()
  if manager then
    manager:RegisterClickEvent(handler(self, self.OnClickEntryItem))
    manager:SetRaycastOn(true)
  end
  AttractManager:SetOtherModelActive(true)
  self.bIsLoading = false
  self:InitData()
  self:FreshUI()
  StackTop:RemoveUIFromStack(UIDefines.ID_FORM_GAMESCENELOADING)
end

function Form_AttractMain2:OnInactive()
  self.super.OnInactive(self)
  AttractManager:SetRaycastOn(false)
end

function Form_AttractMain2:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_AttractMain2:InitData()
  local tParam = self.m_csui.m_param
  self.m_allHeroList = AttractManager:GetAttractHeroList()
  if tParam then
    local iCurHeroId = tParam.hero_id
    for i, v in ipairs(self.m_allHeroList) do
      if v.serverData.iHeroId == iCurHeroId then
        self.m_curChooseHeroIndex = i
        self.m_curShowHeroData = v
        break
      end
    end
    self.m_csui.m_param = nil
  else
    self.m_curShowHeroData = self.m_curShowHeroData or nil
    if self.m_curShowHeroData then
      for i, v in ipairs(self.m_allHeroList) do
        if v.serverData.iHeroId == self.m_curShowHeroData.serverData.iHeroId then
          self.m_curChooseHeroIndex = i
          break
        end
      end
    end
  end
end

function Form_AttractMain2:FreshUI()
  self:FreshHeroList()
  self:FreshHeroCard()
end

function Form_AttractMain2:FreshHeroList()
  for i, v in ipairs(self.m_allHeroList) do
    v.bIsAttractSelected = false
  end
  if self.m_curShowHeroData then
    self.m_curShowHeroData.bIsAttractSelected = true
  end
  self.m_luaHeroListInfinityGrid:ShowItemList(self.m_allHeroList)
  self.m_luaHeroListInfinityGrid:LocateTo(self.m_curChooseHeroIndex - 1)
end

function Form_AttractMain2:FreshHeroCard()
  if self.m_curShowHeroData then
    self.m_pnl_hero_card:SetActive(true)
    local characterCfg = self.m_curShowHeroData.characterCfg
    self.m_txt_hero_name_Text.text = characterCfg.m_mFullName
    self.m_txt_hero_nike_name_Text.text = characterCfg.m_mTitle
    local iAttractRank = self.m_curShowHeroData.serverData.iAttractRank
    local iBreak = self.m_curShowHeroData.serverData.iBreak
    self.m_txt_attract_lv_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100809), iAttractRank)
    self.m_txt_hero_bd_Text.text = characterCfg.m_mBirthday
    local campCfg = HeroManager:GetCharacterCampCfgByCamp(characterCfg.m_Camp)
    local characterCampSubCfg = ConfigManager:GetConfigInsByName("CharacterCampSub")
    local subCampInfo = characterCampSubCfg:GetValue_ByCampSubID(characterCfg.m_CampSubID)
    self.m_txt_hero_sl_Text.text = campCfg.m_mCampName .. "-" .. subCampInfo.m_mCampSubName
    self:RegisterOrUpdateRedDotItem(self.m_canon_red, RedDotDefine.ModuleType.AttractBiographyEntry, self.m_curShowHeroData.serverData.iHeroId)
    if not self.m_curShowHeroData.characterCfg.m_AttractArchiveIsOpen or self.m_curShowHeroData.characterCfg.m_AttractArchiveIsOpen == 0 then
      self.m_btn_canon:SetActive(false)
      self.m_btn_canon_lock:SetActive(true)
    else
      self.m_btn_canon:SetActive(true)
      self.m_btn_canon_lock:SetActive(false)
    end
    local expCfg = AttractManager:GetExpList(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate)
    local baseExpInfo = expCfg[iAttractRank]
    local baseExp = baseExpInfo.exp
    local m_attractInfo = AttractManager:GetHeroAttractById(self.m_curShowHeroData.serverData.iHeroId)
    local curExp = m_attractInfo.iAttractExp or 0
    local nextExpInfo = expCfg[iAttractRank + 1]
    if nextExpInfo == nil or 0 < nextExpInfo.breakCondition and iBreak < nextExpInfo.breakCondition then
      self.m_img_precent_bar_Image.fillAmount = 1
      self.m_precent_red:SetActive(false)
      return
    end
    self.m_img_precent_bar_Image.fillAmount = (curExp - baseExp) / (nextExpInfo.exp - baseExp)
    local vGiftList = ItemManager:GetItemListByType(ItemManager.ItemType.AttractGift)
    self.m_precent_red:SetActive(0 < #vGiftList)
  else
    self.m_pnl_hero_card:SetActive(false)
  end
end

function Form_AttractMain2:OnHeroItemClick(index, go)
  local itemIndex = index + 1
  if itemIndex == self.m_curChooseHeroIndex or self.bIsLoading then
    return
  end
  self.bIsLoading = true
  AttractManager:LoadFavorabilityHero(self.m_allHeroList[itemIndex].serverData.iHeroId, nil, function()
    if self.m_curShowHeroData then
      self.m_curShowHeroData.bIsAttractSelected = false
      self.m_luaHeroListInfinityGrid:ReBind(self.m_curChooseHeroIndex)
    end
    self.m_curChooseHeroIndex = itemIndex
    self.m_curShowHeroData = self.m_allHeroList[itemIndex]
    self.m_curShowHeroData.bIsAttractSelected = true
    self:FreshHeroCard()
    self.m_luaHeroListInfinityGrid:ReBind(itemIndex)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
    self.bIsLoading = false
  end, function()
    self.bIsLoading = false
  end)
end

function Form_AttractMain2:OnBtncanonClicked()
  if not self.m_curShowHeroData then
    return
  end
  if not self.m_curShowHeroData.characterCfg.m_AttractArchiveIsOpen or self.m_curShowHeroData.characterCfg.m_AttractArchiveIsOpen == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(55001))
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTBOOK2, {
    curShowHeroData = self.m_curShowHeroData
  })
end

function Form_AttractMain2:OnBtncanonlockClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(55001))
end

function Form_AttractMain2:OnClickEntryItem(go, index)
  if index == 1 then
    self:OnBtncanonClicked()
  elseif index == 2 then
    self:OnBtnprecentClicked()
  elseif index == 3 then
    self:OnBtnvoiceClicked()
    UILuaHelper.PlayAnimatorByNameInChildren(go, "Hit")
  end
end

function Form_AttractMain2:OnBtnprecentClicked()
  if not self.m_curShowHeroData then
    return
  end
  AttractManager:SetFavorabilityCameraInit(false)
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTMAINSENDGIFT, {
    curShowHeroData = self.m_curShowHeroData
  })
end

function Form_AttractMain2:OnBtnvoiceClicked()
  if not self.m_curShowHeroData then
    return
  end
  AttractManager:SetFavorabilityCameraInit(false)
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTDIALOGUE, {
    curShowHeroData = self.m_curShowHeroData
  })
end

function Form_AttractMain2:OnBackClk()
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ATTRACTMAIN2)
  self.m_curChooseHeroIndex = nil
  self.m_curShowHeroData = nil
end

function Form_AttractMain2:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
  self.m_curChooseHeroIndex = nil
  self.m_curShowHeroData = nil
end

function Form_AttractMain2:IsFullScreen()
  return true
end

function Form_AttractMain2:GetDownloadResourceExtra(params)
  local hero_id = params.hero_id
  local vPackage = {}
  vPackage[#vPackage + 1] = {
    sName = tostring(hero_id),
    eType = DownloadManager.ResourcePackageType.Level_Character
  }
  vPackage[#vPackage + 1] = {
    sName = "Form_GameSceneLoading",
    eType = DownloadManager.ResourcePackageType.UI
  }
  local vResourceAB = {}
  local stGameSceneConfig = ConfigManager:GetConfigInsByName("GameScene"):GetValue_ByID(GameSceneManager.SceneID.Favorability)
  vResourceAB[#vResourceAB + 1] = {
    sName = stGameSceneConfig.m_LoadingImg,
    eType = DownloadManager.ResourceType.UITexture
  }
  return vPackage, vResourceAB
end

local fullscreen = true
ActiveLuaUI("Form_AttractMain2", Form_AttractMain2)
return Form_AttractMain2
