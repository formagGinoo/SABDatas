local Form_HeroAbilityDetail = class("Form_HeroAbilityDetail", require("UI/UIFrames/Form_HeroAbilityDetailUI"))
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local EnterAnimStr = "heroabilitydetail_ziti_in"

function Form_HeroAbilityDetail:SetInitParam(param)
end

function Form_HeroAbilityDetail:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_showAttrMoreCfgList = nil
  self.m_showAttrMoreItems = {}
  self:InitData()
  self:InitUI()
end

function Form_HeroAbilityDetail:OnActive()
  self.super.OnActive(self)
  self.m_heroAttrList = {}
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_heroAttrList = tParam.heroAttrList
  self:FreshUI()
  self:CheckShowEnterAnim()
end

function Form_HeroAbilityDetail:OnInactive()
  self.super.OnInactive(self)
end

function Form_HeroAbilityDetail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroAbilityDetail:InitData()
  self.m_showAttrMoreCfgList = {}
  local propertyAllCfg = PropertyIndexIns:GetAll()
  for _, tempCfg in pairs(propertyAllCfg) do
    if tempCfg.m_Show == 1 then
      self.m_showAttrMoreCfgList[#self.m_showAttrMoreCfgList + 1] = tempCfg
    end
  end
end

function Form_HeroAbilityDetail:InitUI()
  for _, v in ipairs(self.m_showAttrMoreCfgList) do
    local attrItemRoot = GameObject.Instantiate(self.m_attributes_item_base, self.m_details.transform).transform
    UILuaHelper.SetActive(attrItemRoot, true)
    local attrNumText = attrItemRoot:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
    local attrIconImg = attrItemRoot:Find("c_icon"):GetComponent(T_Image)
    local attrNameText = attrItemRoot:Find("c_txt_sx_name"):GetComponent(T_TextMeshProUGUI)
    local attrItem = {
      itemRoot = attrItemRoot,
      attrNumText = attrNumText,
      attrIconImg = attrIconImg,
      attrNameText = attrNameText,
      propertyCfg = v
    }
    attrNameText.text = v.m_mCNName
    UILuaHelper.SetAtlasSprite(attrIconImg, v.m_PropertyIcon .. "_02")
    self.m_showAttrMoreItems[#self.m_showAttrMoreItems + 1] = attrItem
  end
end

function Form_HeroAbilityDetail:FreshUI()
  local heroAttr = self.m_heroAttrList
  for _, attrItem in ipairs(self.m_showAttrMoreItems) do
    local serverAttrValue = heroAttr["i" .. attrItem.propertyCfg.m_ENName] or 0
    if not heroAttr["i" .. attrItem.propertyCfg.m_ENName] then
      serverAttrValue = heroAttr[attrItem.propertyCfg.m_ENName] or 0
    end
    local showStr = BigNumFormat(serverAttrValue)
    if attrItem.propertyCfg.m_Type == HeroManager.AttrType.TenThousandPercent then
      showStr = math.floor(serverAttrValue / 100) .. "%"
    end
    attrItem.attrNumText.text = showStr
  end
end

function Form_HeroAbilityDetail:CheckShowEnterAnim()
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, EnterAnimStr)
end

function Form_HeroAbilityDetail:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroAbilityDetail:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroAbilityDetail:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_HeroAbilityDetail", Form_HeroAbilityDetail)
return Form_HeroAbilityDetail
