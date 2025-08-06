local Form_RogueItemTips = class("Form_RogueItemTips", require("UI/UIFrames/Form_RogueItemTipsUI"))
local __RogueItemPropertyRangeType = {
  all = 0,
  job = 1,
  camp = 2,
  character = 3
}
local __RogueItemPropertyRangeTips = {
  [0] = {id = 0, tips = 100701},
  [1] = {
    id = 1,
    tips = 100702,
    range = "m_Job"
  },
  [2] = {
    id = 2,
    tips = 100703,
    range = "m_Camp"
  },
  [3] = {
    id = 3,
    tips = 100704,
    range = "m_Character"
  }
}
local ATTR_COEFFICIENT = 100.0

function Form_RogueItemTips:SetInitParam(param)
end

function Form_RogueItemTips:AfterInit()
  self.super.AfterInit(self)
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_DoubleTrigger = self.m_double_trigger:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnDoubleTriggerClk)
  end
  self.m_RogueItem = self:createRogueItemIcon(self.m__rogue_equioment_item)
  self.m_ListItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_list_item_InfinityGrid, "RogueChoose/UIRogueItemTipsItem")
  self:ShowCombination()
end

function Form_RogueItemTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_itemId = tParam.item_id
  self.m_includeHeroIdList = tParam.includeHeroIdList
  self.m_isHaveItemIds = tParam.isHaveItemIds
  self.m_showCombinationFlag = true
  if not self.m_itemId then
    return
  end
  self.m_RogueCombination = self.m_levelRogueStageHelper:GetRogueStageItemCombination(self.m_itemId, self.m_includeHeroIdList, self.m_isHaveItemIds)
  self:RefreshUI()
  self:ShowCombination()
  self:OpenAnim()
end

function Form_RogueItemTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_RogueItemTips:OpenAnim()
  local animStr = "in1"
  local flag = self.m_showCombinationFlag and table.getn(self.m_RogueCombination) > 0
  if flag then
    animStr = "in3"
  end
  if not utils.isNull(self.m_csui.m_uiGameObject) then
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, animStr)
  end
end

function Form_RogueItemTips:ShowCombination()
  self.m_content_node1:SetActive(self.m_showCombinationFlag and table.getn(self.m_RogueCombination) > 0)
  if self.m_showCombinationFlag and table.getn(self.m_RogueCombination) > 0 then
    self.m_ListItemInfinityGrid:ShowItemList(self.m_RogueCombination)
  end
end

function Form_RogueItemTips:RefreshUI()
  local itemCfg = self:GetRogueStageItemInfoCfg(self.m_itemId)
  if itemCfg then
    local heroId = itemCfg.m_Character
    self.m_bg_hero_wear:SetActive(heroId ~= nil and heroId ~= 0)
    if heroId and heroId ~= 0 then
      ResourceUtil:CreateHeroHeadIcon(self.m_img_hero_Image, heroId)
    end
    local campList = utils.changeCSArrayToLuaTable(itemCfg.m_Camp)
    local jobList = utils.changeCSArrayToLuaTable(itemCfg.m_Job)
    if 0 < table.getn(campList) or 0 < table.getn(jobList) then
      local list = 0 < table.getn(campList) and campList or jobList
      local typeFlag = 0 < table.getn(campList)
      self.m_pnl_profession:SetActive(true)
      for i = 1, 3 do
        self["m_item_profession" .. i]:SetActive(list[i] ~= nil)
        local imgName = ""
        if typeFlag then
          local stItemData = HeroManager:GetCharacterCampCfgByCamp(list[i])
          if stItemData then
            imgName = stItemData.m_CampIcon
          end
        else
          local stItemData = HeroManager:GetCharacterCareerCfgByCareer(list[i])
          if stItemData then
            imgName = stItemData.m_CareerIcon
          end
        end
        CS.UI.UILuaHelper.SetAtlasSprite(self["m_img_profession" .. i .. "_Image"], imgName, nil, nil, true)
      end
    else
      self.m_pnl_profession:SetActive(false)
    end
    self.m_btn_formula:SetActive(itemCfg.m_ItemType == RogueStageManager.RogueStageItemType.Material)
    self.m_img_bg_skillbuf:SetActive(itemCfg.m_mItemDesc2 ~= "" and itemCfg.m_mItemDesc2 ~= " " and itemCfg.m_mItemDesc2 ~= "******")
    self.m_pnl_skillnuffinfor:SetActive(itemCfg.m_mItemDesc2 ~= "" and itemCfg.m_mItemDesc2 ~= " " and itemCfg.m_mItemDesc2 ~= "******")
    self.m_txt_skillbuff_Text.text = itemCfg.m_mItemDesc2
    self.m_txt_story_Text.text = itemCfg.m_mItemDesc3
    self:RefreshItemPropertyUI(self.m_itemId)
    self.m_RogueItem:SetItemInfo({
      itemId = self.m_itemId,
      unlock = false,
      useTipsPos = true
    })
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_content_node)
    self.m_scrollview:GetComponent("ScrollRect").verticalNormalizedPosition = 1
    self.m_list_item:GetComponent("ScrollRect").verticalNormalizedPosition = 1
  end
end

function Form_RogueItemTips:RefreshItemPropertyUI(id)
  local itemCfg = self:GetRogueStageItemInfoCfg(id)
  local propertyList = utils.changeCSArrayToLuaTable(itemCfg.m_ItemProperty)
  if table.getn(propertyList) > 0 then
    self.m_list_effectobject:SetActive(true)
    self.m_img_destitle:SetActive(true)
    local list = self:GetAttrInfoList(propertyList)
    for i = 1, 5 do
      local info = list[i]
      self["m_item_effect" .. i]:SetActive(info ~= nil)
      if info then
        self["m_txt_buffadd" .. i .. "_Text"].text = info.name .. "+" .. info.num
        self["m_txt_des" .. i .. "_Text"].text = info.des
      end
    end
  else
    self.m_list_effectobject:SetActive(false)
    self.m_img_destitle:SetActive(false)
  end
end

function Form_RogueItemTips:GetAttrInfoList(attrList)
  local attrInfoList = {}
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  for i, attr in ipairs(attrList) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(attr[1])
    local paramNum = math.floor(attr[2]) or 0
    if propertyIndexCfg.m_Type == 2 then
      paramNum = paramNum / ATTR_COEFFICIENT
      paramNum = string.format(ConfigManager:GetCommonTextById(100009), tostring(paramNum))
    end
    local des = ""
    local info = __RogueItemPropertyRangeTips[attr[3]]
    if info then
      des = self:GetRangeInfoStr(info)
    end
    attrInfoList[#attrInfoList + 1] = {
      name = propertyIndexCfg.m_mCNName,
      num = paramNum,
      id = attr[1],
      des = des
    }
  end
  return attrInfoList
end

function Form_RogueItemTips:GetRangeInfoStr(info)
  if not info or not info.range then
    return ConfigManager:GetCommonTextById(info.tips)
  end
  local itemCfg = self:GetRogueStageItemInfoCfg(self.m_itemId)
  local str = ""
  local ranges = {}
  if type(itemCfg[info.range]) == "number" then
    ranges = {
      itemCfg[info.range]
    }
  else
    ranges = utils.changeCSArrayToLuaTable(itemCfg[info.range])
  end
  if table.getn(ranges) > 0 then
    if info.id == __RogueItemPropertyRangeType.job then
      for i, v in ipairs(ranges) do
        local cfg = HeroManager:GetCharacterCareerCfgByCareer(v)
        if cfg then
          if str ~= "" then
            str = "," .. str
          end
          str = str .. "<color=#368E72>" .. cfg.m_mCareerName .. "</color>"
        end
      end
    elseif info.id == __RogueItemPropertyRangeType.camp then
      for i, v in ipairs(ranges) do
        local cfg = HeroManager:GetCharacterCampCfgByCamp(v)
        if cfg then
          if str ~= "" then
            str = "," .. str
          end
          str = str .. "<color=#368E72>" .. cfg.m_mCampName .. "</color>"
        end
      end
    elseif info.id == __RogueItemPropertyRangeType.character then
      for i, v in ipairs(ranges) do
        local cfg = HeroManager:GetHeroConfigByID(v)
        if cfg then
          if str ~= "" then
            str = "," .. str
          end
          str = str .. "<color=#368E72>" .. cfg.m_mName .. "</color>"
        end
      end
    end
  end
  return string.gsubnumberreplace(ConfigManager:GetCommonTextById(info.tips), str)
end

function Form_RogueItemTips:GetRogueStageItemInfoCfg(id)
  return self.m_levelRogueStageHelper:GetRogueItemCfgByID(id)
end

function Form_RogueItemTips:InitSetPos()
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

function Form_RogueItemTips:OnDoubleTriggerClk()
  self:OnBtnCloseClicked()
end

function Form_RogueItemTips:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_RogueItemTips:OnBtnformulaClicked()
  if table.getn(self.m_RogueCombination) == 0 then
    self.m_showCombinationFlag = false
    self:ShowCombination()
    return
  end
  self.m_showCombinationFlag = not self.m_showCombinationFlag
  self:ShowCombination()
  local animStr = self.m_showCombinationFlag and "in2" or "out3"
  if not utils.isNull(self.m_csui.m_uiGameObject) then
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, animStr)
  end
end

function Form_RogueItemTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RogueItemTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RogueItemTips", Form_RogueItemTips)
return Form_RogueItemTips
