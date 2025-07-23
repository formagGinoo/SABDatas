local BaseManager = require("Manager/Base/BaseManager")
local meta = class("GameManager", BaseManager)

function meta:OnCreate()
  self.m_vManagerList = {}
  self:loadManager("Manager/ChannelManager")
  self:loadManager("Manager/RedDotSystem/RedDotManager")
  self:loadManager("Manager/LocalDataManager")
  self:loadManager("Manager/NetworkManager")
  self:loadManager("Manager/ConfigManager")
  self:loadManager("Manager/ClientDataManager")
  self:loadManager("Manager/RoleManager")
  self:loadManager("Manager/GMManager")
  self:loadManager("Manager/UserDataManager")
  self:loadManager("Manager/SettingManager")
  self:loadManager("Manager/QSDKManager")
  self:loadManager("Manager/DmmManager")
  self:loadManager("Manager/ItemManager")
  self:loadManager("Manager/LevelManager")
  self:loadManager("Manager/EquipManager")
  self:loadManager("Manager/ActivityManager")
  self:loadManager("Manager/HeroActivityManager")
  self:loadManager("Manager/StatueShowroomManager")
  self:loadManager("Manager/StoryManager")
  self:loadManager("Manager/GuideManager")
  self:loadManager("Manager/CineVoiceInBattleManager")
  self:loadManager("Manager/EmailManager")
  self:loadManager("Module/ModuleManager")
  self:loadManager("Manager/HeroManager")
  self:loadManager("Manager/SubPanelManager")
  self:loadManager("Manager/PushFaceManager")
  self:loadManager("Manager/PushMessageManager")
  self:loadManager("Manager/HangUpManager")
  self:loadManager("Manager/UnlockManager")
  self:loadManager("Manager/ConditionManager")
  self:loadManager("Manager/TaskManager")
  self:loadManager("Manager/ReportManager")
  self:loadManager("Manager/DirtyCharManager")
  self:loadManager("Manager/InheritManager")
  self:loadManager("Manager/DownloadManager")
  self:loadManager("Manager/GachaManager")
  self:loadManager("Manager/ShopManager")
  self:loadManager("Manager/RankManager")
  self:loadManager("Manager/ArenaManager")
  self:loadManager("Manager/BattleFlowManager")
  self:loadManager("Manager/PushNotificationSystem/PushNotificationManager")
  self:loadManager("Manager/GuildManager")
  self:loadManager("Manager/AttractManager")
  self:loadManager("Manager/LegacyManager")
  self:loadManager("Manager/LevelHeroLamiaActivityManager")
  self:loadManager("Manager/IAPManager")
  self:loadManager("Manager/MonthlyCardManager")
  self:loadManager("Manager/MallGoodsChapterManager")
  self:loadManager("Manager/GameSceneManager")
  self:loadManager("Manager/CastleManager")
  self:loadManager("Manager/StargazingManager")
  self:loadManager("Manager/MainExploreManager")
  self:loadManager("Manager/PvpReplaceManager")
  self:loadManager("Manager/PersonalRaidManager")
  self:loadManager("Manager/GlobalRankManager")
  self:loadManager("Manager/CastleDispatchManager")
  self:loadManager("Manager/LegacyLevelManager")
  self:loadManager("Manager/FriendManager")
  self:loadManager("Manager/CouncilHallManager")
  self:loadManager("Manager/CastleStoryManager")
  self:loadManager("Manager/UIDynamicObjectSystem/UIDynamicObjectManager")
  self:loadManager("Manager/BackPressedManager")
  self:loadManager("Manager/RogueStageManager")
  self:loadManager("Manager/HuntingRaidManager")
  self:loadManager("Manager/AncientManager")
end

function meta:loadManager(managerpath, ...)
  local manager = require(managerpath):getInstance(...)
  table.insert(self.m_vManagerList, manager)
  _G[manager:getName()] = manager
end

function meta:initLoginPush()
  for _, manager in ipairs(self.m_vManagerList) do
    manager:initLoginPush()
  end
end

function meta:initNetwork()
  if self.m_bInitNetwork == nil then
    self.m_bInitNetwork = true
  else
    return
  end
  for _, manager in ipairs(self.m_vManagerList) do
    manager:initNetwork()
  end
end

function meta:dailyReset()
  for _, manager in ipairs(self.m_vManagerList) do
    manager:dailyReset()
  end
end

function meta:dailyZeroReset()
  for _, manager in ipairs(self.m_vManagerList) do
    manager:dailyZeroReset()
  end
end

function meta:OnUpdate(dt)
  for _, manager in ipairs(self.m_vManagerList) do
    manager:update(dt)
  end
end

function meta:OnDestroy()
  for _, manager in ipairs(self.m_vManagerList) do
    manager:destoryInstance()
  end
  self.m_vManagerList = {}
end

function meta:ReGameLogin()
  self:broadcastEvent("eGameEvent_Login_ReLogin")
end

function meta:OnAfterFreshData()
  for _, manager in ipairs(self.m_vManagerList) do
    if manager and manager.OnAfterFreshData then
      manager:OnAfterFreshData()
    end
  end
end

function meta:OnInitMustRequestInFetchMore()
  for _, manager in ipairs(self.m_vManagerList) do
    TimeService:SetTimer(0.05, 1, function()
      if manager and manager.OnInitMustRequestInFetchMore then
        manager:OnInitMustRequestInFetchMore()
      end
    end)
  end
end

function meta:OnAfterInitConfig()
  for _, manager in ipairs(self.m_vManagerList) do
    if manager and manager.OnAfterInitConfig then
      manager:OnAfterInitConfig()
    end
  end
end

return meta
