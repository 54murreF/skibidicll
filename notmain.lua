--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║              CLL CHEAT - FULL INTEGRATION v11.83-be (native Q/G grab mirror + VR restore)                ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  SUK head-hit, real crosshair, tracers, ESP outline nick,     ║
    ║  ChinaHat/Wings fix, VR hands, anti-flash/shake, antibypass   ║
    ╚═══════════════════════════════════════════════════════════════╝
]]


-- ==================== ANTI-BYPASS (loader-only) ====================
do
	local EXPECT = "CLL_BOOT_v3_htua_9f3a7c2e"
	local function genv()
		local g = _G
		pcall(function() if getgenv then g = getgenv() end end)
		return g
	end
	local g = genv()
	local tok = rawget(g, "CLL_BOOT_TOKEN") or rawget(_G, "CLL_BOOT_TOKEN")
	local from = rawget(g, "CLL_FROM_LOADER") or rawget(_G, "CLL_FROM_LOADER")
	local byLoader = rawget(g, "CLL_LOADED_BY_LOADER") or rawget(_G, "CLL_LOADED_BY_LOADER")
		or rawget(g, "CLL_LOADED_FROM_LOADER") or rawget(_G, "CLL_LOADED_FROM_LOADER")
	local auth = rawget(g, "CLL_Auth") or rawget(_G, "CLL_Auth")
	local sess = rawget(g, "CLL_SESSION") or rawget(_G, "CLL_SESSION")
	local authOk = type(auth) == "table" and tostring(auth.status or ""):lower():find("valid")
	local sessionOk = type(sess) == "table" and sess.ok == true

	-- one-shot consume
	pcall(function()
		rawset(_G, "CLL_BOOT_TOKEN", nil)
		rawset(_G, "CLL_FROM_LOADER", nil)
		if g ~= _G then
			rawset(g, "CLL_BOOT_TOKEN", nil)
			rawset(g, "CLL_FROM_LOADER", nil)
		end
	end)

	local allowed = (tok == EXPECT and from == true)
		or (byLoader == true and (authOk or sessionOk))
		or (sessionOk and authOk)

	if not allowed then
		warn("[CLL] blocked: run via spec-loader (loadstring)")
		return
	end
	if rawget(_G, "CLL_SESSION_ACTIVE") then
		return
	end
	rawset(_G, "CLL_SESSION_ACTIVE", true)
end
-- ===================================================================

local function CLL_Main()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local flyVelocity, flyGyro, spinAngular, InfiniteJumpConnection
local ST = {
	Language = "en",
	isMultiSuk = false,
	SUK_FIRERATE_RPS = 10,
	SUK_FireDelay = 0.1,
	SUK_EquipRequired = true,
	SUK_IgnoreFriends = true,
	SUK_TargetNPCs = false,
	reloadInProgress = false,
	PermanentReloadEnabled = false,
	NoRecoilEnabled = false,
	AntiFlashEnabled = true,
	AntiFlashBlockKill = true,
	AntiFlashBlockBang = true,
	KillHighlightEnabled = true,
	KillHighlightDuration = 0.55,
	KillHighlightFade = 0.65,
	KillHighlightColor = Color3.fromRGB(40, 160, 255),
	KillBeamEnabled = true,
	AntiCamShakeEnabled = false,
	CustomKillSoundEnabled = false, -- REMOVED
	CustomGunSoundsEnabled = false, -- REMOVED
	ReloadSpeed = 0.055,
	AntiCCEnabled = false,
	SUK_MaxPerTick = 1,
	TracersEnabled = false,
	AutoBlockEnabled = false,
	AutoBlockRange = 12,
	AutoBlockHold = 0.35,
	AutoBlockCooldown = 0.55,
	AutoBlockMeleeOnly = true,
	VRTargetMaxSpeed = 90,
	VRTargetProtect = true,
	CursorTrailEnabled = false, -- replaced by menu click ring

	CursorTrailLength = 12,
	CursorTrailSize = 6,
	CursorTrailFade = 0.35,
	CursorTrailColor = Color3.fromRGB(90, 160, 255),
	BgPatternEnabled = false, -- keep off by default (FPS)

	BgPatternSeed = 1,
	BgPatternDensity = 0.4,
	BgPatternScale = 1,
	BgPatternSpeed = 0.15,
	BgPatternColor = Color3.fromRGB(40, 60, 120),
	ESPShowTool = true,
	ESPShowReload = true,
	ESPShowRagdoll = true,

	TracerDuration = 0.5,
	TracerSelfEnabled = true,
	TracerOthersEnabled = true,
	TracerFriendsEnabled = true,
	TracersOthers = true,
	VREnabled = false,
	VRShakeEnabled = false,
	VRHandExtend = 1.2,   -- forward reach (studs)
	VRHandHeight = 0.2,   -- vertical offset from torso
	VRHandWidth = 1.05,   -- half-separation left/right
	VRSwingReach = 2.5,   -- how far the slap travels forward
	VRShakeIntensity = 0.5,
	SkyColorEnabled = false,
	KeybindWatermarkVisible = true,
	isBinding = false,
	HealEnabled = false,
	HealFlyHeight = 3.5,
	isBlockActive = false,
	HighlightChamsEnabled = false,
	WalkSpeedEnabled = false,
	WalkSpeedValue = 16,
	JumpPowerEnabled = false,
	JumpPowerValue = 50,
	InfiniteJumpEnabled = false,
	NoClipEnabled = false,
	NoFallEnabled = false,
	FlyEnabled = false,
	FlySpeed = 50,
	SpinEnabled = false,
	SpinSpeed = 5,
	AntiSlowEnabled = false,
	AntiLagEnabled = false,
	ChinaHatEnabled = false,
	WingsEnabled = false,
	TimeOverrideEnabled = false,
	TimeOverrideValue = 12,
	CameraFOVLocked = false,
	CameraFOVValue = 70,
	MaxZoomEnabled = false,
	MaxZoomValue = 128,
	RemoveFogEnabled = false,
	FullbrightEnabled = false,
	UIOpacity = 0.1,
	MenuGridEnabled = false,
	MenuGridSpeed = 1,
	MenuGridTransparency = 0.85,
	MenuGridColor = Color3.fromRGB(80, 140, 255),
	MenuBgStyle = "chess",
	MenuGridRotation = 0,
	AccentH = 220, AccentS = 0.78, AccentV = 1,
	WatermarkMainVisible = true,
	WatermarkBindsVisible = true,
	WatermarkWorldVisible = true,
	WatermarkAmmoVisible = true,
	isUnloaded = false,
	SilentAimEnabled = false,
	SilentAimFOV = 90,
	RealCrosshairEnabled = true,
	TrueCrosshairEnabled = true,
	LocalInvisEnabled = false,
	NoSpreadEnabled = false,
	HitSoundEnabled = false,
	HitSoundVolume = 0.9,
	HitSoundPreset = "Click",
	SilentAimPart = "Head",
	GunSoundVolume = 0.9,
	VRTargetEnabled = false,
	HitboxFilterEnabled = false, -- when true: only HitboxSelectedTargets; when false: all players
	VRSwingSpeed = 14,
	VRSwingAmp = 1.8,
	ColorSelf = Color3.fromRGB(255, 50, 50),
	ColorOthers = Color3.fromRGB(255, 220, 50),
	ColorFriends = Color3.fromRGB(85, 255, 127),
}

--// ==================== UI ANIMATION PRESETS ====================
local ES, ED = Enum.EasingStyle, Enum.EasingDirection
local SPEED = 1.0
local AnimName = "Smooth"
local AnimOrder = { "Smooth", "Bounce", "Elastic", "Snappy", "Pop", "Slide", "Soft fade" }
local AnimPresets = {
	Smooth = { open = { ES.Quint, ED.Out, 0.5 }, close = { ES.Quart, ED.In, 0.32 }, scale = 0.93 },
	Bounce = { open = { ES.Back, ED.Out, 0.5 }, close = { ES.Back, ED.Out, 0.45 }, scale = 0.5 },
	Elastic = { open = { ES.Elastic, ED.Out, 0.8 }, close = { ES.Quad, ED.In, 0.25 }, scale = 0.7 },
	Snappy = { open = { ES.Exponential, ED.Out, 0.35 }, close = { ES.Exponential, ED.In, 0.22 }, scale = 0.96 },
	Pop = { open = { ES.Back, ED.Out, 0.4 }, close = { ES.Back, ED.In, 0.3 }, scale = 0.6 },
	Slide = { open = { ES.Cubic, ED.Out, 0.45 }, close = { ES.Cubic, ED.In, 0.3 }, scale = 1 },
	["Soft fade"] = { open = { ES.Sine, ED.Out, 0.35 }, close = { ES.Sine, ED.In, 0.25 }, scale = 1 },
}

--// ==================== STATE ====================


local FriendsList = {} -- [userId] = displayName string or true
local Whitelist = {} -- [userId] = displayName — protected from SUK/VR target

local RefreshFriendsUI = nil -- set by Settings page
local SelectedTargets = {}
local VRSelectedTargets = {}
local HitboxSelectedTargets = {}  -- multi-select: only these get hitbox expand


local CustomKillSoundId = ""
local CustomHitSoundId = ""
local HitSoundPresets = {
	Click = "rbxasset://sounds/switch.wav",
	Metal = "rbxasset://sounds/collide.wav",
	Punch = "rbxasset://sounds/impact_explosion.mp3",
	Soft = "rbxasset://sounds/electronicpingshort.wav",
	Custom = "",
}

local CustomGunSoundIds = {
	["Spas 12"] = "",
	["Spas12"] = "",
	["SPAS 12"] = "",
	["Remington"] = "",
	["AK47"] = "",
	["AK-47"] = "",
	["AR"] = "",
	["P250"] = "",
	["Deagle"] = "",
}
function resolveGunSoundKey(toolName)
	if not toolName then return nil end
	local n = string.lower(toolName)
	if n:find("spas") then return "Spas 12" end
	if n:find("remington") then return "Remington" end
	if n:find("ak") or n:find("kalash") or n:find("калиш") then return "AK47" end
	if n:find("p250") then return "P250" end
	if n:find("deagle") or n:find("desert") then return "Deagle" end
	if n:find("ar%-15") or n == "ar" or n:find("ar15") then return "AR" end
	return toolName
end


local AntiCC_Flags = {
	Stunned = true, Endlag = true, Hurt = true, Kicking = true,
	CantSprint = true, CantWalk = true, CantJump = true,
	CantStomp = false, CantDropkick = false, BackKickCooldown = false,
	DropkickCooldown = false, StompCooldown = false,
}


-- Tracers


-- per-category tracers (self / others / friends)


-- ST.ColorSelf -> ST.ColorSelf
-- ST.ColorOthers -> ST.ColorOthers
-- ST.ColorFriends -> ST.ColorFriends
-- legacy TracerColor removed
local lastLocalShotAt = 0
local lastMeleeAt = 0
local lastLocalShotOrigin = nil
function markLocalShot(origin)
	lastLocalShotAt = os.clock()
	if typeof(origin) == "Vector3" then lastLocalShotOrigin = origin end
end


-- VR State


local VRService = game:GetService("VRService")
local VRWantEnabled = false -- user intent; survives death for auto re-toggle
local VRToggleSetUI = nil -- mini-toggle setter from VR page

-- Sky State

local SkyColor = Color3.fromRGB(50, 150, 255)

-- Keybind State
local Keys = {
	VRSwing = Enum.UserInputType.MouseButton1,
	ESP = Enum.KeyCode.Unknown, Hitbox = Enum.KeyCode.Unknown, SUK = Enum.KeyCode.Unknown, 
	NoRecoil = Enum.KeyCode.Unknown, AntiCC = Enum.KeyCode.Unknown, 
	Spin = Enum.KeyCode.Unknown, Fly = Enum.KeyCode.Unknown, WalkSpeed = Enum.KeyCode.Unknown, 
	JumpPower = Enum.KeyCode.Unknown, Heal = Enum.KeyCode.Unknown, SilentAim = Enum.KeyCode.Unknown,
	ChinaHat = Enum.KeyCode.Unknown, Wings = Enum.KeyCode.Unknown, AntiLag = Enum.KeyCode.Unknown,
	Menu = Enum.KeyCode.RightShift, TeleportHeal = Enum.KeyCode.Unknown,
	ReloadSpas = Enum.KeyCode.Unknown, TeleportCursor = Enum.KeyCode.Unknown
}


local bindTarget = nil
local UI_Keybinds = {}


local healConnection, antiVelocityConnection
local savedCollision = {}

local savedHealPosition = nil

local ESP_Config = {
    Enabled = false, Box = true, Name = true, Health = true, Distance = true, MaxDist = 1000,
    ShowTool = true, ShowReload = true, ShowRagdoll = true,
    ChamsColor = Color3.fromRGB(255, 92, 122), FriendColor = Color3.fromRGB(85, 255, 127),
    ChamsFillTrans = 0.5, ChamsOutlineTrans = 0
}
local ESP_Cache = {}
local ESPGui = nil


local Hitbox_Config = { Enabled = false, IncludeNPCs = false, Size = 5, Material = "ForceField", Transparency = 0.5 }
local Hitbox_Cache = {}
local NPC_List = {}
local last_npc_scan = 0


local Connections = {}
local isCharRagdoll, vrReleaseForRagdoll
local UI_SyncHooks = {}
local markKillCandidate, playKillHighlight, onVictimDied -- forward decl
local UI_BindLabels = {} -- keyName -> TextButton to refresh bind text
local UI_SliderHooks = {} -- functions to push slider visuals from ST
local SessionStartTime = os.clock()

--// ==================== i18n ====================
ST.Language = ST.Language or "en"
local LANG = {
	ru = {
		suk_warn = "⚠ Для стабильного рега: RPS 6–8 · Delay 0.12–0.15 · Targets/tick = 1.\nСлишком высокий firerate → FX есть, урона нет.",
		lang = "Язык UI",
		lang_val = "Русский",
		profile_title = "П Р О Ф И Л Ь",
		profile_session = "Сессия",
		profile_build = "Сборка",
		profile_status = "Статус",
		profile_active = "Активен",
		profile_ops = "Оператор CLL",
		profile_stats = "С Е С С И Я",
		profile_ping = "Пинг",
		profile_fps = "FPS",
		profile_feat = "Модули",
		profile_tip = "Совет",
		profile_tip_body = "SUK: не гони firerate. Invis + дальняк требуют head-TP пуль.\nКонфиг сохраняется локально.",
		profile_uid = "UserId",
		profile_server = "Сервер",
		-- feature titles
		t_suk = "Включить SUK",
		t_suk_rps = "Firerate RPS",
		t_suk_delay = "Fire Delay (Safe)",
		t_suk_targets = "Targets / tick",
		t_heal = "Автохил",
		t_heal_h = "Высота хила",
		t_ignore_friends = "Игнор друзей",
		t_target_npcs = "Цель: NPC",
		t_equip = "Нужен Spas в руках",
		t_silent = "Silent Aim",
		t_invis = "Local Invis",
		t_tracers = "Трассеры",
		t_esp = "ESP",
		t_vr = "VR Mode",
		t_antiflash = "Anti Flash",
		t_anticc = "Anti CC",
		t_grid = "Сетка меню",
		t_wm = "Watermark",
		-- descriptions: what it is + what it does
		d_suk = "Автострельба по выбранным целям в голову.",
		d_suk_rps = "Сколько выстрелов SUK делает в секунду.",
		d_suk_delay = "Минимальная пауза между выстрелами SUK.",
		d_suk_targets = "Сколько целей обрабатывать за один тик (сейчас фактически 1).",
		d_heal = "Телепорт в зону хила только пока HP ниже максимума.",
		d_heal_h = "Высота над зоной хила при автотелепорте.",
		d_ignore_friends = "SUK не стреляет по игрокам из списка друзей.",
		d_target_npcs = "SUK также берёт NPC из workspace.Humans.",
		d_equip = "Стрельба только если Spas-12 экипирован.",
		d_silent = "Подводит направление выстрела к цели в FOV.",
		d_invis = "Уносит персонажа далеко на сервере и локально.",
		d_tracers = "Рисует линии пуль своих/чужих выстрелов.",
		d_esp = "Показывает игроков сквозь стены (боксы/имена).",
		d_vr = "Включает VR-руки и VR-камеру в игре.",
		d_antiflash = "Убирает эффект ослепления от флешек.",
		d_anticc = "Снимает замедления и control-эффекты.",
		d_grid = "Анимированная сетка на фоне меню.",
		d_wm = "Оверлей FPS/пинга на экране.",
		d_killbeam = "Вертикальный столб на месте убитого.",
		t_vr_target = "VR Target Mode",
		d_vr_target = "В VR телепортирует к выбранной цели.",
		t_vr_shake = "Тряска рук",
		d_vr_shake = "Лёгкое покачивание VR-рук.",
		t_shake_i = "Сила тряски",
		d_shake_i = "Насколько сильно качаются руки.",
		t_wm_binds = "Watermark бинды",
		d_wm_binds = "Показ текущих клавиш на экране.",
		t_wm_world = "Watermark мир",
		d_wm_world = "Доп. инфо о мире на экране.",
		t_wm_ammo = "Watermark патроны",
		d_wm_ammo = "Показ патронов у курсора.",
		t_theme = "Белая тема", d_theme = "Светлый фон; текст становится тёмным.",
		t_walk = "Скорость ходьбы", d_walk = "Меняет скорость ходьбы.",
		t_jump = "Сила прыжка", d_jump = "Меняет высоту прыжка.",
		t_fly = "Полёт", d_fly = "Позволяет летать в воздухе.",
		t_spin = "Спин", d_spin = "Вращает персонажа на месте.",
		t_noclip = "Ноуклип", d_noclip = "Проход сквозь стены и объекты.",
		t_infjump = "Бесконечный прыжок", d_infjump = "Прыжок снова в воздухе.",
		t_chams = "Чамсы", d_chams = "Подсветка моделей игроков.",
		t_aimvis = "Aim Visualizer", d_aimvis = "Визуальные хелперы прицела/FOV.",
		t_killhl = "Kill Highlight", d_killhl = "Подсветка убитых игроков.",
		t_hat = "China Hat", d_hat = "Косметический конус на голове.",
		t_wings = "Крылья", d_wings = "Косметические крылья на спине.",
		t_antilag = "Anti-Lag", d_antilag = "Чистит дебрис и тяжёлые эффекты.",
		t_fog = "Убрать туман", d_fog = "Убирает дальний туман.",
		t_fb = "Fullbright", d_fb = "Делает карту полностью яркой.",
		t_time = "Время суток", d_time = "Фиксирует время дня.",
		t_fovlock = "FOV камеры", d_fovlock = "Фиксирует поле зрения камеры.",
		t_rain = "Убрать дождь", d_rain = "Один раз убирает дождь, облака и погоду.",
		t_wrain = "Дождь", d_wrain = "Включает дождливую погоду.",
		t_hitbox = "Хитбокс", d_hitbox = "Увеличивает хитбокс цели.",
		t_norecoil = "Без отдачи", d_norecoil = "Убирает отдачу оружия.",
		t_firerate = "Скорострельность", d_firerate = "Ускоряет выстрелы при зажатии ЛКМ.",
		t_nospread = "Без разброса", d_nospread = "Убирает разброс Spas/Remington.",
		t_maxzoom = "Макс. зум", d_maxzoom = "Меняет максимальную дистанцию камеры.",
		t_sky = "Цвет неба", d_sky = "Красит небо и ambient.",
		tab_Combat = "Бой", tab_Movement = "Движение", tab_Visual = "Визуал",
		tab_Effects = "Эффекты", tab_Target = "Цели", tab_Keybinds = "Бинды",
		tab_VR = "VR", tab_Settings = "Настройки", tab_Profile = "Профиль",
		sec_ATTACK = "АТАКА", sec_MOVEMENT = "ДВИЖЕНИЕ", sec_VISUAL = "ВИЗУАЛ", sec_EFFECTS = "ЭФФЕКТЫ",
		hint_rmb = "ПКМ — настройки",
	},
	en = {
		suk_warn = "⚠ For stable hitreg: RPS 6–8 · Delay 0.12–0.15 · Targets/tick = 1.\nToo high firerate → FX only, no damage.",
		lang = "UI Language",
		lang_val = "English",
		profile_title = "P R O F I L E",
		profile_session = "Session",
		profile_build = "Build",
		profile_status = "Status",
		profile_active = "Active",
		profile_ops = "CLL Operator",
		profile_stats = "S E S S I O N",
		profile_ping = "Ping",
		profile_fps = "FPS",
		profile_feat = "Modules",
		profile_tip = "Tip",
		profile_tip_body = "SUK: don't max firerate. Invis + range need head-TP bullets.\nConfig is saved locally.",
		profile_uid = "UserId",
		profile_server = "Server",
		t_suk = "Enable SUK",
		t_suk_rps = "Firerate RPS",
		t_suk_delay = "Fire Delay (Safe)",
		t_suk_targets = "Targets / tick",
		t_heal = "Auto Healing",
		t_heal_h = "Heal Height",
		t_ignore_friends = "Ignore Friends",
		t_target_npcs = "Target NPCs",
		t_equip = "Equip required",
		t_silent = "Silent Aim",
		t_invis = "Local Invis",
		t_tracers = "Tracers",
		t_esp = "ESP",
		t_vr = "VR Mode",
		t_antiflash = "Anti Flash",
		t_anticc = "Anti CC",
		t_grid = "Menu Grid BG",
		t_wm = "Watermark Main",
		d_suk = "Auto-fires at selected targets' heads.",
		d_suk_rps = "How many SUK shots fire per second.",
		d_suk_delay = "Minimum wait between SUK shots.",
		d_suk_targets = "Targets handled per tick (effectively 1 now).",
		d_heal = "Teleports to the heal zone only while HP is below max.",
		d_heal_h = "Height above the heal zone when auto-porting.",
		d_ignore_friends = "SUK skips players on your friends list.",
		d_target_npcs = "SUK also targets NPCs in workspace.Humans.",
		d_equip = "Only shoots while Spas-12 is equipped.",
		d_silent = "Bends your shot direction toward a FOV target.",
		d_invis = "Moves your character far away on client and server.",
		d_tracers = "Draws bullet lines for your and others' shots.",
		d_esp = "Shows players through walls (boxes/names).",
		d_vr = "Enables VR arms and VR camera in-game.",
		d_antiflash = "Removes flashbang blindness effects.",
		d_anticc = "Clears slow and control-style effects.",
		d_grid = "Animated grid behind the menu panel.",
		d_wm = "On-screen FPS/ping overlay.",
		d_killbeam = "Vertical pillar at the killed player's body.",
		t_vr_target = "VR Target Mode",
		d_vr_target = "In VR, teleports you toward the selected target.",
		t_vr_shake = "Enable Hand Shake",
		d_vr_shake = "Subtle VR hand sway animation.",
		t_shake_i = "Shake Intensity",
		d_shake_i = "How strong the hand sway is.",
		t_wm_binds = "Watermark Binds",
		d_wm_binds = "Shows your keybinds on screen.",
		t_wm_world = "Watermark World",
		d_wm_world = "Extra world info overlay.",
		t_wm_ammo = "Watermark Ammo",
		d_wm_ammo = "Ammo counter near the cursor.",
		t_theme = "White Theme", d_theme = "Light background; text becomes dark.",
		t_walk = "Walk Speed", d_walk = "Changes how fast you walk.",
		t_jump = "Jump Power", d_jump = "Changes how high you jump.",
		t_fly = "Fly", d_fly = "Lets you fly in the air.",
		t_spin = "Spin", d_spin = "Spins your character in place.",
		t_noclip = "No Clip", d_noclip = "Walk through walls and parts.",
		t_infjump = "Infinite Jump", d_infjump = "Jump again while in the air.",
		t_chams = "Highlight Chams", d_chams = "Highlights player models through walls.",
		t_aimvis = "Aim Visualizer", d_aimvis = "Shows aim/FOV helpers on screen.",
		t_killhl = "Kill Highlight", d_killhl = "Marks players you kill.",
		t_hat = "China Hat", d_hat = "Cosmetic cone hat on your head.",
		t_wings = "Custom Wings", d_wings = "Cosmetic wings on your back.",
		t_antilag = "Anti-Lag", d_antilag = "Cleans debris and heavy effects.",
		t_fog = "Remove Fog", d_fog = "Removes distance fog.",
		t_fb = "Fullbright", d_fb = "Makes the map fully bright.",
		t_time = "Time Override", d_time = "Locks the clock time of day.",
		t_fovlock = "Camera FOV Lock", d_fovlock = "Locks camera field of view.",
		t_rain = "Clear Rain/Weather", d_rain = "Removes rain, clouds and weather once.",
		t_wrain = "Weather Rain", d_wrain = "Turns rainy weather on.",
		t_hitbox = "Hitbox Expander", d_hitbox = "Makes target hitboxes larger.",
		t_norecoil = "No Recoil", d_norecoil = "Removes weapon camera recoil.",
		t_firerate = "Firerate", d_firerate = "Speeds up shots while you hold fire.",
		t_nospread = "No Spread", d_nospread = "Removes Spas/Remington pellet spread.",
		t_maxzoom = "Max Zoom", d_maxzoom = "Changes max camera zoom distance.",
		t_sky = "Sky Color", d_sky = "Recolors the sky and ambient light.",
		tab_Combat = "Combat", tab_Movement = "Movement", tab_Visual = "Visual",
		tab_Effects = "Effects", tab_Target = "Target", tab_Keybinds = "Keybinds",
		tab_VR = "VR", tab_Settings = "Settings", tab_Profile = "Profile",
		sec_ATTACK = "ATTACK", sec_MOVEMENT = "MOVEMENT", sec_VISUAL = "VISUAL", sec_EFFECTS = "EFFECTS",
		hint_rmb = "RMB - settings",
	},
}

function L(key)
	if type(key) ~= "string" or key == "" then return tostring(key or "") end
	local lang = ST.Language
	if lang ~= "en" and lang ~= "ru" then lang = "en" end
	local pack = LANG[lang] or LANG.en or LANG.ru
	local s = pack and pack[key]
	if type(s) == "string" then return s end
	local alt = (lang == "en") and LANG.ru or LANG.en
	s = alt and alt[key]
	if type(s) == "string" then return s end
	return key
end
local function Lt(key, fallback)
	local s = L(key)
	if type(s) ~= "string" or s == key then return fallback or key end
	return s
end
local UI_LangHooks = {} -- functions() to refresh labels on language change
local function refreshLanguage()
	for _, fn in ipairs(UI_LangHooks) do
		pcall(fn)
	end
	local function walk(root)
		if not root then return end
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				local k = d:GetAttribute("CLL_LangKey")
				if type(k) == "string" and k ~= "" then
					local t = L(k)
					if type(t) == "string" and t ~= k then
						d.Text = t
					end
				end
			end
		end
	end
	pcall(function()
		if UIRefs and UIRefs.window then walk(UIRefs.window) end
		if gui then walk(gui) end
	end)
end



-- Remotes
local FireRemote, ReloadRemote, BulletModel, SwingRemote, FxRemote
local HelperBE -- PlayerScripts.Helper BindableEvent (local FX / Gun Base)
task.spawn(function()
	pcall(function() FireRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Fire", 5) end)
	pcall(function() ReloadRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reload", 5) end)
	pcall(function() BulletModel = ReplicatedStorage:WaitForChild("Models", 5):WaitForChild("Bullets", 5):WaitForChild("Default", 5) end)
	pcall(function() SwingRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Swing", 5) end)
	pcall(function() FxRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Fx", 5) end)
	pcall(function()
		HelperBE = LocalPlayer:WaitForChild("PlayerScripts", 5):WaitForChild("Helper", 5)
	end)
end)


-- dump-accurate remote fire (bypasses broken namecall arg paths)
local function CLL_FireServer(remote, ...)
	if not remote then return end
	-- plain :FireServer. Hook must pass original ... through (unpack breaks namecall / hitreg).
	local a = { ... }
	local unpackFn = table.unpack or unpack
	pcall(function()
		remote:FireServer(unpackFn(a))
	end)
end

function HelperFire(...)
	if not HelperBE then return end
	local a = { ... }
	local unpackFn = table.unpack or unpack
	pcall(function()
		HelperBE:Fire(unpackFn(a))
	end)
end


--// ==================== COSMETICS (China Hat + Wings from old v2) ====================
local Cosmetics = (function()
	local CFG = {
		Hat = false,
		Wings = false,
		HatColor = Color3.fromRGB(255, 220, 40),
		WingColor = Color3.fromRGB(180, 80, 255),
		WingType = "Normal",
	}
	local folderName = "CLL_Cosmetics"
	local wingConn = nil
	local wingPhase = 0
	local wingState = nil

	local function clear()
		if wingConn then wingConn:Disconnect(); wingConn = nil end
		wingState = nil
		local char = LocalPlayer.Character
		if char then
			local old = char:FindFirstChild(folderName)
			if old then old:Destroy() end
		end
		local cam = workspace.CurrentCamera
		if cam then
			for _, c in ipairs(cam:GetChildren()) do
				if c.Name == "WingFeather" then c:Destroy() end
			end
		end
	end

	local function weld(part0, part1, c0, c1)
		local w = Instance.new("Weld")
		w.Part0 = part0
		w.Part1 = part1
		w.C0 = c0 or CFrame.new()
		w.C1 = c1 or CFrame.new()
		w.Parent = part1
		return w
	end

	local function basePart(name, size, color, parent)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Color = color
		p.Material = Enum.Material.Neon
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.CastShadow = false
		p.Anchored = false
		p.Parent = parent
		return p
	end

	local function mkWedge(parent, parts, transparency, color)
		local w = Instance.new("WedgePart")
		w.Anchored = true
		w.CanCollide = false
		w.CanQuery = false
		w.CanTouch = false
		w.CastShadow = false
		w.Massless = true
		w.Material = Enum.Material.SmoothPlastic
		w.Transparency = transparency or 0.35
		w.Color = color or CFG.HatColor
		w.Parent = parent
		parts[#parts + 1] = w
		return w
	end

	local function mkTriangle(a, b, c, parent, parts, transparency, thick, color)
		local ab, ac, bc = b - a, c - a, c - b
		local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
		if abd > acd and abd > bcd then
			c, a = a, c
		elseif acd > bcd and acd > abd then
			a, b = b, a
		end
		ab, ac, bc = b - a, c - a, c - b
		local cross1 = ac:Cross(ab)
		if cross1.Magnitude < 1e-5 then return end
		local right = cross1.Unit
		local cross2 = bc:Cross(right)
		if cross2.Magnitude < 1e-5 then return end
		local up = cross2.Unit
		local back = bc.Unit
		local height = math.abs(ab:Dot(up))
		local w1 = mkWedge(parent, parts, transparency, color)
		local w2 = mkWedge(parent, parts, transparency, color)
		w1.Size = Vector3.new(thick, math.max(height, 0.02), math.max(math.abs(ab:Dot(back)), 0.02))
		w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, back)
		w2.Size = Vector3.new(thick, math.max(height, 0.02), math.max(math.abs(ac:Dot(back)), 0.02))
		w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -back)
	end

	-- China hat: hollow cone (old v2 triangle ring) welded to head
	local function makeHat(char, head, folder)
		local TRANSP, R, H, TH, SEG = 0.32, 1.55, 0.88, 0.035, 24
		local apex = Vector3.new(0, H, 0)
		local parts = {}
		local model = Instance.new("Model")
		model.Name = "ChinaHat"
		model.Parent = folder
		for i = 0, SEG - 1 do
			local a0 = i / SEG * math.pi * 2
			local a1 = (i + 1) / SEG * math.pi * 2
			local p0 = Vector3.new(math.cos(a0) * R, 0, math.sin(a0) * R)
			local p1 = Vector3.new(math.cos(a1) * R, 0, math.sin(a1) * R)
			mkTriangle(apex, p0, p1, model, parts, TRANSP, TH, CFG.HatColor)
		end
		-- weld each wedge to head via Weld at top of head
		local lift = CFrame.new(0, head.Size.Y / 2 - 0.05, 0)
		for _, part in ipairs(parts) do
			part.Anchored = false
			local localCF = lift * CFrame.new(part.Position)
			-- rebuild orientation relative to head
			part.CFrame = head.CFrame * localCF * (part.CFrame - part.Position)
			local w = Instance.new("Weld")
			w.Part0 = head
			w.Part1 = part
			w.C0 = head.CFrame:ToObjectSpace(part.CFrame)
			w.C1 = CFrame.new()
			w.Parent = part
		end
	end

	-- Wings Normal: feather contour from old v2 WING_PTS
	local WING_PTS = (function()
		local pts = { Vector2.new(1.8, 1.5), Vector2.new(3.8, 2.4), Vector2.new(6.2, 1.6) }
		local F = {
			Vector2.new(5.6, 0.4), Vector2.new(4.8, -0.5), Vector2.new(3.8, -1.2),
			Vector2.new(2.6, -1.6), Vector2.new(1.4, -1.5),
		}
		local prev = pts[3]
		for _, f in ipairs(F) do
			pts[#pts + 1] = (prev + f) / 2 * 0.8
			pts[#pts + 1] = f
			prev = f
		end
		return pts
	end)()

	local function makeWings(char, torso, folder)
		-- OLD v2 style: feather models parented to Camera, PivotTo each frame on torso
		local WING_TRANSPARENCY, WING_THICK = 0.35, 0.03
		local WING_Y, WING_YAW = 0.35, 0.45
		local function buildNormal(side)
			local items = {}
			for i = 1, #WING_PTS - 1 do
				local p1 = Vector3.new(side * WING_PTS[i].X, WING_PTS[i].Y, 0)
				local p2 = Vector3.new(side * WING_PTS[i + 1].X, WING_PTS[i + 1].Y, 0)
				local model = Instance.new("Model")
				model.Name = "WingFeather"
				local parts = {}
				mkTriangle(Vector3.zero, p1, p2, model, parts, WING_TRANSPARENCY, WING_THICK, CFG.WingColor)
				for _, pt in ipairs(parts) do
					pt.Anchored = true
					pt.CanCollide = false
					pt.CanQuery = false
					pt.CastShadow = false
				end
				items[#items + 1] = { model = model, parts = parts, k = i }
			end
			return items
		end
		local state = { torso = torso, wings = {} }
		for _, side in ipairs({ 1, -1 }) do
			state.wings[#state.wings + 1] = { s = side, items = buildNormal(side) }
		end
		local phase, speed, amp = 0, 2.4, 0.16
		if wingConn then wingConn:Disconnect() end
		wingConn = RunService.RenderStepped:Connect(function(dt)
			if not CFG.Wings then return end
			local cam = workspace.CurrentCamera
			local ch = LocalPlayer.Character
			local tor = ch and (ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso"))
			if not (cam and tor) then return end
			state.torso = tor
			local hum = ch:FindFirstChildOfClass("Humanoid")
			local air = hum and hum.FloorMaterial == Enum.Material.Air
			local k = math.min(1, dt * 6)
			speed += ((air and 9 or 2.4) - speed) * k
			amp += ((air and 0.5 or 0.16) - amp) * k
			phase += dt * speed
			local flap = 0.28 + amp * math.sin(phase)
			local head = ch:FindFirstChild("Head")
			local show = not head or (cam.CFrame.Position - head.Position).Magnitude > 2
			local want = show and cam or nil
			local color = CFG.WingColor
			for _, w in ipairs(state.wings) do
				local s = w.s
				-- mount on shoulder blades / upper back, slight pitch, flap on roll
				local base = tor.CFrame
					* CFrame.new(s * 0.55, 0.55, 0.65)
					* CFrame.Angles(math.rad(-8), -s * 0.55, 0)
					* CFrame.Angles(0, 0, s * flap)
				for _, it in ipairs(w.items) do
					local rip = (0.12 + it.k * 0.025) * (0.4 + amp * 3) * math.sin(phase - it.k * 0.5)
					pcall(function()
						it.model:PivotTo(base * CFrame.Angles(rip, 0, 0))
					end)
					for _, pt in ipairs(it.parts) do
						pt.Color = color
					end
					if it.model.Parent ~= want then it.model.Parent = want end
				end
			end
		end)
		table.insert(Connections, wingConn)
	end

function apply(char)
		clear()
		if not char then return end
		local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 3)
		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		if not head then return end
		local folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = char
		if CFG.Hat then pcall(makeHat, char, head, folder) end
		if CFG.Wings and torso then pcall(makeWings, char, torso, folder) end
	end

	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.45)
		if CFG.Hat or CFG.Wings then apply(char) end
	end)

	return {
		setHat = function(on)
			CFG.Hat = on and true or false
			ST.ChinaHatEnabled = CFG.Hat
			if LocalPlayer.Character then apply(LocalPlayer.Character) end
		end,
		setWings = function(on)
			CFG.Wings = on and true or false
			ST.WingsEnabled = CFG.Wings
			if LocalPlayer.Character then apply(LocalPlayer.Character) end
		end,
		setWingType = function(t)
			CFG.WingType = t or "Normal"
			if CFG.Wings and LocalPlayer.Character then apply(LocalPlayer.Character) end
		end,
		setHatColor = function(c)
			if typeof(c) == "Color3" then CFG.HatColor = c end
			if CFG.Hat and LocalPlayer.Character then apply(LocalPlayer.Character) end
		end,
		setWingsColor = function(c)
			if typeof(c) == "Color3" then CFG.WingColor = c end
			if CFG.Wings and LocalPlayer.Character then apply(LocalPlayer.Character) end
		end,
		getHatColor = function() return CFG.HatColor end,
		getWingsColor = function() return CFG.WingColor end,
		cfg = CFG,
		off = clear,
		on = function()
			if LocalPlayer.Character then apply(LocalPlayer.Character) end
		end,
	}
end)()


--// ==================== HELPERS ====================
function getCharacterParts()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return character, humanoid, root
end

function IsFriend(player)
	if not player then return false end
	local v = FriendsList[player.UserId]
	return v ~= nil and v ~= false
end
function IsWhitelisted(player)
	if not player then return false end
	local v = Whitelist[player.UserId]
	return v ~= nil and v ~= false
end
function IsProtected(player)
	return IsFriend(player) or IsWhitelisted(player)
end


function ReapplyMovement()
	task.wait(1)
	if ST.isUnloaded then return end
	local char, hum, root = getCharacterParts()
	if not char or not hum or not root then return end
	
	if ST.FlyEnabled then
		if flyVelocity then flyVelocity:Destroy() end
		if flyGyro then flyGyro:Destroy() end
		flyVelocity = Instance.new("BodyVelocity", root)
		flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		flyGyro = Instance.new("BodyGyro", root)
		flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		flyGyro.P = 9000
	end
	if ST.SpinEnabled then
		if spinAngular then spinAngular:Destroy() end
		spinAngular = Instance.new("BodyAngularVelocity", root)
		spinAngular.AngularVelocity = Vector3.new(0, ST.SpinSpeed, 0)
		spinAngular.MaxTorque = Vector3.new(0, math.huge, 0)
		spinAngular.P = 1000
	end
end
LocalPlayer.CharacterAdded:Connect(ReapplyMovement)

--// ==================== TRACERS ====================
local tracerFolder = Instance.new("Folder")
tracerFolder.Name = "CLL_Tracers"
tracerFolder.Parent = workspace

function CreateTracer(origin, targetPos, color)
	if not ST.TracersEnabled then return end
	local dist = (targetPos - origin).Magnitude
	if dist < 0.5 or dist > 800 then return end
	color = color or ST.ColorSelf

	local part = Instance.new("Part")
	part.Name = "CLL_Tracer"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.15
	part.Size = Vector3.new(0.04, 0.04, dist)
	part.CFrame = CFrame.lookAt(origin, targetPos) * CFrame.new(0, 0, -dist / 2)
	part.Parent = tracerFolder

	local att0 = Instance.new("Attachment", part)
	local att1 = Instance.new("Attachment", part)
	att0.Position = Vector3.new(0, 0, dist / 2)
	att1.Position = Vector3.new(0, 0, -dist / 2)
	local beam = Instance.new("Beam", part)
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Color = ColorSequence.new(color)
	beam.Width0 = 0.08
	beam.Width1 = 0.02
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.Transparency = NumberSequence.new(0.1, 0.6)

	local dur = math.clamp(ST.TracerDuration or 0.5, 0.05, 5)
	local tween = TweenService:Create(part, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
	TweenService:Create(beam, TweenInfo.new(dur), { Width0 = 0, Width1 = 0 }):Play()
	tween:Play()
	tween.Completed:Connect(function()
		if part then part:Destroy() end
	end)
	-- sparks burst at muzzle, same color as tracer (optional toggle)

end



function tracerColorForCharacter(char)
	if not char then return ST.ColorOthers, ST.TracerOthersEnabled end
	if char == LocalPlayer.Character then
		return ST.ColorSelf, ST.TracerSelfEnabled
	end
	local plr = Players:GetPlayerFromCharacter(char)
	if plr then
		local uid = plr.UserId
		if FriendsList[uid] or FriendsList[tostring(uid)] or FriendsList[tonumber(uid)] then
			return ST.ColorFriends, ST.TracerFriendsEnabled
		end
		if IsFriend and IsFriend(plr) then
			return ST.ColorFriends, ST.TracerFriendsEnabled
		end
	end
	return ST.ColorOthers, ST.TracerOthersEnabled
end

local function tracerColorFromOrigin(origin)
	if typeof(origin) ~= "Vector3" then
		return ST.ColorOthers, ST.TracerOthersEnabled
	end
	-- local muzzle
	if os.clock() - (lastLocalShotAt or 0) < 0.55 then
		if not lastLocalShotOrigin or (origin - lastLocalShotOrigin).Magnitude < 28 then
			return ST.ColorSelf, ST.TracerSelfEnabled
		end
	end
	local myChar = LocalPlayer.Character
	local myTool = myChar and myChar:FindFirstChildOfClass("Tool")
	local fp = myTool and myTool:FindFirstChild("Firepoint", true)
	if fp and (origin - fp.WorldPosition).Magnitude < 14 then
		return ST.ColorSelf, ST.TracerSelfEnabled
	end
	-- nearest living player to muzzle → friend green / else yellow
	local best, bestD = nil, 45
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
			if hrp then
				local d = (hrp.Position - origin).Magnitude
				if d < bestD then
					bestD, best = d, plr
				end
			end
		end
	end
	if best and (FriendsList[best.UserId] or FriendsList[tostring(best.UserId)] or (IsFriend and IsFriend(best))) then
		return ST.ColorFriends, ST.TracerFriendsEnabled
	end
	return ST.ColorOthers, ST.TracerOthersEnabled
end


--// ==================== WORLD TRACERS (muzzle → impact, local + others) ====================
local tracedBullets = setmetatable({}, { __mode = "k" })

function findMuzzle(toolOrModel)
	if not toolOrModel then return nil end
	local fp = toolOrModel:FindFirstChild("Firepoint", true)
	if fp then return fp.WorldPosition end
	local base = toolOrModel:FindFirstChild("Base")
	if base then
		fp = base:FindFirstChild("Firepoint")
		if fp then return fp.WorldPosition end
	end
	return nil
end

function traceFromBulletPart(part)
	if not ST.TracersEnabled or not part or tracedBullets[part] then return end
	local n = string.lower(part.Name or "")
	-- skip mags / shells / casings / debris (not real bullets)
	if n:find("mag") or n:find("shell") or n:find("casing") or n:find("clip") or n:find("ammo") or n:find("debris") or n:find("blood") then
		return
	end
	-- real cosmetic bullet usually named Default or has ORIGIN attr
	local origin = part:GetAttribute("ORIGIN")
	if typeof(origin) ~= "Vector3" and n ~= "default" and not n:find("bullet") then
		return
	end
	tracedBullets[part] = true
	if typeof(origin) ~= "Vector3" then
		origin = part.Position
	end
	local function classifyColor()
		return tracerColorFromOrigin(origin)
	end
	task.delay(0.03, function()
		local col, on = classifyColor()
		if not on then return end
		if not part.Parent then
			CreateTracer(origin, origin + Vector3.new(0, 0, -50), col)
			return
		end
		local pos = part:IsA("BasePart") and part.Position or origin
		CreateTracer(origin, pos, col)
	end)
	task.delay(0.12, function()
		local col, on = classifyColor()
		if not on then return end
		if part and part.Parent and part:IsA("BasePart") then
			CreateTracer(origin, part.Position, col)
		end
	end)
end

task.spawn(function()
	-- replicate Fire packets (some games fire this to all clients)
	local fr = FireRemote
	pcall(function()
		if not fr then fr = ReplicatedStorage:WaitForChild("Remotes", 8):WaitForChild("Fire", 8) end
	end)
	if fr then
		pcall(function()
			fr.OnClientEvent:Connect(function(tool, action, data)
				if not ST.TracersEnabled then return end
				if action ~= "Fire" then return end
				local origin, dir
				if typeof(data) == "table" then
					origin, dir = data.origin, data.direction
				end
				if typeof(origin) ~= "Vector3" then origin = findMuzzle(tool) end
				if typeof(origin) ~= "Vector3" then return end
				if typeof(dir) ~= "Vector3" then dir = Vector3.new(0, 0, -1) end
				dir = dir.Unit
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = { LocalPlayer.Character, workspace:FindFirstChild("Cache") }
				local ray = workspace:Raycast(origin, dir * 900, params)
				local col, on = ST.ColorOthers, ST.TracerOthersEnabled
				if os.clock() - lastLocalShotAt < 0.55 then
					col, on = ST.ColorSelf, ST.TracerSelfEnabled
				elseif tool then
					local ch = tool.Parent
					if ch == LocalPlayer.Character then
						col, on = ST.ColorSelf, ST.TracerSelfEnabled
					elseif ch and ch:IsA("Model") then
						col, on = tracerColorForCharacter(ch)
					end
				end
				if col == ST.ColorOthers or not col then
					-- reclassify by muzzle origin (friends → green)
					col, on = tracerColorFromOrigin(origin)
				end
				if on then
					CreateTracer(origin, ray and ray.Position or (origin + dir * 350), col)
				end
			end)
		end)
	end

	-- Helper local "Fire Bullet" path used by this game for LOCAL shots
	-- already partially hooked via namecall; also listen workspace Cache
	local function hookCache(folder)
		if not folder then return end
		folder.ChildAdded:Connect(function(child)
			if not ST.TracersEnabled then return end
			if child:IsA("BasePart") or child:IsA("Model") then
				local part = child:IsA("BasePart") and child or child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
				if part then traceFromBulletPart(part) end
			end
		end)
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("BasePart") then traceFromBulletPart(child) end
		end
	end

	local cache = workspace:FindFirstChild("Cache")
	if cache then
		hookCache(cache)
		hookCache(cache:FindFirstChild("Ignore"))
		cache.ChildAdded:Connect(function(c)
			if c.Name == "Ignore" or c:IsA("Folder") then hookCache(c) end
		end)
	else
		workspace.ChildAdded:Connect(function(c)
			if c.Name == "Cache" then
				hookCache(c)
				hookCache(c:FindFirstChild("Ignore"))
			end
		end)
	end
end)


--// ==================== INSTANT INTERACT ====================
-- Instant interact for world props only.
-- Skip downed / revive / carry / player prompts (they must keep normal hold — was auto-drop / bad carry).
-- Instant interact: HoldDuration=0 everywhere EXCEPT downed-player pickup
local function isDownedPlayerPrompt(obj)
	if not obj or not obj:IsA("ProximityPrompt") then return false end
	local n = (tostring(obj.Name) .. " " .. tostring(obj.ActionText) .. " " .. tostring(obj.ObjectText)):lower()
	-- explicit downed / revive / help-up wording
	if n:find("down") or n:find("revive") or n:find("help up") or n:find("pickup player")
		or n:find("pick up player") or n:find("carry player") then
		return true
	end
	-- prompt under a player character that is Downed/Ragdoll
	local model = obj:FindFirstAncestorOfClass("Model")
	if model then
		local plr = Players:GetPlayerFromCharacter(model)
		if plr then
			local d = model:GetAttribute("Downed")
			local r = model:GetAttribute("Ragdoll")
			if d == true or d == 1 or r == true or r == 1 then
				return true
			end
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health <= 0 then
				return true
			end
		end
	end
	return false
end

local function disableHoldDuration(obj)
	if not obj or not obj:IsA("ProximityPrompt") then return end
	if isDownedPlayerPrompt(obj) then return end
	obj.HoldDuration = 0
end
task.spawn(function()
	for _, v in pairs(workspace:GetDescendants()) do pcall(disableHoldDuration, v) end
	table.insert(Connections, workspace.DescendantAdded:Connect(disableHoldDuration))
end)

function GetTargets()
    local targets = {}
    local anySelected = false
    for target, on in pairs(SelectedTargets) do if on then anySelected = true; break end end
    local function addPlayer(target)
        if target == LocalPlayer or not target.Parent then return end
        if (ST.SUK_IgnoreFriends and IsFriend(target)) or IsWhitelisted(target) then return end
        local char = target.Character
        if not char then return end
        -- only skip fully downed/carried; alive ragdoll still takes damage
        if char:GetAttribute("Downed") or char:GetAttribute("Carried") then return end
        -- do NOT filter Ragdoll attribute / PlatformStand — still shoot
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then return end
        if hum:GetState() == Enum.HumanoidStateType.Dead then return end
        table.insert(targets, {char = char, head = head, plr = target, hum = hum})
    end
    local function addNPCs()
        if #NPC_List == 0 and ST.SUK_TargetNPCs then
            -- cheap scan: only workspace.Humans (no full GetDescendants)
            local folder = workspace:FindFirstChild("Humans")
            if folder then
                for _, inst in ipairs(folder:GetChildren()) do
                    if inst:IsA("Model") and not Players:GetPlayerFromCharacter(inst) then
                        local hum = inst:FindFirstChildOfClass("Humanoid")
                        local head = inst:FindFirstChild("Head")
                        local hrp = inst:FindFirstChild("HumanoidRootPart")
                        if hum and head and hrp and hum.Health > 0 then
                            NPC_List[#NPC_List + 1] = inst
                        end
                    end
                end
            end
        end
        for _, char in ipairs(NPC_List) do
            if char and char.Parent then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    table.insert(targets, {char = char, head = head})
                end
            end
        end
    end
    -- selected list → only those; empty selection → everyone (v10/v29 SUK)
    -- ONLY selected players (empty selection = no shots). User requirement.
    if anySelected then
        for target, on in pairs(SelectedTargets) do
            if on then addPlayer(target) end
        end
    end
    if ST.SUK_TargetNPCs then
        addNPCs()
    end
    return targets
end

function GetVRTargets()
    local targets = {}
    for target, on in pairs(VRSelectedTargets) do
        if on and target ~= LocalPlayer and target.Parent and not IsWhitelisted(target) and not (ST.SUK_IgnoreFriends and IsFriend(target)) then
            local char = target.Character
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then table.insert(targets, {char = char, head = head}) end
        end
    end
    return targets
end

--// ==================== COMBAT LOGIC ====================
function ReadAmmo(tool)
	if not tool then return 0, 8 end
	-- dump Spas gates on ClientAmmo first
	local current = tool:GetAttribute("ClientAmmo")
	if current == nil then current = tool:GetAttribute("CurrentAmmo") end
	if current == nil then
		local cv = tool:FindFirstChild("CurrentAmmo")
		if cv and (cv:IsA("NumberValue") or cv:IsA("IntValue")) then current = cv.Value end
	end
	local max = tool:GetAttribute("MaxAmmo")
	if max == nil then
		local mv = tool:FindFirstChild("MaxAmmo")
		if mv and (mv:IsA("NumberValue") or mv:IsA("IntValue")) then max = mv.Value end
	end
	return tonumber(current) or 0, tonumber(max) or 8
end

function IsReloading()
	local char = LocalPlayer.Character
	if not char then return false end
	local a = char:GetAttribute("Reloading")
	if a ~= nil then return a == true end
	local v = char:FindFirstChild("Reloading")
	if v and v:IsA("BoolValue") then return v.Value == true end
	return false
end

function GetSpas()
	local function findSpas(container)
		if not container then return nil end
		local t = container:FindFirstChild("Spas 12") or container:FindFirstChild("Spas12") or container:FindFirstChild("SPAS 12")
		if t then return t end
		for _, ch in ipairs(container:GetChildren()) do
			if ch:IsA("Tool") and string.find(string.lower(ch.Name), "spas") then 
                return ch 
            end
		end
		return nil
	end
	return findSpas(LocalPlayer.Character) or findSpas(LocalPlayer:FindFirstChildOfClass("Backpack"))
end


local lastSpasPickup = 0
function EnsureSpasEquipped()
	local tool = GetSpas()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not char or not hum or not root then return nil end
	if tool and tool.Parent == char then return tool end
	if tool and tool.Parent ~= char then
		pcall(function() hum:EquipTool(tool) end)
		return GetSpas()
	end
	if os.clock() - (lastSpasPickup or 0) < 0.2 then return nil end
	lastSpasPickup = os.clock()
	ST._spasPickupBusy = true

	local function byName(parent)
		if not parent then return nil end
		return parent:FindFirstChild("Spas 12", true)
			or parent:FindFirstChild("Spas12", true)
			or parent:FindFirstChild("SPAS 12", true)
	end

	local map = workspace:FindFirstChild("Map")
	local tables = (map and map:FindFirstChild("Weapon Tables")) or workspace:FindFirstChild("Weapon Tables")
	local spasObj = byName(tables) or byName(map) or byName(workspace:FindFirstChild("Weapons"))
	-- one recursive name search on workspace if tables path failed
	if not spasObj then
		spasObj = workspace:FindFirstChild("Spas 12", true) or workspace:FindFirstChild("Spas12", true)
	end
	if not spasObj then ST._spasPickupBusy = false; return nil end

	local pos = nil
	pcall(function()
		if spasObj:IsA("BasePart") then pos = spasObj.Position
		elseif spasObj:IsA("Tool") then
			local h = spasObj:FindFirstChild("Handle")
			pos = h and h.Position
		elseif spasObj:IsA("Model") then
			pos = spasObj:GetPivot().Position
		end
		if not pos then
			local p = spasObj:FindFirstChildWhichIsA("BasePart", true)
			pos = p and p.Position
		end
	end)
	if not pos then ST._spasPickupBusy = false; return nil end

	local saved = root.CFrame
	-- sit right on the table/handle (3 studs up was often too high for prompt)
	pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0)) end)
	task.wait(0.05)
	pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 2.2, 0)) end)
	for _ = 1, 4 do
		pcall(function()
			local prompt = spasObj:FindFirstChildWhichIsA("ProximityPrompt", true)
			if not prompt then
				local parent = spasObj.Parent
				prompt = parent and parent:FindFirstChildWhichIsA("ProximityPrompt", true)
			end
			if prompt then
				pcall(function() prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 24) end)
				pcall(function() prompt.HoldDuration = 0 end)
				if fireproximityprompt then
					pcall(fireproximityprompt, prompt)
					pcall(fireproximityprompt, prompt, 1)
				end
				pcall(function() prompt:InputHoldBegin() end)
				task.wait(0.05)
				pcall(function() prompt:InputHoldEnd() end)
			end
			-- some tables use ClickDetector / TouchInterest
			local cd = spasObj:FindFirstChildWhichIsA("ClickDetector", true)
			if cd and fireclickdetector then
				pcall(fireclickdetector, cd)
			end
		end)
		task.wait(0.06)
		tool = GetSpas()
		if tool then break end
	end
	tool = GetSpas()
	if tool then
		pcall(function() hum:EquipTool(tool) end)
		task.wait(0.05)
	end
	pcall(function()
		local live = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if live then live.CFrame = saved end
	end)
	ST._spasPickupBusy = false
	return GetSpas()
end


function StopReload(tool) 
    if ReloadRemote and tool then 
        pcall(function() ReloadRemote:InvokeServer(tool, "Stop Reload") end) 
    end 
end

function clearSukReloadState()
	ST.reloadInProgress = false
	ST._reloadRunning = false
	ST._sukChamber = nil
	pcall(function()
		local t = GetSpas()
		if t then
			StopReload(t)
			local char = LocalPlayer.Character
			if char then char:SetAttribute("Reloading", false) end
			t:SetAttribute("Reloading", false)
		end
	end)
end

function InstantReload(tool)
	if not ReloadRemote or not tool then return end
	if ST._reloadRunning then return end
	ST._reloadRunning = true
	ST.reloadInProgress = true
	ST._reloadStartedAt = os.clock()

	local function boostReloadAnims()
		pcall(function()
			local char = LocalPlayer.Character
			if not char then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum)
			if animator and animator.GetPlayingAnimationTracks then
				for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
					local n = string.lower(tostring(tr.Name or (tr.Animation and tr.Animation.Name) or ""))
					if n:find("reload") or n:find("shell") or n:find("insert") or n:find("pump") then
						tr:AdjustSpeed(3.5)
					end
				end
			end
			for _, d in ipairs(tool:GetDescendants()) do
				if d:IsA("AnimationController") or d:IsA("Animator") then
					for _, tr in ipairs(d:GetPlayingAnimationTracks()) do
						tr:AdjustSpeed(3.5)
					end
				end
			end
		end)
	end

	task.spawn(function()
		local maxA = 8
		local okReload = false
		pcall(function()
			local current, max = ReadAmmo(tool)
			current = math.max(0, tonumber(current) or 0)
			max = math.clamp(tonumber(max) or 8, 1, 12)
			maxA = max
			-- empty chamber → force real shell cycle (never pretend already full)
			local forceFullCycle = (ST._sukChamber or 0) <= 0 or current <= 0
			if forceFullCycle then
				current = 0
				pcall(function()
					tool:SetAttribute("ClientAmmo", 0)
					tool:SetAttribute("CurrentAmmo", 0)
					local cv = tool:FindFirstChild("CurrentAmmo")
					if cv and (cv:IsA("NumberValue") or cv:IsA("IntValue")) then cv.Value = 0 end
				end)
			end
			local need = max - current
			if need <= 0 and not forceFullCycle then
				okReload = true
				return
			end
			if need <= 0 then need = max end

			local nameL = string.lower(tool.Name)
			local isShotgun = tool:GetAttribute("Shotgun") or nameL:find("spas") or nameL:find("remington")
			boostReloadAnims()

			if isShotgun then
				-- always top to full tube (need shells)
				need = math.max(need, max - current)
				if need < 1 then need = max end
				ReloadRemote:InvokeServer(tool, "Start Reload")
				boostReloadAnims()
				local step = math.clamp(tonumber(ST.ReloadSpeed) or 0.08, 0.06, 0.2)
				local loaded = current
				for i = 1, need do
					if ST.isUnloaded or not tool or not tool.Parent then break end
					if not ST._reloadRunning then break end
					ReloadRemote:InvokeServer(tool, "New Shell")
					ReloadRemote:InvokeServer(tool, "Insert Shell")
					boostReloadAnims()
					task.wait(step)
					loaded = math.min(max, current + i)
					pcall(function()
						tool:SetAttribute("ClientAmmo", loaded)
						tool:SetAttribute("CurrentAmmo", loaded)
						local cv = tool:FindFirstChild("CurrentAmmo")
						if cv and (cv:IsA("NumberValue") or cv:IsA("IntValue")) then cv.Value = loaded end
					end)
				end
				-- guarantee 8/8 client chamber after cycle
				pcall(function()
					tool:SetAttribute("ClientAmmo", max)
					tool:SetAttribute("CurrentAmmo", max)
					local cv = tool:FindFirstChild("CurrentAmmo")
					if cv and (cv:IsA("NumberValue") or cv:IsA("IntValue")) then cv.Value = max end
				end)
				task.wait(0.05)
				ReloadRemote:InvokeServer(tool, "Stop Reload")
				okReload = true
			else
				ReloadRemote:InvokeServer(tool)
				task.wait(0.02)
				ReloadRemote:InvokeServer(tool, "MagOut")
				task.wait(0.02)
				ReloadRemote:InvokeServer(tool, "ThrowMag")
				task.wait(0.02)
				ReloadRemote:InvokeServer(tool, "GetNewMag")
				task.wait(0.02)
				ReloadRemote:InvokeServer(tool, "InsertNewMag")
				task.wait(0.02)
				ReloadRemote:InvokeServer(tool, "InsertNewMag2")
				task.wait(0.02)
				ReloadRemote:InvokeServer(tool, "SlideAction")
			end

			local char = LocalPlayer.Character
			if char then pcall(function() char:SetAttribute("Reloading", false) end) end
			okReload = true
		end)
		pcall(function() if tool and tool.Parent then ReloadRemote:InvokeServer(tool, "Stop Reload") end end)
		-- chamber = what client thinks after reload (prefer ReadAmmo, fallback max)
		local finalCur = nil
		pcall(function()
			local c, m = ReadAmmo(tool)
			finalCur = tonumber(c)
			maxA = tonumber(m) or maxA
		end)
		if okReload then
			-- full mag after completed reload cycle
			ST._sukChamber = maxA
			pcall(function()
				tool:SetAttribute("ClientAmmo", maxA)
				tool:SetAttribute("CurrentAmmo", maxA)
			end)
		else
			ST._sukChamber = 0
		end
		ST.reloadInProgress = false
		ST._reloadRunning = false
		ST._reloadStartedAt = nil
	end)
end

local targetIndex = 1
function MultiFireAt()
	if ST.reloadInProgress then return end
	if not FireRemote or not FireRemote.Parent then
		pcall(function()
			local r = ReplicatedStorage:FindFirstChild("Remotes")
			FireRemote = r and r:FindFirstChild("Fire")
		end)
	end
	if not FireRemote then return end

	local tool = GetSpas()
	if tool and tool.Parent ~= LocalPlayer.Character then
		pcall(function()
			local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if h then h:EquipTool(tool) end
		end)
		tool = GetSpas()
	end
	if not tool or tool.Parent ~= LocalPlayer.Character then
		if not ST._spasEquipQueued then
			ST._spasEquipQueued = true
			task.spawn(function()
				pcall(EnsureSpasEquipped)
				ST._spasEquipQueued = false
			end)
		end
		return
	end

	if ST.reloadInProgress or ST._reloadRunning then return end

	local realCur, maxA = ReadAmmo(tool)
	realCur = tonumber(realCur) or 0
	maxA = math.clamp(tonumber(maxA) or tool:GetAttribute("MaxAmmo") or 8, 1, 12)

	-- first shot: trust ClientAmmo if valid, else full mag
	if ST._sukChamber == nil then
		ST._sukChamber = (realCur > 0) and realCur or maxA
	end
	-- never shoot more than client thinks it has
	if realCur > 0 and realCur < ST._sukChamber then
		ST._sukChamber = realCur
	end
	local cur = ST._sukChamber

	if cur <= 0 then
		-- HARD stop fire; start real shell reload once
		ST._sukChamber = 0
		if not ST._reloadRunning then
			pcall(function()
				tool:SetAttribute("ClientAmmo", 0)
				tool:SetAttribute("CurrentAmmo", 0)
			end)
			pcall(InstantReload, tool)
		end
		return
	end

	local bulletModel = BulletModel
	if not bulletModel then
		pcall(function()
			bulletModel = ReplicatedStorage:WaitForChild("Models", 1):WaitForChild("Bullets", 1):WaitForChild("Default", 1)
		end)
	end
	if not bulletModel then return end

	local targets = GetTargets() or {}
	local numTargets = #targets
	if numTargets == 0 then
		return
	end

	-- clear every client lock the Spas onActivate checks (dump)
	pcall(function()
		tool:SetAttribute("Cooldown", false)
		tool:SetAttribute("ClientCooldownUntil", 0)
		tool:SetAttribute("Debounce", false)
		tool:SetAttribute("Reloading", false)
		tool:SetAttribute("CanFire", true)
		local char = LocalPlayer.Character
		if char then
			char:SetAttribute("Reloading", false)
		end
		tool:SetAttribute("ClientAmmo", cur)
		tool:SetAttribute("CurrentAmmo", cur)
		local cv = tool:FindFirstChild("CurrentAmmo")
		if cv and (cv:IsA("NumberValue") or cv:IsA("IntValue")) then
			cv.Value = cur
		end
	end)

	local head = nil
	local aimPos
	if numTargets > 0 then
		local data = targets[((targetIndex - 1) % numTargets) + 1]
		targetIndex = targetIndex + 1
		if data and data.head and data.head.Parent then
			head = data.head
			aimPos = head.Position
		end
	end
	-- invalid/missing head → skip shot (never fire into floor/self)
	if not aimPos or not head or not head.Parent then return end

	local fp = tool:FindFirstChild("Firepoint", true)
	if not fp then
		local base = tool:FindFirstChild("Base")
		fp = base and base:FindFirstChild("Firepoint")
	end
	local muzzle
	if fp then
		muzzle = fp.WorldPosition or fp.Position
	else
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hand = char and char:FindFirstChild("Right Arm")
		muzzle = (hand and hand.Position) or (hrp and (hrp.Position + hrp.CFrame.LookVector * 1.5 + Vector3.new(0, 1.2, 0)))
	end
	if typeof(muzzle) ~= "Vector3" then return end

	local hitPos = aimPos
	local dir = (hitPos - muzzle)
	if dir.Magnitude < 0.05 then dir = Vector3.new(0, 0, -1) else dir = dir.Unit end
	-- tracer starts near skull; server Fire still uses muzzle so distance checks pass
	local nearHead = hitPos - dir * 0.8

	if not FireRemote then
		pcall(function()
			FireRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Fire")
		end)
	end
	if not FireRemote then return end

	-- clear gun locks but DO NOT clear reloadInProgress (that caused phantom shells)
	pcall(function()
		tool:SetAttribute("Cooldown", false)
		tool:SetAttribute("ClientCooldownUntil", 0)
		tool:SetAttribute("Debounce", false)
		tool:SetAttribute("CanFire", true)
	end)
	if ST.reloadInProgress or ST._reloadRunning then return end
	if not tool or tool.Parent ~= LocalPlayer.Character then return end
	if not head or not head.Parent then return end
	local liveChar = head.Parent
	if liveChar:GetAttribute("Downed") then return end -- ragdoll still takes hits
	local liveHum = liveChar:FindFirstChildOfClass("Humanoid")
	if not liveHum or liveHum.Health <= 0 then return end
	-- spend shell NOW so concurrent MultiFireAt in same tick cannot reuse it
	if (ST._sukChamber or 0) <= 0 then return end
	ST._sukChamber = math.max(0, (ST._sukChamber or 1) - 1)
	cur = ST._sukChamber
	pcall(function()
		tool:SetAttribute("ClientAmmo", cur)
		tool:SetAttribute("CurrentAmmo", cur)
		local cv = tool:FindFirstChild("CurrentAmmo")
		if cv and (cv:IsA("NumberValue") or cv:IsA("IntValue")) then cv.Value = cur end
	end)

	-- AP-style (v11.70-ap): Fire muzzle + nearHead, 1× Hit at head, dir = muzzle→head
	local pred = hitPos
	pcall(function()
		if head and head.AssemblyLinearVelocity then
			local dist = (hitPos - muzzle).Magnitude
			local t = math.clamp(dist / 2000, 0, 0.12)
			pred = hitPos + head.AssemblyLinearVelocity * t
		end
	end)
	local toHead = pred - muzzle
	local tpDir = (typeof(toHead) == "Vector3" and toHead.Magnitude > 0.05) and toHead.Unit or Vector3.new(0, 0, -1)
	-- tracer / soft origin just in front of skull; server Fire also from real muzzle
	local nearHead = pred - tpDir * 0.8
	local vel = tpDir * 2000
	local bcf = CFrame.lookAt(pred - tpDir * 0.4, pred)

	local function firePayload(org)
		local payload = {
			velocity = 2000,
			bullet = bulletModel,
			origin = org,
			direction = tpDir,
		}
		if CLL_FireServer then
			pcall(CLL_FireServer, FireRemote, tool, "Fire", payload)
		else
			pcall(function() FireRemote:FireServer(tool, "Fire", payload) end)
		end
	end

	firePayload(muzzle)
	firePayload(nearHead)
	markLocalShot(nearHead)

	if head and head.Parent then
		-- one Hit per shell (ap) — position on the head
		local hitTbl = {
			hit = head,
			normal = -tpDir,
			position = pred,
			velocity = vel,
			bullet_cframe = bcf,
		}
		if CLL_FireServer then
			pcall(CLL_FireServer, FireRemote, tool, "Hit", hitTbl)
		else
			pcall(function() FireRemote:FireServer(tool, "Hit", hitTbl) end)
		end
		HelperFire("Gun Base", "Hit", head, pred, -tpDir, vel, bulletModel)
		HelperFire("Fx", "Hitmarker", head)
		markKillCandidate(head.Parent)
		task.defer(function()
			local m2 = head.Parent
			local h2 = m2 and m2:FindFirstChildOfClass("Humanoid")
			if h2 and h2.Health <= 0 then
				onVictimDied(m2)
				end
		end)
	end

	for i = 0, 7 do
		HelperFire("Fx", "Fire Bullet", tool, {
			velocity = 2000,
			bullet = bulletModel,
			origin = nearHead,
			direction = tpDir,
		})
	end
	if ST.TracersEnabled and ST.TracerSelfEnabled then
		CreateTracer(nearHead, pred, ST.ColorSelf)
	end

	local ca = ST._sukChamber or 0
	pcall(function()
		HelperFire("Fx", "Ammo", ca, maxA, false)
	end)
	HelperFire("Gun Base", "Shot", tool)
	if head then HelperFire("Fx", "Hitmarker", head) end
end


-- SUK tick: exactly ONE shell per cycle, then wait (no burst dump into few targets)
task.spawn(function()
	while not ST.isUnloaded do
		if not ST.isMultiSuk then
			task.wait(0.15)
		elseif ST.reloadInProgress or ST._reloadRunning then
			task.wait(0.05)
		else
			local rps = tonumber(ST.SUK_FIRERATE_RPS) or 8
			local delay = tonumber(ST.SUK_FireDelay) or 0.1
			-- cadence between single shots
			local waitT = math.max(0.06, math.max(1 / math.max(1, rps), delay))
			pcall(MultiFireAt)
			task.wait(waitT)
		end
	end
end)


-- SUK reload watchdog: unstick _reloadRunning after 3s so damage never dies forever
task.spawn(function()
	while not ST.isUnloaded do
		task.wait(0.5)
		if ST._reloadRunning or ST.reloadInProgress then
			local t0 = ST._reloadStartedAt
			if typeof(t0) ~= "number" then
				ST._reloadStartedAt = os.clock()
			elseif (os.clock() - t0) > 3.5 then
				ST.reloadInProgress = false
				ST._reloadRunning = false
				ST._reloadStartedAt = nil
				-- allow next empty cycle to retry InstantReload
			end
		else
			ST._reloadStartedAt = nil
		end
	end
end)
function FireNormalGun(tool)
    if not FireRemote or not tool then return end
    if tool.Parent ~= LocalPlayer.Character then return end
    local fp = tool:FindFirstChild("Firepoint", true)
    if not fp then
        local base = tool:FindFirstChild("Base")
        fp = base and base:FindFirstChild("Firepoint")
    end
    if not fp then return end

    pcall(function()
        tool:SetAttribute("Cooldown", false)
        tool:SetAttribute("ClientCooldownUntil", 0)
        tool:SetAttribute("Debounce", false)
        if tool:GetAttribute("Reloading") then tool:SetAttribute("Reloading", false) end
    end)

    local cur = select(1, ReadAmmo(tool))
    if cur <= 0 then return end

    local origin = fp.WorldPosition
    local mouse = LocalPlayer:GetMouse()
    local dir
    -- silent aim overrides mouse if on
    if ST.SilentAimEnabled then
        local part = GetClosestAimPartInFOV and GetClosestAimPartInFOV()
        if part then
            dir = (part.Position - origin)
        end
    end
    if typeof(dir) ~= "Vector3" or dir.Magnitude < 0.05 then
        dir = (mouse.Hit.Position - origin)
    end
    if dir.Magnitude < 0.05 then dir = workspace.CurrentCamera.CFrame.LookVector else dir = dir.Unit end

    local bullet = BulletModel
    if not bullet then
        pcall(function()
            bullet = ReplicatedStorage:FindFirstChild("Models")
                and ReplicatedStorage.Models:FindFirstChild("Bullets")
                and ReplicatedStorage.Models.Bullets:FindFirstChild("Default")
        end)
    end

    local payload = {
        velocity = 2000,
        bullet = bullet,
        origin = origin,
        direction = dir,
    }
    pcall(function()
        CLL_FireServer(FireRemote, tool, "Fire", payload)
    end)
    markLocalShot(origin)

    -- Hit is required for damage on this game
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, workspace.CurrentCamera }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray = workspace:Raycast(origin, dir * 1000, params)
    local hitInst, hitPos, hitN
    if ray then
        hitInst, hitPos, hitN = ray.Instance, ray.Position, ray.Normal
    elseif ST.SilentAimEnabled then
        local part = GetClosestAimPartInFOV and GetClosestAimPartInFOV()
        if part then
            hitInst, hitPos, hitN = part, part.Position, -dir
        end
    end
    if hitInst and hitPos then
        local vel = dir * 2000
        local bcf = CFrame.lookAt(hitPos - dir * 0.5, hitPos)
        pcall(function()
            CLL_FireServer(FireRemote, tool, "Hit", {
                hit = hitInst,
                normal = hitN or -dir,
                position = hitPos,
                velocity = vel,
                bullet_cframe = bcf,
            })
        end)
        HelperFire("Gun Base", "Hit", hitInst, hitPos, hitN or -dir, vel, bullet)
        HelperFire("Fx", "Hitmarker", hitInst)
        local model = hitInst:FindFirstAncestorOfClass("Model") or hitInst.Parent
        if model then markKillCandidate(model) end
        if ST.TracersEnabled and ST.TracerSelfEnabled then
            CreateTracer(origin, hitPos, ST.ColorSelf)
        end
    elseif ST.TracersEnabled and ST.TracerSelfEnabled then
        CreateTracer(origin, origin + dir * 400, ST.ColorSelf)
    end

    pcall(function()
        local ca = tool:GetAttribute("ClientAmmo")
        if typeof(ca) == "number" then tool:SetAttribute("ClientAmmo", math.max(0, ca - 1)) end
        tool:SetAttribute("Cooldown", false)
        tool:SetAttribute("ClientCooldownUntil", 0)
    end)
    HelperFire("Gun Base", "Shot", tool)
end


--// ==================== LOCAL INVIS (clone + far real body, walk control) ====================
local InvisClone = nil
local InvisSavedCF = nil
local InvisConn = nil
local InvisFarPos = nil
local InvisGrounded = true

function destroyInvisClone()
	if InvisConn then InvisConn:Disconnect(); InvisConn = nil end
	if InvisClone then pcall(function() InvisClone:Destroy() end); InvisClone = nil end
end

function stopLocalInvis()
	ST.LocalInvisEnabled = false
	if InvisConn then
		pcall(function() InvisConn:Disconnect() end)
		InvisConn = nil
	end
	destroyInvisClone()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if char and root then
		root.Anchored = false
		if InvisSavedCF then
			pcall(function() root.CFrame = InvisSavedCF end)
		end
		root.AssemblyLinearVelocity = Vector3.zero
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.LocalTransparencyModifier = 0
			elseif p:IsA("Decal") then
				p.Transparency = 0
			end
		end
		local cam = workspace.CurrentCamera
		if cam and hum then
			cam.CameraSubject = hum
			cam.CameraType = Enum.CameraType.Custom
		end
	end
	InvisSavedCF = nil
	InvisFarPos = nil
end

LocalPlayer.CharacterAdded:Connect(function()
	destroyInvisClone()
	InvisSavedCF = nil
	InvisFarPos = nil
	if ST.LocalInvisEnabled then
		task.delay(0.5, function()
			if ST.LocalInvisEnabled then startLocalInvis() end
		end)
	end
end)

-- Local invis: NO clone. Teleport real character far away every 0.1s (Y always positive).
-- Local invis: NO clone. Full-body PivotTo far away (Y always high).
function startLocalInvis()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then return end

	destroyInvisClone()
	if InvisConn then pcall(function() InvisConn:Disconnect() end); InvisConn = nil end

	if not InvisSavedCF then
		InvisSavedCF = root.CFrame
	end

	pcall(function()
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Anchored = false
				p.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end)

	local function pickFar()
		local x = (math.random() * 2 - 1) * (30000 + math.random(0, 40000))
		local z = (math.random() * 2 - 1) * (30000 + math.random(0, 40000))
		local y = 600 + math.random(0, 1400)
		return Vector3.new(x, y, z)
	end
	InvisFarPos = pickFar()

	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			p.LocalTransparencyModifier = 1
		elseif p:IsA("Decal") then
			p.Transparency = 1
		end
	end

	local acc = 0
	InvisConn = RunService.Heartbeat:Connect(function(dt)
		if not ST.LocalInvisEnabled or ST.isUnloaded then return end
		local c = LocalPlayer.Character
		if not c then return end
		local r = c:FindFirstChild("HumanoidRootPart")
		local h = c:FindFirstChildOfClass("Humanoid")
		if not r or not h or h.Health <= 0 then return end

		acc += dt
		if acc < 0.05 then return end -- 20 Hz server-visible TP
		acc = 0
		InvisFarPos = pickFar()
		local pos = InvisFarPos
		if pos.Y < 200 then pos = Vector3.new(pos.X, 600 + math.random(0, 400), pos.Z) end

		-- UNANCHORED CFrame + PivotTo so physics ownership replicates to server
		pcall(function()
			for _, part in ipairs(c:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = false
					part.AssemblyLinearVelocity = Vector3.zero
					part.AssemblyAngularVelocity = Vector3.zero
				end
			end
			local cf = CFrame.new(pos)
			r.CFrame = cf
			c:PivotTo(cf)
		end)
	end)
	table.insert(Connections, InvisConn)
end

--// ==================== HEAL LOGIC ====================
function StartHealLoop()
	if healConnection then healConnection:Disconnect(); healConnection = nil end
	if antiVelocityConnection then antiVelocityConnection:Disconnect(); antiVelocityConnection = nil end
	if not ST.HealEnabled then return end
	local _, _, root = getCharacterParts(); if root then savedHealPosition = root.CFrame end
	if SwingRemote and not ST.isBlockActive then SwingRemote:FireServer('Block'); ST.isBlockActive = true end
	
	healConnection = RunService.Heartbeat:Connect(function()
		if not ST.HealEnabled or ST.isUnloaded then return end
		-- let EnsureSpasEquipped TP to the table first
		if ST._spasPickupBusy then return end
		local char, hum, root = getCharacterParts()
		if not char or not hum or not root or hum.Health <= 0 then return end
		local healBrick = workspace:FindFirstChild("Heal100Brick", true)
		if not healBrick then return end
		-- only port when actually hurt (not on toggle alone)
		local maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
		if hum.Health >= maxH - 0.5 then
			-- full HP: release platform stand if we held it only for heal
			return
		end
		if not hum.PlatformStand then hum.PlatformStand = true end
		local basePos = healBrick.Position + Vector3.new(0, ST.HealFlyHeight or 3.5, 0)
		root.CFrame = ST.isMultiSuk and CFrame.new(basePos) or CFrame.new(basePos + Vector3.new(0, math.sin(os.clock() * 2) * 0.5, 0))
		root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
		for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then if not savedCollision[p] then savedCollision[p] = p.CanCollide end; p.CanCollide = false end end
	end)
	table.insert(Connections, healConnection)
	antiVelocityConnection = RunService.Stepped:Connect(function()
		if not ST.HealEnabled or ST.isUnloaded then return end
		local _, _, root = getCharacterParts(); if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
	end)
	table.insert(Connections, antiVelocityConnection)
end
function StopHealLoop()
	if healConnection then healConnection:Disconnect(); healConnection = nil end
	if antiVelocityConnection then antiVelocityConnection:Disconnect(); antiVelocityConnection = nil end
	if SwingRemote and ST.isBlockActive then SwingRemote:FireServer('UnBlock'); ST.isBlockActive = false end
	if savedHealPosition then local _, _, root = getCharacterParts(); if root then root.CFrame = savedHealPosition end; savedHealPosition = nil end
	local _, humanoid = getCharacterParts(); if humanoid and not (isCharRagdoll and isCharRagdoll(LocalPlayer.Character, humanoid)) then humanoid.PlatformStand = false end
	for p, original in pairs(savedCollision) do if p and p.Parent then p.CanCollide = original end end
	table.clear(savedCollision)
end

--// ==================== MOVEMENT & EFFECTS ====================
RunService.Heartbeat:Connect(function()
	if ST.isUnloaded then return end
	-- skip almost all work when no movement/combat helpers are on
	if not ST.VREnabled and not ST.FlyEnabled and not ST.LocalInvisEnabled
		and not ST.AntiSlowEnabled and not ST.AntiCCEnabled and not ST.NoClipEnabled
		and not ST.WalkSpeedEnabled and not ST.InfiniteJumpEnabled then
		return
	end
	local char, humanoid, root = getCharacterParts()
	if not char or not humanoid or not root then return end
	-- ragdoll FIRST (even without VR): never fight game physics/animators
	local isRag = isCharRagdoll and isCharRagdoll(char, humanoid)
	if isRag then
		if vrReleaseForRagdoll then pcall(vrReleaseForRagdoll, char) end
		-- critical: do NOT clear Stunned/Hurt/Endlag while ragdolled — that restarts idle anims on torso/arms/head
		-- do NOT force WalkSpeed / Jump / NoClip / Fly while ragdolled
		return
	end
	if ST.AntiSlowEnabled or ST.AntiCCEnabled then
		-- if physics-ish, never touch stun/hurt (keeps ragdoll, stops idle anim takeover)
		local phys = false
		pcall(function()
			local st = humanoid:GetState()
			phys = st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
				or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Dead
		end)
		for a, on in pairs(AntiCC_Flags) do
			if on then
				if phys and (a == "Stunned" or a == "Hurt" or a == "Endlag" or a == "Kicking") then
					-- skip
				else
					pcall(function() if char:GetAttribute(a) then char:SetAttribute(a, nil) end end)
				end
			end
		end
		if AntiCC_Flags.Stunned and not phys then
			pcall(function() if humanoid:GetAttribute("Stunned") then humanoid:SetAttribute("Stunned", nil) end end)
		end
	end
	if not ST.VREnabled and not ST.FlyEnabled and not ST.LocalInvisEnabled then
		-- ONLY unanchor our VR-marked parts — NEVER m.Enabled = true here (breaks ragdoll)
		pcall(function()
			if root:GetAttribute("CLL_VR_Anchored") then
				root.Anchored = false
				root:SetAttribute("CLL_VR_Anchored", nil)
			end
			for _, n in ipairs({"Right Arm", "Left Arm", "Head"}) do
				local part = char:FindFirstChild(n)
				if part and part:IsA("BasePart") and part:GetAttribute("CLL_VR_Anchored") then
					part.Anchored = false
					part.Massless = false
					part:SetAttribute("CLL_VR_Anchored", nil)
				end
			end
			for _, inst in ipairs(root:GetChildren()) do
				local isMover = inst:IsA("BodyVelocity") or inst:IsA("BodyGyro") or inst:IsA("BodyPosition")
					or inst:IsA("LinearVelocity") or inst:IsA("AngularVelocity") or inst:IsA("AlignOrientation")
				if isMover then
					local named = (inst.Name or ""):find("CLL")
					if named or inst == flyVelocity or inst == flyGyro then
						inst:Destroy()
					end
				end
			end
			-- if fly leftovers still referenced
			if flyVelocity and not ST.FlyEnabled then pcall(function() flyVelocity:Destroy() end); flyVelocity = nil end
			if flyGyro and not ST.FlyEnabled then pcall(function() flyGyro:Destroy() end); flyGyro = nil end
		end)
	end
	if ST.NoRecoilEnabled then
		pcall(function()
			for _, tr in ipairs(humanoid:GetPlayingAnimationTracks()) do
				local n = tr.Name or ""
				if n:find("Fire") and not n:find("Reload") then tr:AdjustSpeed(0) end
			end
		end)
	end
	if ST.WalkSpeedEnabled and humanoid.WalkSpeed ~= ST.WalkSpeedValue then humanoid.WalkSpeed = ST.WalkSpeedValue end
	if ST.JumpPowerEnabled then humanoid.UseJumpPower = true; humanoid.JumpPower = ST.JumpPowerValue end
	if ST.NoClipEnabled then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then savedCollision[part] = savedCollision[part] or part.CanCollide; part.CanCollide = false end end end
	if ST.FlyEnabled and flyVelocity and flyGyro and root then
		local move = Vector3.zero; local cam = workspace.CurrentCamera
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
		flyVelocity.Velocity = move.Magnitude > 0 and move.Unit * ST.FlySpeed or Vector3.zero
		flyGyro.CFrame = cam.CFrame
	end
	if ST.MaxZoomEnabled then LocalPlayer.CameraMaxZoomDistance = ST.MaxZoomValue end
	if ST.RemoveFogEnabled then game:GetService("Lighting").FogEnd = 100000; game:GetService("Lighting").FogStart = 0 end
	
	if ST.FullbrightEnabled then
		local l = game:GetService("Lighting")
		l.Ambient = Color3.fromRGB(255, 255, 255); l.OutdoorAmbient = Color3.fromRGB(255, 255, 255); l.Brightness = 2; l.FogEnd = 100000
		for _, v in pairs(l:GetChildren()) do if v:IsA("Atmosphere") then v.Density = 0 end end
	elseif not ST.FullbrightEnabled and not ST.SkyColorEnabled then
		local l = game:GetService("Lighting")
		l.Ambient = Color3.fromRGB(70, 70, 70); l.OutdoorAmbient = Color3.fromRGB(128, 128, 128); l.Brightness = 1
	end
	
	if ST.SkyColorEnabled then
		local l = game:GetService("Lighting")
		l.Ambient = SkyColor:Lerp(Color3.new(0,0,0), 0.5)
		l.OutdoorAmbient = SkyColor
		local sky = l:FindFirstChild("CLL_Sky")
		if not sky then
			sky = Instance.new("Sky", l)
			sky.Name = "CLL_Sky"
			sky.SkyboxBk = "rbxassetid://0"
			sky.SkyboxDn = "rbxassetid://0"
			sky.SkyboxFt = "rbxassetid://0"
			sky.SkyboxLf = "rbxassetid://0"
			sky.SkyboxRt = "rbxassetid://0"
			sky.SkyboxUp = "rbxassetid://0"
		end
	end
	
	-- time override moved to dedicated loop (ragdoll early-return was killing it)
end)

-- Time Override: continuous, only write when value drifts (no flicker)
do
	local Lighting = game:GetService("Lighting")
	RunService.RenderStepped:Connect(function()
		if ST.isUnloaded or not ST.TimeOverrideEnabled then return end
		local want = ST.TimeOverrideValue or 12
		local cur = Lighting.ClockTime
		-- only set if game/server moved time away (avoids visual strobe)
		if math.abs(cur - want) > 0.02 then
			Lighting.ClockTime = want
		end
	end)
end

-- FOV Lock Logic (Aggressive)
workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
	if ST.CameraFOVLocked then workspace.CurrentCamera.FieldOfView = ST.CameraFOVValue end
end)
RunService.RenderStepped:Connect(function()
	if ST.CameraFOVLocked and workspace.CurrentCamera.FieldOfView ~= ST.CameraFOVValue then
		workspace.CurrentCamera.FieldOfView = ST.CameraFOVValue
	end
end)


--// ==================== WEATHER (dump: Modules.Fx.Systems.Weather Rain onStart/onStop) ====================
local WeatherActive = false
local WeatherConn = nil
local WeatherModels = {}

function stopWeather()
	WeatherActive = false
	if WeatherConn then WeatherConn:Disconnect(); WeatherConn = nil end
	-- only destroy what WE created
	pcall(function()
		for _, v in ipairs(WeatherModels) do
			if v and v.Parent then
				if v:IsA("Sound") then v:Stop() end
				v:Destroy()
			end
		end
	end)
	table.clear(WeatherModels)
	pcall(function()
		for _, n in ipairs({"Rain", "Rain Wind", "indoor Rain", "CLL_RainWind", "CLL_Rain"}) do
			local s = game:GetService("SoundService"):FindFirstChild(n)
			if s and (s.Name:find("CLL") or WeatherActive == false) then
				-- only stop rain sounds we likely own
				if s.Name:find("Rain") or s.Name:find("Wind") then
					s:Stop()
					-- don't Destroy game's originals if they pre-existed; only CLL-prefixed
					if s.Name:find("CLL") then s:Destroy() end
				end
			end
		end
	end)
	-- soft restore clouds/fog — do NOT destroy Terrain.Clouds or Lighting effects
	pcall(function()
		local clouds = workspace.Terrain:FindFirstChild("Clouds")
		if clouds then
			TweenService:Create(clouds, TweenInfo.new(5), { Cover = 0.2, Density = 0.3 }):Play()
		end
		-- only raise fog if we lowered it for rain
		local L = game:GetService("Lighting")
		if L.FogEnd < 2000 then
			TweenService:Create(L, TweenInfo.new(5), { FogEnd = 10000 }):Play()
		end
	end)
	pcall(function()
		local folder = workspace:FindFirstChild("Weather")
		if folder then
			for _, v in ipairs(folder:GetChildren()) do
				if v.Name:find("CLL") then v:Destroy() end
			end
		end
	end)
end

function startWeatherRain()
	stopWeather()
	WeatherActive = true
	pcall(function()
		local sys = ReplicatedStorage:FindFirstChild("Modules")
			and ReplicatedStorage.Modules:FindFirstChild("Fx")
			and ReplicatedStorage.Modules.Fx:FindFirstChild("Systems")
			and ReplicatedStorage.Modules.Fx.Systems:FindFirstChild("Weather Rain")
		if not sys then return end
		-- try require module API
		local mod
		pcall(function() mod = require(sys) end)
		if type(mod) == "table" and type(mod.onStart) == "function" then
			mod.onStart()
			return
		end
		-- manual: clone Rain Effect + lighting + sounds
		local particles = sys:FindFirstChild("Particles")
		local rainFx = particles and particles:FindFirstChild("Rain Effect")
		local folder = workspace:FindFirstChild("Weather") or Instance.new("Folder", workspace)
		folder.Name = "Weather"
		if rainFx then
			local clone = rainFx:Clone()
			clone.Name = "CLL_Rain"
			clone.Parent = folder
			table.insert(WeatherModels, clone)
		end
		local sounds = sys:FindFirstChild("Sounds")
		if sounds then
			for _, sn in ipairs({"Wind", "Rain", "indoor Rain"}) do
				local src = sounds:FindFirstChild(sn) or sounds:FindFirstChild(sn:gsub("Wind", "Rain Wind"))
				if src and src:IsA("Sound") then
					local s = src:Clone()
					s.Name = sn == "Wind" and "Rain Wind" or sn
					s.Parent = game:GetService("SoundService")
					s.Volume = 0.6
					s:Play()
					table.insert(WeatherModels, s)
				end
			end
		end
		local clouds = workspace.Terrain:FindFirstChild("Clouds")
		if clouds then
			TweenService:Create(clouds, TweenInfo.new(4), {
				Cover = 0.85, Density = 1, Color = Color3.fromRGB(103, 103, 103)
			}):Play()
		end
		TweenService:Create(game:GetService("Lighting"), TweenInfo.new(4), { FogEnd = 555 }):Play()
		-- follow player with rain parts
		WeatherConn = RunService.Heartbeat:Connect(function()
			if not WeatherActive then return end
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not root then return end
			for _, m in ipairs(WeatherModels) do
				if m:IsA("Model") then
					for _, part in ipairs(m:GetChildren()) do
						if part:IsA("BasePart") then
							part.CFrame = CFrame.new(root.Position + Vector3.new(0, 40, 0))
						end
					end
				end
			end
		end)
		table.insert(Connections, WeatherConn)
	end)
end

--// ==================== TRUE AIM CROSSHAIR ====================

local trueAimGui = Instance.new("ScreenGui")
trueAimGui.Name = "CLL_TrueAim"
trueAimGui.ResetOnSpawn = false
trueAimGui.IgnoreGuiInset = true
trueAimGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local aimDot = Instance.new("Frame")
aimDot.Name = "Dot"
aimDot.Size = UDim2.fromOffset(6, 6)
aimDot.AnchorPoint = Vector2.new(0.5, 0.5)
aimDot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
aimDot.BorderSizePixel = 0
aimDot.Visible = ST.TrueCrosshairEnabled
aimDot.Parent = trueAimGui
Instance.new("UICorner", aimDot).CornerRadius = UDim.new(1, 0)
local aimRing = Instance.new("Frame")
aimRing.Size = UDim2.fromOffset(14, 14)
aimRing.AnchorPoint = Vector2.new(0.5, 0.5)
aimRing.BackgroundTransparency = 1
aimRing.Parent = trueAimGui
local ringStroke = Instance.new("UIStroke", aimRing)
ringStroke.Color = Color3.fromRGB(0, 255, 120)
ringStroke.Thickness = 1.2
ringStroke.Transparency = 0.25
Instance.new("UICorner", aimRing).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
	if ST.isUnloaded or not ST.TrueCrosshairEnabled then
		aimDot.Visible = false
		aimRing.Visible = false
		return
	end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local char = LocalPlayer.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	local fp = tool and (tool:FindFirstChild("Firepoint", true) or (tool:FindFirstChild("Base") and tool.Base:FindFirstChild("Firepoint")))
	local origin = (fp and fp.WorldPosition) or cam.CFrame.Position
	local mouse = LocalPlayer:GetMouse()
	local dir = (mouse.Hit.Position - origin)
	if dir.Magnitude < 0.01 then
		aimDot.Visible = false
		aimRing.Visible = false
		return
	end
	dir = dir.Unit
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char, cam, tool }
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, dir * 2000, params)
	local worldPos = result and result.Position or (origin + dir * 350)
	local sp, onScreen = cam:WorldToViewportPoint(worldPos)
	if onScreen and sp.Z > 0 then
		aimDot.Visible = true
		aimRing.Visible = true
		local pos = UDim2.fromOffset(sp.X, sp.Y)
		aimDot.Position = pos
		aimRing.Position = pos
		if result and result.Instance and result.Instance:FindFirstAncestorOfClass("Model") then
			local m = result.Instance:FindFirstAncestorOfClass("Model")
			local hum = m and m:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				aimDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
				ringStroke.Color = Color3.fromRGB(255, 60, 60)
			else
				aimDot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
				ringStroke.Color = Color3.fromRGB(0, 255, 120)
			end
		else
			aimDot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
			ringStroke.Color = Color3.fromRGB(0, 255, 120)
		end
	else
		aimDot.Visible = false
		aimRing.Visible = false
	end
end)

--// ==================== ESP & HITBOX ====================
function removeESP(player)
	local data = ESP_Cache[player]
	if data then for _, obj in pairs(data) do if typeof(obj) == "Instance" and obj.Destroy then obj:Destroy() end end; ESP_Cache[player] = nil end
end
Players.PlayerRemoving:Connect(removeESP); Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function() removeESP(p) end) end)

function createESP(player)
	if ESP_Cache[player] or not ESPGui then return ESP_Cache[player] end
	local data = {}
	data.Box = Instance.new("Frame", ESPGui); data.Box.BackgroundTransparency = 1; data.Box.Visible = false; Instance.new("UIStroke", data.Box).Thickness = 1.5
	data.Name = Instance.new("TextLabel", ESPGui); data.Name.BackgroundTransparency = 1; data.Name.Font = Enum.Font.GothamBold; data.Name.TextSize = 14; data.Name.TextColor3 = Color3.new(1,1,1); data.Name.TextStrokeTransparency = 0; data.Name.TextStrokeColor3 = Color3.new(0,0,0); data.Name.Visible = false
	local nameStroke = Instance.new("UIStroke", data.Name); nameStroke.Color = Color3.new(0,0,0); nameStroke.Thickness = 1.6; nameStroke.Transparency = 0
	data.HealthBg = Instance.new("Frame", ESPGui); data.HealthBg.BackgroundColor3 = Color3.new(0, 0, 0); data.HealthBg.Visible = false
	data.HealthFill = Instance.new("Frame", ESPGui); data.HealthFill.Visible = false
	data.HealthText = Instance.new("TextLabel", ESPGui); data.HealthText.BackgroundTransparency = 1; data.HealthText.Font = Enum.Font.GothamBold; data.HealthText.TextSize = 11; data.HealthText.TextColor3 = Color3.new(1,1,1); data.HealthText.TextStrokeTransparency = 0; data.HealthText.TextStrokeColor3 = Color3.new(0,0,0); data.HealthText.Visible = false
	data.Distance = Instance.new("TextLabel", ESPGui); data.Distance.BackgroundTransparency = 1; data.Distance.Font = Enum.Font.GothamBold; data.Distance.TextSize = 12; data.Distance.TextColor3 = Color3.new(1, 1, 1); data.Distance.Visible = false
	data.Status = Instance.new("TextLabel", ESPGui)
	data.Status.BackgroundTransparency = 1
	data.Status.Font = Enum.Font.GothamMedium
	data.Status.TextSize = 11
	data.Status.TextColor3 = Color3.fromRGB(255, 220, 120)
	data.Status.TextStrokeTransparency = 0.4
	data.Status.TextStrokeColor3 = Color3.new(0,0,0)
	data.Status.Visible = false
	data.RagdollSince = nil
	ESP_Cache[player] = data
	return data
end

RunService.RenderStepped:Connect(function()
	if ST.isUnloaded or (not ESP_Config.Enabled and not ST.HighlightChamsEnabled) then return end
	if not ESPGui then ESPGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui")); ESPGui.Name = "CLL_ESP"; ESPGui.ResetOnSpawn = false; ESPGui.IgnoreGuiInset = true end
	local cam = workspace.CurrentCamera
	if not cam then return end
	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= LocalPlayer then
			local data = ESP_Cache[v]
			local char, hum, hrp, head = v.Character, v.Character and v.Character:FindFirstChildOfClass("Humanoid"), v.Character and v.Character:FindFirstChild("HumanoidRootPart"), v.Character and v.Character:FindFirstChild("Head")
			local visible = false
			if char and hum and hum.Health > 0 and hrp and head then
				local dist = (cam.CFrame.Position - hrp.Position).Magnitude
				if dist <= ESP_Config.MaxDist then
					local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
					if onScreen and sp.Z > 0 then
						local ts, tos = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
						local bs, bos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
						if tos and bos and ts.Z > 0 and bs.Z > 0 then
							visible = true; if not data then data = createESP(v) end
							local color = IsFriend(v) and ESP_Config.FriendColor or ESP_Config.ChamsColor
							local h = math.abs(ts.Y - bs.Y); local w = h * 0.55; local x, y = sp.X - (w / 2), ts.Y
							data.Box.Visible = ESP_Config.Enabled and ESP_Config.Box
							if data.Box.Visible then data.Box.Size = UDim2.fromOffset(math.max(2, w), math.max(2, h)); data.Box.Position = UDim2.fromOffset(x, y); data.Box:FindFirstChildOfClass("UIStroke").Color = color end
							data.Name.Visible = ESP_Config.Enabled and ESP_Config.Name
							if data.Name.Visible then data.Name.Text = (IsFriend(v) and "[F] " or "") .. v.DisplayName; data.Name.TextColor3 = Color3.new(1,1,1); data.Name.Position = UDim2.new(0, sp.X, 0, y - 16); data.Name.Size = UDim2.new(0, 200, 0, 16); data.Name.TextColor3 = color; data.Name.AnchorPoint = Vector2.new(0.5, 0) end
							data.HealthBg.Visible = ESP_Config.Enabled and ESP_Config.Health; data.HealthFill.Visible = data.HealthBg.Visible
							if data.HealthText then data.HealthText.Visible = data.HealthBg.Visible end
							if data.HealthBg.Visible then
								local hp = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
								data.HealthBg.Size = UDim2.new(0, 3, 0, h); data.HealthBg.Position = UDim2.new(0, x - 6, 0, y)
								data.HealthFill.Size = UDim2.new(0, 3, 0, h * hp); data.HealthFill.Position = UDim2.new(0, x - 6, 0, y + (h - h * hp))
								data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hp)
								if data.HealthText then
									data.HealthText.Text = tostring(math.floor(hum.Health + 0.5))
									-- beside HP bar (left of bar), not above
									data.HealthText.AnchorPoint = Vector2.new(1, 0.5)
									data.HealthText.Position = UDim2.new(0, x - 10, 0, y + h * 0.5)
									data.HealthText.Size = UDim2.new(0, 36, 0, 14)
									data.HealthText.TextXAlignment = Enum.TextXAlignment.Right
								end
							end
							data.Distance.Visible = ESP_Config.Enabled and ESP_Config.Distance
							if data.Distance.Visible then data.Distance.Text = string.format("[%d m]", math.floor(dist * 0.28)); data.Distance.Position = UDim2.new(0, sp.X, 0, y + h + 2); data.Distance.Size = UDim2.new(0, 100, 0, 14); data.Distance.AnchorPoint = Vector2.new(0.5, 0) end
							-- tool / reload / ragdoll timer
							if data.Status then
								local bits = {}
								local tool = char:FindFirstChildOfClass("Tool")
								if ESP_Config.ShowTool and tool then
									bits[#bits+1] = tool.Name
								end
								if ESP_Config.ShowReload then
									local reloading = false
									pcall(function()
										reloading = char:GetAttribute("Reloading") == true
											or (tool and (tool:GetAttribute("Reloading") == true or tool:GetAttribute("IsReloading") == true))
										if tool and not reloading then
											local ammo = tool:GetAttribute("Ammo") or tool:GetAttribute("CurrentAmmo")
											local mag = tool:GetAttribute("Mag") or tool:GetAttribute("MaxAmmo")
											if ammo == 0 then reloading = true end
										end
									end)
									if reloading then bits[#bits+1] = "RELOAD" end
								end
								if ESP_Config.Enabled and #bits > 0 then
									data.Status.Visible = true
									data.Status.Text = table.concat(bits, " · ")
									data.Status.AnchorPoint = Vector2.new(0.5, 0)
									local sy = y + h + (data.Distance.Visible and 16 or 2)
									data.Status.Position = UDim2.new(0, sp.X, 0, sy)
									data.Status.Size = UDim2.new(0, 220, 0, 14)
									data.Status.TextColor3 = Color3.fromRGB(255, 220, 120)
								else
									data.Status.Visible = false
								end
							end
							if ST.HighlightChamsEnabled then
								if not data.Highlight or data.Highlight.Parent ~= char then if data.Highlight then data.Highlight:Destroy() end; data.Highlight = Instance.new("Highlight", char); data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end
								data.Highlight.Adornee = char; data.Highlight.Enabled = true; data.Highlight.FillColor = color; data.Highlight.OutlineColor = color; data.Highlight.FillTransparency = ESP_Config.ChamsFillTrans; data.Highlight.OutlineTransparency = ESP_Config.ChamsOutlineTrans
							elseif data.Highlight then data.Highlight.Enabled = false end
						end
					end
				end
			end
			if not visible and data then
				for _, obj in pairs(data) do
					if typeof(obj) == "Instance" then
						if obj:IsA("GuiObject") then obj.Visible = false
						elseif obj:IsA("Highlight") then obj.Enabled = false; pcall(function() obj:Destroy() end) end
					end
				end
				data.Highlight = nil
			end
		end
	end
end)

function restoreHitbox(char, head, hrp)
	local data = Hitbox_Cache[char]
	if not data then return end
	pcall(function()
		if head and head.Parent then
			head.Size = data.HeadSize
			head.Transparency = data.HeadTrans
			head.Material = data.HeadMat
			head.CanCollide = data.HeadCollide
		end
		if hrp and hrp.Parent then
			hrp.Size = data.HRPSize
			hrp.Transparency = data.HRPTrans
			hrp.CanCollide = data.HRPCollide
		end
	end)
	Hitbox_Cache[char] = nil
end

function isHitboxTargetChar(char)
	if not char then return false end
	local plr = Players:GetPlayerFromCharacter(char)
	if plr then
		-- filter OFF → everyone; filter ON → only checked players
		if not ST.HitboxFilterEnabled then return true end
		return HitboxSelectedTargets[plr] == true
	end
	return Hitbox_Config.IncludeNPCs == true
end

function applyHitboxTo(char)
	if not char then return end
	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not head or not hrp then return end
	-- dead / disabled / not in target list → restore
	if not hum or hum.Health <= 0 or not Hitbox_Config.Enabled or not isHitboxTargetChar(char) then
		restoreHitbox(char, head, hrp)
		return
	end
	-- cache ORIGINAL sizes only once (never re-read after expand)
	if not Hitbox_Cache[char] then
		Hitbox_Cache[char] = {
			HeadSize = head.Size,
			HeadTrans = head.Transparency,
			HeadMat = head.Material,
			HeadCollide = head.CanCollide,
			HRPSize = hrp.Size,
			HRPTrans = hrp.Transparency,
			HRPCollide = hrp.CanCollide,
		}
	end
	local sz = math.clamp(Hitbox_Config.Size or 5, 1, 30)
	-- uniform cube, NOT multiplicative grow
	pcall(function()
		head.Size = Vector3.new(sz, sz, sz)
		hrp.Size = Vector3.new(sz, sz, sz)
		head.Transparency = Hitbox_Config.Transparency or 0.5
		local matName = Hitbox_Config.Material or "ForceField"
		local mat = Enum.Material[matName] or Enum.Material.ForceField
		head.Material = mat
		hrp.Transparency = 1
		head.CanCollide = false
		hrp.CanCollide = false
	end)
end

function refreshNPCList()
	table.clear(NPC_List)
	-- NPCs can sit in folders (workspace.NPCs / Mobs / etc.) — scan descendants, throttle cost
	local seen = {}
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Model") and not seen[inst] then
			seen[inst] = true
			if not Players:GetPlayerFromCharacter(inst) then
				local hum = inst:FindFirstChildOfClass("Humanoid")
				local head = inst:FindFirstChild("Head")
				local hrp = inst:FindFirstChild("HumanoidRootPart")
				if hum and head and hrp and hum.Health > 0 then
					NPC_List[#NPC_List + 1] = inst
				end
			end
		end
	end
	last_npc_scan = os.clock()
end

task.spawn(function()
	while not ST.isUnloaded do
		task.wait(0.15)
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= LocalPlayer and pl.Character then
				applyHitboxTo(pl.Character)
			end
		end
		for char, _ in pairs(Hitbox_Cache) do
			if not char or not char.Parent then
				Hitbox_Cache[char] = nil
			end
		end
		-- NPCs: rescan every ~1s, apply every tick when IncludeNPCs
		if Hitbox_Config.IncludeNPCs or ST.SUK_TargetNPCs then
			if (os.clock() - (last_npc_scan or 0)) > 1.0 then
				pcall(refreshNPCList)
			end
			for _, char in ipairs(NPC_List) do
				if char and char.Parent then
					applyHitboxTo(char)
				end
			end
		end
	end
end)

-- restore on death / leave
Players.PlayerRemoving:Connect(function(p)
	if p.Character then
		restoreHitbox(p.Character, p.Character:FindFirstChild("Head"), p.Character:FindFirstChild("HumanoidRootPart"))
	end
end)
function hookCharHitbox(p)
	p.CharacterAdded:Connect(function(char)
		-- previous body is gone; clear any stale cache keys
		task.defer(function()
			for c, _ in pairs(Hitbox_Cache) do
				if not c.Parent then Hitbox_Cache[c] = nil end
			end
		end)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.Died:Connect(function()
				restoreHitbox(char, char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart"))
			end)
		end
	end)
	if p.Character then
		local hum = p.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Died:Connect(function()
				restoreHitbox(p.Character, p.Character:FindFirstChild("Head"), p.Character:FindFirstChild("HumanoidRootPart"))
			end)
		end
	end
end
for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then hookCharHitbox(p) end
end
Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then hookCharHitbox(p) end
end)

function CleanDebris()
	if not ST.AntiLagEnabled or ST.isUnloaded then return end
	pcall(function()
		local killName = function(n)
			n = string.lower(tostring(n or ""))
			return n:find("debris") or n:find("shard") or n:find("chunk") or n:find("rubble")
				or n:find("explosion") or n:find("fx") or n:find("vfx") or n:find("impact")
				or n:find("blood") or n:find("scorch") or n:find("smoke") or n:find("spark")
				or n:find("particle") or n:find("effect")
		end
		local function scrubInst(d)
			if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
				pcall(function() d.Enabled = false; d:Destroy() end)
			elseif d:IsA("Decal") or d:IsA("Texture") then
				if killName(d.Name) or killName(d.Parent and d.Parent.Name) then
					pcall(function() d:Destroy() end)
				end
			elseif d:IsA("Explosion") then
				pcall(function() d:Destroy() end)
			elseif d:IsA("BasePart") then
				local n = string.lower(d.Name)
				if killName(n) or (d.Parent == workspace and d.Anchored == false and d.Size.Magnitude < 10 and not d:FindFirstChildOfClass("Motor6D")) then
					-- free debris cubes
					local joint = d:FindFirstChildWhichIsA("JointInstance") or d:FindFirstChildOfClass("WeldConstraint")
					if not joint and d.Parent == workspace then
						pcall(function() d:Destroy() end)
					elseif killName(n) then
						pcall(function() d:Destroy() end)
					end
				end
			end
		end
		for _, folderName in ipairs({"Cache", "Debris", "debris", "Effects", "FX", "VFX", "Ignore", "Ignore_Debris", "ClientDebris", "Explosions", "Rubble", "IgnoreDebris"}) do
			local f = workspace:FindFirstChild(folderName)
			if f then
				if folderName == "Cache" then
					local id = f:FindFirstChild("Ignore_Debris")
					if id then
						for _, c in ipairs(id:GetChildren()) do pcall(function() c:Destroy() end) end
					end
				else
					for _, d in ipairs(f:GetDescendants()) do scrubInst(d) end
					for _, c in ipairs(f:GetChildren()) do pcall(function() c:Destroy() end) end
				end
			end
		end
		-- workspace loose debris
		for _, v in ipairs(workspace:GetChildren()) do
			scrubInst(v)
			if v:IsA("Model") and killName(v.Name) then
				pcall(function() v:Destroy() end)
			end
		end
	end)
end


local _CLL_MatBackup = {}
local function applyAntiLagMaterials(on)
	-- disabled: plastic materials hurt visuals more than FPS helps
end


function releaseVRCamera()
	-- restore stock camera after PC-VR (no VRService spoof — still clear our state)
	pcall(function()
		UIS.MouseIconEnabled = true
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end)
	pcall(function()
		LocalPlayer.CameraMode = Enum.CameraMode.Classic
	end)
	local cam = workspace.CurrentCamera
	if not cam then return end
	pcall(function()
		cam.CameraType = Enum.CameraType.Custom
	end)
	local live = LocalPlayer.Character
	local liveHum = live and live:FindFirstChildOfClass("Humanoid")
	if liveHum and liveHum.Health > 0 then
		pcall(function()
			cam.CameraSubject = liveHum
			liveHum.CameraOffset = Vector3.zero
		end)
	end
	pcall(function()
		if not ST.CameraFOVLocked then
			cam.FieldOfView = 70
		end
	end)
	pcall(function() VR_Cam_Rotation = CFrame.new() end)
	-- force camera module to leave any VR controller path
	task.defer(function()
		pcall(function()
			local cam2 = workspace.CurrentCamera
			if cam2 then
				cam2.CameraType = Enum.CameraType.Custom
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then cam2.CameraSubject = h end
			end
		end)
	end)
end


function vrDisableShoulders(char)
	vrShoulders = {}
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if not torso then return end
	-- Neck stays Enabled so head does not detach/fall
	for _, name in ipairs({"Right Shoulder", "Left Shoulder", "RightShoulder", "LeftShoulder"}) do
		local m = torso:FindFirstChild(name)
		if m and m:IsA("Motor6D") then
			vrShoulders[#vrShoulders + 1] = m
			m.Enabled = false
		end
	end
end

isCharRagdoll = function(char, hum)
	if not char then return true end
	hum = hum or char:FindFirstChildOfClass("Humanoid")
	if not hum then return true end
	if hum.Health <= 0 then return true end
	if hum.PlatformStand then return true end
	local function truthy(v)
		return v == true or v == 1 or v == "true" or v == "1"
	end
	-- attributes used by this game + common forks
	for _, key in ipairs({
		"Ragdoll", "Ragdolled", "IsRagdoll", "Downed", "Knocked", "KnockedOut",
		"Fallen", "IsDowned", "IsKnocked", "Ragdolling", "InRagdoll", "Down",
	}) do
		if truthy(char:GetAttribute(key)) then return true end
		if truthy(hum:GetAttribute(key)) then return true end
	end
	-- BoolValues some games use
	for _, key in ipairs({"Ragdoll", "Downed", "Knocked"}) do
		local v = char:FindFirstChild(key) or hum:FindFirstChild(key)
		if v and v:IsA("BoolValue") and v.Value then return true end
	end
	local ok, st = pcall(function() return hum:GetState() end)
	if ok and (st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.Physics
		or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll) then
		return true
	end
	return false
end

vrReleaseForRagdoll = function(char)
	if not char then return end
	pcall(function()
		char:SetAttribute("DID_VR", false)
		char:SetAttribute("VR", false)
		char:SetAttribute("VR_RIGHT_ARM_CFRAME", nil)
		char:SetAttribute("VR_LEFT_ARM_CFRAME", nil)
		char:SetAttribute("VR_HEAD_CFRAME", nil)
		char:SetAttribute("VR_ROOTPART_CFRAME", nil)
		char:SetAttribute("VR_CAMERA_RECOIL", Vector3.zero)
		for _, n in ipairs({
			"Right Arm", "Left Arm", "Head", "Torso", "UpperTorso", "LowerTorso",
			"RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
			"RightHand", "LeftHand",
		}) do
			local part = char:FindFirstChild(n)
			if part and part:IsA("BasePart") then
				if part:GetAttribute("CLL_VR_Anchored") or part.Anchored then
					part.Anchored = false
					part.Massless = false
					part:SetAttribute("CLL_VR_Anchored", nil)
				end
			end
		end
	end)
end

function vrRestoreShoulders()
	local char0 = LocalPlayer.Character
	local rag = isCharRagdoll(char0)
	if not rag then
		for _, m in ipairs(vrShoulders) do
			pcall(function() if m and m.Parent then m.Enabled = true end end)
		end
	end
	vrShoulders = {}
	local char = LocalPlayer.Character
	if not char then return end
	for _, n in ipairs({"Right Arm", "Left Arm", "Head", "RightLowerArm", "LeftLowerArm", "RightUpperArm", "LeftUpperArm"}) do
		local p = char:FindFirstChild(n)
		if p and p:IsA("BasePart") then
			p.Anchored = false
			p.Massless = false
			p:SetAttribute("CLL_VR_Anchored", nil)
		end
	end
end

function vrInitCharacter(char, force)
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	if char:GetAttribute("Ragdoll") or char:GetAttribute("Downed") then return end
	-- spawn grace only for auto paths (manual VR toggle passes force=true)
	if not force then
		local spawnT = char:GetAttribute("CLL_SpawnT")
		if typeof(spawnT) == "number" and (tick() - spawnT) < 1.0 then
			return
		end
	end
	pcall(function()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local base = (hrp and hrp.CFrame) or CFrame.new()
		-- NEVER write CFrame.new() (0,0,0) — server teleports you to origin
		char:SetAttribute("DID_VR", true)
		char:SetAttribute("VR", true)
		char:SetAttribute("VR_HEAD_CFRAME", base * CFrame.new(0, 1.5, 0))
		char:SetAttribute("VR_RIGHT_ARM_CFRAME", base * CFrame.new(1.05, 0.4, -1.0))
		char:SetAttribute("VR_LEFT_ARM_CFRAME", base * CFrame.new(-1.05, 0.4, -1.0))
		-- do not set VR_ROOTPART_CFRAME on init (causes pull)
		char:SetAttribute("VR_RIGHT_ARM_RECOIL", CFrame.new(0, 0, 0)) -- relative identity ok
		char:SetAttribute("VR_LEFT_ARM_RECOIL", CFrame.new(0, 0, 0))
		char:SetAttribute("VR_RIGHT_ARM_OFFSET", CFrame.new(0, 0, 0))
		char:SetAttribute("VR_CAMERA_RECOIL", Vector3.zero)
	end)
	vrDisableShoulders(char)
	-- NEVER set Head CollisionGroup Default (caused resets/deaths)
	-- VR_INIT can yank character on some builds right after spawn — delay it
	task.defer(function()
		if not ST.VREnabled or ST.isUnloaded then return end
		local live = LocalPlayer.Character
		if live ~= char then return end
		local r = live:FindFirstChild("HumanoidRootPart")
		local stay = r and r.CFrame
		if FxRemote then
			pcall(function() FxRemote:FireServer("VR_INIT") end)
		end
		if r and stay then
			for _ = 1, 10 do
				pcall(function()
					r.CFrame = CFrame.new(stay.Position.X, stay.Position.Y, stay.Position.Z) * (r.CFrame - r.CFrame.Position)
					r.AssemblyLinearVelocity = Vector3.zero
					r.AssemblyAngularVelocity = Vector3.zero
				end)
				task.wait(0.03)
			end
		end
	end)
	vrDidInit = true
end

function vrForceUnanchor(char)
	if not char then return end
	pcall(function()
		-- arms/head only — never touch HRP/Torso velocity (stop + left-fling)
		for _, n in ipairs({
			"Right Arm", "Left Arm", "Head",
			"RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
		}) do
			local part = char:FindFirstChild(n)
			if part and part:IsA("BasePart") then
				part.Anchored = false
			end
		end
	end)
end

function vrShutdown()
	local char = LocalPlayer.Character
	releaseVRCamera()
	vrRestoreShoulders()
	vrForceUnanchor(char)
	if char then
		pcall(function()
			char:SetAttribute("VR", false)
			char:SetAttribute("DID_VR", false)
			char:SetAttribute("VR_RIGHT_ARM_CFRAME", nil)
			char:SetAttribute("VR_LEFT_ARM_CFRAME", nil)
			char:SetAttribute("VR_HEAD_CFRAME", nil)
			char:SetAttribute("VR_ROOTPART_CFRAME", nil)
			local head = char:FindFirstChild("Head")
			if head then
				pcall(function() head.CollisionGroup = "Default" end)
				head.Anchored = false
			end
			-- force ALL arm/shoulder motors back (list may be empty after respawn)
			local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
			if torso then
				for _, m in ipairs(torso:GetChildren()) do
					if m:IsA("Motor6D") then
						local n = m.Name
						if n:find("Shoulder") or n:find("shoulder") or n == "Neck" then
							m.Enabled = true
						end
					end
				end
			end
			for _, n in ipairs({"Right Arm", "Left Arm", "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm"}) do
				local part = char:FindFirstChild(n)
				if part and part:IsA("BasePart") then
					part.Anchored = false
					part.CanCollide = false
				end
			end
		end)
	end
	vrDidInit = false
	vrShoulders = {}
end

-- VR look delta is read in CLL_VR via GetMouseDelta while RMB locks the cursor in place.
-- LockCenter is NOT used (that snaps the cursor to the screen center).
local vrRmbWas = false




-- Center toast: VR disabled on death
local function showVRDeathNotice()
	pcall(function()
		local parent = (gethui and gethui()) or game:GetService("CoreGui")
		local gui = Instance.new("ScreenGui")
		gui.Name = "CLL_VRDeathNotice"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 200
		gui.Parent = parent
		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromScale(0.5, 0.38)
		label.Size = UDim2.fromOffset(420, 44)
		label.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
		label.BackgroundTransparency = 0.25
		label.BorderSizePixel = 0
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 16
		label.TextColor3 = Color3.fromRGB(235, 240, 255)
		label.Text = "VR disabled — you died. Toggle VR again when ready."
		label.TextTransparency = 1
		label.Parent = gui
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = label
		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(90, 140, 255)
		s.Thickness = 1.2
		s.Transparency = 1
		s.Parent = label
		-- fade in
		local tiIn = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tiOut = TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		TweenService:Create(label, tiIn, { TextTransparency = 0, BackgroundTransparency = 0.2 }):Play()
		TweenService:Create(s, tiIn, { Transparency = 0.35 }):Play()
		task.delay(2.2, function()
			local a = TweenService:Create(label, tiOut, { TextTransparency = 1, BackgroundTransparency = 1 })
			local b = TweenService:Create(s, tiOut, { Transparency = 1 })
			a:Play(); b:Play()
			pcall(function()
				a.Completed:Wait()
			end)
			pcall(function() gui:Destroy() end)
		end)
	end)
end


local function vrHideHeadAccessories(char, hide)
	if not char then return end
	pcall(function()
		if hide then
			for _, a in ipairs(char:GetChildren()) do
				if a:IsA("Accessory") or a:IsA("Hat") then
					local handle = a:FindFirstChild("Handle")
					-- only head-related
					local at = a.AccessoryType
					local isHead = true
					pcall(function()
						isHead = (at == Enum.AccessoryType.Hat or at == Enum.AccessoryType.Hair or at == Enum.AccessoryType.Face
							or at == Enum.AccessoryType.Eyebrow or at == Enum.AccessoryType.Eyelash or at == Enum.AccessoryType.Unknown)
					end)
					local n = string.lower(a.Name)
					if isHead or n:find("hair") or n:find("hat") or n:find("head") or n:find("face") or n:find("glass") or n:find("mask") then
						a:SetAttribute("CLL_HiddenAcc", true)
						for _, d in ipairs(a:GetDescendants()) do
							if d:IsA("BasePart") then
								d:SetAttribute("CLL_AccTrans", d.Transparency)
								d.Transparency = 1
								d.LocalTransparencyModifier = 1
							elseif d:IsA("Decal") or d:IsA("Texture") then
								d:SetAttribute("CLL_AccTrans", d.Transparency)
								d.Transparency = 1
							end
						end
					end
				end
			end
		else
			for _, a in ipairs(char:GetChildren()) do
				if a:GetAttribute("CLL_HiddenAcc") then
					a:SetAttribute("CLL_HiddenAcc", nil)
					for _, d in ipairs(a:GetDescendants()) do
						if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
							local t = d:GetAttribute("CLL_AccTrans")
							if typeof(t) == "number" then d.Transparency = t end
							if d:IsA("BasePart") then d.LocalTransparencyModifier = 0 end
							d:SetAttribute("CLL_AccTrans", nil)
						end
					end
				end
			end
		end
	end)
end


--// ==================== VR ENABLED FORCE (53-style: ONLY VREnabled) ====================
-- GetVRFocus / UserCFrameChanged fakes made CameraModule enter real-VR path and fight Scriptable cam.
do
	local VRS = game:GetService("VRService")
	pcall(function()
		local oldIdx
		oldIdx = hookmetamethod(game, "__index", function(self, key)
			if key == "VREnabled" and ST.VREnabled and self == VRS then
				return true
			end
			return oldIdx(self, key)
		end)
	end)
	task.spawn(function()
		while not ST.isUnloaded do
			task.wait(0.5)
			if ST.VREnabled then
				pcall(function()
					local char = LocalPlayer.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					if not char or not hum or hum.Health <= 0 then return end
					if char:GetAttribute("Ragdoll") or char:GetAttribute("Downed") then return end
					char:SetAttribute("DID_VR", true)
					char:SetAttribute("VR", true)
				end)
			end
		end
	end)
end


function setVREnabled(on, fromUser)
	on = on and true or false
	if fromUser then
		VRWantEnabled = on
	end
	if ST.VREnabled == on then
		-- still refresh UI
		if VRToggleSetUI then pcall(VRToggleSetUI, on) end
		if on and LocalPlayer.Character and not vrDidInit then
			pcall(vrInitCharacter, LocalPlayer.Character, true)
		end
		return
	end
	ST.VREnabled = on
	
	if VRToggleSetUI then pcall(VRToggleSetUI, on) end
	if on then
		_G.CLL_VR_SPAWN_GRACE = os.clock() + 2.0
		local char = LocalPlayer.Character
		if char then
			local r = char:FindFirstChild("HumanoidRootPart")
			local stay = r and r.CFrame
			task.defer(function()
				if not ST.VREnabled then return end
				local live = LocalPlayer.Character
				local rr = live and live:FindFirstChild("HumanoidRootPart")
				if rr and stay then
					pcall(function()
						rr.CFrame = stay
						rr.AssemblyLinearVelocity = Vector3.zero
						rr.AssemblyAngularVelocity = Vector3.zero
					end)
				end
				if live then pcall(vrInitCharacter, live, true); pcall(vrHideHeadAccessories, live, true) end
			end)
		end
	else
		-- no auto RMB/LMB (was freezing UI thread). User: hold RMB while toggling off to restore cam.
		pcall(vrHideHeadAccessories, LocalPlayer.Character, false)
		pcall(vrShutdown)
		vrDidInit = false
		pcall(releaseVRCamera)
		-- server must see non-VR character for normal Grabmove(nil)
		pcall(function()
			local char = LocalPlayer.Character
			if not char then return end
			char:SetAttribute("DID_VR", false)
			char:SetAttribute("VR", false)
			char:SetAttribute("VR_RIGHT_ARM_CFRAME", nil)
			char:SetAttribute("VR_LEFT_ARM_CFRAME", nil)
			char:SetAttribute("VR_HEAD_CFRAME", nil)
			char:SetAttribute("VR_ROOTPART_CFRAME", nil)
			for _, n in ipairs({"Right Arm", "Left Arm", "Head"}) do
				local part = char:FindFirstChild(n)
				if part and part:IsA("BasePart") then
					part.Anchored = false
					pcall(function() part:SetAttribute("CLL_VR_Anchored", nil) end)
				end
			end
		end)
		
	end
end


-- Dump Keybinds mirror — ONLY when a living player is nearby (never item pickup → no instant drop)
UIS.InputBegan:Connect(function(input, _)
	if ST.isUnloaded or ST.isBinding then return end
	if UIS:GetFocusedTextBox() then return end
	local code = input.KeyCode
	local isQ = (code == Enum.KeyCode.Q or code == Enum.KeyCode.ButtonB)
	local isG = (code == Enum.KeyCode.G or code == Enum.KeyCode.ButtonY)
	if not isQ and not isG then return end
	if os.clock() - (_G.CLL_GrabMirrorAt or 0) < 0.12 then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root or hum.Health <= 0 then return end
	if char:GetAttribute("Downed") or char:GetAttribute("Ragdoll") then return end
	-- Tool in hand → never Grabmove (item would be thrown)
	if char:FindFirstChildOfClass("Tool") then return end
	-- need a nearby player (carry target); otherwise leave G to game for items
	local nearPlr = false
	local origin = root.Position
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
			local oh = plr.Character:FindFirstChildOfClass("Humanoid")
			if hrp and oh and oh.Health > 0 and (hrp.Position - origin).Magnitude <= 22 then
				nearPlr = true
				break
			end
		end
	end
	if not nearPlr then return end
	_G.CLL_GrabMirrorAt = os.clock()
	pcall(function()
		char:SetAttribute("GloryKillCooldown", nil)
		char:SetAttribute("Stunned", nil)
		char:SetAttribute("Dropkick", nil)
		hum:SetAttribute("Stunned", nil)
	end)
	if not SwingRemote or not SwingRemote.Parent then
		pcall(function()
			local r = ReplicatedStorage:FindFirstChild("Remotes")
			SwingRemote = r and (r:FindFirstChild("Swing") or r:FindFirstChild("swing"))
		end)
	end
	if not SwingRemote then return end
	if ST.VREnabled then
		if isQ then
			pcall(function() SwingRemote:FireServer("Grabmove", "RIGHT_ARM") end)
		elseif isG then
			pcall(function() SwingRemote:FireServer("Grabmove", "LEFT_ARM") end)
		end
	elseif isG then
		pcall(function() SwingRemote:FireServer("Grabmove", nil) end)
	end
end)

-- VR swing input: start fist animation (no Grabmove)
local VRSwingSide = 1
local VRSwingActive = false
local VRSwingPhase = 0
local VRSwingHitSent = false
UIS.InputBegan:Connect(function(input, gp)
	if ST.isUnloaded or not ST.VREnabled then return end
	-- punches ONLY on the bound control — never on RMB unless user bound RMB
	local bind = Keys.VRSwing or Enum.UserInputType.MouseButton1
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if bind ~= Enum.UserInputType.MouseButton2 then
			return
		end
	end
	local hit = false
	if typeof(bind) == "EnumItem" then
		if bind.EnumType == Enum.UserInputType and input.UserInputType == bind then
			hit = true
		elseif bind.EnumType == Enum.KeyCode and input.KeyCode == bind then
			hit = true
		end
	end
	if not hit then return end
	if VRSwingActive then return end
	VRSwingSide = (VRSwingSide or 1) * -1
	VRSwingActive = true
	VRSwingPhase = 0
end)

RunService:BindToRenderStep("CLL_VR", Enum.RenderPriority.Last.Value, function(dt)
	if ST.isUnloaded then return end

	-- Old behavior: VR off → do nothing. Forcing Motor6D.Enabled every frame
	-- stopped torso/arms/head from ragdolling after inject.
	if not ST.VREnabled then
		if vrDidInit then
			vrDidInit = false
			pcall(vrShutdown)
			pcall(releaseVRCamera)
		end
		return
	end

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera

	local dead = (not char) or (not hum) or (not hrp) or isCharRagdoll(char, hum)
	if dead then
		vrDidInit = false
		vrShoulders = {}
		pcall(vrReleaseForRagdoll, char)
		pcall(releaseVRCamera)
		if hum and hum.Health <= 0 then
			-- death: force VR off; user must re-enable manually (no auto-on)
			local wasOn = ST.VREnabled or VRWantEnabled
			VRWantEnabled = false
			ST.VREnabled = false
			if VRToggleSetUI then pcall(VRToggleSetUI, false) end
			pcall(function()
				game:GetService("ContextActionService"):UnbindAction("CLL_VRCarry")
			end)
			if wasOn then
				pcall(showVRDeathNotice)
			end
		end
		return
	end

	local spawnT = char:GetAttribute("CLL_SpawnT")
	if typeof(spawnT) == "number" and (tick() - spawnT) < 2.0 then
		return
	end

	if not vrDidInit or not char:GetAttribute("DID_VR") then
		vrInitCharacter(char)
	end

	local looking = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	-- LockCurrentPosition keeps the cursor where it is and makes GetMouseDelta non-zero.
	-- LockCenter is what yanked the cursor to the middle — do not use it.
	pcall(function()
		UIS.MouseIconEnabled = not looking
		UIS.MouseBehavior = looking and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
	end)
	if looking and not vrRmbWas and cam then
		local cf = cam.CFrame
		VR_Cam_Rotation = cf - cf.Position
	end
	vrRmbWas = looking
	if looking then
		local d = UIS:GetMouseDelta()
		if typeof(d) == "Vector2" and (d.X ~= 0 or d.Y ~= 0) then
			VR_Cam_Rotation = CFrame.Angles(0, math.rad(-d.X * 0.35), 0)
				* VR_Cam_Rotation
				* CFrame.Angles(math.rad(-d.Y * 0.35), 0, 0)
		end
	end
	pcall(function()
		hum.CameraOffset = Vector3.zero
		char:SetAttribute("VR_CAMERA_RECOIL", Vector3.zero)
	end)

	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or hrp
	local torsoCF = torso.CFrame
	local headPart = char:FindFirstChild("Head")
	local headPos = (headPart and headPart.Position) or (hrp.Position + Vector3.new(0, 1.5, 0))

	-- AIM POINT = center of screen (all axes), same for head + both hands
	local aimPos
	if cam then
		local vp = cam.ViewportSize
		local ray = cam:ViewportPointToRay(vp.X * 0.5, vp.Y * 0.5)
		aimPos = ray.Origin + ray.Direction * 120
		-- short raycast for depth when possible
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Exclude
		rp.FilterDescendantsInstances = { char }
		local hit = workspace:Raycast(ray.Origin, ray.Direction * 200, rp)
		if hit then aimPos = hit.Position end
	else
		aimPos = headPos + torsoCF.LookVector * 50
	end

	-- free-look exactly like v11.10: Scriptable only while RMB, rotation from InputChanged
	local headCF
	if looking and headPos and typeof(headPos) == "Vector3" then
		local rot = VR_Cam_Rotation
		if typeof(rot) ~= "CFrame" then rot = CFrame.new() end
		headCF = CFrame.new(headPos) * rot
		if cam then
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = headCF
			aimPos = headCF.Position + headCF.LookVector * 120
		end
	else
		if cam and cam.CameraType == Enum.CameraType.Scriptable then
			cam.CameraType = Enum.CameraType.Custom
			if hum then cam.CameraSubject = hum end
		end
		if cam then
			headCF = cam.CFrame
		elseif headPos then
			headCF = CFrame.new(headPos)
		else
			headCF = torsoCF
		end
	end
	-- do NOT anchor/teleport the head (Neck stays on; that drag made walk tiny)
	if headPart and headPart:IsA("BasePart") then
		if headPart.Anchored then headPart.Anchored = false end
	end

	local reach = math.clamp(ST.VRHandExtend or 0, 0, 10)
	local handH = ST.VRHandHeight or 0.2
	local handW = math.clamp(ST.VRHandWidth or 1.05, 0.3, 2.5)

	-- BOTH arms always track screen-center aim (with or without tool)
	-- R6: long axis Y → -90 X so fist faces aim
	local function fistFrom(shoulderPos, target, extra)
		if typeof(shoulderPos) ~= "Vector3" then return CFrame.new() end
		if typeof(target) ~= "Vector3" then target = shoulderPos + (torsoCF.LookVector * 3) end
		local dir = target - shoulderPos
		if dir.Magnitude < 0.05 then
			if typeof(aimPos) == "Vector3" then dir = aimPos - shoulderPos else dir = torsoCF.LookVector end
		end
		if dir.Magnitude < 0.05 then dir = torsoCF.LookVector else dir = dir.Unit end
		-- R6 arm primary axis +Y: -90 X aims fist along look, no wrist-flip
		local cf = CFrame.lookAt(shoulderPos, shoulderPos + dir)
			* CFrame.Angles(math.rad(-90), 0, 0)
		if extra then cf = cf * extra end
		return cf
	end
	local shoulderR = (torsoCF * CFrame.new(handW, 0.5 + handH, -0.15 - reach * 0.15)).Position
	local shoulderL = (torsoCF * CFrame.new(-handW, 0.5 + handH, -0.15 - reach * 0.15)).Position
	local rightHand = fistFrom(shoulderR, aimPos, nil)
	local leftHand = fistFrom(shoulderL, aimPos, nil)

	-- weapon: only extra roll on RIGHT arm (still aims center)
	if char:FindFirstChildOfClass("Tool") then
		rightHand = fistFrom(shoulderR, aimPos, CFrame.Angles(0, 0, math.rad(90)))
	end

	-- alias for punch anim
	local hitPos = aimPos

	-- VR target: hands on head + keep body near (teleport only if far so you can still move)
	local vrTargets = (ST.VRTargetEnabled and GetVRTargets and GetVRTargets()) or {}
	local spawnGrace = (type(_G.CLL_VR_SPAWN_GRACE) == "number" and os.clock() < _G.CLL_VR_SPAWN_GRACE)
	if ST.VRTargetEnabled and not spawnGrace and #vrTargets > 0 and vrTargets[1].head then
		local th = vrTargets[1].head
		local above = th.Position + Vector3.new(0, 2.6, 0)
		local dist = (hrp.Position - above).Magnitude
		if dist > 6 then
			pcall(function()
				hrp.CFrame = CFrame.new(above, th.Position)
			end)
		elseif dist > 2.5 then
			pcall(function()
				hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(above, th.Position), 0.35)
			end)
		end
		-- do NOT zero velocity every frame → was turtle walk
		rightHand = fistFrom(th.Position + Vector3.new(0.35, 0.05, 0), th.Position, nil)
		leftHand = fistFrom(th.Position + Vector3.new(-0.35, 0.05, 0), th.Position, nil)
		headCF = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0), th.Position)
	end

	if ST.VRShakeEnabled then
		vrHandShakeSeed = (vrHandShakeSeed or 0) + dt * 40
		local s = (ST.VRShakeIntensity or 0.5) * 0.5
		rightHand = rightHand * CFrame.new(math.sin(vrHandShakeSeed) * s, math.cos(vrHandShakeSeed * 1.3) * s, 0)
		leftHand = leftHand * CFrame.new(math.sin(vrHandShakeSeed + 2) * s, math.cos(vrHandShakeSeed + 2) * s, 0)
	end

	-- fist punch animation toward cursor
	if VRSwingActive then
		local spd = ST.VRSwingSpeed or 14
		local amp = ST.VRSwingAmp or 1.8
		VRSwingPhase = VRSwingPhase + dt * spd
		local swing = math.sin(math.clamp(VRSwingPhase / math.pi, 0, 1) * math.pi)
		local sideSign = VRSwingSide > 0 and 1 or -1
		local sh = sideSign > 0 and shoulderR or shoulderL
		local toHit = hitPos - sh
		if toHit.Magnitude < 0.05 then toHit = headCF.LookVector else toHit = toHit.Unit end
		local mid = sh - toHit * (0.55 * (1 - swing)) + toHit * ((0.9 + reach * 0.35 + amp) * swing)
		local fist = CFrame.lookAt(mid, mid + toHit) * CFrame.Angles(math.rad(-90), 0, 0)
		if sideSign > 0 then rightHand = fist else leftHand = fist end
		if VRSwingPhase >= math.pi * 0.42 and VRSwingPhase < math.pi * 0.55 and not VRSwingHitSent then
			VRSwingHitSent = true
			pcall(function()
				if not SwingRemote then return end
				local victim, hitPart
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = { LocalPlayer.Character }
				local res = workspace:Raycast(mid, toHit * 8, params)
				if res and res.Instance then
					local m = res.Instance:FindFirstAncestorOfClass("Model")
					if m and m:FindFirstChildOfClass("Humanoid") and m ~= LocalPlayer.Character then
						victim = m
						hitPart = res.Instance
					end
				end
				if victim then
					local part = hitPart or victim:FindFirstChild("Head") or victim:FindFirstChild("Torso") or victim:FindFirstChild("HumanoidRootPart")
					local fistTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
					pcall(function()
						if SwingRemote then
							CLL_FireServer(SwingRemote, fistTool, "Hit", part, 1)
							CLL_FireServer(SwingRemote, "Hit", part, 1)
						end
					end)
					if part then HelperFire("Fx", "Hitmarker", part) end
					markKillCandidate(victim)
					lastMeleeAt = os.clock()
				end
			end)
		end
		if VRSwingPhase >= math.pi then
			VRSwingActive = false
			VRSwingPhase = 0
			VRSwingHitSent = false
			-- punch does not grab. Q is the only grab.
		end
	end

	local function driveLimb(name, worldCF)
		local limb = char:FindFirstChild(name)
		if not limb or not limb:IsA("BasePart") then return end
		limb.CanCollide = false
		limb.Anchored = true
		limb:SetAttribute("CLL_VR_Anchored", true)
		limb.CFrame = worldCF
	end
	driveLimb("Right Arm", rightHand)
	driveLimb("Left Arm", leftHand)
	if headPart and headPart:IsA("BasePart") and headPart.Anchored then
		headPart.Anchored = false
	end

	pcall(function()
		char:SetAttribute("VR_RIGHT_ARM_CFRAME", rightHand)
		char:SetAttribute("VR_LEFT_ARM_CFRAME", leftHand)
		char:SetAttribute("VR_HEAD_CFRAME", headCF)
		-- root ONLY when actively locked on a living target (never empty / never alone)
		local vt = (ST.VRTargetEnabled and GetVRTargets and GetVRTargets()) or {}
		if ST.VRTargetEnabled and #vt > 0 and vt[1].head and vt[1].head.Parent then
			char:SetAttribute("VR_ROOTPART_CFRAME", hrp.CFrame)
		end
		char:SetAttribute("VR_CAMERA_RECOIL", Vector3.zero)
	end)
	if headPart and headPart:IsA("BasePart") then
		headPart.Anchored = false
	end
	if hum then
		pcall(function() hum.CameraOffset = Vector3.zero end)
		-- counter server VR slow: keep at least normal walk
		pcall(function()
			local floor = (ST.WalkSpeedEnabled and ST.WalkSpeedValue) or 16
			hum.WalkSpeed = math.max(hum.WalkSpeed, floor)
		end)
	end

	if tick() - (vrLastUpdate or 0) >= 0.05 and FxRemote then
		vrLastUpdate = tick()
		local grace = (type(_G.CLL_VR_SPAWN_GRACE) == "number" and os.clock() < _G.CLL_VR_SPAWN_GRACE)
		if not grace then
			pcall(function()
				local payload = {
					VR_RIGHT_ARM_CFRAME = rightHand,
					VR_LEFT_ARM_CFRAME = leftHand,
					VR_HEAD_CFRAME = headCF,
				}
				local vt = (GetVRTargets and GetVRTargets()) or {}
				if ST.VRTargetEnabled and #vt > 0 and vt[1].head and vt[1].head.Parent then
					payload.VR_ROOTPART_CFRAME = hrp.CFrame
				end
				FxRemote:FireServer("VR_UPDATE", payload)
			end)
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(c)
	vrDidInit = false
	VR_Cam_Rotation = CFrame.Angles(0, 0, 0)
	pcall(function()
		if c then
			c:SetAttribute("CLL_SpawnT", tick())
			c:SetAttribute("DID_VR", false)
			c:SetAttribute("VR", false)
		end
	end)
	pcall(function()
		vrRestoreShoulders()
		if c then
			for _, n in ipairs({"Right Arm", "Left Arm", "Head"}) do
				local part = c:FindFirstChild(n)
				if part and part:IsA("BasePart") then
					part.Anchored = false
				end
			end
		end
		releaseVRCamera()
	end)
	-- no auto re-enable VR after respawn (user toggles manually)
end)

--// ==================== REAL AIM CROSSHAIR ====================

local realCrossGui = Instance.new("ScreenGui")
realCrossGui.Name = "CLL_RealCrosshair"
realCrossGui.ResetOnSpawn = false
realCrossGui.IgnoreGuiInset = true
realCrossGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local realDot = Instance.new("Frame")
realDot.Name = "Dot"
realDot.AnchorPoint = Vector2.new(0.5, 0.5)
realDot.Size = UDim2.fromOffset(6, 6)
realDot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
realDot.BorderSizePixel = 0
realDot.Visible = false
realDot.Parent = realCrossGui
Instance.new("UICorner", realDot).CornerRadius = UDim.new(1, 0)
local realRing = Instance.new("Frame")
realRing.Name = "Ring"
realRing.AnchorPoint = Vector2.new(0.5, 0.5)
realRing.Size = UDim2.fromOffset(14, 14)
realRing.BackgroundTransparency = 1
realRing.Visible = false
realRing.Parent = realCrossGui
local realStroke = Instance.new("UIStroke", realRing)
realStroke.Color = Color3.fromRGB(0, 255, 120)
realStroke.Thickness = 1.5
Instance.new("UICorner", realRing).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
	if ST.isUnloaded or not ST.RealCrosshairEnabled then
		realDot.Visible = false
		realRing.Visible = false
		return
	end
	local cam = workspace.CurrentCamera
	local char = LocalPlayer.Character
	if not cam or not char then
		realDot.Visible = false
		realRing.Visible = false
		return
	end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool or tool.Parent ~= char then
		realDot.Visible = false
		realRing.Visible = false
		return
	end
	local fp = tool:FindFirstChild("Firepoint", true)
	if not fp then
		local base = tool:FindFirstChild("Base")
		fp = base and base:FindFirstChild("Firepoint")
	end
	if not fp then
		realDot.Visible = false
		realRing.Visible = false
		return
	end
	local origin = fp.WorldPosition
	local mouse = LocalPlayer:GetMouse()
	local hitPos = mouse.Hit.Position
	local dir = (hitPos - origin)
	if dir.Magnitude < 0.05 then
		realDot.Visible = false
		realRing.Visible = false
		return
	end
	dir = dir.Unit
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char, workspace:FindFirstChild("Cache") }
	local ray = workspace:Raycast(origin, dir * 2000, params)
	local worldPos = ray and ray.Position or (origin + dir * 200)
	local sp, onScreen = cam:WorldToViewportPoint(worldPos)
	if onScreen and sp.Z > 0 then
		realDot.Position = UDim2.fromOffset(sp.X, sp.Y)
		realRing.Position = UDim2.fromOffset(sp.X, sp.Y)
		realDot.Visible = true
		realRing.Visible = true
	else
		realDot.Visible = false
		realRing.Visible = false
	end
end)

--// ==================== HOOKS ====================
function GetClosestPlayerInFOV()
	if not ST.SilentAimEnabled then return nil end
	local cam = workspace.CurrentCamera; if not cam then return nil end
	local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2); local closest, closestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local head, hum = plr.Character:FindFirstChild("Head"), plr.Character:FindFirstChildOfClass("Humanoid")
			if head and hum and hum.Health > 0 then
				local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
				if onScreen then
					local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
					if distFromCenter < (cam.ViewportSize.Y / 2) * (ST.SilentAimFOV / cam.FieldOfView) and distFromCenter < closestDist then closest, closestDist = head, distFromCenter end
				end
			end
		end
	end
	return closest
end

function GetClosestAimPartInFOV()
	if not ST.SilentAimEnabled then return nil end
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local fovR = (cam.ViewportSize.Y / 2) * (ST.SilentAimFOV / math.max(cam.FieldOfView, 1))
	local partName = ST.SilentAimPart or "Head"
	local closest, closestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and not (ST.SUK_IgnoreFriends and FriendsList[plr.UserId]) then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local part = plr.Character:FindFirstChild(partName)
					or plr.Character:FindFirstChild("Head")
					or plr.Character:FindFirstChild("HumanoidRootPart")
				if part then
					local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
					if onScreen and screenPos.Z > 0 then
						local d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
						if d < fovR and d < closestDist then
							closest, closestDist = part, d
						end
					end
				end
			end
		end
	end
	return closest
end


local lastFireTime = 0
local SHAKE_FX = {
	["Camera Shake"] = true,
	["Camera Shake Alt"] = true,
	["Shake"] = true,
	["Earthquake"] = true,
	["Fov"] = true,
	["Crosshair Shove"] = true,
	["Color Correction"] = true,
	["Flash"] = true,
	["Screen Flash"] = true,
	["Blind"] = true,
}
function shouldBlockFx(name)
	if not name then return false end
	local l = string.lower(tostring(name))
	-- camera shake / fov / shove: ONLY when AntiCamShake or NoRecoil
	if ST.AntiCamShakeEnabled or ST.NoRecoilEnabled then
		if SHAKE_FX[name] then
			-- flash names are not shake — don't fold them here
			if name == "Flash" or name == "Screen Flash" or name == "Blind" or name == "Color Correction" then
				-- fall through to flash section
			else
				return true
			end
		end
		if l:find("shake") or l:find("recoil") or l:find("shove") then return true end
		if ST.NoRecoilEnabled and (l:find("fov") or name == "Fov") then return true end
		if ST.AntiCamShakeEnabled and (l:find("fov") or name == "Fov") then return true end
	end
	-- Kill HIGHLIGHT (xray/kill feed glow) — controlled by AntiFlashBlockKill
	-- ON = block kill highlight; OFF = allow kill highlight
	local isKillHL = l:find("kill") or l:find("death") or l:find("headshot")
		or l:find("xray") or l:find("highlight") or l:find("eliminat") or l:find("playerkill")
	if isKillHL then
		if ST.AntiFlashEnabled and ST.AntiFlashBlockKill then
			return true
		end
		return false -- never treat kill HL as flashbang
	end
	-- real flashbang / white screen — controlled by AntiFlashBlockBang
	if ST.AntiFlashEnabled and ST.AntiFlashBlockBang then
		if name == "Flash" or name == "Screen Flash" or name == "Blind" or name == "Color Correction" then
			return true
		end
		if l:find("flash") or l:find("blind") or l:find("blackoverlay") or l:find("black overlay")
			or l:find("color correction") or (l:find("bang") and not l:find("shake")) then
			return true
		end
		if l:find("pulse") and not l:find("shake") then return true end
	end
	return false
end


-- ==================== KILL HIGHLIGHT ====================
local KillHL_Tracked = {} -- [Model] = os.clock()
markKillCandidate = function(char)
	if not char or not char:IsA("Model") then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then return end -- corpse hits must not arm a highlight
	KillHL_Tracked[char] = os.clock()
end

playKillHighlight = function(char)
	if not ST.KillHighlightEnabled or not char or not char.Parent then return end
	pcall(function()
		local oldHl = char:FindFirstChild("CLL_KillHL")
		if oldHl then oldHl:Destroy() end
		local oldBeam = workspace:FindFirstChild("CLL_KillBeam_" .. tostring(char.Name))
		if oldBeam then oldBeam:Destroy() end
		local col = ST.KillHighlightColor or Color3.fromRGB(40, 160, 255)
		-- chams-style: AlwaysOnTop Highlight, soft fill + crisp outline, smooth fade
		local hl = Instance.new("Highlight")
		hl.Name = "CLL_KillHL"
		hl.Adornee = char
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillColor = col
		hl.OutlineColor = Color3.new(
			math.min(1, col.R * 1.15 + 0.08),
			math.min(1, col.G * 1.15 + 0.08),
			math.min(1, col.B * 1.15 + 0.08)
		)
		local fill0 = math.clamp(ESP_Config.ChamsFillTrans or 0.5, 0.15, 0.85)
		local out0 = math.clamp(ESP_Config.ChamsOutlineTrans or 0, 0, 0.4)
		hl.FillTransparency = math.max(0.05, fill0 - 0.25)
		hl.OutlineTransparency = out0
		hl.Parent = char
		local hold = math.clamp(ST.KillHighlightDuration or 0.55, 0.05, 5)
		local fade = math.clamp(ST.KillHighlightFade or 0.65, 0.05, 5)
		-- vertical kill pillar (world-space, always up); toggle ST.KillBeamEnabled
		if ST.KillBeamEnabled then
			pcall(function()
				local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
				if not head then return end
				local base = head.Position
				local pillar = Instance.new("Part")
				pillar.Name = "CLL_KillBeam_" .. (char.Name or "x")
				pillar.Anchored = true
				pillar.CanCollide = false
				pillar.CanQuery = false
				pillar.CanTouch = false
				pillar.Transparency = 1
				pillar.Size = Vector3.new(0.1, 0.1, 0.1)
				pillar.CFrame = CFrame.new(base) -- origin at body; attachments define pure +Y span
				pillar.Parent = workspace
				local aBot = Instance.new("Attachment")
				aBot.Name = "Bot"
				aBot.Position = Vector3.new(0, 0, 0)
				aBot.Parent = pillar
				local aTop = Instance.new("Attachment")
				aTop.Name = "Top"
				aTop.Position = Vector3.new(0, 100, 0) -- pure vertical
				aTop.Parent = pillar
				local beam = Instance.new("Beam")
				beam.Attachment0 = aTop
				beam.Attachment1 = aBot
				beam.Color = ColorSequence.new(col)
				beam.Width0 = 2.2
				beam.Width1 = 0.25
				beam.FaceCamera = true
				beam.LightEmission = 1
				beam.LightInfluence = 0
				beam.Segments = 10
				beam.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.05),
					NumberSequenceKeypoint.new(1, 0.4),
				})
				beam.Parent = pillar
				task.spawn(function()
					local t0 = os.clock()
					local life = hold + fade
					while pillar.Parent and os.clock() - t0 < life do
						local tr = math.clamp((os.clock() - t0) / life, 0, 1)
						beam.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, tr),
							NumberSequenceKeypoint.new(1, math.min(1, tr + 0.35)),
						})
						beam.Width0 = 2.2 * (1 - tr * 0.75)
						task.wait(0.03)
					end
					pcall(function() pillar:Destroy() end)
				end)
			end)
		end
		-- settle pop to normal chams look over ~0.12s
		task.spawn(function()
			local t0 = os.clock()
			while hl and hl.Parent do
				local a = math.clamp((os.clock() - t0) / 0.12, 0, 1)
				local e = a * a * (3 - 2 * a) -- smoothstep
				hl.FillTransparency = math.max(0.05, fill0 - 0.25) + (fill0 - math.max(0.05, fill0 - 0.25)) * e
				if a >= 1 then break end
				task.wait()
			end
		end)
		task.delay(hold, function()
			if not hl or not hl.Parent then return end
			local t0 = os.clock()
			local fillStart = hl.FillTransparency
			local outStart = hl.OutlineTransparency
			local colStart = hl.FillColor
			local colEnd = colStart:Lerp(Color3.new(1, 1, 1), 0.35)
			local conn
			conn = RunService.RenderStepped:Connect(function()
				if not hl or not hl.Parent then
					if conn then conn:Disconnect() end
					return
				end
				local a = math.clamp((os.clock() - t0) / fade, 0, 1)
				-- smooth ease-out cubic, then soft tail
				local e = 1 - (1 - a) * (1 - a) * (1 - a)
				e = e * e -- longer soft tail
				hl.FillTransparency = fillStart + (1 - fillStart) * e
				hl.OutlineTransparency = outStart + (1 - outStart) * math.clamp(e * 1.05, 0, 1)
				hl.FillColor = colStart:Lerp(colEnd, e)
				hl.OutlineColor = hl.OutlineColor:Lerp(Color3.new(1, 1, 1), e * 0.5)
				if a >= 1 then
					conn:Disconnect()
					pcall(function() hl:Destroy() end)
				end
			end)
		end)
	end)
end

onVictimDied = function(char)
	-- any death, not only ours. corpses already flagged never flash
	if not char or char == LocalPlayer.Character then return end
	if char:GetAttribute("CLL_HL_Done") then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then return end
	char:SetAttribute("CLL_HL_Done", true)
	playKillHighlight(char)
end

task.spawn(function()
	local function hookChar(char)
		if not char or char == LocalPlayer.Character or char:GetAttribute("CLL_KH_Hook") then return end
		local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
		if not hum then return end
		char:SetAttribute("CLL_KH_Hook", true)
		if hum.Health <= 0 then
			char:SetAttribute("CLL_HL_Done", true)
			return
		end
		hum.Died:Connect(function()
			onVictimDied(char)
		end)
		hum.HealthChanged:Connect(function(hp)
			if hp <= 0 then onVictimDied(char) end
		end)
	end
	local function hookPlr(plr)
		if plr == LocalPlayer then return end
		if plr.Character then hookChar(plr.Character) end
		plr.CharacterAdded:Connect(function(char)
			char:SetAttribute("CLL_KH_Hook", nil)
			char:SetAttribute("CLL_HL_Done", nil)
			hookChar(char)
		end)
	end
	for _, pl in ipairs(Players:GetPlayers()) do hookPlr(pl) end
	Players.PlayerAdded:Connect(hookPlr)
	task.spawn(function()
		while not ST.isUnloaded do
			task.wait(4)
			-- only scan Humans folder + player chars (no full workspace)
			local folder = workspace:FindFirstChild("Humans")
			if folder then
				for _, m in ipairs(folder:GetChildren()) do
					if m:IsA("Model") then pcall(hookChar, m) end
				end
			end
			for _, pl in ipairs(Players:GetPlayers()) do
				if pl.Character then pcall(hookChar, pl.Character) end
			end
		end
	end)
end)

local CLL_PendingGunName = nil
local CLL_PendingKillSound = false
local CLL_PendingHitSound = false
local CLL_PendingKillChar = nil

function playCustomSound(soundId, parent, vol)
	-- custom sounds fully stripped (user request)
	return
end

-- wallbang target: closest living head along look / silent aim, ignore walls


local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	-- capture method BEFORE any other call. Raycast/Instance inside this hook
	-- replaces the namecall method, so FireServer never reaches the server.
	local method = getnamecallmethod()
	local function pass(...)
		if setnamecallmethod then pcall(setnamecallmethod, method) end
		return oldNamecall(self, ...)
	end
	if type(checkcaller) == "function" then
		local okc, mine = pcall(checkcaller)
		if okc and mine then
			return pass(...)
		end
	end
	local args = { ... }

	-- Helper BindableEvent:Fire("Fx", ...)
	if method == "Fire" then
		if args[1] == "Fx" and shouldBlockFx(args[2]) then
			return
		end
		-- kill / death sound swap via Helper if game routes there
		if args[1] == "Fx" then
			local n = tostring(args[2] or ""):lower()
			if n == "kill" or n == "death" or n == "headshot" or n:find("eliminat") or n:find("playerkill") then
				if ST.CustomKillSoundEnabled and CustomKillSoundId ~= "" then
					CLL_PendingKillSound = true
				end
				pcall(function()
					for i = 3, math.min(#args, 6) do
						local a = args[i]
						if typeof(a) == "Instance" then
							local model = a:IsA("Model") and a or a:FindFirstAncestorOfClass("Model")
							if model then CLL_PendingKillChar = model end
						end
					end
				end)
			end
		end
	end

	if method == "FireServer" then
		-- block shake/flash on remotes
		-- only block Fx remote payloads, NEVER tool Fire/Hit/Reload strings
		if (self == FxRemote or tostring(self and self.Name) == "Fx") and typeof(args[1]) == "string" and shouldBlockFx(args[1]) then
			return
		end
		if args[1] == "Fx" and shouldBlockFx(args[2]) then
			return
		end
		-- do NOT shouldBlockFx(args[2]) on gun remotes — broke damage when args[2]=="Hit"/"Fire" matched loosely

		-- Silent aim / fire path: match FireRemote OR any FireServer(tool, "Fire", payload)
		local isGunFire = (args[2] == "Fire" and typeof(args[3]) == "table" and typeof(args[3].origin) == "Vector3")
			and (self == FireRemote or (typeof(args[1]) == "Instance" and args[1].ClassName == "Tool"))
		if isGunFire then
			-- only mutate the payload table. no Raycast / CreateTracer / FindFirstChild here.
			local payload = args[3]
			local origin = payload.origin
			if ST.SilentAimEnabled and typeof(origin) == "Vector3" and _G.CLL_AimPos and typeof(_G.CLL_AimPos) == "Vector3" then
				local d = _G.CLL_AimPos - origin
				if d.Magnitude > 0.01 then payload.direction = d.Unit end
			end
			if ST.NoSpreadEnabled and typeof(payload.direction) == "Vector3" and payload.direction.Magnitude > 1e-4 then
				payload.direction = payload.direction.Unit
				_G.CLL_NoSpreadDir = payload.direction
				_G.CLL_NoSpreadUntil = os.clock() + 0.12
			end
			task.defer(function()
				pcall(markLocalShot, origin)
			end)
			return pass(...)
		end
		-- track Hit packets for kill highlight (does not modify packet)
		if args[2] == "Hit" then
			pcall(function()
				local hitArg = args[3]
				local model = nil
				if typeof(hitArg) == "table" and typeof(hitArg.hit) == "Instance" then
					model = hitArg.hit:FindFirstAncestorOfClass("Model") or hitArg.hit.Parent
				elseif typeof(hitArg) == "Instance" then
					model = hitArg:IsA("Model") and hitArg or hitArg:FindFirstAncestorOfClass("Model")
				end
				if model then
					markKillCandidate(model)
					markLocalShot(nil)
				end
			end)
		end
	end

	-- NoSpread: pin every Helper "Fire Bullet" pellet to the locked dir (no mouse rewrite)
	if method == "Fire" and ST.NoSpreadEnabled then
		pcall(function()
			if args[1] == "Fx" and tostring(args[2]) == "Fire Bullet" then
				local payload = args[4]
				if typeof(payload) == "table" and typeof(payload.direction) == "Vector3" then
					local locked = nil
					if typeof(_G.CLL_NoSpreadDir) == "Vector3" and type(_G.CLL_NoSpreadUntil) == "number" and os.clock() <= _G.CLL_NoSpreadUntil then
						locked = _G.CLL_NoSpreadDir
					end
					if locked then
						payload.direction = locked
					else
						-- first pellet this burst becomes the lock
						if payload.direction.Magnitude > 1e-4 then
							_G.CLL_NoSpreadDir = payload.direction.Unit
							_G.CLL_NoSpreadUntil = os.clock() + 0.12
							payload.direction = _G.CLL_NoSpreadDir
						end
					end
				end
			end
		end)
	end

	-- melee / VR swing Hit → kill highlight
	if method == "FireServer" and (self == SwingRemote or tostring(self and self.Name) == "Swing") then
		pcall(function()
			local a1, a2, a3 = args[1], args[2], args[3]
			local part
			if a2 == "Hit" and typeof(a3) == "Instance" then part = a3
			elseif a1 == "Hit" and typeof(a2) == "Instance" then part = a2
			elseif typeof(a2) == "string" and tostring(a2):find("Hit") and typeof(a3) == "Instance" then part = a3
			end
			if part then
				local model = part:IsA("Model") and part or part:FindFirstAncestorOfClass("Model")
				if model and model:FindFirstChildOfClass("Humanoid") then
					if markKillCandidate then markKillCandidate(model) end
					lastMeleeAt = os.clock()
				end
			end
		end)
	end
	return pass(...)
end)


-- silent aim position, computed outside __namecall (namecall inside the hook kills FireServer)
task.spawn(function()
	while not ST.isUnloaded do
		task.wait(0.03)
		if ST.SilentAimEnabled and GetClosestAimPartInFOV then
			local ok, part = pcall(GetClosestAimPartInFOV)
			if ok and part then
				_G.CLL_AimPos = part.Position
			else
				_G.CLL_AimPos = nil
			end
		else
			_G.CLL_AimPos = nil
		end
	end
end)

-- kill highlight queue only (custom sounds removed)
RunService.Heartbeat:Connect(function()
	if ST.isUnloaded then return end
	-- only act when a kill is pending (was clearing every frame → FPS + broken highlights)
	if CLL_PendingKillChar then
		local model = CLL_PendingKillChar
		CLL_PendingKillChar = nil
		if playKillHighlight then playKillHighlight(model) end
	end
end)

-- hard anti-camera-shake: freeze CFrame deltas from BodyMovers / humanoid
local lastCamCF = nil
RunService:BindToRenderStep("CLL_AntiShake", Enum.RenderPriority.Camera.Value + 10, function()
	if ST.isUnloaded then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	if ST.AntiCamShakeEnabled or ST.NoRecoilEnabled then
		-- zero humanoid camera offset / shake attributes
		local char = LocalPlayer.Character
		if char then
			pcall(function()
				char:SetAttribute("VR_CAMERA_RECOIL", Vector3.zero)
				char:SetAttribute("CameraShake", Vector3.zero)
			end)
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function()
					hum.CameraOffset = Vector3.zero
				end)
			end
		end
	end
	if ST.AntiFlashEnabled then
		pcall(function()
			local pg = LocalPlayer:FindFirstChild("PlayerGui")
			if not pg then return end
			local vfx = pg:FindFirstChild("VFXRuntimeScreenFX")
			if vfx then
				local flash = vfx:FindFirstChild("Flash")
				if flash and flash:IsA("GuiObject") then
					flash.Visible = false
					flash.BackgroundTransparency = 1
				end
			end
			local lighting = game:GetService("Lighting")
			for _, c in ipairs(lighting:GetChildren()) do
				if c:IsA("ColorCorrectionEffect") or c:IsA("BloomEffect") then
					if c.Name:lower():find("flash") or c.Name:lower():find("blind") or c.Name:lower():find("cc") then
						c.Enabled = false
					end
				end
			end
		end)
	end
end)

-- custom kill/hit/gun sounds removed


-- Spoof VR State
local oldIndex = nil

--// ==================== UI FRAMEWORK ====================
local ThemeDark = {
	Bg = Color3.fromRGB(10, 10, 12), Panel = Color3.fromRGB(16, 16, 20), Row = Color3.fromRGB(24, 24, 30),
	Stroke = Color3.fromRGB(38, 40, 50), Text = Color3.fromRGB(240, 242, 248), Dim = Color3.fromRGB(110, 114, 130),
	Off = Color3.fromRGB(32, 32, 40), OnTrack = Color3.fromRGB(55, 120, 255), Knob = Color3.fromRGB(255, 255, 255),
	TabOn = Color3.fromRGB(28, 32, 44), Accent = Color3.fromRGB(55, 120, 255),
}
local ThemeLight = {
	Bg = Color3.fromRGB(245, 246, 250), Panel = Color3.fromRGB(255, 255, 255), Row = Color3.fromRGB(236, 238, 244),
	Stroke = Color3.fromRGB(210, 214, 224), Text = Color3.fromRGB(22, 24, 32), Dim = Color3.fromRGB(100, 106, 120),
	Off = Color3.fromRGB(220, 224, 232), OnTrack = Color3.fromRGB(55, 120, 255), Knob = Color3.fromRGB(255, 255, 255),
	TabOn = Color3.fromRGB(228, 232, 242), Accent = Color3.fromRGB(55, 120, 255),
}
local Theme = {}
for k, v in pairs(ThemeDark) do Theme[k] = v end
ST.ThemeLight = false

local CosmeticColorCustom = Color3.fromRGB(55, 120, 255)
local CosmeticUseCustom = true
local watermarkMain, watermarkBinds, watermarkWorld = nil, nil, nil

local UIRefs = { window = nil, logoLabel = nil, sidebar = nil, header = nil }
local ThemeSubscribers = {}
function subscribeTheme(fn) ThemeSubscribers[#ThemeSubscribers + 1] = fn end

local function accentFromHSV()
	local h = tonumber(ST.AccentH) or 220
	local s = tonumber(ST.AccentS) or 0.78
	local v = tonumber(ST.AccentV) or 1
	local col = Color3.fromHSV(math.clamp(h, 0, 360) / 360, math.clamp(s, 0, 1), math.clamp(v, 0, 1))
	Theme.Accent = col
	Theme.OnTrack = col
	ST.MenuGridColor = col
	CosmeticColorCustom = col
	fireTheme()
	pcall(function() if rebuildMenuGrid and ST.MenuGridEnabled then rebuildMenuGrid() end end)
	return col
end

function fireTheme()
	Theme.OnTrack = Theme.Accent
	for i = 1, #ThemeSubscribers do pcall(ThemeSubscribers[i]) end
end


local function repaintThemeTree(root)
	if not root then return end
	pcall(function()
		local function walk(o)
			if not o then return end
			local role = o:GetAttribute("CLL_ThemeRole")
			if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
				if role == "dim" or (not role and o.TextSize and o.TextSize <= 12) then
					o.TextColor3 = Theme.Dim
				else
					-- force readable body text
					local tc = o.TextColor3
					local lum = tc.R * 0.3 + tc.G * 0.59 + tc.B * 0.11
					if ST.ThemeLight then
						if lum > 0.55 then o.TextColor3 = Theme.Text end
					else
						if lum < 0.45 then o.TextColor3 = Theme.Text end
					end
				end
			end
			if o:IsA("UIStroke") then
				pcall(function() o.Color = Theme.Stroke end)
			end
			if o:IsA("Frame") or o:IsA("CanvasGroup") then
				if role == "bg" or o == UIRefs.window then
					o.BackgroundColor3 = Theme.Bg
				elseif role == "panel" then
					o.BackgroundColor3 = Theme.Panel
				elseif role == "row" then
					o.BackgroundColor3 = Theme.Row
				elseif o.BackgroundTransparency < 0.85 then
					local bg = o.BackgroundColor3
					local lum = bg.R * 0.3 + bg.G * 0.59 + bg.B * 0.11
					if ST.ThemeLight and lum < 0.22 then
						o.BackgroundColor3 = Theme.Panel
					elseif (not ST.ThemeLight) and lum > 0.82 then
						o.BackgroundColor3 = Theme.Panel
					end
				end
			end
			for _, ch in ipairs(o:GetChildren()) do walk(ch) end
		end
		walk(root)
	end)
end

function applyThemeMode(light, animate)
	-- light theme removed
	ST.ThemeLight = false
	if light then return end
	local srcT = light and ThemeLight or ThemeDark
	-- keep accent from current
	local accent = Theme.Accent
	if animate then
		local from = {}
		for k, v in pairs(Theme) do
			if typeof(v) == "Color3" then from[k] = v end
		end
		local t0 = os.clock()
		local dur = 0.35
		local conn
		conn = RunService.RenderStepped:Connect(function()
			local a = math.clamp((os.clock() - t0) / dur, 0, 1)
			a = a * a * (3 - 2 * a) -- smoothstep
			for k, goal in pairs(srcT) do
				if typeof(goal) == "Color3" and from[k] then
					Theme[k] = from[k]:Lerp(goal, a)
				elseif typeof(goal) == "Color3" then
					Theme[k] = goal
				end
			end
			Theme.Accent = accent
			Theme.OnTrack = accent
			fireTheme()
			-- repaint common roots
			pcall(function()
				if UIRefs.window then UIRefs.window.BackgroundColor3 = Theme.Bg; repaintThemeTree(UIRefs.window) end; if gui then repaintThemeTree(gui) end
			end)
			if a >= 1 then
				conn:Disconnect()
				for k, goal in pairs(srcT) do Theme[k] = goal end
				Theme.Accent = accent
				Theme.OnTrack = accent
				fireTheme()
			end
		end)
	else
		for k, goal in pairs(srcT) do Theme[k] = goal end
		Theme.Accent = accent
		Theme.OnTrack = accent
		fireTheme()
		pcall(function()
			if UIRefs.window then UIRefs.window.BackgroundColor3 = Theme.Bg; repaintThemeTree(UIRefs.window) end; if gui then repaintThemeTree(gui) end
		end)
	end
end

local DESIGN_W, DESIGN_H = 920, 560
new = function(c, p, ch) local o = Instance.new(c); for k, v in pairs(p or {}) do o[k] = v end; for _, x in ipairs(ch or {}) do x.Parent = o end; return o end
corner = function(r) return new("UICorner", { CornerRadius = UDim.new(0, r) }) end
round = function() return new("UICorner", { CornerRadius = UDim.new(0.5, 0) }) end
stroke = function(c, t) return new("UIStroke", { Color = c or Theme.Stroke, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end
label = function(p)
	p.BackgroundTransparency = 1
	p.Font = p.Font or Enum.Font.Gotham
	p.TextColor3 = p.TextColor3 or Theme.Text
	p.TextSize = p.TextSize or 15
	p.TextXAlignment = p.TextXAlignment or Enum.TextXAlignment.Left
	local langKey = p.LangKey
	p.LangKey = nil
	local isDim = (p.TextColor3 == Theme.Dim)
	local o = new("TextLabel", p)
	if type(langKey) == "string" and langKey ~= "" then
		o:SetAttribute("CLL_LangKey", langKey)
	end
	if isDim then
		o:SetAttribute("CLL_ThemeRole", "dim")
	else
		o:SetAttribute("CLL_ThemeRole", "text")
	end
	return o
end
function tween(o, t, p)
	if typeof(o) ~= "Instance" then return end
	pcall(function() TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad), p):Play() end)
end
function spaced(t) return (t:upper():gsub("(.)", "%1 "):gsub(" $", "")) end

local gui = new("ScreenGui", { Name = "CLL", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true })
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- FOV Circle
local fovCircle = new("Frame", {
	Size = UDim2.fromOffset(200, 200), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1, Visible = false, Parent = gui
}, { round(), stroke(Color3.fromRGB(255, 255, 255), 1) })

function updateFOVCircle()
	if ST.SilentAimEnabled then
		fovCircle.Visible = true
		local cam = workspace.CurrentCamera
		if not cam then return end
		local fovRadius = (cam.ViewportSize.Y / 2) * (ST.SilentAimFOV / cam.FieldOfView)
		fovCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
	else
		fovCircle.Visible = false
	end
end
subscribeTheme(function() local s = fovCircle:FindFirstChildOfClass("UIStroke"); if s then s.Color = Theme.Accent end end)

function cosmeticColor() return CosmeticUseCustom and CosmeticColorCustom or Theme.Accent end


-- Anti-displace: dump CameraShaker binds at Last+1 — strip + run later
task.spawn(function()
	local bindName = "CLL_NoShake"
	pcall(function() RunService:UnbindFromRenderStep(bindName) end)
	local function stripShakers()
		for _, n in ipairs({"forge_updateCameraShake", "VFXRuntimeCameraShaker", "CameraShake", "CameraShakerUpdate"}) do
			pcall(function() RunService:UnbindFromRenderStep(n) end)
		end
	end
	stripShakers()
	RunService:BindToRenderStep(bindName, Enum.RenderPriority.Last.Value + 5, function()
		if ST.isUnloaded then return end
		stripShakers()
		local cam = workspace.CurrentCamera
		local char = LocalPlayer.Character
		if char then
			pcall(function()
				char:SetAttribute("CameraShake", Vector3.zero)
				char:SetAttribute("VR_CAMERA_RECOIL", Vector3.zero)
				char:SetAttribute("VR_RIGHT_ARM_RECOIL", CFrame.new())
				char:SetAttribute("CameraPunch", Vector3.zero)
				char:SetAttribute("Recoil", Vector3.zero)
			end)
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then pcall(function() hum.CameraOffset = Vector3.zero end) end
		end
		pcall(function() if cam then cam:SetAttribute("Shake", nil) end end)
		if ST.AntiFlashEnabled then
			pcall(function()
				local pg = LocalPlayer:FindFirstChild("PlayerGui")
				if not pg then return end
				for _, n in ipairs({"VFXRuntimeScreenFX", "Flashbang", "Flash", "Blind", "ScreenFX"}) do
					local g = pg:FindFirstChild(n, true)
					if g then
						if g:IsA("GuiObject") then g.Visible = false end
						if g:IsA("ScreenGui") then g.Enabled = false end
						for _, c in ipairs(g:GetDescendants()) do
							if c:IsA("Frame") or c:IsA("ImageLabel") then
								c.BackgroundTransparency = 1
								if c:IsA("ImageLabel") then c.ImageTransparency = 1 end
							end
							if c:IsA("BlurEffect") or c:IsA("ColorCorrectionEffect") then
								pcall(function() c.Enabled = false end)
							end
						end
					end
				end
				local lighting = game:GetService("Lighting")
				for _, c in ipairs(lighting:GetChildren()) do
					if c:IsA("BlurEffect") and (c.Name:lower():find("flash") or c.Size > 8) then
						c.Size = 0
					end
				end
			end)
		end
	end)
end)


-- Fire-rate assist: while LMB held, clear gun debounces so packets go out faster
task.spawn(function()
	while not ST.isUnloaded do
		local held = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		if held and not ST.isMultiSuk then
			local char = LocalPlayer.Character
			local tool = char and char:FindFirstChildOfClass("Tool")
			if tool then
				pcall(function()
					tool:SetAttribute("Cooldown", false)
					tool:SetAttribute("ClientCooldownUntil", 0)
					tool:SetAttribute("Debounce", false)
					tool:SetAttribute("CanFire", true)
					if char then char:SetAttribute("Reloading", false) end
				end)
			end
			task.wait(0.03)
		else
			task.wait(0.08)
		end
	end
end)

-- Window (No Auto Center, No Position Reset)
local window = new("CanvasGroup", { Size = UDim2.fromOffset(DESIGN_W, DESIGN_H), Position = UDim2.fromOffset(100, 100), BackgroundColor3 = Theme.Bg, GroupTransparency = 1, Parent = gui }, { corner(18), stroke() })
UIRefs.window = window
window.Visible = false
local uiScale = new("UIScale", { Parent = window })
local baseScale = 1; local animFactor = new("NumberValue", { Value = 1, Parent = gui })
function applyScale() uiScale.Scale = math.max(baseScale * animFactor.Value, 0.001) end
animFactor.Changed:Connect(applyScale)
function fit() local cam = workspace.CurrentCamera; if not cam then return end; local vs = cam.ViewportSize; baseScale = math.clamp(math.min((vs.X - 24) / DESIGN_W, (vs.Y - 24) / DESIGN_H), 0.4, 1); applyScale() end
fit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

local header = new("Frame", { Size = UDim2.new(1, 0, 0, 62), BackgroundTransparency = 1, Parent = window })
local logoLabel = label({ Text = "CLL", Font = Enum.Font.Michroma, TextSize = 26, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.fromOffset(100, 62), Position = UDim2.fromOffset(23, 0), Parent = header })
logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Always white
local verLabel = label({ Text = "v11.83-be", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(50, 62), Position = UDim2.fromOffset(85, 2), Parent = header })
local timeLabel = label({ Text = "Session: 00:00", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(150, 62), Position = UDim2.fromOffset(150, 0), Parent = header })
task.spawn(function()
	while not ST.isUnloaded do
		local e = os.clock() - SessionStartTime
		timeLabel.Text = string.format("Session: %02d:%02d", math.floor(e/60), math.floor(e%60))
		task.wait(1)
	end
end)

-- Icons & Tabs
function makeIcon(parent, build)
	local holder = new("Frame", { Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Parent = parent })
	local fills, strokes = {}, {}; local kit = {}
	function kit.bar(w, h, x, y, rot, par) local f = new("Frame", { Size = UDim2.fromOffset(w, h), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Rotation = rot or 0, BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, Parent = par or holder }, { corner(1) }); table.insert(fills, f); return f end
	function kit.disc(d, x, y, par) local f = new("Frame", { Size = UDim2.fromOffset(d, d), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, Parent = par or holder }, { round() }); table.insert(fills, f); return f end
	function kit.ring(w, h, x, y, t, par) local f = new("Frame", { Size = UDim2.fromOffset(w, h), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), BackgroundTransparency = 1, Parent = par or holder }, { round() }); local s = stroke(Theme.Dim, t or 1.5); s.Parent = f; table.insert(strokes, s); return f end
	function kit.group(par) return new("Frame", { Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(11, 11), BackgroundTransparency = 1, Parent = par or holder }) end
	build(kit)
	local function setColor(c) for _, f in ipairs(fills) do f.BackgroundColor3 = c end; for _, s in ipairs(strokes) do s.Color = c end end
	return setColor
end
local IconBuilders = {
	Combat = function(k) k.ring(14, 14, 11, 11, 1.5); k.bar(2, 5, 11, 2.5); k.bar(2, 5, 11, 19.5); k.bar(5, 2, 2.5, 11); k.bar(5, 2, 19.5, 11); k.disc(3, 11, 11) end,
	Movement = function(k) for _, x0 in ipairs({ 6.5, 13.5 }) do k.bar(8.5, 2, x0, 8, 45); k.bar(8.5, 2, x0, 14, -45) end end,
	Visual = function(k) local eye = k.ring(20, 12, 11, 11, 1.5); k.disc(5, 11, 11); return eye end,
	Effects = function(k) k.bar(8, 2.5, 11, 11, 0); k.bar(8, 2.5, 11, 11, 90); k.bar(6, 2, 11, 11, 45); k.bar(6, 2, 11, 11, -45); k.disc(2.5, 11, 11); for _, pos in ipairs({{5, 5}, {17, 5}, {5, 17}, {17, 17}}) do k.bar(4, 2, pos[1], pos[2], 0); k.bar(4, 2, pos[1], pos[2], 90); k.disc(1.5, pos[1], pos[2]) end end,
	Target = function(k) k.ring(19, 19, 11, 11, 1.5); k.ring(9, 9, 11, 11, 1); k.disc(3, 11, 11); k.bar(9, 1.5, 15.5, 11, 0); k.disc(3, 16.5, 6.5) end,
	Keybinds = function(k) k.ring(18, 18, 11, 11, 2); k.bar(2, 10, 9, 11, 20); k.bar(2, 10, 13, 11, -20); k.bar(5, 1.5, 11, 12, 0) end,
	Settings = function(k) local g = k.group(); for _, r in ipairs({{ 5, 8, { 3, 2 }, { 16, 8 } }, { 11, 15, { 6.5, 9 }, nil }, { 17, 11, { 4.5, 5 }, { 17.5, 5 } }}) do local y, kx, l, rt = r[1], r[2], r[3], r[4]; if l then k.bar(l[2], 2, l[1], y, 0, g) end; if rt then k.bar(rt[2], 2, rt[1], y, 0, g) end; k.disc(5, kx, y, g) end; return g end,
	VR = function(k) k.ring(16, 10, 11, 11, 1.5); k.disc(6, 7, 11); k.disc(6, 15, 11); k.bar(2, 4, 11, 5, 0) end,
	Profile = function(k) k.ring(18, 18, 11, 11, 2); k.bar(2, 10, 9, 11, 20); k.bar(2, 10, 13, 11, -20); k.bar(5, 1.5, 11, 12, 0) end,
}

local TAB_ORDER = { "Combat", "Movement", "Visual", "Effects", "Target", "Keybinds", "VR", "Settings" }
local sidebar = new("Frame", { Size = UDim2.fromOffset(150, DESIGN_H - 62), Position = UDim2.fromOffset(0, 62), BackgroundColor3 = Theme.Panel, Parent = window }, { corner(16), stroke() })
local pages, tabs = {}, {}
local currentTab
local contentFrame = new("Frame", { Size = UDim2.new(1, -150, 1, -62), Position = UDim2.fromOffset(150, 62), BackgroundTransparency = 1, ZIndex = 3, Parent = window })

function selectTab(name)
	pcall(function() if closeDrawer then closeDrawer() end end)
	currentTab = name
	-- tabs highlight (soft tween only on buttons, NOT pages — pages are Frames, fade caused overlap)
	for n, tab in pairs(tabs) do
		local on = (n == name)
		if tab and typeof(tab.btn) == "Instance" then
			pcall(function()
				TweenService:Create(tab.btn, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundTransparency = on and 0 or 1
				}):Play()
			end)
		end
		if tab and tab.setColor then pcall(tab.setColor, on and Theme.Accent or Theme.Dim) end
		if tab and typeof(tab.lbl) == "Instance" then
			pcall(function() tab.lbl.TextColor3 = on and Theme.Text or Theme.Dim end)
		end
	end
	-- exactly one page visible
	for n, pg in pairs(pages) do
		if typeof(pg) == "Instance" then
			pg.Visible = (n == name)
			pcall(function()
				if pg:IsA("CanvasGroup") then pg.GroupTransparency = 0 end
			end)
		end
	end
end

for idx, name in ipairs(TAB_ORDER) do
	local btn = new("TextButton", { Name = name, Text = "", AutoButtonColor = false, Size = UDim2.new(1, -16, 0, 34), Position = UDim2.fromOffset(8, 8 + (idx - 1) * 38), BackgroundColor3 = Theme.TabOn, BackgroundTransparency = 1, Parent = sidebar }, { corner(10) })
	local iconFrame = new("Frame", { Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), BackgroundTransparency = 1, Parent = btn })
	local setColor = makeIcon(iconFrame, IconBuilders[name] or IconBuilders.Settings)
	local tabKey = "tab_" .. name
	local lbl = label({ Text = Lt(tabKey, name), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.new(1, -48, 1, 0), Position = UDim2.fromOffset(36, 0), Parent = btn, LangKey = tabKey })
	tabs[name] = { btn = btn, setColor = setColor, lbl = lbl }
	pages[name] = new("Frame", { Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = contentFrame })
	local tabName = name
	subscribeTheme(function() if currentTab == tabName then setColor(Theme.Accent) else setColor(Theme.Dim) end end)
	btn.MouseButton1Click:Connect(function() selectTab(name) end)
end

-- Profile
pages.Profile = new("Frame", { Name = "Profile", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = contentFrame })
do
	local card = new("TextButton", { Name = "ProfileCard", Text = "", AutoButtonColor = false, Size = UDim2.new(1, -16, 0, 56), Position = UDim2.new(0, 8, 1, -64), BackgroundColor3 = Theme.Row, Parent = sidebar }, { corner(12), stroke() })
	local avatar = new("ImageLabel", { Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = Theme.Off, Parent = card }, { round(), stroke() })
	task.spawn(function() local ok, img = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100); if ok then avatar.Image = img end end)
	local nick = label({ Text = LocalPlayer.DisplayName, Font = Enum.Font.GothamMedium, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -56, 0, 18), Position = UDim2.fromOffset(52, 10), Parent = card })
	label({ Text = "@" .. LocalPlayer.Name, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -56, 0, 16), Position = UDim2.fromOffset(52, 28), Parent = card })
	tabs.Profile = { btn = card, setColor = function() end, lbl = nick }
	card.MouseButton1Click:Connect(function() selectTab("Profile") end)
end

local PAD = 20
function divider(parent, y) return new("Frame", { Size = UDim2.new(1, -PAD * 2, 0, 1), Position = UDim2.fromOffset(PAD, y), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = parent }) end

function toggle(parent, cy, text, cb, initial, getState, desc)
	-- title + switch on one row; optional dim desc under title
	if text ~= "" then label({ Text = text, Size = UDim2.new(1, -90, 0, 20), Position = UDim2.fromOffset(PAD, cy), Parent = parent }) end
	if type(desc) == "string" and desc ~= "" then
		label({
			Text = desc,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Theme.Dim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Size = UDim2.new(1, -PAD * 2 - 50, 0, 28),
			Position = UDim2.fromOffset(PAD, cy + 20),
			Parent = parent,
		})
	end
	local state = (getState and getState() or initial) and true or false
	local sw = new("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(42, 24),
		Position = UDim2.new(1, -PAD - 42, 0, cy), BackgroundColor3 = Theme.Off, Parent = parent
	}, { corner(12), stroke() })
	local knob = new("Frame", {
		Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.Bg, Parent = sw
	}, { corner(9) })
	local strokeObj = sw:FindFirstChildOfClass("UIStroke")
	local function paint(hover)
		local onCol = Theme.OnTrack
		local offCol = hover and Theme.Row or Theme.Off
		local goalTrack = state and onCol or offCol
		local goalKnob = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
		pcall(function()
			TweenService:Create(sw, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = goalTrack
			}):Play()
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = goalKnob, BackgroundColor3 = state and Theme.Knob or Theme.Bg
			}):Play()
			if strokeObj then
				TweenService:Create(strokeObj, TweenInfo.new(0.18), {
					Color = hover and Theme.OnTrack or Theme.Stroke, Thickness = hover and 1.4 or 1
				}):Play()
			end
		end)
	end
	local function render()
		paint(false)
	end
	sw.MouseEnter:Connect(function() paint(true) end)
	sw.MouseLeave:Connect(function() paint(false) end)
	sw.MouseButton1Click:Connect(function()
		state = not state
		paint(true)
		if cb then cb(state) end
	end)
	render(); subscribeTheme(render)
	local function set(val, fire)
		val = val and true or false
		if state == val then render(); return end
		state = val
		render()
		if fire and cb then cb(state) end
	end
	if getState then
		table.insert(UI_SyncHooks, function()
			pcall(function() set(getState() == true, false) end)
		end)
	end
	return set
end

function slider(parent, cy, text, min, max, default, step, cb, getValue, desc)
	-- layout: title+value at cy, optional dim desc below, track under that
	label({ Text = text, Size = UDim2.new(1, -90, 0, 16), Position = UDim2.fromOffset(PAD, cy), Parent = parent })
	local valueLbl = label({ Text = tostring(default), TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.fromOffset(50, 16), Position = UDim2.new(1, -PAD - 50, 0, cy), Parent = parent })
	local trackY = cy + 22
	if type(desc) == "string" and desc ~= "" then
		label({
			Text = desc,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Theme.Dim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Size = UDim2.new(1, -PAD * 2, 0, 14),
			Position = UDim2.fromOffset(PAD, cy + 16),
			Parent = parent,
		})
		trackY = cy + 34
	end
	local track = new("Frame", { Size = UDim2.new(1, -PAD * 2, 0, 5), Position = UDim2.fromOffset(PAD, trackY), BackgroundColor3 = Theme.Off, BorderSizePixel = 0, Parent = parent }, { corner(3) })
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = track }, { corner(3) })
	local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = Theme.Knob, Parent = track }, { corner(7) })
	local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), Parent = track })
	local lastV = nil
	local function apply(a, fire)
		a = math.clamp(a, 0, 1); fill.Size = UDim2.fromScale(a, 1); knob.Position = UDim2.fromScale(a, 0.5)
		local v = min + (max - min) * a
		if step and step > 0 then v = math.floor(v / step + 0.5) * step end
		if step >= 1 then v = math.floor(v + 0.5) end
		valueLbl.Text = (step < 1) and string.format("%.3g", v) or tostring(v)
		if fire and v ~= lastV then lastV = v; if cb then cb(v) end end
	end
	local function setFromValue(v, fire)
		v = tonumber(v) or default
		v = math.clamp(v, min, max)
		local a = (v - min) / math.max(max - min, 1e-6)
		lastV = nil
		apply(a, fire and true or false)
		lastV = v
	end
	local dragging = false
	local function fromInput(i) apply((i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), true) end
	hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; fromInput(i) end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then fromInput(i) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	subscribeTheme(function() fill.BackgroundColor3 = Theme.Accent end)
	lastV = default; apply((default - min) / math.max(max - min, 1e-6), false)
	if getValue then
		table.insert(UI_SliderHooks, function()
			pcall(function() setFromValue(getValue(), false) end)
		end)
	end
	return setFromValue
end

function makeMiniToggle(parent, initial, cb)
	local state = initial == true
	local sw = new("TextButton", {
		Text = "", AutoButtonColor = false, Active = true, Size = UDim2.fromOffset(42, 24),
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0),
		BackgroundColor3 = Theme.Off, ZIndex = 5, Parent = parent
	}, { corner(12), stroke() })
	local knob = new("Frame", {
		Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.Bg, ZIndex = 6, Parent = sw
	}, { corner(9) })
	local strokeObj = sw:FindFirstChildOfClass("UIStroke")
	local function paint(hover)
		local goalTrack = state and Theme.OnTrack or (hover and Theme.Row or Theme.Off)
		local goalKnob = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
		pcall(function()
			TweenService:Create(sw, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = goalTrack
			}):Play()
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = goalKnob, BackgroundColor3 = state and Theme.Knob or Theme.Bg
			}):Play()
			if strokeObj then
				TweenService:Create(strokeObj, TweenInfo.new(0.18), {
					Color = hover and Theme.OnTrack or Theme.Stroke, Thickness = hover and 1.4 or 1
				}):Play()
			end
		end)
	end
	local function render() paint(false) end
	sw.MouseEnter:Connect(function() paint(true) end)
	sw.MouseLeave:Connect(function() paint(false) end)
	sw.MouseButton1Click:Connect(function()
		state = not state
		paint(true)
		if cb then cb(state) end
	end)
	render()
	subscribeTheme(render)
	return function(v)
		local nv = v and true or false
		if state == nv then render(); return end
		state = nv
		render()
	end
end


function detailSlider(parent, order, text, min, max, default, step, cb)
	local wrap = new("Frame", { Size = UDim2.new(1, -16, 0, 52), BackgroundTransparency = 1, LayoutOrder = order, Parent = parent })
	label({ Text = text, TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.new(1, -50, 0, 18), Position = UDim2.fromOffset(0, 0), Parent = wrap })
	local valueLbl = label({ Text = tostring(default), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.fromOffset(48, 18), Position = UDim2.new(1, -48, 0, 0), Parent = wrap })
	local track = new("Frame", { Size = UDim2.new(1, 0, 0, 8), Position = UDim2.fromOffset(0, 28), BackgroundColor3 = Theme.Off, BorderSizePixel = 0, Parent = wrap }, { corner(4) })
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = track }, { corner(4) })
	local knob = new("Frame", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = Theme.Knob, Parent = track }, { corner(6) })
	local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), Parent = track })
	local function apply(a, fire)
		a = math.clamp(a, 0, 1); fill.Size = UDim2.fromScale(a, 1); knob.Position = UDim2.fromScale(a, 0.5)
		local v = min + (max - min) * a
		if step and step > 0 then v = math.floor(v / step + 0.5) * step end
		if step >= 1 then v = math.floor(v + 0.5) end
		valueLbl.Text = (step and step < 1) and string.format("%.3f", v) or tostring(v)
		if fire then cb(v) end
	end
	local dragging = false
	local function fromInput(i) apply((i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), true) end
	hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; fromInput(i) end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then fromInput(i) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	subscribeTheme(function() fill.BackgroundColor3 = Theme.Accent end)
	apply((default - min) / math.max(max - min, 1e-6), false)
end

function detailColor(parent, order, title, getColor, setColor)
	local wrap = new("Frame", {
		Size = UDim2.new(1, -16, 0, 118),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = parent,
	})
	label({
		Text = title,
		TextSize = 13,
		TextColor3 = Theme.Dim,
		Size = UDim2.new(1, -40, 0, 18),
		Position = UDim2.fromOffset(0, 0),
		Parent = wrap,
	})
	local preview = new("Frame", {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.new(1, -22, 0, 0),
		BackgroundColor3 = getColor(),
		BorderSizePixel = 0,
		Parent = wrap,
	}, { corner(4), stroke() })

	local function channel(row, name, getter, setter)
		local y = 26 + row * 28
		label({
			Text = name,
			TextSize = 12,
			TextColor3 = Theme.Text,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(0, y),
			Parent = wrap,
		})
		local track = new("Frame", {
			Size = UDim2.new(1, -28, 0, 10),
			Position = UDim2.fromOffset(20, y + 3),
			BackgroundColor3 = Theme.Off,
			BorderSizePixel = 0,
			Parent = wrap,
		}, { corner(5) })
		local fill = new("Frame", {
			Size = UDim2.fromScale(math.clamp(getter(), 0, 1), 1),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Parent = track,
		}, { corner(5) })
		local hit = new("TextButton", {
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 10),
			Position = UDim2.fromOffset(0, -5),
			Parent = track,
		})
		local dragging = false
		local function apply(a)
			a = math.clamp(a, 0, 1)
			fill.Size = UDim2.fromScale(a, 1)
			setter(a)
			local c = getColor()
			preview.BackgroundColor3 = c
			setColor(c)
		end
		hit.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				apply((i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				apply((i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
			end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
	end

	local col = getColor()
	local r, g, b = col.R, col.G, col.B
	channel(0, "R", function() return r end, function(v) r = v; setColor(Color3.new(r, g, b)); preview.BackgroundColor3 = Color3.new(r, g, b) end)
	channel(1, "G", function() return g end, function(v) g = v; setColor(Color3.new(r, g, b)); preview.BackgroundColor3 = Color3.new(r, g, b) end)
	channel(2, "B", function() return b end, function(v) b = v; setColor(Color3.new(r, g, b)); preview.BackgroundColor3 = Color3.new(r, g, b) end)
end

function detailToggle(parent, order, text, initial, cb, desc)
	local h = (type(desc) == "string" and desc ~= "") and 44 or 28
	local wrap = new("Frame", { Size = UDim2.new(1, -16, 0, h), BackgroundTransparency = 1, LayoutOrder = order, Parent = parent })
	label({ Text = text, TextSize = 13, Size = UDim2.new(1, -50, 0, 18), Position = UDim2.fromOffset(0, 0), Parent = wrap })
	if type(desc) == "string" and desc ~= "" then
		label({ Text = desc, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, TextWrapped = true, Size = UDim2.new(1, -50, 0, 20), Position = UDim2.fromOffset(0, 18), Parent = wrap })
	end
	makeMiniToggle(wrap, initial, cb)
end

local activeDrawer, activeDimmer = nil, nil
function closeDrawer()
	local d, dim = activeDrawer, activeDimmer
	activeDrawer, activeDimmer = nil, nil
	if not d and not dim then return end
	if dim then local tdim = TweenService:Create(dim, TweenInfo.new(0.16), { BackgroundTransparency = 1 }); tdim:Play(); tdim.Completed:Connect(function() if dim then dim:Destroy() end end) end
	if d then local tw = TweenService:Create(d, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 24, 0, 70) }); tw:Play(); tw.Completed:Connect(function() if d then d:Destroy() end end) end
end

function openFeatureDrawer(feat)
	closeDrawer()
	if not feat.buildDetail then return end
	local dimmer = new("TextButton", { Name = "Dimmer", Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 80, Parent = window })
	local drawer = new("Frame", { Name = "FeatureDrawer", Size = UDim2.fromOffset(300, DESIGN_H - 80), Position = UDim2.new(1, 24, 0, 70), BackgroundColor3 = Theme.Panel, ZIndex = 90, Parent = window }, { corner(16), stroke() })
	activeDrawer, activeDimmer = drawer, dimmer
	label({ Text = feat.name, Font = Enum.Font.GothamBold, TextSize = 15, Size = UDim2.new(1, -50, 0, 24), Position = UDim2.fromOffset(16, 14), ZIndex = 91, Parent = drawer })
	local closeBtn = new("TextButton", { Text = "X", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Theme.Dim, BackgroundTransparency = 1, Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -40, 0, 10), ZIndex = 91, Parent = drawer })
	closeBtn.MouseButton1Click:Connect(closeDrawer)
	dimmer.MouseButton1Click:Connect(closeDrawer)
	new("Frame", { Size = UDim2.new(1, -32, 0, 1), Position = UDim2.fromOffset(16, 48), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, ZIndex = 91, Parent = drawer })
	local body = new("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -64), Position = UDim2.fromOffset(8, 56), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Stroke, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 91, Parent = drawer }, {
		new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
		new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
	})
	feat.buildDetail(body)
	dimmer.Name = "Dimmer"
	TweenService:Create(dimmer, TweenInfo.new(0.18), { BackgroundTransparency = 0.45 }):Play()
	TweenService:Create(drawer, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(1, -312, 0, 70) }):Play()
end

local FEAT_STATE = {
	["Walk Speed"] = function() return ST.WalkSpeedEnabled end,
	["Jump Power"] = function() return ST.JumpPowerEnabled end,
	["Fly"] = function() return ST.FlyEnabled end,
	["Spin"] = function() return ST.SpinEnabled end,
	["No Clip"] = function() return ST.NoClipEnabled end,
	["Infinite Jump"] = function() return ST.InfiniteJumpEnabled end,
	["Anti-CC"] = function() return ST.AntiCCEnabled end,
	["ESP"] = function() return ESP_Config.Enabled end,
	["Highlight Chams"] = function() return ST.HighlightChamsEnabled end,
	["Aim Visualizer"] = function() return ST.TrueCrosshairEnabled end,
	["Bullet Tracers"] = function() return ST.TracersEnabled end,
	["Kill Highlight"] = function() return ST.KillHighlightEnabled end,
	["Anti Flash"] = function() return ST.AntiFlashEnabled end,
	["China Hat"] = function() return ST.ChinaHatEnabled end,
	["Custom Wings"] = function() return ST.WingsEnabled end,
	["Anti-Lag"] = function() return ST.AntiLagEnabled end,
	["Remove Fog"] = function() return ST.RemoveFogEnabled end,
	["Fullbright"] = function() return ST.FullbrightEnabled end,
	["Time Override"] = function() return ST.TimeOverrideEnabled end,
	["Camera FOV Lock"] = function() return ST.CameraFOVLocked end,
	["Max Zoom"] = function() return ST.MaxZoomEnabled end,
	["Sky Color"] = function() return ST.SkyColorEnabled end,
	["Silent Aim"] = function() return ST.SilentAimEnabled end,
	["Hitbox Expander"] = function() return Hitbox_Config.Enabled end,
	["No Recoil"] = function() return ST.NoRecoilEnabled end,
	["No Spread (Spas/Remington)"] = function() return ST.NoSpreadEnabled end,
	["Local Invis"] = function() return ST.LocalInvisEnabled end,
	["Custom Kill Sound"] = function() return ST.CustomKillSoundEnabled end,
	["Hit Sound"] = function() return ST.HitSoundEnabled end,
	["Custom Gun Sounds"] = function() return ST.CustomGunSoundsEnabled end,
}

function buildFeaturePage(page, sectionTitle, features)
	local panel = new("Frame", { Size = UDim2.new(1, -24, 1, -24), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.Panel, Parent = page }, { corner(14), stroke() })
	label({ Text = sectionTitle, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(16, 12), Parent = panel })
	label({ Text = "RMB - settings", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.fromOffset(120, 18), Position = UDim2.new(1, -132, 0, 12), Parent = panel })
	local list = new("ScrollingFrame", { Size = UDim2.new(1, -12, 1, -42), Position = UDim2.fromOffset(6, 36), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Stroke, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = panel }, { new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }), new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }) })
	for i, feat in ipairs(features) do
		local descText = (feat.descKey and Lt(feat.descKey, feat.desc)) or feat.desc
		if not descText or descText == "" then
			descText = feat.desc
		end
		-- always show a short description when we have a name
		if (not descText or descText == "") and feat.name then
			descText = nil -- optional
		end
		local rowH = descText and 54 or 40
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, rowH), BackgroundColor3 = Theme.Row, BackgroundTransparency = 0.35, LayoutOrder = i, Parent = list }, { corner(8) })
		row:SetAttribute("CLL_ThemeRole", "row")
		local accentLine = new("Frame", { Size = UDim2.fromOffset(3, 18), Position = UDim2.fromOffset(8, (rowH - 18) / 2), BackgroundColor3 = Theme.Accent, BackgroundTransparency = feat.buildDetail and 0.3 or 1, BorderSizePixel = 0, Parent = row }, { corner(2) })
		subscribeTheme(function() accentLine.BackgroundColor3 = Theme.Accent end)
		local titleStr = (feat.nameKey and Lt(feat.nameKey, feat.name)) or feat.name
		label({ Text = titleStr, Font = Enum.Font.GothamMedium, TextSize = 13, Size = UDim2.new(1, -100, 0, 18), Position = UDim2.fromOffset(18, descText and 6 or 11), Parent = row, LangKey = feat.nameKey })
		if descText then
			label({ Text = descText, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -100, 0, 16), Position = UDim2.fromOffset(18, 28), Parent = row, LangKey = feat.descKey })
		end
		if feat.buildDetail then label({ Text = "⚙", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(28, rowH), Position = UDim2.new(1, -78, 0, 0), Parent = row }) end
		local hit = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, -52, 1, 0), Parent = row })
		-- full row height so toggle sits centered (not stuck to top)
		local swHolder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(48, rowH), Position = UDim2.new(1, -48, 0, 0), ZIndex = 5, Parent = row })
		local initOn = feat.getState and (feat.getState() == true) or (feat.initial == true)
		local setT = makeMiniToggle(swHolder, initOn, function(v) feat.onToggle(v) end)
		UI_SyncHooks = UI_SyncHooks or {}
		table.insert(UI_SyncHooks, function()
			local getter = feat.getState or (FEAT_STATE and FEAT_STATE[feat.name])
			if not getter then return end
			local ok, on = pcall(getter)
			if ok then pcall(function() setT(on == true) end) end
		end)
		hit.MouseEnter:Connect(function() tween(row, 0.12, { BackgroundTransparency = 0.1 }) end)
		hit.MouseLeave:Connect(function() tween(row, 0.12, { BackgroundTransparency = 0.35 }) end)
		hit.MouseButton1Click:Connect(function() if feat.buildDetail then openFeatureDrawer(feat) end end)
		hit.MouseButton2Click:Connect(function() if feat.buildDetail then openFeatureDrawer(feat) end end)
	end
end

-- Pages
function buildCombat()
	buildFeaturePage(pages.Combat, "ATTACK", {
		{ name = "Silent Aim", nameKey = "t_silent", descKey = "d_silent", initial = false, getState = function() return ST.SilentAimEnabled end, onToggle = function(v) ST.SilentAimEnabled = v; updateFOVCircle() end, buildDetail = function(d)
			detailSlider(d, 1, "FOV", 20, 360, ST.SilentAimFOV, 1, function(v) ST.SilentAimFOV = v; updateFOVCircle() end)
			local parts = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" }
			local idx = 1
			for i, n in ipairs(parts) do if n == (ST.SilentAimPart or "Head") then idx = i end end
			local row = new("Frame", { Size = UDim2.new(1, -16, 0, 32), BackgroundTransparency = 1, LayoutOrder = 2, Parent = d })
			label({ Text = "Hit Part", TextSize = 12, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(70, 32), Parent = row })
			local btn = new("TextButton", { Text = parts[idx], Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, AutoButtonColor = false, Size = UDim2.new(1, -78, 1, 0), Position = UDim2.fromOffset(74, 0), BackgroundColor3 = Theme.Row, Parent = row }, { corner(6), stroke() })
			btn.MouseButton1Click:Connect(function()
				idx = (idx % #parts) + 1
				ST.SilentAimPart = parts[idx]
				btn.Text = parts[idx]
			end)
		end },
		{ name = "Hitbox Expander", initial = false, getState = function() return Hitbox_Config.Enabled end, onToggle = function(v)
			Hitbox_Config.Enabled = v
			if not v then
				for char, _ in pairs(Hitbox_Cache) do
					pcall(restoreHitbox, char, char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart"))
				end
			end
		end, buildDetail = function(d)
			detailSlider(d, 1, "Size", 1, 30, Hitbox_Config.Size or 5, 0.5, function(v) Hitbox_Config.Size = v end)
			detailSlider(d, 2, "Transparency", 0, 1, Hitbox_Config.Transparency or 0.5, 0.05, function(v) Hitbox_Config.Transparency = v end)
			detailToggle(d, 3, "Include NPCs", Hitbox_Config.IncludeNPCs == true, function(v) Hitbox_Config.IncludeNPCs = v end)
			detailToggle(d, 4, "Target filter (only selected)", ST.HitboxFilterEnabled == true, function(v)
				ST.HitboxFilterEnabled = v
				-- re-apply so list takes effect immediately
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character then
						if Hitbox_Config.Enabled then
							applyHitboxTo(p.Character)
						end
					end
				end
			end)
			-- multi-select list used when Target filter is ON
			local search = new("TextBox", {
				PlaceholderText = "search players…", PlaceholderColor3 = Theme.Dim,
				Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text,
				ClearTextOnFocus = false, Size = UDim2.new(1, -16, 0, 28),
				BackgroundColor3 = Theme.Row, LayoutOrder = 4, Parent = d
			}, { corner(6), stroke() })
			local list = new("Frame", {
				Size = UDim2.new(1, -16, 0, 160), BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.2, LayoutOrder = 5, Parent = d
			}, {
				corner(8), stroke(),
				new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
				new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
			})
			local rows = {}
			local function refreshHB()
				for _, r in pairs(rows) do if r.frame then r.frame:Destroy() end end
				table.clear(rows)
				local q = string.lower(search.Text or "")
				local arr = {}
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer then
						local n, dn = string.lower(p.Name), string.lower(p.DisplayName)
						if q == "" or string.find(n, q, 1, true) or string.find(dn, q, 1, true) then
							table.insert(arr, p)
						end
					end
				end
				table.sort(arr, function(a, b) return a.DisplayName < b.DisplayName end)
				for i, p in ipairs(arr) do
					local on = HitboxSelectedTargets[p] == true
					local row = new("Frame", {
						Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Row,
						BackgroundTransparency = 0.25, LayoutOrder = i, Parent = list
					}, { corner(6) })
					label({
						Text = p.DisplayName, Font = Enum.Font.GothamMedium, TextSize = 12,
						TextColor3 = Theme.Text, Size = UDim2.new(1, -40, 1, 0),
						Position = UDim2.fromOffset(8, 0), Parent = row
					})
					local btn = new("TextButton", {
						Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(20, 20),
						Position = UDim2.new(1, -28, 0.5, -10),
						BackgroundColor3 = on and Theme.Accent or Theme.Off, Parent = row
					}, { corner(5), stroke() })
					btn.MouseButton1Click:Connect(function()
						HitboxSelectedTargets[p] = not HitboxSelectedTargets[p]
						btn.BackgroundColor3 = HitboxSelectedTargets[p] and Theme.Accent or Theme.Off
						-- force re-evaluate
						if p.Character then
							if HitboxSelectedTargets[p] and Hitbox_Config.Enabled then
								applyHitboxTo(p.Character)
							else
								restoreHitbox(p.Character, p.Character:FindFirstChild("Head"), p.Character:FindFirstChild("HumanoidRootPart"))
							end
						end
					end)
					rows[p] = { frame = row, btn = btn }
				end
			end
			search:GetPropertyChangedSignal("Text"):Connect(refreshHB)
			local btns = new("Frame", {
				Size = UDim2.new(1, -16, 0, 28), BackgroundTransparency = 1, LayoutOrder = 6, Parent = d
			})
			local function mk(txt, x, fn)
				local b = new("TextButton", {
					Text = txt, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.Text,
					AutoButtonColor = false, Size = UDim2.new(0.32, -2, 1, 0), Position = UDim2.new(x, 0, 0, 0),
					BackgroundColor3 = Theme.Row, Parent = btns
				}, { corner(6), stroke() })
				b.MouseButton1Click:Connect(fn)
			end
			mk("All", 0, function()
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer then HitboxSelectedTargets[p] = true end
				end
				refreshHB()
			end)
			mk("None", 0.34, function()
				table.clear(HitboxSelectedTargets)
				for char, _ in pairs(Hitbox_Cache) do
					pcall(restoreHitbox, char, char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart"))
				end
				refreshHB()
			end)
			mk("Refresh", 0.68, refreshHB)
			Players.PlayerAdded:Connect(function() task.defer(refreshHB) end)
			Players.PlayerRemoving:Connect(function(p)
				HitboxSelectedTargets[p] = nil
				task.defer(refreshHB)
			end)
			refreshHB()
		end },
		{ name = "No Recoil", initial = false, getState = function() return ST.NoRecoilEnabled end, onToggle = function(v) ST.NoRecoilEnabled = v end, buildDetail = nil },
		{ name = "Firerate", initial = false, onToggle = function(v) end, buildDetail = function(d) detailSlider(d, 1, "RPS (1-30)", 1, 30, ST.SUK_FIRERATE_RPS, 1, function(v) ST.SUK_FIRERATE_RPS = v end); detailSlider(d, 2, "Fire Delay", 0.01, 0.5, ST.SUK_FireDelay, 0.01, function(v) ST.SUK_FireDelay = v end) end },
		{ name = "No Spread (Spas/Remington)", initial = false, getState = function() return ST.NoSpreadEnabled end, onToggle = function(v) ST.NoSpreadEnabled = v end, buildDetail = nil },
		{ name = "Local Invis", initial = false, getState = function() return ST.LocalInvisEnabled end, onToggle = function(v)
			if v then ST.LocalInvisEnabled = true; startLocalInvis() else stopLocalInvis() end
		end, buildDetail = nil },
		
	})
end

function buildTarget()
	local left = new("Frame", { Size = UDim2.fromOffset(300, DESIGN_H - 102), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.Panel, ClipsDescendants = true, Parent = pages.Target }, { corner(14), stroke() })
	local right = new("Frame", { Size = UDim2.new(1, -328, 1, -24), Position = UDim2.fromOffset(320, 12), BackgroundColor3 = Theme.Panel, Parent = pages.Target }, { corner(14), stroke() })
	label({ Text = "COMBAT TARGET", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 18), Position = UDim2.fromOffset(14, 12), Parent = left })
	local scroll = new("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -38), Position = UDim2.fromOffset(0, 34), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Stroke, CanvasSize = UDim2.fromOffset(0, 980), Parent = left })
	local y = 18
	toggle(scroll, y, L("t_suk"), function(v) ST.isMultiSuk = v; if not v then clearSukReloadState() end end, false, function() return ST.isMultiSuk end, L("d_suk")); y += 54
	local sukWarn = label({
		Text = L("suk_warn"),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 175, 70),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -36, 0, 44),
		Position = UDim2.fromOffset(PAD, y),
		Parent = scroll,
	})
	table.insert(UI_LangHooks, function() if sukWarn and sukWarn.Parent then sukWarn.Text = L("suk_warn") end end)
	y += 58
	slider(scroll, y, L("t_suk_rps"), 1, 30, ST.SUK_FIRERATE_RPS, 1, function(v) ST.SUK_FIRERATE_RPS = v end, function() return ST.SUK_FIRERATE_RPS end, L("d_suk_rps")); y += 58
	slider(scroll, y, L("t_suk_delay"), 0.01, 0.5, ST.SUK_FireDelay, 0.01, function(v) ST.SUK_FireDelay = v end, function() return ST.SUK_FireDelay end, L("d_suk_delay")); y += 58
	slider(scroll, y, L("t_suk_targets"), 1, 16, ST.SUK_MaxPerTick, 1, function(v) ST.SUK_MaxPerTick = v end, function() return ST.SUK_MaxPerTick end, L("d_suk_targets")); y += 58
	toggle(scroll, y, L("t_heal"), function(v) ST.HealEnabled = v; if v then StartHealLoop() else StopHealLoop() end end, false, function() return ST.HealEnabled end, L("d_heal")); y += 54
	slider(scroll, y, L("t_heal_h"), -5, 10, ST.HealFlyHeight or 3.5, 0.5, function(v) ST.HealFlyHeight = v end, function() return ST.HealFlyHeight end, L("d_heal_h")); y += 58
	toggle(scroll, y, L("t_ignore_friends"), function(v) ST.SUK_IgnoreFriends = v end, true, function() return ST.SUK_IgnoreFriends end, L("d_ignore_friends")); y += 54
	toggle(scroll, y, L("t_target_npcs"), function(v) ST.SUK_TargetNPCs = v end, false, function() return ST.SUK_TargetNPCs end, L("d_target_npcs")); y += 54
	toggle(scroll, y, L("t_equip"), function(v) ST.SUK_EquipRequired = v end, ST.SUK_EquipRequired, function() return ST.SUK_EquipRequired end, L("d_equip"))

	label({ Text = "PLAYERS", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(120, 18), Position = UDim2.fromOffset(14, 12), Parent = right })
	local searchBox = new("Frame", { Size = UDim2.new(1, -24, 0, 34), Position = UDim2.fromOffset(12, 36), BackgroundColor3 = Theme.Row, Parent = right }, { corner(10), stroke() })
	local search = new("TextBox", { PlaceholderText = "Search...", PlaceholderColor3 = Theme.Dim, Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(10, 0), Parent = searchBox })
	-- bulk actions
	local actBar = new("Frame", { Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 76), BackgroundTransparency = 1, Parent = right })
	local function smallBtn(text, x, w, cb)
		local b = new("TextButton", { Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.Text, AutoButtonColor = false, Size = UDim2.fromOffset(w, 28), Position = UDim2.fromOffset(x, 0), BackgroundColor3 = Theme.Row, Parent = actBar }, { corner(8), stroke() })
		b.MouseButton1Click:Connect(cb)
		return b
	end
	local list = new("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -118), Position = UDim2.fromOffset(8, 112), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = right }, { new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }), new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }) })
	local rows = {}
	local function refreshList()
		for _, r in pairs(rows) do if r.frame then r.frame:Destroy() end end
		table.clear(rows); local q = string.lower(search.Text or ""); local arr = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then local n, d = string.lower(p.Name), string.lower(p.DisplayName); if q == "" or string.find(n, q, 1, true) or string.find(d, q, 1, true) then table.insert(arr, p) end end
		end
		table.sort(arr, function(a, b) return a.DisplayName < b.DisplayName end)
		for i, p in ipairs(arr) do
			local on = SelectedTargets[p] == true
			local isFr = FriendsList[p.UserId] == true
			local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Row, BackgroundTransparency = 0.25, LayoutOrder = i, Parent = list }, { corner(8) })
			label({ Text = (isFr and "★ " or "") .. p.DisplayName, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = isFr and Color3.fromRGB(85, 255, 127) or Theme.Text, Size = UDim2.new(1, -100, 0, 18), Position = UDim2.fromOffset(12, 3), Parent = row })
			label({ Text = "@" .. p.Name, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.new(1, -100, 0, 14), Position = UDim2.fromOffset(12, 20), Parent = row })
			local friendBtn = new("TextButton", { Text = isFr and "Unfr" or "Friend", Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Theme.Text, AutoButtonColor = false, Size = UDim2.fromOffset(48, 22), Position = UDim2.new(1, -86, 0.5, -11), BackgroundColor3 = isFr and Color3.fromRGB(40, 90, 50) or Theme.Off, Parent = row }, { corner(6), stroke() })
			friendBtn.MouseButton1Click:Connect(function()
				if FriendsList[p.UserId] then FriendsList[p.UserId] = nil else FriendsList[p.UserId] = true end
				refreshList()
				if RefreshFriendsUI then pcall(RefreshFriendsUI) end
			end)
			local btn = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -34, 0.5, -11), BackgroundColor3 = on and Theme.Accent or Theme.Off, Parent = row }, { corner(6), stroke() })
			btn.MouseButton1Click:Connect(function() SelectedTargets[p] = not SelectedTargets[p]; btn.BackgroundColor3 = SelectedTargets[p] and Theme.Accent or Theme.Off end)
			rows[p] = { frame = row, btn = btn }
		end
	end
	smallBtn("Select All", 0, 78, function()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				if not (ST.SUK_IgnoreFriends and FriendsList[p.UserId]) then
					SelectedTargets[p] = true
				end
			end
		end
		refreshList()
	end)
	smallBtn("Clear", 84, 56, function()
		table.clear(SelectedTargets)
		refreshList()
	end)
	smallBtn("Friends Only", 146, 90, function()
		table.clear(SelectedTargets)
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and FriendsList[p.UserId] then SelectedTargets[p] = true end
		end
		refreshList()
	end)
	search:GetPropertyChangedSignal("Text"):Connect(refreshList); Players.PlayerAdded:Connect(function() task.defer(refreshList) end); Players.PlayerRemoving:Connect(function(p) SelectedTargets[p] = nil; task.defer(refreshList) end); refreshList()
end

function buildKeybinds()
	local panel = new("Frame", { Size = UDim2.new(1, -24, 1, -24), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.Panel, Parent = pages.Keybinds }, { corner(12), stroke() })
	label({ Text = "KEYBINDS", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 20), Position = UDim2.fromOffset(14, 12), Parent = panel })
	local list = new("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -44), Position = UDim2.fromOffset(8, 36), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = panel }, { new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }), new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }) })
	local bindRows = {
		{ "Menu", "Menu" }, { "SUK", "SUK" }, { "No Recoil", "NoRecoil" }, { "Anti-CC", "AntiCC" },
		{ "ESP", "ESP" }, { "Hitbox", "Hitbox" }, { "Fly", "Fly" }, { "Walk Speed", "WalkSpeed" }, { "Jump Power", "JumpPower" },
		{ "Heal", "Heal" }, { "Silent Aim", "SilentAim" }, { "China Hat", "ChinaHat" }, { "Wings", "Wings" }, { "Anti-Lag", "AntiLag" }, { "Spin", "Spin" },
        { "Teleport Heal", "TeleportHeal" }, { "Teleport Cursor", "TeleportCursor" }, { "Combo", "Combo" }, { "Reload Spas", "ReloadSpas" }
	}
	for i, item in ipairs(bindRows) do
		local title, keyName = item[1], item[2]
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Row, BackgroundTransparency = 0.25, LayoutOrder = i, Parent = list }, { corner(6) })
		label({ Text = title, Font = Enum.Font.Gotham, TextSize = 14, Size = UDim2.new(1, -120, 1, 0), Position = UDim2.fromOffset(12, 0), Parent = row })
		local cur = Keys[keyName]
		local btn = new("TextButton", { Text = (cur and cur ~= Enum.KeyCode.Unknown) and cur.Name or "None", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, AutoButtonColor = false, Size = UDim2.fromOffset(100, 24), Position = UDim2.new(1, -110, 0.5, -12), BackgroundColor3 = Theme.Off, Parent = row }, { corner(6), stroke() })
		btn.MouseButton1Click:Connect(function() btn.Text = "..."; ST.isBinding = true; bindTarget = { btn = btn, keyName = keyName } end)
		UI_BindLabels[keyName] = btn
	end
end

function refreshAllBindLabels()
	for keyName, btn in pairs(UI_BindLabels) do
		if btn and btn.Parent then
			local cur = Keys[keyName]
			if typeof(cur) == "EnumItem" and cur ~= Enum.KeyCode.Unknown then
				btn.Text = cur.Name
			else
				btn.Text = "None"
			end
		end
	end
end

function buildVR()
	local scroll = new("ScrollingFrame", { Size = UDim2.new(1, -24, 1, -24), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 1100), Parent = pages.VR }, { corner(12), stroke() })
	
	label({ Text = "VR CONTROL (PC ONLY)", Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(300, 24), Position = UDim2.fromOffset(PAD, 20), Parent = scroll })
	divider(scroll, 55)
	local y = 80
	do
		local setSw = toggle(scroll, y, "Enable VR Mode", function(v)
			setVREnabled(v, true)
		end, ST.VREnabled == true, function() return ST.VREnabled == true end)
		VRToggleSetUI = function(on)
			pcall(function() setSw(on and true or false, false) end)
		end
	end
	y = y + 48
	label({
		Text = "Tip: hold RMB while turning VR off to restore camera",
		TextSize = 11,
		TextColor3 = Theme.Dim,
		TextWrapped = true,
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.fromOffset(12, y),
		Parent = scroll,
	})
	y = y + 32
	toggle(scroll, y, "VR Target Mode", function(v) ST.VRTargetEnabled = v end, false)
	y = y + 48
	toggle(scroll, y, "Enable Hand Shake", function(v) ST.VRShakeEnabled = v end, false)
	y = y + 52
	slider(scroll, y, "Shake Intensity", 0, 2, ST.VRShakeIntensity, 0.1, function(v) ST.VRShakeIntensity = v end)
	y = y + 55
	slider(scroll, y, "Hand Extend forward (studs)", 0, 10, ST.VRHandExtend or 1.2, 0.25, function(v) ST.VRHandExtend = v end)
	y = y + 55
	slider(scroll, y, "Hand Height", -1, 2, ST.VRHandHeight or 0.2, 0.05, function(v) ST.VRHandHeight = v end)
	y = y + 55
	slider(scroll, y, "Hand Width (gap)", 0.3, 2.5, ST.VRHandWidth or 1.05, 0.05, function(v) ST.VRHandWidth = v end)
	y = y + 55
	slider(scroll, y, "Swing Reach (удар, дальность)", 0.5, 8, ST.VRSwingReach or 2.5, 0.1, function(v) ST.VRSwingReach = v; ST.VRSwingAmp = v end)
	y = y + 55
	slider(scroll, y, "Swing Speed", 6, 24, ST.VRSwingSpeed or 14, 1, function(v) ST.VRSwingSpeed = v end)
	y = y + 50
	-- swing bind button
	label({ Text = "Swing Bind", TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(120, 24), Position = UDim2.fromOffset(PAD, y - 12), Parent = scroll })
	local swingBindBtn = new("TextButton", {
		Text = "LMB (MouseButton1)",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(160, 28),
		Position = UDim2.new(1, -PAD - 160, 0, y - 14),
		BackgroundColor3 = Theme.Row,
		Parent = scroll,
	}, { corner(8), stroke() })
	local listeningSwing = false
	swingBindBtn.MouseButton1Click:Connect(function()
		if listeningSwing then return end
		listeningSwing = true
		swingBindBtn.Text = "Press key/mouse..."
		local conn
		conn = UIS.InputBegan:Connect(function(input, gp)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3 then
				Keys.VRSwing = input.UserInputType
				swingBindBtn.Text = input.UserInputType.Name
				listeningSwing = false
				conn:Disconnect()
			elseif input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
				Keys.VRSwing = input.KeyCode
				swingBindBtn.Text = input.KeyCode.Name
				listeningSwing = false
				conn:Disconnect()
			end
		end)
	end)
	y = y + 48
	divider(scroll, y)
	y = y + 20
	label({ Text = "VR TARGETS", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 16), Position = UDim2.fromOffset(PAD, y), Parent = scroll })
	y = y + 25
	
	local vrList = new("ScrollingFrame", { Size = UDim2.new(1, -40, 0, 150), Position = UDim2.fromOffset(PAD, y), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = scroll }, { new("UIListLayout", { Padding = UDim.new(0, 4) }) })
	y = y + 160
	local vrRows = {}
	local function refreshVRList()
		for _, r in pairs(vrRows) do if r.frame then r.frame:Destroy() end end
		table.clear(vrRows)
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				local on = VRSelectedTargets[p] == true
				local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Row, Parent = vrList }, { corner(6) })
				label({ Text = p.DisplayName, TextSize = 13, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(10, 0), Parent = row })
				local btn = new("TextButton", { Text = "", Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -25, 0.5, -10), BackgroundColor3 = on and Theme.Accent or Theme.Off, Parent = row }, { corner(5), stroke() })
				btn.MouseButton1Click:Connect(function() VRSelectedTargets[p] = not VRSelectedTargets[p]; btn.BackgroundColor3 = VRSelectedTargets[p] and Theme.Accent or Theme.Off end)
				vrRows[p] = { frame = row }
			end
		end
	end
	refreshVRList()
	Players.PlayerAdded:Connect(function() task.defer(refreshVRList) end); Players.PlayerRemoving:Connect(function(p) VRSelectedTargets[p] = nil; task.defer(refreshVRList) end)

	y = y + 20
	divider(scroll, y)
	y = y + 24
	label({ Text = "VR AURA", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 16), Position = UDim2.fromOffset(PAD, y), Parent = scroll })
	y = y + 28
	y = y + 50
	y = y + 55
	y = y + 55
end

function buildProfile()
	local panel = new("Frame", { Size = UDim2.fromOffset(350, DESIGN_H - 102), Position = UDim2.fromOffset(20, 20), BackgroundColor3 = Theme.Panel, Parent = pages.Profile }, { corner(16), stroke() })
	local title = label({ Text = L("profile_title"), Font = Enum.Font.GothamMedium, TextSize = 20, Size = UDim2.fromOffset(250, 30), Position = UDim2.fromOffset(PAD, 20), Parent = panel })
	divider(panel, 61)
	local avatar = new("ImageLabel", { Size = UDim2.fromOffset(80, 80), Position = UDim2.fromOffset(PAD, 80), BackgroundColor3 = Theme.Row, Parent = panel }, { round(), stroke() })
	task.spawn(function() local ok, img = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420); if ok then avatar.Image = img end end)
	label({ Text = LocalPlayer.DisplayName, Font = Enum.Font.GothamBold, TextSize = 22, Size = UDim2.fromOffset(200, 30), Position = UDim2.fromOffset(PAD + 100, 85), Parent = panel })
	label({ Text = "@" .. LocalPlayer.Name, TextSize = 15, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 20), Position = UDim2.fromOffset(PAD + 100, 115), Parent = panel })
	local roleLbl = label({ Text = L("profile_ops"), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Accent, Size = UDim2.fromOffset(200, 18), Position = UDim2.fromOffset(PAD + 100, 138), Parent = panel })
	divider(panel, 180)

	local statsTitle = label({ Text = L("profile_stats"), Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(220, 22), Position = UDim2.fromOffset(PAD, 195), Parent = panel })

	local function row(titleKey, y)
		local t = label({ Text = L(titleKey), TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(110, 18), Position = UDim2.fromOffset(PAD, y), Parent = panel })
		local v = label({ Text = "—", Font = Enum.Font.GothamMedium, TextSize = 13, Size = UDim2.fromOffset(200, 18), Position = UDim2.fromOffset(PAD + 120, y), Parent = panel })
		return t, v
	end
	local tBuild, vBuild = row("profile_build", 225)
	vBuild.Text = "v11.83-be"
	local tSess, vSess = row("profile_session", 250)
	local tStat, vStat = row("profile_status", 275)
	vStat.Text = L("profile_active")
	vStat.TextColor3 = Color3.fromRGB(90, 220, 140)
	local tPing, vPing = row("profile_ping", 300)
	local tFps, vFps = row("profile_fps", 325)
	local tFeat, vFeat = row("profile_feat", 350)
	local tUid, vUid = row("profile_uid", 375)
	vUid.Text = tostring(LocalPlayer.UserId)
	local tSrv, vSrv = row("profile_server", 400)
	pcall(function() vSrv.Text = tostring(game.JobId):sub(1, 12) .. "…" end)

	divider(panel, 430)
	local tipTitle = label({ Text = L("profile_tip"), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(120, 18), Position = UDim2.fromOffset(PAD, 445), Parent = panel })
	local tipBody = label({
		Text = L("profile_tip_body"),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Text,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -PAD * 2, 0, 70),
		Position = UDim2.fromOffset(PAD, 468),
		Parent = panel,
	})

	table.insert(UI_LangHooks, function()
		if title and title.Parent then title.Text = L("profile_title") end
		if roleLbl and roleLbl.Parent then roleLbl.Text = L("profile_ops") end
		if statsTitle and statsTitle.Parent then statsTitle.Text = L("profile_stats") end
		if tBuild then tBuild.Text = L("profile_build") end
		if tSess then tSess.Text = L("profile_session") end
		if tStat then tStat.Text = L("profile_status") end
		if vStat then vStat.Text = L("profile_active") end
		if tPing then tPing.Text = L("profile_ping") end
		if tFps then tFps.Text = L("profile_fps") end
		if tFeat then tFeat.Text = L("profile_feat") end
		if tUid then tUid.Text = L("profile_uid") end
		if tSrv then tSrv.Text = L("profile_server") end
		if tipTitle then tipTitle.Text = L("profile_tip") end
		if tipBody then tipBody.Text = L("profile_tip_body") end
	end)

	task.spawn(function()
		while panel.Parent and not ST.isUnloaded do
			local e = os.clock() - (SessionStartTime or os.clock())
			vSess.Text = string.format("%02d:%02d:%02d", math.floor(e / 3600), math.floor(e / 60) % 60, math.floor(e) % 60)
			local ping = 0
			pcall(function()
				ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
			end)
			vPing.Text = tostring(ping) .. " ms"
			local fps = 0
			pcall(function()
				fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))
			end)
			-- crude fps from last wait is noisy; use Stats if present
			pcall(function()
				local s = game:GetService("Stats")
				local item = s and s:FindFirstChild("PerformanceStats")
				-- fallback keep previous style
			end)
			vFps.Text = tostring(math.clamp(fps, 1, 240))
			local n = 0
			if ST.isMultiSuk then n += 1 end
			if ST.VREnabled then n += 1 end
			if ST.LocalInvisEnabled then n += 1 end
			if ESP_Config and ESP_Config.Enabled then n += 1 end
			if ST.TracersEnabled then n += 1 end
			if ST.HealEnabled then n += 1 end
			vFeat.Text = tostring(n) .. " on"
			task.wait(1)
		end
	end)
end

function makeColorSlider(parent, y, labelText, value01, onChange)
	label({ Text = labelText, TextSize = 12, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(18, 16), Position = UDim2.fromOffset(70, y), Parent = parent })
	local track = new("Frame", { Size = UDim2.fromOffset(220, 8), Position = UDim2.fromOffset(92, y + 4), BackgroundColor3 = Theme.Off, BorderSizePixel = 0, Parent = parent }, { corner(4) })
	local fill = new("Frame", { Size = UDim2.fromScale(math.clamp(value01, 0, 1), 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = track }, { corner(4) })
	local hit = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5), Parent = track })
	local dragging = false
	local function applyFromX(x) local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1); fill.Size = UDim2.fromScale(a, 1); fill.BackgroundColor3 = Theme.Accent; onChange(a, fill) end
	hit.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; applyFromX(input.Position.X) end end)
	UIS.InputChanged:Connect(function(input) if not dragging then return end; if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then applyFromX(input.Position.X) end end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
	subscribeTheme(function() fill.BackgroundColor3 = Theme.Accent end)
	return fill
end

local rebuildMenuGrid -- forward (defined later)
function buildSettings()
    local left = new("Frame", { Size = UDim2.new(0.45, -10, 1, -24), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.Panel, Parent = pages.Settings }, { corner(14), stroke() })
	local right = new("Frame", { Size = UDim2.new(0.55, -14, 1, -24), Position = UDim2.new(0.45, 10, 0, 12), BackgroundColor3 = Theme.Panel, Parent = pages.Settings }, { corner(14), stroke() })

    label({ Text = "INTERFACE", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 18), Position = UDim2.fromOffset(14, 12), Parent = left })
    local leftScroll = new("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -38), Position = UDim2.fromOffset(0, 34), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, Parent = left })
    
    local y = 18
	-- Language
	local langLbl = label({ Text = L("lang"), TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(120, 18), Position = UDim2.fromOffset(PAD, y), Parent = leftScroll })
	local langBtn = new("TextButton", {
		Text = (ST.Language == "ru") and "Русский" or "English",
		Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
		AutoButtonColor = false, Size = UDim2.new(1, -PAD * 2 - 100, 0, 28),
		Position = UDim2.fromOffset(PAD + 100, y - 4),
		BackgroundColor3 = Theme.Row, Parent = leftScroll,
	}, { corner(8), stroke() })
	langBtn.MouseButton1Click:Connect(function()
		ST.Language = (ST.Language == "ru") and "en" or "ru"
		langBtn.Text = (ST.Language == "en") and "English" or "Русский"
		langLbl.Text = L("lang")
		refreshLanguage()
	end)
	table.insert(UI_LangHooks, function()
		if langLbl and langLbl.Parent then langLbl.Text = L("lang") end
		if langBtn and langBtn.Parent then langBtn.Text = (ST.Language == "en") and "English" or "Русский" end
	end)
	y += 44
	-- Menu grid (spaced so nothing overlaps)
	toggle(leftScroll, y, L("t_grid"), function(v)
		ST.MenuGridEnabled = v
		if rebuildMenuGrid then pcall(rebuildMenuGrid) end
	end, false, function() return ST.MenuGridEnabled end, L("d_grid"))
	y += 54
	label({ Text = "BG Style", TextSize = 13, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(140, 18), Position = UDim2.fromOffset(PAD, y), Parent = leftScroll })
	local styleBtn = new("TextButton", {
		Text = tostring(ST.MenuBgStyle or "chess"), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
		AutoButtonColor = false, Size = UDim2.new(1, -PAD * 2 - 150, 0, 28),
		Position = UDim2.fromOffset(PAD + 150, y - 4), BackgroundColor3 = Theme.Row, Parent = leftScroll,
	}, { corner(8), stroke() })
	local styles = { "chess", "grid", "waves" }
	styleBtn.MouseButton1Click:Connect(function()
		local cur = ST.MenuBgStyle or "chess"
		local idx = 1
		for i, s in ipairs(styles) do if s == cur then idx = i break end end
		ST.MenuBgStyle = styles[(idx % #styles) + 1]
		styleBtn.Text = ST.MenuBgStyle
		if rebuildMenuGrid then pcall(rebuildMenuGrid) end
	end)
	y += 44
	slider(leftScroll, y, "Grid Speed", 0.1, 5, ST.MenuGridSpeed or 1, 0.1, function(v) ST.MenuGridSpeed = v end, function() return ST.MenuGridSpeed or 1 end)
	y += 58
	slider(leftScroll, y, "Grid Transparency", 0.3, 0.98, ST.MenuGridTransparency or 0.85, 0.02, function(v) ST.MenuGridTransparency = v end, function() return ST.MenuGridTransparency or 0.85 end)
	y += 58
	slider(leftScroll, y, "Grid Rotation", 0, 45, ST.MenuGridRotation or 0, 1, function(v)
		ST.MenuGridRotation = v
		if rebuildMenuGrid and ST.MenuGridEnabled then pcall(rebuildMenuGrid) end
	end, function() return ST.MenuGridRotation or 0 end)
	y += 58
	label({ Text = "Accent HSV", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 18), Position = UDim2.fromOffset(PAD, y), Parent = leftScroll })
	y += 22
	local accentPrev = new("Frame", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -PAD - 28, 0, y - 2),
		BackgroundColor3 = Theme.Accent, Parent = leftScroll
	}, { corner(6), stroke() })
	slider(leftScroll, y, "H", 0, 360, ST.AccentH or 220, 1, function(v)
		ST.AccentH = v; accentPrev.BackgroundColor3 = accentFromHSV()
	end, function() return ST.AccentH or 220 end)
	y += 52
	slider(leftScroll, y, "S", 0, 1, ST.AccentS or 0.78, 0.01, function(v)
		ST.AccentS = v; accentPrev.BackgroundColor3 = accentFromHSV()
	end, function() return ST.AccentS or 0.78 end)
	y += 52
	slider(leftScroll, y, "V", 0, 1, ST.AccentV or 1, 0.01, function(v)
		ST.AccentV = v; accentPrev.BackgroundColor3 = accentFromHSV()
	end, function() return ST.AccentV or 1 end)
	y += 56
	toggle(leftScroll, y, L("t_wm"), function(v) ST.WatermarkMainVisible = v; if watermarkMain then watermarkMain.Visible = v end end, true, function() return ST.WatermarkMainVisible end, L("d_wm")); y += 48
	toggle(leftScroll, y, L("t_wm_binds"), function(v) ST.WatermarkBindsVisible = v; watermarkBinds.Visible = v end, true, function() return ST.WatermarkBindsVisible end, L("d_wm_binds")); y += 48
	toggle(leftScroll, y, L("t_wm_world"), function(v) ST.WatermarkWorldVisible = v; watermarkWorld.Visible = v end, true, function() return ST.WatermarkWorldVisible end, L("d_wm_world")); y += 54
	toggle(leftScroll, y, L("t_wm_ammo"), function(v) ST.WatermarkAmmoVisible = v; if ammoLbl then ammoLbl.Visible = v end end, true, function() return ST.WatermarkAmmoVisible end, L("d_wm_ammo")); y += 54
	
	local animLbl = label({ Text = "UI Animation: " .. tostring(AnimName), TextSize = 13, Size = UDim2.new(1, -40, 0, 20), Position = UDim2.fromOffset(PAD, y), Parent = leftScroll }); y += 25
	local animBtn = new("TextButton", { Text = "Cycle preset", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, Size = UDim2.fromOffset(120, 28), Position = UDim2.fromOffset(PAD, y), BackgroundColor3 = Theme.Row, AutoButtonColor = false, Parent = leftScroll }, { corner(8), stroke() }); y += 48
	local animIdx = 1
    for i, n in ipairs(AnimOrder or {}) do 
        if n == AnimName then animIdx = i end 
    end
	animBtn.MouseButton1Click:Connect(function() 
        animIdx = (animIdx % #AnimOrder) + 1
        AnimName = AnimOrder[animIdx]
        animLbl.Text = "UI Animation: " .. AnimName 
    end)

	label({ Text = "ACCENT / SOLID COLOR", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(240, 18), Position = UDim2.fromOffset(16, y), Parent = leftScroll }); y += 30
	local accentPrev = new("Frame", { Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(PAD, y), BackgroundColor3 = Theme.Accent, Parent = leftScroll }, { corner(8), stroke() }); y += 5
	local ar, ag, ab = Theme.Accent.R, Theme.Accent.G, Theme.Accent.B
	local function pushAccent() 
        Theme.Accent = Color3.new(ar, ag, ab)
        Theme.OnTrack = Theme.Accent
        accentPrev.BackgroundColor3 = Theme.Accent
        fireTheme() 
    end
	makeColorSlider(leftScroll, y, "R", ar, function(v, fill) ar = v; pushAccent(); if fill then fill.BackgroundColor3 = Theme.Accent end end); y += 25
	makeColorSlider(leftScroll, y, "G", ag, function(v, fill) ag = v; pushAccent(); if fill then fill.BackgroundColor3 = Theme.Accent end end); y += 25
	makeColorSlider(leftScroll, y, "B", ab, function(v, fill) ab = v; pushAccent(); if fill then fill.BackgroundColor3 = Theme.Accent end end); y += 40

	label({ Text = "CHINA HAT COLOR", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(240, 18), Position = UDim2.fromOffset(16, y), Parent = leftScroll }); y += 28
	local hatC = Cosmetics.getHatColor and Cosmetics.getHatColor() or Color3.fromRGB(255, 220, 40)
	local hr, hg, hb = hatC.R, hatC.G, hatC.B
	local hatPrev = new("Frame", { Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(PAD, y), BackgroundColor3 = hatC, Parent = leftScroll }, { corner(8), stroke() }); y += 5
	local function pushHat()
		local c = Color3.new(hr, hg, hb)
		hatPrev.BackgroundColor3 = c
		pcall(function() Cosmetics.setHatColor(c) end)
	end
	makeColorSlider(leftScroll, y, "R", hr, function(v, fill) hr = v; pushHat(); if fill then fill.BackgroundColor3 = Color3.new(hr,0,0) end end); y += 25
	makeColorSlider(leftScroll, y, "G", hg, function(v, fill) hg = v; pushHat(); if fill then fill.BackgroundColor3 = Color3.new(0,hg,0) end end); y += 25
	makeColorSlider(leftScroll, y, "B", hb, function(v, fill) hb = v; pushHat(); if fill then fill.BackgroundColor3 = Color3.new(0,0,hb) end end); y += 40

    leftScroll.CanvasSize = UDim2.fromOffset(0, 1100)
	y += 20
	local rejoinBtn = new("TextButton", { Text = "Rejoin", Size = UDim2.new(1, -40, 0, 40), Position = UDim2.fromOffset(20, y), BackgroundColor3 = Theme.Row, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text, AutoButtonColor = false, Parent = leftScroll }, { corner(10), stroke() })
	rejoinBtn.MouseButton1Click:Connect(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
	y += 52
	local unhookBtn = new("TextButton", { Text = "UnHook / Unload", Size = UDim2.new(1, -40, 0, 40), Position = UDim2.fromOffset(20, y), BackgroundColor3 = Theme.Row, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Color3.fromRGB(255, 95, 110), AutoButtonColor = false, Parent = leftScroll }, { corner(10), stroke(Color3.fromRGB(255, 95, 110), 1.2) })
	y += 56
	leftScroll.CanvasSize = UDim2.fromOffset(0, math.max(y + 40, 900))
	unhookBtn.MouseButton1Click:Connect(function()
		ST.isUnloaded = true
		ST.VREnabled = false
		ST.isMultiSuk = false
		ST.SilentAimEnabled = false
		for k, _ in pairs(Keys) do Keys[k] = Enum.KeyCode.Unknown end
		VRWantEnabled = false
		ST.TracersEnabled = false
		ST.LocalInvisEnabled = false
		ESP_Config.Enabled = false
		Hitbox_Config.Enabled = false
		-- FULL session kill so spec-loader can boot again
		pcall(function()
			local function wipe(g)
				if type(g) ~= "table" then return end
				g.CLL_SESSION_ACTIVE = nil
				g.CLL_LOADED_BY_LOADER = nil
				g.CLL_LOADED_FROM_LOADER = nil
				g.CLL_BOOT_TOKEN = nil
				g.CLL_FROM_LOADER = nil
				g.CLL_Auth = nil
				g.CLL_SESSION = nil
				g.CLL_ANTIBYPASS = nil
				g.CLL_VR_SPAWN_GRACE = nil
			end
			wipe(_G)
			if getgenv then wipe(getgenv()) end
			if shared then wipe(shared) end
		end)
		pcall(function() RunService:UnbindFromRenderStep("CLL_VR") end)
		pcall(function() RunService:UnbindFromRenderStep("CLL_AntiShake") end)
		pcall(vrShutdown)
		pcall(stopLocalInvis)
		pcall(stopWeather)
		pcall(function() Cosmetics.setHat(false) end)
		pcall(function() Cosmetics.setWings(false) end)
		pcall(StopHealLoop)
		for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
		table.clear(Connections)
		if flyVelocity then pcall(function() flyVelocity:Destroy() end); flyVelocity = nil end
		if flyGyro then pcall(function() flyGyro:Destroy() end); flyGyro = nil end
		if spinAngular then pcall(function() spinAngular:Destroy() end); spinAngular = nil end
		if wingConn then pcall(function() wingConn:Disconnect() end); wingConn = nil end
		-- restore all hitboxes
		for char, _ in pairs(Hitbox_Cache) do
			pcall(function()
				restoreHitbox(char, char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart"))
			end)
		end
		-- destroy ALL CLL visuals / guis
		pcall(function() if trueAimGui then trueAimGui:Destroy() end end)
		pcall(function() if realCrossGui then realCrossGui:Destroy() end end)
		pcall(function() if ESPGui then ESPGui:Destroy() end end)
		pcall(function() if tracerFolder then tracerFolder:Destroy() end end)
		pcall(function() if ammoGui then ammoGui:Destroy() end end)
		pcall(function() if ammoLbl then ammoLbl:Destroy() end end)
		pcall(function() if menuGridConn then menuGridConn:Disconnect() end end)
pcall(function() if menuGridFolder then menuGridFolder:Destroy() end end)
pcall(function() if watermarkMain then watermarkMain:Destroy() end end)
		pcall(function() if watermarkWorld then watermarkWorld:Destroy() end end)
		pcall(function() if watermarkBinds then watermarkBinds:Destroy() end end)
		pcall(function()
			local pg = LocalPlayer:FindFirstChild("PlayerGui")
			if pg then
				for _, g in ipairs(pg:GetChildren()) do
					if g.Name:find("CLL") then g:Destroy() end
				end
			end
		end)
		pcall(function()
			local hui = gethui and gethui()
			if hui then
				for _, g in ipairs(hui:GetChildren()) do
					if g.Name:find("CLL") then g:Destroy() end
				end
			end
		end)
		pcall(function()
			local cg = game:GetService("CoreGui")
			for _, g in ipairs(cg:GetChildren()) do
				if g.Name:find("CLL") then g:Destroy() end
			end
		end)
		pcall(function() RunService:UnbindFromRenderStep("CLL_VR") end)
		pcall(function()
			local cam = workspace.CurrentCamera
			if cam then
				for _, c in ipairs(cam:GetChildren()) do
					if c.Name:find("Wing") or c.Name:find("China") or c.Name:find("CLL") then c:Destroy() end
				end
			end
		end)
		pcall(function()
			RunService:UnbindFromRenderStep("CLL_AntiShake")
		end)
		if oldNamecall then pcall(function() hookmetamethod(game, "__namecall", oldNamecall) end) end
		pcall(function() gui:Destroy() end)
	end)

    label({ Text = "FRIENDS & CONFIG", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.Dim, Size = UDim2.fromOffset(200, 18), Position = UDim2.fromOffset(14, 12), Parent = right })
    local rScroll = new("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -44), Position = UDim2.fromOffset(8, 36), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, Parent = right })
    
    local rY = 0
    label({ Text = "FRIENDS", TextSize = 12, TextColor3 = Theme.Dim, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, rY), Parent = rScroll }); rY += 25
	local friendBox = new("TextBox", { PlaceholderText = "Player name...", PlaceholderColor3 = Theme.Dim, Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text, Size = UDim2.new(1, -100, 0, 32), Position = UDim2.fromOffset(0, rY), BackgroundColor3 = Theme.Row, Parent = rScroll }, { corner(8), stroke() })
	local addFriend = new("TextButton", { Text = "Add", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, Size = UDim2.fromOffset(90, 32), Position = UDim2.new(1, -90, 0, rY), BackgroundColor3 = Theme.Row, AutoButtonColor = false, Parent = rScroll }, { corner(8), stroke() })
    rY += 40
	
	-- fixed-height list that scrolls internally so rows never cover CONFIG below
	local friendList = Instance.new("ScrollingFrame")
	friendList.Name = "CLL_FriendList"
	friendList.Size = UDim2.new(1, 0, 0, 120)
	friendList.Position = UDim2.fromOffset(0, rY)
	friendList.BackgroundTransparency = 1
	friendList.BorderSizePixel = 0
	friendList.ScrollBarThickness = 5
	friendList.ScrollingDirection = Enum.ScrollingDirection.Y
	friendList.CanvasSize = UDim2.new(0, 0, 0, 0)
	friendList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	friendList.ClipsDescendants = true
	friendList.ZIndex = 2
	friendList.Parent = rScroll
	local flLayout = Instance.new("UIListLayout")
	flLayout.Padding = UDim.new(0, 4)
	flLayout.SortOrder = Enum.SortOrder.LayoutOrder
	flLayout.Parent = friendList
	rY += 130
	local function refreshFriends()
		for _, v in ipairs(friendList:GetChildren()) do
			if v:IsA("Frame") then v:Destroy() end
		end
		local n = 0
		for id, stored in pairs(FriendsList) do
			n += 1
			local pl = Players:GetPlayerByUserId(id)
			local name = pl and (pl.DisplayName .. "  @" .. pl.Name)
				or (type(stored) == "string" and stored)
				or ("ID: " .. tostring(id))
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -8, 0, 30)
			row.BackgroundColor3 = Theme.Row
			row.BorderSizePixel = 0
			row.LayoutOrder = n
			row.Parent = friendList
			pcall(function()
				local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = row
			end)
			local lab = Instance.new("TextLabel")
			lab.BackgroundTransparency = 1
			lab.Text = name
			lab.Font = Enum.Font.Gotham
			lab.TextSize = 13
			lab.TextColor3 = Theme.Text
			lab.TextXAlignment = Enum.TextXAlignment.Left
			lab.TextTruncate = Enum.TextTruncate.AtEnd
			lab.Size = UDim2.new(1, -40, 1, 0)
			lab.Position = UDim2.fromOffset(10, 0)
			lab.Parent = row
			local btn = Instance.new("TextButton")
			btn.Text = "X"
			btn.Size = UDim2.fromOffset(22, 22)
			btn.Position = UDim2.new(1, -28, 0.5, -11)
			btn.BackgroundTransparency = 1
			btn.TextColor3 = Color3.fromRGB(255, 80, 80)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 14
			btn.Parent = row
			btn.MouseButton1Click:Connect(function()
				FriendsList[id] = nil
				refreshFriends()
			end)
		end
		pcall(function()
			rScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(rY + 80, 400))
		end)
	end
	RefreshFriendsUI = refreshFriends
	addFriend.MouseButton1Click:Connect(function()
		local text = friendBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
		if text == "" then return end
		local plr = Players:FindFirstChild(text)
		if not plr then
			for _, x in ipairs(Players:GetPlayers()) do
				if x.Name:lower() == text:lower() or x.DisplayName:lower() == text:lower() then
					plr = x; break
				end
			end
		end
		if plr and plr ~= LocalPlayer then
			FriendsList[plr.UserId] = plr.DisplayName .. " (@" .. plr.Name .. ")"
			friendBox.Text = ""
			refreshFriends()
			if CLL_Notify then CLL_Notify("Friend added", FriendsList[plr.UserId]) end
			return
		end
		-- offline resolve
		task.spawn(function()
			local ok, uid = pcall(function()
				return Players:GetUserIdFromNameAsync(text)
			end)
			if ok and type(uid) == "number" and uid > 1000 then
				local ok2, name = pcall(function()
					return Players:GetNameFromUserIdAsync(uid)
				end)
				FriendsList[uid] = (ok2 and name and (name .. " (#" .. uid .. ")")) or ("@" .. text)
				friendBox.Text = ""
				refreshFriends()
				if CLL_Notify then CLL_Notify("Friend added", tostring(FriendsList[uid])) end
			else
				if CLL_Notify then CLL_Notify("Friend", "Player not found") end
			end
		end)
	end)
	refreshFriends()

    label({ Text = "CONFIG", TextSize = 12, TextColor3 = Theme.Dim, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, rY), Parent = rScroll }); rY += 25

	-- executor FS helpers
	local function fs_list(prefix)
		local out = {}
		if not listfiles then return out end
		local ok, files = pcall(listfiles, "")
		if not ok or type(files) ~= "table" then
			ok, files = pcall(listfiles, "./")
		end
		if not ok or type(files) ~= "table" then return out end
		for _, f in ipairs(files) do
			local name = tostring(f):gsub("\\", "/"):match("([^/]+)$") or tostring(f)
			if name:sub(1, #prefix) == prefix and name:sub(-5) == ".json" then
				table.insert(out, name)
			end
		end
		table.sort(out)
		return out
	end
	local function fs_write(path, data)
		if not writefile then return false, "no writefile" end
		local ok, err = pcall(writefile, path, data)
		return ok, err
	end
	local function fs_read(path)
		if not (isfile and readfile) then return nil end
		if not isfile(path) then return nil end
		local ok, body = pcall(readfile, path)
		if ok then return body end
		return nil
	end
	local function fs_del(path)
		if delfile and isfile and isfile(path) then
			pcall(delfile, path)
			return true
		end
		return false
	end

	local CFG_PREFIX = "cll_cfg_"
	local AUTOLOAD_FILE = "cll_autoload.txt"
	local function configPath(name)
		name = tostring(name or "default"):gsub("%s+", "_"):gsub("[^%w_%-]", "")
		if name == "" then name = "default" end
		return CFG_PREFIX .. name .. ".json"
	end
	local function colorToArr(c)
		if typeof(c) == "Color3" then return { c.R, c.G, c.B } end
		return c
	end
	local function arrToColor(a)
		if type(a) == "table" and a[1] then
			return Color3.new(tonumber(a[1]) or 1, tonumber(a[2]) or 1, tonumber(a[3]) or 1)
		end
		return nil
	end
	local function keycodeToStr(k)
		if typeof(k) == "EnumItem" then return k.Name end
		return "Unknown"
	end
	local function strToKeycode(s)
		if type(s) ~= "string" or s == "" or s == "Unknown" then return Enum.KeyCode.Unknown end
		local ok, v = pcall(function() return Enum.KeyCode[s] end)
		if ok and v then return v end
		return Enum.KeyCode.Unknown
	end

	local function collectConfig()
		local esp = {}
		for k, v in pairs(ESP_Config) do
			if typeof(v) == "Color3" then esp[k] = colorToArr(v) else esp[k] = v end
		end
		local keys = {}
		for k, v in pairs(Keys) do keys[k] = keycodeToStr(v) end
		local stDump = {}
		for k, v in pairs(ST) do
			local ty = typeof(v)
			if ty == "boolean" or ty == "number" or ty == "string" then
				stDump[k] = v
			elseif ty == "Color3" then
				stDump[k] = colorToArr(v)
			end
		end
		return {
			version = 3,
			st = stDump,
			hitbox = {
				Enabled = Hitbox_Config.Enabled,
				IncludeNPCs = Hitbox_Config.IncludeNPCs,
				Size = Hitbox_Config.Size,
				Material = Hitbox_Config.Material,
				Transparency = Hitbox_Config.Transparency,
			},
			esp = esp,
			keys = keys,
			anim = AnimName,
			accent = colorToArr(Theme.Accent),
			skyColor = colorToArr(SkyColor),
			hatColor = colorToArr(Cosmetics.getHatColor and Cosmetics.getHatColor() or Color3.fromRGB(255, 220, 40)),
			wingColor = colorToArr(Cosmetics.getWingsColor and Cosmetics.getWingsColor() or Color3.fromRGB(180, 80, 255)),
			killSoundId = CustomKillSoundId,
			gunSounds = CustomGunSoundIds,
			hitSound = ST.HitSoundEnabled,
			hitPreset = ST.HitSoundPreset,
			hitCustom = CustomHitSoundId,
			hitVol = ST.HitSoundVolume,
			killHL = ST.KillHighlightEnabled,
			killHLDur = ST.KillHighlightDuration,
			killHLFade = ST.KillHighlightFade,
			killHLColor = {ST.KillHighlightColor.R, ST.KillHighlightColor.G, ST.KillHighlightColor.B},
			killBeam = ST.KillBeamEnabled ~= false,
			friends = (function()
				local a = {}
				for id, name in pairs(FriendsList) do
					a[tostring(id)] = (type(name) == "string" and name) or true
				end
				return a
			end)(),
			whitelist = (function()
				local a = {}
				for id, name in pairs(Whitelist) do
					a[tostring(id)] = (type(name) == "string" and name) or true
				end
				return a
			end)(),
			-- legacy flat fields for older loaders
			suk = ST.isMultiSuk,
			language = ST.Language or "ru",
			fireDelay = ST.SUK_FireDelay,
			silent = ST.SilentAimEnabled,
			fov = ST.SilentAimFOV,
			tracers = ST.TracersEnabled,
			tracerColorSelf = colorToArr(ST.ColorSelf),
			tracerColorOthers = colorToArr(ST.ColorOthers),
			tracerColorFriends = colorToArr(ST.ColorFriends),
		}
	end

function applyConfig(data)
		if type(data) ~= "table" then return end
		-- full ST table (v3)
		if type(data.st) == "table" then
			for k, v in pairs(data.st) do
				if ST[k] ~= nil and k ~= "isUnloaded" and k ~= "isBinding" and k ~= "reloadInProgress" then
					if type(v) == "table" and v[1] and typeof(ST[k]) == "Color3" then
						local c = arrToColor(v)
						if c then ST[k] = c end
					else
						ST[k] = v
					end
				end
			end
		end
		-- legacy flat keys
		if data.fireDelay then ST.SUK_FireDelay = data.fireDelay end
		if data.sukMax then ST.SUK_MaxPerTick = data.sukMax end
		if data.healH then ST.HealFlyHeight = data.healH end
		if data.ignoreFriends ~= nil then ST.SUK_IgnoreFriends = data.ignoreFriends end
		if data.npcs ~= nil then ST.SUK_TargetNPCs = data.npcs end
		if data.silent ~= nil then ST.SilentAimEnabled = data.silent end
		if data.fov then ST.SilentAimFOV = data.fov end
		if data.suk ~= nil then ST.isMultiSuk = data.suk end
		if data.language == "en" or data.language == "ru" then ST.Language = data.language end
		if data.heal ~= nil then
			ST.HealEnabled = data.heal
			if ST.HealEnabled then pcall(StartHealLoop) else pcall(StopHealLoop) end
		end
		if type(data.hitbox) == "table" then
			for k, v in pairs(data.hitbox) do Hitbox_Config[k] = v end
		end
		if type(data.esp) == "table" then
			for k, v in pairs(data.esp) do
				local c = arrToColor(v)
				if c then ESP_Config[k] = c else ESP_Config[k] = v end
			end
		end
		if data.chams ~= nil then ST.HighlightChamsEnabled = data.chams end
		if data.tracers ~= nil then ST.TracersEnabled = data.tracers end
		if data.tracerDur then ST.TracerDuration = data.tracerDur end
		if data.tracerSelf ~= nil then ST.TracerSelfEnabled = data.tracerSelf end
		if data.tracerOthers ~= nil then ST.TracerOthersEnabled = data.tracerOthers; ST.TracersOthers = data.tracerOthers end
		if data.tracerFriends ~= nil then ST.TracerFriendsEnabled = data.tracerFriends end
		if data.tracerColorSelf then local c = arrToColor(data.tracerColorSelf); if c then ST.ColorSelf = c end end
		if data.tracerColorOthers then local c = arrToColor(data.tracerColorOthers); if c then ST.ColorOthers = c end end
		if data.tracerColorFriends then local c = arrToColor(data.tracerColorFriends); if c then ST.ColorFriends = c end end
		if data.walk ~= nil then ST.WalkSpeedEnabled = data.walk end
		if data.walkV then ST.WalkSpeedValue = data.walkV end
		if data.jump ~= nil then ST.JumpPowerEnabled = data.jump end
		if data.jumpV then ST.JumpPowerValue = data.jumpV end
		if data.fly ~= nil then ST.FlyEnabled = data.fly end
		if data.flyS then ST.FlySpeed = data.flyS end
		if data.spin ~= nil then ST.SpinEnabled = data.spin end
		if data.spinS then ST.SpinSpeed = data.spinS end
		if data.noclip ~= nil then ST.NoClipEnabled = data.noclip end
		if data.infJump ~= nil then ST.InfiniteJumpEnabled = data.infJump end
		if data.noRecoil ~= nil then ST.NoRecoilEnabled = data.noRecoil end
		if data.antiCC ~= nil then ST.AntiCCEnabled = data.antiCC; ST.AntiSlowEnabled = data.antiCC end
		if data.chinaHat ~= nil then ST.ChinaHatEnabled = data.chinaHat; pcall(function() Cosmetics.setHat(data.chinaHat) end) end
		if data.wings ~= nil then ST.WingsEnabled = data.wings; pcall(function() Cosmetics.setWings(data.wings) end) end
		if data.hatColor then local c = arrToColor(data.hatColor); if c then pcall(function() Cosmetics.setHatColor(c) end) end end
		if data.wingColor then local c = arrToColor(data.wingColor); if c then pcall(function() Cosmetics.setWingsColor(c) end) end end
		if data.antiLag ~= nil then ST.AntiLagEnabled = data.antiLag end
		if data.removeFog ~= nil then ST.RemoveFogEnabled = data.removeFog end
		if data.fullbright ~= nil then ST.FullbrightEnabled = data.fullbright end
		if data.timeOn ~= nil then ST.TimeOverrideEnabled = data.timeOn end
		if data.timeV then ST.TimeOverrideValue = data.timeV end
		if data.camFov ~= nil then ST.CameraFOVLocked = data.camFov; ST.AntiCamShakeEnabled = data.camFov end
		if data.camFovV then ST.CameraFOVValue = data.camFovV end
		if data.maxZoom ~= nil then ST.MaxZoomEnabled = data.maxZoom end
		if data.maxZoomV then ST.MaxZoomValue = data.maxZoomV end
		if data.skyOn ~= nil then ST.SkyColorEnabled = data.skyOn end
		if data.skyColor then local c = arrToColor(data.skyColor); if c then SkyColor = c end end
		if data.vrShake ~= nil then ST.VRShakeEnabled = data.vrShake end
		if data.vrShakeI then ST.VRShakeIntensity = data.vrShakeI end
		if data.vrHand then ST.VRHandExtend = data.vrHand end
		if data.trueAim ~= nil then ST.TrueCrosshairEnabled = data.trueAim end
		if data.antiFlash ~= nil then ST.AntiFlashEnabled = data.antiFlash end
		if data.antiShake ~= nil then ST.AntiCamShakeEnabled = data.antiShake end
		if data.killSoundOn ~= nil then ST.CustomKillSoundEnabled = data.killSoundOn end
		if data.killSoundId then CustomKillSoundId = data.killSoundId end
		if data.gunSoundsOn ~= nil then ST.CustomGunSoundsEnabled = data.gunSoundsOn end
		if type(data.gunSounds) == "table" then
			for k, v in pairs(data.gunSounds) do CustomGunSoundIds[k] = v end
		end
		if type(data.keys) == "table" then
			for k, v in pairs(data.keys) do
				if Keys[k] ~= nil then Keys[k] = strToKeycode(v) end
			end
		end
		if data.anim and AnimPresets[data.anim] then AnimName = data.anim end
		if data.accent then
			local c = arrToColor(data.accent)
			if c then Theme.Accent = c; pcall(fireTheme) end
		end
		-- never auto-enable VR from config
		ST.VREnabled = false
		VRWantEnabled = false
		ST.HitSoundEnabled = false
		ST.CustomKillSoundEnabled = false
		ST.CustomGunSoundsEnabled = false
		if data.killHL ~= nil then ST.KillHighlightEnabled = data.killHL end
		if data.killHLDur then ST.KillHighlightDuration = data.killHLDur end
		if data.killHLFade then ST.KillHighlightFade = data.killHLFade end
		if data.killHLColor then local c = arrToColor(data.killHLColor); if c then ST.KillHighlightColor = c end end
		if data.killBeam ~= nil then ST.KillBeamEnabled = data.killBeam and true or false end
		if type(data.friends) == "table" then
			table.clear(FriendsList)
			for k, v in pairs(data.friends) do
				local id, name = nil, nil
				-- array form {12345,67890} → keys 1,2 values are ids
				if type(k) == "number" and type(v) == "number" then
					id, name = v, true
				elseif type(k) == "number" and type(v) == "string" then
					id, name = k, v
				elseif type(k) == "string" then
					id = tonumber(k)
					name = (type(v) == "string" and v) or true
				elseif type(v) == "table" then
					id = tonumber(v.id or v.UserId or v[1])
					name = v.name or v.Name or v[2] or true
				elseif type(v) == "number" then
					id = v
					name = true
				end
				if id and id > 1000 then -- ignore bogus 1,2 from bad array loads
					FriendsList[id] = name or true
				end
			end
			if type(data.whitelist) == "table" then
				table.clear(Whitelist)
				for k, v in pairs(data.whitelist) do
					local id, name = nil, true
					if type(k) == "number" then id, name = k, (type(v) == "string" and v) or true
					else id = tonumber(v) or tonumber(k) end
					if id then Whitelist[id] = name or true end
				end
			end
			if RefreshFriendsUI then pcall(RefreshFriendsUI) end
		end
		-- re-apply cosmetics colors/toggles from ST
		pcall(function()
			if Cosmetics then
				Cosmetics.setHat(ST.ChinaHatEnabled)
				Cosmetics.setWings(ST.WingsEnabled)
			end
		end)
		pcall(updateFOVCircle)
		-- sync feature toggles
		if UI_SyncHooks then
			for _, fn in ipairs(UI_SyncHooks) do pcall(fn) end
		end
		if refreshAllBindLabels then pcall(refreshAllBindLabels) end
		if UI_SliderHooks then
			for _, fn in ipairs(UI_SliderHooks) do pcall(fn) end
		end
		pcall(function()
			if watermarkMain then watermarkMain.Visible = ST.WatermarkMainVisible ~= false end
			if watermarkBinds then watermarkBinds.Visible = ST.WatermarkBindsVisible ~= false end
			if watermarkWorld then watermarkWorld.Visible = ST.WatermarkWorldVisible ~= false end
			if ammoLbl then ammoLbl.Visible = ST.WatermarkAmmoVisible ~= false end
		end)
		-- grid must follow config
		pcall(function()
			if rebuildMenuGrid then rebuildMenuGrid() end
		end)
		-- VR state from config
		pcall(function()
			if setVREnabled then setVREnabled(ST.VREnabled == true, false) end
		end)
	end

function saveConfigNamed(name, overwrite)
		local path = configPath(name)
		if not overwrite and isfile and isfile(path) then
			return false, "exists"
		end
		local ok, err = fs_write(path, HttpService:JSONEncode(collectConfig()))
		if ok and CLL_Notify and ST.NotifyConfig ~= false then CLL_Notify("Config saved", tostring(name)) end
		return ok, err
	end

	local function loadConfigNamed(name)
		local body = fs_read(configPath(name))
		if not body then return false, "missing" end
		local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
		if not ok or type(data) ~= "table" then return false, "bad_json" end
		applyConfig(data)
		return true
	end

	local function deleteConfigNamed(name)
		return fs_del(configPath(name))
	end

	local function setAutoload(name)
		if name == nil or name == "" then
			fs_del(AUTOLOAD_FILE)
			return
		end
		fs_write(AUTOLOAD_FILE, tostring(name))
	end

	local function getAutoload()
		local body = fs_read(AUTOLOAD_FILE)
		if body and body ~= "" then return body:gsub("%s+", "") end
		return nil
	end

	-- UI
	local cfgBox = new("TextBox", {
		Text = getAutoload() or "default",
		PlaceholderText = "config name",
		PlaceholderColor3 = Theme.Dim,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Text,
		Size = UDim2.new(1, -100, 0, 32),
		Position = UDim2.fromOffset(0, rY),
		BackgroundColor3 = Theme.Row,
		ClearTextOnFocus = false,
		Parent = rScroll,
	}, { corner(8), stroke() })

	local cfgStatus = label({
		Text = "autoload: " .. tostring(getAutoload() or "none"),
		TextSize = 12,
		TextColor3 = Theme.Dim,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, rY + 200),
		Parent = rScroll,
	})

	local function mkBtn(text, xOff, y, w, cb)
		local b = new("TextButton", {
			Text = text,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = Theme.Text,
			Size = UDim2.fromOffset(w or 90, 28),
			Position = UDim2.new(1, -xOff, 0, y),
			BackgroundColor3 = Theme.Row,
			Parent = rScroll,
		}, { corner(8), stroke() })
		b.MouseButton1Click:Connect(cb)
		return b
	end

	mkBtn("Save", 90, rY, 90, function()
		local name = cfgBox.Text
		local ok, err = saveConfigNamed(name, true)
		cfgStatus.Text = ok and ("saved: " .. configPath(name)) or ("save fail: " .. tostring(err))
		refreshCfgList()
	end)
	rY += 36

	mkBtn("Load", 90, rY, 90, function()
		local ok, err = loadConfigNamed(cfgBox.Text)
		cfgStatus.Text = ok and ("loaded: " .. cfgBox.Text) or ("load fail: " .. tostring(err))
	end)
	local loadBtnLeft = new("TextButton", {
		Text = "Overwrite save",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Size = UDim2.new(1, -100, 0, 28),
		Position = UDim2.fromOffset(0, rY),
		BackgroundColor3 = Theme.Row,
		Parent = rScroll,
	}, { corner(8), stroke() })
	loadBtnLeft.MouseButton1Click:Connect(function()
		local ok, err = saveConfigNamed(cfgBox.Text, true)
		cfgStatus.Text = ok and ("overwritten: " .. cfgBox.Text) or ("fail: " .. tostring(err))
		refreshCfgList()
	end)
	rY += 36

	mkBtn("Delete", 90, rY, 90, function()
		local name = cfgBox.Text
		if deleteConfigNamed(name) then
			cfgStatus.Text = "deleted: " .. name
			if getAutoload() == name then setAutoload(nil) end
			refreshCfgList()
		else
			cfgStatus.Text = "delete fail / missing"
		end
	end)
	local autoBtn = new("TextButton", {
		Text = "Set Autoload",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Size = UDim2.new(1, -100, 0, 28),
		Position = UDim2.fromOffset(0, rY),
		BackgroundColor3 = Theme.Row,
		Parent = rScroll,
	}, { corner(8), stroke() })
	autoBtn.MouseButton1Click:Connect(function()
		setAutoload(cfgBox.Text)
		cfgStatus.Text = "autoload = " .. tostring(cfgBox.Text)
		refreshCfgList()
	end)
	rY += 36

	local clearAuto = new("TextButton", {
		Text = "Clear Autoload",
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.fromOffset(0, rY),
		BackgroundColor3 = Theme.Row,
		Parent = rScroll,
	}, { corner(8), stroke() })
	clearAuto.MouseButton1Click:Connect(function()
		setAutoload(nil)
		cfgStatus.Text = "autoload cleared"
		refreshCfgList()
	end)
	rY += 36

	rY += 24

	local cfgList = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 140),
		Position = UDim2.fromOffset(0, rY),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = rScroll,
	}, { corner(8), stroke(), new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
	rY += 150

	function refreshCfgList()
		for _, ch in ipairs(cfgList:GetChildren()) do
			if ch:IsA("Frame") or ch:IsA("TextButton") then ch:Destroy() end
		end
		local files = fs_list(CFG_PREFIX)
		local auto = getAutoload()
		if #files == 0 then
			label({
				Text = "no configs on disk",
				TextSize = 12,
				TextColor3 = Theme.Dim,
				Size = UDim2.new(1, -8, 0, 22),
				Parent = cfgList,
			})
		end
		for i, fname in ipairs(files) do
			local short = fname:gsub("^" .. CFG_PREFIX, ""):gsub("%.json$", "")
			local row = new("Frame", {
				Size = UDim2.new(1, -6, 0, 28),
				BackgroundColor3 = Theme.Row,
				LayoutOrder = i,
				Parent = cfgList,
			}, { corner(6) })
			local tag = (auto == short) and " [AUTO]" or ""
			label({
				Text = short .. tag,
				TextSize = 12,
				Size = UDim2.new(1, -120, 1, 0),
				Position = UDim2.fromOffset(8, 0),
				Parent = row,
			})
			local lb = new("TextButton", {
				Text = "Load",
				Font = Enum.Font.GothamMedium,
				TextSize = 11,
				TextColor3 = Theme.Text,
				Size = UDim2.fromOffset(44, 22),
				Position = UDim2.new(1, -100, 0.5, -11),
				BackgroundColor3 = Theme.Off,
				Parent = row,
			}, { corner(5) })
			lb.MouseButton1Click:Connect(function()
				cfgBox.Text = short
				local ok, err = loadConfigNamed(short)
				cfgStatus.Text = ok and ("loaded: " .. short) or ("fail: " .. tostring(err))
			end)
			local db = new("TextButton", {
				Text = "Del",
				Font = Enum.Font.GothamMedium,
				TextSize = 11,
				TextColor3 = Theme.Text,
				Size = UDim2.fromOffset(36, 22),
				Position = UDim2.new(1, -50, 0.5, -11),
				BackgroundColor3 = Theme.Off,
				Parent = row,
			}, { corner(5) })
			db.MouseButton1Click:Connect(function()
				deleteConfigNamed(short)
				if auto == short then setAutoload(nil) end
				refreshCfgList()
				cfgStatus.Text = "deleted: " .. short
			end)
		end
		task.defer(function()
			local layout = cfgList:FindFirstChildOfClass("UIListLayout")
			if layout then
				cfgList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
			end
		end)
		cfgStatus.Text = "autoload: " .. tostring(getAutoload() or "none") .. " | " .. #files .. " file(s)"
	end

	refreshCfgList()
	-- outer panel must scroll so CONFIG is reachable under FRIENDS list
	pcall(function()
		rScroll.ScrollingDirection = Enum.ScrollingDirection.Y
		rScroll.ScrollBarThickness = 6
		rScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(rY + 24, 500))
	end)

	-- autoload on boot
	task.spawn(function()
		local auto = getAutoload()
		if auto then
			task.wait(0.35)
			local ok = loadConfigNamed(auto)
			if ok then
				cfgStatus.Text = "autoload ok: " .. auto
			else
				cfgStatus.Text = "autoload failed: " .. tostring(auto)
			end
		end
	end)

	-- expose for external
	_G.CLL_Config = {
		save = saveConfigNamed,
		load = loadConfigNamed,
		delete = deleteConfigNamed,
		list = function() return fs_list(CFG_PREFIX) end,
		setAutoload = setAutoload,
		getAutoload = getAutoload,
		collect = collectConfig,
		apply = applyConfig,
	}
end


-- ==================== INJECT KEY LOG (cll-auth) ====================
local AUTH_API_BASE = "https://cll-auth.onrender.com" -- change if your bot host differs
task.spawn(function()
	task.wait(1)
	if ST.isUnloaded then return end
	local hwid = "unknown"
	pcall(function()
		hwid = game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	local payload = {
		event = "inject",
		userid = LocalPlayer.UserId,
		username = LocalPlayer.Name,
		display = LocalPlayer.DisplayName,
		hwid = hwid,
		placeId = game.PlaceId,
		jobId = game.JobId,
		executor = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "unknown",
		ts = os.time(),
	}
	local body = HttpService:JSONEncode(payload)
	local function post(url)
		local ok, res = pcall(function()
			if request then
				return request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
			elseif http_request then
				return http_request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
			elseif syn and syn.request then
				return syn.request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
			elseif http and http.request then
				return http.request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
			end
			-- fallback
			return game:HttpPost(url, body, Enum.HttpContentType.ApplicationJson)
		end)
		return ok, res
	end
	pcall(function()
		post(AUTH_API_BASE .. "/log")
	end)
end)

buildCombat(); buildTarget(); buildKeybinds(); buildVR(); buildSettings(); buildProfile()

-- Movement
buildFeaturePage(pages.Movement, "MOVEMENT", {
	{ name = "Walk Speed", nameKey = "t_walk", descKey = "d_walk", initial = false, onToggle = function(v) ST.WalkSpeedEnabled = v; local _, h = getCharacterParts(); if h then h.WalkSpeed = v and ST.WalkSpeedValue or 16 end end, buildDetail = function(d) detailSlider(d, 1, "Speed", 16, 200, ST.WalkSpeedValue, 1, function(v) ST.WalkSpeedValue = v; if ST.WalkSpeedEnabled then local _, h = getCharacterParts(); if h then h.WalkSpeed = v end end end) end },
	{ name = "Jump Power", nameKey = "t_jump", descKey = "d_jump", initial = false, onToggle = function(v) ST.JumpPowerEnabled = v; local _, h = getCharacterParts(); if h then h.UseJumpPower = true; h.JumpPower = v and ST.JumpPowerValue or 50 end end, buildDetail = function(d) detailSlider(d, 1, "Power", 50, 500, ST.JumpPowerValue, 1, function(v) ST.JumpPowerValue = v; if ST.JumpPowerEnabled then local _, h = getCharacterParts(); if h then h.JumpPower = v end end end) end },
	{ name = "Fly", nameKey = "t_fly", descKey = "d_fly", initial = false, onToggle = function(v) ST.FlyEnabled = v; if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end; if flyGyro then flyGyro:Destroy(); flyGyro = nil end; if v then local _, _, r = getCharacterParts(); if r then flyVelocity = Instance.new("BodyVelocity", r); flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge); flyGyro = Instance.new("BodyGyro", r); flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); flyGyro.P = 9000 end end end, buildDetail = function(d) detailSlider(d, 1, "Speed", 10, 200, ST.FlySpeed, 1, function(v) ST.FlySpeed = v end) end },
	{ name = "Spin", nameKey = "t_spin", descKey = "d_spin", initial = false, onToggle = function(v) ST.SpinEnabled = v; local _, _, r = getCharacterParts(); if spinAngular then spinAngular:Destroy(); spinAngular = nil end; if v and r then spinAngular = Instance.new("BodyAngularVelocity", r); spinAngular.AngularVelocity = Vector3.new(0, ST.SpinSpeed, 0); spinAngular.MaxTorque = Vector3.new(0, math.huge, 0); spinAngular.P = 1000 end end, buildDetail = function(d) detailSlider(d, 1, "Spin Speed", 10, 500, ST.SpinSpeed, 10, function(v) ST.SpinSpeed = v; if spinAngular then spinAngular.AngularVelocity = Vector3.new(0, v, 0) end end) end },
	{ name = "No Clip", nameKey = "t_noclip", descKey = "d_noclip", initial = false, onToggle = function(v) ST.NoClipEnabled = v; if not v then for part, old in pairs(savedCollision) do if part and part.Parent then part.CanCollide = old end end; table.clear(savedCollision) end end, buildDetail = nil },
	{ name = "Infinite Jump", nameKey = "t_infjump", descKey = "d_infjump", initial = false, onToggle = function(v) ST.InfiniteJumpEnabled = v; if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect(); InfiniteJumpConnection = nil end; if v then InfiniteJumpConnection = UIS.JumpRequest:Connect(function() if ST.InfiniteJumpEnabled and not ST.isUnloaded then local _, h = getCharacterParts(); if h and h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end) end end, buildDetail = nil },
	{ name = "Anti-CC", nameKey = "t_anticc", descKey = "d_anticc", initial = false, onToggle = function(v) ST.AntiCCEnabled = v; ST.AntiSlowEnabled = v end, buildDetail = function(d)
		local order = 1
		for flag, on in pairs(AntiCC_Flags) do
			detailToggle(d, order, tostring(flag), on == true, function(v) AntiCC_Flags[flag] = v end)
			order = order + 1
		end
	end },
})

-- Visuals
buildFeaturePage(pages.Visual, "VISUAL", {
	
	{ name = "ESP", nameKey = "t_esp", descKey = "d_esp", initial = false, onToggle = function(v) ESP_Config.Enabled = v end, buildDetail = function(d)
		detailSlider(d, 1, "Max Distance", 100, 2000, ESP_Config.MaxDist, 50, function(v) ESP_Config.MaxDist = v end)
		detailToggle(d, 2, "Box", ESP_Config.Box, function(v) ESP_Config.Box = v end)
		detailToggle(d, 3, "Name", ESP_Config.Name, function(v) ESP_Config.Name = v end)
		detailToggle(d, 4, "Health", ESP_Config.Health, function(v) ESP_Config.Health = v end)
		detailToggle(d, 5, "Distance", ESP_Config.Distance, function(v) ESP_Config.Distance = v end)
		detailToggle(d, 6, "Tool in hand", ESP_Config.ShowTool ~= false, function(v) ESP_Config.ShowTool = v end)
		detailToggle(d, 7, "Reload status", ESP_Config.ShowReload ~= false, function(v) ESP_Config.ShowReload = v end)
		detailColor(d, 9, "ESP Color", function() return ESP_Config.ChamsColor end, function(c) ESP_Config.ChamsColor = c end)
		detailColor(d, 10, "Friend Color", function() return ESP_Config.FriendColor end, function(c) ESP_Config.FriendColor = c end)
	end },
	{ name = "Highlight Chams", nameKey = "t_chams", descKey = "d_chams", initial = false, onToggle = function(v) ST.HighlightChamsEnabled = v end, buildDetail = function(d)
		detailSlider(d, 1, "Fill Transparency", 0, 1, ESP_Config.ChamsFillTrans, 0.05, function(v) ESP_Config.ChamsFillTrans = v end)
		detailSlider(d, 2, "Outline Transparency", 0, 1, ESP_Config.ChamsOutlineTrans, 0.05, function(v) ESP_Config.ChamsOutlineTrans = v end)
	end },

})

-- Effects
buildFeaturePage(pages.Effects, "EFFECTS", {
	{ name = "Aim Visualizer", nameKey = "t_aimvis", descKey = "d_aimvis", initial = true, onToggle = function(v) ST.TrueCrosshairEnabled = v; if aimDot then aimDot.Visible = v end; if aimRing then aimRing.Visible = v end end, buildDetail = nil },
	{ name = "Bullet Tracers", nameKey = "t_tracers", descKey = "d_tracers", initial = false, onToggle = function(v) ST.TracersEnabled = v end, buildDetail = function(d)
		detailSlider(d, 1, "Duration", 0.1, 2, ST.TracerDuration, 0.1, function(v) ST.TracerDuration = v end)
		detailToggle(d, 3, "My tracers", ST.TracerSelfEnabled, function(v) ST.TracerSelfEnabled = v end)
		detailColor(d, 3, "My color (red)", function() return ST.ColorSelf end, function(c) ST.ColorSelf = c end)
		detailToggle(d, 4, "Players' tracers", ST.TracerOthersEnabled, function(v) ST.TracerOthersEnabled = v; ST.TracersOthers = v end)
		detailColor(d, 5, "Players color (yellow)", function() return ST.ColorOthers end, function(c) ST.ColorOthers = c end)
		detailToggle(d, 6, "Friends' tracers", ST.TracerFriendsEnabled, function(v) ST.TracerFriendsEnabled = v end)
		detailColor(d, 7, "Friends color (green)", function() return ST.ColorFriends end, function(c) ST.ColorFriends = c end)
	end },
	{ name = "Kill Highlight", nameKey = "t_killhl", descKey = "d_killhl", initial = true, getState = function() return ST.KillHighlightEnabled end, onToggle = function(v) ST.KillHighlightEnabled = v end, buildDetail = function(d)
		detailSlider(d, 1, "Hold (sec)", 0.1, 2, ST.KillHighlightDuration or 0.5, 0.05, function(v) ST.KillHighlightDuration = v end)
		detailSlider(d, 2, "Fade out (sec)", 0.05, 2, ST.KillHighlightFade or 0.4, 0.05, function(v) ST.KillHighlightFade = v end)
		detailColor(d, 3, "Color", function() return ST.KillHighlightColor end, function(c) ST.KillHighlightColor = c end)
		detailToggle(d, 4, "Sky pillar", ST.KillBeamEnabled ~= false, function(v) ST.KillBeamEnabled = v end)
	end },
	{ name = "Anti Flash", nameKey = "t_antiflash", descKey = "d_antiflash", initial = true, onToggle = function(v) ST.AntiFlashEnabled = v end, buildDetail = function(d)
		detailToggle(d, 1, "Block kill highlight", ST.AntiFlashBlockKill, function(v) ST.AntiFlashBlockKill = v end)
		detailToggle(d, 2, "Block flashbang", ST.AntiFlashBlockBang, function(v) ST.AntiFlashBlockBang = v end)
	end },

	{ name = "China Hat", nameKey = "t_hat", descKey = "d_hat", initial = false, onToggle = function(v) ST.ChinaHatEnabled = v; pcall(function() Cosmetics.setHat(v) end) end, buildDetail = nil },
	{ name = "Custom Wings", nameKey = "t_wings", descKey = "d_wings", initial = false, onToggle = function(v) ST.WingsEnabled = v; pcall(function() Cosmetics.setWings(v) end) end, buildDetail = nil },
	{ name = "Anti-Lag", nameKey = "t_antilag", descKey = "d_antilag", initial = false, onToggle = function(s) ST.AntiLagEnabled = s; if s then CleanDebris() end end, buildDetail = nil },
		{ name = "Clear Rain/Weather", nameKey = "t_rain", descKey = "d_rain", initial = false, onToggle = function(s)
		-- one-shot: clear once, do not leave a laggy loop on
		ST.RemoveRainEnabled = false
		if not s then return end
		task.spawn(function()
			for _ = 1, 40 do
				pcall(function()
					local L = game:GetService("Lighting")
					L.FogStart = 1e9
					L.FogEnd = 1e9
					local atm = L:FindFirstChildOfClass("Atmosphere")
					if atm then atm.Density = 0; atm.Haze = 0; atm.Glare = 0 end
				end)
				task.wait(0.12)
			end
		end)
		pcall(function()
			local L = game:GetService("Lighting")
			L.FogEnd = 1e9
			L.FogStart = 1e9
			L.Brightness = math.max(L.Brightness, 2)
			for _, v in ipairs(L:GetChildren()) do
				if v:IsA("Atmosphere") then
					v.Density = 0; v.Haze = 0; v.Glare = 0
				elseif v:IsA("BlurEffect") then
					v.Size = 0
					v.Enabled = false
					pcall(function() v:Destroy() end)
				elseif v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
					v.Enabled = false
				end
			end
			local function kill(v)
				local n = string.lower(v.Name or "")
				local id = string.lower(tostring(v:IsA("Sound") and v.SoundId or ""))
				local hit = n:find("rain") or n:find("storm") or n:find("cloud") or n:find("weather") or n:find("drizzle") or n:find("thunder")
					or id:find("rain") or id:find("storm") or id:find("thunder")
				if not hit then return end
				if v:IsA("Sound") then pcall(function() v.Volume = 0; v:Stop() end) end
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then pcall(function() v.Enabled = false end) end
				pcall(function() v:Destroy() end)
			end
			for _, v in ipairs(workspace:GetDescendants()) do kill(v) end
			for _, v in ipairs(game:GetService("SoundService"):GetDescendants()) do kill(v) end
		end)
		if CLL_Notify then CLL_Notify("Weather", "Rain/clouds cleared once") end
	end, buildDetail = nil },
	{ name = "Remove Fog", nameKey = "t_fog", descKey = "d_fog", initial = false, onToggle = function(s) ST.RemoveFogEnabled = s; if not s then game:GetService("Lighting").FogEnd = 1000 end end, buildDetail = nil },
	{ name = "Fullbright", nameKey = "t_fb", descKey = "d_fb", initial = false, onToggle = function(s) ST.FullbrightEnabled = s end, buildDetail = nil },
	{ name = "Weather Rain", nameKey = "t_wrain", descKey = "d_wrain", initial = false, onToggle = function(v) if v then startWeatherRain() else stopWeather() end end, buildDetail = nil },
	{ name = "Time Override", nameKey = "t_time", descKey = "d_time", initial = false, onToggle = function(s) ST.TimeOverrideEnabled = s; if not s then game:GetService("Lighting").ClockTime = 14 end end, buildDetail = function(d) detailSlider(d, 1, "Time", 0, 24, ST.TimeOverrideValue, 0.1, function(v) ST.TimeOverrideValue = v end) end },
	{ name = "Camera FOV Lock", nameKey = "t_fovlock", descKey = "d_fovlock", initial = false, onToggle = function(s)
		ST.CameraFOVLocked = s
		ST.AntiCamShakeEnabled = s  -- locks FOV + kills Helper Camera Shake / Alt / Crosshair Shove
		if not s then
			workspace.CurrentCamera.FieldOfView = 70
			ST.AntiCamShakeEnabled = false
		end
	end, buildDetail = function(d)
		detailSlider(d, 1, "FOV", 30, 120, ST.CameraFOVValue, 1, function(v) ST.CameraFOVValue = v end)
	end },
	{ name = "Max Zoom", initial = false, onToggle = function(s) ST.MaxZoomEnabled = s; if not s then LocalPlayer.CameraMaxZoomDistance = 128 end end, buildDetail = function(d) detailSlider(d, 1, "Distance", 10, 500, ST.MaxZoomValue, 1, function(v) ST.MaxZoomValue = v; if ST.MaxZoomEnabled then LocalPlayer.CameraMaxZoomDistance = v end end) end },
	{ name = "Sky Color", initial = false, onToggle = function(s) ST.SkyColorEnabled = s; if not s then local sky = game:GetService("Lighting"):FindFirstChild("CLL_Sky"); if sky then sky:Destroy() end end end, buildDetail = function(d)
		detailColor(d, 1, "Sky Color", function() return SkyColor end, function(c) 
			SkyColor = c
			if ST.SkyColorEnabled then
				local l = game:GetService("Lighting")
				local sky = l:FindFirstChild("CLL_Sky") or Instance.new("Sky", l)
				sky.Name = "CLL_Sky"
				sky.SkyboxBk = "rbxassetid://0"
				sky.SkyboxDn = "rbxassetid://0"
				sky.SkyboxFt = "rbxassetid://0"
				sky.SkyboxLf = "rbxassetid://0"
				sky.SkyboxRt = "rbxassetid://0"
				sky.SkyboxUp = "rbxassetid://0"
				sky.StarCount = 0
				l.Ambient = c:Lerp(Color3.new(0,0,0), 0.5)
				l.OutdoorAmbient = c
			end
		end)
	end }
})

-- Window Drag
do
	local dragging, startPos, startMouse
	header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, startMouse, startPos = true, i.Position, window.Position end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - startMouse; window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

-- Watermarks

-- ==================== MENU GRID BACKGROUND ====================
local menuGridFolder = nil
local menuGridConn = nil
rebuildMenuGrid = function()
	pcall(function()
		if menuGridFolder then menuGridFolder:Destroy() end
		menuGridFolder = nil
		if menuGridConn then menuGridConn:Disconnect(); menuGridConn = nil end
		if not ST.MenuGridEnabled or not window or not window.Parent then return end

		local folder = Instance.new("Frame")
		folder.Name = "CLL_MenuGrid"
		folder.BackgroundTransparency = 1
		folder.Size = UDim2.fromScale(1, 1)
		folder.ClipsDescendants = true
		folder.ZIndex = 0
		folder.Parent = window
		menuGridFolder = folder

		local style = ST.MenuBgStyle or "chess"
		local col = ST.MenuGridColor or Theme.Accent or Color3.fromRGB(80, 140, 255)
		local tr = math.clamp(ST.MenuGridTransparency or 0.85, 0.15, 0.98)
		local rot = tonumber(ST.MenuGridRotation) or 0
		local cell = 26
		local t0 = os.clock()

		local function mk(parent, x, y, w, h, c, a)
			local f = Instance.new("Frame")
			f.BorderSizePixel = 0
			f.BackgroundColor3 = c
			f.BackgroundTransparency = a
			f.Size = UDim2.fromOffset(w, h)
			f.Position = UDim2.fromOffset(x, y)
			f.ZIndex = 0
			f.Parent = parent
			return f
		end

		if style == "chess" then
			local holder = Instance.new("Frame")
			holder.BackgroundTransparency = 1
			holder.Size = UDim2.fromScale(1.7, 1.7)
			holder.Position = UDim2.fromScale(0.5, 0.5)
			holder.AnchorPoint = Vector2.new(0.5, 0.5)
			holder.Rotation = rot
			holder.ZIndex = 0
			holder.Parent = folder
			local cells = {}
			for gy = 0, 24 do
				for gx = 0, 28 do
					local on = ((gx + gy) % 2 == 0)
					local c = on and col or Color3.new(col.R * 0.32, col.G * 0.32, col.B * 0.32)
					local a = on and (tr * 0.5 + 0.3) or (tr * 0.8 + 0.12)
					cells[#cells + 1] = { f = mk(holder, gx * cell - 40, gy * cell - 40, cell, cell, c, a), on = on }
				end
			end
			menuGridConn = RunService.RenderStepped:Connect(function()
				if ST.isUnloaded or not ST.MenuGridEnabled or not folder.Parent then
					if menuGridConn then menuGridConn:Disconnect() end
					return
				end
				local spd = math.clamp(ST.MenuGridSpeed or 1, 0.05, 8)
				holder.Rotation = (ST.MenuGridRotation or 0) + ((os.clock() - t0) * spd * 5) % 360
				local c2 = ST.MenuGridColor or Theme.Accent or col
				local dark = Color3.new(c2.R * 0.32, c2.G * 0.32, c2.B * 0.32)
				local tr2 = math.clamp(ST.MenuGridTransparency or tr, 0.15, 0.98)
				for _, c in ipairs(cells) do
					c.f.BackgroundColor3 = c.on and c2 or dark
					c.f.BackgroundTransparency = c.on and (tr2 * 0.5 + 0.3) or (tr2 * 0.8 + 0.12)
				end
			end)
		elseif style == "waves" then
			local bars = {}
			for i = 0, 40 do
				bars[#bars + 1] = { f = mk(folder, i * 16 - 10, 0, 9, 900, col, tr), i = i }
			end
			menuGridConn = RunService.RenderStepped:Connect(function()
				if ST.isUnloaded or not ST.MenuGridEnabled or not folder.Parent then
					if menuGridConn then menuGridConn:Disconnect() end
					return
				end
				local spd = math.clamp(ST.MenuGridSpeed or 1, 0.05, 8)
				local t = (os.clock() - t0) * spd
				local c2 = ST.MenuGridColor or Theme.Accent or col
				local tr2 = math.clamp(ST.MenuGridTransparency or tr, 0.15, 0.98)
				for _, b in ipairs(bars) do
					local y = math.sin(t * 1.5 + b.i * 0.32) * 48 + math.sin(t * 0.6 + b.i * 0.12) * 18
					b.f.Position = UDim2.fromOffset(b.i * 16 - 10, y - 30)
					b.f.BackgroundColor3 = c2
					b.f.BackgroundTransparency = tr2
				end
			end)
		else
			local spacing = 28
			local holder = Instance.new("Frame")
			holder.BackgroundTransparency = 1
			holder.Size = UDim2.fromScale(1.5, 1.5)
			holder.Position = UDim2.fromScale(0.5, 0.5)
			holder.AnchorPoint = Vector2.new(0.5, 0.5)
			holder.Rotation = rot
			holder.Parent = folder
			local lines = {}
			for i = 0, 40 do
				lines[#lines + 1] = { ln = mk(holder, i * spacing, -20, 1, 900, col, tr), axis = "v", i = i }
			end
			for i = 0, 30 do
				lines[#lines + 1] = { ln = mk(holder, -20, i * spacing, 900, 1, col, tr), axis = "h", i = i }
			end
			menuGridConn = RunService.RenderStepped:Connect(function()
				if ST.isUnloaded or not ST.MenuGridEnabled or not folder.Parent then
					if menuGridConn then menuGridConn:Disconnect() end
					return
				end
				local spd = math.clamp(ST.MenuGridSpeed or 1, 0.05, 8)
				local off = ((os.clock() - t0) * spd * 12) % spacing
				local c2 = ST.MenuGridColor or Theme.Accent or col
				local tr2 = math.clamp(ST.MenuGridTransparency or tr, 0.15, 0.98)
				holder.Rotation = ST.MenuGridRotation or 0
				for _, L in ipairs(lines) do
					L.ln.BackgroundColor3 = c2
					L.ln.BackgroundTransparency = tr2
					if L.axis == "v" then
						L.ln.Position = UDim2.fromOffset(L.i * spacing - off, -20)
					else
						L.ln.Position = UDim2.fromOffset(-20, L.i * spacing - off)
					end
				end
			end)
		end
	end)
end


function createWatermark(name, pos, width)
	local wm = new("Frame", {
		Size = UDim2.fromOffset(width, 32), Position = pos,
		BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.4, Parent = gui,
	}, { corner(10), stroke(), new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }), new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8) }) })
	local dragging, startPos, startMouse
	wm.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, startMouse, startPos = true, i.Position, wm.Position end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - startMouse; wm.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	return wm
end

watermarkMain = createWatermark("Main", UDim2.fromOffset(14, 70), 180)
pcall(function()
	watermarkMain.BackgroundTransparency = 0.25
	local st = watermarkMain:FindFirstChildOfClass("UIStroke")
	if st then st.Color = Theme.Accent; st.Thickness = 1.2 end
end)
local wmLogo = label({ Text = "CLL", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Accent, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 32), Parent = watermarkMain })
subscribeTheme(function()
	pcall(function()
		wmLogo.TextColor3 = Theme.Accent
		local st = watermarkMain:FindFirstChildOfClass("UIStroke")
		if st then st.Color = Theme.Accent end
	end)
end)
function wmSep(parent) return new("Frame", { Size = UDim2.fromOffset(1, 12), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = parent }) end
wmSep(watermarkMain)
local fpsLbl = label({ Text = "-- FPS", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 32), Parent = watermarkMain })
wmSep(watermarkMain)
local pingLbl = label({ Text = "-- ms", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Dim, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 32), Parent = watermarkMain })

watermarkWorld = createWatermark("World", UDim2.fromOffset(14, 112), 120)
local worldLbl = label({ Text = "Time: 00:00", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 32), Parent = watermarkWorld })

watermarkBinds = new("Frame", {
	Size = UDim2.fromOffset(220, 36), Position = UDim2.fromOffset(14, 154),
	BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.35, Parent = gui,
	AutomaticSize = Enum.AutomaticSize.Y,
}, {
	corner(10), stroke(),
	new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
})
local bindsLbl = label({
	Text = "Binds: —",
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = false,
	RichText = false,
	AutomaticSize = Enum.AutomaticSize.XY,
	Size = UDim2.fromOffset(0, 0),
	BackgroundTransparency = 1,
	Parent = watermarkBinds,
})

do
	local dragging, startPos, startMouse
	watermarkBinds.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, startMouse, startPos = true, i.Position, watermarkBinds.Position end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - startMouse; watermarkBinds.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end


-- Ammo watermark (under cursor) — ClientAmmo of last held gun
ST.WatermarkAmmoVisible = ST.WatermarkAmmoVisible ~= false
local ammoGui = Instance.new("ScreenGui")
ammoGui.Name = "CLL_AmmoWM"
ammoGui.ResetOnSpawn = false
ammoGui.IgnoreGuiInset = true
ammoGui.DisplayOrder = 999
ammoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	if gethui then ammoGui.Parent = gethui() end
end)
if not ammoGui.Parent then
	pcall(function() ammoGui.Parent = game:GetService("CoreGui") end)
end
if not ammoGui.Parent then
	pcall(function() ammoGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2) end)
end
local ammoLbl = Instance.new("TextLabel")
ammoLbl.Name = "Ammo"
ammoLbl.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ammoLbl.BackgroundTransparency = 0.35
ammoLbl.BorderSizePixel = 0
ammoLbl.Size = UDim2.fromOffset(90, 24)
ammoLbl.AnchorPoint = Vector2.new(0.5, 0)
ammoLbl.Font = Enum.Font.GothamBold
ammoLbl.TextSize = 15
ammoLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoLbl.TextStrokeTransparency = 0.5
ammoLbl.Text = "— / —"
ammoLbl.Visible = ST.WatermarkAmmoVisible
ammoLbl.Parent = ammoGui
do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = ammoLbl
end
local lastHeldTool = nil
local lastClientAmmo, lastMaxAmmo = nil, nil

function refreshAmmoLabel()
	if not ST.WatermarkAmmoVisible then
		ammoLbl.Visible = false
		return
	end
	ammoLbl.Visible = true
	if lastClientAmmo ~= nil then
		ammoLbl.Text = string.format("%d / %d", lastClientAmmo, lastMaxAmmo or 0)
	else
		ammoLbl.Text = "— / —"
	end
end

function trackToolAmmo(tool)
	if not tool or not tool:IsA("Tool") then return end
	lastHeldTool = tool
	local function read()
		if not tool or not tool.Parent then return end
		local cur = tool:GetAttribute("ClientAmmo")
		if cur == nil then cur = tool:GetAttribute("CurrentAmmo") end
		if cur == nil then
			local v = tool:FindFirstChild("CurrentAmmo")
			if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then cur = v.Value end
		end
		local maxA = tool:GetAttribute("MaxAmmo")
		if maxA == nil then
			local v = tool:FindFirstChild("MaxAmmo")
			if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then maxA = v.Value end
		end
		lastClientAmmo = tonumber(cur)
		lastMaxAmmo = tonumber(maxA) or lastMaxAmmo
		refreshAmmoLabel()
	end
	read()
	pcall(function()
		tool:GetAttributeChangedSignal("ClientAmmo"):Connect(read)
		tool:GetAttributeChangedSignal("CurrentAmmo"):Connect(read)
		tool:GetAttributeChangedSignal("MaxAmmo"):Connect(read)
	end)
	pcall(function()
		local v = tool:FindFirstChild("CurrentAmmo")
		if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then
			v.Changed:Connect(read)
		end
	end)
end

function hookCharTools(char)
	if not char then return end
	char.ChildAdded:Connect(function(ch)
		if ch:IsA("Tool") then trackToolAmmo(ch) end
	end)
	char.ChildRemoved:Connect(function(ch)
		if ch:IsA("Tool") and ch == lastHeldTool then
			-- keep last ammo numbers displayed
			refreshAmmoLabel()
		end
	end)
	local t = char:FindFirstChildOfClass("Tool")
	if t then trackToolAmmo(t) end
end
if LocalPlayer.Character then hookCharTools(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookCharTools)

RunService.RenderStepped:Connect(function()
	if ST.isUnloaded then return end
	refreshAmmoLabel()
	if not ammoLbl.Visible then return end
	local m = UIS:GetMouseLocation()
	ammoLbl.Position = UDim2.fromOffset(m.X, m.Y + 26)
end)

task.spawn(function()
	local frames, acc = 0, 0
	RunService.RenderStepped:Connect(function(dt)
		if ST.isUnloaded then return end
		frames += 1; acc += dt
		if acc >= 0.5 then
			fpsLbl.Text = string.format("%d FPS", math.floor(frames / acc + 0.5))
			local ping = 0
			pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
			pingLbl.Text = string.format("%d ms", ping)
			worldLbl.Text = "Time: " .. os.date("%H:%M")
			
			local activeBinds = {}
			local order = {"Menu","SUK","ESP","Hitbox","Fly","Heal","SilentAim","TeleportHeal","ReloadSpas","Combo"}
			for _, k in ipairs(order) do
				local v = Keys[k]
				if v and v ~= Enum.KeyCode.Unknown then
					table.insert(activeBinds, string.format("%s · %s", k, v.Name))
				end
			end
			for k, v in pairs(Keys) do
				if v ~= Enum.KeyCode.Unknown then
					local known = false
					for _, o in ipairs(order) do if o == k then known = true break end end
					if not known then table.insert(activeBinds, string.format("%s · %s", k, v.Name)) end
				end
			end
			if #activeBinds > 0 then
				bindsLbl.Text = table.concat(activeBinds, "\n")
			else
				bindsLbl.Text = "Binds: —"
			end
			-- width from longest line; height from line count (AutomaticSize helps)
			local maxW = 80
			for _, line in ipairs(activeBinds) do
				maxW = math.max(maxW, #line * 7 + 8)
			end
			local lines = math.max(1, #activeBinds)
			watermarkBinds.Size = UDim2.fromOffset(math.clamp(maxW, 140, 320), 16 + lines * 16)
			frames, acc = 0, 0
		end
	end)
end)


-- Open / Close
local isOpen = false
local tweens = {}
function play(obj, ti, goal)
	if obj == nil or typeof(ti) ~= "TweenInfo" or type(goal) ~= "table" then return nil end
	local ok, t = pcall(function() return TweenService:Create(obj, ti, goal) end)
	if not ok or not t then return nil end
	pcall(function()
		table.insert(tweens, t)
		t:Play()
	end)
	return t
end
function setOpen(state)
	-- 10.8 menu motion + hard fallbacks (no stuck glass / no nil crash / no stuck open)
	if state == isOpen then return end
	isOpen = state
	for _, t in ipairs(tweens) do pcall(function() t:Cancel() end) end
	table.clear(tweens)
	if not window then return end
	local A = AnimPresets[AnimName] or AnimPresets.Smooth
	local scaleStart = (type(A.scale) == "number" and A.scale) or 0.93
	local oi = TweenInfo.new(math.min(0.22, (A.open[3] or 0.5) * 0.45), A.open[1], A.open[2])
	local ci = TweenInfo.new((A.close[3] or 0.32) * 0.9, A.close[1], A.close[2])
	if state then
		window.Visible = true
		window.GroupTransparency = 1
		animFactor.Value = scaleStart
		play(animFactor, oi, { Value = 1 })
		play(window, TweenInfo.new(0.22, ES.Sine, ED.Out), { GroupTransparency = 0 })
		task.delay(0.35, function()
			if isOpen and window then
				window.GroupTransparency = 0
				animFactor.Value = 1
			end
		end)
	else
		play(animFactor, ci, { Value = scaleStart })
		local fade = play(window, TweenInfo.new(0.2, ES.Sine, ED.In), { GroupTransparency = 1 })
		if fade then
			pcall(function()
				fade.Completed:Connect(function(st)
					if st == Enum.PlaybackState.Completed and not isOpen and window then
						window.Visible = false
					end
				end)
			end)
		else
			window.GroupTransparency = 1
			window.Visible = false
		end
		task.delay(0.32, function()
			if not isOpen and window then
				window.Visible = false
				window.GroupTransparency = 1
			end
		end)
	end
end

function toggleFly(state) ST.FlyEnabled = state; if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end; if flyGyro then flyGyro:Destroy(); flyGyro = nil end; if state then local _, _, r = getCharacterParts(); if r then flyVelocity = Instance.new("BodyVelocity", r); flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge); flyGyro = Instance.new("BodyGyro", r); flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); flyGyro.P = 9000 end end end


function TeleportToCursor()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local mouse = LocalPlayer:GetMouse()
	local pos
	pcall(function()
		if mouse and mouse.Hit then
			pos = mouse.Hit.Position
		end
	end)
	if not pos then
		local ray = cam:ViewportPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char }
		local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
		if res then pos = res.Position end
	end
	if not pos then return end
	root.CFrame = CFrame.new(pos + Vector3.new(0, 3.2, 0))
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

function TeleportToHeal()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local brick = nil
	local traps = workspace:FindFirstChild("Traps")
	local buttons = traps and traps:FindFirstChild("buttons")
	if buttons then brick = buttons:FindFirstChild("Heal100Brick") end
	if not brick then brick = workspace:FindFirstChild("Heal100Brick", true) end
	if not brick then
		for _, v in ipairs(workspace:GetDescendants()) do
			if v.Name == "Heal100Brick" and v:IsA("BasePart") then brick = v; break end
		end
	end
	if not brick then return end
	local pos = brick.Position + Vector3.new(0, 3.5, 0)
	root.CFrame = CFrame.new(pos)
	root.AssemblyLinearVelocity = Vector3.zero
end



-- VR Carry — same as v11.4: needs VR on + victim Character as 3rd arg
-- VRCarry only: pick up player into hands (not punch). VR must be on.
-- VRCarry: mirror game path exactly (Keybinds u107 + mobile Helper "Grab")
UIS.InputBegan:Connect(function(input, gp)
	if ST.isUnloaded then return end
	-- keybind capture runs even if gameProcessed (ESC must always reset)
	if ST.isBinding then
		if input.KeyCode == Enum.KeyCode.Escape then
			if bindTarget then
				bindTarget.btn.Text = "None"
				Keys[bindTarget.keyName] = Enum.KeyCode.Unknown
			end
			ST.isBinding = false
			bindTarget = nil
			return
		end
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			if bindTarget then
				Keys[bindTarget.keyName] = input.KeyCode
				bindTarget.btn.Text = input.KeyCode.Name
			end
			ST.isBinding = false
			bindTarget = nil
			return
		end
		-- mouse buttons as binds
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3 then
			if bindTarget then
				Keys[bindTarget.keyName] = input.UserInputType
				bindTarget.btn.Text = input.UserInputType.Name
			end
			ST.isBinding = false
			bindTarget = nil
			return
		end
		return
	end
	if gp or UIS:GetFocusedTextBox() then return end
	local key = input.KeyCode
	if key == (Keys.Menu or Enum.KeyCode.RightShift) then setOpen(not isOpen); return end
	local function pressed(bind)
		if bind == nil or bind == Enum.KeyCode.Unknown then return false end
		if typeof(bind) ~= "EnumItem" then return false end
		if bind.EnumType == Enum.KeyCode then return key == bind end
		if bind.EnumType == Enum.UserInputType then return input.UserInputType == bind end
		return false
	end
	if pressed(Keys.SUK) then
		ST.isMultiSuk = not ST.isMultiSuk
		if not ST.isMultiSuk then clearSukReloadState() end
	elseif pressed(Keys.AntiCC) then
		ST.AntiCCEnabled = not ST.AntiCCEnabled
		ST.AntiSlowEnabled = ST.AntiCCEnabled
	elseif pressed(Keys.ESP) then
		ESP_Config.Enabled = not ESP_Config.Enabled
	elseif pressed(Keys.Hitbox) then
		Hitbox_Config.Enabled = not Hitbox_Config.Enabled
	elseif pressed(Keys.Fly) then
		ST.FlyEnabled = not ST.FlyEnabled
		if not ST.FlyEnabled then
			if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
			if flyGyro then flyGyro:Destroy(); flyGyro = nil end
		end
	elseif pressed(Keys.WalkSpeed) then
		ST.WalkSpeedEnabled = not ST.WalkSpeedEnabled
		local _, h = getCharacterParts()
		if h then h.WalkSpeed = ST.WalkSpeedEnabled and (ST.WalkSpeedValue or 16) or 16 end
	elseif pressed(Keys.JumpPower) then
		ST.JumpPowerEnabled = not ST.JumpPowerEnabled
		local _, h = getCharacterParts()
		if h then h.UseJumpPower = true; h.JumpPower = ST.JumpPowerEnabled and (ST.JumpPowerValue or 50) or 50 end
	elseif pressed(Keys.Heal) then
		ST.HealEnabled = not ST.HealEnabled
		if ST.HealEnabled then StartHealLoop() else StopHealLoop() end
	elseif pressed(Keys.SilentAim) then
		ST.SilentAimEnabled = not ST.SilentAimEnabled
		pcall(updateFOVCircle)
	elseif pressed(Keys.Spin) then
		ST.SpinEnabled = not ST.SpinEnabled
	elseif pressed(Keys.NoRecoil) then
		ST.NoRecoilEnabled = not ST.NoRecoilEnabled
	elseif pressed(Keys.ChinaHat) then
		ST.ChinaHatEnabled = not ST.ChinaHatEnabled
	elseif pressed(Keys.Wings) then
		ST.WingsEnabled = not ST.WingsEnabled
	elseif pressed(Keys.AntiLag) then
		ST.AntiLagEnabled = not ST.AntiLagEnabled
	elseif pressed(Keys.TeleportHeal) then
		pcall(TeleportToHeal)
	elseif pressed(Keys.TeleportCursor) then
		pcall(TeleportToCursor)
	elseif pressed(Keys.ReloadSpas) then
		local t = GetSpas()
		if t then pcall(InstantReload, t) end
	end
end)


-- residual cam cleanup: ONLY when ST.AntiCamShakeEnabled (tied to FOV lock)
-- NoRecoil alone only strips Helper Fx via namecall, does NOT fight camera
RunService.RenderStepped:Connect(function()
	if ST.isUnloaded then return end
	if ST.AntiCamShakeEnabled then
		local cam = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function() hum.CameraOffset = Vector3.zero end)
		end
		if char then
			pcall(function()
				char:SetAttribute("VR_CAMERA_RECOIL", Vector3.zero)
			end)
		end
		-- Camera Shake Alt multiplies CFrame by random offset — snap subject back
		if cam and hum and cam.CameraType == Enum.CameraType.Custom then
			pcall(function()
				cam.CameraSubject = hum
			end)
		end
	end
	if ST.AntiFlashEnabled then
		-- throttle heavy GUI walk (was every frame → micro freezes)
		_G.CLL_AF_ACC = (_G.CLL_AF_ACC or 0) + 1
		if _G.CLL_AF_ACC >= 6 then
			_G.CLL_AF_ACC = 0
			local pg = LocalPlayer:FindFirstChild("PlayerGui")
			if pg then
				for _, gui in ipairs(pg:GetChildren()) do
					local n = string.lower(gui.Name)
					if n:find("vfx") or n:find("screenfx") or n:find("flash") then
						for _, c in ipairs(gui:GetDescendants()) do
							local cn = string.lower(c.Name)
							if c:IsA("Frame") or c:IsA("ImageLabel") or c:IsA("ImageButton") then
								if cn:find("flash") or cn:find("pulse") or cn:find("blind") or cn:find("black") or cn:find("overlay") then
									c.Visible = false
									if c:IsA("Frame") then c.BackgroundTransparency = 1 end
									if c:IsA("ImageLabel") or c:IsA("ImageButton") then c.ImageTransparency = 1 end
								end
							end
						end
					end
				end
			end
		end
		local cc = game:GetService("Lighting"):FindFirstChildOfClass("ColorCorrectionEffect")
		if cc and (cc.Brightness > 0.15 or cc.Contrast > 0.25 or cc.Saturation < -0.2) then
			pcall(function() cc.Brightness = 0; cc.Contrast = 0; cc.Saturation = 0; cc.TintColor = Color3.new(1,1,1) end)
		end
		-- do NOT touch CameraOffset / FOV here — flash only
	end
end)

ST.VREnabled = false



-- ==================== VR TARGET SPEED PROTECT ====================
task.spawn(function()
	while not ST.isUnloaded do
		task.wait(0.05)
		if not (ST.VREnabled and ST.VRTargetProtect and ST.VRTargetEnabled) then continue end
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not (root and hum) or hum.Health <= 0 then continue end
		local maxS = ST.VRTargetMaxSpeed or 90
		local v = root.AssemblyLinearVelocity
		if v.Magnitude > maxS then
			root.AssemblyLinearVelocity = v.Unit * maxS
		end
		-- soft floor clamp on fall
		if v.Y < -120 then
			root.AssemblyLinearVelocity = Vector3.new(v.X, -80, v.Z)
		end
	end
end)

-- ==================== MENU CLICK RING (menu only) ====================
do
	local ringGui = Instance.new("ScreenGui")
	ringGui.Name = "CLL_MenuClickRing"
	ringGui.IgnoreGuiInset = true
	ringGui.ResetOnSpawn = false
	ringGui.DisplayOrder = 120
	pcall(function()
		ringGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
	end)
	local function spawnRing(x, y)
		if not isOpen then return end
		local r = Instance.new("Frame")
		r.AnchorPoint = Vector2.new(0.5, 0.5)
		r.Position = UDim2.fromOffset(x, y)
		r.Size = UDim2.fromOffset(28, 28)
		r.BackgroundTransparency = 1
		r.BorderSizePixel = 0
		r.Parent = ringGui
		local stroke = Instance.new("UIStroke")
		stroke.Color = Theme.Accent or Color3.fromRGB(90, 160, 255)
		stroke.Thickness = 2
		stroke.Transparency = 0.15
		stroke.Parent = r
		Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)
		local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(r, ti, { Size = UDim2.fromOffset(8, 8) }):Play()
		local t2 = TweenService:Create(stroke, ti, { Transparency = 1, Thickness = 1 })
		t2:Play()
		t2.Completed:Connect(function()
			r:Destroy()
		end)
		-- restore pulse: grow slightly then fade already handled
	end
	UIS.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not isOpen then return end
		local m = UIS:GetMouseLocation()
		spawnRing(m.X, m.Y)
	end)
end

-- ==================== NOTIFY (toasts removed; VR death notice kept elsewhere) ====================
local function CLL_Notify(title, body, dur)
	-- no-op: toasts disabled (FPS / spam). VR uses showVRDeathNotice only.
end
_G.CLL_Notify = CLL_Notify

-- ==================== WHITELIST SYNC (cll-auth / Mongo via bot) ====================
task.spawn(function()
	local url = "https://cll-auth.onrender.com/whitelist"
	local function pull()
		pcall(function()
			local body = game:HttpGet(url)
			if type(body) ~= "string" or #body < 2 then return end
			local data = HttpService:JSONDecode(body)
			local list = data.list or data.whitelist or data.data or data
			if type(list) ~= "table" then return end
			local nextWL = {}
			for k, v in pairs(list) do
				local id, name = nil, true
				if type(v) == "table" then
					id = tonumber(v.id or v.userId or v.UserId or v[1])
					name = v.name or v.Name or v.username or true
				elseif type(v) == "number" then
					id = v
				elseif type(k) == "string" or type(k) == "number" then
					id = tonumber(k) or tonumber(v)
					name = type(v) == "string" and v or true
				end
				if id and id > 1000 then nextWL[id] = name end
			end
			if next(nextWL) then
				Whitelist = nextWL
			end
		end)
	end
	pull()
	while not ST.isUnloaded do
		task.wait(45)
		pull()
	end
end)




selectTab("Combat")
setOpen(true)
fireTheme()
updateFOVCircle()

end
CLL_Main()
