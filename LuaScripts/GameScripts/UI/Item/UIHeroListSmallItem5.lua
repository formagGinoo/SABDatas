local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroListSmallItem5 = class("UIHeroListSmallItem5", UIItemBase)
local LineMaxCount = 5
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function UIHeroListSmallItem5:OnInit()
end

function UIHeroListSmallItem5:OnFreshData()
  self:InitItem()
  if not self.m_heroWidgetList then
    return
  end
  for i = 1, #self.m_heroWidgetList do
    local heroinfoId = self.m_itemData.vHeroId[i]
    if heroinfoId then
      local characterCfg = HeroManager:GetHeroConfigByID(heroinfoId)
      if characterCfg then
        self.m_heroWidgetList[i].heroWid:SetHeroDataHeroHot(characterCfg)
        self.m_heroWidgetList[i].heroWid:SetHeroIconClickCB(function()
          StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
            heroID = characterCfg.m_HeroID
          })
        end)
        do
          local data = HeroManager:GetHeroDataByID(characterCfg.m_HeroID)
          if not data then
            UILuaHelper.SetActive(self.m_heroWidgetList[i].heroMask, true)
          else
            UILuaHelper.SetActive(self.m_heroWidgetList[i].heroMask, false)
          end
          ResourceUtil:CreateEquipTypeImg(self.m_heroWidgetList[i].heroCamp, characterCfg.m_Equiptype)
        end
      end
    end
  end
  local tempscore = math.floor(self.m_itemData.fScore * 10 or 0)
  local score = tempscore / 10
  self.m_txt_score_numrecom_Text.text = tostring(score)
end

function UIHeroListSmallItem5:InitItem()
  self.heroitem = self.m_form_rootrecom.transform:Find("c_common_hero_small").gameObject
  local childCount = self.m_form_rootrecom.transform.childCount
  self.m_heroWidgetList = {}
  if childCount < 5 then
    for i = 1, 5 do
      local tempitem = GameObject.Instantiate(self.heroitem, self.m_form_rootrecom.transform).gameObject
      tempitem.name = tostring(i)
      local item = {
        heroWid = self:createHeroIcon(tempitem),
        heroMask = tempitem.transform:Find("m_notownedrecom").gameObject,
        heroCamp = tempitem.transform:Find("m_pnl_camp/img_bg_camp/m_icon_camp"):GetComponent(T_Image)
      }
      table.insert(self.m_heroWidgetList, item)
    end
    self.heroitem:SetActive(false)
  else
    for i = 1, 5 do
      local tempitem = self.m_form_rootrecom.transform:GetChild(i)
      tempitem.name = tostring(i)
      local item = {
        heroWid = self:createHeroIcon(tempitem),
        heroMask = tempitem.transform:Find("m_notownedrecom").gameObject,
        heroCamp = tempitem.transform:Find("m_pnl_camp/img_bg_camp/m_icon_camp"):GetComponent(T_Image)
      }
      table.insert(self.m_heroWidgetList, item)
    end
  end
end

return UIHeroListSmallItem5
