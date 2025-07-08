local Form_PopoverSkill = class("Form_PopoverSkill", require("UI/UIFrames/Form_PopoverSkillUI"))
local InGameSkillInstance = ConfigManager:GetConfigInsByName("Skill")
local SkillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
local SkillBuffIns = ConfigManager:GetConfigInsByName("SkillBuff")

function Form_PopoverSkill:SetInitParam(param)
end

function Form_PopoverSkill:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_rt = self.m_csui.m_uiGameObject:GetComponent("RectTransform")
  self.m_DoubleTrigger = self.m_double_trigger:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnDoubleTriggerClk)
  end
  self.m_buffItemList = {}
  self.m_buffCfgDataList = nil
  self:InitBuffItem(self.m_baseBuff, 1)
end

function Form_PopoverSkill:OnActive()
  self.super.OnActive(self)
  UILuaHelper.SetLocalPosition(self.m_content_node, 10000, 10000, 0)
  local tParam = self.m_csui.m_param or {}
  self.m_skillId = tParam.skill_id
  self.m_skillGroupId = tParam.skill_group_id
  self.m_click_transform = tParam.click_transform
  self.m_pivot = tParam.content_pivot
  self.m_posOffset = tParam.pos_offset or {x = 0, y = 0}
  self.m_hero_cfg_id = tParam.hero_cfg_id
  self.m_skillLv = tParam.skill_lv ~= nil and tParam.skill_lv or HeroManager:GetHeroSkillLvById(self.m_hero_cfg_id, self.m_skillId)
  if not self.m_skillId then
    return
  end
  self:RefreshUI()
  self:setTimer(0.06, 1, function()
    if self.m_click_transform then
      self:InitSetPos()
    else
      UILuaHelper.SetLocalPosition(self.m_content_node, 0, 0, 0)
    end
  end)
end

function Form_PopoverSkill:OnInactive()
  self.super.OnInactive(self)
  if self.m_sequence then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
end

function Form_PopoverSkill:RefreshUI()
  local tempSkillCfg = HeroManager:GetSkillConfigById(self.m_skillId)
  if not tempSkillCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_icon_skill_Image, tempSkillCfg.m_Skillicon)
    local skillDescription = HeroManager:GetSkillDescriptionBySkillIdAndLv(self.m_skillId, self.m_skillLv)
    if tempSkillCfg.m_SkillDescriptionType == 1 then
      self.m_txt_skill_describe:SetActive(false)
      self.m_scrollView_list:SetActive(true)
      self.m_txt_desc_Text.text = skillDescription
    else
      self.m_txt_skill_describe:SetActive(true)
      self.m_scrollView_list:SetActive(false)
      self.m_txt_skill_describe_Text.text = skillDescription
      local maxSkillLv = HeroManager:GetSkillMaxLevelById(self.m_skillGroupId, self.m_skillId)
      self.m_txt_skill_lv_num_Text.text = maxSkillLv == 1 and "" or tostring(self.m_skillLv)
      self.m_img_skill_rectangle:SetActive(maxSkillLv ~= 1)
    end
    self.m_txt_skill_name_Text.text = tempSkillCfg.m_mName
    self:FreshShowBuffInfo(tempSkillCfg.m_BuffDescID)
    if self.m_sequence then
      self.m_sequence:Kill()
      self.m_sequence = nil
    end
    self.m_sequence = Tweening.DOTween.Sequence()
    self.m_sequence:AppendInterval(0.01)
    self.m_sequence:OnComplete(function()
      if self and not utils.isNull(self.m_content_node) then
        UILuaHelper.ForceRebuildLayoutImmediate(self.m_content_node)
      end
    end)
  end
  local tempSkillGroupCfg = SkillGroupInstance:GetValue_BySkillGroupIDAndSkillID(self.m_skillGroupId, self.m_skillId)
  if not tempSkillGroupCfg:GetError() then
    local skillShowType = tempSkillGroupCfg.m_SkillShowType
    local txtId = GlobalConfig.SKILL_SHOW_TYPE_COMMON_TXT_ID_LIST[skillShowType]
    if txtId then
      self.m_txt_skill_type_Text.text = ConfigManager:GetCommonTextById(txtId)
    end
  end
  local cost = HeroManager:GetSkillCost(self.m_skillId, self.m_skillLv)
  UILuaHelper.SetActive(self.m_pnl_skillcost, false)
  if 0 < cost then
    UILuaHelper.SetActive(self.m_pnl_skillcost, true)
    self.m_txt_skillcost_Text.text = tostring(cost)
  end
end

function Form_PopoverSkill:InitSetPos()
  local pos = self.m_content_node.transform.parent:InverseTransformPoint(self.m_click_transform.position)
  local content_w, content_h = UILuaHelper.GetUISize(self.m_content_node)
  local width, height = UILuaHelper.GetUISize(self.m_rootTrans)
  local d_pos = Vector3.New(pos.x, pos.y, pos.z)
  if self.m_pivot then
    if self.m_pivot.x ~= 0.5 then
      local clickRectW, _ = UILuaHelper.GetUISize(self.m_click_transform)
      if self.m_pivot.x == 0 then
        d_pos.x = pos.x - content_w / 2 - clickRectW / 2
      elseif self.m_pivot.x == 1 then
        d_pos.x = pos.x + content_w / 2 + clickRectW / 2
      end
    end
    if self.m_pivot.y ~= 0.5 then
      local _, clickRectH = UILuaHelper.GetUISize(self.m_click_transform)
      if self.m_pivot.y == 0 then
        d_pos.y = pos.y - content_h / 2 - clickRectH / 2
      elseif self.m_pivot.y == 1 then
        d_pos.y = pos.y + content_h / 2 + clickRectH / 2
      end
    end
  end
  d_pos.x = d_pos.x + self.m_posOffset.x or 0
  d_pos.y = d_pos.y + self.m_posOffset.y or 0
  d_pos.y = math.max(math.min(d_pos.y, height * 0.5 - content_h * 0.5), -height * 0.5)
  d_pos.x = math.max(math.min(d_pos.x, width * 0.5 - content_w * 0.5), -width * 0.5 + content_w * 0.5)
  UILuaHelper.SetLocalPosition(self.m_content_node, d_pos.x, d_pos.y, 0)
end

function Form_PopoverSkill:RefreshSkillCost()
end

function Form_PopoverSkill:FreshShowBuffInfo(buffIDArray)
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
  else
    UILuaHelper.SetActive(self.m_buff_list, true)
    local parentTrans = self.m_buff_list.transform
    local childCount = parentTrans.childCount
    local totalFreshNum = dataLen < childCount and childCount or dataLen
    for i = 1, totalFreshNum do
      if i <= childCount and i <= dataLen then
        if self.m_buffItemList[i] == nil then
          local itemTrans = parentTrans:GetChild(i - 1)
          self:InitBuffItem(itemTrans, i)
        end
        local itemTrans = self.m_buffItemList[i].rootNode
        UILuaHelper.SetActive(itemTrans, true)
        self:FreshBuffItem(i, datalist[i])
      elseif i > childCount and i <= dataLen then
        local itemTrans = parentTrans:GetChild(0)
        local newItemTrans = GameObject.Instantiate(itemTrans, parentTrans).transform
        self:InitBuffItem(newItemTrans, i)
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
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_buff_list)
end

function Form_PopoverSkill:InitBuffItem(itemTran, index)
  local itemRootTrans = itemTran.transform
  local buffIcon = itemRootTrans:Find("m_img_buff_icon"):GetComponent(T_Image)
  local txt_buff_desc = itemRootTrans:Find("m_txt_buff_desc"):GetComponent(T_TextMeshProUGUI)
  local showItem = {
    buffIcon = buffIcon,
    txt_buff_desc = txt_buff_desc,
    itemData = nil,
    rootNode = itemRootTrans
  }
  self.m_buffItemList[index] = showItem
end

function Form_PopoverSkill:FreshBuffItem(index, buffData)
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

function Form_PopoverSkill:OnDoubleTriggerClk()
  self:CloseForm()
end

function Form_PopoverSkill:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_POPOVERSKILL)
end

function Form_PopoverSkill:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_PopoverSkill", Form_PopoverSkill)
return Form_PopoverSkill
