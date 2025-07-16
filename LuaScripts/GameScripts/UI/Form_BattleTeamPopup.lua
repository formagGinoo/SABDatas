local Form_BattleTeamPopup = class("Form_BattleTeamPopup", require("UI/UIFrames/Form_BattleTeamPopupUI"))

function Form_BattleTeamPopup:SetInitParam(param)
end

function Form_BattleTeamPopup:AfterInit()
  self.super.AfterInit(self)
end

function Form_BattleTeamPopup:OnActive()
  self.super.OnActive(self)
  self.replaceData = self.m_csui.m_param
  self:InitView()
  self:AddEventListeners()
end

function Form_BattleTeamPopup:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_BattleTeamPopup:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattleTeamPopup:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetForm", handler(self, self.OnEventSetForm))
end

function Form_BattleTeamPopup:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattleTeamPopup:InitView()
  local charIds = {}
  if self.replaceData.data.serverData then
    for i = 1, #self.replaceData.data.serverData.vHeroId do
      table.insert(charIds, self.replaceData.data.serverData.vHeroId[i])
    end
  end
  self:initItemView(self.m_item_team, self.replaceData.data.teamName, charIds)
  self:initItemView(self.m_item_team_new, self.replaceData.data.teamName, self.replaceData.replaceCharIds)
end

function Form_BattleTeamPopup:initItemView(itemObj, teamName, charIds)
  itemObj.transform:Find("m_pnl_normal/m_txt_name"):GetComponent("TMPPro").text = teamName
  itemObj.transform:Find("m_bg_empty/m_txt_name_empty"):GetComponent("TMPPro").text = teamName
  local heroRoot = itemObj.transform:Find("m_pnl_normal/pnl_hero_list").gameObject
  local tempRoot = itemObj.transform:Find("m_pnl_normal/pnl_hero_list/c_common_hero_small").gameObject
  for i = 1, heroRoot.transform.childCount do
    heroRoot.transform:GetChild(i - 1).gameObject:SetActive(false)
  end
  local m_pnl_normal = itemObj.transform:Find("m_pnl_normal").gameObject
  local m_bg_empty = itemObj.transform:Find("m_bg_empty").gameObject
  if 0 < #charIds then
    m_pnl_normal:SetActive(true)
    m_bg_empty:SetActive(false)
    for i = 1, #charIds do
      local heroObj
      if i <= heroRoot.transform.childCount then
        heroObj = heroRoot.transform:GetChild(i - 1).gameObject
      else
        heroObj = GameObject.Instantiate(tempRoot, heroRoot.transform).gameObject
      end
      heroObj:SetActive(true)
      self:initHeroView(heroObj, charIds[i])
    end
  else
    m_pnl_normal:SetActive(false)
    m_bg_empty:SetActive(true)
  end
end

function Form_BattleTeamPopup:initHeroView(heroObj, heroID)
  local heroData = HeroManager:GetHeroDataByID(heroID)
  local iBreak = 0
  if heroData then
    heroObj.transform:Find("c_battle_card/c_txt_lv_num"):GetComponent(T_TextMeshProUGUI).text = string.format(ConfigManager:GetCommonTextById(20033), tostring(heroData.serverData.iLevel))
    iBreak = heroData.serverData.iBreak
  end
  local characterInfoCfg = ConfigManager:GetConfigInsByName("CharacterInfo")
  local characterCfg = characterInfoCfg:GetValue_ByHeroID(heroID)
  if not characterCfg:GetError() then
    local performanceID = characterCfg.m_PerformanceID[0]
    local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
    local m_imgHead = heroObj.transform:Find("c_battle_card/pnl_head_mask/c_img_head"):GetComponent(T_Image)
    local szIcon = presentationData.m_UIkeyword .. "001"
    UILuaHelper.SetAtlasSprite(m_imgHead, szIcon)
    heroObj.transform:Find("c_bg_moon").gameObject:SetActive(true)
    heroObj.transform:Find("c_bg_moon/c_icon_moon1").gameObject:SetActive(characterCfg.m_MoonType == 1)
    heroObj.transform:Find("c_bg_moon/c_icon_moon2").gameObject:SetActive(characterCfg.m_MoonType == 2)
    heroObj.transform:Find("c_bg_moon/c_icon_moon3").gameObject:SetActive(characterCfg.m_MoonType == 3)
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

function Form_BattleTeamPopup:OnEventSetForm(param)
  self:CloseForm()
end

function Form_BattleTeamPopup:OnBtnnoClicked()
  self:CloseForm()
end

function Form_BattleTeamPopup:OnBtnyesClicked()
  HeroManager:ReqSetPreset(self.replaceData.data.presetID, self.replaceData.replaceCharIds)
end

local fullscreen = true
ActiveLuaUI("Form_BattleTeamPopup", Form_BattleTeamPopup)
return Form_BattleTeamPopup
