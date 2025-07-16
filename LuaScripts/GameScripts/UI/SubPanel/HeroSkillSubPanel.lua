local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroSkillSubPanel = class("HeroSkillSubPanel", UISubPanelBase)
local SkillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
local InGameSkillInstance = ConfigManager:GetConfigInsByName("Skill")
local SkillBuffIns = ConfigManager:GetConfigInsByName("SkillBuff")
local String_format = string.format
local EnterAnimStr = "herodetail_panel_base_in"

function HeroSkillSubPanel:OnInit()
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_curChooseHeroIndex = nil
  self.m_chooseSkillId = nil
  self.m_skillList = {}
  self.m_heroSkillGroupID = nil
  self.m_maxSkillLv = 0
  self.m_costItemList = {}
  self.m_needItemList = {}
  self.m_buffItemList = {}
  self.m_buffCfgDataList = nil
  self.m_curRot = 270
  self.m_targetRot = 270
  self.timeElapsed = 0
  self.m_takeRotTime = 0.12
  self.uiElement = self.m_select_Arrow.transform:GetComponent("RectTransform")
  self.m_buffItemList[1] = self:InitBuffItem(self.m_baseBuff, 1)
end

function HeroSkillSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.heroData
  self.m_allHeroList = self.m_panelData.allHeroList
  self.m_curChooseHeroIndex = self.m_panelData.chooseIndex
  local serverData = self.m_curShowHeroData.serverData
  local heroCfg = self.m_curShowHeroData.characterCfg
  self.m_heroSkillGroupID = heroCfg.m_SkillGroupID[0]
  self.m_lockLevelUpBtn = false
  self.m_needItemList = {}
  if self.m_curHeroId ~= serverData.iHeroId then
    self:FreshShowSkillInfo(self.m_heroSkillGroupID)
    self.m_curHeroId = serverData.iHeroId
  end
  self:RefreshSkillInfo()
  self:RefreshSkillPanelSkillResetState()
end

function HeroSkillSubPanel:RefreshSkillPanelSkillResetState()
  local posY = self.m_uiVariables.SkillPanelPosY
  local isOpen = HeroManager:CheckHeroSkillResetActivityIsOpen()
  if isOpen then
    posY = self.m_uiVariables.SkillPanelPosYAct
  end
  local posX, _, PosZ = UILuaHelper.GetLocalPosition(self.m_pnl_skill_list)
  UILuaHelper.SetLocalPosition(self.m_pnl_skill_list, posX, posY, PosZ)
  local isEnough = HeroManager:CheckSkillResetIsEnough()
  local lvUP = HeroManager:CheckHeroSkillLvUp(self.m_curHeroId)
  self.m_btn_reset:SetActive(isOpen and isEnough and lvUP)
end

function HeroSkillSubPanel:OnActivePanel()
  self.m_openTime = TimeUtil:GetServerTimeS()
  ReportManager:ReportSystemOpen(GlobalConfig.SYSTEM_ID.SkillLevelUp, self.m_openTime)
  self:AddEventListeners()
end

function HeroSkillSubPanel:OnHidePanel()
  ReportManager:ReportSystemClose(GlobalConfig.SYSTEM_ID.SkillLevelUp, self.m_openTime)
  self:RemoveAllEventListeners()
  if self.m_sequence then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
end

function HeroSkillSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SkillLevelUp", handler(self, self.OnSkillLevelUp))
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.RefreshSkillInfo))
end

function HeroSkillSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroSkillSubPanel:FreshShowSkillInfo(skillGroupID)
  if not skillGroupID then
    return
  end
  local skillGroupCfgList = HeroManager:GetSkillGroupCfgList(skillGroupID)
  local OverMaxSkillTag = #HeroManager.HeroSkillTagSort + 1
  table.sort(skillGroupCfgList, function(a, b)
    local skillTagA = a.m_SkillShowType
    local skillTagB = b.m_SkillShowType
    local skillSortA = HeroManager.HeroSkillTagSort[skillTagA] or OverMaxSkillTag
    local skillSortB = HeroManager.HeroSkillTagSort[skillTagB] or OverMaxSkillTag
    return skillSortA < skillSortB
  end)
  local skillCfgList = {}
  for _, skillGroupCfg in ipairs(skillGroupCfgList) do
    local skillID = skillGroupCfg.m_SkillID
    if skillID then
      local tempSkillCfg = HeroManager:GetSkillConfigById(skillID)
      skillCfgList[#skillCfgList + 1] = tempSkillCfg
    end
  end
  if not skillCfgList[1] then
    log.error("can not find hero skillCfg skillGroupID == " .. tostring(skillGroupID))
    return
  end
  self.m_chooseSkillId = skillCfgList[1].m_SkillID
  self.m_curRot = 270
  self.m_targetRot = 270
  UILuaHelper.SetLocalEuler(self.uiElement, 0, 0, self.m_curRot)
  self.m_skillList = skillCfgList
  for i = 1, GlobalConfig.HERO_SKILL_COUNT do
    local skillCfg = skillCfgList[i]
    if skillCfg then
      self["m_btn_skill0" .. i]:SetActive(true)
      UILuaHelper.SetAtlasSprite(self[String_format("m_icon_kill0%d_Image", i)], skillCfg.m_Skillicon)
    else
      self["m_btn_skill0" .. i]:SetActive(false)
    end
  end
end

function HeroSkillSubPanel:RefreshSkillInfo()
  self.m_maxSkillLv = HeroManager:GetSkillMaxLevelById(self.m_heroSkillGroupID, self.m_chooseSkillId)
  local selSkillLv = 1
  for i = 1, #self.m_skillList do
    local skillLv = HeroManager:GetHeroSkillLvById(self.m_curHeroId, self.m_skillList[i].m_SkillID)
    local maxSkillLv = HeroManager:GetSkillMaxLevelById(self.m_heroSkillGroupID, self.m_skillList[i].m_SkillID)
    if skillLv == maxSkillLv and maxSkillLv == 1 then
      self["m_img_skill_rectangle0" .. i]:SetActive(false)
      self["m_txt_skill_lv_num0" .. i .. "_Text"].text = ""
    else
      self["m_img_skill_rectangle0" .. i]:SetActive(true)
      self["m_txt_skill_lv_num0" .. i .. "_Text"].text = tostring(skillLv)
    end
    if self.m_skillList[i].m_SkillID == self.m_chooseSkillId then
      selSkillLv = skillLv
    end
    self["m_select_skill" .. i]:SetActive(self.m_skillList[i].m_SkillID == self.m_chooseSkillId)
    local canLevelUp = HeroManager:CheckHeroSkillCanLevelUp(self.m_curHeroId, self.m_skillList[i].m_SkillID)
    self["m_redpoint_skill" .. i]:SetActive(canLevelUp)
  end
  local skillCfg = HeroManager:GetSkillConfigById(self.m_chooseSkillId, selSkillLv)
  self.m_txt_skill_name_Text.text = skillCfg.m_mName
  self.m_txt_skill_namemax_Text.text = skillCfg.m_mName
  self.m_txt_skill_nametrait_Text.text = skillCfg.m_mName
  local showCost = false
  UILuaHelper.SetActive(self.m_pnl_costskill, false)
  if skillCfg.m_SkillType == 2 and selSkillLv < self.m_maxSkillLv then
    local costBefore = HeroManager:GetSkillCost(self.m_chooseSkillId, selSkillLv)
    local costAfter = HeroManager:GetSkillCost(self.m_chooseSkillId, math.min(selSkillLv + 1, self.m_maxSkillLv))
    if costBefore ~= costAfter then
      UILuaHelper.SetActive(self.m_pnl_costskill, true)
      self.m_txt_skillcost_Text.text = tostring(costBefore)
      self.m_txt_skillcost1_Text.text = tostring(costAfter)
      showCost = true
    end
  end
  UILuaHelper.SetActive(self.m_scrollview_skil_desc, showCost)
  UILuaHelper.SetActive(self.m_scrollview_skil_desc_long, not showCost)
  local des = HeroManager:GetSkillDescriptionBySkillIdAndLv(self.m_chooseSkillId, selSkillLv, true)
  self.m_txt_desc_Text.text = des
  self.m_txt_descmax_Text.text = des
  self.m_txt_desctrait_Text.text = des
  self.m_txt_desc_long_Text.text = des
  local skillLv = HeroManager:GetHeroSkillLvById(self.m_curHeroId, self.m_chooseSkillId)
  self:FreshShowBuffInfo(skillLv, self.m_maxSkillLv, showCost)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_skill_root)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_skill_root_long)
  local tempSkillGroupCfg = SkillGroupInstance:GetValue_BySkillGroupIDAndSkillID(self.m_heroSkillGroupID, self.m_chooseSkillId)
  if not tempSkillGroupCfg:GetError() then
    local skillShowType = tempSkillGroupCfg.m_SkillShowType
    local txtId = GlobalConfig.SKILL_SHOW_TYPE_COMMON_TXT_ID_LIST[skillShowType]
    if txtId then
      self.m_txt_ult_Text.text = ConfigManager:GetCommonTextById(txtId)
      self.m_txt_ultmax_Text.text = ConfigManager:GetCommonTextById(txtId)
      self.m_txt_ulttrait_Text.text = ConfigManager:GetCommonTextById(txtId)
    end
  end
  if selSkillLv < self.m_maxSkillLv then
    if not self.m_costItemList then
      self.m_costItemList = {}
    end
    local skillTemplate = HeroManager:GetSkillTemplateByIDAndSkillLevel(self.m_heroSkillGroupID, self.m_chooseSkillId, selSkillLv)
    local skillLevelUpCostList = utils.changeCSArrayToLuaTable(skillTemplate.m_SkillLevelUpCost) or {}
    local canLvUp = true
    self.m_needItemList = {}
    for i = 1, 4 do
      self["m_cost_item" .. i]:SetActive(i <= #skillLevelUpCostList)
      if i <= #skillLevelUpCostList then
        if self.m_costItemList[i] == nil then
          self.m_costItemList[i] = self:createCommonItem(self["m_cost_item" .. i])
        end
        local processData = ResourceUtil:GetProcessRewardData({
          iID = skillLevelUpCostList[i][1],
          iNum = 0
        })
        self.m_costItemList[i]:SetItemInfo(processData)
        self.m_costItemList[i]:SetItemIconClickCB(handler(self, self.OnItemClick))
        local userItemNum = ItemManager:GetItemNum(skillLevelUpCostList[i][1])
        self.m_costItemList[i]:SetNeedNum(skillLevelUpCostList[i][2], userItemNum)
        self.m_needItemList[#self.m_needItemList + 1] = skillLevelUpCostList[i]
        if userItemNum < skillLevelUpCostList[i][2] then
          canLvUp = false
        end
      end
    end
    self.m_btn_levelup_un:SetActive(not canLvUp)
    self.m_btn_levelup:SetActive(canLvUp)
  end
  self.m_pnl_content_righttop:SetActive(selSkillLv < self.m_maxSkillLv)
  self.m_pnl_btn_levelup:SetActive(selSkillLv < self.m_maxSkillLv)
  self.m_pnl_btn_levelmax:SetActive(selSkillLv >= self.m_maxSkillLv)
  self.m_txt_skill_before_num_Text.text = selSkillLv
  self.m_txt_skill_after_num_Text.text = math.min(selSkillLv + 1, self.m_maxSkillLv)
  self:ShowLevelPanel(skillLv, self.m_maxSkillLv)
end

function HeroSkillSubPanel:ShowLevelPanel(skillLv, maxSkillLv)
  if skillLv == maxSkillLv and maxSkillLv ~= 1 then
    self.m_pnl_skill_lv_upgrade:SetActive(false)
    self.m_pnl_skill_lv_top:SetActive(true)
    self.m_txt_skill_num_top_Text.text = maxSkillLv
    self.m_pnl_skill_desc:SetActive(false)
    self.m_pnl_skill_descmax:SetActive(true)
    self.m_pnl_skill_desctrait:SetActive(false)
  elseif maxSkillLv == 1 then
    self.m_pnl_skill_lv_upgrade:SetActive(false)
    self.m_pnl_skill_lv_top:SetActive(false)
    self.m_pnl_skill_desc:SetActive(false)
    self.m_pnl_skill_descmax:SetActive(false)
    self.m_pnl_skill_desctrait:SetActive(true)
  else
    self.m_pnl_skill_lv_upgrade:SetActive(true)
    self.m_pnl_skill_lv_top:SetActive(false)
    self.m_pnl_skill_desc:SetActive(true)
    self.m_pnl_skill_descmax:SetActive(false)
    self.m_pnl_skill_desctrait:SetActive(false)
  end
end

function HeroSkillSubPanel:FreshShowBuffInfo(skillLv, maxSkillLv, showCost)
  local skillCfg = HeroManager:GetSkillConfigById(self.m_chooseSkillId, 1)
  local buffIDArray = skillCfg.m_BuffDescID
  if not buffIDArray then
    return
  end
  local buffIDLen = buffIDArray.Length
  local buffCfgList = {}
  for i = 1, buffIDLen do
    local tempBuffID = buffIDArray[i - 1]
    local buffCfg = SkillBuffIns:GetValue_ByBuffID(tempBuffID)
    if buffCfg:GetError() ~= true then
      buffCfgList[#buffCfgList + 1] = buffCfg
    end
  end
  self.m_buffCfgDataList = buffCfgList
  local datalist = self.m_buffCfgDataList
  local dataLen = #datalist
  if dataLen == 0 then
    UILuaHelper.SetActive(self.m_buff_list, false)
    UILuaHelper.SetActive(self.m_buff_listtrait, false)
    UILuaHelper.SetActive(self.m_buff_listmax, false)
    UILuaHelper.SetActive(self.m_buff_list_long, false)
  else
    local rootParent
    if skillLv == maxSkillLv and maxSkillLv ~= 1 then
      rootParent = self.m_buff_listmax
      UILuaHelper.SetActive(self.m_buff_listmax, true)
      UILuaHelper.SetActive(self.m_buff_listtrait, false)
      UILuaHelper.SetActive(self.m_buff_list, false)
    elseif maxSkillLv == 1 then
      rootParent = self.m_buff_listtrait
      UILuaHelper.SetActive(self.m_buff_listtrait, true)
      UILuaHelper.SetActive(self.m_buff_list, false)
      UILuaHelper.SetActive(self.m_buff_listmax, false)
    else
      rootParent = showCost == true and self.m_buff_list or self.m_buff_list_long
      UILuaHelper.SetActive(self.m_buff_list, showCost)
      UILuaHelper.SetActive(self.m_buff_listmax, false)
      UILuaHelper.SetActive(self.m_buff_listtrait, false)
      UILuaHelper.SetActive(self.m_buff_list_long, not showCost)
    end
    local parentTrans = rootParent.transform
    local childCount = parentTrans.childCount
    local totalFreshNum = dataLen < childCount and childCount or dataLen
    for i = 1, totalFreshNum do
      if i <= childCount and i <= dataLen then
        local itemTrans = parentTrans:GetChild(i - 1)
        self.m_buffItemList[i] = self:InitBuffItem(itemTrans)
        local itemTrans1 = self.m_buffItemList[i].rootNode
        UILuaHelper.SetActive(itemTrans1, true)
        self:FreshBuffItem(i, datalist[i])
      elseif i > childCount and i <= dataLen then
        local itemTrans = parentTrans:GetChild(0)
        local newItemTrans = GameObject.Instantiate(itemTrans, parentTrans).transform
        self.m_buffItemList[i] = self:InitBuffItem(newItemTrans, i)
        UILuaHelper.SetActive(newItemTrans, true)
        self:FreshBuffItem(i, datalist[i])
      elseif i <= childCount and i > dataLen then
        local itemTrans = parentTrans:GetChild(i - 1)
        UILuaHelper.SetActive(itemTrans, false)
        if self.m_buffItemList[i] ~= nil then
          self.m_buffItemList[i].itemData = nil
        end
      end
    end
  end
  if self.m_sequence then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
  self.m_sequence = Tweening.DOTween.Sequence()
  self.m_sequence:AppendInterval(0.01)
  self.m_sequence:OnComplete(function()
    if self and not utils.isNull(self.m_buff_list) then
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_buff_list)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_buff_listmax)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_buff_listtrait)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_skill_root)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_skill_root_long)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_skill_roottrait)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_skill_rootmax)
    end
  end)
  self.m_sequence:SetAutoKill(true)
end

function HeroSkillSubPanel:InitBuffItem(itemTran)
  local itemRootTrans = itemTran.transform
  local buffIcon = itemRootTrans:Find("c_img_buff_icon"):GetComponent(T_Image)
  local txt_buff_desc = itemRootTrans:Find("c_txt_buff_desc"):GetComponent(T_TextMeshProUGUI)
  local showItem = {
    buffIcon = buffIcon,
    txt_buff_desc = txt_buff_desc,
    itemData = nil,
    rootNode = itemRootTrans
  }
  return showItem
end

function HeroSkillSubPanel:FreshBuffItem(index, buffData)
  local showItem = self.m_buffItemList[index]
  if showItem == nil then
    return
  end
  showItem.itemData = buffData
  UILuaHelper.SetAtlasSprite(showItem.buffIcon, "Atlas_Buff/" .. buffData.m_Icon)
  local buffName = buffData.m_mName
  local showParamStr = HeroManager:GetBuffDescribeByCfg(buffData)
  showItem.txt_buff_desc.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20092), buffName, showParamStr)
end

function HeroSkillSubPanel:OnItemClick(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function HeroSkillSubPanel:ShowEnterInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroSkillSubPanel:ShowTabInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroSkillSubPanel:OnSkillLevelUp(skillData)
  StackFlow:Push(UIDefines.ID_FORM_HEROSKILLLEVELUP_TIPS, {
    oldLv = skillData.iLevel - 1,
    newLv = skillData.iLevel
  })
  self.m_lockLevelUpBtn = false
  self:RefreshSkillInfo()
end

function HeroSkillSubPanel:OnSkillClk(index)
  self.m_chooseSkillId = self.m_skillList[index].m_SkillID
  self.m_maxSkillLv = HeroManager:GetSkillMaxLevelById(self.m_heroSkillGroupID, self.m_chooseSkillId)
  self:RefreshSkillInfo()
end

function HeroSkillSubPanel:OnBtnskill01Clicked()
  self:OnSkillClk(1)
  self.timeElapsed = 0
  self.m_targetRot = 270
  self:CheckRotAngle()
end

function HeroSkillSubPanel:OnBtnskill02Clicked()
  self:OnSkillClk(2)
  self.timeElapsed = 0
  self.m_targetRot = 0
  self:CheckRotAngle()
end

function HeroSkillSubPanel:OnBtnskill03Clicked()
  self:OnSkillClk(3)
  self.timeElapsed = 0
  self.m_targetRot = 180
  self:CheckRotAngle()
end

function HeroSkillSubPanel:OnBtnskill04Clicked()
  self:OnSkillClk(4)
  self.timeElapsed = 0
  self.m_targetRot = 90
  self:CheckRotAngle()
end

function HeroSkillSubPanel:OnBtnresetClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROSKILLRESET, {
    heroId = self.m_curHeroId
  })
end

function HeroSkillSubPanel:OnBtnlevelupClicked()
  if self.m_lockLevelUpBtn then
    return
  end
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(2)
  sequence:OnComplete(function()
    self.m_lockLevelUpBtn = false
  end)
  sequence:SetAutoKill(true)
  HeroManager:ReqHeroSkillLevelUp(self.m_curHeroId, self.m_chooseSkillId)
end

function HeroSkillSubPanel:OnBtnlevelupunClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30021)
end

function HeroSkillSubPanel:OnBtnbagquickClicked()
  if #self.m_needItemList > 0 then
    StackPopup:Push(UIDefines.ID_FORM_POPUPQUICKBAG, {
      quickBagType = ItemManager.ItemQuickUseType.SkillLevelUp,
      costList = self.m_needItemList
    })
  end
end

function HeroSkillSubPanel:OnBtnpreviewClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROSKILLPREVIEW, {
    hero_cfg_id = self.m_curHeroId
  })
end

function HeroSkillSubPanel:OnUpdate(dt)
  if self.m_curRot ~= self.m_targetRot then
    self.timeElapsed = self.timeElapsed + dt
    if self.timeElapsed < self.m_takeRotTime then
      local t = self.timeElapsed / self.m_takeRotTime
      local zRotation = CS.UnityEngine.Mathf.Lerp(self.m_curRot, self.m_targetRot, t)
      UILuaHelper.SetLocalEuler(self.uiElement, 0, 0, zRotation)
      self.m_curRot = zRotation
    else
      UILuaHelper.SetLocalEuler(self.uiElement, 0, 0, self.m_targetRot)
      self.m_curRot = self.m_targetRot
    end
  end
end

function HeroSkillSubPanel:CheckRotAngle()
  if self.m_targetRot - self.m_curRot > 180 then
    self.m_curRot = self.m_curRot + 360
    UILuaHelper.SetLocalEuler(self.uiElement, 0, 0, self.m_curRot)
  end
  if self.m_targetRot - self.m_curRot < -180 then
    self.m_curRot = self.m_curRot - 360
    UILuaHelper.SetLocalEuler(self.uiElement, 0, 0, self.m_curRot)
  end
end

return HeroSkillSubPanel
