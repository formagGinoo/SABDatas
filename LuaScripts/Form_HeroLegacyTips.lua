local Form_HeroLegacyTips = class("Form_HeroLegacyTips", require("UI/UIFrames/Form_HeroLegacyTipsUI"))
local SkillIns = ConfigManager:GetConfigInsByName("Skill")
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
local MaxLegacySkillNum = LegacyManager.MaxLegacySkillNum
local SkillBuffIns = ConfigManager:GetConfigInsByName("SkillBuff")

function Form_HeroLegacyTips:SetInitParam(param)
end

function Form_HeroLegacyTips:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_DoubleTrigger = self.m_double_trigger:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnDoubleTriggerClk)
  end
  self.m_rt = self.m_csui.m_uiGameObject:GetComponent("RectTransform")
  self.m_curLegacyCfg = nil
  self.m_curLegacyID = nil
  self.m_curLegacyLv = nil
  self.m_curSkillID = nil
  self.m_curSkillLv = nil
  self.m_legacyLvCfgList = {}
  self.m_curLegacyLvCfg = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_showAttrBaseCfgList = {}
  self.m_clickTrans = nil
  self.m_pivot = nil
  self.m_posOffset = nil
  self.m_buffItemList = {}
  self.m_buffCfgDataList = nil
  self:InitBuffItem(self.m_baseBuff, 1)
end

function Form_HeroLegacyTips:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_HeroLegacyTips:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_HeroLegacyTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroLegacyTips:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curLegacyID = tParam.legacyID
    self.m_curLegacyLv = tParam.legacyLv
    self.m_curLegacyCfg = LegacyManager:GetLegacyCfgByID(self.m_curLegacyID)
    self:FreshLegacyLvList()
    self.m_curLegacyLvCfg = self.m_legacyLvCfgList[self.m_curLegacyLv]
    self.m_curSkillID = tParam.skillID
    self.m_curSkillIndex = self:GetSkillIndex()
    self.m_curSkillLv = self.m_curLegacyLvCfg["m_SkillLevel" .. self.m_curSkillIndex] or 0
    self.m_clickTrans = tParam.clickTrans
    self.m_pivot = tParam.contentPivot
    self.m_posOffset = tParam.posOffset or {x = 0, y = 0}
    self.m_csui.m_param = nil
  end
end

function Form_HeroLegacyTips:GetSkillIndex()
  for i = 1, MaxLegacySkillNum do
    local skillID = self.m_curLegacyCfg["m_Skillgroup" .. i]
    if skillID == self.m_curSkillID then
      return i
    end
  end
end

function Form_HeroLegacyTips:FreshLegacyLvList()
  if not self.m_curLegacyID then
    return
  end
  local legacyDic = LegacyLevelIns:GetValue_ByID(self.m_curLegacyID)
  if not legacyDic then
    return
  end
  for _, v in pairs(legacyDic) do
    self.m_legacyLvCfgList[v.m_Level] = v
  end
end

function Form_HeroLegacyTips:ClearCacheData()
end

function Form_HeroLegacyTips:AddEventListeners()
end

function Form_HeroLegacyTips:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroLegacyTips:FreshUI()
  self:FreshLegacySkillBaseInfo()
  self:FreshUpgradeLockStatus()
  self:FreshSkillPosition()
end

function Form_HeroLegacyTips:FreshSkillPosition()
  self:setTimer(0.06, 1, function()
    if self.m_clickTrans then
      self:InitSetPos()
    else
      UILuaHelper.SetLocalPosition(self.m_content_node, 0, 0, 0)
    end
  end)
end

function Form_HeroLegacyTips:InitSetPos()
  local pos = self.m_content_node.transform.parent:InverseTransformPoint(self.m_clickTrans.position)
  local content_w, content_h = UILuaHelper.GetUISize(self.m_content_node)
  local width, height = UILuaHelper.GetUISize(self.m_rootTrans)
  local d_pos = Vector3.New(pos.x, pos.y, pos.z)
  if self.m_pivot then
    if self.m_pivot.x ~= 0.5 then
      local clickRectW, _ = UILuaHelper.GetUISize(self.m_clickTrans)
      if self.m_pivot.x == 0 then
        d_pos.x = pos.x - content_w / 2 - clickRectW / 2
      elseif self.m_pivot.x == 1 then
        d_pos.x = pos.x + content_w / 2 + clickRectW / 2
      end
    end
    if self.m_pivot.y ~= 0.5 then
      local _, clickRectH = UILuaHelper.GetUISize(self.m_clickTrans)
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

function Form_HeroLegacyTips:FreshLegacySkillBaseInfo()
  if not self.m_curSkillID then
    return
  end
  local skillCfg = SkillIns:GetValue_BySkillID(self.m_curSkillID)
  if skillCfg:GetError() == true then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_icon_skill_Image, skillCfg.m_Skillicon)
  local showDescLv = self.m_curSkillLv > 0 and self.m_curSkillLv or 1
  local skillDescription = HeroManager:GetSkillDescriptionBySkillIdAndLv(self.m_curSkillID, showDescLv)
  if skillCfg.m_SkillDescriptionType == 1 then
    self.m_txt_skill_describe:SetActive(false)
    self.m_scrollView_list:SetActive(true)
    self.m_txt_desc_Text.text = skillDescription
  else
    self.m_txt_skill_describe:SetActive(true)
    self.m_scrollView_list:SetActive(false)
    self.m_txt_skill_describe_Text.text = skillDescription
    local maxSkillLv = self.m_legacyLvCfgList[#self.m_legacyLvCfgList]["m_SkillLevel" .. self.m_curSkillIndex] or 1
    self.m_txt_grade_Text.text = maxSkillLv == 1 and "" or string.format(ConfigManager:GetCommonTextById(20033), tostring(showDescLv))
  end
  self.m_txt_skill_name_Text.text = skillCfg.m_mName
  local txtId = GlobalConfig.SKILL_SHOW_TYPE_COMMON_TXT_ID_LIST[4]
  self.m_txt_skill_type_Text.text = ConfigManager:GetCommonTextById(txtId)
  self:FreshShowBuffInfo(skillCfg.m_BuffDescID)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_content_node)
end

function Form_HeroLegacyTips:FreshUpgradeLockStatus()
  local isLock = self.m_curSkillLv == nil or self.m_curSkillLv == 0
  local maxSkillLv = self.m_legacyLvCfgList[#self.m_legacyLvCfgList]["m_SkillLevel" .. self.m_curSkillIndex] or 0
  local isMax = maxSkillLv <= self.m_curSkillLv
  local isCanUp = not isMax and not isLock
  UILuaHelper.SetActive(self.m_legacy_up_list, isCanUp)
  UILuaHelper.SetActive(self.m_legacy_lock_list, isLock)
  local maxNum = #self.m_legacyLvCfgList
  if isCanUp then
    local nextUpLegacyLv = 0
    for i = self.m_curLegacyLv, maxNum do
      local nextSkillLv = self.m_legacyLvCfgList[i]["m_SkillLevel" .. self.m_curSkillIndex] or 0
      if nextSkillLv > self.m_curSkillLv then
        nextUpLegacyLv = i
        break
      end
    end
    self.m_txt_legacy_up_desc_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20100), self.m_curLegacyCfg.m_mName, nextUpLegacyLv)
  end
  if isLock then
    local nextUnlockLv = 0
    for i = self.m_curLegacyLv + 1, maxNum do
      local nextSkillLv = self.m_legacyLvCfgList[i]["m_SkillLevel" .. self.m_curSkillIndex] or 0
      if nextSkillLv ~= nil and nextSkillLv ~= 0 then
        nextUnlockLv = i
        break
      end
    end
    self.m_txt_legacy_lock_desc_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20100), self.m_curLegacyCfg.m_mName, nextUnlockLv)
  end
end

function Form_HeroLegacyTips:FreshShowBuffInfo(buffIDArray)
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

function Form_HeroLegacyTips:InitBuffItem(itemTran, index)
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

function Form_HeroLegacyTips:FreshBuffItem(index, buffData)
  local showItem = self.m_buffItemList[index]
  if showItem == nil then
    return
  end
  showItem.itemData = buffData
  UILuaHelper.SetAtlasSprite(showItem.buffIcon, "Atlas_Buff/" .. buffData.m_Icon)
  local descStr = HeroManager:GetBuffDescribeByCfg(buffData)
  local buffName = buffData.m_mName
  showItem.txt_buff_desc.text = string.CS_Format(ConfigManager:GetCommonTextById(20092), buffName, descStr)
end

function Form_HeroLegacyTips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroLegacyTips:OnDoubleTriggerClk()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_HeroLegacyTips", Form_HeroLegacyTips)
return Form_HeroLegacyTips
