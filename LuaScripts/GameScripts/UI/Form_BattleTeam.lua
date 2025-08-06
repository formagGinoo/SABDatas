local Form_BattleTeam = class("Form_BattleTeam", require("UI/UIFrames/Form_BattleTeamUI"))

function Form_BattleTeam:SetInitParam(param)
end

function Form_BattleTeam:AfterInit()
  self.super.AfterInit(self)
  self.TeamMaxCount = 6
  self.TeamNames = {
    "01",
    "02",
    "03",
    "04",
    "05",
    "06"
  }
  self.rootAnimation = self.m_csui.m_uiGameObject.transform:GetComponent("Animation")
end

function Form_BattleTeam:ActiveRootUI()
  self.rootAnimation.gameObject:SetActive(true)
  self.rootAnimation:Play("in")
end

function Form_BattleTeam:OnActive()
  self.rootAnimation.gameObject:SetActive(false)
  GuideManager:AddFrame(1, handler(self, self.ActiveRootUI), nil, "Form_BattleTeam")
  self.super.OnActive(self)
  local fight_Type = CS.BattleGlobalManager.Instance:GetSaveInt(4)
  if fight_Type == MTTDProto.FightType_SoloRaid then
    self.FormTypeBase = HeroManager.TeamTypeBase.SoloRaid
    self.m_UseHero = PersonalRaidManager:GetSoloRaidmUseHero()
  else
    self.m_UseHero = {}
    self.FormTypeBase = HeroManager.TeamTypeBase.Default
  end
  if self.m_csui.m_param.isBattleResult then
    self.m_UseHero = {}
  end
  self.replaceCharIds = {}
  if self.m_csui.m_param.isLuaTable then
    self.replaceCharIds = self.m_csui.m_param.list
  else
    for i = 1, self.m_csui.m_param.Count do
      table.insert(self.replaceCharIds, self.m_csui.m_param[i - 1])
    end
  end
  self.recoValue = CS.BattleGlobalManager.Instance:GetRecoValue()
  self.notRecoValue = CS.BattleGlobalManager.Instance:GetNotRecoValue()
  self:InitView()
  self:AddEventListeners()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(328)
end

function Form_BattleTeam:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_BattleTeam:OnDestroy()
  GuideManager:RemoveFrameByKey("CloseBattleTeam")
  GuideManager:RemoveFrameByKey("Form_BattleTeam")
end

function Form_BattleTeam:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetForm", handler(self, self.OnEventSetForm))
end

function Form_BattleTeam:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattleTeam:OnEventSetForm(param)
  local allFormDic = HeroManager:GetPresetDic() or {}
  self.replaceCharIds = {}
  for i = 1, self.m_viewContent.transform.childCount do
    local itemObj = self.m_viewContent.transform:GetChild(i - 1).gameObject
    local mask_replace = itemObj.transform:Find("mask_replace").gameObject
    mask_replace:SetActive(false)
  end
  local teamData = {}
  local teamIdx = HeroManager:GetTeamIdxByTypeBaseAndTeamType(self.FormTypeBase, self.replacePresetID)
  teamData.teamName = self.TeamNames[teamIdx]
  teamData.presetID = self.replacePresetID
  teamData.serverData = allFormDic[self.replacePresetID]
  teamData.iPower = 0
  if teamData.serverData then
    teamData.iPower = teamData.serverData.iPower
  end
  self:initItemView(self.replaceItemObj, teamData, true)
end

function Form_BattleTeam:InitView()
  self:UpdateView()
end

function Form_BattleTeam:UpdateView()
  self.m_common_item_team:SetActive(false)
  local allFormDic = HeroManager:GetPresetDic() or {}
  self.teamDatas = {}
  for i = 1, self.TeamMaxCount do
    local teamData = {}
    teamData.teamName = self.TeamNames[i]
    teamData.presetID = HeroManager:GetTeamTypeByTeamIdxAndTypeBase(self.FormTypeBase, i)
    teamData.serverData = allFormDic[HeroManager:GetTeamTypeByTeamIdxAndTypeBase(self.FormTypeBase, i)]
    teamData.iPower = 0
    if teamData.serverData then
      teamData.iPower = teamData.serverData.iPower
    end
    table.insert(self.teamDatas, teamData)
  end
  
  local function sortFun(data1, data2)
    local value1 = self.TeamMaxCount - data1.presetID + data1.iPower
    local value2 = self.TeamMaxCount - data2.presetID + data2.iPower
    return value1 > value2
  end
  
  for i = 1, #self.teamDatas do
    local itemObj
    if i <= self.m_viewContent.transform.childCount then
      itemObj = self.m_viewContent.transform:GetChild(i - 1).gameObject
    else
      itemObj = GameObject.Instantiate(self.m_common_item_team, self.m_viewContent.transform).gameObject
    end
    itemObj:SetActive(true)
    self:initItemView(itemObj, self.teamDatas[i], false)
  end
end

function Form_BattleTeam:initItemView(itemObj, data, isUpdate)
  itemObj.transform:Find("m_pnl_normal/m_txt_name"):GetComponent("TMPPro").text = data.teamName
  itemObj.transform:Find("m_bg_empty/m_txt_name_empty"):GetComponent("TMPPro").text = data.teamName
  local heroRoot = itemObj.transform:Find("m_pnl_normal/pnl_hero_list").gameObject
  local tempRoot = itemObj.transform:Find("m_pnl_normal/pnl_hero_list/c_common_hero_small").gameObject
  for i = 1, heroRoot.transform.childCount do
    heroRoot.transform:GetChild(i - 1).gameObject:SetActive(false)
  end
  local formationAvailable = true
  local m_pnl_normal = itemObj.transform:Find("m_pnl_normal").gameObject
  local m_bg_empty = itemObj.transform:Find("m_bg_empty").gameObject
  local is_all_banned = true
  if data.serverData then
    m_pnl_normal:SetActive(true)
    m_bg_empty:SetActive(false)
    for i = 1, #data.serverData.vHeroId do
      local heroObj
      if i <= heroRoot.transform.childCount then
        heroObj = heroRoot.transform:GetChild(i - 1).gameObject
      else
        heroObj = GameObject.Instantiate(tempRoot, heroRoot.transform).gameObject
      end
      heroObj:SetActive(true)
      self:initHeroView(heroObj, data.serverData.vHeroId[i])
      if not self.m_UseHero[data.serverData.vHeroId[i]] then
        is_all_banned = false
      end
    end
    local inputData = {
      chars = data.serverData.vHeroId
    }
    formationAvailable = CS.UI.UILuaHelper.FormationAvailable(inputData)
  else
    m_pnl_normal:SetActive(false)
    m_bg_empty:SetActive(true)
  end
  local m_tag_recommend = itemObj.transform:Find("m_tag_recommend").gameObject
  m_tag_recommend:SetActive(false)
  local m_tag_recommend_no = itemObj.transform:Find("m_tag_recommend_no").gameObject
  m_tag_recommend_no:SetActive(false)
  local m_mask_unable = itemObj.transform:Find("m_mask_unable").gameObject
  m_mask_unable:SetActive(false)
  if formationAvailable then
    if data.iPower > self.recoValue then
      m_tag_recommend:SetActive(true)
    elseif data.iPower < self.notRecoValue and data.iPower > 0 then
      m_tag_recommend_no:SetActive(true)
    end
  else
    m_mask_unable:SetActive(true)
  end
  local mask_replace = itemObj.transform:Find("mask_replace").gameObject
  if 0 < #self.replaceCharIds then
    mask_replace:SetActive(true)
    local replaceAnimation = mask_replace.transform:GetComponent("Animation")
    replaceAnimation:Play("tihuan_loop")
    local replaceButton = mask_replace:GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(self, replaceButton, function()
      local replaceData = {}
      replaceData.data = data
      replaceData.replaceCharIds = self.replaceCharIds
      StackFlow:Push(UIDefines.ID_FORM_BATTLETEAMPOPUP, replaceData)
      self.replaceItemObj = itemObj
      self.replacePresetID = data.presetID
    end)
  else
    mask_replace:SetActive(false)
  end
  local btn_formation = itemObj.transform:Find("m_btn_formation").gameObject
  btn_formation:SetActive(true)
  local formationButton = btn_formation:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(self, formationButton, function()
    if is_all_banned then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20054)
      return
    end
    if not data.serverData or #data.serverData.vHeroId == 0 then
      return
    end
    if not formationAvailable then
      return
    end
    local inputData = {
      chars = data.serverData.vHeroId
    }
    CS.UI.UILuaHelper.PresetFormation(inputData)
    self:CloseForm()
  end)
end

function Form_BattleTeam:initHeroView(heroObj, heroID)
  local heroData = HeroManager:GetHeroDataByID(heroID)
  local iBreak = 0
  if heroData then
    heroObj.transform:Find("c_battle_card/c_txt_lv_num"):GetComponent(T_TextMeshProUGUI).text = string.format(ConfigManager:GetCommonTextById(20033), tostring(heroData.serverData.iLevel))
    iBreak = heroData.serverData.iBreak
  end
  local characterInfoCfg = ConfigManager:GetConfigInsByName("CharacterInfo")
  local characterCfg = characterInfoCfg:GetValue_ByHeroID(heroID)
  local fashionInfo = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(heroData.serverData.iHeroId, heroData.serverData.iFashion)
  if fashionInfo and not characterCfg:GetError() then
    local performanceID = fashionInfo.m_PerformanceID[0]
    local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
    local m_imgHead = heroObj.transform:Find("c_battle_card/pnl_head_mask/c_img_head"):GetComponent(T_Image)
    local szIcon = presentationData.m_UIkeyword .. "001"
    UILuaHelper.SetAtlasSprite(m_imgHead, szIcon)
    heroObj.transform:Find("c_bg_moon").gameObject:SetActive(true)
    heroObj.transform:Find("c_bg_moon/c_icon_moon1").gameObject:SetActive(characterCfg.m_MoonType == 1)
    heroObj.transform:Find("c_bg_moon/c_icon_moon2").gameObject:SetActive(characterCfg.m_MoonType == 2)
    heroObj.transform:Find("c_bg_moon/c_icon_moon3").gameObject:SetActive(characterCfg.m_MoonType == 3)
    heroObj.transform:Find("c_bg_prohibit").gameObject:SetActive(self.m_UseHero[heroID])
    UILuaHelper.InitBreakView(heroObj.transform:Find("c_battle_card/c_list_star").gameObject, iBreak, characterCfg.m_Quality)
    UILuaHelper.InitCarrerViewTeam(heroObj.transform:Find("c_pnl_left_top/c_img_career").gameObject, characterCfg.m_Career)
    if not characterCfg.m_Quality then
      return
    end
    local pathData = QualityPathCfg[characterCfg.m_Quality]
    local borderObj = heroObj.transform:Find("c_battle_card/c_img_border"):GetComponent(T_Image)
    local border2Obj = heroObj.transform:Find("c_battle_card/c_img_border/c_img_border2"):GetComponent(T_Image)
    if borderObj then
      UILuaHelper.SetAtlasSprite(borderObj, pathData.borderImgPath)
    end
    if border2Obj then
      UILuaHelper.SetAtlasSprite(border2Obj, pathData.borderImgPath)
    end
  else
    log.error("CharacterInfo not find heroID=" .. heroID)
  end
end

function Form_BattleTeam:OnBtnmaskClicked()
  self:CloseBattleTeam()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(327)
end

function Form_BattleTeam:CloseBattleTeam()
  GuideManager:RemoveFrameByKey("CloseBattleTeam")
  self.rootAnimation = self.m_csui.m_uiGameObject.transform:GetComponent("Animation")
  self.rootAnimation:Play("out2")
  local clip = self.rootAnimation:GetClip("out2")
  local closeTime = clip.length
  GuideManager:AddTimer(closeTime, handler(self, self.CloseForm), nil, "CloseBattleTeam")
  for i = 1, self.m_viewContent.transform.childCount do
    local itemObj = self.m_viewContent.transform:GetChild(i - 1).gameObject
  end
end

function Form_BattleTeam:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BattleTeam", Form_BattleTeam)
return Form_BattleTeam
