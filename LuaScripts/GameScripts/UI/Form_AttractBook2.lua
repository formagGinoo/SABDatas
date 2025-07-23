local Form_AttractBook2 = class("Form_AttractBook2", require("UI/UIFrames/Form_AttractBook2UI"))

function Form_AttractBook2:SetInitParam(param)
end

function Form_AttractBook2:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1121)
  self.leftPrefabHelper = self.m_pnl_hero_book_l:GetComponent("PrefabHelper")
  self.rightPrefabHelper = self.m_pnl_hero_book_r:GetComponent("PrefabHelper")
  self.m_desc_rootButton = self.m_desc_root:GetComponent("ButtonExtensions")
  if self.m_desc_rootButton then
    self.m_desc_rootButton.Clicked = handler(self, self.OnBtncheckroleClicked)
  end
end

function Form_AttractBook2:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:FreshUI()
  AttractManager:SetRaycastOn(false)
  self:DealFromBattle()
end

function Form_AttractBook2:OnInactive()
  self.super.OnInactive(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  if self.changePageTimer then
    TimeService:KillTimer(self.changePageTimer)
    self.changePageTimer = nil
  end
  if self.changePage2Timer then
    TimeService:KillTimer(self.changePage2Timer)
    self.changePage2Timer = nil
  end
  UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, "book_r_swich")
  UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, "book_l_swich")
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
end

function Form_AttractBook2:OnDestroy()
  self.super.OnDestroy(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  if self.changePageTimer then
    TimeService:KillTimer(self.changePageTimer)
    self.changePageTimer = nil
  end
  if self.changePage2Timer then
    TimeService:KillTimer(self.changePage2Timer)
    self.changePage2Timer = nil
  end
end

function Form_AttractBook2:InitData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curShowHeroData = HeroManager:GetHeroDataByID(tParam.hero_id)
    self.bIsFromBattle = tParam.bIsFromBattle or false
    self.iCurPage = 0
    self.fCB = tParam.callback
    self.m_csui.m_param = nil
  end
  if not self.m_curShowHeroData then
    return
  end
  local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
  self.mAttractBookCfg = AttractManager:GetAttractArchiveSerializationCfgByHeroID(iHeroId)
  self.mCurHeroAttract = AttractManager:GetHeroAttractById(iHeroId)
  self.iCurPage, self.iCurArchiveId = AttractManager:GetTheNewestPage(iHeroId)
end

function Form_AttractBook2:FreshUI()
  self.iCurPage = self.iCurPage or 0
  self:FreshFirstPage()
  self:FreshPage()
end

function Form_AttractBook2:DealFromBattle()
  if self.bIsFromBattle then
    self.bIsFromBattle = false
    local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
    StackFlow:Push(UIDefines.ID_FORM_ATTRACTLETTER, {
      bIsInAttract = true,
      isReading = true,
      hero_id = iHeroId,
      callback = function()
        local bIsMailSaw = AttractManager:IsMailSaw(iHeroId, self.iCurArchiveId)
        if bIsMailSaw then
          AttractManager:ReqTakeArchiveReward(iHeroId, self.iCurArchiveId, function()
            local cfg = AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID(iHeroId, self.iCurArchiveId)
            local aniName = cfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialLetter and "timeline_in" or "new_discovery_in"
            UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, aniName)
            if self.timer then
              TimeService:KillTimer(self.timer)
              self.timer = nil
            end
            self.timer = TimeService:SetTimer(0.1, 1, function()
              self:FreshPage()
            end)
          end)
        end
      end
    })
    if self.fCB then
      self.fCB("Form_AttractLetter")
      self.fCB = nil
    end
  end
end

function Form_AttractBook2:FreshPage()
  self:FreshLeftPage()
  self:FreshRightPage()
  self:FreshArrow()
  self:FreshRedPoint()
end

function Form_AttractBook2:FreshFirstPage()
  if not self.m_curShowHeroData then
    return
  end
  local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
  local characterCfg = self.m_curShowHeroData.characterCfg
  self.m_txt_hero_name_Text.text = characterCfg.m_mFullName
  self.m_txt_hero_nike_name_Text.text = characterCfg.m_mTitle
  self.m_txt_hero_bd_Text.text = characterCfg.m_mBirthday
  local campCfg = HeroManager:GetCharacterCampCfgByCamp(characterCfg.m_Camp)
  local characterCampSubCfg = ConfigManager:GetConfigInsByName("CharacterCampSub")
  local subCampInfo = characterCampSubCfg:GetValue_ByCampSubID(characterCfg.m_CampSubID)
  self.m_txt_hero_sl_Text.text = campCfg.m_mCampName .. "-" .. subCampInfo.m_mCampSubName
  local iFasionId = HeroManager:GetCurUseFashionID(iHeroId) or 0
  ResourceUtil:CreatHeroBust(self.m_img_head_Image, iHeroId, iFasionId)
  local cfg = AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID(iHeroId, 1)
  if cfg then
    self.m_txt_desc_Text.text = cfg.m_mText
  end
  self.m_scrollview_skil_desc:GetComponent("ScrollRect").verticalNormalizedPosition = 1
end

function Form_AttractBook2:FreshLeftPage()
  local info = self.mAttractBookCfg[self.iCurPage]
  if not info then
    self.m_pnl_hero_book_l:SetActive(false)
    self.m_pnl_hero_book_first:SetActive(true)
    self.m_img_line_l:SetActive(false)
    return
  end
  self.m_pnl_hero_book_l:SetActive(true)
  self.m_pnl_hero_book_first:SetActive(false)
  self.m_img_line_l:SetActive(true)
  utils.ShowPrefabHelper(self.leftPrefabHelper, handler(self, self.FreshPageItem), info)
end

function Form_AttractBook2:FreshRightPage()
  local info = self.mAttractBookCfg[self.iCurPage + 1]
  if not info then
    self.m_pnl_hero_book_r:SetActive(false)
    return
  end
  self.m_pnl_hero_book_r:SetActive(true)
  utils.ShowPrefabHelper(self.rightPrefabHelper, handler(self, self.FreshPageItem), info)
end

function Form_AttractBook2:FreshPageItem(go, idx, attractArchiveCfg)
  local transform = go.transform
  local index = idx + 1
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
  local iArchiveId = attractArchiveCfg.m_ArchiveId
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline", false)
  local bIsUnlock, iUnlockAttractRank = AttractManager:IsArchiveUnlock(iHeroId, iArchiveId)
  local bIsRewardRecived = AttractManager:IsArchiveRewardRecived(iHeroId, iArchiveId)
  if attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.NormalStory then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02", true)
    if bIsUnlock then
      if bIsRewardRecived then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_normal", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_unlock", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_lock", false)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt02_light", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt02_dark", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title02", attractArchiveCfg.m_mTitle)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_desc02", attractArchiveCfg.m_mText)
        LuaBehaviourUtil.findGameObject(luaBehaviour, "m_scrollview_skil_desc02"):GetComponent("ScrollRect").verticalNormalizedPosition = 1
      else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_normal", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_unlock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_lock", false)
        local vReward = utils.changeCSArrayToLuaTable(attractArchiveCfg.m_Rewards)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_redpoint_txt02_unlock", 0 < #vReward)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_title02_unlock", ConfigManager:GetCommonTextById(100804))
      end
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_normal", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_unlock", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt02_lock", true)
      if iUnlockAttractRank then
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title02_lock", string.gsubNumberReplace(ConfigManager:GetCommonTextById(100801), iUnlockAttractRank))
      else
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title02_lock", ConfigManager:GetCommonTextById(100802))
      end
    end
  elseif attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialStory then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01", true)
    if bIsUnlock then
      if bIsRewardRecived then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_normal", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_unlock", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_lock", false)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt01_light", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt01_dark", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setImg(luaBehaviour, "m_icon_item01", attractArchiveCfg.m_ArchivePic)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title01", attractArchiveCfg.m_mTitle)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_desc01", attractArchiveCfg.m_mText)
        LuaBehaviourUtil.findGameObject(luaBehaviour, "m_scrollview_skil_desc01"):GetComponent("ScrollRect").verticalNormalizedPosition = 1
      else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_normal", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_unlock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_lock", false)
        local vReward = utils.changeCSArrayToLuaTable(attractArchiveCfg.m_Rewards)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_redpoint_txt01_unlock", 0 < #vReward)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_title01_unlock", ConfigManager:GetCommonTextById(100804))
      end
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_normal", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_unlock", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt01_lock", true)
      if iUnlockAttractRank then
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title01_lock", string.gsubNumberReplace(ConfigManager:GetCommonTextById(100801), iUnlockAttractRank))
      else
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title01_lock", ConfigManager:GetCommonTextById(100802))
      end
    end
  elseif attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialStory2 then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03", true)
    if bIsUnlock then
      if bIsRewardRecived then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_normal", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_unlock", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_lock", false)
        LuaBehaviourUtil.setImg(luaBehaviour, "m_icon_item03", attractArchiveCfg.m_ArchivePic)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt03_light", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt03_dark", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title03", attractArchiveCfg.m_mTitle)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_desc03", attractArchiveCfg.m_mText)
        LuaBehaviourUtil.findGameObject(luaBehaviour, "m_scrollview_skil_desc03"):GetComponent("ScrollRect").verticalNormalizedPosition = 1
      else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_normal", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_unlock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_lock", false)
        local vReward = utils.changeCSArrayToLuaTable(attractArchiveCfg.m_Rewards)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_redpoint_txt03_unlock", 0 < #vReward)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_title03_unlock", ConfigManager:GetCommonTextById(100804))
      end
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_normal", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_unlock", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt03_lock", true)
      if iUnlockAttractRank then
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title03_lock", string.gsubNumberReplace(ConfigManager:GetCommonTextById(100801), iUnlockAttractRank))
      else
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title03_lock", ConfigManager:GetCommonTextById(100802))
      end
    end
  elseif attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialStory3 then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04", true)
    if bIsUnlock then
      if bIsRewardRecived then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_normal", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_unlock", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_lock", false)
        LuaBehaviourUtil.setImg(luaBehaviour, "m_icon_item04", attractArchiveCfg.m_ArchivePic)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt04_light", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_txt04_dark", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title04", attractArchiveCfg.m_mTitle)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_desc04", attractArchiveCfg.m_mText)
        LuaBehaviourUtil.findGameObject(luaBehaviour, "m_scrollview_skil_desc04"):GetComponent("ScrollRect").verticalNormalizedPosition = 1
      else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_normal", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_unlock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_lock", false)
        local vReward = utils.changeCSArrayToLuaTable(attractArchiveCfg.m_Rewards)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_redpoint_txt04_unlock", 0 < #vReward)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_title04_unlock", ConfigManager:GetCommonTextById(100804))
      end
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_normal", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_unlock", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_txt04_lock", true)
      if iUnlockAttractRank then
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title04_lock", string.gsubNumberReplace(ConfigManager:GetCommonTextById(100801), iUnlockAttractRank))
      else
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_title04_lock", ConfigManager:GetCommonTextById(100802))
      end
    end
  elseif attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.NormalLetter then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01", true)
    if bIsUnlock then
      if bIsRewardRecived then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_normal", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_unlock", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_lock", false)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_mail01_light", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_mail01_dark", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_mail01", attractArchiveCfg.m_mTitle)
        LuaBehaviourUtil.setImg(luaBehaviour, "m_icon_mail01", attractArchiveCfg.m_MailPic)
      else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_normal", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_unlock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_lock", false)
        local bIsMailSaw = AttractManager:IsMailSaw(iHeroId, iArchiveId)
        local vReward = utils.changeCSArrayToLuaTable(attractArchiveCfg.m_Rewards)
        if bIsMailSaw then
          LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_mail01_unlock", ConfigManager:GetCommonTextById(100806))
          LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_redpointnml_mail01_unlock", 0 < #vReward)
        else
          LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_mail01_unlock", ConfigManager:GetCommonTextById(100805))
          LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_redpointnml_mail01_unlock", 0 < #vReward)
        end
        LuaBehaviourUtil.setImg(luaBehaviour, "m_img_bg_mail01_unlock", attractArchiveCfg.m_MailPicLock)
      end
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_normal", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_unlock", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_mail01_lock", true)
      if iUnlockAttractRank then
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_mail01_lock", string.gsubNumberReplace(ConfigManager:GetCommonTextById(100801), iUnlockAttractRank))
      else
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_mail01_lock", ConfigManager:GetCommonTextById(100802))
      end
    end
  elseif attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialLetter then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline", true)
    if bIsUnlock then
      if bIsRewardRecived then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_normal", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_unlock", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_lock", false)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_timeline_light", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_num_timeline_dark", attractArchiveCfg.m_ArchiveId - 1)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_timeline", attractArchiveCfg.m_mTitle)
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_desc_timeline", attractArchiveCfg.m_mText)
      else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_normal", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_unlock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_lock", false)
        local vReward = utils.changeCSArrayToLuaTable(attractArchiveCfg.m_Rewards)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_gift_timeline_unlock", 0 < #vReward)
        local bIsMailSaw = AttractManager:IsMailSaw(iHeroId, iArchiveId)
        if bIsMailSaw then
          LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_timeline_unlock", ConfigManager:GetCommonTextById(100808))
        else
          LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_timeline_unlock", ConfigManager:GetCommonTextById(100807))
        end
      end
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_lock", true)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_normal", false)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_nml_timeline_unlock", false)
      if iUnlockAttractRank then
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_timeline_lock", string.gsubNumberReplace(ConfigManager:GetCommonTextById(100801), iUnlockAttractRank))
      else
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_timeline_lock", ConfigManager:GetCommonTextById(100802))
      end
    end
  end
  local btn = transform:GetComponent("ButtonExtensions")
  local params = {
    iHeroId = iHeroId,
    attractArchiveCfg = attractArchiveCfg,
    bIsUnlock = bIsUnlock,
    bIsRewardRecived = bIsRewardRecived,
    iArchiveId = iArchiveId,
    go = go
  }
  btn.Clicked = handler1(self, self.OnBtnItemClicked, params)
end

function Form_AttractBook2:OnBtnItemClicked(params)
  local iHeroId = params.iHeroId
  local attractArchiveCfg = params.attractArchiveCfg
  local bIsUnlock = params.bIsUnlock
  local bIsRewardRecived = params.bIsRewardRecived
  local iArchiveId = params.iArchiveId
  if not bIsUnlock then
    return
  end
  if not bIsRewardRecived then
    if attractArchiveCfg.m_ArchiveType == AttractManager.ArchiveType.Story then
      StackFlow:Push(UIDefines.ID_FORM_ATTRACTMAILPOP1, {
        attractArchiveCfg = attractArchiveCfg,
        callback = function()
          AttractManager:ReqTakeArchiveReward(iHeroId, iArchiveId, function()
            UILuaHelper.PlayAnimationByName(params.go, "new_discovery_in")
            if self.timer then
              TimeService:KillTimer(self.timer)
              self.timer = nil
            end
            self.timer = TimeService:SetTimer(0.1, 1, function()
              self:FreshPage()
            end)
          end)
        end
      })
    elseif attractArchiveCfg.m_ArchiveType == AttractManager.ArchiveType.Letter then
      local bIsMailSaw = AttractManager:IsMailSaw(iHeroId, iArchiveId)
      
      local function RequestTakeReward()
        AttractManager:ReqTakeArchiveReward(iHeroId, iArchiveId, function()
          local aniName = attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialLetter and "timeline_in" or "new_discovery_in"
          UILuaHelper.PlayAnimationByName(params.go, aniName)
          if self.timer then
            TimeService:KillTimer(self.timer)
            self.timer = nil
          end
          self.timer = TimeService:SetTimer(0.1, 1, function()
            self:FreshPage()
          end)
        end)
      end
      
      if bIsMailSaw then
        RequestTakeReward()
      else
        StackFlow:Push(UIDefines.ID_FORM_ATTRACTLETTER, {
          bIsInAttract = true,
          isReading = true,
          hero_id = iHeroId,
          callback = function()
            bIsMailSaw = AttractManager:IsMailSaw(iHeroId, iArchiveId)
            if bIsMailSaw then
              RequestTakeReward()
            end
          end
        })
      end
    end
    return
  end
  if attractArchiveCfg.m_ArchiveType == AttractManager.ArchiveType.Story then
    StackFlow:Push(UIDefines.ID_FORM_ATTRACTMAILPOP1, {attractArchiveCfg = attractArchiveCfg})
  elseif attractArchiveCfg.m_ArchiveType == AttractManager.ArchiveType.Letter then
    if attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.NormalLetter then
      StackFlow:Push(UIDefines.ID_FORM_ATTRACTLETTER, {
        bIsInAttract = true,
        isReading = false,
        hero_id = iHeroId,
        iLetterId = attractArchiveCfg.m_LetterId
      })
    elseif attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialLetter then
      self.m_UILockID = UILockIns:Lock(1)
      local externRes = {}
      local depen = CS.VisualFavorability.GetDepenResource(attractArchiveCfg.m_TimelineType, attractArchiveCfg.m_TimelineId)
      for k, v in pairs(depen) do
        table.insert(externRes, {sName = k, eType = v})
      end
      DownloadManager:DownloadResourceWithUI(nil, externRes, "Form_AttractBook2:OnClickAcceptInviteCallback", nil, nil, function()
        self:OnClickAcceptInviteCallback(attractArchiveCfg)
      end, nil, nil, nil, nil, function()
        if self.m_UILockID then
          UILockIns:Unlock(self.m_UILockID)
          self.m_UILockID = nil
        end
      end)
    end
  end
end

function Form_AttractBook2:OnClickAcceptInviteCallback(attractArchiveCfg)
  if self.m_UILockID then
    UILockIns:Unlock(self.m_UILockID)
    self.m_UILockID = nil
  end
  self.m_UILockID = UILockIns:Lock(10)
  CS.VisualFavorability.LoadFavorability(attractArchiveCfg.m_TimelineType, attractArchiveCfg.m_TimelineId, function()
    CS.UI.UILuaHelper.HideMainUI()
    if self.m_UILockID then
      UILockIns:Unlock(self.m_UILockID)
      self.m_UILockID = nil
    end
  end, function()
    CS.UI.UILuaHelper.ShowMainUI()
    AttractManager:ResetCamera()
  end)
end

function Form_AttractBook2:FreshArrow()
  if self.iCurPage == 0 then
    self.m_btn_arrow_l:SetActive(false)
  else
    self.m_btn_arrow_l:SetActive(true)
  end
  if self.iCurPage + 2 > #self.mAttractBookCfg then
    self.m_btn_arrow_r:SetActive(false)
  else
    self.m_btn_arrow_r:SetActive(true)
  end
end

function Form_AttractBook2:FreshRedPoint()
  local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
  local tempRedPage = AttractManager:IsHaveRewardCanTake(iHeroId)
  if tempRedPage then
    self.m_redpoint_l:SetActive(tempRedPage < self.iCurPage)
    self.m_redpoint_r:SetActive(tempRedPage - 1 > self.iCurPage)
  else
    self.m_redpoint_l:SetActive(false)
    self.m_redpoint_r:SetActive(false)
  end
end

function Form_AttractBook2:OnBtnarrowlClicked()
  if self.iCurPage > 0 then
    self.iCurPage = self.iCurPage - 2
    UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, "book_r_swich")
    UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, "book_l_swich")
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "book_l_swich")
    if self.changePageTimer then
      TimeService:KillTimer(self.changePageTimer)
      self.changePageTimer = nil
    end
    if self.changePage2Timer then
      TimeService:KillTimer(self.changePage2Timer)
      self.changePage2Timer = nil
    end
    self.changePageTimer = TimeService:SetTimer(0.2, 1, function()
      self:FreshLeftPage()
      self:FreshArrow()
      self:FreshRedPoint()
    end)
    self.changePage2Timer = TimeService:SetTimer(0.49, 1, function()
      self:FreshRightPage()
    end)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(66)
  end
end

function Form_AttractBook2:OnBtnarrowrClicked()
  if self.iCurPage + 2 <= #self.mAttractBookCfg then
    self.iCurPage = self.iCurPage + 2
    UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, "book_r_swich")
    UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, "book_l_swich")
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "book_r_swich")
    if self.changePageTimer then
      TimeService:KillTimer(self.changePageTimer)
      self.changePageTimer = nil
    end
    if self.changePage2Timer then
      TimeService:KillTimer(self.changePage2Timer)
      self.changePage2Timer = nil
    end
    self.changePageTimer = TimeService:SetTimer(0.2, 1, function()
      self:FreshRightPage()
      self:FreshArrow()
      self:FreshRedPoint()
    end)
    self.changePage2Timer = TimeService:SetTimer(0.49, 1, function()
      self:FreshLeftPage()
    end)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(66)
  end
end

function Form_AttractBook2:OnBackClk()
  self:CloseForm()
end

function Form_AttractBook2:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_AttractBook2:OnBtncheckroleClicked()
  local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTMAILPOP1, {
    attractArchiveCfg = AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID(iHeroId, 1)
  })
end

function Form_AttractBook2:IsFullScreen()
  return true
end

function Form_AttractBook2:GetDownloadResourceExtra(params)
  local CfgIns = ConfigManager:GetConfigInsByName("AttractArchive")
  local cfgs = CfgIns:GetAll()
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "TimelineDependency",
    eType = DownloadManager.ResourceType.Bytes
  }
  for k, v in pairs(cfgs) do
    if v.m_HeroID and v.m_HeroID > 0 then
      for _, cfg in ipairs(v) do
        if cfg.m_TimelineType and cfg.m_TimelineType == 1 then
          vResourceExtra[#vResourceExtra + 1] = {
            sName = cfg.m_TimelineId,
            eType = DownloadManager.ResourceType.MaterialReplace
          }
        end
      end
    end
  end
  return nil, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_AttractBook2", Form_AttractBook2)
return Form_AttractBook2
