local Form_HeroSkillReset = class("Form_HeroSkillReset", require("UI/UIFrames/Form_HeroSkillResetUI"))
local SkillNum = 4

function Form_HeroSkillReset:SetInitParam(param)
end

function Form_HeroSkillReset:AfterInit()
  self.super.AfterInit(self)
  local parentTran = self.m_btn_consume.transform
  self.m_consumeIconImg = parentTran:Find("img_jb_bg/consume_quantity/consume_icon"):GetComponent("Image")
  self.m_consumeNumTxt = parentTran:Find("img_jb_bg/consume_quantity"):GetComponent(T_TextMeshProUGUI)
  self.m_widgetResourceBar = self:createResourceBar(self.m_top_resource)
  local initGiftGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_itemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initGiftGridData)
end

function Form_HeroSkillReset:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_heroId = tParam.heroId
  self:RefreshUI()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_HeroSkillReset:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_HeroSkillReset:RefreshUI()
  local list = HeroManager:GetHeroSkillCosts(self.m_heroId)
  local vItemData = {}
  for k, v in ipairs(list) do
    local processData = ResourceUtil:GetProcessRewardData(v)
    vItemData[#vItemData + 1] = processData
  end
  self.m_itemInfinityGrid:ShowItemList(vItemData)
  self:FreshShowSkillInfo()
  local itemId, needNum = HeroManager:GetSkillResetItem()
  self.m_widgetResourceBar:FreshChangeItems({
    [1] = itemId
  })
  ResourceUtil:CreateItemIcon(self.m_consumeIconImg, itemId)
  self.m_consumeNumTxt.text = needNum
  local _, cutDownTime = HeroManager:CheckHeroSkillResetActivityIsOpen()
  local timeStr = TimeUtil:SecondToTimeText(cutDownTime)
  self.m_txt_time_Text.text = timeStr
end

function Form_HeroSkillReset:FreshShowSkillInfo()
  local heroCfg = HeroManager:GetHeroConfigByID(self.m_heroId)
  local skillGroupID = heroCfg.m_SkillGroupID[0]
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
  for i = 1, SkillNum do
    local skillCfg = skillCfgList[i]
    if skillCfg then
      UILuaHelper.SetAtlasSprite(self[string.format("m_icon_killleft%d_Image", i)], skillCfg.m_Skillicon)
      local skillLv = HeroManager:GetHeroSkillLvById(self.m_heroId, skillCfg.m_SkillID)
      local maxSkillLv = HeroManager:GetSkillMaxLevelById(skillGroupID, skillCfg.m_SkillID)
      self["m_img_skill_rectangleleft" .. i]:SetActive(maxSkillLv ~= 1)
      self["m_btn_skillleft" .. i]:SetActive(maxSkillLv ~= 1)
      self["m_txt_skill_lv_numleft" .. i .. "_Text"].text = tostring(skillLv)
      UILuaHelper.SetAtlasSprite(self[string.format("m_icon_killright%d_Image", i)], skillCfg.m_Skillicon)
      self["m_img_skill_rectangleright" .. i]:SetActive(maxSkillLv ~= 1)
      self["m_btn_skillright" .. i]:SetActive(maxSkillLv ~= 1)
      self["m_txt_skill_lv_numright" .. i .. "_Text"].text = 1
    else
      self["m_btn_skillleft" .. i]:SetActive(false)
      self["m_btn_skillright" .. i]:SetActive(false)
    end
  end
end

function Form_HeroSkillReset:IsFullScreen()
  return false
end

function Form_HeroSkillReset:IsOpenGuassianBlur()
  return true
end

function Form_HeroSkillReset:OnItemClk(itemIndex, itemRootObj, itemIcon)
  utils.openItemDetailPop({
    iID = itemIcon.m_iItemID,
    iNum = 1
  })
end

function Form_HeroSkillReset:OnBtnresetClicked()
  local itemId, needNum = HeroManager:GetSkillResetItem()
  local itemNum = ItemManager:GetItemNum(itemId)
  if needNum > itemNum then
    return
  end
  utils.ShowCommonTipCost({
    beforeItemID = itemId,
    beforeItemNum = needNum,
    confirmCommonTipsID = 1023,
    funSure = function()
      HeroManager:ReqHeroSkillResetCS(self.m_heroId)
      if self.CloseForm then
        self:CloseForm()
      end
    end
  })
end

function Form_HeroSkillReset:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_HeroSkillReset:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_HeroSkillReset", Form_HeroSkillReset)
return Form_HeroSkillReset
