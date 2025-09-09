local Form_DownloadCleanTips = class("Form_DownloadCleanTips", require("UI/UIFrames/Form_DownloadCleanTipsUI"))

function Form_DownloadCleanTips:SetInitParam(param)
end

function Form_DownloadCleanTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_DownloadCleanTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_finishCallback = tParam.finishCallback
  self.m_vDeleteList = tParam.vDeleteList
  TimeService:SetTimer(0.5, 1, function()
    local fullPath
    for k, resPath in ipairs(self.m_vDeleteList) do
      fullPath = CS.MUF.Resource.ResourceLocationHelper.Instance.PersistentDataAssetsPath .. "/" .. resPath
      if CS.System.IO.File.Exists(fullPath) then
        log.info(fullPath .. " deleted...")
        CS.System.IO.File.Delete(fullPath)
      end
    end
    if self.m_finishCallback then
      self.m_finishCallback(true)
    end
    self:CloseForm()
  end)
end

function Form_DownloadCleanTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_DownloadCleanTips:OnDestroy()
  self.super.OnDestroy(self)
end

ActiveLuaUI("Form_DownloadCleanTips", Form_DownloadCleanTips)
return Form_DownloadCleanTips
