local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroHotItem = class("UIHeroHotItem", UIItemBase)
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function UIHeroHotItem:OnInit()
  self.heroitem = self.m_item_hot.transform:Find("c_common_hero_hot").gameObject
end

function UIHeroHotItem:OnFreshData()
  local score = self.m_itemData.fScore
  local isNew = self.m_itemData.bIsNew
  local heroCfg = CharacterInfoIns:GetValue_ByHeroID(self.m_itemData.iHeroId)
  self:OnFreshUI(heroCfg, score, isNew)
end

function UIHeroHotItem:OnFreshUI(heroCfg, score, isNew)
  local characterCfg = heroCfg
  if self.heroitem then
    if characterCfg then
      UILuaHelper.SetActive(self.heroitem, true)
      local heroWid = self:createHeroIcon(self.heroitem)
      heroWid:SetHeroDataHeroHot(characterCfg)
      heroWid:SetHeroIconClickCB(function()
        StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
          heroID = characterCfg.m_HeroID
        })
      end)
    else
      UILuaHelper.SetActive(self.heroitem, false)
    end
  end
  local tempscore = math.floor(score * 10)
  local scorefin = tempscore / 10
  self.m_txt_score_num_Text.text = tostring(scorefin)
  self.m_txt_heroname_Text.text = tostring(characterCfg.m_mName)
  ResourceUtil:CreateEquipTypeImg(self.m_icon_skill1:GetComponent("Image"), characterCfg.m_Equiptype)
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(characterCfg.m_Career)
  if careerCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_skill2:GetComponent("Image"), careerCfg.m_CareerIcon)
  UILuaHelper.SetActive(self.m_icon_moon1, characterCfg.m_MoonType == 1)
  UILuaHelper.SetActive(self.m_icon_moon2, characterCfg.m_MoonType == 2)
  UILuaHelper.SetActive(self.m_icon_moon3, characterCfg.m_MoonType == 3)
  UILuaHelper.SetActive(self.m_img_new, isNew)
  local btn1 = self.m_btn_skill1:GetComponent(T_Button)
  local btn2 = self.m_btn_skill2:GetComponent(T_Button)
  local btn3 = self.m_btn_skill3:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(btn1, function()
    StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {heroCfg = characterCfg})
  end)
  UILuaHelper.BindButtonClickManual(btn2, function()
    StackPopup:Push(UIDefines.ID_FORM_HEROCAREERDETAIL, {heroCfg = characterCfg})
  end)
  UILuaHelper.BindButtonClickManual(btn3, function()
    StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {heroCfg = characterCfg, isMoonType = true})
  end)
end

function UIHeroHotItem:OnHeroItemClick()
end

return UIHeroHotItem
