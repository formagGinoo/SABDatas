local UISubPanelBase = require("UI/Common/UISubPanelBase")
local OnePicActivitySubPanel = class("OnePicActivitySubPanel", UISubPanelBase)
local PicPath = {
  "ActivitySinglePic/wm_benefits_bg_01",
  "ActivitySinglePic/wm_benefits_bg_01_s",
  "ActivitySinglePic/activtyout_bg",
  "Atlas_MultiLan_cn_cht/activtyout_title_cht",
  "Atlas_MultiLan_cn/activtyout_title_cn",
  "Atlas_MultiLan_en/activtyout_title_en",
  "Atlas_MultiLan_ja/activtyout_title_ja",
  "Atlas_MultiLan_kr/activtyout_title_kr"
}

function OnePicActivitySubPanel:OnInit()
end

function OnePicActivitySubPanel:OnFreshData()
  self:RefreshUI()
end

function OnePicActivitySubPanel:AddEventListeners()
end

function OnePicActivitySubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function OnePicActivitySubPanel:RefreshUI()
  self.m_stActivity = self.m_panelData.activity
  if self.m_stActivity == nil then
    return
  end
  local cfg = self.m_stActivity:GetOnePicActCfg()
  UILuaHelper.SetAtlasSprite(self.m_bg_Image, cfg.sBGPicPath, nil, nil, true)
  local subPicPath = self.m_stActivity:getLangText(cfg.sSubPicPath)
  self.m_bg:SetActive(true)
  self.m_bg_s:SetActive(true)
  UILuaHelper.SetAtlasSprite(self.m_bg_s_Image, subPicPath, function()
    self.m_bg_s_Image:SetNativeSize()
  end, nil, true)
  self.m_bg_s:GetComponent("RectTransform").anchoredPosition = Vector3(cfg.iSubPicPosX or 0, cfg.iSubPicPosY or 0, 0)
  if cfg.iJumpType and cfg.sJumpParam then
    UILuaHelper.BindButtonClickManual(self, self.m_bg.transform:GetComponent("Button"), function()
      ActivityManager:DealJump(cfg.iJumpType, cfg.sJumpParam)
    end)
  end
end

function OnePicActivitySubPanel:GetDownloadResourceExtra(subPaneCfg)
  local vPackage = {}
  local vResourceExtra = {}
  for i, v in ipairs(PicPath) do
    vResourceExtra[#vResourceExtra + 1] = {
      sName = v,
      eType = DownloadManager.ResourceType.Atlas
    }
  end
  return vPackage, vResourceExtra
end

return OnePicActivitySubPanel
