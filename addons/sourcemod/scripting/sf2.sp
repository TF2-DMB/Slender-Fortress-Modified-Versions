#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <tf2items>
#include <tf2attributes>
#include <dhooks>
#include <navmesh>
#include <nativevotes>
#include <collisionhook>

#pragma semicolon 1

#include <tf2>
#include <tf2_stocks>
#include <morecolors>

#undef REQUIRE_PLUGIN
#include <adminmenu>
#tryinclude <store/store-tf2footprints>
#define REQUIRE_PLUGIN

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#tryinclude <steamworks>
bool steamtools;
bool steamworks;
#define REQUIRE_EXTENSIONS

#define DEBUG
#define SF2

#include <sf2>
#pragma newdecls required

#define PLUGIN_VERSION "1.6.1 Modified"
#define PLUGIN_VERSION_DISPLAY "1.6.1 Modified"

#define TFTeam_Spectator 1
#define TFTeam_Red 2
#define TFTeam_Blue 3
#define TFTeam_Boss 5

#define MASK_RED 33640459
#define MASK_BLUE 33638411

#define EF_ITEM_BLINK 0x100


public Plugin myinfo = 
{
    name = "Slender Fortress",
    author	= "KitRifty, Kenzzer, Mentrillum, The Gaben",
    description	= "Based on the game Slender: The Eight Pages.",
    version = PLUGIN_VERSION,
    url = "https://discord.gg/uytDCFS"
}

#define FILE_RESTRICTEDWEAPONS "configs/sf2/restrictedweapons.cfg"
#define FILE_RESTRICTEDWEAPONS_DATA "data/sf2/restrictedweapons.cfg"

#define BOSS_THINKRATE 0.1 // doesn't really matter much since timers go at a minimum of 0.1 seconds anyways

#define CRIT_SOUND "player/crit_hit.wav"
#define CRIT_PARTICLENAME "crit_text"
#define MINICRIT_SOUND "player/crit_hit_mini.wav"
#define MINICRIT_PARTICLENAME "minicrit_text"
#define ZAP_SOUND "weapons/barret_arm_zap.wav"
#define ZAP_PARTICLENAME "dxhr_arm_muzzleflash"
#define FIREWORKSBLU_PARTICLENAME "utaunt_firework_teamcolor_blue"
#define FIREWORKSRED_PARTICLENAME "utaunt_firework_teamcolor_red"
#define TELEPORTEDINBLU_PARTICLENAME "teleported_red"
#define SOUND_THUNDER "ambient/explosions/explode_9.wav"

#define EXPLOSIVEDANCE_EXPLOSION1 "weapons/explode1.wav"
#define EXPLOSIVEDANCE_EXPLOSION2 "weapons/explode2.wav"
#define EXPLOSIVEDANCE_EXPLOSION3 "weapons/explode3.wav"

#define SPECIAL1UPSOUND "mvm/mvm_revive.wav"

#define SPECIALROUND_BOO_DISTANCE 120.0
#define SPECIALROUND_BOO_DURATION 4.0

#define PAGE_DETECTOR_BEEP "items/cart_explode_trigger.wav"

#define PAGE_MODEL "models/slender/pickups/sheet.mdl"
#define PAGE_MODELSCALE 1.0

#define DEFAULT_CLOAKONSOUND "weapons/medi_shield_deploy.wav"
#define DEFAULT_CLOAKOFFSOUND "weapons/medi_shield_retract.wav"

#define SF_KEYMODEL "models/demani_sf/key_australium.mdl"

#define FLASHLIGHT_CLICKSOUND "slender/slenderflashlightclick.wav"
#define FLASHLIGHT_CLICKSOUND_NIGHTVISION "slender/nightvision.mp3"
#define FLASHLIGHT_BREAKSOUND "ambient/energy/spark6.wav"
#define FLASHLIGHT_NOSOUND "player/suit_denydevice.wav"
#define PAGE_GRABSOUND "slender/slenderpagegrab.wav"
#define TWENTYDOLLARS_MUSIC "slender/gimm20dollars_v2.wav"
#define MARBLEHORNETS_STATIC "slender/staticlight.wav"

#define MUSIC_CHAN SNDCHAN_AUTO
#define MUSIC_GOTPAGES1_SOUND "slender/newambience_1.wav"
#define MUSIC_GOTPAGES2_SOUND "slender/newambience_2.wav"
#define MUSIC_GOTPAGES3_SOUND "slender/newambience_3.wav"
#define MUSIC_GOTPAGES4_SOUND "slender/newambience_4.wav"
#define MUSIC_PAGE_VOLUME 1.0

#define SF2_INTRO_DEFAULT_MUSIC "slender/intro.mp3"

#define PROXY_RAGE_MODE_SOUND "slender/proxyrage.mp3"

#define FIREBALL_SHOOT "misc/halloween/spell_fireball_cast.wav"
#define FIREBALL_IMPACT "misc/halloween/spell_fireball_impact.wav"
#define ICEBALL_IMPACT "weapons/icicle_freeze_victim_01.wav"
#define ROCKET_SHOOT "weapons/rocket_shoot.wav"
#define ROCKET_IMPACT "weapons/explode1.wav"
#define ROCKET_IMPACT2 "weapons/explode2.wav"
#define ROCKET_IMPACT3 "weapons/explode3.wav"
#define ROCKET_MODEL "models/weapons/w_models/w_rocket.mdl"
#define ROCKET_TRAIL "rockettrail"
#define ROCKET_EXPLODE_PARTICLE "ExplosionCore_MidAir"
#define GRENADE_SHOOT "weapons/grenade_launcher_shoot.wav"
#define SENTRYROCKET_SHOOT "weapons/sentry_rocket.wav"
#define ARROW_SHOOT "weapons/bow_shoot.wav"
#define GRENADE_MODEL "models/weapons/w_models/w_grenade_grenadelauncher.mdl"
#define MANGLER_SHOOT "weapons/cow_mangler_main_shot.wav"
#define MANGLER_EXPLODE1 "weapons/cow_mangler_explosion_normal_01.wav"
#define MANGLER_EXPLODE2 "weapons/cow_mangler_explosion_normal_02.wav"
#define MANGLER_EXPLODE3 "weapons/cow_mangler_explosion_normal_03.wav"
#define BASEBALL_SHOOT "weapons/bat_baseball_hit1.wav"
#define BASEBALL_MODEL "weapons/w_models/w_baseball.mdl"

#define JARATE_HITPLAYER "weapons/jar_single.wav"
#define JARATE_PARTICLE "peejar_impact"
#define MILK_PARTICLE "peejar_impact_milk"
#define GAS_PARTICLE "gas_can_impact_blue"
#define STUN_HITPLAYER "weapons/icicle_freeze_victim_01.wav"
#define STUN_PARTICLE "xms_icicle_melt"
#define ELECTRIC_RED_PARTICLE "electrocuted_gibbed_red"
#define ELECTRIC_BLUE_PARTICLE "electrocuted_gibbed_red"

//Page Rewards
#define EXPLODE_PLAYER "items/pumpkin_explode1.wav"
#define UBER_ROLL "misc/halloween/spell_overheal.wav"
#define NO_EFFECT_ROLL "player/taunt_sorcery_fail.wav"
#define BLEED_ROLL "items/powerup_pickup_plague_infected.wav"
#define CRIT_ROLL "items/powerup_pickup_crits.wav"
#define LOSE_SPRINT_ROLL "misc/banana_slip.wav"
#define JARATE_ROLL "weapons/jar_explode.wav"
#define GAS_ROLL "weapons/gas_can_explode.wav"

#define FIREWORK_EXPLOSION	"weapons/flare_detonator_explode.wav"
#define FIREWORK_START "weapons/flare_detonator_launch.wav"
#define FIREWORK_PARTICLE	"burningplayer_rainbow_flame"

#define GENERIC_ROLL_TICK_1 "ui/buttonrollover.wav"
#define GENERIC_ROLL_TICK_2 "ui/buttonrollover.wav"

#define MINICRIT_BUFF "weapons/buff_banner_flag.wav"

#define HYPERSNATCHER_NIGHTAMRE_1 "slender/snatcher/nightmare1.wav"
#define HYPERSNATCHER_NIGHTAMRE_2 "slender/snatcher/nightmare2.wav"
#define HYPERSNATCHER_NIGHTAMRE_3 "slender/snatcher/nightmare3.wav"
#define HYPERSNATCHER_NIGHTAMRE_4 "slender/snatcher/nightmare4.wav"
#define HYPERSNATCHER_NIGHTAMRE_5 "slender/snatcher/nightmare5.wav"
#define SNATCHER_APOLLYON_1 "slender/snatcher/apollyon1.wav"
#define SNATCHER_APOLLYON_2 "slender/snatcher/apollyon2.wav"
#define SNATCHER_APOLLYON_3 "slender/snatcher/apollyon3.wav"

#define RENEVANT_MAXWAVES 5

#define NULLSOUND "misc/null.wav"

#define NINETYSMUSIC "slender/sf2modified_runninginthe90s_v2.wav"
#define TRIPLEBOSSESMUSIC "slender/sf2modified_triplebosses_v2.wav"

#define TRAP_DEPLOY "slender/modified_traps/beartrap/trap_deploy.mp3"
#define TRAP_CLOSE "slender/modified_traps/beartrap/trap_close.mp3"
#define TRAP_MODEL "models/mentrillum/traps/beartrap.mdl"

#define LASER_MODEL "sprites/laser.vmt"

#define SF2_HUD_TEXT_COLOR_R 127
#define SF2_HUD_TEXT_COLOR_G 167
#define SF2_HUD_TEXT_COLOR_B 141
#define SF2_HUD_TEXT_COLOR_A 255

enum struct MuteMode
{
	int MuteMode_Normal;
	int MuteMode_DontHearOtherTeam;
	int MuteMode_DontHearOtherTeamIfNotProxy;
}

enum struct FlashlightTemperature
{
	int FlashlightTemperature_6000;
	int FlashlightTemperature_1000;
	int FlashlightTemperature_2000;
	int FlashlightTemperature_3000;
	int FlashlightTemperature_4000;
	int FlashlightTemperature_5000;
	int FlashlightTemperature_7000;
	int FlashlightTemperature_8000;
	int FlashlightTemperature_9000;
	int FlashlightTemperature_10000;
}

char g_strSoundNightmareMode[][] =
{
 "ambient/halloween/thunder_04.wav",
 "ambient/halloween/thunder_05.wav",
 "ambient/halloween/thunder_08.wav",
 "ambient/halloween/mysterious_perc_09.wav",
 "ambient/halloween/mysterious_perc_09.wav",
 "ambient/halloween/windgust_08.wav"
};

static const char g_sPageCollectDuckSounds[][] = 
{
	"ambient/bumper_car_quack1.wav",
	"ambient/bumper_car_quack2.wav",
	"ambient/bumper_car_quack3.wav",
	"ambient/bumper_car_quack4.wav",
	"ambient/bumper_car_quack5.wav",
	"ambient/bumper_car_quack9.wav",
	"ambient/bumper_car_quack11.wav"
};

//Update
bool g_bSeeUpdateMenu[MAXPLAYERS+1] = false;
//Command
bool g_bAdminNoPoints[MAXPLAYERS+1] = false;

// Offsets.
int g_offsPlayerFOV = -1;
int g_offsPlayerDefaultFOV = -1;
int g_offsPlayerFogCtrl = -1;
int g_offsPlayerPunchAngle = -1;
int g_offsPlayerPunchAngleVel = -1;
int g_offsFogCtrlEnable = -1;
int g_offsFogCtrlEnd = -1;
int g_offsCollisionGroup = -1;

//Commands
float g_flLastCommandTime[MAXPLAYERS + 1];

bool g_bEnabled;

KeyValues g_hConfig;
Handle g_hRestrictedWeaponsConfig;
Handle g_hSpecialRoundsConfig;

ArrayList g_hPageMusicRanges;
int g_iPageMusicActiveIndex[MAXPLAYERS + 1] = { -1, ... };

int g_iSlenderModel[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_iSlenderPoseEnt[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_iSlenderCopyMaster[MAX_BOSSES] = { -1, ... };
float g_flSlenderEyePosOffset[MAX_BOSSES][3];
float g_flSlenderEyeAngOffset[MAX_BOSSES][3];
float g_flSlenderDetectMins[MAX_BOSSES][3];
float g_flSlenderDetectMaxs[MAX_BOSSES][3];
Handle g_hSlenderThink[MAX_BOSSES];
Handle g_hSlenderEntityThink[MAX_BOSSES];
Handle g_hSlenderFakeTimer[MAX_BOSSES];
Handle g_hSlenderDeathCamTimer[MAX_BOSSES];
float g_flSlenderLastKill[MAX_BOSSES];
int g_iSlenderState[MAX_BOSSES];
int g_iSlenderTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_bSlenderSpawning[MAX_BOSSES] = false;
float g_flSlenderAcceleration[MAX_BOSSES];
float g_flSlenderGoalPos[MAX_BOSSES][3];
float g_flSlenderStaticRadius[MAX_BOSSES][Difficulty_Max];
float g_flSlenderChaseDeathPosition[MAX_BOSSES][3];
bool g_bSlenderChaseDeathPosition[MAX_BOSSES];
float g_flSlenderIdleAnimationPlaybackRate[MAX_BOSSES];
float g_flSlenderWalkAnimationPlaybackRate[MAX_BOSSES];
float g_flSlenderRunAnimationPlaybackRate[MAX_BOSSES];
float g_flSlenderJumpSpeed[MAX_BOSSES];
bool g_bSlenderHasBurnKillEffect[MAX_BOSSES];
bool g_bSlenderHasCloakKillEffect[MAX_BOSSES];
bool g_bSlenderHasDecapKillEffect[MAX_BOSSES];
bool g_bSlenderHasGibKillEffect[MAX_BOSSES];
bool g_bSlenderHasGoldKillEffect[MAX_BOSSES];
bool g_bSlenderHasIceKillEffect[MAX_BOSSES];
bool g_bSlenderHasElectrocuteKillEffect[MAX_BOSSES];
bool g_bSlenderHasAshKillEffect[MAX_BOSSES];
bool g_bSlenderHasDisintegrateKillEffect[MAX_BOSSES];
bool g_bSlenderHasDeleteKillEffect[MAX_BOSSES];
bool g_bSlenderHasPushRagdollOnKill[MAX_BOSSES];
bool g_bSlenderHasDissolveRagdollOnKill[MAX_BOSSES];
int g_iSlenderDissolveRagdollType[MAX_BOSSES];
bool g_bSlenderHasPlasmaRagdollOnKill[MAX_BOSSES];
bool g_bSlenderHasResizeRagdollOnKill[MAX_BOSSES];
float g_flSlenderResizeRagdollHands[MAX_BOSSES];
float g_flSlenderResizeRagdollHead[MAX_BOSSES];
float g_flSlenderResizeRagdollTorso[MAX_BOSSES];
bool g_bSlenderUseCustomOutlines[MAX_BOSSES];
int g_iSlenderOutlineColorR[MAX_BOSSES];
int g_iSlenderOutlineColorG[MAX_BOSSES];
int g_iSlenderOutlineColorB[MAX_BOSSES];
int g_iSlenderOutlineTransparency[MAX_BOSSES];

int g_iProjectileFlags[2049] = { 0, ... };

char g_sSlenderCloakOnSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderCloakOffSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderJarateHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderMilkHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderGasHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderStunHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderFireballExplodeSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderFireballShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderIceballImpactSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderRocketExplodeSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderRocketShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderGrenadeShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderSentryRocketShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderArrowShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderManglerShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderBaseballShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderEngineSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderShockwaveBeamSprite[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderShockwaveHaloSprite[MAX_BOSSES][PLATFORM_MAX_PATH];

int g_iSlenderTeleportTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_iSlenderProxyTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_bSlenderTeleportTargetIsCamping[MAX_BOSSES] = false;

float g_flSlenderNextTeleportTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportTargetTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportMinRange[MAX_BOSSES][Difficulty_Max];
float g_flSlenderTeleportMaxRange[MAX_BOSSES][Difficulty_Max];
float g_flSlenderTeleportMaxTargetTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTeleportMaxTargetStress[MAX_BOSSES] = { 0.0, ... };
float g_flSlenderTeleportPlayersRestTime[MAX_BOSSES][MAXPLAYERS + 1];

bool g_bSlenderInDeathcam[MAX_BOSSES] = false;

int g_iSlenderBoxingBossCount = 0;
int g_iSlenderBoxingBossKilled = 0;
bool g_bSlenderBoxingBossIsKilled[MAX_BOSSES] = false;

int g_iRenevantWaveNumber = 0;
int g_iRenevantFinaleTime = 0;
bool g_bRenevantMultiEffect = false;
bool g_bRenevantBeaconEffect = false;

//The global timer replacing OnGameFrame()
Handle g_hOnGameFrameTimer;

// For boss type 2
// General variables
int g_iSlenderHealth[MAX_BOSSES];
bool g_bSlenderAttacking[MAX_BOSSES];
bool g_bSlenderGiveUp[MAX_BOSSES];
Handle g_hSlenderAttackTimer[MAX_BOSSES];
Handle g_hSlenderLaserTimer[MAX_BOSSES];
Handle g_hSlenderBackupAtkTimer[MAX_BOSSES];
Handle g_hSlenderChaseInitialTimer[MAX_BOSSES];
Handle g_hSlenderRage1Timer[MAX_BOSSES];
Handle g_hSlenderRage2Timer[MAX_BOSSES];
Handle g_hSlenderRage3Timer[MAX_BOSSES];
Handle g_hSlenderSpawnTimer[MAX_BOSSES];
Handle g_hSlenderHealTimer[MAX_BOSSES];
Handle g_hSlenderHealDelayTimer[MAX_BOSSES];
Handle g_hSlenderHealEventTimer[MAX_BOSSES];
Handle g_hSlenderStartFleeTimer[MAX_BOSSES];

int g_iSlenderInterruptConditions[MAX_BOSSES];
float g_flSlenderLastFoundPlayer[MAX_BOSSES][MAXPLAYERS + 1];
float g_flSlenderLastFoundPlayerPos[MAX_BOSSES][MAXPLAYERS + 1][3];
float g_flSlenderNextPathTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderLastCalculPathTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderCalculatedWalkSpeed[MAX_BOSSES];
float g_flSlenderCalculatedSpeed[MAX_BOSSES];
float g_flSlenderCalculatedAirSpeed[MAX_BOSSES];
float g_flSlenderTimeUntilNoPersistence[MAX_BOSSES];

float g_flSlenderProxyTeleportMinRange[MAX_BOSSES];
float g_flSlenderProxyTeleportMaxRange[MAX_BOSSES];

// Sound variables
float g_flSlenderTargetSoundLastTime[MAX_BOSSES] = { -1.0, ... };
SoundType g_iSlenderTargetSoundType[MAX_BOSSES] = { SoundType_None, ... };
float g_flSlenderTargetSoundMasterPos[MAX_BOSSES][3]; // to determine hearing focus
float g_flSlenderTargetSoundTempPos[MAX_BOSSES][3];
float g_flSlenderTargetSoundDiscardMasterPosTime[MAX_BOSSES];
bool g_bSlenderInvestigatingSound[MAX_BOSSES];
int g_iSlenderTargetSoundCount[MAX_BOSSES];
int g_iSlenderAutoChaseCount[MAX_BOSSES];
float g_flSlenderAutoChaseCooldown[MAX_BOSSES];
int g_iSlenderSoundTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_bAutoChasingLoudPlayer[MAX_BOSSES];
float g_flSlenderLastHeardVoice[MAX_BOSSES];
float g_flSlenderLastHeardFootstep[MAX_BOSSES];
float g_flSlenderLastHeardWeapon[MAX_BOSSES];

float g_flSlenderNextStunTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextJumpScare[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextVoiceSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextMoanSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextWanderPos[MAX_BOSSES][Difficulty_Max];
float g_flSlenderNextCloakTime[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextTrapPlacement[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextFootstepIdleSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextFootstepWalkSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextFootstepRunSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextFootstepStunSound[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderNextFootstepAttackSound[MAX_BOSSES] = { -1.0, ... };

float g_flSlenderIdleFootstepTime[MAX_BOSSES];
float g_flSlenderWalkFootstepTime[MAX_BOSSES];
float g_flSlenderRunFootstepTime[MAX_BOSSES];
float g_flSlenderStunFootstepTime[MAX_BOSSES];
float g_flSlenderAttackFootstepTime[MAX_BOSSES];

float g_flSlenderTimeUntilRecover[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilAlert[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilIdle[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilChase[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilKill[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilNextProxy[MAX_BOSSES] = { -1.0, ... };
float g_flSlenderTimeUntilAttackEnd[MAX_BOSSES] = {-1.0, ... };

bool g_bSlenderInBacon[MAX_BOSSES];

int g_iNightvisionType = 0;

//Healthbar
int g_ihealthBar;

// Page data.
enum struct SF2PageEntityData
{
	int EntRef;
	char CollectSound[PLATFORM_MAX_PATH];
	int CollectSoundPitch;
}

ArrayList g_hPages;
int g_iPageCount;
int g_iPageMax;
float g_flPageFoundLastTime;
bool g_bPageRef;
char g_strPageRefModel[PLATFORM_MAX_PATH];
float g_flPageRefModelScale;

static Handle g_hPlayerIntroMusicTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

// Seeing Mr. Slendy data.

float g_flLastVisibilityProcess[MAXPLAYERS + 1];
bool g_bPlayerSeesSlender[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerSeesSlenderLastTime[MAXPLAYERS + 1][MAX_BOSSES];

float g_flPlayerSightSoundNextTime[MAXPLAYERS + 1][MAX_BOSSES];

float g_flPlayerScareLastTime[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerScareNextTime[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerStaticAmount[MAXPLAYERS + 1];

int g_iNPCPlayerScareVictin[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_bNPCChasingScareVictin[MAX_BOSSES];
bool g_bNPCLostChasingScareVictim[MAX_BOSSES];
bool g_bPlayerScaredByBoss[MAXPLAYERS + 1][MAX_BOSSES];

bool g_bNPCVelocityCancel[MAX_BOSSES];

bool g_bNPCAlertedCopy[MAX_BOSSES];
bool g_bNPCStopAlertingCopies[MAX_BOSSES];
Handle g_hNPCResetAlertCopyTimer[MAX_BOSSES];
Handle g_hNPCRegisterAlertingCopiesTimer[MAX_BOSSES];

//Boxing data
Handle g_hSlenderBurnTimer[MAX_BOSSES];
Handle g_hSlenderBleedTimer[MAX_BOSSES];
Handle g_hSlenderMarkedTimer[MAX_BOSSES];
Handle g_hSlenderMilkedTimer[MAX_BOSSES];
Handle g_hSlenderGasTimer[MAX_BOSSES];
Handle g_hSlenderJarateTimer[MAX_BOSSES];
float g_flSlenderStopBurning[MAX_BOSSES];
float g_flSlenderStopBleeding[MAX_BOSSES];
bool g_bSlenderIsBurning[MAX_BOSSES]; //This is for the Sun-on-a-Stick
bool g_bSlenderIsMarked[MAX_BOSSES]; //For mini-crits and Bushwacka
bool g_bSlenderIsMilked[MAX_BOSSES];
bool g_bSlenderIsGassed[MAX_BOSSES];
bool g_bSlenderIsJarate[MAX_BOSSES];
int g_iPlayerHitsToCrits[MAXPLAYERS + 1];
int g_iPlayerHitsToHeads[MAXPLAYERS + 1];

static bool g_bPlayersAreCritted = false;
static bool g_bPlayersAreMiniCritted = false;

bool g_bPlayerIn1UpCondition[MAXPLAYERS + 1];
bool g_bPlayerDied1Up[MAXPLAYERS + 1];

float g_flPlayerLastChaseBossEncounterTime[MAXPLAYERS + 1][MAX_BOSSES];

// Player static data.
int g_iPlayerStaticMode[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerStaticIncreaseRate[MAXPLAYERS + 1];
float g_flPlayerStaticDecreaseRate[MAXPLAYERS + 1];
Handle g_hPlayerStaticTimer[MAXPLAYERS + 1];
int g_iPlayerStaticMaster[MAXPLAYERS + 1] = { -1, ... };
char g_strPlayerStaticSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char g_strPlayerLastStaticSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerLastStaticTime[MAXPLAYERS + 1];
float g_flPlayerLastStaticVolume[MAXPLAYERS + 1];
Handle g_hPlayerLastStaticTimer[MAXPLAYERS + 1];

// Static shake data.
int g_iPlayerStaticShakeMaster[MAXPLAYERS + 1];
bool g_bPlayerInStaticShake[MAXPLAYERS + 1];
char g_strPlayerStaticShakeSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerStaticShakeMinVolume[MAXPLAYERS + 1];
float g_flPlayerStaticShakeMaxVolume[MAXPLAYERS + 1];

float g_flPlayerProxyNextVoiceSound[MAXPLAYERS + 1];

bool g_bPlayerTrapped[MAXPLAYERS + 1];
int g_iPlayerTrapCount[MAXPLAYERS + 1];

int g_iPlayerBossKillSubject[MAXPLAYERS + 1];

// Difficulty
bool g_bPlayerCalledForNightmare[MAXPLAYERS + 1];
bool g_bProxySurvivalRageMode = false;

int g_iPlayerRandomClassNumber[MAXPLAYERS + 1];

// Hint data.
enum
{
	PlayerHint_Sprint = 0,
	PlayerHint_Flashlight,
	PlayerHint_MainMenu,
	PlayerHint_Blink,
	PlayerHint_Trap,
	PlayerHint_MaxNum
};

enum struct PlayerPreferences
{
	bool PlayerPreference_PvPAutoSpawn;
	bool PlayerPreference_FilmGrain;
	bool PlayerPreference_ShowHints;
	bool PlayerPreference_EnableProxySelection;
	bool PlayerPreference_ProjectedFlashlight;
	
	int PlayerPreference_MuteMode; //0 = Normal, 1 = Opposing Team, 2 = Opposing Team Proxy Ignore
	int PlayerPreference_FlashlightTemperature; //1 = 1000, 2 = 2000, 3 = 3000, 4 = 4000, 5 = 5000, 6 = 6000, 7 = 7000, 8 = 8000, 9 = 9000, 10 = 10000
}

bool g_bPlayerHints[MAXPLAYERS + 1][PlayerHint_MaxNum];
PlayerPreferences g_iPlayerPreferences[MAXPLAYERS + 1];

//Particle data.
enum
{
	CriticalHit = 0,
	MiniCritHit,
	ZapParticle,
	FireworksRED,
	FireworksBLU,
	TeleportedInBlu,
	MaxParticle
};

int g_iParticle[MaxParticle] = -1;

// Player data.
bool g_bPlayerIsExitCamping[MAXPLAYERS + 1];
int g_iPlayerLastButtons[MAXPLAYERS + 1];
bool g_bPlayerChoseTeam[MAXPLAYERS + 1];
bool g_bPlayerEliminated[MAXPLAYERS + 1];
bool g_bPlayerHasRegenerationItem[MAXPLAYERS + 1];
bool g_bPlayerEscaped[MAXPLAYERS + 1];
int g_iPlayerPageCount[MAXPLAYERS + 1];
int g_iPlayerQueuePoints[MAXPLAYERS + 1];
bool g_bPlayerPlaying[MAXPLAYERS + 1];
bool g_bBackStabbed[MAXPLAYERS + 1];
Handle g_hPlayerOverlayCheck[MAXPLAYERS + 1];

Handle g_hPlayerSwitchBlueTimer[MAXPLAYERS + 1];

// Player stress data.
float g_flPlayerStress[MAXPLAYERS + 1];
float g_flPlayerStressNextUpdateTime[MAXPLAYERS + 1];

// Proxy data.
bool g_bPlayerProxy[MAXPLAYERS + 1];
bool g_bPlayerProxyAvailable[MAXPLAYERS + 1];
Handle g_hPlayerProxyAvailableTimer[MAXPLAYERS + 1];
bool g_bPlayerProxyAvailableInForce[MAXPLAYERS + 1];
int g_iPlayerProxyAvailableCount[MAXPLAYERS + 1];
int g_iPlayerProxyMaster[MAXPLAYERS + 1];
int g_iPlayerProxyControl[MAXPLAYERS + 1];
Handle g_hPlayerProxyControlTimer[MAXPLAYERS + 1];
float g_flPlayerProxyControlRate[MAXPLAYERS + 1];
Handle g_flPlayerProxyVoiceTimer[MAXPLAYERS + 1];
int g_iPlayerProxyAskMaster[MAXPLAYERS + 1] = { -1, ... };
float g_iPlayerProxyAskPosition[MAXPLAYERS + 1][3];
int g_iPlayerProxyAskSpawnPoint[MAXPLAYERS + 1] = { -1, ... };

int g_iPlayerDesiredFOV[MAXPLAYERS + 1];

Handle g_hPlayerPostWeaponsTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
Handle g_hPlayerIgniteTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
Handle g_hPlayerResetIgnite[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
Handle g_hPlayerPageRewardTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
Handle g_hPlayerPageRewardCycleTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };
Handle g_hPlayerFireworkTimer[MAXPLAYERS + 1] = { INVALID_HANDLE, ... };

bool g_bPlayerGettingPageReward[MAXPLAYERS + 1] = false;

// Music system.
int g_iPlayerMusicFlags[MAXPLAYERS + 1];
char g_strPlayerMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerMusicVolume[MAXPLAYERS + 1];
float g_flPlayerMusicTargetVolume[MAXPLAYERS + 1];
Handle g_hPlayerMusicTimer[MAXPLAYERS + 1];
int g_iPlayerPageMusicMaster[MAXPLAYERS + 1];

// Chase music system, which apparently also uses the alert song system. And the idle sound system.
char g_strPlayerChaseMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char g_strPlayerChaseMusicSee[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerChaseMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerChaseMusicSeeVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayerChaseMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayerChaseMusicSeeTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_iPlayerChaseMusicMaster[MAXPLAYERS + 1] = { -1, ... };
int g_iPlayerChaseMusicSeeMaster[MAXPLAYERS + 1] = { -1, ... };

char g_strPlayerAlertMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerAlertMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayerAlertMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_iPlayerAlertMusicMaster[MAXPLAYERS + 1] = { -1, ... };


char g_strPlayer20DollarsMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayer20DollarsMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_hPlayer20DollarsMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_iPlayer20DollarsMusicMaster[MAXPLAYERS + 1] = { -1, ... };


char g_strPlayer90sMusic[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayer90sMusicVolumes[MAXPLAYERS + 1];
Handle g_hPlayer90sMusicTimer[MAXPLAYERS + 1];


SF2RoundState g_iRoundState = SF2RoundState_Invalid;
bool g_bRoundGrace = false;
float g_flRoundDifficultyModifier = DIFFICULTY_NORMAL;
bool g_bRoundInfiniteFlashlight = false;
bool g_bIsSurvivalMap = false;
bool g_bIsRaidMap = false;
bool g_bIsProxyMap = false;
bool g_bBossesChaseEndlessly = false;
bool g_bIsBoxingMap = false;
bool g_bIsRenevantMap = false;
bool g_bIsSlaughterRunMap = false;
bool g_bRoundInfiniteBlink = false;
bool g_bRoundInfiniteSprint = false;

Handle g_hRoundGraceTimer = INVALID_HANDLE;
static Handle g_hRoundTimer = INVALID_HANDLE;
static Handle g_hVoteTimer = INVALID_HANDLE;
Handle g_hRenevantWaveTimer = INVALID_HANDLE;
static char g_strRoundBossProfile[SF2_MAX_PROFILE_NAME_LENGTH];
static char g_strRoundBoxingBossProfile[SF2_MAX_PROFILE_NAME_LENGTH];

static int g_iRoundCount = 0;
static int g_iRoundEndCount = 0;
static int g_iRoundActiveCount = 0;
int g_iRoundTime = 0;
int g_iSpecialRoundTime = 0;
static int g_iTimeEscape = 0;
int g_iRoundTimeLimit = 0;
int g_iRoundEscapeTimeLimit = 0;
int g_iRoundTimeGainFromPage = 0;
bool g_bRoundHasEscapeObjective = false;
bool g_bRoundStopPageMusicOnEscape = false;

static int g_iRoundEscapePointEntity = INVALID_ENT_REFERENCE;

static int g_iRoundIntroFadeColor[4] = { 255, ... };
static float g_flRoundIntroFadeHoldTime;
static float g_flRoundIntroFadeDuration;
static Handle g_hRoundIntroTimer = INVALID_HANDLE;
static bool g_bRoundIntroTextDefault = true;
static Handle g_hRoundIntroTextTimer = INVALID_HANDLE;
static int g_iRoundIntroText;
char g_strRoundIntroMusic[PLATFORM_MAX_PATH] = "";
static char g_strPageCollectSound[PLATFORM_MAX_PATH] = "";
static int g_iPageSoundPitch = 100;
char sCurrentMusicTrack[PLATFORM_MAX_PATH], sCurrentMusicTrackNormal[PLATFORM_MAX_PATH], sCurrentMusicTrackHard[PLATFORM_MAX_PATH], sCurrentMusicTrackInsane[PLATFORM_MAX_PATH], sCurrentMusicTrackNightmare[PLATFORM_MAX_PATH], sCurrentMusicTrackApollyon[PLATFORM_MAX_PATH];

static int g_iRoundWarmupRoundCount = 0;

static bool g_bRoundWaitingForPlayers = false;

// Special round variables.
bool g_bSpecialRound = false;

bool g_bSpecialRoundNew = false;
bool g_bSpecialRoundContinuous = false;
int g_iSpecialRoundCount = 1;
bool g_bPlayerPlayedSpecialRound[MAXPLAYERS + 1] = { true, ... };

// int boss round variables.
static bool g_bNewBossRound = false;
static bool g_bNewBossRoundNew = false;
static bool g_bNewBossRoundContinuous = false;
static int g_iNewBossRoundCount = 1;

static bool g_bPlayerPlayedNewBossRound[MAXPLAYERS + 1] = { true, ... };
static char g_strNewBossRoundProfile[64] = "";

static Handle g_hRoundMessagesTimer = INVALID_HANDLE;
static int g_iRoundMessagesNum = 0;

static Handle g_hBossCountUpdateTimer = INVALID_HANDLE;
static Handle g_hClientAverageUpdateTimer = INVALID_HANDLE;
static Handle g_hBlueNightvisionOutlineTimer = INVALID_HANDLE;

// Server variables.
ConVar g_cvVersion;
ConVar g_cvEnabled;
ConVar g_cvSlenderMapsOnly;
ConVar g_cvPlayerViewbobEnabled;
ConVar g_cvPlayerShakeEnabled;
ConVar g_cvPlayerShakeFrequencyMax;
ConVar g_cvPlayerShakeAmplitudeMax;
ConVar g_cvGraceTime;
ConVar g_cvAllChat;
ConVar g_cv20Dollars;
ConVar g_cvMaxPlayers;
ConVar g_cvMaxPlayersOverride;
ConVar g_cvCampingEnabled;
ConVar g_cvCampingMaxStrikes;
ConVar g_cvCampingStrikesWarn;
ConVar g_cvExitCampingTimeAllowed;
ConVar g_cvCampingMinDistance;
ConVar g_cvCampingNoStrikeSanity;
ConVar g_cvCampingNoStrikeBossDistance;
ConVar g_cvDifficulty;
ConVar g_cvBossMain;
ConVar g_cvBossProfileOverride;
ConVar g_cvPlayerBlinkRate;
ConVar g_cvPlayerBlinkHoldTime;
ConVar g_cvSpecialRoundBehavior;
ConVar g_cvSpecialRoundForce;
ConVar g_cvSpecialRoundOverride;
ConVar g_cvSpecialRoundInterval;
ConVar g_cvNewBossRoundBehavior;
ConVar g_cvNewBossRoundInterval;
ConVar g_cvNewBossRoundForce;
ConVar g_cvIgnoreRoundWinConditions;
ConVar g_cvDisableBossCrushFix;
ConVar g_cvIgnoreRedPlayerDeathSwap;
ConVar g_cvPlayerVoiceDistance;
ConVar g_cvPlayerVoiceWallScale;
ConVar g_cvUltravisionEnabled;
ConVar g_cvUltravisionRadiusRed;
ConVar g_cvUltravisionRadiusBlue;
ConVar g_cvUltravisionBrightness;
ConVar g_cvNightvisionRadius;
ConVar g_cvNightvisionEnabled;
ConVar g_cvGhostModeConnection;
ConVar g_cvGhostModeConnectionCheck;
ConVar g_cvGhostModeConnectionTolerance;
ConVar g_cvIntroEnabled;
ConVar g_cvIntroDefaultHoldTime;
ConVar g_cvIntroDefaultFadeTime;
ConVar g_cvTimeLimit;
ConVar g_cvTimeLimitEscape;
ConVar g_cvTimeGainFromPageGrab;
ConVar g_cvWarmupRound;
ConVar g_cvWarmupRoundNum;
ConVar g_cvPlayerViewbobHurtEnabled;
ConVar g_cvPlayerViewbobSprintEnabled;
ConVar g_cvPlayerProxyWaitTime;
ConVar g_cvPlayerProxyAsk;
ConVar g_cvHalfZatoichiHealthGain;
ConVar g_cvBlockSuicideDuringRound;
ConVar g_cvRaidMap;
ConVar g_cvProxyMap;
ConVar g_cvBossChaseEndlessly;
ConVar g_cvSurvivalMap;
ConVar g_cvBoxingMap;
ConVar g_cvRenevantMap;
ConVar g_cvSlaughterRunMap;
ConVar g_cvTimeEscapeSurvival;
ConVar g_cvSlaughterRunDivisibleTime;
ConVar g_cvUseAlternateConfigDirectory;

ConVar g_cvPlayerInfiniteSprintOverride;
ConVar g_cvPlayerInfiniteFlashlightOverride;
ConVar g_cvPlayerInfiniteBlinkOverride;

ConVar g_cvGravity;
float g_flGravity;

ConVar g_cvMaxRounds;

bool g_b20Dollars;

bool g_bPlayerShakeEnabled;
bool g_bPlayerViewbobEnabled;
bool g_bPlayerViewbobHurtEnabled;
bool g_bPlayerViewbobSprintEnabled;

Handle g_hHudSync;
Handle g_hHudSync2;
Handle g_hRoundTimerSync;

Handle g_hCookie;

int g_SmokeSprite;
int g_LightningSprite;
int g_ShockwaveBeam;
int g_ShockwaveHalo;

// Global forwards.
Handle fOnBossAdded;
Handle fOnBossSpawn;
Handle fOnBossDespawn;
Handle fOnBossChangeState;
Handle fOnBossAnimationUpdate;
Handle fOnBossGetSpeed;
Handle fOnBossGetWalkSpeed;
Handle fOnBossSeeEntity;
Handle fOnBossHearEntity;
Handle fOnBossRemoved;
Handle fOnPagesSpawned;
Handle fOnRoundStateChange;
Handle fOnClientCollectPage;
Handle fOnClientBlink;
Handle fOnClientScare;
Handle fOnClientCaughtByBoss;
Handle fOnClientGiveQueuePoints;
Handle fOnClientActivateFlashlight;
Handle fOnClientDeactivateFlashlight;
Handle fOnClientBreakFlashlight;
Handle fOnClientStartSprinting;
Handle fOnClientStopSprinting;
Handle fOnClientEscape;
Handle fOnClientLooksAtBoss;
Handle fOnClientLooksAwayFromBoss;
Handle fOnClientStartDeathCam;
Handle fOnClientEndDeathCam;
Handle fOnClientGetDefaultWalkSpeed;
Handle fOnClientGetDefaultSprintSpeed;
Handle fOnClientTakeDamage;
Handle fOnClientSpawnedAsProxy;
Handle fOnClientDamagedByBoss;
Handle fOnGroupGiveQueuePoints;
Handle fOnRenevantTriggerWave;

Handle g_hSDKGetMaxHealth;
Handle g_hSDKGetLastKnownArea;
Handle g_hSDKUpdateLastKnownArea;
Handle g_hSDKWantsLagCompensationOnEntity;
Handle g_hSDKShouldTransmit;
Handle g_hSDKEquipWearable;
Handle g_hSDKPlaySpecificSequence;
Handle g_hSDKPointIsWithin;
Handle g_hSDKGetSmoothedVelocity;
Handle g_hSDKGetVectors;
Handle g_hSDKResetSequence;
Handle g_hSDKStudioFrameAdvance;
Handle g_hSDKStartTouch;
Handle g_hSDKEndTouch;
Handle g_hSDKWeaponSwitch;
Handle g_hSDKWeaponGetCustomDamageType;
Handle g_hSDKProjectileCanCollideWithTeammates;

int g_iOffset_m_id;

int g_iServerOS;

// SourceTV userid used for boss name
int g_iSourceTVUserID = -1;
char g_sOldSourceTVClientName[64];
Handle g_hTimerChangeSourceTVBotName;

//Fail Timer
Handle g_hTimerFail;

#if defined DEBUG
#include "sf2/debug.sp"
#endif
#include "sf2/nextbot/nextbot.sp"
#include "sf2/stocks.sp"
#include "sf2/baseanimating.sp"
#include "sf2/logging.sp"
#include "sf2/profiles.sp"
#include "sf2/nav.sp"
#include "sf2/effects.sp"
#include "sf2/playergroups.sp"
#include "sf2/mapentities.sp"
#include "sf2/menus.sp"
#include "sf2/tutorial.sp"
#include "sf2/npc.sp"
#include "sf2/pvp.sp"
#include "sf2/client.sp"
#include "sf2/specialround.sp"
#include "sf2/adminmenu.sp"
#include "sf2/traps.sp"


#define SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND "ui/item_acquired.wav"

SF2GamerulesEntity g_GamerulesEntity = view_as<SF2GamerulesEntity>(-1);
SF2LogicRenevantEntity g_RenevantLogicEntity = view_as<SF2LogicRenevantEntity>(-1);

//	==========================================================
//	GENERAL PLUGIN HOOK FUNCTIONS
//	==========================================================

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error,int err_max)
{
	RegPluginLibrary("sf2");
	
	fOnBossAdded = CreateGlobalForward("SF2_OnBossAdded", ET_Ignore, Param_Cell);
	fOnBossSpawn = CreateGlobalForward("SF2_OnBossSpawn", ET_Ignore, Param_Cell);
	fOnBossDespawn = CreateGlobalForward("SF2_OnBossDespawn", ET_Ignore, Param_Cell);
	fOnBossChangeState = CreateGlobalForward("SF2_OnBossChangeState", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	fOnBossAnimationUpdate = CreateGlobalForward("SF2_OnBossAnimationUpdate", ET_Hook, Param_Cell);
	fOnBossGetSpeed = CreateGlobalForward("SF2_OnBossGetSpeed", ET_Hook, Param_Cell, Param_FloatByRef);
	fOnBossGetWalkSpeed = CreateGlobalForward("SF2_OnBossGetWalkSpeed", ET_Hook, Param_Cell, Param_FloatByRef);
	fOnBossHearEntity = CreateGlobalForward("SF2_OnBossHearEntity", ET_Hook, Param_Cell, Param_Cell);
	fOnBossSeeEntity = CreateGlobalForward("SF2_OnBossSeeEntity", ET_Hook, Param_Cell, Param_Cell);
	fOnBossRemoved = CreateGlobalForward("SF2_OnBossRemoved", ET_Ignore, Param_Cell);
	fOnPagesSpawned = CreateGlobalForward("SF2_OnPagesSpawned", ET_Ignore);
	fOnRoundStateChange = CreateGlobalForward("SF2_OnRoundStateChange", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientCollectPage = CreateGlobalForward("SF2_OnClientCollectPage", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientBlink = CreateGlobalForward("SF2_OnClientBlink", ET_Ignore, Param_Cell);
	fOnClientScare = CreateGlobalForward("SF2_OnClientScare", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientCaughtByBoss = CreateGlobalForward("SF2_OnClientCaughtByBoss", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientGiveQueuePoints = CreateGlobalForward("SF2_OnClientGiveQueuePoints", ET_Hook, Param_Cell, Param_CellByRef);
	fOnClientActivateFlashlight = CreateGlobalForward("SF2_OnClientActivateFlashlight", ET_Ignore, Param_Cell);
	fOnClientDeactivateFlashlight = CreateGlobalForward("SF2_OnClientDeactivateFlashlight", ET_Ignore, Param_Cell);
	fOnClientBreakFlashlight = CreateGlobalForward("SF2_OnClientBreakFlashlight", ET_Ignore, Param_Cell);
	fOnClientStartSprinting = CreateGlobalForward("SF2_OnClientStartSprinting", ET_Ignore, Param_Cell);
	fOnClientStopSprinting = CreateGlobalForward("SF2_OnClientStopSprinting", ET_Ignore, Param_Cell);
	fOnClientEscape = CreateGlobalForward("SF2_OnClientEscape", ET_Ignore, Param_Cell);
	fOnClientLooksAtBoss = CreateGlobalForward("SF2_OnClientLooksAtBoss", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientLooksAwayFromBoss = CreateGlobalForward("SF2_OnClientLooksAwayFromBoss", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientStartDeathCam = CreateGlobalForward("SF2_OnClientStartDeathCam", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientEndDeathCam = CreateGlobalForward("SF2_OnClientEndDeathCam", ET_Ignore, Param_Cell, Param_Cell);
	fOnClientGetDefaultWalkSpeed = CreateGlobalForward("SF2_OnClientGetDefaultWalkSpeed", ET_Hook, Param_Cell, Param_CellByRef);
	fOnClientGetDefaultSprintSpeed = CreateGlobalForward("SF2_OnClientGetDefaultSprintSpeed", ET_Hook, Param_Cell, Param_CellByRef);
	fOnClientTakeDamage = CreateGlobalForward("SF2_OnClientTakeDamage", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	fOnClientSpawnedAsProxy = CreateGlobalForward("SF2_OnClientSpawnedAsProxy", ET_Ignore, Param_Cell);
	fOnClientDamagedByBoss = CreateGlobalForward("SF2_OnClientDamagedByBoss", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	fOnGroupGiveQueuePoints = CreateGlobalForward("SF2_OnGroupGiveQueuePoints", ET_Hook, Param_Cell, Param_CellByRef);
	fOnRenevantTriggerWave = CreateGlobalForward("SF2_OnRenevantWaveTrigger", ET_Ignore, Param_Cell);
	
	CreateNative("SF2_IsRunning", Native_IsRunning);
	CreateNative("SF2_GetRoundState", Native_GetRoundState);
	CreateNative("SF2_IsRoundInGracePeriod", Native_IsRoundInGracePeriod);
	CreateNative("SF2_GetCurrentDifficulty", Native_GetCurrentDifficulty);
	CreateNative("SF2_GetDifficultyModifier", Native_GetDifficultyModifier);
	CreateNative("SF2_IsClientEliminated", Native_IsClientEliminated);
	CreateNative("SF2_IsClientInGhostMode", Native_IsClientInGhostMode);
	CreateNative("SF2_IsClientProxy", Native_IsClientProxy);
	CreateNative("SF2_GetClientBlinkCount", Native_GetClientBlinkCount);
	CreateNative("SF2_IsClientBlinking", Native_IsClientBlinking);
	CreateNative("SF2_GetClientBlinkMeter", Native_GetClientBlinkMeter);
	CreateNative("SF2_SetClientBlinkMeter", Native_SetClientBlinkMeter);
	CreateNative("SF2_GetClientProxyMaster", Native_GetClientProxyMaster);
	CreateNative("SF2_GetClientProxyControlAmount", Native_GetClientProxyControlAmount);
	CreateNative("SF2_GetClientProxyControlRate", Native_GetClientProxyControlRate);
	CreateNative("SF2_SetClientProxyMaster", Native_SetClientProxyMaster);
	CreateNative("SF2_SetClientProxyControlAmount", Native_SetClientProxyControlAmount);
	CreateNative("SF2_SetClientProxyControlRate", Native_SetClientProxyControlRate);
	CreateNative("SF2_IsClientLookingAtBoss", Native_IsClientLookingAtBoss);
	CreateNative("SF2_DidClientEscape", Native_DidClientEscape);
	CreateNative("SF2_ForceClientEscape", Native_ForceClientEscape);
	CreateNative("SF2_GetClientFlashlightBatteryLife", Native_GetClientFlashlightBatteryLife);
	CreateNative("SF2_SetClientFlashlightBatteryLife", Native_SetClientFlashlightBatteryLife);
	CreateNative("SF2_IsClientUsingFlashlight", Native_IsClientUsingFlashlight);
	CreateNative("SF2_GetClientSprintPoints", Native_GetClientSprintPoints);
	CreateNative("SF2_SetClientSprintPoints", Native_SetClientSprintPoints);
	CreateNative("SF2_IsClientSprinting", Native_IsClientSprinting);
	CreateNative("SF2_IsClientReallySprinting", Native_IsClientReallySprinting);
	CreateNative("SF2_IsClientTrapped", Native_IsClientTrapped);
	CreateNative("SF2_CollectAsPage", Native_CollectAsPage);
	CreateNative("SF2_GetMaxBossCount", Native_GetMaxBosses);
	CreateNative("SF2_EntIndexToBossIndex", Native_EntIndexToBossIndex);
	CreateNative("SF2_BossIndexToEntIndex", Native_BossIndexToEntIndex);
	CreateNative("SF2_BossIndexToEntIndexEx", Native_BossIndexToEntIndexEx);
	CreateNative("SF2_BossIDToBossIndex", Native_BossIDToBossIndex);
	CreateNative("SF2_BossIndexToBossID", Native_BossIndexToBossID);
	CreateNative("SF2_AddBoss", Native_AddBoss);
	CreateNative("SF2_RemoveBoss", Native_RemoveBoss);
	CreateNative("SF2_GetBossName", Native_GetBossName);
	CreateNative("SF2_GetBossType", Native_GetBossType);
	CreateNative("SF2_GetBossFlags", Native_GetBossFlags);
	CreateNative("SF2_SetBossFlags", Native_SetBossFlags);
	CreateNative("SF2_SpawnBoss", Native_SpawnBoss);
	CreateNative("SF2_DespawnBoss", Native_DespawnBoss);
	CreateNative("SF2_GetBossModelEntity", Native_GetBossModelEntity);
	CreateNative("SF2_GetBossTarget", Native_GetBossTarget);
	CreateNative("SF2_GetBossMaster", Native_GetBossMaster);
	CreateNative("SF2_GetBossState", Native_GetBossState);
	CreateNative("SF2_GetBossEyePosition", Native_GetBossEyePosition);
	CreateNative("SF2_GetBossEyePositionOffset", Native_GetBossEyePositionOffset);
	CreateNative("SF2_GetBossFOV", Native_GetBossFOV);
	CreateNative("SF2_GetBossTimeUntilNoPersistence", Native_GetBossTimeUntilNoPersistence);
	CreateNative("SF2_SetBossTimeUntilNoPersistence", Native_SetBossTimeUntilNoPersistence);
	CreateNative("SF2_GetBossTimeUntilIdle", Native_GetBossTimeUntilIdle);
	CreateNative("SF2_SetBossTimeUntilIdle", Native_SetBossTimeUntilIdle);
	CreateNative("SF2_GetBossTimeUntilAlert", Native_GetBossTimeUntilAlert);
	CreateNative("SF2_SetBossTimeUntilAlert", Native_SetBossTimeUntilAlert);
	CreateNative("SF2_IsBossStunnable", Native_IsBossStunnable);
	CreateNative("SF2_IsBossStunnableByFlashlight", Native_IsBossStunnableByFlashlight);
	CreateNative("SF2_IsBossCloaked", Native_IsBossCloaked);
	CreateNative("SF2_GetBossStunHealth", Native_GetBossStunHealth);
	CreateNative("SF2_SetBossStunHealth", Native_SetBossStunHealth);
	CreateNative("SF2_GetBossNextStunTime", Native_GetBossNextStunTime);
	CreateNative("SF2_SetBossNextStunTime", Native_SetBossNextStunTime);
	CreateNative("SF2_ForceBossGiveUp", Native_ForceBossGiveUp);
	CreateNative("SF2_GetBossGoalPosition", Native_GetBossGoalPosition);
	CreateNative("SF2_CanBossHearClient", Native_CanBossHearClient);
	CreateNative("SF2_CreateBossSoundHint", Native_CreateBossSoundHint);
	CreateNative("SF2_IsBossProfileValid", Native_IsBossProfileValid);
	CreateNative("SF2_GetBossProfileNum", Native_GetBossProfileNum);
	CreateNative("SF2_GetBossProfileFloat", Native_GetBossProfileFloat);
	CreateNative("SF2_GetBossProfileString", Native_GetBossProfileString);
	CreateNative("SF2_GetBossProfileVector", Native_GetBossProfileVector);
	CreateNative("SF2_GetRandomStringFromBossProfile", Native_GetRandomStringFromBossProfile);
	CreateNative("SF2_GetBossAttributeName", Native_GetBossAttributeName);
	CreateNative("SF2_GetBossAttributeValue", Native_GetBossAttributeValue);
	CreateNative("SF2_GetBossProjectileType", Native_GetBossProjectileType);
	CreateNative("SF2_GetBossCurrentAttackIndex", Native_GetBossCurrentAttackIndex);
	CreateNative("SF2_GetBossAttackIndexDamageType", Native_GetBossAttackIndexDamageType);
	CreateNative("SF2_GetBossAttackIndexDamage", Native_GetBossAttackIndexDamage);
	CreateNative("SF2_GetBossAttackIndexType", Native_GetBossAttackIndexType);
	CreateNative("SF2_IsSurvivalMap", Native_IsSurvivalMap);
	CreateNative("SF2_IsBoxingMap", Native_IsBoxingMap);
	CreateNative("SF2_IsRaidMap", Native_IsRaidMap);
	CreateNative("SF2_IsProxyMap", Native_IsProxyMap);
	CreateNative("SF2_IsRenevantMap", Native_IsRenevantMap);
	CreateNative("SF2_IsSlaughterRunMap", Native_IsSlaughterRunMap);
	
	PvP_InitializeAPI();
	
	SpecialRoundInitializeAPI();

	#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
	#endif
	#if defined _SteamWorks_Included
	MarkNativeAsOptional("SteamWorks_SetGameDescription");
	#endif
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("sf2.phrases");
	LoadTranslations("basetriggers.phrases");
	
	// Get offsets.
	g_offsPlayerFOV = FindSendPropInfo("CBasePlayer", "m_iFOV");
	if (g_offsPlayerFOV == -1) SetFailState("Couldn't find CBasePlayer offset for m_iFOV.");
	
	g_offsPlayerDefaultFOV = FindSendPropInfo("CBasePlayer", "m_iDefaultFOV");
	if (g_offsPlayerDefaultFOV == -1) SetFailState("Couldn't find CBasePlayer offset for m_iDefaultFOV.");
	
	g_offsPlayerFogCtrl = FindSendPropInfo("CBasePlayer", "m_PlayerFog.m_hCtrl");
	if (g_offsPlayerFogCtrl == -1) LogError("Couldn't find CBasePlayer offset for m_PlayerFog.m_hCtrl!");
	
	g_offsPlayerPunchAngle = FindSendPropInfo("CBasePlayer", "m_vecPunchAngle");
	if (g_offsPlayerPunchAngle == -1) LogError("Couldn't find CBasePlayer offset for m_vecPunchAngle!");
	
	g_offsPlayerPunchAngleVel = FindSendPropInfo("CBasePlayer", "m_vecPunchAngleVel");
	if (g_offsPlayerPunchAngleVel == -1) LogError("Couldn't find CBasePlayer offset for m_vecPunchAngleVel!");
	
	g_offsFogCtrlEnable = FindSendPropInfo("CFogController", "m_fog.enable");
	if (g_offsFogCtrlEnable == -1) LogError("Couldn't find CFogController offset for m_fog.enable!");
	
	g_offsFogCtrlEnd = FindSendPropInfo("CFogController", "m_fog.end");
	if (g_offsFogCtrlEnd == -1) LogError("Couldn't find CFogController offset for m_fog.end!");
	
	g_offsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	if (g_offsCollisionGroup == -1)  LogError("Couldn't find CBaseEntity offset for m_CollisionGroup!");
	
	g_hPages = new ArrayList(sizeof(SF2PageEntityData));
	g_hPageMusicRanges = new ArrayList(3);
	
	// Register console variables.
	g_cvVersion = CreateConVar("sf2modified_version", PLUGIN_VERSION, "The current version of Slender Fortress. DO NOT TOUCH!", FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	SetConVarString(g_cvVersion, PLUGIN_VERSION);
	
	g_cvEnabled = CreateConVar("sf2_enabled", "1", "Enable/Disable the Slender Fortress gamemode. This will take effect on map change.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_cvSlenderMapsOnly = CreateConVar("sf2_slendermapsonly", "1", "Only enable the Slender Fortress gamemode on map names prefixed with \"slender_\" or \"sf2_\".");
	
	g_cvGraceTime = CreateConVar("sf2_gracetime", "30.0");
	g_cvIntroEnabled = CreateConVar("sf2_intro_enabled", "1");
	g_cvIntroDefaultHoldTime = CreateConVar("sf2_intro_default_hold_time", "9.0");
	g_cvIntroDefaultFadeTime = CreateConVar("sf2_intro_default_fade_time", "1.0");
	
	g_cvBlockSuicideDuringRound = CreateConVar("sf2_block_suicide_during_round", "0");
	
	g_cvAllChat = CreateConVar("sf2_alltalk", "0");
	HookConVarChange(g_cvAllChat, OnConVarChanged);
	
	g_cvPlayerVoiceDistance = CreateConVar("sf2_player_voice_distance", "800.0", "The maximum distance RED can communicate in voice chat. Set to 0 if you want them to be heard at all times.", _, true, 0.0);
	g_cvPlayerVoiceWallScale = CreateConVar("sf2_player_voice_scale_blocked", "0.5", "The distance required to hear RED in voice chat will be multiplied by this amount if something is blocking them.");
	
	g_cvPlayerViewbobEnabled = CreateConVar("sf2_player_viewbob_enabled", "1", "Enable/Disable player viewbobbing.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerViewbobEnabled, OnConVarChanged);
	g_cvPlayerViewbobHurtEnabled = CreateConVar("sf2_player_viewbob_hurt_enabled", "0", "Enable/Disable player view tilting when hurt.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerViewbobHurtEnabled, OnConVarChanged);
	g_cvPlayerViewbobSprintEnabled = CreateConVar("sf2_player_viewbob_sprint_enabled", "0", "Enable/Disable player step viewbobbing when sprinting.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerViewbobSprintEnabled, OnConVarChanged);
	g_cvGravity = FindConVar("sv_gravity");
	HookConVarChange(g_cvGravity, OnConVarChanged);

	g_cvPlayerShakeEnabled = CreateConVar("sf2_player_shake_enabled", "1", "Enable/Disable player view shake during boss encounters.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cvPlayerShakeEnabled, OnConVarChanged);
	g_cvPlayerShakeFrequencyMax = CreateConVar("sf2_player_shake_frequency_max", "255", "Maximum frequency value of the shake. Should be a value between 1-255.", _, true, 1.0, true, 255.0);
	g_cvPlayerShakeAmplitudeMax = CreateConVar("sf2_player_shake_amplitude_max", "5", "Maximum amplitude value of the shake. Should be a value between 1-16.", _, true, 1.0, true, 16.0);
	
	g_cvPlayerBlinkRate = CreateConVar("sf2_player_blink_rate", "0.33", "How long (in seconds) each bar on the player's Blink meter lasts.", _, true, 0.0);
	g_cvPlayerBlinkHoldTime = CreateConVar("sf2_player_blink_holdtime", "0.15", "How long (in seconds) a player will stay in Blink mode when he or she blinks.", _, true, 0.0);
	
	g_cvUltravisionEnabled = CreateConVar("sf2_player_ultravision_enabled", "1", "Enable/Disable player Ultravision. This helps players see in the dark when their Flashlight is off or unavailable.", _, true, 0.0, true, 1.0);
	g_cvUltravisionRadiusRed = CreateConVar("sf2_player_ultravision_radius_red", "600.0");
	g_cvUltravisionRadiusBlue = CreateConVar("sf2_player_ultravision_radius_blue", "1600.0");
	g_cvNightvisionRadius = CreateConVar("sf2_player_nightvision_radius", "900.0");
	g_cvUltravisionBrightness = CreateConVar("sf2_player_ultravision_brightness", "-2");
	g_cvNightvisionEnabled = CreateConVar("sf2_player_flashlight_isnightvision", "0", "Enable/Disable flashlight replacement with nightvision",_, true, 0.0, true, 1.0);
	
	g_cvGhostModeConnection = CreateConVar("sf2_ghostmode_no_tolerance", "0", "If set on 1, it will instant kick out the client of the Ghost mode if the client has timed out.");
	g_cvGhostModeConnectionCheck = CreateConVar("sf2_ghostmode_check_connection", "1", "Checks a player's connection while in Ghost Mode. If the check fails, the client is booted out of Ghost Mode and the action and client's SteamID is logged in the main SF2 log.");
	g_cvGhostModeConnectionTolerance = CreateConVar("sf2_ghostmode_connection_tolerance", "5.0", "If sf2_ghostmode_check_connection is set to 1 and the client has timed out for at least this amount of time, the client will be booted out of Ghost Mode.");
	
	g_cv20Dollars = CreateConVar("sf2_20dollarmode", "0", "Enable/Disable $20 mode.", _, true, 0.0, true, 1.0);
	HookConVarChange(g_cv20Dollars, OnConVarChanged);
	
	g_cvMaxPlayers = CreateConVar("sf2_maxplayers", "6", "The maximum amount of players that can be in one round.", _, true, 1.0);
	HookConVarChange(g_cvMaxPlayers, OnConVarChanged);
	
	g_cvMaxPlayersOverride = CreateConVar("sf2_maxplayers_override", "-1", "Overrides the maximum amount of players that can be in one round.", _, true, -1.0);
	HookConVarChange(g_cvMaxPlayersOverride, OnConVarChanged);
	
	g_cvCampingEnabled = CreateConVar("sf2_anticamping_enabled", "1", "Enable/Disable anti-camping system for RED.", _, true, 0.0, true, 1.0);
	g_cvCampingMaxStrikes = CreateConVar("sf2_anticamping_maxstrikes", "4", "How many 5-second intervals players are allowed to stay in one spot before he/she is forced to suicide.", _, true, 0.0);
	g_cvCampingStrikesWarn = CreateConVar("sf2_anticamping_strikeswarn", "2", "The amount of strikes left where the player will be warned of camping.");
	g_cvExitCampingTimeAllowed = CreateConVar("sf2_exitcamping_allowedtime", "25.0", "The amount of time a player can stay near the exit before being flagged as camper.");
	g_cvCampingMinDistance = CreateConVar("sf2_anticamping_mindistance", "128.0", "Every 5 seconds the player has to be at least this far away from his last position 5 seconds ago or else he'll get a strike.");
	g_cvCampingNoStrikeSanity = CreateConVar("sf2_anticamping_no_strike_sanity", "0.1", "The camping system will NOT give any strikes under any circumstances if the players's Sanity is missing at least this much of his maximum Sanity (max is 1.0).");
	g_cvCampingNoStrikeBossDistance = CreateConVar("sf2_anticamping_no_strike_boss_distance", "512.0", "The camping system will NOT give any strikes under any circumstances if the player is this close to a boss (ignoring LOS).");
	g_cvBossMain = CreateConVar("sf2_boss_main", "slenderman", "The name of the main boss (its profile name, not its display name)");
	g_cvBossProfileOverride = CreateConVar("sf2_boss_profile_override", "", "Overrides which boss will be chosen next. Only applies to the first boss being chosen.");
	g_cvDifficulty = CreateConVar("sf2_difficulty", "1", "Difficulty of the game. 1 = Normal, 2 = Hard, 3 = Insane, 4 = Nightmare, 5 = Apollyon.", _, true, 1.0, true, 5.0);
	HookConVarChange(g_cvDifficulty, OnConVarChanged);
	
	g_cvSpecialRoundBehavior = CreateConVar("sf2_specialround_mode", "0", "0 = Special Round resets on next round, 1 = Special Round keeps going until all players have played (not counting spectators, recently joined players, and those who reset their queue points during the round)", _, true, 0.0, true, 1.0);
	g_cvSpecialRoundForce = CreateConVar("sf2_specialround_forceenable", "-1", "Sets whether a Special Round will occur on the next round or not.", _, true, -1.0, true, 1.0);
	g_cvSpecialRoundOverride = CreateConVar("sf2_specialround_forcetype", "-1", "Sets the type of Special Round that will be chosen on the next Special Round. Set to -1 to let the game choose.", _, true, -1.0);
	g_cvSpecialRoundInterval = CreateConVar("sf2_specialround_interval", "5", "If this many rounds are completed, the next round will be a Special Round.", _, true, 0.0);
	
	g_cvNewBossRoundBehavior = CreateConVar("sf2_newbossround_mode", "0", "0 = boss selection will return to normal after the boss round, 1 = the new boss will continue being the boss until all players in the server have played against it (not counting spectators, recently joined players, and those who reset their queue points during the round).", _, true, 0.0, true, 1.0);
	g_cvNewBossRoundInterval = CreateConVar("sf2_newbossround_interval", "3", "If this many rounds are completed, the next round's boss will be randomly chosen, but will not be the main boss.", _, true, 0.0);
	g_cvNewBossRoundForce = CreateConVar("sf2_newbossround_forceenable", "-1", "Sets whether a new boss will be chosen on the next round or not. Set to -1 to let the game choose.", _, true, -1.0, true, 1.0);
	
	g_cvIgnoreRoundWinConditions = CreateConVar("sf2_ignore_round_win_conditions", "0", "If set to 1, round will not end when RED is eliminated.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_cvIgnoreRoundWinConditions, OnConVarChanged);
	g_cvIgnoreRedPlayerDeathSwap = CreateConVar("sf2_ignore_red_player_death_team_switch", "0", "If set to 1, RED players will not switch back to the BLU team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_cvIgnoreRedPlayerDeathSwap, OnConVarChanged);
	
	g_cvDisableBossCrushFix = CreateConVar("sf2_disable_boss_crush_fix", "0", "Enables/disables the boss crushing patch from Secret Update 4, should only be turned on if the server introduces players getting stuck in bosses.", _, true, 0.0, true, 1.0);
	
	g_cvTimeLimit = CreateConVar("sf2_timelimit_default", "300", "The time limit of the round. Maps can change the time limit.", _, true, 0.0);
	g_cvTimeLimitEscape = CreateConVar("sf2_timelimit_escape_default", "90", "The time limit to escape. Maps can change the time limit.", _, true, 0.0);
	g_cvTimeGainFromPageGrab = CreateConVar("sf2_time_gain_page_grab", "12", "The time gained from grabbing a page. Maps can change the time gain amount.");
	
	g_cvWarmupRound = CreateConVar("sf2_warmupround", "1", "Enables/disables Warmup Rounds after the \"Waiting for Players\" phase.", _, true, 0.0, true, 1.0);
	g_cvWarmupRoundNum = CreateConVar("sf2_warmupround_num", "1", "Sets the amount of Warmup Rounds that occur after the \"Waiting for Players\" phase.", _, true, 0.0);
	
	g_cvPlayerProxyWaitTime = CreateConVar("sf2_player_proxy_waittime", "35", "How long (in seconds) after a player was chosen to be a Proxy must the system wait before choosing him again.");
	g_cvPlayerProxyAsk = CreateConVar("sf2_player_proxy_ask", "0", "Set to 1 if the player can choose before becoming a Proxy, set to 0 to force.");
	
	g_cvHalfZatoichiHealthGain = CreateConVar("sf2_halfzatoichi_healthgain", "20", "How much health should be gained from killing a player with the Half-Zatoichi? Set to -1 for default behavior.");
	
	g_cvPlayerInfiniteSprintOverride = CreateConVar("sf2_player_infinite_sprint_override", "-1", "1 = infinite sprint, 0 = never have infinite sprint, -1 = let the game choose.", _, true, -1.0, true, 1.0);
	g_cvPlayerInfiniteFlashlightOverride = CreateConVar("sf2_player_infinite_flashlight_override", "-1", "1 = infinite flashlight, 0 = never have infinite flashlight, -1 = let the game choose.", _, true, -1.0, true, 1.0);
	g_cvPlayerInfiniteBlinkOverride = CreateConVar("sf2_player_infinite_blink_override", "-1", "1 = infinite blink, 0 = never have infinite blink, -1 = let the game choose.", _, true, -1.0, true, 1.0);
	
	g_cvRaidMap = CreateConVar("sf2_israidmap", "0", "Set to 1 if the map is a raid map.", _, true, 0.0, true, 1.0);
	
	g_cvBossChaseEndlessly = CreateConVar("sf2_bosseschaseendlessly", "0", "Set to 1 if you want bosses chasing you forever.", _, true, 0.0, true, 1.0);
	
	g_cvProxyMap = CreateConVar("sf2_isproxymap", "0", "Set to 1 if the map is a proxy survival map.", _, true, 0.0, true, 1.0);
	
	g_cvBoxingMap = CreateConVar("sf2_isboxingmap", "0", "Set to 1 if the map is a boxing map.", _, true, 0.0, true, 1.0);
	
	g_cvRenevantMap = CreateConVar("sf2_isrenevantmap", "0", "Set to 1 if the map uses Renevant logic.", _, true, 0.0, true, 1.0);

	g_cvSlaughterRunMap = CreateConVar("sf2_isslaughterrunmap", "0", "Set to 1 if the map is a slaughter run map.", _, true, 0.0, true, 1.0);

	g_cvSlaughterRunDivisibleTime = CreateConVar("sf2_slaughterrun_divide_time", "125.0", "Determines how much the average time should be divided by in Slaughter Run, the lower the number, the longer the bosses spawn.", _, true, 0.0);
	
	g_cvUseAlternateConfigDirectory = CreateConVar("sf2_alternateconfigs", "0", "Set to 1 if the server should pick up the configs from data/.", _, true, 0.0, true, 1.0);

	g_cvSurvivalMap = CreateConVar("sf2_issurvivalmap", "0", "Set to 1 if the map is a survival map.", _, true, 0.0, true, 1.0);
	g_cvTimeEscapeSurvival = CreateConVar("sf2_survival_time_limit", "30", "when X secs left the mod will turn back the Survive! text to Escape! text", _, true, 0.0);

	g_cvMaxRounds = FindConVar("mp_maxrounds");
	
	g_hHudSync = CreateHudSynchronizer();
	g_hHudSync2 = CreateHudSynchronizer();
	g_hRoundTimerSync = CreateHudSynchronizer();
	g_hCookie = RegClientCookie("sf2_newcookies", "", CookieAccess_Private);
	
	// Register console commands.
	RegConsoleCmd("sm_sf2", Command_MainMenu);
	RegConsoleCmd("sm_sl", Command_MainMenu);
	RegConsoleCmd("sm_slender", Command_MainMenu);
	RegConsoleCmd("sm_sltutorial", Command_Tutorial);
	RegConsoleCmd("sm_sltuto", Command_Tutorial);
	RegConsoleCmd("sm_sf2tutorial", Command_Tutorial);
	RegConsoleCmd("sm_sf2tuto", Command_Tutorial);
	RegConsoleCmd("sm_slupdate", Command_Update);
	RegConsoleCmd("sm_slpack", Command_Pack);
	RegConsoleCmd("sm_sf2pack", Command_Pack);
	RegConsoleCmd("sm_slnextpack", Command_NextPack);
	RegConsoleCmd("sm_sf2nextpack", Command_NextPack);
	RegConsoleCmd("sm_slnext", Command_Next);
	RegConsoleCmd("sm_slgroup", Command_Group);
	RegConsoleCmd("sm_slghost", Command_GhostMode);
	RegConsoleCmd("sm_slhelp", Command_Help);
	RegConsoleCmd("sm_slsettings", Command_Settings);
	RegConsoleCmd("sm_slcredits", Command_Credits);
	RegConsoleCmd("sm_slviewbosslist", Command_BossList);
	RegConsoleCmd("sm_slbosslist", Command_BossList);
	RegConsoleCmd("sm_flashlight", Command_ToggleFlashlight);
	RegConsoleCmd("+sprint", Command_SprintOn);
	RegConsoleCmd("-sprint", Command_SprintOff);
	
	RegAdminCmd("sm_slgroupname", Command_GroupName, ADMFLAG_SLAY); //People like to use naughty names, keep it at this for now until pre-defined group names are made
	RegAdminCmd("sm_sf2_bosspack_vote", DevCommand_BossPackVote, ADMFLAG_CHEATS);
	RegAdminCmd("sm_sf2_nopoints", Command_NoPoints, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_scare", Command_ClientPerformScare, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_spawn_boss", Command_SpawnSlender, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_add_boss", Command_AddSlender, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_add_boss_fake", Command_AddSlenderFake, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_remove_boss", Command_RemoveSlender, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_remove_all_bosses", Command_RemoveAllSlenders, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_getbossindexes", Command_GetBossIndexes, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_setplaystate", Command_ForceState, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_boss_attack_waiters", Command_SlenderAttackWaiters, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_boss_no_teleport", Command_SlenderNoTeleport, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_force_proxy", Command_ForceProxy, ADMFLAG_SLAY);
	//RegAdminCmd("sm_sf2_nightvision", Command_NightVision, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_force_escape", Command_ForceEscape, ADMFLAG_CHEATS);
	RegAdminCmd("sm_sf2_set_difficulty", Command_ForceDifficulty, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_force_special_round", Command_ForceSpecialRound, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_toggle_boss_teleports", Command_ToggleAllBossTeleports, ADMFLAG_SLAY);
	RegAdminCmd("sm_sf2_toggle_attack_waiters", Command_ToggleAllAttackWaiters, ADMFLAG_SLAY);

	// Hook onto existing console commands.
	AddCommandListener(Hook_CommandBuild, "build");
	AddCommandListener(Hook_CommandTaunt, "taunt");
	AddCommandListener(Hook_CommandDisguise, "disguise");
	AddCommandListener(Hook_CommandSuicideAttempt, "kill");
	AddCommandListener(Hook_CommandSuicideAttempt, "explode");
	AddCommandListener(Hook_CommandSuicideAttempt, "joinclass");
	AddCommandListener(Hook_CommandPreventJoinTeam, "join_class");
	AddCommandListener(Hook_CommandSuicideAttempt, "jointeam");
	AddCommandListener(Hook_CommandPreventJoinTeam, "autoteam");
	AddCommandListener(Hook_CommandSuicideAttempt, "spectate");
	AddCommandListener(Hook_CommandVoiceMenu, "voicemenu");
	// Hook events.
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundEnd);
	HookEvent("teamplay_win_panel", Event_WinPanel, EventHookMode_Pre);
	HookEvent("player_team", Event_DontBroadcastToClients, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("npc_hurt", Event_HitBoxHurt);
	HookEvent("post_inventory_application", Event_PostInventoryApplication);
	HookEvent("item_found", Event_DontBroadcastToClients, EventHookMode_Pre);
	HookEvent("teamplay_teambalanced_player", Event_DontBroadcastToClients, EventHookMode_Pre);
	HookEvent("fish_notice", Event_PlayerDeathPre, EventHookMode_Pre);
	HookEvent("fish_notice__arm", Event_PlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeathPre, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath);
	
	// Hook entities.
	HookEntityOutput("info_npc_spawn_destination", "OnUser1", NPCSpawn);
	HookEntityOutput("trigger_multiple", "OnStartTouch", Hook_TriggerOnStartTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouch", Hook_TriggerOnEndTouch);
	HookEntityOutput("trigger_teleport", "OnStartTouch", Hook_TriggerTeleportOnStartTouch);
	//HookEntityOutput("trigger_teleport", "OnEndTouch", Hook_TriggerTeleportOnEndTouch);
	
	// Hook usermessages.
	HookUserMessage(GetUserMessageId("VoiceSubtitle"), Hook_BlockUserMessage, true);
	HookUserMessage(GetUserMessageId("PlayerTauntSoundLoopStart"), Hook_TauntUserMessage, true);
	HookUserMessage(GetUserMessageId("SayText2"), Hook_BlockUserMessageEx, true);
	//HookUserMessage(GetUserMessageId("TextMsg"), Hook_BlockUserMessage, true);
	
	// Hook sounds.
	AddNormalSoundHook(view_as<NormalSHook>(Hook_NormalSound));
	
	AddTempEntHook("Fire Bullets", Hook_TEFireBullets);

	steamtools = LibraryExists("SteamTools");
	
	steamworks = LibraryExists("SteamWorks");

	InitializeBossProfiles();
	
	NPCInitialize();
	
	SetupMenus();
	
	Tutorial_Initialize();
	
	SetupAdminMenu();

	SetupPlayerGroups();
	
	PvP_Initialize();
	
	Nav_Initialize();

	SF2MapEntity_Initialize();
	
	// @TODO: When cvars are finalized, set this to true.
	AutoExecConfig(false);
#if defined DEBUG
	InitializeDebug();
#endif
}

public void OnAllPluginsLoaded()
{
	SDK_Init();
}

public void OnPluginEnd()
{
	StopPlugin();
}
public void OnLibraryAdded(const char[] name)
{
	
	if(!strcmp(name, "SteamTools", false))
	{
		steamtools = true;
	}
	
	if(!strcmp(name, "SteamWorks", false))
	{
		steamworks = true;
	}
	
}
public void OnLibraryRemoved(const char[] name)
{
	
	if(!strcmp(name, "SteamTools", false))
	{
		steamtools = false;
	}
	
	if(!strcmp(name, "SteamWorks", false))
	{
		steamworks = false;
	}
	
}
static void SDK_Init()
{
	// Check SDKHooks gamedata.
	GameData hConfig = LoadGameConfigFile("sdkhooks.games");
	if (hConfig == INVALID_HANDLE) SetFailState("Couldn't find SDKHooks gamedata!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "GetMaxHealth");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSDKGetMaxHealth = EndPrepSDKCall()) == INVALID_HANDLE)
	{
		SetFailState("Failed to retrieve GetMaxHealth offset from SDKHooks gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "StartTouch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDKStartTouch = EndPrepSDKCall();
	if (g_hSDKStartTouch == INVALID_HANDLE)
	{
		SetFailState("Failed to retrieve StartTouch offset from SDKHooks gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "EndTouch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDKEndTouch = EndPrepSDKCall();
	if (g_hSDKEndTouch == INVALID_HANDLE)
	{
		SetFailState("Failed to retrieve EndTouch offset from SDKHooks gamedata!");
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKWeaponSwitch = EndPrepSDKCall();
	if (g_hSDKWeaponSwitch == INVALID_HANDLE)
	{
		SetFailState("Failed to retrieve Weapon_Switch offset from SDKHooks gamedata!");
	}

	
	delete hConfig;
	
	// Check our own gamedata.
	hConfig = LoadGameConfigFile("sf2");
	if (hConfig == INVALID_HANDLE) SetFailState("Could not find SF2 gamedata!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf( hConfig, SDKConf_Virtual, "CTFPlayer::EquipWearable" );
	PrepSDKCall_AddParameter( SDKType_CBaseEntity, SDKPass_Pointer );
	g_hSDKEquipWearable = EndPrepSDKCall();
	if( g_hSDKEquipWearable == INVALID_HANDLE )//In case the offset is missing, look if the server has the tf2 randomizer's gamedata.
	{
		char strFilePath[PLATFORM_MAX_PATH];
		BuildPath( Path_SM, strFilePath, sizeof(strFilePath), "gamedata/tf2items.randomizer.txt" );
		if( FileExists( strFilePath ) )
		{
			Handle hGameConf = LoadGameConfigFile( "tf2items.randomizer" );
			if( hGameConf != INVALID_HANDLE )
			{
				StartPrepSDKCall(SDKCall_Player);
				PrepSDKCall_SetFromConf( hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable" );
				PrepSDKCall_AddParameter( SDKType_CBaseEntity, SDKPass_Pointer );
				g_hSDKEquipWearable = EndPrepSDKCall();
				if( g_hSDKEquipWearable == INVALID_HANDLE )
				{
					// Old gamedata
					StartPrepSDKCall(SDKCall_Player);
					PrepSDKCall_SetFromConf( hGameConf, SDKConf_Virtual, "EquipWearable" );
					PrepSDKCall_AddParameter( SDKType_CBaseEntity, SDKPass_Pointer );
					g_hSDKEquipWearable = EndPrepSDKCall();
				}
			}
			delete hGameConf;
		}
	}
	if( g_hSDKEquipWearable == INVALID_HANDLE )
	{
		SetFailState("Failed to retrieve CTFPlayer::EquipWearable offset from SF2 gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "CBaseCombatCharacter::GetLastKnownArea");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
	g_hSDKGetLastKnownArea = EndPrepSDKCall();
	if(g_hSDKGetLastKnownArea == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve CBaseCombatCharacter::GetLastKnownArea offset from SF2 gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "CBaseCombatCharacter::UpdateLastKnownArea");
	g_hSDKUpdateLastKnownArea = EndPrepSDKCall();
	if(g_hSDKUpdateLastKnownArea == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve CBaseCombatCharacter::UpdateLastKnownArea offset from SF2 gamedata!");
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CTFPlayer::PlaySpecificSequence");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	g_hSDKPlaySpecificSequence = EndPrepSDKCall();
	if(g_hSDKPlaySpecificSequence == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve CTFPlayer::PlaySpecificSequence signature from SF2 gamedata!");
		//Don't have to call SetFailState, since this function is used in a minor part of the code.
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CBaseTrigger::PointIsWithin");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	g_hSDKPointIsWithin = EndPrepSDKCall();
	if(g_hSDKPointIsWithin == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve CBaseTrigger::PointIsWithin signature from SF2 gamedata!");
		//Don't have to call SetFailState, since this function is used in a minor part of the code.
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "CBaseEntity::GetSmoothedVelocity");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByValue);
	if ((g_hSDKGetSmoothedVelocity = EndPrepSDKCall()) == INVALID_HANDLE)
	{
		SetFailState("Couldn't find CBaseEntity::GetSmoothedVelocity offset from SF2 gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "CBaseEntity::GetVectors");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	g_hSDKGetVectors = EndPrepSDKCall();
	if (g_hSDKGetVectors == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve CBaseEntity::GetVectors signature from SF2 gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CBaseAnimating::ResetSequence");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	g_hSDKResetSequence = EndPrepSDKCall();
	if(g_hSDKResetSequence == INVALID_HANDLE)
	{
		SetFailState("Failed to retrieve CBaseAnimating::ResetSequence signature from SF2 gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "CBaseAnimating::StudioFrameAdvance");
	if ((g_hSDKStudioFrameAdvance = EndPrepSDKCall()) == INVALID_HANDLE)
	{
		SetFailState("Couldn't find CBaseAnimating::StudioFrameAdvance offset in SF2 gamedata!");
	}

	int iOffset = GameConfGetOffset(hConfig, "CTFPlayer::WantsLagCompensationOnEntity"); 
	switch (iOffset)
	{
		case 327: g_iServerOS = 0; //Windows
		case 328: g_iServerOS = 1; //Linux
	}
	g_hSDKWantsLagCompensationOnEntity = DHookCreate(iOffset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, Hook_ClientWantsLagCompensationOnEntity); 
	if (g_hSDKWantsLagCompensationOnEntity == INVALID_HANDLE)
	{
		SetFailState("Failed to create hook CTFPlayer::WantsLagCompensationOnEntity offset from SF2 gamedata!");
	}

	DHookAddParam(g_hSDKWantsLagCompensationOnEntity, HookParamType_CBaseEntity);
	DHookAddParam(g_hSDKWantsLagCompensationOnEntity, HookParamType_ObjectPtr);
	DHookAddParam(g_hSDKWantsLagCompensationOnEntity, HookParamType_Unknown);

	iOffset = GameConfGetOffset(hConfig, "CBaseEntity::ShouldTransmit");
	g_hSDKShouldTransmit = DHookCreate(iOffset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, Hook_EntityShouldTransmit);
	if (g_hSDKShouldTransmit == INVALID_HANDLE)
	{
		SetFailState("Failed to create hook CBaseEntity::ShouldTransmit offset from SF2 gamedata!");
	}
	DHookAddParam(g_hSDKShouldTransmit, HookParamType_ObjectPtr);
	
	iOffset = GameConfGetOffset(hConfig, "CTFWeaponBase::GetCustomDamageType");
	g_hSDKWeaponGetCustomDamageType = DHookCreate(iOffset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, Hook_WeaponGetCustomDamageType);
	if (g_hSDKWeaponGetCustomDamageType == INVALID_HANDLE)
	{
		SetFailState("Failed to create hook CTFWeaponBase::GetCustomDamageType offset from SF2 gamedata!");
	}

	iOffset = GameConfGetOffset(hConfig, "CBaseProjectile::CanCollideWithTeammates");
	g_hSDKProjectileCanCollideWithTeammates = DHookCreate(iOffset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity);
	if (g_hSDKProjectileCanCollideWithTeammates == INVALID_HANDLE)
	{
		SetFailState("Failed to create hook CBaseProjectile::CanCollideWithTeammates offset from SF2 gamedata!");
	}

	g_iOffset_m_id = GameConfGetOffset(hConfig, "CNavArea::m_id");
	
	//Initialize the nextbot logic.
	InitNextBotGameData(hConfig);
	CBaseAnimating_InitGameData(hConfig);
	
	//Initialize tutorial detours & calls
	//Tutorial_SetupSDK(hConfig);
	
	SF2MapEntity_InitGameData(hConfig);

	delete hConfig;
}

#pragma dynamic 2097152
public Action OnLevelInit(const char[] mapName, char mapEntities[2097152])
{
	// Since OnLevelInit is called before OnConfigsExecuted() we shouldn't check g_bEnabled
	SF2MapEntity_OnLevelInit(mapName);

	return Plugin_Continue;
}

public void OnMapStart()
{
	g_hTimerFail = INVALID_HANDLE;
	PvP_OnMapStart();
	FindHealthBar();
	PrecacheSound(SOUND_THUNDER, true);
	PrecacheSound("weapons/teleporter_send.wav");
	g_SmokeSprite = PrecacheModel("sprites/steam1.vmt");
	g_LightningSprite = PrecacheModel("sprites/lgtning.vmt");
	g_ShockwaveBeam = PrecacheModel("sprites/laser.vmt");
	g_ShockwaveHalo = PrecacheModel("sprites/halo01.vmt");
	PrecacheModel(LASER_MODEL, true);

	SF2MapEntity_OnMapStart();
}

public void OnConfigsExecuted()
{
	if (!GetConVarBool(g_cvEnabled))
	{
		StopPlugin();
	}
	else
	{
		if (GetConVarBool(g_cvSlenderMapsOnly))
		{
			char sMap[256];
			GetCurrentMap(sMap, sizeof(sMap));
			
			if (!StrContains(sMap, "slender_", false) || !StrContains(sMap, "sf2_", false))
			{
				StartPlugin();
			}
			else
			{
				LogMessage("%s is not a Slender Fortress map. Plugin disabled!", sMap);
				StopPlugin();
			}
		}
		else
		{
			StartPlugin();
		}
	}
}

static void StartPlugin()
{
	if (g_bEnabled) return;
	
	g_bEnabled = true;
	
	InitializeLogging();
	
#if defined DEBUG
	InitializeDebugLogging();
#endif

	int i2 = 0;
	
	// Handle ConVars.
	ConVar hCvar = FindConVar("mp_friendlyfire");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE)) SetConVarBool(hCvar, true);
	
	hCvar = FindConVar("mp_flashlight");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE)) SetConVarBool(hCvar, true);
	
	hCvar = FindConVar("mat_supportflashlight");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE)) SetConVarBool(hCvar, true);
	
	hCvar = FindConVar("mp_autoteambalance");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE)) SetConVarBool(hCvar, false);
	
	hCvar = FindConVar("tf_base_boss_max_turn_rate");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE) && GetConVarInt(hCvar) < 720) SetConVarInt(hCvar, 720);

	g_flGravity = GetConVarFloat(g_cvGravity);
	
	g_b20Dollars = GetConVarBool(g_cv20Dollars);
	
	g_bPlayerShakeEnabled = GetConVarBool(g_cvPlayerShakeEnabled);
	g_bPlayerViewbobEnabled = GetConVarBool(g_cvPlayerViewbobEnabled);
	g_bPlayerViewbobHurtEnabled = GetConVarBool(g_cvPlayerViewbobHurtEnabled);
	g_bPlayerViewbobSprintEnabled = GetConVarBool(g_cvPlayerViewbobSprintEnabled);

	#if defined _SteamWorks_Included
	if(steamworks)
	{
		SteamWorks_SetGameDescription("Slender Fortress (" ... PLUGIN_VERSION_DISPLAY ... ")");
		steamtools=false;
	}
	#endif
	#if defined _steamtools_included
	if(steamtools)
	{
		Steam_SetGameDescription("Slender Fortress (" ... PLUGIN_VERSION_DISPLAY ... ")");
		steamworks=false;
	}
	#endif

	if (steamworks) i2 = 1;
	else if (steamtools) i2 = 2;
	
	PrecacheStuff();

	if (i2 == 1 || i2 == 2 || i2 == 0) WarningRemoval(); //Sourcemod loves to call steamworks and steamtools unused symbols, do this to prevent this
	
	// Reset special round.
	g_bSpecialRound = false;
	g_bSpecialRoundNew = false;
	g_bSpecialRoundContinuous = false;
	g_iSpecialRoundCount = 1;
	SF_RemoveAllSpecialRound();
	
	SpecialRoundReset();
	
	// Reset boss rounds.
	g_bNewBossRound = false;
	g_bNewBossRoundNew = false;
	g_bNewBossRoundContinuous = false;
	g_iNewBossRoundCount = 1;
	g_strNewBossRoundProfile[0] = '\0';
	
	// Reset global round vars.
	g_iRoundCount = 0;
	g_iRoundEndCount = 0;
	g_iRoundActiveCount = 0;
	g_iRoundState = SF2RoundState_Invalid;
	g_hRoundMessagesTimer = CreateTimer(200.0, Timer_RoundMessages, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundMessagesNum = 0;
	
	g_iRoundWarmupRoundCount = 0;
	
	g_hClientAverageUpdateTimer = CreateTimer(0.2, Timer_ClientAverageUpdate, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	g_hBossCountUpdateTimer = CreateTimer(2.0, Timer_BossCountUpdate, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	g_hOnGameFrameTimer = CreateTimer(0.1, Timer_GlobalGameFrame, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	SetRoundState(SF2RoundState_Waiting);
	
	ReloadBossProfiles();
	ReloadRestrictedWeapons();
	ReloadSpecialRounds();
	
	NPCOnConfigsExecuted();
	
	InitializeBossPackVotes();
	SetupTimeLimitTimerForBossPackVote();
	
	// Late load compensation.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		OnClientPutInServer(i);
	}
}

void WarningRemoval()
{

}

static void PrecacheStuff()
{
	// Initialize particles.
	g_iParticle[CriticalHit] = PrecacheParticleSystem(CRIT_PARTICLENAME);
	g_iParticle[MiniCritHit] = PrecacheParticleSystem(MINICRIT_PARTICLENAME);
	g_iParticle[ZapParticle] = PrecacheParticleSystem(ZAP_PARTICLENAME);
	g_iParticle[FireworksRED] = PrecacheParticleSystem(FIREWORKSRED_PARTICLENAME);
	g_iParticle[FireworksBLU] = PrecacheParticleSystem(FIREWORKSBLU_PARTICLENAME);
	g_iParticle[TeleportedInBlu] = PrecacheParticleSystem(TELEPORTEDINBLU_PARTICLENAME);
	
	for (int i = 0; i < sizeof(g_strSoundNightmareMode)-1; i++) PrecacheSound2(g_strSoundNightmareMode[i]);
	
	PrecacheSound("ui/itemcrate_smash_ultrarare_short.wav");
	PrecacheSound(")weapons/crusaders_crossbow_shoot.wav");
	PrecacheSound(MINICRIT_SOUND);
	PrecacheSound(CRIT_SOUND);
	PrecacheSound(ZAP_SOUND);
	PrecacheSound(PAGE_DETECTOR_BEEP);
	PrecacheSound(EXPLOSIVEDANCE_EXPLOSION1);
	PrecacheSound(EXPLOSIVEDANCE_EXPLOSION2);
	PrecacheSound(EXPLOSIVEDANCE_EXPLOSION3);
	PrecacheSound(SPECIAL1UPSOUND);
	PrecacheSound("player/spy_shield_break.wav");

	PrecacheSound(CRIT_ROLL);
	PrecacheSound(EXPLODE_PLAYER);
	PrecacheSound(UBER_ROLL);
	PrecacheSound(NO_EFFECT_ROLL);
	PrecacheSound(BLEED_ROLL);
	PrecacheSound(GENERIC_ROLL_TICK_1);
	PrecacheSound(GENERIC_ROLL_TICK_2);
	PrecacheSound(LOSE_SPRINT_ROLL);
	PrecacheSound(FIREWORK_EXPLOSION);
	PrecacheSound(FIREWORK_START);
	PrecacheSound(MINICRIT_BUFF);
	PrecacheSound(NULLSOUND);
	PrecacheSound(JARATE_ROLL);
	PrecacheSound(GAS_ROLL);
	
	// simple_bot;
	PrecacheModel("models/humans/group01/female_01.mdl", true);
	
	PrecacheModel(PAGE_MODEL, true);
	PrecacheModel(SF_KEYMODEL, true);
	PrecacheModel(TRAP_MODEL, true);
	
	PrecacheSound2(FLASHLIGHT_CLICKSOUND);
	PrecacheSound2(FLASHLIGHT_CLICKSOUND_NIGHTVISION);
	PrecacheSound2(FLASHLIGHT_BREAKSOUND);
	PrecacheSound2(FLASHLIGHT_NOSOUND);
	PrecacheSound2(PAGE_GRABSOUND);
	PrecacheSound2(TWENTYDOLLARS_MUSIC);
	PrecacheSound2(MARBLEHORNETS_STATIC);
	
	PrecacheSound2(DEFAULT_CLOAKONSOUND);
	PrecacheSound2(DEFAULT_CLOAKOFFSOUND);
	
	PrecacheSound2(FIREBALL_IMPACT);
	PrecacheSound2(FIREBALL_SHOOT);
	PrecacheSound2(ICEBALL_IMPACT);
	PrecacheSound2(ROCKET_SHOOT);
	PrecacheSound2(ROCKET_IMPACT);
	PrecacheSound2(ROCKET_IMPACT2);
	PrecacheSound2(ROCKET_IMPACT3);
	PrecacheSound2(GRENADE_SHOOT);
	PrecacheSound2(SENTRYROCKET_SHOOT);
	PrecacheSound2(ARROW_SHOOT);
	PrecacheSound2(MANGLER_EXPLODE1);
	PrecacheSound2(MANGLER_EXPLODE2);
	PrecacheSound2(MANGLER_EXPLODE3);
	PrecacheSound2(MANGLER_SHOOT);
	PrecacheSound2(BASEBALL_SHOOT);
	
	PrecacheModel(ROCKET_MODEL, true);
	PrecacheModel(GRENADE_MODEL, true);
	PrecacheModel(BASEBALL_MODEL, true);
	
	PrecacheSound2(JARATE_HITPLAYER);
	PrecacheSound2(STUN_HITPLAYER);
	
	PrecacheSound2(MUSIC_GOTPAGES1_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES2_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES3_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES4_SOUND);
	
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_1);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_2);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_3);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_4);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_5);
	PrecacheSound2(SNATCHER_APOLLYON_1);
	PrecacheSound2(SNATCHER_APOLLYON_2);
	PrecacheSound2(SNATCHER_APOLLYON_3);
	
	PrecacheSound2(NINETYSMUSIC);
	PrecacheSound2(TRIPLEBOSSESMUSIC);
	
	PrecacheSound2(TRAP_CLOSE);
	PrecacheSound2(TRAP_DEPLOY);

	for (int i = 0; i < sizeof(g_sPageCollectDuckSounds); i++)
	{
		PrecacheSound(g_sPageCollectDuckSounds[i]);
	}

	PrecacheSound2(PROXY_RAGE_MODE_SOUND);
	
	PrecacheSound2(SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND);
	
	for (int i = 0; i < sizeof(g_strPlayerBreathSounds); i++)
	{
		PrecacheSound2(g_strPlayerBreathSounds[i]);
	}
	
	// Special round.
	PrecacheSound2(SR_MUSIC);
	PrecacheSound2(SR_SOUND_SELECT);
	PrecacheSound2(SF2_INTRO_DEFAULT_MUSIC);
	
	PrecacheMaterial2(SF2_OVERLAY_DEFAULT);
	PrecacheMaterial2(SF2_OVERLAY_DEFAULT_NO_FILMGRAIN);
	PrecacheMaterial2(SF2_OVERLAY_GHOST);
	PrecacheMaterial2(SF2_OVERLAY_MARBLEHORNETS);
	
	AddFileToDownloadsTable("models/slender/pickups/sheet.mdl");
	AddFileToDownloadsTable("models/slender/pickups/sheet.dx80.vtx");
	AddFileToDownloadsTable("models/slender/pickups/sheet.dx90.vtx");
	AddFileToDownloadsTable("models/slender/pickups/sheet.phy");
	AddFileToDownloadsTable("models/slender/pickups/sheet.sw.vtx");
	AddFileToDownloadsTable("models/slender/pickups/sheet.vvd");
	AddFileToDownloadsTable("models/slender/pickups/sheet.xbox");
	
	AddFileToDownloadsTable("models/demani_sf/key_australium.mdl");
	AddFileToDownloadsTable("models/demani_sf/key_australium.dx80.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.dx90.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.sw.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.vvd");
	
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium.vmt");
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium.vtf");
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium_normal.vtf");
	
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_1.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_1.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_2.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_2.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_3.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_3.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_4.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_4.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_5.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_5.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_6.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_6.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_7.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_7.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_8.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_8.vmt");
	
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.mdl");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.sw.vtx");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.dx80.vtx");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.dx90.vtx");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.phy");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.vvd");
	
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_m.vtf");
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_m.vmt");
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_n.vtf");
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_r.vtf");
	
	// pvp
	PvP_Precache();
}

static void StopPlugin()
{
	if (!g_bEnabled) return;
	
	g_bEnabled = false;
	
	// Reset CVars.
	ConVar hCvar = FindConVar("mp_friendlyfire");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE)) SetConVarBool(hCvar, false);
	
	hCvar = FindConVar("mp_flashlight");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE)) SetConVarBool(hCvar, false);
	
	hCvar = FindConVar("mat_supportflashlight");
	if (hCvar != view_as<ConVar>(INVALID_HANDLE)) SetConVarBool(hCvar, false);

	if (MusicActive()) NPCStopMusic();

	//Remove Timer handles
	CleanTimerHandles();

	// Cleanup bosses.
	NPCRemoveAll();
	
	// Cleanup clients.
	for (int i = 1; i <= MaxClients; i++)
	{
		ClientResetFlashlight(i);
		ClientDeactivateUltravision(i);
		ClientDisableConstantGlow(i);
		ClientRemoveInteractiveGlow(i);
	}
	
	BossProfilesOnMapEnd();
	
	Tutorial_OnMapEnd();
}

public void CleanTimerHandles()
{
	g_hRoundMessagesTimer = INVALID_HANDLE;
	g_hClientAverageUpdateTimer = INVALID_HANDLE;
	g_hBossCountUpdateTimer = INVALID_HANDLE;
	g_hBlueNightvisionOutlineTimer = INVALID_HANDLE;
	g_hRoundIntroTextTimer = INVALID_HANDLE;
	g_hRoundIntroTimer = INVALID_HANDLE;
	g_hRoundGraceTimer = INVALID_HANDLE;
	g_hRoundTimer = INVALID_HANDLE;
	g_hRenevantWaveTimer = INVALID_HANDLE;
	g_hTimerChangeSourceTVBotName = INVALID_HANDLE;
	g_hVoteTimer = INVALID_HANDLE;
	g_hTimerFail = INVALID_HANDLE;
	g_hBossPackVoteTimer = INVALID_HANDLE;
	g_hBossPackVoteMapTimer = INVALID_HANDLE;
	hTimerMusic = INVALID_HANDLE;
	g_hOnGameFrameTimer = INVALID_HANDLE;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsClientInGame(i)) continue;
		g_hPlayerPageRewardTimer[i] = INVALID_HANDLE;
		g_hPlayerPageRewardCycleTimer[i] = INVALID_HANDLE;
		g_hPlayerOverlayCheck[i] = INVALID_HANDLE;
		g_hPlayerPostWeaponsTimer[i] = INVALID_HANDLE;
		g_hPlayerSwitchBlueTimer[i] = INVALID_HANDLE;
		g_hPlayerIntroMusicTimer[i] = INVALID_HANDLE;
		g_hPlayerPvPRespawnTimer[i] = INVALID_HANDLE;
		g_hPlayerPvPTimer[i] = INVALID_HANDLE;
		g_hPlayerIgniteTimer[i] = INVALID_HANDLE;
		g_hPlayerResetIgnite[i] = INVALID_HANDLE;
		g_hPlayerStaticTimer[i] = INVALID_HANDLE;
		g_hPlayerLastStaticTimer[i] = INVALID_HANDLE;
		g_hClientSpecialRoundTimer[i] = INVALID_HANDLE;
		g_hPlayerBreathTimer[i] = INVALID_HANDLE;
		g_hPlayerSprintTimer[i] = INVALID_HANDLE;
		g_hPlayerProxyAvailableTimer[i] = INVALID_HANDLE;
		g_hPlayerProxyControlTimer[i] = INVALID_HANDLE;
		g_hClientGlowTimer[i] = INVALID_HANDLE;
		g_hPlayerDeathCamTimer[i] = INVALID_HANDLE;
		g_hPlayerGhostModeConnectionCheckTimer[i] = INVALID_HANDLE;
		g_hPlayerCampingTimer[i] = INVALID_HANDLE;
		g_hPlayerBlinkTimer[i] = INVALID_HANDLE;
		g_hPlayerMusicTimer[i] = INVALID_HANDLE;
		g_hPlayer90sMusicTimer[i] = INVALID_HANDLE;
		g_hPlayerFlashlightBatteryTimer[i] = INVALID_HANDLE;
	}
	for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
	{
		if (NPCGetUniqueID(iBossIndex) == -1) continue;
		g_hNPCResetAlertCopyTimer[iBossIndex] = INVALID_HANDLE;
		g_hBossFailSafeTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderRage1Timer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderRage2Timer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderRage3Timer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderHealTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderHealDelayTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderStartFleeTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderAttackTimer[iBossIndex] = INVALID_HANDLE;
		g_hNPCLifeStealTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderChaseInitialTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderEntityThink[iBossIndex] = INVALID_HANDLE;
		g_hSlenderHealEventTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderLaserTimer[iBossIndex] = INVALID_HANDLE;
		g_hNPCRegisterAlertingCopiesTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderThink[iBossIndex] = INVALID_HANDLE;
		g_hSlenderSpawnTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderBurnTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderBleedTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderMarkedTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderMilkedTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderJarateTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderGasTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderFakeTimer[iBossIndex] = INVALID_HANDLE;
		g_hSlenderDeathCamTimer[iBossIndex] = INVALID_HANDLE;
	}
}

public void OnMapEnd()
{
	StopPlugin();
}

public void OnMapTimeLeftChanged()
{
	if (g_bEnabled)
	{
		SetupTimeLimitTimerForBossPackVote();
	}
}

public void TF2_OnConditionAdded(int iClient, TFCond cond)
{
	if (cond == TFCond_Taunting)
	{
		if (IsClientInGhostMode(iClient))
		{
			// Stop ghosties from taunting.
			TF2_RemoveCondition(iClient, TFCond_Taunting);
		}
		
		if (g_bPlayerProxy[iClient])
		{
			g_iPlayerProxyControl[iClient] -= 20;
			if (g_iPlayerProxyControl[iClient] <= 0) g_iPlayerProxyControl[iClient] = 0;
		}
	}
	if(cond==view_as<TFCond>(82))
	{
		if (g_bPlayerProxy[iClient])
		{
			//Stop proxies from using kart commands
			TF2_RemoveCondition(iClient,TFCond_HalloweenKart);
			TF2_RemoveCondition(iClient,TFCond_HalloweenKartDash);
			TF2_RemoveCondition(iClient,TFCond_HalloweenKartNoTurn);
			TF2_RemoveCondition(iClient,TFCond_HalloweenKartCage);
			TF2_RemoveCondition(iClient, TFCond_SpawnOutline);
		}
	}
}

public Action Timer_GlobalGameFrame(Handle timer)
{
	if (!g_bEnabled) return Plugin_Stop;

	if (timer != g_hOnGameFrameTimer) return Plugin_Stop;
	
	// Process through boss movement.
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		
		int iBoss = NPCGetEntIndex(i);
		if (!iBoss || iBoss == INVALID_ENT_REFERENCE) continue;
		
		if (NPCGetFlags(i) & SFF_MARKEDASFAKE) continue;
		
		int iType = NPCGetType(i);
		
		switch (iType)
		{
			case SF2BossType_Static:
			{
				float myPos[3], hisPos[3];
				SlenderGetAbsOrigin(i, myPos);
				AddVectors(myPos, g_flSlenderEyePosOffset[i], myPos);
				
				int iBestPlayer = -1;
				float flBestDistance = SquareFloat(16384.0);
				float flTempDistance;
				
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || IsClientInGhostMode(iClient) || IsClientInDeathCam(iClient)) continue;
					if (!IsPointVisibleToPlayer(iClient, myPos, false, false)) continue;
					
					GetClientAbsOrigin(iClient, hisPos);
					
					flTempDistance = GetVectorSquareMagnitude(myPos, hisPos);
					if (flTempDistance < flBestDistance)
					{
						iBestPlayer = iClient;
						flBestDistance = flTempDistance;
					}
				}
				
				if (iBestPlayer > 0)
				{
					SlenderGetAbsOrigin(i, myPos);
					GetClientAbsOrigin(iBestPlayer, hisPos);
					
					if (!SlenderOnlyLooksIfNotSeen(i) || !IsPointVisibleToAPlayer(myPos, false, SlenderUsesBlink(i)))
					{
						float flTurnRate = NPCGetTurnRate(i);
					
						if (flTurnRate > 0.0)
						{
							float flMyEyeAng[3], ang[3];
							GetEntPropVector(iBoss, Prop_Data, "m_angAbsRotation", flMyEyeAng);
							AddVectors(flMyEyeAng, g_flSlenderEyeAngOffset[i], flMyEyeAng);
							SubtractVectors(hisPos, myPos, ang);
							GetVectorAngles(ang, ang);
							ang[0] = 0.0;
							ang[1] += (AngleDiff(ang[1], flMyEyeAng[1]) >= 0.0 ? 1.0 : -1.0) * flTurnRate * GetTickInterval();
							ang[2] = 0.0;
							
							// Take care of angle offsets.
							AddVectors(ang, g_flSlenderEyePosOffset[i], ang);
							for (int i2 = 0; i2 < 3; i2++) ang[i2] = AngleNormalize(ang[i2]);
							
							TeleportEntity(iBoss, NULL_VECTOR, ang, NULL_VECTOR);
						}
					}
				}
			}
		}
	}
	// Check if we can add some proxies.
	if (!g_bRoundGrace)
	{
		if (NavMesh_Exists())
		{
			Handle hProxyCandidates = CreateArray();
			
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			
			for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
			{
				if (NPCGetUniqueID(iBossIndex) == -1) continue;
				
				if (!(NPCGetFlags(iBossIndex) & SFF_PROXIES)) continue;
				
				if (g_iSlenderCopyMaster[iBossIndex] != -1) continue; // Copies cannot generate proxies.
				
				if (GetGameTime() < g_flSlenderTimeUntilNextProxy[iBossIndex]) continue; // Proxy spawning hasn't cooled down yet.

				int iTeleportTarget = EntRefToEntIndex(g_iSlenderProxyTarget[iBossIndex]);
				if (!iTeleportTarget || iTeleportTarget == INVALID_ENT_REFERENCE) continue; // No teleport target.

				NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
				
				int iMaxProxies = GetProfileNum(sProfile, "proxies_max");
				if (g_bProxySurvivalRageMode) iMaxProxies += 5;
				
				int iNumActiveProxies = 0;
				
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsClientInGame(iClient) || !g_bPlayerEliminated[iClient]) continue;
					if (!g_bPlayerProxy[iClient]) continue;
					
					if (NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]) == iBossIndex)
					{
						iNumActiveProxies++;
					}
				}
				if (iNumActiveProxies >= iMaxProxies) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d has too many active proxies!", iBossIndex);
					//PrintToChatAll("[PROXIES] Boss %d has too many active proxies!", iBossIndex);
#endif
					continue;
				}
				
				float flSpawnChanceMin = GetProfileFloat(sProfile, "proxies_spawn_chance_min");
				float flSpawnChanceMax = GetProfileFloat(sProfile, "proxies_spawn_chance_max");
				float flSpawnChanceThreshold = GetProfileFloat(sProfile, "proxies_spawn_chance_threshold") * NPCGetAnger(iBossIndex);
				
				float flChance = GetRandomFloat(flSpawnChanceMin, flSpawnChanceMax);
				if (flChance > flSpawnChanceThreshold && !g_bProxySurvivalRageMode) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d's chances weren't in his favor!", iBossIndex);
					//PrintToChatAll("[PROXIES] Boss %d's chances weren't in his favor!", iBossIndex);
#endif
					continue;
				}
				
				int iAvailableProxies = iMaxProxies - iNumActiveProxies;
				
				int iSpawnNumMin = GetProfileNum(sProfile, "proxies_spawn_num_min");
				int iSpawnNumMax = GetProfileNum(sProfile, "proxies_spawn_num_max");
				
				int iSpawnNum = 0;
				
				// Get a list of people we can transform into a good Proxy.
				ClearArray(hProxyCandidates);
				
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsClientInGame(iClient) || !g_bPlayerEliminated[iClient]) continue;
					if (g_bPlayerProxy[iClient]) continue;
					
					if (!g_iPlayerPreferences[iClient].PlayerPreference_EnableProxySelection)
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because of your preferences.", iBossIndex);
						//PrintToChatAll("[PROXIES] You were rejected for being a proxy for boss %d because of your preferences.", iBossIndex);
#endif
						continue;
					}
					
					if (!g_bPlayerProxyAvailable[iClient])
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because of your cooldown.", iBossIndex);
#endif
						continue;
					}
					
					if (g_bPlayerProxyAvailableInForce[iClient])
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because you're already being forced into a Proxy.", iBossIndex);
#endif
						continue;
					}
					
					if (!IsClientParticipating(iClient))
					{
#if defined DEBUG
						SendDebugMessageToPlayer(iClient, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because you're not participating.", iBossIndex);
#endif
						continue;
					}
					
					PushArrayCell(hProxyCandidates, iClient);
					iSpawnNum++;
				}
				
				if (iSpawnNum >= iSpawnNumMax)
				{
					iSpawnNum = GetRandomInt(iSpawnNumMin, iSpawnNumMax);
				}
				else if (iSpawnNum >= iSpawnNumMin)
				{
					iSpawnNum = GetRandomInt(iSpawnNumMin, iSpawnNum);
				}
				
				if (iSpawnNum <= 0) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d had a set spawn number of 0!", iBossIndex);
#endif
					continue;
				}
				bool bCooldown = false;
				// Randomize the array.
				SortADTArray(hProxyCandidates, Sort_Random, Sort_Integer);
				
				float flDestinationPos[3];
				
				for (int iNum = 0; iNum < iSpawnNum && iNum < iAvailableProxies; iNum++)
				{
					int iClient = GetArrayCell(hProxyCandidates, iNum);
					int iSpawnPoint = -1;

					if (!SpawnProxy(iClient, iBossIndex, flDestinationPos, iSpawnPoint))
					{
#if defined DEBUG
						SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d could not find any areas to place proxies (spawned %d)!", iBossIndex, iNum);
						//PrintToChatAll("[PROXIES] Boss %d could not find any areas to place proxies (spawned %d)!", iBossIndex, iNum);
#endif
						break;
					}
					bCooldown = true;
					if (!GetConVarBool(g_cvPlayerProxyAsk))
					{
						ClientStartProxyForce(iClient, NPCGetUniqueID(iBossIndex), flDestinationPos, iSpawnPoint);
					}
					else
					{
						DisplayProxyAskMenu(iClient, NPCGetUniqueID(iBossIndex), flDestinationPos, iSpawnPoint);
					}
				}
				// Set the cooldown time!
				if(bCooldown)
				{
					float flSpawnCooldownMin = GetProfileFloat(sProfile, "proxies_spawn_cooldown_min");
					float flSpawnCooldownMax = GetProfileFloat(sProfile, "proxies_spawn_cooldown_max");
				
					g_flSlenderTimeUntilNextProxy[iBossIndex] = GetGameTime() + GetRandomFloat(flSpawnCooldownMin, flSpawnCooldownMax);
				}
				else
					g_flSlenderTimeUntilNextProxy[iBossIndex] = GetGameTime() + GetRandomFloat(3.0, 4.0);
				
#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0,"[PROXIES] Boss %d finished proxy process!", iBossIndex);
#endif
			}
			
			delete hProxyCandidates;
		}
	}
	
	PvP_OnGameFrame();

	return Plugin_Continue;
}

//	==========================================================
//	COMMANDS AND COMMAND HOOK FUNCTIONS
//	==========================================================

public Action Command_Help(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayMenu(g_hMenuHelp, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Settings(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayMenu(g_hMenuSettings, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Credits(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayMenu(g_hMenuCredits, iClient, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action Command_BossList(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayBossList(iClient);
	return Plugin_Handled;
}

public Action Command_ToggleFlashlight(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient)) return Plugin_Handled;
	
	if (!IsRoundInWarmup() && !IsRoundInIntro() && !IsRoundEnding() && !DidClientEscape(iClient))
	{
		if (GetGameTime() >= ClientGetFlashlightNextInputTime(iClient))
		{
			ClientHandleFlashlight(iClient);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_SprintOn(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsPlayerAlive(iClient) && !g_bPlayerEliminated[iClient])
	{
		ClientHandleSprint(iClient, true);
	}
	
	return Plugin_Handled;
}

public Action Command_SprintOff(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsPlayerAlive(iClient) && !g_bPlayerEliminated[iClient])
	{
		ClientHandleSprint(iClient, false);
	}
	
	return Plugin_Handled;
}

public Action DevCommand_BossPackVote(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	InitiateBossPackVote(iClient);
	return Plugin_Handled;
}

public Action Command_NoPoints(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	if(!g_bAdminNoPoints[iClient])
	{
		CPrintToChat(iClient, "{royalblue}Disabled going to RED naturally.");
		g_bAdminNoPoints[iClient] = true;
	}
	else
	{
		CPrintToChat(iClient, "{royalblue}Enabled going to RED naturally.");
		g_bAdminNoPoints[iClient] = false;
	}
	return Plugin_Handled;
}

public Action Command_MainMenu(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	DisplayMenu(g_hMenuMain, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Tutorial(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	//Tutorial_HandleClient(iClient);
	return Plugin_Handled;
}

public Action Command_Update(int iClient, int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	DisplayMenu(g_hMenuUpdate, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Next(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayQueuePointsMenu(iClient);
	return Plugin_Handled;
}


public Action Command_Group(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	DisplayGroupMainMenuToClient(iClient);
	return Plugin_Handled;
}

public Action Command_GroupName(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_slgroupname <name>");
		return Plugin_Handled;
	}
	
	int iGroupIndex = ClientGetPlayerGroup(iClient);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		CPrintToChat(iClient, "%T", "SF2 Group Does Not Exist", iClient);
		return Plugin_Handled;
	}
	
	if (GetPlayerGroupLeader(iGroupIndex) != iClient)
	{
		CPrintToChat(iClient, "%T", "SF2 Not Group Leader", iClient);
		return Plugin_Handled;
	}
	
	char sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
	GetCmdArg(1, sGroupName, sizeof(sGroupName));
	if (!sGroupName[0])
	{
		CPrintToChat(iClient, "%T", "SF2 Invalid Group Name", iClient);
		return Plugin_Handled;
	}
	
	char sOldGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
	GetPlayerGroupName(iGroupIndex, sOldGroupName, sizeof(sOldGroupName));
	SetPlayerGroupName(iGroupIndex, sGroupName);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		if (ClientGetPlayerGroup(i) != iGroupIndex) continue;
		CPrintToChat(i, "%T", "SF2 Group Name Set", i, sOldGroupName, sGroupName);
	}
	
	return Plugin_Handled;
}
public Action Command_GhostMode(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (IsRoundEnding() || IsRoundInWarmup() || !g_bPlayerEliminated[iClient] || !IsClientParticipating(iClient) || g_bPlayerProxy[iClient] || IsClientInPvP(iClient) || IsClientInKart(iClient) || TF2_IsPlayerInCondition(iClient,TFCond_Taunting)|| TF2_IsPlayerInCondition(iClient,TFCond_Charging) || g_flLastCommandTime[iClient] > GetEngineTime())
	{
		CPrintToChat(iClient, "{red}%T", "SF2 Ghost Mode Not Allowed", iClient);
		return Plugin_Handled;
	}
	if (!IsClientInGhostMode(iClient))
	{
		TF2_RespawnPlayer(iClient);
		ClientSetGhostModeState(iClient, true);
		HandlePlayerHUD(iClient);
		TF2_AddCondition(iClient, TFCond_StealthedUserBuffFade, -1.0);
	
		CPrintToChat(iClient, "{dodgerblue}%T", "SF2 Ghost Mode Enabled", iClient);
	}
	else
	{
		ClientSetGhostModeState(iClient, false);
		TF2_RespawnPlayer(iClient);
		TF2_RemoveCondition(iClient, TFCond_StealthedUserBuffFade);
		
		CPrintToChat(iClient, "{dodgerblue}%T", "SF2 Ghost Mode Disabled", iClient);
	}
	g_flLastCommandTime[iClient] = GetEngineTime()+0.5;
	return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	if (!g_bPlayerCalledForNightmare[client])
		g_bPlayerCalledForNightmare[client] = (StrContains(sArgs, "nightmare", false) != -1 || StrContains(sArgs, "Nightmare", false) != -1 );

	if (!g_bEnabled || g_cvAllChat.BoolValue || SF_IsBoxingMap()) return Plugin_Continue;

	if (!IsRoundEnding()) {
		bool bSayTeam = strcmp(command, "say_team") == 0;

		if (g_bPlayerEliminated[client]) 
		{
			if (!IsPlayerAlive(client) && GetClientTeam(client) == TFTeam_Red)
				return Plugin_Stop; // Plugin_Stop in this case stops message AND post hook so bot won't see message in OnClientSayCommand_Post()

			char szMessage[256];
			FormatEx(szMessage, sizeof szMessage, "{blue}%N:{default} %s", client, sArgs);
			//Broadcast the msg to the source tv, if the server has one.
			PrintToSourceTV(szMessage);

			if (!bSayTeam) 
			{
				FakeClientCommandEx(client, "say_team %s", sArgs);
				return Plugin_Stop;
			}
		}

		if (!bSayTeam) 
		{
			char szMessage[256];
			FormatEx(szMessage, sizeof szMessage, "{red}%N:{default} %s", client, sArgs);
			//Broadcast the msg to the source tv, if the server has one.
			PrintToSourceTV(szMessage);
		}
	}
	
	return Plugin_Continue;
}
public Action Hook_CommandSuicideAttempt(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (GetClientTeam(iClient) == TFTeam_Spectator) return Plugin_Continue;
	if (IsClientInGhostMode(iClient)) return Plugin_Handled;
	
	if (IsRoundInIntro() && !g_bPlayerEliminated[iClient]) return Plugin_Handled;
	
	if (GetConVarBool(g_cvBlockSuicideDuringRound))
	{
		if (!g_bRoundGrace && !g_bPlayerEliminated[iClient] && !DidClientEscape(iClient))
		{
			return Plugin_Handled;
		}
	}
	
	if (IsClientInPvP(iClient)) //Nobody asked you to cheat your way out of PvP to miss a kill.
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
public Action Hook_CommandPreventJoinTeam(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (GetClientTeam(iClient) == TFTeam_Spectator) return Plugin_Continue;
	if (IsClientInGhostMode(iClient)) return Plugin_Handled;
	
	if (IsRoundInIntro() && !g_bPlayerEliminated[iClient]) return Plugin_Handled;
	
	if (GetConVarBool(g_cvBlockSuicideDuringRound))
	{
		if (!g_bRoundGrace && !g_bPlayerEliminated[iClient] && !DidClientEscape(iClient))
		{
			return Plugin_Handled;
		}
	}
	
	if (IsClientInPvP(iClient)) //Nobody asked you to cheat your way out of PvP to miss a kill.
	{
		return Plugin_Handled;
	}
	
	if (IsClientInKart(iClient))
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Hook_CommandBlockInGhostMode(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (IsClientInGhostMode(iClient)) return Plugin_Handled;
	if (IsRoundInIntro() && !g_bPlayerEliminated[iClient]) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Hook_CommandVoiceMenu(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (IsClientInGhostMode(iClient))
	{
		ClientGhostModeNextTarget(iClient);
		return Plugin_Handled;
	}
	
	if (g_bPlayerProxy[iClient]) //We want to implement custom voices
	{
		int iMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]);
		if (iMaster != -1)
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iMaster, sProfile, sizeof(sProfile));
			char sBuffer[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_proxy_idle", sBuffer, sizeof(sBuffer));

			if (sBuffer[0] && GetGameTime() >= g_flPlayerProxyNextVoiceSound[iClient])
			{
				int iChannel = GetProfileNum(sProfile, "sound_proxy_idle_channel", SNDCHAN_AUTO);
				int iLevel = GetProfileNum(sProfile, "sound_proxy_idle_level", SNDLEVEL_NORMAL);
				int iFlags = GetProfileNum(sProfile, "sound_proxy_idle_flags", SND_NOFLAGS);
				float flVolume = GetProfileFloat(sProfile, "sound_proxy_idle_volume", SNDVOL_NORMAL);
				int iPitch = GetProfileNum(sProfile, "sound_proxy_idle_pitch", SNDPITCH_NORMAL);

				EmitSoundToAll(sBuffer, iClient, iChannel, iLevel, iFlags, flVolume, iPitch);
				float flCooldownMin = GetProfileFloat(sProfile, "sound_proxy_idle_cooldown_min", 1.5);
				float flCooldownMax = GetProfileFloat(sProfile, "sound_proxy_idle_cooldown_max", 3.0);
				
				g_flPlayerProxyNextVoiceSound[iClient] = GetGameTime() + GetRandomFloat(flCooldownMin, flCooldownMax);
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Command_ClientPerformScare(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_scare <name|#userid> <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32], arg2[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		ClientPerformScare(target, StringToInt(arg2));
	}
	
	return Plugin_Handled;
}

public Action Command_SpawnSlender(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args == 0)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_spawn_boss <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(StringToInt(arg1));
	if (NPCGetUniqueID(Npc.Index) == -1) return Plugin_Handled;
	
	float eyePos[3], eyeAng[3], endPos[3];
	GetClientEyePosition(iClient, eyePos);
	GetClientEyeAngles(iClient, eyeAng);
	
	Handle hTrace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_NPCSOLID, RayType_Infinite, TraceRayDontHitEntity, iClient);
	TR_GetEndPosition(endPos, hTrace);
	delete hTrace;
	
	SpawnSlender(Npc, endPos);
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	Npc.GetProfile(sProfile, sizeof(sProfile));
	
	CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Spawned Boss", iClient);

	return Plugin_Handled;
}

public Action Command_RemoveSlender(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args == 0)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_remove_boss <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iBossIndex = StringToInt(arg1);
	if (NPCGetUniqueID(iBossIndex) == -1) return Plugin_Handled;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	NPCRemove(iBossIndex);
	
	if (SF_IsBoxingMap() && (GetRoundState() == SF2RoundState_Escape) && view_as<bool>(GetProfileNum(sProfile,"boxing_boss",0)))
	{
		g_iSlenderBoxingBossCount -= 1;
	}
	
	if (MusicActive() && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES) && BossHasMusic(sProfile))
	{
		NPCStopMusic();
	}
	
	CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Removed Boss", iClient);
	
	return Plugin_Handled;
}

public Action Command_RemoveAllSlenders(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (!SF_IsBoxingMap())
	{
		for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
		{
			if (NPCGetUniqueID(iNPCIndex) == -1) continue;
			NPCRemove(iNPCIndex);
		}
		CPrintToChat(iClient, "{royalblue}%t{default}Removed all bosses.", "SF2 Prefix", iClient);
	}
	else
	{
		CPrintToChat(iClient, "{royalblue}%t{default}Cannot use this command in Boxing maps.", "SF2 Prefix", iClient);
	}

	if (MusicActive() && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
	{
		NPCStopMusic();
	}

	return Plugin_Handled;
}

public Action Command_GetBossIndexes(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	char sMessage[512];
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	if (!IsValidClient(iClient))
	{
		LogMessage("Active Boss Indexes:");
		LogMessage("----------------------------");
	}
	else
	{
		ClientCommand(iClient, "echo Active Boss Indexes:");
		ClientCommand(iClient, "echo ----------------------------");
	}
	
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		
		NPCGetProfile(i, sProfile, sizeof(sProfile));
		
		FormatEx(sMessage, sizeof(sMessage), "%d - %s", i, sProfile);
		if (NPCGetFlags(i) & SFF_FAKE)
		{
			StrCat(sMessage, sizeof(sMessage), " (fake)");
		}
		
		if (g_iSlenderCopyMaster[i] != -1)
		{
			char sCat[64];
			FormatEx(sCat, sizeof(sCat), " (copy of %d)", g_iSlenderCopyMaster[i]);
			StrCat(sMessage, sizeof(sMessage), sCat);
		}
		
		if (IsValidClient(iClient))
		{
			ClientCommand(iClient, "echo %s", sMessage);
		}
		else
		{
			LogMessage("%s", sMessage);
		}
	}
	
	if (IsValidClient(iClient))
	{
		ClientCommand(iClient, "echo ----------------------------");
		
		ReplyToCommand(iClient, "Printed active boss indexes to your console!");
	}
	else
	{
		LogMessage("----------------------------");

		LogMessage("Printed active boss indexes to the server console!");
	}
	
	return Plugin_Handled;
}

public Action Command_SlenderAttackWaiters(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_boss_attack_waiters <bossindex 0-%d> <0/1>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iBossIndex = StringToInt(arg1);
	if (NPCGetUniqueID(iBossIndex) == -1) return Plugin_Handled;
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iBossFlags = NPCGetFlags(iBossIndex);
	
	bool bState = view_as<bool>(StringToInt(arg2));
	bool bOldState = view_as<bool>(iBossFlags & SFF_ATTACKWAITERS);
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (bState)
	{
		if (!bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags | SFF_ATTACKWAITERS);
			CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Boss Attack Waiters", iClient);
		}
	}
	else
	{
		if (bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags & ~SFF_ATTACKWAITERS);
			CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Boss Do Not Attack Waiters", iClient);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_SlenderNoTeleport(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_boss_no_teleport <bossindex 0-%d> <0/1>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iBossIndex = StringToInt(arg1);
	if (NPCGetUniqueID(iBossIndex) == -1) return Plugin_Handled;
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iBossFlags = NPCGetFlags(iBossIndex);
	
	bool bState = view_as<bool>(StringToInt(arg2));
	bool bOldState = view_as<bool>(iBossFlags & SFF_NOTELEPORT);
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (bState)
	{
		if (!bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags | SFF_NOTELEPORT);
			CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Boss Should Not Teleport", iClient);
		}
	}
	else
	{
		if (bOldState)
		{
			NPCSetFlags(iBossIndex, iBossFlags & ~SFF_NOTELEPORT);
			CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Boss Should Teleport", iClient);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_ToggleAllBossTeleports(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_toggle_boss_teleports <0/1>");
		return Plugin_Handled;
	}

	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));

	int iState = StringToInt(arg1);

	for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
	{
		if (NPCGetUniqueID(iNPCIndex) == -1) continue;
		int iBossFlags = NPCGetFlags(iNPCIndex);
		if (iState) NPCSetFlags(iNPCIndex, iBossFlags | SFF_NOTELEPORT);
		else if (!iState) NPCSetFlags(iNPCIndex, iBossFlags & ~SFF_NOTELEPORT);
	}
	if (iState) 
	{
		CPrintToChat(iClient, "{royalblue}%t{default}All bosses can no longer teleport.", "SF2 Prefix", iClient);
	}
	else if (!iState) 
	{
		CPrintToChat(iClient, "{royalblue}%t{default}All bosses can now teleport.", "SF2 Prefix", iClient);
	}

	return Plugin_Handled;
}

public Action Command_ToggleAllAttackWaiters(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_toggle_attack_waiters <0/1>");
		return Plugin_Handled;
	}

	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));

	int iState = StringToInt(arg1);

	for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
	{
		if (NPCGetUniqueID(iNPCIndex) == -1) continue;
		int iBossFlags = NPCGetFlags(iNPCIndex);
		if (iState) NPCSetFlags(iNPCIndex, iBossFlags | SFF_ATTACKWAITERS);
		else if (!iState) NPCSetFlags(iNPCIndex, iBossFlags & ~SFF_ATTACKWAITERS);
	}
	if (iState) 
	{
		CPrintToChat(iClient, "{royalblue}%t{default}All bosses can now attack waiters.", "SF2 Prefix", iClient);
	}
	else if (!iState) 
	{
		CPrintToChat(iClient, "{royalblue}%t{default}All bosses can no longer attack waiters.", "SF2 Prefix", iClient);
	}

	return Plugin_Handled;
}

public Action Command_ForceProxy(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_force_proxy <name|#userid> <bossindex 0-%d>", MAX_BOSSES - 1);
		return Plugin_Handled;
	}
	
	if (IsRoundEnding() || IsRoundInWarmup())
	{
		CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Cannot Use Command", iClient);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iBossIndex = StringToInt(arg2);
	if (iBossIndex < 0 || iBossIndex >= MAX_BOSSES)
	{
		ReplyToCommand(iClient, "Boss index is out of range!");
		return Plugin_Handled;
	}
	else if (NPCGetUniqueID(iBossIndex) == -1)
	{
		ReplyToCommand(iClient, "Boss index is invalid! Boss index not active!");
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		int iTarget = target_list[i];
		
		char sName[MAX_NAME_LENGTH];
		if (IsClientSourceTV(iTarget)) continue;//Exclude the sourcetv bot
		FormatEx(sName, sizeof(sName), "%N", iTarget);

		if (!g_bPlayerEliminated[iTarget])
		{
			CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Unable To Perform Action On Player In Round", iClient, sName);
			continue;
		}

		if (g_bPlayerProxy[iTarget]) continue; //Exclude any active proxies

		float flintPos[3];
		int iSpawnPoint = -1;

		if (!SpawnProxy(iClient, iBossIndex, flintPos, iSpawnPoint)) 
		{
			CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Player No Place For Proxy", iClient, sName);
			continue;
		}
		
		ClientEnableProxy(iTarget, iBossIndex, flintPos, iSpawnPoint);
	}
	
	return Plugin_Handled;
}

public Action Command_ForceEscape(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_force_escape <name|#userid>");
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		if (!g_bPlayerEliminated[i] && !DidClientEscape(i))
		{
			ClientEscape(target);
			TeleportClientToEscapePoint(target);
		}
	}
	
	return Plugin_Handled;
}
public Action Command_ForceDifficulty(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (args == 0)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_set_difficulty <difficulty 1-5>");
		return Plugin_Handled;
	}
	
	if (IsRoundEnding() || IsRoundInWarmup())
	{
		CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Cannot Use Command", iClient);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iNewDifficulty = StringToInt(arg1);
	
	if (iNewDifficulty < 1)
	{
		iNewDifficulty = 1;
	}
	else if (iNewDifficulty > 5)
	{
		iNewDifficulty = 5;
	}
	else if (iNewDifficulty > 0 && iNewDifficulty < 6)
	{
		SetConVarInt(g_cvDifficulty, iNewDifficulty);
	}
	
	switch (iNewDifficulty)
	{
		case Difficulty_Normal: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the difficulty to {yellow}%t{default}.", "SF2 Prefix", iClient, "SF2 Normal Difficulty");
		case Difficulty_Hard: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the difficulty to {orange}%t{default}.", "SF2 Prefix", iClient, "SF2 Hard Difficulty");
		case Difficulty_Insane: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the difficulty to {red}%t{default}.", "SF2 Prefix", iClient, "SF2 Insane Difficulty");
		case Difficulty_Nightmare: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the difficulty to {valve}Nightmare!", "SF2 Prefix", iClient);
		case Difficulty_Apollyon: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the difficulty to {darkgray}Apollyon!", "SF2 Prefix", iClient);
	}

	return Plugin_Handled;
}
public Action Command_ForceSpecialRound(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (args == 0)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_force_special_round <specialround 1-37>");
		return Plugin_Handled;
	}

	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int iSpecialRound = StringToInt(arg1);
	
	if (iSpecialRound < 1)
	{
		iSpecialRound = 1;
	}
	else if (iSpecialRound > 38)
	{
		iSpecialRound = 38;
	}
	else if (iSpecialRound > 0 && iSpecialRound < 39)
	{
		SetConVarInt(g_cvSpecialRoundOverride, iSpecialRound);
	}
	
	switch (iSpecialRound)
	{
		case SPECIALROUND_DOUBLETROUBLE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Double Trouble.", "SF2 Prefix", iClient);
		case SPECIALROUND_INSANEDIFFICULTY: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Suicide Time.", "SF2 Prefix", iClient);
		case SPECIALROUND_DOUBLEMAXPLAYERS: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Double Players.", "SF2 Prefix", iClient);
		case SPECIALROUND_LIGHTSOUT: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Lights Out.", "SF2 Prefix", iClient);
		case SPECIALROUND_BEACON: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Bacon Spray.", "SF2 Prefix", iClient);
		case SPECIALROUND_DOOMBOX: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Stealth Box of Doom.", "SF2 Prefix", iClient);
		case SPECIALROUND_NOGRACE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Start Running.", "SF2 Prefix", iClient);
		case SPECIALROUND_2DOUBLE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Double It All, But Go No Higher.", "SF2 Prefix", iClient);
		case SPECIALROUND_DOUBLEROULETTE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Double Roulette.", "SF2 Prefix", iClient);
		case SPECIALROUND_NIGHTVISION: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Night Vision.", "SF2 Prefix", iClient);
		case SPECIALROUND_INFINITEFLASHLIGHT: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Infinite Flashlight.", "SF2 Prefix", iClient);
		case SPECIALROUND_DREAMFAKEBOSSES: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Just A Dream.", "SF2 Prefix", iClient);
		case SPECIALROUND_EYESONTHECLOACK: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Countdown.", "SF2 Prefix", iClient);
		case SPECIALROUND_NOPAGEBONUS: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Deadline.", "SF2 Prefix", iClient);
		case SPECIALROUND_DUCKS: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Ducks.", "SF2 Prefix", iClient);
		case SPECIALROUND_1UP: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}1-Up.", "SF2 Prefix", iClient);
		case SPECIALROUND_NOULTRAVISION: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Blind.", "SF2 Prefix", iClient);
		case SPECIALROUND_SUPRISE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Surprise Me.", "SF2 Prefix", iClient);
		case SPECIALROUND_LASTRESORT: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Last Resort.", "SF2 Prefix", iClient);
		case SPECIALROUND_ESCAPETICKETS: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Escape Tickets.", "SF2 Prefix", iClient);
		case SPECIALROUND_REVOLUTION: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Special Round Revolution.", "SF2 Prefix", iClient);
		case SPECIALROUND_DISTORTION: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Space Distortion.", "SF2 Prefix", iClient);
		case SPECIALROUND_MULTIEFFECT: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Multieffect.", "SF2 Prefix", iClient);
		case SPECIALROUND_BOO: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Boo.", "SF2 Prefix", iClient);
		case SPECIALROUND_REALISM: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Marble Hornets.", "SF2 Prefix", iClient);
		case SPECIALROUND_VOTE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Special Round Vote.", "SF2 Prefix", iClient);
		case SPECIALROUND_COFFEE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Coffee.", "SF2 Prefix", iClient);
		case SPECIALROUND_PAGEDETECTOR: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Item Detectors.", "SF2 Prefix", iClient);
		case SPECIALROUND_CLASSSCRAMBLE: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Class Scramble.", "SF2 Prefix", iClient);
		case SPECIALROUND_2DOOM: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Silent Slender.", "SF2 Prefix", iClient);
		case SPECIALROUND_WALLHAX: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Wall Hax.", "SF2 Prefix", iClient);
		case SPECIALROUND_HYPERSNATCHER:
		{
			if (!SF_IsBoxingMap()) CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Hyper Snatcher {default}(Warning, you're going to die).", "SF2 Prefix", iClient);
			else CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Hyper Argonite Giant {default}(Warning, be so prepared).", "SF2 Prefix", iClient);
		}
		case SPECIALROUND_PAGEREWARDS: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Page Rewards.", "SF2 Prefix", iClient);
		case SPECIALROUND_TINYBOSSES: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Tiny Bosses.", "SF2 Prefix", iClient);
		case SPECIALROUND_RUNNINGINTHE90S: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}In The 90s.", "SF2 Prefix", iClient);
		case SPECIALROUND_TRIPLEBOSSES: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}Triple Bosses.", "SF2 Prefix", iClient);
		case SPECIALROUND_20DOLLARS: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}20 Dollars.", "SF2 Prefix", iClient);
		case SPECIALROUND_MODBOSSES: CPrintToChatAll("{royalblue}%t{collectors}%N {default}set the next special round to {lightblue}MODified Bosses {default}(WARNING, ITS H3LL).", "SF2 Prefix", iClient);
	}

	return Plugin_Handled;
}

public Action Command_AddSlender(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_add_boss <name>");
		return Plugin_Handled;
	}
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetCmdArg(1, sProfile, sizeof(sProfile));
	
	KvRewind(g_hConfig);
	if (!KvJumpToKey(g_hConfig, sProfile)) 
	{
		ReplyToCommand(iClient, "That boss does not exist!");
		return Plugin_Handled;
	}
	
	SF2NPC_BaseNPC Npc = AddProfile(sProfile);
	if (Npc.IsValid())
	{
		float eyePos[3], eyeAng[3], flPos[3];
		GetClientEyePosition(iClient, eyePos);
		GetClientEyeAngles(iClient, eyeAng);

		Handle hTrace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_NPCSOLID, RayType_Infinite, TraceRayDontHitEntity, iClient);
		TR_GetEndPosition(flPos, hTrace);
		delete hTrace;
	
		SpawnSlender(Npc, flPos);
		
		if (SF_IsBoxingMap() && (GetRoundState() == SF2RoundState_Escape) && view_as<bool>(GetProfileNum(sProfile,"boxing_boss",0)))
		{
			g_iSlenderBoxingBossCount += 1;
		}
	}
	
	return Plugin_Handled;
}
public void NPCSpawn(const char[] output,int iEnt,int activator, float delay)
{
	if (!g_bEnabled) return;
	char targetName[255];
	float vecPos[3];
	GetEntPropString(iEnt, Prop_Data, "m_iName", targetName, sizeof(targetName));
	if (targetName[0])
	{
		if (!StrContains(targetName, "sf2_spawn_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_spawn_", "", false);
			KvRewind(g_hConfig);
			if (!KvJumpToKey(g_hConfig, targetName)) 
			{
				if (!SF_IsBoxingMap())
				{
					PrintToServer("Entity: %i.That boss does not exist!",iEnt);
				}
				return;
			}
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			SF2NPC_BaseNPC Npc;
			for(int iNpc;iNpc<=MAX_BOSSES;iNpc++)
			{
				Npc = view_as<SF2NPC_BaseNPC>(iNpc);
				if(Npc.IsValid())
				{
					Npc.GetProfile(sProfile,sizeof(sProfile));
					if(strcmp(sProfile,targetName) == 0)
					{
						Npc.UnSpawn();
						float flPos[3];
						GetEntPropVector(iEnt, Prop_Data, "m_vecOrigin", flPos);
						SpawnSlender(Npc, flPos);
						break;
					}
				}
			}
		}
		if (SF_IsBoxingMap())
		{
			ArrayList hSpawnPoint = new ArrayList();
			if (strcmp(targetName, "sf2_boxing_boss_spawn") == 0)
			{
				hSpawnPoint.Push(iEnt);
			}
			iEnt = -1;
			if (hSpawnPoint.Length > 0) iEnt = hSpawnPoint.Get(GetRandomInt(0,hSpawnPoint.Length-1));
			delete hSpawnPoint;
			if (iEnt > MaxClients)
			{
				GetEntPropVector(iEnt, Prop_Data, "m_vecAbsOrigin", vecPos);
				for(int iNpc = 0;iNpc <= MAX_BOSSES; iNpc++)
				{
					SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(iNpc);
					if (!Npc.IsValid()) continue;
					if (Npc.Flags & SFF_NOTELEPORT)
					{
						continue;
					}
					Npc.UnSpawn();
					SpawnSlender(Npc, vecPos);
					break;
				}
			}
		}
	}
	return;
}

public Action Command_AddSlenderFake(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 1)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_add_boss_fake <name>");
		return Plugin_Handled;
	}
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetCmdArg(1, sProfile, sizeof(sProfile));
	
	KvRewind(g_hConfig);
	if (!KvJumpToKey(g_hConfig, sProfile)) 
	{
		ReplyToCommand(iClient, "That boss does not exist!");
		return Plugin_Handled;
	}
	
	SF2NPC_BaseNPC Npc = AddProfile(sProfile, SFF_FAKE);
	if (Npc.IsValid())
	{
		float eyePos[3], eyeAng[3], flPos[3];
		GetClientEyePosition(iClient, eyePos);
		GetClientEyeAngles(iClient, eyeAng);
		
		Handle hTrace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_NPCSOLID, RayType_Infinite, TraceRayDontHitEntity, iClient);
		TR_GetEndPosition(flPos, hTrace);
		delete hTrace;
	
		SpawnSlender(Npc, flPos);
	}
	
	return Plugin_Handled;
}

public Action Command_ForceState(int iClient,int args)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (args < 2)
	{
		ReplyToCommand(iClient, "Usage: sm_sf2_setplaystate <name|#userid> <0/1>");
		return Plugin_Handled;
	}
	
	if (IsRoundEnding() || IsRoundInWarmup())
	{
		CPrintToChat(iClient, "{royalblue}%t{default}%T", "SF2 Prefix", "SF2 Cannot Use Command", iClient);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			iClient,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(iClient, target_count);
		return Plugin_Handled;
	}
	
	char arg2[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int iState = StringToInt(arg2);
	
	char sName[MAX_NAME_LENGTH];
	
	for (int i = 0; i < target_count; i++)
	{
		int target = target_list[i];
		
		if (IsClientSourceTV(target)) continue;//Exclude the sourcetv bot
		
		FormatEx(sName, sizeof(sName), "%N", target);
		
		if (g_bPlayerProxy[target]) continue;//Can't force proxies
		
		if (iState && g_bPlayerEliminated[target])
		{
			SetClientPlayState(target, true);
			
			CPrintToChatAll("{royalblue}%t {collectors}%N: {default}%t", "SF2 Prefix", iClient, "SF2 Player Forced In Game", sName);
		}
		else if (!iState && !g_bPlayerEliminated[target])
		{
			SetClientPlayState(target, false);
			
			CPrintToChatAll("{royalblue}%t {collectors}%N: {default}%t", "SF2 Prefix", iClient, "SF2 Player Forced Out Of Game", sName);
		}
	}
	
	return Plugin_Handled;
}

public Action Hook_CommandBuild(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (!IsClientInPvP(iClient)) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Hook_CommandTaunt(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (!g_bPlayerEliminated[iClient] && GetRoundState() == SF2RoundState_Intro) return Plugin_Handled;
	if (IsClientInGhostMode(iClient)) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Hook_CommandDisguise(int iClient, const char[] command,int argc)
{
	if (!g_bEnabled) return Plugin_Continue;
	return Plugin_Handled;
}

public Action Timer_BlueNightvisionOutline(Handle timer)
{
	if (timer != g_hBlueNightvisionOutlineTimer) return Plugin_Stop;
	
	if (!g_bEnabled) return Plugin_Stop;

	for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
	{	
		if (NPCGetUniqueID(iNPCIndex) == -1) continue;
		SlenderRemoveGlow(iNPCIndex);
		char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		NPCGetProfile(iNPCIndex, sProfile, sizeof(sProfile));
		if (NPCGetCustomOutlinesState(iNPCIndex))
		{
			int color[4];
			color[0] = NPCGetOutlineColorR(iNPCIndex);
			color[1] = NPCGetOutlineColorG(iNPCIndex);
			color[2] = NPCGetOutlineColorB(iNPCIndex);
			color[3] = NPCGetOutlineTransparency(iNPCIndex);
			if (color[0] < 0) color[0] = 0;
			if (color[1] < 0) color[1] = 0;
			if (color[2] < 0) color[2] = 0;
			if (color[3] < 0) color[3] = 0;
			if (color[0] > 255) color[0] = 255;
			if (color[1] > 255) color[1] = 255;
			if (color[2] > 255) color[2] = 255;
			if (color[3] > 255) color[3] = 255;
			SlenderAddGlow(iNPCIndex,_,color);
		}
		else
		{
			int iPurple[4] = {150, 0, 255, 255};
			SlenderAddGlow(iNPCIndex,_,iPurple);
		}
	}
	return Plugin_Continue;
}

public Action Timer_BossCountUpdate(Handle timer)
{
	if (timer != g_hBossCountUpdateTimer) return Plugin_Stop;
	
	if (!g_bEnabled) return Plugin_Stop;

	int iBossCount = NPCGetCount();
	int iBossPreferredCount;
	int iDifficulty = GetConVarInt(g_cvDifficulty);

	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1 ||
			g_iSlenderCopyMaster[i] != -1 ||
			(NPCGetFlags(i) & SFF_FAKE))
		{
			continue;
		}
		
		iBossPreferredCount++;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) ||
			!IsPlayerAlive(i) ||
			g_bPlayerEliminated[i] ||
			IsClientInGhostMode(i) ||
			IsClientInDeathCam(i) ||
			DidClientEscape(i)) continue;
		
		// Check if we're near any bosses.
		int iClosest = -1;
		float flBestDist = SquareFloat(SF2_BOSS_PAGE_CALCULATION);
		
		for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
		{
			if (NPCGetUniqueID(iBoss) == -1) continue;
			if (NPCGetEntIndex(iBoss) == INVALID_ENT_REFERENCE) continue;
			if (NPCGetFlags(iBoss) & SFF_FAKE) continue;
			
			float flDist = NPCGetDistanceFromEntity(iBoss, i);
			if (flDist < flBestDist)
			{
				iClosest = iBoss;
				flBestDist = flDist;
				break;
			}
		}
		
		if (iClosest != -1) continue;
		
		iClosest = -1;
		flBestDist = SquareFloat(SF2_BOSS_PAGE_CALCULATION);
		
		for (int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if (!IsValidClient(iClient) ||
				!IsPlayerAlive(iClient) ||
				g_bPlayerEliminated[iClient] ||
				IsClientInGhostMode(iClient) ||
				IsClientInDeathCam(iClient) ||
				DidClientEscape(iClient)) 
			{
				continue;
			}
			
			bool bwub = false;
			for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
			{
				if (NPCGetUniqueID(iBoss) == -1) continue;
				if (NPCGetFlags(iBoss) & SFF_FAKE) continue;
				
				if (g_iSlenderTarget[iBoss] == iClient)
				{
					bwub = true;
					break;
				}
			}
			
			if (!bwub) continue;
			
			float flDist = EntityDistanceFromEntity(i, iClient);
			if (flDist < flBestDist)
			{
				iClosest = iClient;
				flBestDist = flDist;
			}
		}
		
		if (!IsValidClient(iClosest))
		{
			// No one's close to this dude? DUDE! WE NEED ANOTHER BOSS!
			iBossPreferredCount++;
		}
	}
	
	int iDiff = iBossCount - iBossPreferredCount;
	if (iDiff)
	{	
		if (iDiff > 0)
		{
			int iCount = iDiff;
			// We need less bosses. Try and see if we can remove some.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (g_iSlenderCopyMaster[i] == -1) continue;
				if (PeopleCanSeeSlender(i, _, false)) continue;
				if (NPCGetFlags(i) & SFF_FAKE) continue;
				
				if (SlenderCanRemove(i))
				{
					NPCRemove(i);
					iCount--;
				}
				
				if (iCount <= 0)
				{
					break;
				}
			}
		}
		else
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
		
			int iCount = RoundToFloor(FloatAbs(float(iDiff)));
			// Add int bosses (copy of the first boss).
			for (int i = 0; i < MAX_BOSSES && iCount > 0; i++)
			{
				SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(i);
				if (!Npc.IsValid()) continue;
				if (g_iSlenderCopyMaster[Npc.Index] != -1) continue;
				if (!(Npc.Flags & SFF_COPIES)) continue;
				if (Npc.Flags & SFF_FAKE) continue;
				
				// Get the number of copies I already have and see if I can have more copies.
				int iCopyCount;
				for (int i2 = 0; i2 < MAX_BOSSES; i2++)
				{
					if (NPCGetUniqueID(i2) == -1) continue;
					if (g_iSlenderCopyMaster[i2] != i) continue;
					
					iCopyCount++;
				}
				
				Npc.GetProfile(sProfile, sizeof(sProfile));
				int CopyNormal = GetProfileNum(sProfile, "copy_max", 10);
				int CopyEasy = GetProfileNum(sProfile, "copy_max_easy", CopyNormal);
				int CopyHard = GetProfileNum(sProfile, "copy_max_hard", CopyNormal);
				int CopyInsane = GetProfileNum(sProfile, "copy_max_insane", CopyHard);
				int CopyNightmare = GetProfileNum(sProfile, "copy_max_nightmare", CopyInsane);
				int CopyApollyon = GetProfileNum(sProfile, "copy_max_apollyon", CopyNightmare);
				switch (iDifficulty)
				{
					case Difficulty_Easy:
					{
						if (iCopyCount >= CopyEasy) 
						{
							continue;
						}
					}
					case Difficulty_Normal:
					{
						if (iCopyCount >= CopyNormal) 
						{
							continue;
						}
					}
					case Difficulty_Hard:
					{
						if (iCopyCount >= CopyHard) 
						{
							continue;
						}
					}
					case Difficulty_Insane:
					{
						if (iCopyCount >= CopyInsane) 
						{
							continue;
						}
					}
					case Difficulty_Nightmare:
					{
						if (iCopyCount >= CopyNightmare) 
						{
							continue;
						}
					}
					case Difficulty_Apollyon:
					{
						if (iCopyCount >= CopyApollyon) 
						{
							continue;
						}
					}
				}
				SF2NPC_BaseNPC NpcCopy = AddProfile(sProfile, _, Npc);
				if (!NpcCopy.IsValid())
				{
					LogError("Could not add copy for %d: No free slots!", i);
				}
				
				iCount--;
			}
		}
	}
	return Plugin_Continue;
}

void ReloadRestrictedWeapons()
{
	if (g_hRestrictedWeaponsConfig != INVALID_HANDLE)
	{
		delete g_hRestrictedWeaponsConfig;
		g_hRestrictedWeaponsConfig = INVALID_HANDLE;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if (!GetConVarBool(g_cvUseAlternateConfigDirectory)) BuildPath(Path_SM, buffer, sizeof(buffer), FILE_RESTRICTEDWEAPONS);
	else BuildPath(Path_SM, buffer, sizeof(buffer), FILE_RESTRICTEDWEAPONS_DATA);
	KeyValues kv = new KeyValues("root");
	if (!FileToKeyValues(kv, buffer))
	{
		delete kv;
		LogError("Failed to load restricted weapons list! File not found!");
	}
	else
	{
		g_hRestrictedWeaponsConfig = kv;
		LogSF2Message("Reloaded restricted weapons configuration file successfully");
	}
}

public Action Timer_RoundMessages(Handle timer)
{
	if (!g_bEnabled) return Plugin_Stop;
	
	if (timer != g_hRoundMessagesTimer) return Plugin_Stop;
	
	switch (g_iRoundMessagesNum)
	{
		case 0: CPrintToChatAll("{royalblue}== {violet}Slender Fortress{royalblue} coded by {hotpink}KitRifty & Kenzzer{royalblue}==\n== Modified by {deeppink}Mentrillum & The Gaben{royalblue}, current version {violet}%s{royalblue}==", PLUGIN_VERSION_DISPLAY);
		case 1: CPrintToChatAll("%t", "SF2 Ad Message 1");
		case 2: CPrintToChatAll("%t", "SF2 Ad Message 2");
	}
	
	g_iRoundMessagesNum++;
	if (g_iRoundMessagesNum > 2) g_iRoundMessagesNum = 0;
	
	return Plugin_Continue;
}

public Action Timer_WelcomeMessage(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	
	CPrintToChat(iClient, "%T", "SF2 Welcome Message", iClient);
}

int GetMaxPlayersForRound()
{
	int iOverride = GetConVarInt(g_cvMaxPlayersOverride);
	if (iOverride != -1) return iOverride;
	return GetConVarInt(g_cvMaxPlayers);
}

public void OnConVarChanged(Handle cvar, const char[] oldValue, const char[] intValue)
{
	if (cvar == g_cvDifficulty)
	{
		switch (StringToInt(intValue))
		{
			case Difficulty_Easy: g_flRoundDifficultyModifier = DIFFICULTY_NORMAL;
			case Difficulty_Hard: g_flRoundDifficultyModifier = DIFFICULTY_HARD;
			case Difficulty_Insane: g_flRoundDifficultyModifier = DIFFICULTY_INSANE;
			case Difficulty_Nightmare: g_flRoundDifficultyModifier = DIFFICULTY_NIGHTMARE;
			case Difficulty_Apollyon: g_flRoundDifficultyModifier = DIFFICULTY_APOLLYON;
			default: g_flRoundDifficultyModifier = DIFFICULTY_NORMAL;
		}
		if (MusicActive() && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i) || !IsClientInGame(i) || IsClientSourceTV(i)) continue;
				
				char sPath[PLATFORM_MAX_PATH];
				GetBossMusic(sPath,sizeof(sPath));
				StopSound(i, MUSIC_CHAN, sPath);
			}
		}
		ChangeAllSlenderModels();
	}
	else if (cvar == g_cvMaxPlayers || cvar == g_cvMaxPlayersOverride)
	{
		for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
		{
			CheckPlayerGroup(i);
		}
	}
	else if (cvar == g_cvPlayerShakeEnabled)
	{
		g_bPlayerShakeEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvPlayerViewbobEnabled)
	{
		g_bPlayerViewbobEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvPlayerViewbobHurtEnabled)
	{
		g_bPlayerViewbobHurtEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvPlayerViewbobSprintEnabled)
	{
		g_bPlayerViewbobSprintEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvGravity)
	{
		g_flGravity = StringToFloat(intValue);
	}
	else if (cvar == g_cv20Dollars)
	{
		g_b20Dollars = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_cvAllChat || SF_IsBoxingMap())
	{
		if (g_bEnabled)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				ClientUpdateListeningFlags(i);
			}
		}
	}
	else if (cvar == g_cvIgnoreRoundWinConditions)
	{
		if (!view_as<bool>(StringToInt(intValue)) && !IsRoundInWarmup() && !IsRoundEnding())
		{
			CheckRoundWinConditions();
		}
	}
}

//	==========================================================
//	IN-GAME AND ENTITY HOOK FUNCTIONS
//	==========================================================


public void OnEntityCreated(int ent, const char[] classname)
{
	if (!g_bEnabled) return;
	
	if (!IsValidEntity(ent) || ent <= 0) return;
	
	if (strcmp(classname, "spotlight_end") == 0)
	{
		SDKHook(ent, SDKHook_SpawnPost, Hook_FlashlightEndSpawnPost);
	}
	else if (strcmp(classname, "beam") == 0)
	{
		SDKHook(ent, SDKHook_SetTransmit, Hook_FlashlightBeamSetTransmit);
	}
	else if(strncmp(classname, "item_healthkit_", 15) == 0 && !SF_IsBoxingMap())
	{
		SDKHook(ent, SDKHook_Touch, Hook_HealthKitOnTouch);
	}
	else if(strcmp(classname, "func_button") == 0)
	{
		SDKHook(ent, SDKHook_Touch, Hook_GhostNoTouch);
	}
	else if(strncmp(classname, "trigger_", 8) == 0)
	{
		SDKHook(ent, SDKHook_Touch, Hook_GhostNoTouch);
	}
	else if(strcmp(classname, "tf_projectile_pipe") == 0)
	{
		//SDKHook(ent, SDKHook_Spawn, Hook_ProjectileSpawn);
	}
	else if(strcmp(classname, "tf_projectile_jar_milk") == 0 && SF_IsBoxingMap())
	{
		SDKHook(ent, SDKHook_Touch, Hook_MilkTouch);
	}
	else if(strcmp(classname, "tf_projectile_jar") == 0 && SF_IsBoxingMap())
	{
		SDKHook(ent, SDKHook_Touch, Hook_JarateTouch);
	}
	else if(strcmp(classname, "tf_projectile_jar_gas") == 0 && SF_IsBoxingMap())
	{
		//SDKHook(ent, SDKHook_Touch, Hook_GasTouch);
	}
	else if(strcmp(classname, "tf_dropped_weapon") == 0)
	{
		SDKHook(ent, SDKHook_SpawnPost, Hook_DeleteDroppedWeapon);
	}

	PvP_OnEntityCreated(ent, classname);
}

public void Hook_DeleteDroppedWeapon(int ent)
{
	if (!g_bEnabled) return;

	if (IsValidEntity(ent))
	{
		SDKUnhook(ent, SDKHook_SpawnPost, Hook_DeleteDroppedWeapon);
		RemoveEntity(ent);
	}
}

public void Hook_ProjectileSpawn(int ent)
{
	if (!g_bEnabled) return;

	int projent = INVALID_ENT_REFERENCE;
	while ((projent = FindEntityByClassname(projent, "tf_point_weapon_mimic")) != -1)
	{
		if ((ProjectileGetFlags(projent) & PROJ_GRENADE))
		{
			int slender = GetEntPropEnt(projent, Prop_Send, "m_hOwnerEntity");
			if(slender != INVALID_ENT_REFERENCE)
			{
				int iBossIndex = NPCGetFromEntIndex(slender);
				int slenderref = NPCGetEntIndex(iBossIndex);
				SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", slenderref);
			}
		}
	}

	SDKUnhook(ent, SDKHook_Spawn, Hook_ProjectileSpawn);
}

public MRESReturn Hook_WeaponGetCustomDamageType(int weapon, Handle hReturn, Handle hParams)
{
	if (!g_bEnabled) return MRES_Ignored;

	int ownerEntity = GetEntPropEnt(weapon, Prop_Data, "m_hOwnerEntity");
	if (IsValidClient(ownerEntity) && IsClientInPvP(ownerEntity) && IsValidEntity(weapon) && ownerEntity)
	{
		int customDamageType = DHookGetReturn(hReturn);
		if (customDamageType != -1)
		{
			MRESReturn hookResult = PvP_GetWeaponCustomDamageType(weapon, ownerEntity, customDamageType);
			if (hookResult != MRES_Ignored)
			{
				DHookSetReturn(hReturn, customDamageType);
				return hookResult;
			}
		}
		else return MRES_Ignored;
	}
	else
	{
		return MRES_Ignored;
	}

	return MRES_Ignored;
}

public void OnEntityDestroyed(int ent)
{
	// Since OnLevelInit is called before OnConfigsExecuted() we shouldn't check g_bEnabled
	SF2MapEntity_OnEntityDestroyed(ent);

	if (!g_bEnabled) return;

	if (!IsValidEntity(ent) || ent <= 0) return;
	
	int iBossIndex = NPCGetFromEntIndex(ent);
	if (iBossIndex != -1)
	{
		RemoveSlender(iBossIndex);
		return;
	}
	
	char sClassname[64];
	GetEntityClassname(ent, sClassname, sizeof(sClassname));

	if (strcmp(sClassname, "light_dynamic", false) == 0)
	{
		AcceptEntityInput(ent, "TurnOff");
		
		int iEnd = INVALID_ENT_REFERENCE;
		while ((iEnd = FindEntityByClassname(iEnd, "spotlight_end")) != -1)
		{
			if (GetEntPropEnt(iEnd, Prop_Data, "m_hOwnerEntity") == ent)
			{
				RemoveEntity(iEnd);
				break;
			}
		}
	}

	PvP_OnEntityDestroyed(ent, sClassname);
}

public Action Hook_BlockUserMessage(UserMsg msg_id, Handle bf, const int[] players,int playersNum, bool reliable, bool init) 
{
	if (!g_bEnabled) return Plugin_Continue;
	return Plugin_Handled;
}

public Action Hook_TauntUserMessage(UserMsg msg_id, BfRead msg, const int[] players,int playersNum, bool reliable, bool init)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	int iClient = msg.ReadByte();
	if (!g_bPlayerEliminated[iClient]) return Plugin_Handled;//Don't allow a red player to play a taunt sound
	if (g_bPlayerProxy[iClient]) return Plugin_Handled;//Don't allow proxies to play a taunt sound
	
	char sTauntSound[PLATFORM_MAX_PATH];
	msg.ReadString(sTauntSound, PLATFORM_MAX_PATH); 
	
	DataPack dataTaunt = new DataPack();
	dataTaunt.WriteCell(iClient);
	dataTaunt.WriteString(sTauntSound);
	
	RequestFrame(Frame_SendNewTauntMessage, dataTaunt);//Resend taunt sound to eliminated players only
	
	return Plugin_Handled;//Never ever allow a red player/proxy to hear taunt sound, we keep the playing area "tauntmusicless"
}

public void Frame_SendNewTauntMessage(DataPack dataMessage)
{
	int players[MAXPLAYERS+1];
	int playersNum;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient)) continue;
		if (g_bPlayerProxy[iClient]) continue;
		if (!g_bPlayerEliminated[iClient] && !DidClientEscape(iClient)) continue;
		players[playersNum++] = iClient;
	}
	
	dataMessage.Reset();

	BfWrite message = UserMessageToBfWrite(StartMessage("PlayerTauntSoundLoopStart", players, playersNum, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS)); 
	message.WriteByte(dataMessage.ReadCell());
	char sTauntSound[PLATFORM_MAX_PATH];
	dataMessage.ReadString(sTauntSound, sizeof(sTauntSound));
	message.WriteString(sTauntSound); 
	delete message;
	EndMessage();
	delete dataMessage;
}

public Action Hook_BlockUserMessageEx(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	char message[32];
	msg.ReadByte();
	msg.ReadByte();
	msg.ReadString(message, sizeof(message));
	
	if(strcmp(message, "#TF_Name_Change") == 0)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Hook_NormalSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (IsValidClient(entity))
	{
		if (IsClientInGhostMode(entity))
		{
			switch (channel)
			{
				case SNDCHAN_VOICE, SNDCHAN_WEAPON, SNDCHAN_ITEM, SNDCHAN_BODY: return Plugin_Handled;
			}
		}
		else if (g_bPlayerProxy[entity])
		{
			int iMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[entity]);
			if (iMaster != -1)
			{
				char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
				NPCGetProfile(iMaster, sProfile, sizeof(sProfile));

				switch (channel)
				{
					case SNDCHAN_VOICE:
					{
						if (!view_as<bool>(GetProfileNum(sProfile, "proxies_allownormalvoices", 1)))
						{
							return Plugin_Handled;
						}
					}
				}
			}
		}
		else if (!g_bPlayerEliminated[entity] && !g_bPlayerEscaped[entity])
		{
			switch (channel)
			{
				case SNDCHAN_VOICE:
				{
					if (IsRoundInIntro()) return Plugin_Handled;
				
					for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
					{
						if (NPCGetUniqueID(iBossIndex) == -1) continue;
						
						if (SlenderCanHearPlayer(iBossIndex, entity, SoundType_Voice) && NPCShouldHearEntity(iBossIndex, entity))
						{
							GetClientAbsOrigin(entity, g_flSlenderTargetSoundTempPos[iBossIndex]);
							g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDSUSPICIOUSSOUND;
							g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDVOICE;
							if (g_iSlenderState[iBossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(iBossIndex) && g_flSlenderAutoChaseCooldown[iBossIndex] < GetGameTime())
							{
								g_iSlenderAutoChaseCount[iBossIndex] += NPCChaserAutoChaseAddVoice(iBossIndex);
								g_iSlenderSoundTarget[iBossIndex] = EntIndexToEntRef(entity);
								g_flSlenderAutoChaseCooldown[iBossIndex] = GetGameTime() + 0.3;
							}
						}
					}
				}
				case SNDCHAN_BODY:
				{
					if (!StrContains(sample, "player/footsteps", false) || StrContains(sample, "step", false) != -1)
					{
						if (GetConVarBool(g_cvPlayerViewbobSprintEnabled) && IsClientReallySprinting(entity))
						{
							// Viewpunch.
							float flPunchVelStep[3];
							
							float flVelocity[3];
							GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", flVelocity);
							float flSpeed = GetVectorLength(flVelocity, true);
							
							flPunchVelStep[0] = (flSpeed / SquareFloat(300.0));
							flPunchVelStep[1] = 0.0;
							flPunchVelStep[2] = 0.0;
							
							ClientViewPunch(entity, flPunchVelStep);
						}
						
						for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
						{
							if (NPCGetUniqueID(iBossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(iBossIndex, entity, SoundType_Footstep) && NPCShouldHearEntity(iBossIndex, entity))
							{
								GetClientAbsOrigin(entity, g_flSlenderTargetSoundTempPos[iBossIndex]);
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDFOOTSTEP;
								if (g_iSlenderState[iBossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(iBossIndex) && g_flSlenderAutoChaseCooldown[iBossIndex] < GetGameTime())
								{
									g_iSlenderAutoChaseCount[iBossIndex] += NPCChaserAutoChaseAddFootstep(iBossIndex);
									g_iSlenderSoundTarget[iBossIndex] = EntIndexToEntRef(entity);
									g_flSlenderAutoChaseCooldown[iBossIndex] = GetGameTime() + 0.3;
								}
								
								if (IsClientSprinting(entity) && !(GetEntProp(entity, Prop_Send, "m_bDucking") || GetEntProp(entity, Prop_Send, "m_bDucked")))
								{
									g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDFOOTSTEPLOUD;
								}
							}
						}
					}
				}
				case SNDCHAN_ITEM, SNDCHAN_WEAPON:
				{
					if (StrContains(sample, "swing", false) || StrContains(sample, "impact", false) != -1 || StrContains(sample, "hit", false) != -1 || StrContains(sample, "slice", false) != -1 || StrContains(sample, "reload", false) != -1 || StrContains(sample, "woosh", false) != -1 || StrContains(sample, "eviction", false) != -1 || StrContains(sample, "holy", false) != -1)
					{
						for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
						{
							if (NPCGetUniqueID(iBossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(iBossIndex, entity, SoundType_Weapon) && NPCShouldHearEntity(iBossIndex, entity))
							{
								GetClientAbsOrigin(entity, g_flSlenderTargetSoundTempPos[iBossIndex]);
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDWEAPON;
								if (g_iSlenderState[iBossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(iBossIndex) && g_flSlenderAutoChaseCooldown[iBossIndex] < GetGameTime())
								{
									g_iSlenderAutoChaseCount[iBossIndex] += NPCChaserAutoChaseAddWeapon(iBossIndex);
									g_iSlenderSoundTarget[iBossIndex] = EntIndexToEntRef(entity);
									g_flSlenderAutoChaseCooldown[iBossIndex] = GetGameTime() + 0.3;
								}
							}
						}
					}
				}
				case SNDCHAN_STATIC:
				{
					if (StrContains(sample, FLASHLIGHT_CLICKSOUND, false) != -1)
					{
						for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
						{
							if (NPCGetUniqueID(iBossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(iBossIndex, entity, SoundType_Flashlight) && NPCShouldHearEntity(iBossIndex, entity))
							{
								GetClientAbsOrigin(entity, g_flSlenderTargetSoundTempPos[iBossIndex]);
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_iSlenderInterruptConditions[iBossIndex] |= COND_HEARDFLASHLIGHT;
								if (g_iSlenderState[iBossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(iBossIndex) && g_flSlenderAutoChaseCooldown[iBossIndex] < GetGameTime())
								{
									g_iSlenderAutoChaseCount[iBossIndex] += NPCChaserAutoChaseAddWeapon(iBossIndex);
									g_iSlenderSoundTarget[iBossIndex] = EntIndexToEntRef(entity);
									g_flSlenderAutoChaseCooldown[iBossIndex] = GetGameTime() + 0.3;
								}
							}
						}
					}
				}
			}
		}
	}
	
	if (IsValidEntity(entity))
	{
		char classname[64];
		if (GetEntityClassname(entity, classname, sizeof(classname)) && strcmp(classname, "tf_projectile_rocket") == 0 && ((ProjectileGetFlags(entity) & PROJ_ICEBALL) || (ProjectileGetFlags(entity) & PROJ_FIREBALL)))
		{
			if (strcmp(sample, EXPLOSIVEDANCE_EXPLOSION1, false) == 0 || strcmp(sample, EXPLOSIVEDANCE_EXPLOSION2, false) == 0 || strcmp(sample, EXPLOSIVEDANCE_EXPLOSION3, false) == 0) return Plugin_Handled;
		}
	}
	
	bool bModified = false;
	
	/*for (int i = 0; i < numClients; i++)
	{
		int iClient = clients[i];
		if (IsValidClient(iClient) && IsPlayerAlive(iClient) && !IsClientInGhostMode(iClient))
		{
			bool bCanHearSound = true;
			
			if (IsValidClient(entity) && entity != iClient)
			{
				if (!g_bPlayerEliminated[iClient])
				{
					if (g_bSpecialRound && SF_SpecialRound(SPECIALROUND_SINGLEPLAYER))
					{
						if (!g_bPlayerEliminated[entity] && !DidClientEscape(entity))
						{
							bCanHearSound = false;
						}
					}
				}
			}
			
			if (!bCanHearSound)
			{
				bModified = true;
				clients[i] = -1;
			}
		}
	}*/
	
	if (bModified) return Plugin_Changed;
	return Plugin_Continue;
}

public MRESReturn Hook_EntityShouldTransmit(int entity, Handle hReturn, Handle hParams)
{
	if (!g_bEnabled) return MRES_Ignored;
	
	if (IsValidClient(entity))
	{
		if (DoesClientHaveConstantGlow(entity))
		{
			DHookSetReturn(hReturn, FL_EDICT_ALWAYS); // Should always transmit, but our SetTransmit hook gets the final say.
			return MRES_Supercede;
		}
		else if(IsClientInGhostMode(entity))
		{
			DHookSetReturn(hReturn, FL_EDICT_DONTSEND);
			return MRES_Supercede;
		}
	}
	else
	{
		DHookSetReturn(hReturn, FL_EDICT_ALWAYS); // Should always transmit, but our SetTransmit hook gets the final say.
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}

void SF_CollectTriggersMultiple()
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "trigger_*")) != -1)
	{
		SDKHook(ent, SDKHook_StartTouch, Hook_TriggerOnStartTouchEx);
		SDKHook(ent, SDKHook_Touch, Hook_TriggerOnTouchEx);
		SDKHook(ent, SDKHook_EndTouch, Hook_TriggerOnEndTouchEx);
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "func*")) != -1)
	{
		SDKHook(ent, SDKHook_StartTouch, Hook_FuncOnStartTouchEx);
		SDKHook(ent, SDKHook_Touch, Hook_FuncOnTouchEx);
		SDKHook(ent, SDKHook_EndTouch, Hook_FuncOnEndTouchEx);
	}
}
public Action Hook_TriggerOnStartTouchEx(int iTrigger, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	Hook_TriggerOnStartTouch("OnStartTouch", iTrigger, iOther, 0.0);
	return Plugin_Continue;
}

public Action Hook_TriggerOnTouchEx(int iTrigger, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public Action Hook_TriggerOnEndTouchEx(int iTrigger, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	Hook_TriggerOnEndTouch("OnEndTouch", iTrigger, iOther, 0.0);
	return Plugin_Continue;
}

public Action Hook_FuncOnStartTouchEx(int iFunc, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public Action Hook_FuncOnTouchEx(int iFunc, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public Action Hook_FuncOnEndTouchEx(int iFunc, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public void Hook_TriggerOnStartTouch(const char[] output,int caller,int activator, float delay)
{
	if (!g_bEnabled) return;

	if (!IsValidEntity(caller)) return;
	
	char sName[64];
	GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) LogSF2Message("[SF2 TRIGGERS LOG] Trigger %i (trigger_multiple) %s start touch by %i (%s)!", caller, sName, activator, IsValidClient(activator) ? "Player" : "Entity");
#endif	
	if (StrContains(sName, "sf2_escape_trigger", false) == 0)
	{
		if (IsRoundInEscapeObjective())
		{
			if (IsValidClient(activator) && IsPlayerAlive(activator) && !IsClientInDeathCam(activator) && !g_bPlayerEliminated[activator] && !DidClientEscape(activator))
			{
				ClientEscape(activator);
				TeleportClientToEscapePoint(activator);
			}
		}
	}
	
	PvP_OnTriggerStartTouch(caller, activator);
}

public void Hook_TriggerOnEndTouch(const char[] sOutput,int caller,int activator, float flDelay)
{
	if (!g_bEnabled) return;
	
	if (!IsValidEntity(caller)) return;
	
	char sName[64];
	GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));
#if defined DEBUG	
	if (GetConVarInt(g_cvDebugDetail) > 0) LogSF2Message("[SF2 TRIGGERS LOG] Trigger %i (trigger_multiple) %s end touch by %i (%s)!", caller, sName, activator, IsValidClient(activator) ? "Player" : "Entity");
#endif
}

public void Hook_TriggerTeleportOnStartTouch(const char[] output,int caller,int activator, float delay)
{
	if (!g_bEnabled) return;

	if (!IsValidEntity(caller)) return;
	
	int flags = GetEntProp(caller, Prop_Data, "m_spawnflags");
	if (((flags & TRIGGER_CLIENTS) && (flags & TRIGGER_NPCS)) || (flags & TRIGGER_EVERYTHING_BUT_PHYSICS_DEBRIS))
	{
		if (IsValidClient(activator))
		{
			bool bChase = ClientHasMusicFlag(activator, MUSICF_CHASE);
			if (bChase)
			{
				// The player took a teleporter and is chased, and the boss can take it too, add the teleporter to the temp boss' goals.
				for (int i = 0; i < MAX_BOSSES; i++)
				{
					if (NPCGetUniqueID(i) == -1) continue;
					if (EntRefToEntIndex(g_iSlenderTarget[i]) == activator)
					{
						for (int ii = 0;ii < MAX_NPCTELEPORTER;ii++)
						{
							if (NPCChaserGetTeleporter(i,ii) == INVALID_ENT_REFERENCE)
							{
								NPCChaserSetTeleporter(i,ii,EntIndexToEntRef(caller));
								break;
							}
						}
					}
				}
			}
			return;
		}
		SF2NPC_Chaser NpcChaser = view_as<SF2NPC_Chaser>(NPCGetFromEntIndex(activator));
		if (NpcChaser.IsValid())
		{
			//A boss took a teleporter
			int iTeleporter = NpcChaser.GetTeleporter(0);
			if (iTeleporter == EntIndexToEntRef(caller)) //Remove our temp goal, and go back chase our target! GRAAAAAAAAAAAAh! Unless we have some other teleporters to take....fak.
				NpcChaser.SetTeleporter(0,INVALID_ENT_REFERENCE);
			if (MAX_NPCTELEPORTER>2 && NpcChaser.GetTeleporter(1) != INVALID_ENT_REFERENCE)
			{
				for (int i = 0;i+1 < MAX_NPCTELEPORTER;i++)
				{
					if (NpcChaser.GetTeleporter(i+1) != INVALID_ENT_REFERENCE)
						NpcChaser.SetTeleporter(i,NpcChaser.GetTeleporter(i+1));
					else
						NpcChaser.SetTeleporter(i,INVALID_ENT_REFERENCE);
				}
			}
		}
	}
	if (IsValidClient(activator))
	{
		bool bChase = ClientHasMusicFlag(activator, MUSICF_CHASE);
		if (bChase)
		{
			// The player took a teleporter and is chased, but the boss can't follow.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (NPCGetUniqueID(i) == -1) continue;
				if (EntRefToEntIndex(g_iSlenderTarget[i]) == activator)
				{
					g_bSlenderGiveUp[i] = true;
				}
			}
		}
	}
}
public Action Hook_PageOnTakeDamage(int page,int &attacker,int &inflictor,float &damage,int &damagetype,int &weapon, float damageForce[3], float damagePosition[3],int damagecustom)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (IsValidClient(attacker))
	{
		if (!g_bPlayerEliminated[attacker])
		{
			if (damagetype & 0x80) // 0x80 == melee damage
			{
				CollectPage(page, attacker);
			}
		}
	}
	
	return Plugin_Continue;
}

static void CollectPage(int page,int activator)
{
	if (SF_SpecialRound(SPECIALROUND_ESCAPETICKETS))
	{
		ClientEscape(activator);
		TeleportClientToEscapePoint(activator);
	}
	
	if (SF_SpecialRound(SPECIALROUND_PAGEREWARDS) && !g_bPlayerGettingPageReward[activator])
	{
		g_hPlayerPageRewardTimer[activator] = CreateTimer(3.0, Timer_GiveRandomPageReward, EntIndexToEntRef(activator));
		g_bPlayerGettingPageReward[activator] = true;
		EmitRollSound(activator);
	}

	SetPageCount(g_iPageCount + 1);
	g_iPlayerPageCount[activator] += 1;

	// Play page collect sound
	char sPageCollectSound[PLATFORM_MAX_PATH]; int iPageCollectionSoundPitch = g_iPageSoundPitch;
	if (SF_SpecialRound(SPECIALROUND_DUCKS))
	{
		// Ducks!
		int iRandomSound = GetRandomInt(0, sizeof(g_sPageCollectDuckSounds));
		strcopy(sPageCollectSound, sizeof(sPageCollectSound), g_sPageCollectDuckSounds[iRandomSound]);
	}
	else
	{
		strcopy(sPageCollectSound, sizeof(sPageCollectSound), g_strPageCollectSound);

		if (IsValidEntity(page))
		{
			int iPageIndex = g_hPages.FindValue(EnsureEntRef(page));
			if (iPageIndex != -1)
			{
				SF2PageEntityData pageData;
				g_hPages.GetArray(iPageIndex, pageData, sizeof(pageData));

				if (pageData.CollectSound[0] != '\0')
					strcopy(sPageCollectSound, sizeof(sPageCollectSound), pageData.CollectSound);

				if (pageData.CollectSoundPitch > 0)
					iPageCollectionSoundPitch = pageData.CollectSoundPitch;
			}
		}
	}

	EmitSoundToAll(sPageCollectSound, activator, SNDCHAN_ITEM, SNDLEVEL_SCREAMING, _, _, iPageCollectionSoundPitch);

	Call_StartForward(fOnClientCollectPage);
	Call_PushCell(page);
	Call_PushCell(activator);
	Call_Finish();

	// Gives points. Credit to the makers of VSH/FF2.
	Handle hEvent = CreateEvent("player_escort_score", true);
	SetEventInt(hEvent, "player", activator);
	SetEventInt(hEvent, "points", 1);
	FireEvent(hEvent);

	int iPage2 = GetEntPropEnt(page, Prop_Send, "m_hOwnerEntity");
	if (iPage2 > MaxClients)
		RemoveEntity(iPage2);
	else
	{
		iPage2 = GetEntPropEnt(page, Prop_Send, "m_hEffectEntity");
		if (iPage2 > MaxClients)
			RemoveEntity(iPage2);
	}
	
	AcceptEntityInput(page, "FireUser1");
	AcceptEntityInput(page, "KillHierarchy");
}

static void EmitRollSound(int client)
{
	EmitSoundToClient(client, GENERIC_ROLL_TICK_1, client);
	CreateTimer(0.12, Timer_RollTick_Case2, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RollTick_Case1(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case2, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case2(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case3, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case3(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case4, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case4(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case5, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case5(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case6, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case6(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case7, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case7(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case8, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case8(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case9, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case9(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case10, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case10(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.3, Timer_RollTick_Case11, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case11(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.3, Timer_RollTick_Case12, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case12(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.3, Timer_RollTick_Case13, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case13(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.5, Timer_RollTick_Case14, EntIndexToEntRef(player));
}

public Action Timer_RollTick_Case14(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
}

public Action Timer_GiveRandomPageReward(Handle timer, any entref)
{
	if (!g_bEnabled) return;

	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return;

	if (timer != g_hPlayerPageRewardTimer[player]) return;
	
	g_bPlayerGettingPageReward[player] = false;

	int iEffect = GetRandomInt(0, 11);
	switch (iEffect)
	{
		case 1:
		{
			TF2_IgnitePlayer(player, player);
		}
		case 2:
		{
			TF2_RegeneratePlayer(player);
		}
		case 3:
		{
			TF2_StunPlayer(player, 5.0, _, TF_STUNFLAG_BONKSTUCK);
		}
		case 4:
		{
			TF2_AddCondition(player, TFCond_CritOnFirstBlood, 8.0);
			EmitSoundToClient(player, CRIT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 5:
		{
			TF2_MakeBleed(player, player, 8.0);
			EmitSoundToClient(player, BLEED_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 6:
		{
			int iRareEffect = GetRandomInt(0, 30);
			switch (iRareEffect)
			{
				case 1, 2, 3, 4, 5:
				{
					int iDeathEffect = GetRandomInt(1, 3);
					switch (iDeathEffect)
					{
						case 1:
						{
							EmitSoundToAll(EXPLODE_PLAYER, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
							SDKHooks_TakeDamage(player, player, player, 9001.0, 262272, _, view_as<float>({ 0.0, 0.0, 0.0 }));
							return;
						}
						case 2:
						{
							EmitSoundToAll(FIREWORK_START, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
							float fPush[3], flPlayerPos[3];
							GetClientAbsOrigin(player, flPlayerPos);
							flPlayerPos[2] += 10.0;
							fPush[2] = 4096.0;
							TeleportEntity(player, flPlayerPos, NULL_VECTOR, fPush);

							int iParticle = AttachParticle(player, FIREWORK_PARTICLE);
							CreateTimer(0.5, Timer_DestroyEntity, iParticle, TIMER_FLAG_NO_MAPCHANGE);

							CreateTimer(0.5, Timer_Firework_Explode, GetClientUserId(player), TIMER_FLAG_NO_MAPCHANGE);
						}
						case 3:
						{
							// define where the lightning strike ends
							float clientpos[3];
							GetClientAbsOrigin(player, clientpos);
							clientpos[2] -= 26; // increase y-axis by 26 to strike at player's chest instead of the ground
							
							// get random numbers for the x and y starting positions
							int randomx = GetRandomInt(-500, 500);
							int randomy = GetRandomInt(-500, 500);
							
							// define where the lightning strike starts
							float startpos[3];
							startpos[0] = clientpos[0] + randomx;
							startpos[1] = clientpos[1] + randomy;
							startpos[2] = clientpos[2] + 800;
							
							// define the color of the strike
							int color[4];
							color[0] = 255;
							color[1] = 255;
							color[2] = 255;
							color[3] = 255;
							
							// define the direction of the sparks
							float dir[3];
							
							TE_SetupBeamPoints(startpos, clientpos, g_LightningSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
							TE_SendToAll();
							
							TE_SetupSparks(clientpos, dir, 5000, 1000);
							TE_SendToAll();
							
							TE_SetupEnergySplash(clientpos, dir, false);
							TE_SendToAll();
							
							TE_SetupSmoke(clientpos, g_SmokeSprite, 5.0, 10);
							TE_SendToAll();
							
							CreateTimer(0.01, Timer_AshRagdoll, GetClientUserId(player), TIMER_FLAG_NO_MAPCHANGE);
							
							SDKHooks_TakeDamage(player, player, player, 9001.0, 1048576, _, view_as<float>({ 0.0, 0.0, 0.0 }));
							
							EmitAmbientSound(SOUND_THUNDER, startpos, player, SNDLEVEL_RAIDSIREN);
						}
					}
				}
				case 6:
				{
					TF2_IgnitePlayer(player, player);
				}
				case 7:
				{
					TF2_RegeneratePlayer(player);
				}
				case 8:
				{
					TF2_StunPlayer(player, 5.0, _, TF_STUNFLAG_BONKSTUCK);
				}
				case 9:
				{
					TF2_AddCondition(player, TFCond_CritOnFirstBlood, 8.0);
					EmitSoundToClient(player, CRIT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 14:
				{
					TF2_MakeBleed(player, player, 10.0);
					EmitSoundToClient(player, BLEED_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 10, 11, 12, 13:
				{
					TF2_AddCondition(player, TFCond_UberchargedCanteen, 5.0);
					EmitSoundToClient(player, UBER_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 15, 16:
				{
					EmitSoundToClient(player, LOSE_SPRINT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
					g_iPlayerSprintPoints[player] = 0;
				}
				case 17:
				{
					TF2_AddCondition(player, TFCond_Jarated, 10.0);
					EmitSoundToClient(player, JARATE_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 18:
				{
					TF2_AddCondition(player, TFCond_Gas, 10.0);
					EmitSoundToClient(player, GAS_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 19:
				{
					TF2_AddCondition(player, TFCond_SpeedBuffAlly, 5.0);
				}
				case 20:
				{
					TF2_AddCondition(player, TFCond_CritCola, 16.0);
					EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 21:
				{
					TF2_AddCondition(player, TFCond_DefenseBuffed, 10.0);
					EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 22:
				{
					TF2_AddCondition(player, TFCond_HalloweenQuickHeal, 3.0);
					TF2_AddCondition(player, TFCond_UberchargedCanteen, 1.0);
					EmitSoundToClient(player, UBER_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				default:
				{
					EmitSoundToClient(player, NO_EFFECT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
			}
		}
		case 7:
		{
			TF2_AddCondition(player, TFCond_Jarated, 10.0);
			EmitSoundToClient(player, JARATE_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 8:
		{
			TF2_AddCondition(player, TFCond_Gas, 10.0);
			EmitSoundToClient(player, GAS_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 9:
		{
			TF2_AddCondition(player, TFCond_SpeedBuffAlly, 5.0);
		}
		case 10:
		{
			TF2_AddCondition(player, TFCond_CritCola, 16.0);
			EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 11:
		{
			TF2_AddCondition(player, TFCond_DefenseBuffed, 10.0);
			EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 12:
		{
			TF2_AddCondition(player, TFCond_HalloweenQuickHeal, 3.0);
			TF2_AddCondition(player, TFCond_UberchargedCanteen, 1.0);
			EmitSoundToClient(player, UBER_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		default:
		{
			EmitSoundToClient(player, NO_EFFECT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
	}
	g_hPlayerPageRewardTimer[player] = INVALID_HANDLE;
	g_hPlayerPageRewardCycleTimer[player] = INVALID_HANDLE;
}

public Action Timer_Firework_Explode(Handle hTimer, int iUserId){
	int client = GetClientOfUserId(iUserId);
	if(!client) return Plugin_Stop;

	EmitSoundToAll(FIREWORK_EXPLOSION, client);
	SDKHooks_TakeDamage(client, client, client, 9001.0, 1327104, _, view_as<float>({ 0.0, 0.0, 0.0 }));
	return Plugin_Stop;
}

//	==========================================================
//	GENERIC iClient HOOKS AND FUNCTIONS
//	==========================================================


public Action OnPlayerRunCmd(int iClient,int &buttons,int &impulse, float vel[3], float angles[3],int &weapon,int &subtype,int &cmdnum,int &tickcount,int &seed,int mouse[2])
{
	if (!g_bEnabled) return Plugin_Continue;

	bool bChanged = false;
	
	// Check impulse (block spraying and built-in flashlight)
	switch (impulse)
	{
		case 100:
		{
			impulse = 0;
		}
		case 201, 202:
		{
			if (IsClientInGhostMode(iClient))
			{
				impulse = 0;
			}
		}
	}
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		
		if ((buttons & button))
		{
			if (!(g_iPlayerLastButtons[iClient] & button))
			{
				ClientOnButtonPress(iClient, button);
				if (button==IN_ATTACK2)
				{
					if (IsClientInPvP(iClient) && !(buttons & IN_ATTACK))
					{
						if (TF2_GetPlayerClass(iClient) == TFClass_Medic)
						{
							int iWeapon = GetPlayerWeaponSlot(iClient, 0);
							if (iWeapon > MaxClients)
							{
								char sWeaponClass[64];
								GetEdictClassname(iWeapon, sWeaponClass, sizeof(sWeaponClass));
								if (strcmp(sWeaponClass,"tf_weapon_crossbow") == 0)
								{
									int iClip = GetEntProp(iWeapon, Prop_Send, "m_iClip1");
									if (iClip > 0)
									{
										buttons |= IN_ATTACK;
										g_iPlayerLastButtons[iClient] = buttons;
										buttons &= ~IN_ATTACK2;
										bChanged = true;
										
										RequestFrame(Frame_ClientHealArrow, iClient);
										
										EmitSoundToAll(")weapons/crusaders_crossbow_shoot.wav", iClient, SNDCHAN_WEAPON, SNDLEVEL_MINIBIKE);//Fix client's predictions.
									}
								}
							}
						}
					}
				}
			}
			if (button == IN_ATTACK2)
			{
				if(!g_bPlayerEliminated[iClient])
				{
					g_iPlayerLastButtons[iClient] = buttons;
					int iWeaponActive = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
					if(iWeaponActive > MaxClients && IsTauntWep(iWeaponActive))
					{
						buttons &= ~IN_ATTACK2;	//Tough break update made players able to taunt with secondary attack. Block this feature.
						bChanged = true;
					}
				}
			}
			/*if (!g_bPlayerEliminated[iClient] && button == IN_JUMP && g_iPlayerSprintPoints[iClient] < 7)
			{
				g_iPlayerLastButtons[iClient] = buttons;
				buttons &= ~IN_JUMP;
				bChanged = true;
			}*/
		}
		else if ((g_iPlayerLastButtons[iClient] & button))
		{
			ClientOnButtonRelease(iClient, button);
		}
	}
	if (!bChanged) g_iPlayerLastButtons[iClient] = buttons;
	return (bChanged) ? Plugin_Changed : Plugin_Continue;
}

public void OnClientCookiesCached(int iClient)
{
	if (!g_bEnabled) return;
	
	// Load our saved settings.
	char sCookie[64];
	GetClientCookie(iClient, g_hCookie, sCookie, sizeof(sCookie));
	
	g_iPlayerQueuePoints[iClient] = 0;
	
	g_iPlayerPreferences[iClient].PlayerPreference_PvPAutoSpawn = false;
	g_iPlayerPreferences[iClient].PlayerPreference_ShowHints = true;
	g_iPlayerPreferences[iClient].PlayerPreference_MuteMode = 0;
	g_iPlayerPreferences[iClient].PlayerPreference_FilmGrain = false;
	g_iPlayerPreferences[iClient].PlayerPreference_EnableProxySelection = true;
	g_iPlayerPreferences[iClient].PlayerPreference_FlashlightTemperature = 6;
	
	if (sCookie[0])
	{
		char s2[12][32];
		int count = ExplodeString(sCookie, " ; ", s2, 12, 32);
		
		if (count > 0)
			g_iPlayerQueuePoints[iClient] = StringToInt(s2[0]);
		if (count > 1)
			g_iPlayerPreferences[iClient].PlayerPreference_PvPAutoSpawn = view_as<bool>(StringToInt(s2[1]));
		if (count > 2)
			g_iPlayerPreferences[iClient].PlayerPreference_ShowHints = view_as<bool>(StringToInt(s2[2]));
		if (count > 3)
			g_iPlayerPreferences[iClient].PlayerPreference_MuteMode = view_as<int>(StringToInt(s2[3]));
		if (count > 4)
			g_iPlayerPreferences[iClient].PlayerPreference_FilmGrain = view_as<bool>(StringToInt(s2[4]));
		if (count > 5)
			g_iPlayerPreferences[iClient].PlayerPreference_EnableProxySelection = view_as<bool>(StringToInt(s2[5]));
		if (count > 6)
			g_iPlayerPreferences[iClient].PlayerPreference_FlashlightTemperature = view_as<int>(StringToInt(s2[6]));
	}
}

public void OnClientPutInServer(int iClient)
{
	if (!g_bEnabled) return;
	
	if (IsClientSourceTV(iClient)) g_iSourceTVUserID = GetClientUserId(iClient);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START OnClientPutInServer(%d)", iClient);
#endif
	
	ClientSetPlayerGroup(iClient, -1);
	
	g_flLastCommandTime[iClient] = GetEngineTime();
	
	g_bPlayerEscaped[iClient] = false;
	g_bPlayerEliminated[iClient] = true;
	g_bPlayerChoseTeam[iClient] = false;
	g_bPlayerPlayedSpecialRound[iClient] = true;
	g_bPlayerPlayedNewBossRound[iClient] = true;
	
	g_iPlayerPreferences[iClient].PlayerPreference_PvPAutoSpawn = false;
	g_iPlayerPreferences[iClient].PlayerPreference_ProjectedFlashlight = false;
	
	g_iPlayerPageCount[iClient] = 0;
	g_iPlayerDesiredFOV[iClient] = 90;
	
	SDKHook(iClient, SDKHook_PreThink, Hook_ClientPreThink);
	SDKHook(iClient, SDKHook_SetTransmit, Hook_ClientSetTransmit);
	SDKHook(iClient, SDKHook_TraceAttack, Hook_PvPPlayerTraceAttack);
	SDKHook(iClient, SDKHook_OnTakeDamage, Hook_ClientOnTakeDamage);
	
	SDKHook(iClient, SDKHook_WeaponEquipPost, Hook_ClientWeaponEquipPost);
	
	DHookEntity(g_hSDKWantsLagCompensationOnEntity, true, iClient); 

	DHookEntity(g_hSDKShouldTransmit, true, iClient);
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		
		SetPlayerGroupInvitedPlayer(i, iClient, false);
		SetPlayerGroupInvitedPlayerCount(i, iClient, 0);
		SetPlayerGroupInvitedPlayerTime(i, iClient, 0.0);
	}

	ClientResetStatic(iClient);
	ClientResetSlenderStats(iClient);
	ClientResetCampingStats(iClient);
	ClientResetOverlay(iClient);
	ClientResetJumpScare(iClient);
	ClientUpdateListeningFlags(iClient);
	ClientUpdateMusicSystem(iClient);
	ClientChaseMusicReset(iClient);
	ClientChaseMusicSeeReset(iClient);
	ClientAlertMusicReset(iClient);
	Client20DollarsMusicReset(iClient);
	Client90sMusicReset(iClient);
	ClientMusicReset(iClient);
	ClientResetProxy(iClient);
	ClientResetHints(iClient);
	ClientResetScare(iClient);
	
	ClientResetDeathCam(iClient);
	ClientResetFlashlight(iClient);
	ClientDeactivateUltravision(iClient);
	ClientResetSprint(iClient);
	ClientResetBreathing(iClient);
	ClientResetBlink(iClient);
	ClientResetInteractiveGlow(iClient);
	ClientDisableConstantGlow(iClient);
	
	ClientSetScareBoostEndTime(iClient, -1.0);
	
	ClientStartProxyAvailableTimer(iClient);
	
	if (!IsFakeClient(iClient))
	{
		// See if the player is using the projected flashlight.
		QueryClientConVar(iClient, "mat_supportflashlight", OnClientGetProjectedFlashlightSetting);
		
		// Get desired FOV.
		QueryClientConVar(iClient, "fov_desired", OnClientGetDesiredFOV);
	}
	
	PvP_OnClientPutInServer(iClient);
	
#if defined DEBUG
	g_iPlayerDebugFlags[iClient] = 0;

	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END OnClientPutInServer(%d)", iClient);
#endif
}

public void OnClientGetProjectedFlashlightSetting(QueryCookie cookie,int iClient, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (result != ConVarQuery_Okay) 
	{
		LogError("Warning: Player %N failed to query for ConVar mat_supportflashlight", iClient);
		return;
	}
	
	if (StringToInt(cvarValue))
	{
		char sAuth[64];
		GetClientAuthId(iClient,AuthId_Engine, sAuth, sizeof(sAuth));
		
		g_iPlayerPreferences[iClient].PlayerPreference_ProjectedFlashlight = true;
		LogSF2Message("Player %N (%s) has mat_supportflashlight enabled, projected flashlight will be used", iClient, sAuth);
	}
}

public void OnClientGetDesiredFOV(QueryCookie cookie,int iClient, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (!IsValidClient(iClient)) return;
	
	g_iPlayerDesiredFOV[iClient] = StringToInt(cvarValue);
}

public void OnClientDisconnect(int iClient)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START OnClientDisconnect(%d)", iClient);
#endif

	Handle message = StartMessageAll("PlayerTauntSoundLoopEnd", USERMSG_RELIABLE);
	BfWriteByte(message, iClient);
	delete message;
	EndMessage();

	g_bSeeUpdateMenu[iClient] = false;
	g_bPlayerEscaped[iClient] = false;
	g_bAdminNoPoints[iClient] = false;
	g_bPlayerIn1UpCondition[iClient] = false;
	g_bPlayerDied1Up[iClient] = false;
	
	// Save and reset settings for the next iClient.
	ClientSaveCookies(iClient);
	ClientSetPlayerGroup(iClient, -1);
	
	// Reset variables.
	g_iPlayerPreferences[iClient].PlayerPreference_ShowHints = true;
	g_iPlayerPreferences[iClient].PlayerPreference_MuteMode = 0;
	g_iPlayerPreferences[iClient].PlayerPreference_FilmGrain = false;
	g_iPlayerPreferences[iClient].PlayerPreference_EnableProxySelection = true;
	g_iPlayerPreferences[iClient].PlayerPreference_ProjectedFlashlight = false;
	g_iPlayerPreferences[iClient].PlayerPreference_FlashlightTemperature = 6;

	// Reset any iClient functions that may be still active.
	ClientResetOverlay(iClient);
	ClientResetFlashlight(iClient);
	ClientDeactivateUltravision(iClient);
	ClientSetGhostModeState(iClient, false);
	ClientResetInteractiveGlow(iClient);
	ClientDisableConstantGlow(iClient);
	
	ClientStopProxyForce(iClient);
	
	Network_ResetClient(iClient);
	
	if (SF_IsBoxingMap() && IsRoundInEscapeObjective())
	{
		CreateTimer(0.2, Timer_CheckAlivePlayers, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	if (!IsRoundInWarmup())
	{
		if (g_bPlayerPlaying[iClient] && !g_bPlayerEliminated[iClient])
		{
			if (g_bRoundGrace)
			{
				// Force the next player in queue to take my place, if any.
				ForceInNextPlayersInQueue(1, true);
			}
			else
			{
				if (!IsRoundEnding()) 
				{
					CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
	
	g_bPlayerEliminated[iClient] = true;
	// Reset queue points global variable.
	g_iPlayerQueuePoints[iClient] = 0;
	
	PvP_OnClientDisconnect(iClient);

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END OnClientDisconnect(%d)", iClient);
#endif
}

public void OnClientDisconnect_Post(int iClient)
{
    g_iPlayerLastButtons[iClient] = 0;
}

public void TF2_OnWaitingForPlayersStart()
{
	g_bRoundWaitingForPlayers = true;
}

public void TF2_OnWaitingForPlayersEnd()
{
	g_bRoundWaitingForPlayers = false;
}

SF2RoundState GetRoundState()
{
	return g_iRoundState;
}

void SetRoundTime(int iTime)
{
	int iOldRoundTime = g_iRoundTime;
	if (iTime == iOldRoundTime)
		return;

	g_iRoundTime = iTime;

	switch (GetRoundState())
	{
		case SF2RoundState_Escape:
		{
			if (SF_IsSurvivalMap() && iTime <= g_iTimeEscape && iOldRoundTime > g_iTimeEscape && g_GamerulesEntity.IsValid())
			{
				g_GamerulesEntity.FireOutputNoVariant("OnSurvivalComplete", -1, g_GamerulesEntity.EntRef);
			}
		}
	}
}

void SetGracePeriodState(bool state)
{
	bool bOldGraceState = g_bRoundGrace;
	g_bRoundGrace = state;

	if (!g_bRoundGrace && bOldGraceState) 
	{
		SF2MapEntity_OnGracePeriodEnd();
	}
}

void SetRoundState(SF2RoundState iRoundState)
{
	if (g_iRoundState == iRoundState) return;
	
	PrintToServer("SetRoundState(%d)", iRoundState);
	
	SF2RoundState iOldRoundState = GetRoundState();
	g_iRoundState = iRoundState;
	
	//Tutorial_OnRoundStateChange(iOldRoundState, g_iRoundState);

	// Cleanup from old roundstate if needed.
	switch (iOldRoundState)
	{
		case SF2RoundState_Waiting:
		{
		}
		case SF2RoundState_Intro:
		{
			g_hRoundIntroTimer = INVALID_HANDLE;
			g_iNightvisionType = GetRandomInt(0, 2);
		}
		case SF2RoundState_Active:
		{
			SetGracePeriodState(false);
			g_hRoundGraceTimer = INVALID_HANDLE;
			g_hRoundTimer = INVALID_HANDLE;
			g_bPlayersAreCritted = false;
			g_bPlayersAreMiniCritted = false;
			
			bool bNightVision = (GetConVarBool(g_cvNightvisionEnabled) || SF_SpecialRound(SPECIALROUND_NIGHTVISION));
			if (bNightVision)
			{
				switch (g_iNightvisionType)
				{
					case 2:
					{
						g_hBlueNightvisionOutlineTimer = CreateTimer(10.0, Timer_BlueNightvisionOutline, _, TIMER_REPEAT);
					}
					default:
					{
						g_hBlueNightvisionOutlineTimer = INVALID_HANDLE;
					}
				}
			}
		}
		case SF2RoundState_Escape:
		{
			g_hRoundTimer = INVALID_HANDLE;
		}
		case SF2RoundState_Outro:
		{
		}
	}
	
	switch (g_iRoundState)
	{
		case SF2RoundState_Waiting:
		{
		}
		case SF2RoundState_Intro:
		{
			SetGracePeriodState(true);
			g_hRoundIntroTimer = INVALID_HANDLE;
			g_bProxySurvivalRageMode = false;

			StartIntroTextSequence();
			
			// Gather data on the intro parameters set by the map.
			float flHoldTime = g_flRoundIntroFadeHoldTime;
			g_hRoundIntroTimer = CreateTimer(flHoldTime, Timer_ActivateRoundFromIntro);
			
			// Trigger any intro logic entities, if any.
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "logic_relay")) != -1)
			{
				char sName[64];
				GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
				if (strcmp(sName, "sf2_intro_relay", false) == 0)
				{
					AcceptEntityInput(ent, "Trigger");
					break;
				}
			}
		}
		case SF2RoundState_Active:
		{
			// Start the grace period timer.
			SetGracePeriodState(true);
			g_hRoundGraceTimer = CreateTimer(GetConVarFloat(g_cvGraceTime), Timer_RoundGrace);
			
			CreateTimer(2.0, Timer_RoundStart, _, TIMER_FLAG_NO_MAPCHANGE);
			
			// Enable movement on players.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || g_bPlayerEliminated[i]) continue;
				SetEntityFlags(i, GetEntityFlags(i) & ~FL_FROZEN);
				TF2Attrib_SetByDefIndex(i, 10, 7.0);
			}
			
			// Fade in.
			float flFadeTime = g_flRoundIntroFadeDuration;
			int iFadeFlags = SF_FADE_IN | FFADE_PURGE;
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || g_bPlayerEliminated[i]) continue;
				UTIL_ScreenFade(i, FixedUnsigned16(flFadeTime, 1 << 12), 0, iFadeFlags, g_iRoundIntroFadeColor[0], g_iRoundIntroFadeColor[1], g_iRoundIntroFadeColor[2], g_iRoundIntroFadeColor[3]);
			}
		}
		case SF2RoundState_Escape:
		{
			// Initialize the escape timer, if needed.
			if (g_iRoundEscapeTimeLimit > 0)
			{
				SetRoundTime(g_iRoundEscapeTimeLimit);
				g_hRoundTimer = CreateTimer(1.0, Timer_RoundTimeEscape, _, TIMER_REPEAT);
			}
			else
			{
				g_hRoundTimer = INVALID_HANDLE;
			}
		
			char sName[32];
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
			{
				GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
				if (!SF_IsBoxingMap())
				{
					if (strcmp(sName, "sf2_logic_escape", false) == 0)
					{
						AcceptEntityInput(ent, "FireUser1");
						break;
					}
				}
				else
				{
					if (!SF_SpecialRound(SPECIALROUND_HYPERSNATCHER))
					{
						if (strcmp(sName, "sf2_logic_escape", false) == 0)
						{
							AcceptEntityInput(ent, "FireUser1");
							break;
						}
					}
					else
					{
						if (strcmp(sName, "sf2_logic_escape_hyper", false) == 0)
						{
							AcceptEntityInput(ent, "FireUser1");
							break;
						}
					}
				}
			}

			if (SF_IsBoxingMap())
			{
				g_cvDifficulty.IntValue = Difficulty_Normal;
				CPrintToChatAll("%t", "SF2 Boxing Initiate");
				CreateTimer(0.2, Timer_CheckAlivePlayers, _, TIMER_FLAG_NO_MAPCHANGE);

				char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
				for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
				{
					SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(iBoss);
					if (!Npc.IsValid()) continue;
					Npc.GetProfile(sBuffer, sizeof(sBuffer));
					if (view_as<bool>(GetProfileNum(sBuffer,"boxing_boss",0))) g_iSlenderBoxingBossCount += 1;
				}
			}
			else if (SF_IsRenevantMap())
			{
				Renevant_SetWave(1, true);
			}
		}
		case SF2RoundState_Outro:
		{
			if (!g_bRoundHasEscapeObjective)
			{
				// Teleport winning players to the escape point.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i)) continue;
					
					if (!g_bPlayerEliminated[i])
					{
						TeleportClientToEscapePoint(i);
					}
				}
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				if (IsClientInGhostMode(i))
				{
					// Take the player out of ghost mode.
					ClientSetGhostModeState(i, false);	
					TF2_RespawnPlayer(i);
				}
				else if (g_bPlayerProxy[i])
				{
					TF2_RespawnPlayer(i);
				}
				
				if (!g_bPlayerEliminated[i])
				{
					// Give them back all their weapons so they can beat the crap out of the other team.
					TF2_RegeneratePlayer(i);
				}
				
				ClientUpdateListeningFlags(i);
			}
		}
	}

	SF2MapEntity_OnRoundStateChanged(iRoundState, iOldRoundState);

	Call_StartForward(fOnRoundStateChange);
	Call_PushCell(iOldRoundState);
	Call_PushCell(g_iRoundState);
	Call_Finish();
}

bool IsRoundInEscapeObjective()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Escape);
}

bool IsRoundInWarmup()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Waiting);
}

bool IsRoundInIntro()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Intro);
}

bool IsRoundEnding()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Outro);
}

bool IsInfiniteBlinkEnabled()
{
	return view_as<bool>(g_bRoundInfiniteBlink || (GetConVarInt(g_cvPlayerInfiniteBlinkOverride) == 1));
}

bool IsInfiniteSprintEnabled()
{
	return view_as<bool>(g_bRoundInfiniteSprint || (GetConVarInt(g_cvPlayerInfiniteSprintOverride) == 1));
}

#define SF2_PLAYER_HUD_BLINK_SYMBOL "B"
#define SF2_PLAYER_HUD_FLASHLIGHT_SYMBOL "ϟ"
#define SF2_PLAYER_HUD_BAR_SYMBOL "|"
#define SF2_PLAYER_HUD_BAR_MISSING_SYMBOL ""
#define SF2_PLAYER_HUD_INFINITY_SYMBOL "∞"
#define SF2_PLAYER_HUD_SPRINT_SYMBOL "»"

public Action Timer_ClientAverageUpdate(Handle timer)
{
	if (timer != g_hClientAverageUpdateTimer) return Plugin_Stop;
	
	if (!g_bEnabled) return Plugin_Stop;
	
	if (IsRoundInWarmup() || IsRoundEnding()) return Plugin_Continue;
	
	if (SF_SpecialRound(SPECIALROUND_REALISM)) return Plugin_Continue;
	
	// First, process through HUD stuff.
	char buffer[256];
	
	static iHudColorHealthy[3] = { 150, 255, 150 };
	static iHudColorCritical[3] = { 255, 10, 10 };
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		
		if (IsPlayerAlive(i) && !IsClientInDeathCam(i))
		{
			if (!g_bPlayerEliminated[i])
			{
				if (DidClientEscape(i)) continue;
				
				int iMaxBars = 12;
				int iBars;
				if(!SF_IsRaidMap() && !SF_IsBoxingMap())
				{
					iBars = RoundToCeil(float(iMaxBars) * ClientGetBlinkMeter(i));
					if (iBars > iMaxBars) iBars = iMaxBars;
					
					FormatEx(buffer, sizeof(buffer), "%s  ", SF2_PLAYER_HUD_BLINK_SYMBOL);
					
					if (IsInfiniteBlinkEnabled())
					{
						StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_INFINITY_SYMBOL);
					}
					else
					{
						for (int i2 = 0; i2 < iMaxBars; i2++) 
						{
							if (i2 < iBars)
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
							}
							else
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_MISSING_SYMBOL);
							}
						}
					}
				}
				if (!SF_SpecialRound(SPECIALROUND_LIGHTSOUT) && !SF_IsRaidMap() && !SF_IsBoxingMap())
				{
					iBars = RoundToCeil(float(iMaxBars) * ClientGetFlashlightBatteryLife(i));
					if (iBars > iMaxBars) iBars = iMaxBars;
					
					char sBuffer2[64];
					FormatEx(sBuffer2, sizeof(sBuffer2), "\n%s  ", SF2_PLAYER_HUD_FLASHLIGHT_SYMBOL);
					StrCat(buffer, sizeof(buffer), sBuffer2);
					
					if (IsInfiniteFlashlightEnabled())
					{
						StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_INFINITY_SYMBOL);
					}
					else
					{
						for (int i2 = 0; i2 < iMaxBars; i2++) 
						{
							if (i2 < iBars)
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
							}
							else
							{
								StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_MISSING_SYMBOL);
							}
						}
					}
				}
				
				iBars = RoundToCeil(float(iMaxBars) * (float(ClientGetSprintPoints(i)) / 100.0));
				if (iBars > iMaxBars) iBars = iMaxBars;
				
				char sBuffer2[64];
				FormatEx(sBuffer2, sizeof(sBuffer2), "\n%s  ", SF2_PLAYER_HUD_SPRINT_SYMBOL);
				StrCat(buffer, sizeof(buffer), sBuffer2);
				
				if (IsInfiniteSprintEnabled())
				{
					StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_INFINITY_SYMBOL);
				}
				else
				{
					for (int i2 = 0; i2 < iMaxBars; i2++) 
					{
						if (i2 < iBars)
						{
							StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
						}
						else
						{
							StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_MISSING_SYMBOL);
						}
					}
				}
				
				
				float flHealthRatio = float(GetEntProp(i, Prop_Send, "m_iHealth")) / float(SDKCall(g_hSDKGetMaxHealth, i));
				
				int iColor[3];
				for (int i2 = 0; i2 < 3; i2++)
				{
					iColor[i2] = RoundFloat(float(iHudColorHealthy[i2]) + (float(iHudColorCritical[i2] - iHudColorHealthy[i2]) * (1.0 - flHealthRatio)));
				}
				if(!SF_IsRaidMap() && !SF_IsBoxingMap())
				{
					SetHudTextParams(0.035, 0.83,
						0.3,
						iColor[0],
						iColor[1],
						iColor[2],
						40,
						_,
						1.0,
						0.07,
						0.5);
				}
				else if(SF_IsRaidMap() || SF_IsBoxingMap())
				{
					SetHudTextParams(0.035, 0.43,
						0.3,
						iColor[0],
						iColor[1],
						iColor[2],
						40,
						_,
						1.0,
						0.07,
						0.5);
				}
				ShowSyncHudText(i, g_hHudSync2, buffer);
				buffer[0] = '\0';
			}
			else
			{
				if (g_bPlayerProxy[i])
				{
					int iMaxBars = 12;
					int iBars = RoundToCeil(float(iMaxBars) * (float(g_iPlayerProxyControl[i]) / 100.0));
					if (iBars > iMaxBars) iBars = iMaxBars;
					
					strcopy(buffer, sizeof(buffer), "CONTROL\n");
					
					for (int i2 = 0; i2 < iBars; i2++)
					{
						StrCat(buffer, sizeof(buffer), SF2_PLAYER_HUD_BAR_SYMBOL);
					}

					SetHudTextParams(-1.0, 0.83,
						0.3,
						SF2_HUD_TEXT_COLOR_R,
						SF2_HUD_TEXT_COLOR_G,
						SF2_HUD_TEXT_COLOR_B,
						40,
						_,
						1.0,
						0.07,
						0.5);
					ShowSyncHudText(i, g_hHudSync2, buffer);
				}
			}
		}
		ClientUpdateListeningFlags(i);
		ClientUpdateMusicSystem(i);
	}
	
	return Plugin_Continue;
}

stock bool IsClientParticipating(int iClient)
{
	if (!IsValidClient(iClient)) return false;
	
	if (view_as<bool>(GetEntProp(iClient, Prop_Send, "m_bIsCoaching"))) 
	{
		// Who would coach in this game?
		return false;
	}
	
	int iTeam = GetClientTeam(iClient);

	switch (iTeam)
	{
		case TFTeam_Unassigned, TFTeam_Spectator: return false;
	}
	
	if (view_as<int>(TF2_GetPlayerClass(iClient)) == 0)
	{
		// Player hasn't chosen a class? What.
		return false;
	}
	
	return true;
}

Handle GetQueueList()
{
	Handle hArray = CreateArray(3);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientParticipating(i)) continue;
		if (IsPlayerGroupActive(ClientGetPlayerGroup(i))) continue;
		
		int index = PushArrayCell(hArray, i);
		SetArrayCell(hArray, index, g_iPlayerQueuePoints[i], 1);
		SetArrayCell(hArray, index, false, 2);
	}
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		int index = PushArrayCell(hArray, i);
		SetArrayCell(hArray, index, GetPlayerGroupQueuePoints(i), 1);
		SetArrayCell(hArray, index, true, 2);
	}
	
	if (GetArraySize(hArray)) SortADTArrayCustom(hArray, SortQueueList);
	return hArray;
}

stock int GetOppositeTeam(int iTeam){
	return iTeam == 2 ? 3 : 2;
}

stock int GetOppositeTeamOf(int client){
	int iTeam = GetClientTeam(client);
	return GetOppositeTeam(iTeam);
}

void SetClientPlayState(int iClient, bool bState, bool bEnablePlay=true)
{
	Handle message = StartMessageAll("PlayerTauntSoundLoopEnd", USERMSG_RELIABLE);
	BfWriteByte(message, iClient);
	delete message;
	EndMessage();

	if (bState)
	{
		if (!g_bPlayerEliminated[iClient]) return;
		if (g_bPlayerProxy[iClient]) return;
		
		g_bPlayerCalledForNightmare[iClient] = false;
		g_bPlayerEliminated[iClient] = false;
		g_bPlayerPlaying[iClient] = bEnablePlay;
		g_hPlayerSwitchBlueTimer[iClient] = INVALID_HANDLE;
		
		ClientSetGhostModeState(iClient, false);
		
		PvP_SetPlayerPvPState(iClient, false, false, false);
		
		if (g_bSpecialRound) 
		{
			SetClientPlaySpecialRoundState(iClient, true);
		}
		
		if (g_bNewBossRound) 
		{
			SetClientPlayNewBossRoundState(iClient, true);
		}
		
		if (TF2_GetPlayerClass(iClient) == view_as<TFClassType>(0))
		{
			// Player hasn't chosen a class for some reason. Choose one for him.
			TF2_SetPlayerClass(iClient, view_as<TFClassType>(GetRandomInt(1, 9)), true, true);
		}
		
		ChangeClientTeamNoSuicide(iClient, TFTeam_Red);
	}
	else
	{
		if (g_bPlayerEliminated[iClient]) return;
		
		g_bPlayerEliminated[iClient] = true;
		g_bPlayerPlaying[iClient] = false;
		
		ChangeClientTeamNoSuicide(iClient, TFTeam_Blue);
	}

}
/*
bool DidClientPlayNewBossRound(int iClient)
{
	return g_bPlayerPlayedNewBossRound[iClient];
}
*/
void SetClientPlayNewBossRoundState(int iClient, bool bState)
{
	g_bPlayerPlayedNewBossRound[iClient] = bState;
}
/*
bool DidClientPlaySpecialRound(int iClient)
{
	return g_bPlayerPlayedNewBossRound[iClient];
}
*/
void SetClientPlaySpecialRoundState(int iClient, bool bState)
{
	g_bPlayerPlayedSpecialRound[iClient] = bState;
}

void TeleportClientToEscapePoint(int iClient)
{
	if (!IsClientInGame(iClient)) return;
	
	ArrayList hSpawnPoints = new ArrayList();

	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "sf2_info_player_escapespawn")) != -1)
	{
		SF2PlayerEscapeSpawnEntity spawnPoint = SF2PlayerEscapeSpawnEntity(ent);
		if (!spawnPoint.IsValid() || !spawnPoint.Enabled)
			continue;
		
		hSpawnPoints.Push(ent);
	}

	if (hSpawnPoints.Length > 0)
		ent = hSpawnPoints.Get(GetRandomInt(0, hSpawnPoints.Length - 1));
	else 
		ent = EntRefToEntIndex(g_iRoundEscapePointEntity);

	delete hSpawnPoints;

	if (ent && IsValidEntity(ent))
	{
		SF2PlayerEscapeSpawnEntity spawnPoint = SF2PlayerEscapeSpawnEntity(ent);

		float flPos[3], flAng[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flPos);
		GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", flAng);
		
		TeleportEntity(iClient, flPos, flAng, view_as<float>({ 0.0, 0.0, 0.0 }));

		if (spawnPoint.IsValid())
		{
			spawnPoint.FireOutputNoVariant("OnSpawn", iClient, ent);
		}
		else 
		{
			AcceptEntityInput(ent, "FireUser1", iClient);
		}
	}
}

void ForceInNextPlayersInQueue(int iAmount, bool bShowMessage=false)
{
	// Grab the next person in line, or the next group in line if space allows.
	int iAmountLeft = iAmount;
	Handle hPlayers = CreateArray();
	Handle hArray = GetQueueList();
	
	for (int i = 0, iSize = GetArraySize(hArray); i < iSize && iAmountLeft > 0; i++)
	{
		if (!GetArrayCell(hArray, i, 2))
		{
			int iClient = GetArrayCell(hArray, i);
			if (g_bPlayerPlaying[iClient] || !g_bPlayerEliminated[iClient] || !IsClientParticipating(iClient) || g_bAdminNoPoints[iClient]) continue;
			
			PushArrayCell(hPlayers, iClient);
			iAmountLeft-=1;
		}
		else
		{
			int iGroupIndex = GetArrayCell(hArray, i);
			if (!IsPlayerGroupActive(iGroupIndex)) continue;
			
			int iMemberCount = GetPlayerGroupMemberCount(iGroupIndex);
			if (iMemberCount <= iAmountLeft)
			{
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (!IsValidClient(iClient) || g_bPlayerPlaying[iClient] || !g_bPlayerEliminated[iClient] || !IsClientParticipating(iClient)) continue;
					if (ClientGetPlayerGroup(iClient) == iGroupIndex)
					{
						PushArrayCell(hPlayers, iClient);
					}
				}
				
				SetPlayerGroupPlaying(iGroupIndex, true);
				
				iAmountLeft -= iMemberCount;
			}
		}
	}
	
	delete hArray;
	
	for (int i = 0, iSize = GetArraySize(hPlayers); i < iSize; i++)
	{
		int iClient = GetArrayCell(hPlayers, i);
		ClientSetQueuePoints(iClient, 0);
		SetClientPlayState(iClient, true);
		
		if (bShowMessage) CPrintToChat(iClient, "%T", "SF2 Force Play", iClient);
	}
	
	delete hPlayers;
}

public int SortQueueList(int index1,int index2, Handle array, Handle hndl)
{
	int iQueuePoints1 = GetArrayCell(array, index1, 1);
	int iQueuePoints2 = GetArrayCell(array, index2, 1);
	
	if (iQueuePoints1 > iQueuePoints2) return -1;
	else if (iQueuePoints1 == iQueuePoints2) return 0;
	return 1;
}

//	==========================================================
//	GENERIC PAGE/BOSS HOOKS AND FUNCTIONS
//	==========================================================

public Action Hook_SlenderObjectSetTransmit(int ent,int other)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (!IsPlayerAlive(other) || IsClientInDeathCam(other))
	{
		if (!IsValidEdict(GetEntPropEnt(other, Prop_Send, "m_hObserverTarget"))) return Plugin_Handled;
	}
	if (IsClientInGhostMode(other) || g_bPlayerProxy[other]) return Plugin_Handled;
	if (IsValidClient(other))
	{
		if(ClientGetDistanceFromEntity(other,ent)>=SquareFloat(320.0))
			return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action Hook_SlenderObjectSetTransmitEx(int ent,int other)
{
	if (!g_bEnabled) return Plugin_Continue;
	
	if (!IsPlayerAlive(other) || IsClientInDeathCam(other))
	{
		if (!IsValidEdict(GetEntPropEnt(other, Prop_Send, "m_hObserverTarget"))) return Plugin_Handled;
	}
	if (IsClientInGhostMode(other) || g_bPlayerProxy[other]) return Plugin_Handled;
	if (IsValidClient(other))
	{
		if(ClientGetDistanceFromEntity(other,ent)<=SquareFloat(320.0))
			return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Timer_SlenderBlinkBossThink(Handle timer, any entref)
{
	int slender = EntRefToEntIndex(entref);
	if (!slender || slender == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	int iBossIndex = NPCGetFromEntIndex(slender);
	if (iBossIndex == -1) return Plugin_Stop;
	
	if (timer != g_hSlenderEntityThink[iBossIndex]) return Plugin_Stop;
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	
	if (NPCGetType(iBossIndex) == SF2BossType_Creeper)
	{
		bool bMove = false;
		
		if ((GetGameTime() - g_flSlenderLastKill[iBossIndex]) >= GetProfileFloat(sProfile, "kill_cooldown"))
		{
			if (PeopleCanSeeSlender(iBossIndex, false, false) && !PeopleCanSeeSlender(iBossIndex, true, SlenderUsesBlink(iBossIndex)))
			{
				int iBestPlayer = -1;
				Handle hArray = CreateArray();
				
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsClientInDeathCam(i) || g_bPlayerEliminated[i] || DidClientEscape(i) || IsClientInGhostMode(i) || !PlayerCanSeeSlender(i, iBossIndex, false, false)) continue;
					
					if (!NPCShouldSeeEntity(iBossIndex, i))
						continue;
						
					PushArrayCell(hArray, i);
				}
				
				if (GetArraySize(hArray))
				{
					float flSlenderPos[3];
					SlenderGetAbsOrigin(iBossIndex, flSlenderPos);
					
					float flTempPos[3];
					int iTempPlayer = -1;
					float flTempDist = SquareFloat(16384.0);
					for (int i = 0; i < GetArraySize(hArray); i++)
					{
						int iClient = GetArrayCell(hArray, i);
						GetClientAbsOrigin(iClient, flTempPos);
						if (GetVectorSquareMagnitude(flTempPos, flSlenderPos) < flTempDist)
						{
							iTempPlayer = iClient;
							flTempDist = GetVectorSquareMagnitude(flTempPos, flSlenderPos);
						}
						if (SF_SpecialRound(SPECIALROUND_BOO) && GetVectorSquareMagnitude(flTempPos, flSlenderPos) < SquareFloat(SPECIALROUND_BOO_DISTANCE))
							TF2_StunPlayer(iClient, SPECIALROUND_BOO_DURATION, _, TF_STUNFLAGS_GHOSTSCARE);
					}
					
					iBestPlayer = iTempPlayer;
				}
				
				delete hArray;
				
				float buffer[3];
				if (iBestPlayer != -1 && SlenderCalculateApproachToPlayer(iBossIndex, iBestPlayer, buffer))
				{
					bMove = true;
					
					float flAng[3], flBuffer[3];
					float flSlenderPos[3], flPos[3];
					GetEntPropVector(slender, Prop_Data, "m_vecAbsOrigin", flSlenderPos);
					GetClientAbsOrigin(iBestPlayer, flPos);
					SubtractVectors(flPos, buffer, flAng);
					GetVectorAngles(flAng, flAng);
					
					// Take care of angle offsets.
					AddVectors(flAng, g_flSlenderEyeAngOffset[iBossIndex], flAng);
					for (int i = 0; i < 3; i++) flAng[i] = AngleNormalize(flAng[i]);
					
					flAng[0] = 0.0;
					
					// Take care of position offsets.
					GetProfileVector(sProfile, "pos_offset", flBuffer);
					AddVectors(buffer, flBuffer, buffer);
					
					TeleportEntity(slender, buffer, flAng, NULL_VECTOR);
					
					float flMaxRange = GetProfileFloat(sProfile, "teleport_range_max");
					float flDist = GetVectorSquareMagnitude(buffer, flPos);
					
					char sBuffer[PLATFORM_MAX_PATH];
					
					if (flDist < SquareFloat(flMaxRange * 0.33)) 
					{
						GetProfileString(sProfile, "model_closedist", sBuffer, sizeof(sBuffer));
					}
					else if (flDist < SquareFloat(flMaxRange * 0.66)) 
					{
						GetProfileString(sProfile, "model_averagedist", sBuffer, sizeof(sBuffer));
					}
					else 
					{
						GetProfileString(sProfile, "model", sBuffer, sizeof(sBuffer));
					}
					
					// Fallback if error.
					if (!sBuffer[0]) GetProfileString(sProfile, "model", sBuffer, sizeof(sBuffer));
					
					SetEntProp(slender, Prop_Send, "m_nModelIndex", PrecacheModel(sBuffer));
					
					if (flDist <= NPCGetInstantKillRadius(iBossIndex))
					{
						if (NPCGetFlags(iBossIndex) & SFF_FAKE)
						{
							SlenderMarkAsFake(iBossIndex);
							return Plugin_Stop;
						}
						else
						{
							g_flSlenderLastKill[iBossIndex] = GetGameTime();
							ClientStartDeathCam(iBestPlayer, iBossIndex, buffer);
						}
					}
				}
			}
		}
		
		if (bMove)
		{
			char sBuffer[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_move_single", sBuffer, sizeof(sBuffer));
			if (sBuffer[0]) EmitSoundToAll(sBuffer, slender, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
			
			GetRandomStringFromProfile(sProfile, "sound_move", sBuffer, sizeof(sBuffer));
			if (sBuffer[0]) EmitSoundToAll(sBuffer, slender, SNDCHAN_AUTO, SNDLEVEL_SCREAMING, SND_CHANGEVOL);
		}
		else
		{
			char sBuffer[PLATFORM_MAX_PATH];
			GetRandomStringFromProfile(sProfile, "sound_move", sBuffer, sizeof(sBuffer));
			if (sBuffer[0]) StopSound(slender, SNDCHAN_AUTO, sBuffer);
		}
	}
	
	return Plugin_Continue;
}


void SlenderOnClientStressUpdate(int iClient)
{
	float flStress = g_flPlayerStress[iClient];
	
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
	{	
		if (NPCGetUniqueID(iBossIndex) == -1) continue;
		
		int iBossFlags = NPCGetFlags(iBossIndex);
		if (iBossFlags & SFF_MARKEDASFAKE ||
			iBossFlags & SFF_NOTELEPORT)
		{
			continue;
		}
		
		NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
		
		int iTeleportTarget = EntRefToEntIndex(g_iSlenderTeleportTarget[iBossIndex]);
		if (iTeleportTarget && iTeleportTarget != INVALID_ENT_REFERENCE && !g_bPlayerIsExitCamping[iTeleportTarget])
		{
			if (g_bPlayerEliminated[iTeleportTarget] ||
				DidClientEscape(iTeleportTarget) ||
				flStress >= g_flSlenderTeleportMaxTargetStress[iBossIndex] ||
				GetGameTime() >= g_flSlenderTeleportMaxTargetTime[iBossIndex])
			{
				// Queue for a new target and mark the old target in the rest period.
				float flRestPeriod = GetProfileFloat(sProfile, "teleport_target_rest_period", 15.0);
				flRestPeriod = (flRestPeriod * GetRandomFloat(0.92, 1.08)) / (NPCGetAnger(iBossIndex) * g_flRoundDifficultyModifier);
				
				g_iSlenderTeleportTarget[iBossIndex] = INVALID_ENT_REFERENCE;
				g_flSlenderTeleportPlayersRestTime[iBossIndex][iTeleportTarget] = GetGameTime() + flRestPeriod;
				g_flSlenderTeleportMaxTargetStress[iBossIndex] = 9999.0;
				g_flSlenderTeleportMaxTargetTime[iBossIndex] = -1.0;
				g_flSlenderTeleportTargetTime[iBossIndex] = -1.0;
				
#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: lost target, putting at rest period", iBossIndex);
#endif
			}
		}
		else if (!g_bRoundGrace)
		{
			int iPreferredTeleportTarget = INVALID_ENT_REFERENCE;
			
			float flTargetStressMin = GetProfileFloat(sProfile, "teleport_target_stress_min", 0.2);
			float flTargetStressMax = GetProfileFloat(sProfile, "teleport_target_stress_max", 0.9);
			
			float flTargetStress = flTargetStressMax - ((flTargetStressMax - flTargetStressMin) / (g_flRoundDifficultyModifier * NPCGetAnger(iBossIndex)));
			
			float flPreferredTeleportTargetStress = flTargetStress;
			
			Handle hArrayRaidTargets = CreateArray();
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) ||
					!IsPlayerAlive(i) ||
					g_bPlayerEliminated[i] ||
					IsClientInGhostMode(i) ||
					DidClientEscape(i))
				{
					continue;
				}
				if (g_bPlayerIsExitCamping[i])
				{
					if((iTeleportTarget != INVALID_ENT_REFERENCE && !g_bPlayerIsExitCamping[iTeleportTarget]))
					{
						iPreferredTeleportTarget = i;
						break;
					}
				}
				if (g_flPlayerStress[i] < flPreferredTeleportTargetStress)
				{
					if (g_flSlenderTeleportPlayersRestTime[iBossIndex][i] <= GetGameTime())
					{
						iPreferredTeleportTarget = i;
						flPreferredTeleportTargetStress = g_flPlayerStress[i];
					}
				}
				PushArrayCell(hArrayRaidTargets, i);
			}
			if(GetArraySize(hArrayRaidTargets)>0)
			{
				int iRaidTarget = GetArrayCell(hArrayRaidTargets,GetRandomInt(0, GetArraySize(hArrayRaidTargets) - 1));
				if(IsValidClient(iRaidTarget) && !g_bPlayerEliminated[iRaidTarget])
				{
					g_iSlenderProxyTarget[iBossIndex] = EntIndexToEntRef(iRaidTarget);
				}
			}
			delete hArrayRaidTargets;

			if (iPreferredTeleportTarget && iPreferredTeleportTarget != INVALID_ENT_REFERENCE)
			{
				// Set our preferred target to the new guy.
				float flTargetDuration = GetProfileFloat(sProfile, "teleport_target_persistency_period", 13.0);
				float flDeviation = GetRandomFloat(0.92, 1.08);
				flTargetDuration = Pow(flDeviation * flTargetDuration, ((g_flRoundDifficultyModifier * (NPCGetAnger(iBossIndex) - 1.0)) / 2.0)) + ((flDeviation * flTargetDuration) - 1.0);
				
				g_iSlenderTeleportTarget[iBossIndex] = EntIndexToEntRef(iPreferredTeleportTarget);
				g_flSlenderTeleportPlayersRestTime[iBossIndex][iPreferredTeleportTarget] = -1.0;
				g_flSlenderTeleportMaxTargetTime[iBossIndex] = GetGameTime() + flTargetDuration;
				g_flSlenderTeleportTargetTime[iBossIndex] = GetGameTime();
				g_flSlenderTeleportMaxTargetStress[iBossIndex] = flTargetStress;
				
				iTeleportTarget = iPreferredTeleportTarget;
				
#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: got new target %N", iBossIndex, iPreferredTeleportTarget);
#endif
			}
		}
	}
}

static int GetPageMusicRanges()
{
	g_hPageMusicRanges.Clear();
	
	char sName[64];
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (sName[0] && !StrContains(sName, "sf2_page_music_", false))
		{
			ReplaceString(sName, sizeof(sName), "sf2_page_music_", "", false);
			
			char sPageRanges[2][32];
			ExplodeString(sName, "-", sPageRanges, 2, 32);
			
			int iIndex = g_hPageMusicRanges.Push(EnsureEntRef(ent));
			if (iIndex != -1)
			{
				int iMin = StringToInt(sPageRanges[0]);
				int iMax = StringToInt(sPageRanges[1]);
				
#if defined DEBUG
				DebugMessage("Page range found: entity %d, iMin = %d, iMax = %d", ent, iMin, iMax);
#endif
				g_hPageMusicRanges.Set(iIndex, iMin, 1);
				g_hPageMusicRanges.Set(iIndex, iMax, 2);
			}
		}
	}

	while ((ent = FindEntityByClassname(ent, "sf2_info_page_music")) != -1)
	{
		SF2PageMusicEntity pageMusic = SF2PageMusicEntity(ent);
		if (!pageMusic.IsValid())
			continue;
		
		pageMusic.InsertRanges(g_hPageMusicRanges);
	}
	
	// precache
	if (g_hPageMusicRanges.Length > 0)
	{
		char sPath[PLATFORM_MAX_PATH];
		
		for (int i = 0; i < g_hPageMusicRanges.Length; i++)
		{
			ent = EntRefToEntIndex(g_hPageMusicRanges.Get(i));
			if (!ent || ent == INVALID_ENT_REFERENCE) continue;
			
			SF2PageMusicEntity pageMusic = SF2PageMusicEntity(ent);
			if (pageMusic.IsValid())
			{
				// Don't do anything; entity already precached its own music.
			}
			else
			{
				GetEntPropString(ent, Prop_Data, "m_iszSound", sPath, sizeof(sPath));
				if (sPath[0] != '\0')
					PrecacheSound(sPath);
			}
		}
	}
	
	LogSF2Message("Loaded page music ranges successfully!");
}

void SetPageCount(int iNum)
{
	if (iNum > g_iPageMax) iNum = g_iPageMax;
	
	int iOldPageCount = g_iPageCount;
	g_iPageCount = iNum;
	int iDifficulty = GetConVarInt(g_cvDifficulty);	
	if (g_iPageCount != iOldPageCount)
	{
		if (g_iPageCount > iOldPageCount)
		{
			if (g_hRoundGraceTimer != INVALID_HANDLE) 
			{
				TriggerTimer(g_hRoundGraceTimer);
			}

			if (g_iRoundTime < g_iRoundTimeLimit)
			{
				// Add round time.
				int iRoundTime = g_iRoundTime;

				if (!SF_SpecialRound(SPECIALROUND_NOPAGEBONUS))
					iRoundTime += g_iRoundTimeGainFromPage;

				if (iRoundTime > g_iRoundTimeLimit) iRoundTime = g_iRoundTimeLimit;

				SetRoundTime(iRoundTime);
			}
			
			if (SF_SpecialRound(SPECIALROUND_DISTORTION))
			{
				ArrayList hClientSwap = new ArrayList();
				for (int iClient = 0; iClient < MAX_BOSSES; iClient++)
				{
					if (!IsValidClient(iClient)) continue;
					if (!IsPlayerAlive(iClient)) continue;
					if (g_bPlayerEliminated[iClient]) continue;
					if (DidClientEscape(iClient)) continue;
					hClientSwap.Push(iClient);
				}
				
				int iSize = hClientSwap.Length;
				if (iSize > 1)
				{
					int iClient, iClient2;
					float flPos[3], flPos2[3], flAng[3], flAng2[3], flVel[3], flVel2[3];
					SortADTArray(hClientSwap, Sort_Random, Sort_Integer);
					for (int iArray = 0; iArray < (iSize/2); iArray++)
					{
						iClient = hClientSwap.Get(iArray);
						GetClientAbsOrigin(iClient, flPos);
						GetClientEyeAngles(iClient, flAng);
						GetEntPropVector(iClient, Prop_Data, "m_vecAbsVelocity", flVel);
						
						iClient2 = hClientSwap.Get((iSize-1)-iArray);
						GetClientAbsOrigin(iClient2, flPos2);
						GetClientEyeAngles(iClient2, flAng2);
						GetEntPropVector(iClient2, Prop_Data, "m_vecAbsVelocity", flVel2);
						
						TeleportEntity(iClient, flPos2, flAng2, flVel2);
						if (IsSpaceOccupiedIgnorePlayers(flPos2, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS, iClient))
						{
							Player_FindFreePosition2(iClient, flPos2, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS);
						}
						
						TeleportEntity(iClient2, flPos, flAng, flVel);
						if (IsSpaceOccupiedIgnorePlayers(flPos, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS, iClient2))
						{
							Player_FindFreePosition2(iClient2, flPos, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS);
						}
					}
				}
				delete hClientSwap;
			}
			
			if (SF_SpecialRound(SPECIALROUND_CLASSSCRAMBLE))
			{
				for (int iClient = 0; iClient <= MAX_BOSSES; iClient++)
				{
					if (!IsValidClient(iClient)) continue;
					if (!IsPlayerAlive(iClient)) continue;
					if (g_bPlayerEliminated[iClient]) continue;
					if (DidClientEscape(iClient)) continue;

					TFClassType newClass;
					switch (g_iPlayerRandomClassNumber[iClient])
					{
						case 1: newClass = TFClass_Scout;
						case 2: newClass = TFClass_Soldier;
						case 3: newClass = TFClass_Pyro;
						case 4: newClass = TFClass_DemoMan;
						case 5: newClass = TFClass_Heavy;
						case 6: newClass = TFClass_Engineer;
						case 7: newClass = TFClass_Medic;
						case 8: newClass = TFClass_Sniper;
						case 9: newClass = TFClass_Spy;
					}

					TF2_SetPlayerClass(iClient, newClass);

					CreateTimer(0.1, Timer_ClassScramblePlayer, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.25, Timer_ClassScramblePlayer2, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);

					// Regenerate player but keep health the same.
					int iHealth = GetEntProp(iClient, Prop_Send, "m_iHealth");
					TF2_RegeneratePlayer(iClient);
					SetEntProp(iClient, Prop_Data, "m_iHealth", iHealth);
					SetEntProp(iClient, Prop_Send, "m_iHealth", iHealth);
				}
			}
			
			// Increase anger on selected bosses.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (NPCGetUniqueID(i) == -1) continue;
				
				float flPageDiff = NPCGetAngerAddOnPageGrabTimeDiff(i);
				if (flPageDiff >= 0.0)
				{
					int iDiff = g_iPageCount - iOldPageCount;
					if ((GetGameTime() - g_flPageFoundLastTime) < flPageDiff)
					{
						NPCAddAnger(i, NPCGetAngerAddOnPageGrab(i) * float(iDiff));
					}
				}
			}

			if (SF_IsSlaughterRunMap())
			{
				if (g_iPageCount == 1) //The first collectible for maps like Enclosed
				{
					int iBosses = 0;
					float[] flTimes = new float[MAX_BOSSES];
					float flAverageTime = 0.0;
					for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
					{
						if (NPCGetUniqueID(iNPCIndex) == -1) continue;

						float flOriginalSpeed, flSpeed, flTimerCheck;
						flOriginalSpeed = NPCGetSpeed(iNPCIndex, iDifficulty) + NPCGetAddSpeed(iNPCIndex);
						if (flOriginalSpeed < 600.0) flOriginalSpeed = 600.0;
						if (g_flRoundDifficultyModifier > 1.0)
						{
							flSpeed = flOriginalSpeed + ((flOriginalSpeed * g_flRoundDifficultyModifier)/15) + (NPCGetAnger(iNPCIndex) * g_flRoundDifficultyModifier);
						}
						else
						{
							flSpeed = flOriginalSpeed + NPCGetAnger(iNPCIndex);
						}
						flTimerCheck = flSpeed/GetConVarFloat(g_cvSlaughterRunDivisibleTime);
						flTimes[iBosses] = flTimerCheck;
						iBosses++;
					}
					int iArrayLength = iBosses;
					if (iArrayLength > 0)
					{
						for (int i2 = 0; i2 < iArrayLength; i2++)
						{
							flAverageTime += flTimes[i2];
						}
						flAverageTime = flAverageTime/iArrayLength;
						flAverageTime += (float(iBosses)/2.0);
						for (int i3 = 0; i3 < iArrayLength; i3++)
						{
							flAverageTime += (flTimes[i3]/GetRandomFloat(10.0, 20.0));
						}
						PrintToChatAll("Time before bosses spawn: %f seconds", flAverageTime);
						CreateTimer(flAverageTime, Timer_SlaughterRunSpawnBosses, _, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
			
			g_flPageFoundLastTime = GetGameTime();
		}
		
		SF2MapEntity_OnPageCountChanged(g_iPageCount, iOldPageCount);

		// Notify logic entities.
		char sTargetName[64];
		char sFindTargetName[64];
		FormatEx(sFindTargetName, sizeof(sFindTargetName), "sf2_onpagecount_%d", g_iPageCount);
		
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "logic_relay")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
			if (sTargetName[0] && strcmp(sTargetName, sFindTargetName, false) == 0)
			{
				AcceptEntityInput(ent, "Trigger");
				break;
			}
		}
	
		int iClients[MAXPLAYERS + 1] = { -1, ... };
		int iClientsNum = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			if (!g_bPlayerEliminated[i] || IsClientInGhostMode(i))
			{
				if (g_iPageCount)
				{
					iClients[iClientsNum] = i;
					iClientsNum++;
				}
			}
		}
		
		if (g_iPageCount > 0 && g_bRoundHasEscapeObjective && g_iPageCount == g_iPageMax)
		{
			// Escape initialized!
			SetRoundState(SF2RoundState_Escape);
			
			if (iClientsNum && !SF_SpecialRound(SPECIALROUND_REALISM))
			{
				int iGameTextEscape = -1;
				SF2GameTextEntity gameText = SF2GameTextEntity(-1);

				if (g_GamerulesEntity.IsValid() && (gameText = g_GamerulesEntity.EscapeTextEntity).IsValid())
				{
					char sMessage[512];
					gameText.GetEscapeMessage(sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, gameText.EntRef, g_hHudSync, sMessage);
				}
				else if (IsValidEntity((iGameTextEscape = GetTextEntity("sf2_escape_message", false))))
				{
					// Custom escape message.
					char sMessage[512];
					GetEntPropString(iGameTextEscape, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameTextEscape, g_hHudSync, sMessage);
				}
				else
				{
					// Default escape message.
					for (int i = 0; i < iClientsNum; i++)
					{
						int iClient = iClients[i];
						ClientShowMainMessage(iClient, "%d/%d\n%T", g_iPageCount, g_iPageMax, "SF2 Default Escape Message", i);
					}
				}
			}
			
			if (SF_SpecialRound(SPECIALROUND_LASTRESORT))
			{
				char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
				Handle hSelectableBosses = CloneArray(GetSelectableBossProfileList());
				if (GetArraySize(hSelectableBosses) > 0)
				{
					GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
				}
				delete hSelectableBosses;
			}
		}
		else
		{
			if (iClientsNum && !SF_SpecialRound(SPECIALROUND_REALISM))
			{
				int iGameTextPage = -1;
				SF2GameTextEntity gameText = SF2GameTextEntity(-1);

				if (g_GamerulesEntity.IsValid() && (gameText = g_GamerulesEntity.PageTextEntity).IsValid())
				{
					char sMessage[512];
					gameText.GetPageMessage(sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, gameText.EntRef, g_hHudSync, sMessage);
				}
				else if (IsValidEntity((iGameTextPage = GetTextEntity("sf2_page_message", false))))
				{
					// Custom page message.
					char sMessage[512];
					GetEntPropString(iGameTextPage, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameTextPage, g_hHudSync, sMessage, g_iPageCount, g_iPageMax);
				}
				else
				{
					// Default page message.
					for (int i = 0; i < iClientsNum; i++)
					{
						int iClient = iClients[i];
						ClientShowMainMessage(iClient, "%d/%d", g_iPageCount, g_iPageMax);
					}
				}
			}
		}
		
		CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_SlaughterRunSpawnBosses(Handle timer)
{
	ArrayList hSpawnPoint = new ArrayList();
	float flTeleportPos[3];
	int ent = -1, iSpawnTeam = 0;
	while ((ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1)
	{
		iSpawnTeam = GetEntProp(ent, Prop_Data, "m_iInitialTeamNum");
		if (iSpawnTeam == TFTeam_Red) 
		{
			hSpawnPoint.Push(ent);
		}

	}
	ent = -1;

	for(int iNpc = 0;iNpc <= MAX_BOSSES; iNpc++)
	{
		SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(iNpc);
		if (!Npc.IsValid()) continue;
		Npc.UnSpawn();
		if (hSpawnPoint.Length > 0) ent = hSpawnPoint.Get(GetRandomInt(0,hSpawnPoint.Length-1));
		if (IsValidEntity(ent))
		{
			GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flTeleportPos);
			SpawnSlender(Npc, flTeleportPos);
		}
	}
	delete hSpawnPoint;
}

bool Player_FindFreePosition2(int client, float position[3], float mins[3], float maxs[3])
{
	int team = GetClientTeam(client);
	int mask = MASK_RED;
	if(team != TFTeam_Red) mask = MASK_BLUE;

	// -90 to 90
	float pitchMin = 75.0; // down
	float pitchMax = -89.0; // up
	float pitchInc = 10.0;

	float yawMin = -180.0;
	float yawMax = 180.0;
	float yawInc = 10.0;

	float radiusMin = 150.0; // 150.0
	float radiusMax = 300.0;
	float radiusInc = 25.0; // 25.0
	
	float ang[3];

	for(float p=pitchMin; p>=pitchMax; p-=pitchInc)
	{
		ang[0] = p;
		for(float y=yawMin; y<=yawMax; y+=yawInc)
		{
			ang[1] = y;
			for(float r=radiusMin; r<=radiusMax; r+=radiusInc)
			{
				float freePosition[3];
				GetPositionForward(position, ang, freePosition, r);

				// Perform a line of sight check to avoid spawning players in unreachable map locations.
				// The tank has this weird bug where players can be pushed into map displacements and can sometimes go completely through a wall.
				TR_TraceRayFilter(position, freePosition, mask, RayType_EndPoint, TraceRayDontHitPlayersOrEntity);

				if(!TR_DidHit())
				{
					TR_TraceHullFilter(freePosition, freePosition, mins, maxs, mask, TraceFilter_NotTeam, team);

					if(!TR_DidHit())
					{
						TeleportEntity(client, freePosition, NULL_VECTOR, NULL_VECTOR);
						return true;
					}
				}
				else
				{
					// We hit a wall, breaking line of sight. Give up on this angle.
					break;
				}
			}
		}
	}
	return false;
}
public bool TraceFilter_NotTeam(int entity, int contentsMask, int team)
{
	if(entity >= 1 && entity <= MaxClients && GetClientTeam(entity) == team)
	{
		return false;
	}
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityNetClass(entity, sClass, sizeof(sClass));
		if (strcmp(sClass, "CTFBaseBoss") == 0) return false;
	}
	return true;
}
int GetTextEntity(const char[] sTargetName, bool bCaseSensitive=true)
{
	// Try to see if we can use a custom message instead of the default.
	char targetName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "game_text")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (strcmp(targetName, sTargetName, bCaseSensitive) == 0)
			{
				return ent;
			}
		}
	}
	
	return -1;
}

void ShowHudTextUsingTextEntity(const int[] iClients,int iClientsNum,int iGameText, Handle hHudSync, const char[] sMessage, ...)
{
	if (!sMessage[0]) return;
	if (!IsValidEntity(iGameText)) return;
	
	char sTrueMessage[512];
	VFormat(sTrueMessage, sizeof(sTrueMessage), sMessage, 6);
	
	float flX = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.x");
	float flY = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.y");
	int iEffect = GetEntProp(iGameText, Prop_Data, "m_textParms.effect");
	float flFadeInTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeinTime");
	float flFadeOutTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeoutTime");
	float flHoldTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.holdTime");
	float flFxTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fxTime");
	
	int Color1[4] = { 255, 255, 255, 255 };
	int Color2[4] = { 255, 255, 255, 255 };
	
	int iParmsOffset = FindDataMapInfo(iGameText, "m_textParms");
	if (iParmsOffset != -1)
	{
		// hudtextparms_s m_textParms
		
		Color1[0] = GetEntData(iGameText, iParmsOffset + 12, 1);
		Color1[1] = GetEntData(iGameText, iParmsOffset + 13, 1);
		Color1[2] = GetEntData(iGameText, iParmsOffset + 14, 1);
		Color1[3] = GetEntData(iGameText, iParmsOffset + 15, 1);
		
		Color2[0] = GetEntData(iGameText, iParmsOffset + 16, 1);
		Color2[1] = GetEntData(iGameText, iParmsOffset + 17, 1);
		Color2[2] = GetEntData(iGameText, iParmsOffset + 18, 1);
		Color2[3] = GetEntData(iGameText, iParmsOffset + 19, 1);
	}
	
	SetHudTextParamsEx(flX, flY, flHoldTime, Color1, Color2, iEffect, flFxTime, flFadeInTime, flFadeOutTime);
	
	for (int i = 0; i < iClientsNum; i++)
	{
		int iClient = iClients[i];
		if (!IsValidClient(iClient) || IsFakeClient(iClient)) continue;
		
		ShowSyncHudText(iClient, hHudSync, sTrueMessage);
	}
}

//	==========================================================
//	EVENT HOOKS
//	==========================================================

public Action Event_RoundStart(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	Handle hProf = CreateProfiler();
	StartProfiling(hProf);
	SendDebugMessageToPlayers(DEBUG_EVENT, 0, "(Event_RoundStart) Started profiling...");
	
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_RoundStart");
#endif
	
	// Reset some global variables.
	g_iRoundCount++;
	g_hRoundTimer = INVALID_HANDLE;
	
	SetRoundState(SF2RoundState_Invalid);
	
	SetPageCount(0);
	g_iPageMax = 0;
	g_flPageFoundLastTime = GetGameTime();
	
	g_hVoteTimer = INVALID_HANDLE;
	//Stop the music if needed.
	NPCStopMusic();
	// Remove all bosses from the game.
	NPCRemoveAll();
	// Collect the func_nav_prefer.
	NavCollectFuncNavPrefer();
	// Collect trigger_multiple to prevent touch bug.
	SF_CollectTriggersMultiple();
	// Refresh groups.
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		SetPlayerGroupPlaying(i, false);
		CheckPlayerGroup(i);
	}
	
	// Refresh players.
	for (int i = 1; i <= MaxClients; i++)
	{
		ClientSetGhostModeState(i, false);
		
		g_bPlayerPlaying[i] = false;
		g_bPlayerEliminated[i] = true;
		g_bPlayerEscaped[i] = false;
	}
	SF_RemoveAllSpecialRound();
	// Calculate the new round state.
	if (g_bRoundWaitingForPlayers)
	{
		SetRoundState(SF2RoundState_Waiting);
	}
	else if (GetConVarBool(g_cvWarmupRound) && g_iRoundWarmupRoundCount < GetConVarInt(g_cvWarmupRoundNum))
	{
		g_iRoundWarmupRoundCount++;
		
		SetRoundState(SF2RoundState_Waiting);
		
		ServerCommand("mp_restartgame 15");
		PrintCenterTextAll("Round restarting in 15 seconds");
	}
	else
	{
		g_iRoundActiveCount++;
		
		InitializeNewGame();
	}
	
	PvP_OnRoundStart();
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_RoundStart");
	
	StopProfiling(hProf);
	SendDebugMessageToPlayers(DEBUG_EVENT, 0, "(Event_RoundStart) Stopped profiling, total execution time: %f", GetProfilerTime(hProf));
	delete hProf;
	
#endif
	//Nextbot doesn't trigger the triggers with npc flags, for map backward compatibility we are going to change the trigger filter and force a custom one.
	/*int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_*")) != -1)
	{
		if(IsValidEntity(iEnt))
		{
			int flags = GetEntProp(iEnt, Prop_Data, "m_spawnflags");
			if ((flags & TRIGGER_NPCS) && !(flags & TRIGGER_EVERYTHING_BUT_PHYSICS_DEBRIS))
			{
				//Set the trigger to allow every entity, our custom filter will discard the unwanted entities.
				SetEntProp(iEnt, Prop_Data, "m_spawnflags", flags|TRIGGER_EVERYTHING_BUT_PHYSICS_DEBRIS);
				SDKHook(iEnt, SDKHook_StartTouch, Hook_TriggerNPCTouch);
				SDKHook(iEnt, SDKHook_Touch, Hook_TriggerNPCTouch);
				SDKHook(iEnt, SDKHook_EndTouch, Hook_TriggerNPCTouch);
			}
		}
	}*/
}
public Action Hook_TriggerNPCTouch(int iTrigger, int iOther)
{
	int flags = GetEntProp(iTrigger, Prop_Data, "m_spawnflags");
	if ((flags & TRIGGER_CLIENTS) && MaxClients >= iOther > 0) return Plugin_Continue;
	if (MAX_BOSSES >= NPCGetFromEntIndex(iOther) > -1) return Plugin_Continue;
	
	return Plugin_Handled;
}
public Action Event_WinPanel(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bEnabled) return Plugin_Continue;
	
	char cappers[7];
	int i=0;
	for(int iClient;iClient<=MaxClients;iClient++)
	{
		if(IsValidClient(iClient) && DidClientEscape(iClient) && i<7)
		{
			cappers[i] = iClient;
			event.SetString("cappers", cappers);
			i+=1;
		}
	}
	delete event;
	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_RoundEnd");
#endif

	SF_FailEnd();

	for (int i = 1; i < MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		g_bPlayerDied1Up[i] = false;
		g_bPlayerIn1UpCondition[i] = false;
	}
	
	SpecialRound_RoundEnd();
	
	SetRoundState(SF2RoundState_Outro);
	
	DistributeQueuePointsToPlayers();
	
	g_iRoundEndCount++;	
	CheckRoundLimitForBossPackVote(g_iRoundEndCount);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_RoundEnd");
#endif
	delete event;
}

static void DistributeQueuePointsToPlayers()
{
	// Give away queue points.
	int iDefaultAmount = 5;
	int iAmount = iDefaultAmount;
	int iAmount2 = iAmount;
	Action iAction = Plugin_Continue;
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		
		if (IsPlayerGroupPlaying(i))
		{
			SetPlayerGroupQueuePoints(i, 0);
		}
		else
		{
			iAmount = iDefaultAmount;
			iAmount2 = iAmount;
			iAction = Plugin_Continue;
			
			Call_StartForward(fOnGroupGiveQueuePoints);
			Call_PushCell(i);
			Call_PushCellRef(iAmount2);
			Call_Finish(iAction);
			
			if (iAction == Plugin_Changed) iAmount = iAmount2;
			
			SetPlayerGroupQueuePoints(i, GetPlayerGroupQueuePoints(i) + iAmount);
		
			for (int iClient = 1; iClient <= MaxClients; iClient++)
			{
				if (!IsValidClient(iClient)) continue;
				if (ClientGetPlayerGroup(iClient) == i)
				{
					CPrintToChat(iClient, "%T", "SF2 Give Group Queue Points", iClient, iAmount);
				}
			}
		}
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (g_bAdminNoPoints[i]) continue;
		if (g_bPlayerPlaying[i]) 
		{
			ClientSetQueuePoints(i, 0);
		}
		else
		{
			if (!IsClientParticipating(i))
			{
				CPrintToChat(i, "%T", "SF2 No Queue Points To Spectator", i);
			}
			else
			{
				iAmount = iDefaultAmount;
				iAmount2 = iAmount;
				iAction = Plugin_Continue;
				
				Call_StartForward(fOnClientGiveQueuePoints);
				Call_PushCell(i);
				Call_PushCellRef(iAmount2);
				Call_Finish(iAction);
				
				if (iAction == Plugin_Changed) iAmount = iAmount2;
				
				ClientSetQueuePoints(i, g_iPlayerQueuePoints[i] + iAmount);
				CPrintToChat(i, "%T", "SF2 Give Queue Points", i, iAmount);
			}
		}	
	}
}

public Action Event_PlayerTeamPre(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return Plugin_Continue;

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT START: Event_PlayerTeamPre");
#endif
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient > 0)
	{
		if (GetEventInt(event, "team") > 1 || GetEventInt(event, "oldteam") > 1) SetEventBroadcast(event, true);
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT END: Event_PlayerTeamPre");
#endif
	
	delete event;
	
	return Plugin_Continue;
}

public Action Event_PlayerTeam(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerTeam");
#endif
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient > 0)
	{
		int iintTeam = GetEventInt(event, "team");
		if (iintTeam <= TFTeam_Spectator)
		{
			if (g_bRoundGrace)
			{
				if (g_bPlayerPlaying[iClient] && !g_bPlayerEliminated[iClient])
				{
					ForceInNextPlayersInQueue(1, true);
				}
			}
			
			// You're not playing anymore.
			if (g_bPlayerPlaying[iClient])
			{
				ClientSetQueuePoints(iClient, 0);
			}
			
			g_bPlayerPlaying[iClient] = false;
			g_bPlayerEliminated[iClient] = true;
			g_bPlayerEscaped[iClient] = false;
			
			ClientSetGhostModeState(iClient, false);
			
			if (!view_as<bool>(GetEntProp(iClient, Prop_Send, "m_bIsCoaching")))
			{
				// This is to prevent player spawn spam when someone is coaching. Who coaches in SF2, anyway?
				TF2_RespawnPlayer(iClient);
			}
			
			// Special round.
			if (g_bSpecialRound) g_bPlayerPlayedSpecialRound[iClient] = true;
			
			// Boss round.
			if (g_bNewBossRound) g_bPlayerPlayedNewBossRound[iClient] = true;
		}
		else
		{
			if (!g_bPlayerChoseTeam[iClient])
			{
				g_bPlayerChoseTeam[iClient] = true;
				
				if (g_iPlayerPreferences[iClient].PlayerPreference_ProjectedFlashlight)
				{
					EmitSoundToClient(iClient, SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND);
					CPrintToChat(iClient, "%T", "SF2 Projected Flashlight", iClient);
				}
				else
				{
					CPrintToChat(iClient, "%T", "SF2 Normal Flashlight", iClient);
				}
				
				CreateTimer(5.0, Timer_WelcomeMessage, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	// Check groups.
	if (!IsRoundEnding())
	{
		for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
		{
			if (!IsPlayerGroupActive(i)) continue;
			CheckPlayerGroup(i);
		}
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerTeam");
#endif
	delete event;
}

/**
 *	Sets the player to the correct team if needed. Returns true if a change was necessary, false if no change occurred.
 */
static bool HandlePlayerTeam(int iClient, bool bRespawn=true)
{
	if (!IsClientInGame(iClient) || !IsClientParticipating(iClient)) return false;
	
	if (!g_bPlayerEliminated[iClient])
	{
		if (GetClientTeam(iClient) != TFTeam_Red)
		{
			if (bRespawn)
			{
				TF2_RemoveCondition(iClient,TFCond_HalloweenKart);
				TF2_RemoveCondition(iClient,TFCond_HalloweenKartDash);
				TF2_RemoveCondition(iClient,TFCond_HalloweenKartNoTurn);
				TF2_RemoveCondition(iClient,TFCond_HalloweenKartCage);
				TF2_RemoveCondition(iClient, TFCond_SpawnOutline);
				ChangeClientTeamNoSuicide(iClient, TFTeam_Red);
			}
			else
				ChangeClientTeam(iClient, TFTeam_Red);
				
			return true;
		}
	}
	else
	{
		if (GetClientTeam(iClient) != TFTeam_Blue)
		{
			if (bRespawn)
			{
				TF2_RemoveCondition(iClient,TFCond_HalloweenKart);
				TF2_RemoveCondition(iClient,TFCond_HalloweenKartDash);
				TF2_RemoveCondition(iClient,TFCond_HalloweenKartNoTurn);
				TF2_RemoveCondition(iClient,TFCond_HalloweenKartCage);
				TF2_RemoveCondition(iClient, TFCond_SpawnOutline);
				ChangeClientTeamNoSuicide(iClient, TFTeam_Blue);
			}
			else
				ChangeClientTeam(iClient, TFTeam_Blue);
				
			return true;
		}
	}
	
	return false;
}

static void HandlePlayerIntroState(int iClient)
{
	if (!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || !IsClientParticipating(iClient)) return;
	
	if (!IsRoundInIntro()) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("START HandlePlayerIntroState(%d)", iClient);
#endif
	
	// Disable movement on player.
	SetEntityFlags(iClient, GetEntityFlags(iClient) | FL_FROZEN);
	
	float flDelay = 0.0;
	if (!IsFakeClient(iClient))
	{
		flDelay = GetClientLatency(iClient, NetFlow_Outgoing);
	}
	
	CreateTimer(flDelay * 4.0, Timer_IntroBlackOut, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 2) DebugMessage("END HandlePlayerIntroState(%d)", iClient);
#endif
}

void HandlePlayerHUD(int iClient)
{
	if(SF_IsRaidMap() || SF_IsBoxingMap())
		return;
	if (IsRoundInWarmup() || IsClientInGhostMode(iClient))
	{
		SetEntProp(iClient, Prop_Send, "m_iHideHUD", 0);
	}
	else
	{
		if (!g_bPlayerEliminated[iClient])
		{
			if (!DidClientEscape(iClient))
			{
				// Player is in the game; disable normal HUD.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", HIDEHUD_CROSSHAIR|HIDEHUD_HEALTH);
			}
			else
			{
				// Player isn't in the game; enable normal HUD behavior.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", 0);
			}
		}
		else
		{
			if (g_bPlayerProxy[iClient])
			{
				// Player is in the game; disable normal HUD.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", HIDEHUD_CROSSHAIR | HIDEHUD_HEALTH);
			}
			else
			{
				// Player isn't in the game; enable normal HUD behavior.
				SetEntProp(iClient, Prop_Send, "m_iHideHUD", 0);
			}
		}
	}
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient <= 0) return;
#if defined DEBUG

	Handle hProf = CreateProfiler();
	StartProfiling(hProf);
	SendDebugMessageToPlayers(DEBUG_EVENT, 0, "(Event_PlayerSpawn) Started profiling...");

	//PrintToChatAll("(SPAWN) Spawn event called.");
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerSpawn(%d)", iClient);
#endif
	
	if(GetClientTeam(iClient) > 1)
	{
		g_flLastVisibilityProcess[iClient]=GetGameTime();
		ClientResetStatic(iClient);
		if(!g_bSeeUpdateMenu[iClient])
		{
			g_bSeeUpdateMenu[iClient] = true;
			DisplayMenu(g_hMenuUpdate, iClient, 30);
		}
	}
	if (!IsClientParticipating(iClient))
	{
		TF2Attrib_SetByName(iClient, "increased jump height", 1.0);
		TF2Attrib_RemoveByDefIndex(iClient, 10);
		
		ClientSetGhostModeState(iClient, false);
		SetEntityGravity(iClient, 1.0);
		g_iPlayerPageCount[iClient] = 0;

		ClientResetStatic(iClient);
		ClientResetSlenderStats(iClient);
		ClientResetCampingStats(iClient);
		ClientResetOverlay(iClient);
		ClientResetJumpScare(iClient);
		ClientUpdateListeningFlags(iClient);
		ClientUpdateMusicSystem(iClient);
		ClientChaseMusicReset(iClient);
		ClientChaseMusicSeeReset(iClient);
		ClientAlertMusicReset(iClient);
		Client20DollarsMusicReset(iClient);
		Client90sMusicReset(iClient);
		ClientMusicReset(iClient);
		ClientResetProxy(iClient);
		ClientResetHints(iClient);
		ClientResetScare(iClient);
		
		ClientResetDeathCam(iClient);
		ClientResetFlashlight(iClient);
		ClientDeactivateUltravision(iClient);
		ClientResetSprint(iClient);
		ClientResetBreathing(iClient);
		ClientResetBlink(iClient);
		ClientResetInteractiveGlow(iClient);
		ClientDisableConstantGlow(iClient);
		
		ClientHandleGhostMode(iClient);
	}
	
	if (SF_IsBoxingMap() && IsRoundInEscapeObjective())
	{
		CreateTimer(0.2, Timer_CheckAlivePlayers, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	g_hPlayerPostWeaponsTimer[iClient] = INVALID_HANDLE;
	g_hPlayerIgniteTimer[iClient] = INVALID_HANDLE;
	g_hPlayerResetIgnite[iClient] = INVALID_HANDLE;
	g_hPlayerPageRewardTimer[iClient] = INVALID_HANDLE;
	g_hPlayerPageRewardCycleTimer[iClient] = INVALID_HANDLE;
	g_hPlayerFireworkTimer[iClient] = INVALID_HANDLE;

	g_iPlayerBossKillSubject[iClient] = INVALID_ENT_REFERENCE;
	
	g_bPlayerGettingPageReward[iClient] = false;
	g_iPlayerHitsToCrits[iClient] = 0;
	g_iPlayerHitsToHeads[iClient] = 0;
	
	g_bPlayerTrapped[iClient] = false;
	g_iPlayerTrapCount[iClient] = 0;

	g_iPlayerRandomClassNumber[iClient] = 1;
	
	if (IsPlayerAlive(iClient) && IsClientParticipating(iClient))
	{
		if(MusicActive() || SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))//A boss is overriding the music.
		{
			char sPath[PLATFORM_MAX_PATH];
			GetBossMusic(sPath,sizeof(sPath));
			StopSound(iClient, MUSIC_CHAN, sPath);
			if (SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
			{
				StopSound(iClient, MUSIC_CHAN, TRIPLEBOSSESMUSIC);
			}
		}
		g_bBackStabbed[iClient] = false;
		TF2_RemoveCondition(iClient,TFCond_HalloweenKart);
		TF2_RemoveCondition(iClient,TFCond_HalloweenKartDash);
		TF2_RemoveCondition(iClient,TFCond_HalloweenKartNoTurn);
		TF2_RemoveCondition(iClient,TFCond_HalloweenKartCage);
		TF2_RemoveCondition(iClient, TFCond_SpawnOutline);

		if (HandlePlayerTeam(iClient))
		{
#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("iClient->HandlePlayerTeam()");
#endif
		}
		else
		{
			g_iPlayerPageCount[iClient] = 0;

			ClientResetStatic(iClient);
			ClientResetSlenderStats(iClient);
			ClientResetCampingStats(iClient);
			ClientResetOverlay(iClient);
			ClientResetJumpScare(iClient);
			ClientUpdateListeningFlags(iClient);
			ClientUpdateMusicSystem(iClient);
			ClientChaseMusicReset(iClient);
			ClientChaseMusicSeeReset(iClient);
			ClientAlertMusicReset(iClient);
			Client20DollarsMusicReset(iClient);
			Client90sMusicReset(iClient);
			ClientMusicReset(iClient);
			ClientResetProxy(iClient);
			ClientResetHints(iClient);
			ClientResetScare(iClient);
			
			ClientResetDeathCam(iClient);
			ClientResetFlashlight(iClient);
			ClientDeactivateUltravision(iClient);
			ClientResetSprint(iClient);
			ClientResetBreathing(iClient);
			ClientResetBlink(iClient);
			ClientResetInteractiveGlow(iClient);
			ClientDisableConstantGlow(iClient);
			
			ClientHandleGhostMode(iClient);
			
			TF2Attrib_SetByName(iClient, "increased jump height", 1.0);
			
			if (!g_bPlayerEliminated[iClient])
			{
				if((SF_IsRaidMap() || SF_IsBoxingMap()) && g_bRoundGrace)
					TF2Attrib_SetByDefIndex(iClient, 10, 7.0);
				else
					TF2Attrib_RemoveByDefIndex(iClient, 10);
				
				TF2Attrib_SetByDefIndex(iClient, 49, 1.0);
		
				ClientStartDrainingBlinkMeter(iClient);
				ClientSetScareBoostEndTime(iClient, -1.0);
				
				ClientStartCampingTimer(iClient);
				
				HandlePlayerIntroState(iClient);

				// screen overlay timer
				if (!SF_IsRaidMap() && !SF_IsBoxingMap())
				{
					g_hPlayerOverlayCheck[iClient] = CreateTimer(0.0, Timer_PlayerOverlayCheck, GetClientUserId(iClient), TIMER_REPEAT);
					TriggerTimer(g_hPlayerOverlayCheck[iClient], true);
				}
				if (DidClientEscape(iClient))
				{
					CreateTimer(0.1, Timer_TeleportPlayerToEscapePoint, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					int iRed[4] = {184, 56, 59, 255};
					ClientEnableConstantGlow(iClient, "head", iRed);
					ClientActivateUltravision(iClient);
				}
				
				if (SF_SpecialRound(SPECIALROUND_1UP) && !g_bPlayerIn1UpCondition[iClient] && !g_bPlayerDied1Up[iClient])
				{
					g_bPlayerDied1Up[iClient] = false;
					g_bPlayerIn1UpCondition[iClient] = true;
				}
				
				if (SF_SpecialRound(SPECIALROUND_PAGEDETECTOR))
					ClientSetSpecialRoundTimer(iClient, 0.0, Timer_ClientPageDetector, GetClientUserId(iClient));
					
				if (SF_SpecialRound(SPECIALROUND_REALISM))
					EmitSoundToClient(iClient, MARBLEHORNETS_STATIC, _, SNDCHAN_STATIC, 100, _, 0.8);
			}
			else
			{
				g_hPlayerOverlayCheck[iClient] = INVALID_HANDLE;
				TF2Attrib_RemoveByDefIndex(iClient, 10);
				TF2Attrib_RemoveByDefIndex(iClient, 49);
			}
			ClientSwitchToWeaponSlot(iClient, TFWeaponSlot_Melee);
			g_hPlayerPostWeaponsTimer[iClient] = CreateTimer(0.1, Timer_ClientPostWeapons, GetClientUserId(iClient));
			
			HandlePlayerHUD(iClient);
		}
	}
	
	PvP_OnPlayerSpawn(iClient);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerSpawn(%d)", iClient);

	StopProfiling(hProf);
	SendDebugMessageToPlayers(DEBUG_EVENT, 0, "(Event_PlayerSpawn) Stopped profiling, function executed in %f",GetProfilerTime(hProf));
	delete hProf;
#endif
	
	delete event;
}

public Action Timer_IntroBlackOut(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	
	if (!IsRoundInIntro()) return;
	
	if (!IsPlayerAlive(iClient) || g_bPlayerEliminated[iClient]) return;
	
	// Black out the player's screen.
	int iFadeFlags = FFADE_OUT | FFADE_STAYOUT | FFADE_PURGE;
	UTIL_ScreenFade(iClient, 0, FixedUnsigned16(90.0, 1 << 12), iFadeFlags, g_iRoundIntroFadeColor[0], g_iRoundIntroFadeColor[1], g_iRoundIntroFadeColor[2], g_iRoundIntroFadeColor[3]);
}

public Action Event_PostInventoryApplication(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PostInventoryApplication");
#endif
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient > 0)
	{
		ClientSwitchToWeaponSlot(iClient, TFWeaponSlot_Melee);
		g_hPlayerPostWeaponsTimer[iClient] = CreateTimer(0.1, Timer_ClientPostWeapons, GetClientUserId(iClient));
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PostInventoryApplication");
#endif
	delete event;
}
public Action Event_DontBroadcastToClients(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (IsRoundInWarmup()) return Plugin_Continue;
	
	SetEventBroadcast(event, true);
	delete event;
	return Plugin_Continue;
}

public Action Event_PlayerDeathPre(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return Plugin_Continue;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT START: Event_PlayerDeathPre");
#endif
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	int iDifficulty = GetConVarInt(g_cvDifficulty);
	
	int inflictor = GetEventInt(event, "inflictor_entindex");

	// If this player was killed by a boss, play a sound.
	int npcIndex = NPCGetFromEntIndex(inflictor);
	if (npcIndex != -1)
	{
		int iSourceTV = GetClientOfUserId(g_iSourceTVUserID);
		int iAttackIndex = NPCGetCurrentAttackIndex(npcIndex);
		if (MaxClients >= iSourceTV > 0 && IsClientInGame(iSourceTV) && IsClientSourceTV(iSourceTV))//If the server has a source TV bot uses to print boss' name in kill feed.
		{
			if (g_hTimerChangeSourceTVBotName != INVALID_HANDLE)
				delete g_hTimerChangeSourceTVBotName;
			else //No timer running that means the SourceTV bot's current name is the correct one, we can safely update our last known SourceTV bot's name.
				GetEntPropString(iSourceTV, Prop_Data, "m_szNetname", g_sOldSourceTVClientName, sizeof(g_sOldSourceTVClientName));
				
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH], sBossName[64];
			NPCGetProfile(npcIndex, sProfile, sizeof(sProfile));
			switch (iDifficulty)
			{
				case Difficulty_Normal: GetProfileString(sProfile, "name", sBossName, sizeof(sBossName));
				case Difficulty_Hard:
				{
					GetProfileString(sProfile, "name_hard", sBossName, sizeof(sBossName));
					if (!sBossName[0]) GetProfileString(sProfile, "name", sBossName, sizeof(sBossName));
				}
				case Difficulty_Insane:
				{
					GetProfileString(sProfile, "name_insane", sBossName, sizeof(sBossName));
					if (!sBossName[0])
					{
						GetProfileString(sProfile, "name_hard", sBossName, sizeof(sBossName));
						if (!sBossName[0]) GetProfileString(sProfile, "name", sBossName, sizeof(sBossName));
					}
				}
				case Difficulty_Nightmare:
				{
					GetProfileString(sProfile, "name_nightmare", sBossName, sizeof(sBossName));
					if (!sBossName[0])
					{
						GetProfileString(sProfile, "name_insane", sBossName, sizeof(sBossName));
						if (!sBossName[0])
						{
							GetProfileString(sProfile, "name_hard", sBossName, sizeof(sBossName));
							if (!sBossName[0]) GetProfileString(sProfile, "name", sBossName, sizeof(sBossName));
						}
					}
				}
				case Difficulty_Apollyon:
				{
					GetProfileString(sProfile, "name_apollyon", sBossName, sizeof(sBossName));
					if (!sBossName[0])
					{
						GetProfileString(sProfile, "name_nightmare", sBossName, sizeof(sBossName));
						if (!sBossName[0])
						{
							GetProfileString(sProfile, "name_insane", sBossName, sizeof(sBossName));
							if (!sBossName[0])
							{
								GetProfileString(sProfile, "name_hard", sBossName, sizeof(sBossName));
								if (!sBossName[0]) GetProfileString(sProfile, "name", sBossName, sizeof(sBossName));
							}
						}
					}
				}
			}

			//TF2_ChangePlayerName(iSourceTV, sBossName, true);
			SetClientName(iSourceTV, sBossName);
			SetEntPropString(iSourceTV, Prop_Data, "m_szNetname", sBossName);

			SetEventString(event, "assister_fallback","");
			if ((NPCGetFlags(npcIndex) & SFF_WEAPONKILLS) || (NPCGetFlags(npcIndex) & SFF_WEAPONKILLSONRADIUS))
			{
				if (NPCGetFlags(npcIndex) & SFF_WEAPONKILLS)
				{
					char sWeaponType[PLATFORM_MAX_PATH];
					int iWeaponNum = GetProfileAttackNum(sProfile, "attack_weapontypeint", 0, iAttackIndex+1);
					GetProfileAttackString(sProfile, "attack_weapontype", sWeaponType, sizeof(sWeaponType), "", iAttackIndex+1);
					SetEventString(event, "weapon_logclassname",sWeaponType);
					SetEventString(event, "weapon",sWeaponType);
					SetEventInt(event, "customkill",iWeaponNum);
				}
				else if (NPCGetFlags(npcIndex) & SFF_WEAPONKILLSONRADIUS)
				{
					char sWeaponType[PLATFORM_MAX_PATH];
					int iWeaponNum = GetProfileNum(sProfile, "kill_weapontypeint", 0);
					GetProfileString(sProfile, "kill_weapontype", sWeaponType, sizeof(sWeaponType));
					SetEventString(event, "weapon_logclassname",sWeaponType);
					SetEventString(event, "weapon",sWeaponType);
					SetEventInt(event, "customkill",iWeaponNum);
				}
			}
			else
			{
				SetEventString(event, "weapon","");
				SetEventString(event, "weapon_logclassname","");
			}
			
			SetEventInt(event,"attacker", g_iSourceTVUserID);
			g_hTimerChangeSourceTVBotName = CreateTimer(0.6, Timer_RevertSourceTVBotName);
		}
	}
	char classname[64], sStringName[128];

	GetEventString(event, "weapon", sStringName, sizeof(sStringName));
	
	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_KILLICONS, 0, "String kill icon is %s, integer kill icon is %i.", sStringName, GetEventInt(event, "customkill"));
	#endif
	
	if (IsValidEntity(inflictor) && (GetEntityClassname(inflictor, classname, sizeof(classname)) && (strcmp(classname, "env_explosion") == 0 || strcmp(classname, "tf_projectile_sentryrocket") == 0 || strcmp(classname, "tf_projectile_rocket") == 0 || strcmp(classname, "tf_projectile_pipe") == 0 || strcmp(classname, "tf_projectile_arrow") == 0)))
	{
		int npcIndex2 = NPCGetFromEntIndex(GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity"));
		if (npcIndex2 != -1)
		{
			int iSourceTV = GetClientOfUserId(g_iSourceTVUserID);
			if (MaxClients >= iSourceTV > 0 && IsClientInGame(iSourceTV) && IsClientSourceTV(iSourceTV))//If the server has a source TV bot uses to print boss' name in kill feed.
			{
				if (g_hTimerChangeSourceTVBotName != INVALID_HANDLE)
					delete g_hTimerChangeSourceTVBotName;
				else //No timer running that means the SourceTV bot's current name is the correct one, we can safely update our last known SourceTV bot's name.
					GetEntPropString(iSourceTV, Prop_Data, "m_szNetname", g_sOldSourceTVClientName, sizeof(g_sOldSourceTVClientName));
					
				char sProfile[SF2_MAX_PROFILE_NAME_LENGTH], sBossName[64];
				NPCGetProfile(npcIndex2, sProfile, sizeof(sProfile));
				GetProfileString(sProfile, "name", sBossName, sizeof(sBossName));
				
				//TF2_ChangePlayerName(iSourceTV, sBossName, true);
				SetClientName(iSourceTV, sBossName);
				SetEntPropString(iSourceTV, Prop_Data, "m_szNetname", sBossName);
				
				SetEventString(event, "assister_fallback","");
				
				SetEventInt(event, "attacker", g_iSourceTVUserID);
				g_hTimerChangeSourceTVBotName = CreateTimer(0.6, Timer_RevertSourceTVBotName);
			}
		}
	}
	
	if (!IsRoundInWarmup())
	{
		if (iClient > 0)
		{
			if (g_bBackStabbed[iClient])
			{
				SetEventInt(event, "customkill", TF_CUSTOM_BACKSTAB);
				g_bBackStabbed[iClient] = false;
			}
		}
	}
	if (GetEventInt(event,"duck_streak_victim") != 99) 
	{
		if (MAX_BOSSES > npcIndex >= 0 && (g_bSlenderHasAshKillEffect[npcIndex] || g_bSlenderHasCloakKillEffect[npcIndex]
										|| g_bSlenderHasDecapKillEffect[npcIndex] || g_bSlenderHasDeleteKillEffect[npcIndex]
										|| g_bSlenderHasDisintegrateKillEffect[npcIndex] || g_bSlenderHasDissolveRagdollOnKill[npcIndex]
										|| g_bSlenderHasElectrocuteKillEffect[npcIndex] || g_bSlenderHasGoldKillEffect[npcIndex]
										|| g_bSlenderHasIceKillEffect[npcIndex] || g_bSlenderHasPlasmaRagdollOnKill[npcIndex]
										|| g_bSlenderHasPushRagdollOnKill[npcIndex] || g_bSlenderHasResizeRagdollOnKill[npcIndex]
										|| g_bSlenderHasBurnKillEffect[npcIndex] || g_bSlenderHasGibKillEffect[npcIndex]))
		{
			CreateTimer(0.0, Timer_ModifyRagdoll, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
		}
		SetEventBroadcast(event, true);
	}
	else SetEventBroadcast(event, false);
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 1) DebugMessage("EVENT END: Event_PlayerDeathPre");
#endif
	delete event;
	return Plugin_Changed;
}

public Action Event_PlayerHurt(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient <= 0) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerHurt");
#endif

	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (attacker > 0)
	{
		if (g_bPlayerProxy[attacker])
		{
			g_iPlayerProxyControl[attacker] = 100;
		}
	}

	// Play any sounds, if any.
	if (g_bPlayerProxy[iClient])
	{
		int iProxyMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]);
		if (iProxyMaster != -1)
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			NPCGetProfile(iProxyMaster, sProfile, sizeof(sProfile));
		
			char sBuffer[PLATFORM_MAX_PATH];
			if (GetRandomStringFromProfile(sProfile, "sound_proxy_hurt", sBuffer, sizeof(sBuffer)) && sBuffer[0])
			{
				int iChannel = GetProfileNum(sProfile, "sound_proxy_hurt_channel", SNDCHAN_AUTO);
				int iLevel = GetProfileNum(sProfile, "sound_proxy_hurt_level", SNDLEVEL_NORMAL);
				int iFlags = GetProfileNum(sProfile, "sound_proxy_hurt_flags", SND_NOFLAGS);
				float flVolume = GetProfileFloat(sProfile, "sound_proxy_hurt_volume", SNDVOL_NORMAL);
				int iPitch = GetProfileNum(sProfile, "sound_proxy_hurt_pitch", SNDPITCH_NORMAL);
				
				EmitSoundToAll(sBuffer, iClient, iChannel, iLevel, iFlags, flVolume, iPitch);
			}
		}
	}
	delete event;
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerHurt");
#endif
}

public void SF2_OnBossAdded(int iBossIndex)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	SF2_GetBossName(iBossIndex, sProfile, sizeof(sProfile));
	g_bSlenderHasBurnKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "burn_ragdoll_on_kill"));
	g_bSlenderHasCloakKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "cloak_ragdoll_on_kill"));
	g_bSlenderHasDecapKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "decap_ragdoll_on_kill"));
	g_bSlenderHasGibKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "gib_ragdoll_on_kill"));
	g_bSlenderHasGoldKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "gold_ragdoll_on_kill"));
	g_bSlenderHasIceKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "ice_ragdoll_on_kill"));
	g_bSlenderHasElectrocuteKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "electrocute_ragdoll_on_kill"));
	g_bSlenderHasAshKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "ash_ragdoll_on_kill"));
	g_bSlenderHasDisintegrateKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "disintegrate_ragdoll_on_kill"));
	g_bSlenderHasDeleteKillEffect[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "delete_ragdoll_on_kill"));
	g_bSlenderHasPushRagdollOnKill[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "push_ragdoll_on_kill"));

	g_bSlenderHasDissolveRagdollOnKill[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "dissolve_ragdoll_on_kill"));
	g_iSlenderDissolveRagdollType[iBossIndex] = GetProfileNum(sProfile, "dissolve_ragdoll_type");

	g_bSlenderHasPlasmaRagdollOnKill[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "plasma_ragdoll_on_kill"));

	g_bSlenderHasResizeRagdollOnKill[iBossIndex] = view_as<bool>(GetProfileNum(sProfile, "resize_ragdoll_on_kill"));
	g_flSlenderResizeRagdollHands[iBossIndex] = GetProfileFloat(sProfile, "resize_ragdoll_head", 1.0);
	g_flSlenderResizeRagdollHead[iBossIndex] = GetProfileFloat(sProfile, "resize_ragdoll_hands", 1.0);
	g_flSlenderResizeRagdollTorso[iBossIndex] = GetProfileFloat(sProfile, "resize_ragdoll_torso", 1.0);
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dB)
{
	if (!g_bEnabled) return;
	
	if (GetEventInt(event,"duck_streak_victim") == 99) return;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient <= 0) return;
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT START: Event_PlayerDeath(%d)", iClient);
#endif
	
	bool bFake = view_as<bool>(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER);
	int inflictor = GetEventInt(event, "inflictor_entindex");
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("inflictor = %d", inflictor);
#endif

	if (!bFake)
	{	
		ClientResetStatic(iClient);
		ClientResetSlenderStats(iClient);
		ClientResetCampingStats(iClient);
		ClientResetOverlay(iClient);
		ClientResetJumpScare(iClient);
		ClientResetInteractiveGlow(iClient);
		ClientDisableConstantGlow(iClient);
		ClientChaseMusicReset(iClient);
		ClientChaseMusicSeeReset(iClient);
		ClientAlertMusicReset(iClient);
		Client20DollarsMusicReset(iClient);
		Client90sMusicReset(iClient);
		ClientMusicReset(iClient);

		ClientResetFlashlight(iClient);
		ClientDeactivateUltravision(iClient);
		ClientResetSprint(iClient);
		ClientResetBreathing(iClient);
		ClientResetBlink(iClient);
		ClientResetDeathCam(iClient);
		
		ClientUpdateMusicSystem(iClient);
		
		PvP_SetPlayerPvPState(iClient, false, false, false);
		
		if (IsRoundInWarmup())
		{
			CreateTimer(0.3, Timer_RespawnPlayer, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			if (!g_bPlayerEliminated[iClient])
			{
				if (SF_SpecialRound(SPECIALROUND_MULTIEFFECT) || g_bRenevantMultiEffect)
						CreateTimer(0.1, Timer_ReplacePlayerRagdoll, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
				if (IsRoundInIntro() || g_bRoundGrace || DidClientEscape(iClient) || (SF_SpecialRound(SPECIALROUND_1UP) && g_bPlayerIn1UpCondition[iClient] && !g_bPlayerDied1Up[iClient]))
				{
					CreateTimer(0.3, Timer_RespawnPlayer, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					g_bPlayerEliminated[iClient] = true;
					g_bPlayerEscaped[iClient] = false;
					g_hPlayerSwitchBlueTimer[iClient] = CreateTimer(0.5, Timer_PlayerSwitchToBlue, GetClientUserId(iClient));
				}
				if (SF_SpecialRound(SPECIALROUND_REALISM))
					StopSound(iClient, SNDCHAN_STATIC, MARBLEHORNETS_STATIC);
			}
			else
			{
			}
			
			
			// If this player was killed by a boss, play a sound, or print a message.
			int npcIndex = NPCGetFromEntIndex(inflictor);
			if (npcIndex != -1)
			{
				int iSlender = NPCGetEntIndex(npcIndex);
				if (iSlender && iSlender != INVALID_ENT_REFERENCE) g_iPlayerBossKillSubject[iClient] = EntIndexToEntRef(iSlender);

				char npcProfile[SF2_MAX_PROFILE_NAME_LENGTH], buffer[PLATFORM_MAX_PATH];
				NPCGetProfile(npcIndex, npcProfile, sizeof(npcProfile));
				
				if(GetRandomStringFromProfile(npcProfile, "sound_attack_killed_client", buffer, sizeof(buffer)) && buffer[0] != '\0')
				{
					if (g_bPlayerEliminated[iClient])
					{
						EmitSoundToClient(iClient, buffer, _, MUSIC_CHAN);
					}
				}
				
				if (GetRandomStringFromProfile(npcProfile, "sound_attack_killed_all", buffer, sizeof(buffer)) && buffer[0] != '\0')
				{
					if (g_bPlayerEliminated[iClient])
					{
						EmitSoundToAll(buffer, _, MUSIC_CHAN, SNDLEVEL_HELICOPTER);
					}
				}
				
				SlenderPrintChatMessage(npcIndex, iClient);
				
				SlenderPerformVoice(npcIndex, "sound_attack_killed");
			}
			
			char classname[64];
			
			if (IsValidEntity(inflictor) && GetEntityClassname(inflictor, classname, sizeof(classname)) && (strcmp(classname, "env_explosion") == 0 || strcmp(classname, "tf_projectile_sentryrocket") == 0 || strcmp(classname, "tf_projectile_rocket") == 0 || strcmp(classname, "tf_projectile_pipe") == 0 || strcmp(classname, "tf_projectile_arrow") == 0 || strcmp(classname, "tf_point_weapon_mimic") == 0))
			{
				int npcIndex2 = NPCGetFromEntIndex(GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity"));
				if (npcIndex2 != -1)
				{
					int iSlender = NPCGetEntIndex(npcIndex2);
					if (iSlender && iSlender != INVALID_ENT_REFERENCE) g_iPlayerBossKillSubject[iClient] = EntIndexToEntRef(iSlender);

					char npcProfile[SF2_MAX_PROFILE_NAME_LENGTH], buffer[PLATFORM_MAX_PATH];
					NPCGetProfile(npcIndex2, npcProfile, sizeof(npcProfile));
					
					if(GetRandomStringFromProfile(npcProfile, "sound_attack_killed_client", buffer, sizeof(buffer)) && buffer[0] != '\0')
					{
						if (g_bPlayerEliminated[iClient])
						{
							EmitSoundToClient(iClient, buffer, _, MUSIC_CHAN);
						}
					}
					
					if (GetRandomStringFromProfile(npcProfile, "sound_attack_killed_all", buffer, sizeof(buffer)) && buffer[0] != '\0')
					{
						if (g_bPlayerEliminated[iClient])
						{
							EmitSoundToAll(buffer, _, MUSIC_CHAN, SNDLEVEL_HELICOPTER);
						}
					}
					
					SlenderPrintChatMessage(npcIndex2, iClient);
					
					SlenderPerformVoice(npcIndex2, "sound_attack_killed");
				}
			}
			
			CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
			
			// Notify to other bosses that this player has died.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (NPCGetUniqueID(i) == -1) continue;
				
				if (EntRefToEntIndex(g_iSlenderTarget[i]) == iClient)
				{
					g_iSlenderInterruptConditions[i] |= COND_CHASETARGETINVALIDATED;
					GetClientAbsOrigin(iClient, g_flSlenderChaseDeathPosition[i]);
				}
			}
			
			if (g_cvIgnoreRedPlayerDeathSwap.BoolValue)
			{
				g_bPlayerEliminated[iClient] = false;
				g_bPlayerEscaped[iClient] = false;
			}
		}
		
		if (g_bPlayerProxy[iClient])
		{
			// We're a proxy, so play some sounds.
		
			int iProxyMaster = NPCGetFromUniqueID(g_iPlayerProxyMaster[iClient]);
			if (iProxyMaster != -1)
			{
				char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
				NPCGetProfile(iProxyMaster, sProfile, sizeof(sProfile));
				
				char sBuffer[PLATFORM_MAX_PATH];
				if (GetRandomStringFromProfile(sProfile, "sound_proxy_death", sBuffer, sizeof(sBuffer)) && sBuffer[0])
				{
					int iChannel = GetProfileNum(sProfile, "sound_proxy_death_channel", SNDCHAN_AUTO);
					int iLevel = GetProfileNum(sProfile, "sound_proxy_death_level", SNDLEVEL_NORMAL);
					int iFlags = GetProfileNum(sProfile, "sound_proxy_death_flags", SND_NOFLAGS);
					float flVolume = GetProfileFloat(sProfile, "sound_proxy_death_volume", SNDVOL_NORMAL);
					int iPitch = GetProfileNum(sProfile, "sound_proxy_death_pitch", SNDPITCH_NORMAL);
					
					EmitSoundToAll(sBuffer, iClient, iChannel, iLevel, iFlags, flVolume, iPitch);
				}
			}
		}
		
		ClientResetProxy(iClient, false);
		ClientUpdateListeningFlags(iClient);
		
		// Half-Zatoichi nerf code.
		int iKatanaHealthGain = GetConVarInt(g_cvHalfZatoichiHealthGain);
		if (iKatanaHealthGain >= 0)
		{
			int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
			if (iAttacker > 0)
			{
				if (!IsClientInPvP(iAttacker) && (!g_bPlayerEliminated[iAttacker] || g_bPlayerProxy[iAttacker]))
				{
					char sWeapon[64];
					GetEventString(event, "weapon",sWeapon,sizeof(sWeapon));
					
					if (strcmp(sWeapon, "demokatana") == 0)
					{
						int iAttackerPreHealth = GetEntProp(iAttacker, Prop_Send, "m_iHealth");
						Handle hPack = CreateDataPack();
						WritePackCell(hPack, GetClientUserId(iAttacker));
						WritePackCell(hPack, iAttackerPreHealth + iKatanaHealthGain);
						
						CreateTimer(0.0, Timer_SetPlayerHealth, hPack, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
		
		g_hPlayerPostWeaponsTimer[iClient] = INVALID_HANDLE;
		g_hPlayerIgniteTimer[iClient] = INVALID_HANDLE;
		g_hPlayerResetIgnite[iClient] = INVALID_HANDLE;
		g_hPlayerPageRewardTimer[iClient] = INVALID_HANDLE;
		g_hPlayerPageRewardCycleTimer[iClient] = INVALID_HANDLE;
		g_hPlayerFireworkTimer[iClient] = INVALID_HANDLE;
		
		g_bPlayerGettingPageReward[iClient] = false;
		g_iPlayerHitsToCrits[iClient] = 0;
		g_iPlayerHitsToHeads[iClient] = 0;
		
		g_bPlayerTrapped[iClient] = false;
		g_iPlayerTrapCount[iClient] = 0;

		g_iPlayerRandomClassNumber[iClient] = 1;
	}
	if (!IsRoundEnding() && !g_bRoundWaitingForPlayers)
	{
		int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		if (!g_bRoundGrace && iClient != iAttacker)
		{
			//Copy the data
			char sString[64];
			Handle event2 = CreateEvent("player_death", true);
			SetEventInt(event2, "userid",GetEventInt(event, "userid"));
			SetEventInt(event2, "victim_entindex",GetEventInt(event, "victim_entindex"));
			SetEventInt(event2, "inflictor_entindex",GetEventInt(event, "inflictor_entindex"));
			SetEventInt(event2, "attacker",GetEventInt(event, "attacker"));
			SetEventInt(event2, "weaponid",GetEventInt(event, "weaponid"));
			SetEventInt(event2, "damagebits",GetEventInt(event, "damagebits"));
			SetEventInt(event2, "customkill",GetEventInt(event, "customkill"));
			SetEventInt(event2, "assister",GetEventInt(event, "assister"));
			SetEventInt(event2, "stun_flags",GetEventInt(event, "stun_flags"));
			SetEventInt(event2, "death_flags",GetEventInt(event, "death_flags"));
			SetEventBool(event2, "silent_kill",GetEventBool(event, "silent_kill"));
			SetEventInt(event2, "playerpenetratecount",GetEventInt(event, "playerpenetratecount"));
			SetEventInt(event2, "kill_streak_total",GetEventInt(event, "kill_streak_total"));
			SetEventInt(event2, "kill_streak_wep",GetEventInt(event, "kill_streak_wep"));
			SetEventInt(event2, "kill_streak_assist",GetEventInt(event, "kill_streak_assist"));
			SetEventInt(event2, "kill_streak_victim",GetEventInt(event, "kill_streak_victim"));
			SetEventInt(event2, "ducks_streaked",GetEventInt(event, "ducks_streaked"));
			SetEventInt(event2, "duck_streak_total",GetEventInt(event, "duck_streak_total"));
			SetEventInt(event2, "duck_streak_assist",GetEventInt(event, "duck_streak_assist"));
			SetEventInt(event2, "duck_streak_victim",99);
			SetEventBool(event2, "rocket_jump",GetEventBool(event, "rocket_jump"));
			SetEventInt(event2, "weapon_def_index",GetEventInt(event, "weapon_def_index"));
			GetEventString(event, "weapon_logclassname",sString,sizeof(sString));
			SetEventString(event2, "weapon_logclassname",sString);
			GetEventString(event, "assister_fallback",sString,sizeof(sString));
			SetEventString(event2, "assister_fallback",sString);
			GetEventString(event, "weapon",sString,sizeof(sString));
			SetEventString(event2, "weapon",sString);
			
			CreateTimer(0.2, Timer_SendDeath, event2, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if (SF_IsBoxingMap() && IsRoundInEscapeObjective())
	{
		CreateTimer(0.2, Timer_CheckAlivePlayers, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	PvP_OnPlayerDeath(iClient, bFake);

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("EVENT END: Event_PlayerDeath(%d)", iClient);
#endif
	delete event;
}

public Action Timer_SendDeath(Handle timer, Handle event)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient > 0)
	{
		//Send it to the clients
		FireEvent(event);
	}
}

public Action Timer_RevertSourceTVBotName(Handle timer)
{
	g_hTimerChangeSourceTVBotName = INVALID_HANDLE;
	int iSourceTV = GetClientOfUserId(g_iSourceTVUserID);
	if (MaxClients >= iSourceTV > 0 && IsClientInGame(iSourceTV) && IsClientSourceTV(iSourceTV))
	{
		//TF2_ChangePlayerName(iSourceTV, g_sOldSourceTVClientName, true);
		SetClientName(iSourceTV, g_sOldSourceTVClientName);
		SetEntPropString(iSourceTV, Prop_Data, "m_szNetname", g_sOldSourceTVClientName);
	}
	return Plugin_Continue;
}

public Action Timer_CheckAlivePlayers(Handle timer)
{
	if (!g_bEnabled || !SF_IsBoxingMap()) return Plugin_Continue;
	
	int iClients[MAXPLAYERS + 1];
	int iClientsNum;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsClientInGame(i) || g_bPlayerEliminated[i]) continue;

		iClients[iClientsNum] = i;
		iClientsNum++;
	}
	
	switch (iClientsNum)
	{
		case 1:
		{
			for (int i = 0; i < iClientsNum; i++)
			{
				int iClient = iClients[i];
				TF2_AddCondition(iClient, TFCond_HalloweenCritCandy, -1.0);
			}
			if (!g_bPlayersAreCritted)
			{
				if (g_iRoundTime > 120)
				{
					SetRoundTime(120);
					CPrintToChatAll("Only 1 {red}RED{default} player is alive, 2 minutes left on the timer...");
					for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
					{	
						if (NPCGetUniqueID(iNPCIndex) == -1) continue;
						NPCSetAddSpeed(iNPCIndex, 50.0);
						NPCSetAddMaxSpeed(iNPCIndex, 75.0);
					}
					g_bPlayersAreCritted = true;
				}
				else
				{
					CPrintToChatAll("Only 1 {red}RED{default} player is alive...");
					for (int iNPCIndex = 0; iNPCIndex < MAX_BOSSES; iNPCIndex++)
					{	
						if (NPCGetUniqueID(iNPCIndex) == -1) continue;
						NPCSetAddSpeed(iNPCIndex, 50.0);
						NPCSetAddMaxSpeed(iNPCIndex, 75.0);
					}
					g_bPlayersAreCritted = true;
				}
			}
		}
		case 2, 3:
		{
			if (!g_bPlayersAreMiniCritted)
			{
				if (g_iRoundTime > 200)
				{
					SetRoundTime(200);
					CPrintToChatAll("3 {red}RED{default} players are alive, 3 minutes and 20 seconds left on the timer...");
					for (int i = 0; i < iClientsNum; i++)
					{
						int iClient = iClients[i];
						TF2_AddCondition(iClient, TFCond_Buffed, -1.0);
					}
					g_bPlayersAreMiniCritted = true;
				}
				else
				{
					CPrintToChatAll("3 {red}RED{default} players are alive...");
					for (int i = 0; i < iClientsNum; i++)
					{
						int iClient = iClients[i];
						TF2_AddCondition(iClient, TFCond_Buffed, -1.0);
					}
					g_bPlayersAreMiniCritted = true;
				}
			}
		}
		default:
		{
			for (int i = 0; i < iClientsNum; i++)
			{
				int iClient = iClients[i];
				TF2_RemoveCondition(iClient, TFCond_Buffed);
				TF2_RemoveCondition(iClient, TFCond_HalloweenCritCandy);
			}
			g_bPlayersAreCritted = false;
			g_bPlayersAreMiniCritted = false;
		}
	}
	return Plugin_Continue;
}

public Action Timer_ReplacePlayerRagdoll(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Continue;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Continue;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iDeathType = GetRandomInt(1, 8);
		switch (iDeathType)
		{
			case 1:
			{
				velocity[0] = 40.0; 
				velocity[1] = 40.0;
				velocity[2] = 40.0;
				force[0] = 40.0; 
				force[1] = 40.0;
				force[2] = 40.0;
				ScaleVector(velocity, 10000.0);
				ScaleVector(force, 10000.0);
				velocity[0] = 0.0;
				velocity[1] = 0.0;
				force[0] = 0.0;
				force[1] = 0.0;
				SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bGib", true);
			}
			case 3:
			{
				SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", true);
			}
			case 4:
			{
				SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			}
			case 5:
			{
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			}
			case 6:
			{
				SetEntProp(ent, Prop_Send, "m_bBurning", true);
			}
			case 7:
			{
				SetEntProp(ent, Prop_Send, "m_bElectrocuted", true);
			}
			case 8:
			{
				velocity[0] = 40.0; 
				velocity[1] = 40.0;
				velocity[2] = 40.0;
				force[0] = 40.0; 
				force[1] = 40.0;
				force[2] = 40.0;
				MakeVectorFromPoints(pos, view_as<float>({0.0, 0.0, 0.0}), velocity);
				ScaleVector(velocity, 20000.0);
				ScaleVector(force, 20000.0);
				SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	RemoveEntity(ragdoll);
	return Plugin_Continue;
}

public Action Timer_IceRagdoll(Handle timer, any userid)
{

	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Continue;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Continue;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iIce = GetRandomInt(1, 2);
		switch (iIce)
		{
			case 1:
			{
				SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	AcceptEntityInput(ragdoll, "Kill", -1, -1, 0);
	return Plugin_Continue;
}

public Action Timer_AshRagdoll(Handle timer, any userid)
{

	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Continue;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Continue;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iAsh = GetRandomInt(1, 2);
		switch (iAsh)
		{
			case 1:
			{
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	AcceptEntityInput(ragdoll, "Kill", -1, -1, 0);
	return Plugin_Continue;
}

public Action Timer_ModifyRagdoll(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Continue;
	}
	int iSlender = EntRefToEntIndex(g_iPlayerBossKillSubject[client]);
	if (!iSlender || iSlender == INVALID_ENT_REFERENCE) return Plugin_Continue;
	int iBossIndex = NPCGetFromEntIndex(iSlender);
	if (iBossIndex == -1) return Plugin_Continue;
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(iBossIndex, sProfile, sizeof(sProfile));
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Continue;
	}
	if (!g_bSlenderHasDeleteKillEffect[iBossIndex])
	{
		int ent = CreateEntityByName("tf_ragdoll", -1);
		if (ent != -1)
		{
			float pos[3], ang[3], velocity[3], force[3];
			GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
			GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
			GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
			GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
			TeleportEntity(ent, pos, ang, NULL_VECTOR);
			SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
			if (g_bSlenderHasPushRagdollOnKill[iBossIndex])
			{
				float flForce[3];
				GetProfileVector(sProfile, "push_ragdoll_force", flForce);
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", flForce);
				SetEntPropVector(ent, Prop_Send, "m_vecForce", flForce);
			}
			else
			{
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
				SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
			}
			if (g_bSlenderHasResizeRagdollOnKill[iBossIndex])
			{
				SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", g_flSlenderResizeRagdollHead[iBossIndex]);
				SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", g_flSlenderResizeRagdollTorso[iBossIndex]);
				SetEntPropFloat(ent, Prop_Send, "m_flHandScale", g_flSlenderResizeRagdollHands[iBossIndex]);
			}
			else
			{
				SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
				SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
				SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
			}
			SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
			SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));

			if (g_bSlenderHasCloakKillEffect[iBossIndex]) SetEntProp(ent, Prop_Send, "m_bCloaked", true);
			else SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));

			SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
			SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
			SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
			SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
			SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));

			if (g_bSlenderHasGibKillEffect[iBossIndex]) SetEntProp(ent, Prop_Send, "m_bGib", true);
			else SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));

			if (g_bSlenderHasDecapKillEffect[iBossIndex]) SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_DECAPITATION);
			else if (g_bSlenderHasPlasmaRagdollOnKill[iBossIndex]) SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_PLASMA);
			else SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));

			if (g_bSlenderHasBurnKillEffect[iBossIndex]) SetEntProp(ent, Prop_Send, "m_bBurning", true);
			else SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));

			if (g_bSlenderHasDisintegrateKillEffect[iBossIndex] || g_bSlenderHasAshKillEffect[iBossIndex])
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			else SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));

			if (g_bSlenderHasGoldKillEffect[iBossIndex]) SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", true);
			else SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));

			if (g_bSlenderHasIceKillEffect[iBossIndex]) SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			else SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));

			if (g_bSlenderHasElectrocuteKillEffect[iBossIndex]) SetEntProp(ent, Prop_Send, "m_bElectrocuted", true);
			else SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));

			DispatchSpawn(ent);
			ActivateEntity(ent);
			SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
		}
		if (g_bSlenderHasDissolveRagdollOnKill[iBossIndex])
		{
			int dissolver = CreateEntityByName("env_entity_dissolver");
			if (!IsValidEntity(dissolver))
			{
				return Plugin_Continue;
			}
			char sType[2];
			int iType = g_iSlenderDissolveRagdollType[iBossIndex];
			IntToString(iType, sType, sizeof(sType));
			DispatchKeyValue(dissolver, "dissolvetype", sType);
			DispatchKeyValue(dissolver, "magnitude", "1");
			DispatchKeyValue(dissolver, "target", "!activator");

			AcceptEntityInput(dissolver, "Dissolve", ent);
			RemoveEntity(dissolver);
		}
	}
	RemoveEntity(ragdoll);
	return Plugin_Continue;
}

public Action Timer_SetPlayerHealth(Handle timer, any data)
{
	Handle hPack = view_as<Handle>(data);
	ResetPack(hPack);
	int iAttacker = GetClientOfUserId(ReadPackCell(hPack));
	int iHealth = ReadPackCell(hPack);
	delete hPack;
	
	if (iAttacker <= 0) return;
	
	SetEntProp(iAttacker, Prop_Data, "m_iHealth", iHealth);
	SetEntProp(iAttacker, Prop_Send, "m_iHealth", iHealth);
}

public Action Timer_PlayerSwitchToBlue(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	
	if (timer != g_hPlayerSwitchBlueTimer[iClient]) return;
	if (g_cvIgnoreRedPlayerDeathSwap.BoolValue) return;
	
	ChangeClientTeam(iClient, TFTeam_Blue);
}

public int ProjectileGetFlags(int iProjectile)
{
	return g_iProjectileFlags[iProjectile];
}

void ProjectileSetFlags(int iProjectile,int iFlags)
{
	g_iProjectileFlags[iProjectile] = iFlags;
}

stock int AttachParticle(int entity, char[] particleType, float posOffset[3] = {0.0, 0.0, 0.0})
{
	int particle = CreateEntityByName("info_particle_system");
	
	if(IsValidEntity(particle))
	{
		SetEntPropEnt(particle, Prop_Data, "m_hOwnerEntity", entity);
		DispatchKeyValue(particle, "effect_name", particleType);
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", entity, particle, 0);
		float vec_start[3];
		TeleportEntity(particle, vec_start, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(particle);
		
		AcceptEntityInput(particle, "start");
		ActivateEntity(particle);
		
		return EntIndexToEntRef(particle);
	}
	return -1;
}

void CreateGeneralParticle(int entity, const char[] sSectionName, float time, float flParticleZPos = 0.0)
{
	if (entity == -1) return;

	float flSlenderPosition[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", flSlenderPosition);
	flSlenderPosition[2] += flParticleZPos;

	int iParticle = CreateEntityByName("info_particle_system");

	char sName[64];

	if (iParticle != -1 && entity != -1)
	{
		TeleportEntity(iParticle, flSlenderPosition, NULL_VECTOR, NULL_VECTOR);

		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));

		DispatchKeyValue(iParticle, "targetname", "tf2particle");
		DispatchKeyValue(iParticle, "parentname", sName);
		DispatchKeyValue(iParticle, "effect_name", sSectionName);
		
		DispatchSpawn(iParticle);
		SetVariantString(sName);

		AcceptEntityInput(iParticle, "SetParent", iParticle, iParticle, 0);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "start");

		CreateTimer(time, Timer_SlenderDeleteParticle, iParticle, TIMER_FLAG_NO_MAPCHANGE);
	}
}
/*
void DestroyEntity(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (entity != -1)
	{
		RemoveEntity(entity);
		ref = INVALID_ENT_REFERENCE;
	}
		
}
*/
public Action Timer_DestroyEntity(Handle timer, any entref)
{
	int iEnt = EntRefToEntIndex(entref);
	if (iEnt != INVALID_ENT_REFERENCE)
	{
		RemoveEntity(iEnt);
	}
	return Plugin_Continue;
}

public Action Timer_RoundStart(Handle timer)
{
	if (g_iPageMax > 0)
	{
		Handle hArrayClients = CreateArray();
		int iClients[MAXPLAYERS + 1];
		int iClientsNum = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i) || g_bPlayerEliminated[i]) continue;
			
			PushArrayCell(hArrayClients, GetClientUserId(i));
			iClients[iClientsNum] = i;
			iClientsNum++;
		}
		
		// Show difficulty menu.
		if (!SF_IsBoxingMap() && !SF_IsRenevantMap() && !SF_SpecialRound(SPECIALROUND_HYPERSNATCHER) && !SF_SpecialRound(SPECIALROUND_MODBOSSES))
		{
			if (iClientsNum)
			{
				// Automatically set it to Normal.
				SetConVarInt(g_cvDifficulty, Difficulty_Normal);
				
				g_hVoteTimer = CreateTimer(1.0, Timer_VoteDifficulty, hArrayClients, TIMER_REPEAT);
				TriggerTimer(g_hVoteTimer, true);
				
				int iGameText = -1;
				char sMessage[512];

				if (g_GamerulesEntity.IsValid() && g_GamerulesEntity.IntroTextEntity.IsValid())
				{
					// Do nothing; already being handled.
				}
				else if ((iGameText = GetTextEntity("sf2_intro_message", false)) != -1)
				{
					GetEntPropString(iGameText, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameText, g_hHudSync, sMessage);
				}
				else
				{
					for (int i = 0; i < iClientsNum; i++)
					{
						int iClient = iClients[i];
						FormatEx(sMessage, sizeof(sMessage), "%T", g_iPageMax > 1 ? "SF2 Default Intro Message Plural" : "SF2 Default Intro Message Singular", iClient, g_iPageMax);
						ClientShowMainMessage(iClient, sMessage);
					}
				}
			}
			else
			{
				delete hArrayClients;
			}
		}
		else
		{
			delete hArrayClients;
		}
	}
}

public Action Timer_CheckRoundWinConditions(Handle timer)
{
	CheckRoundWinConditions();
}

public Action Timer_RoundGrace(Handle timer)
{
	if (timer != g_hRoundGraceTimer) return;
	
	SetGracePeriodState(false);
	g_hRoundGraceTimer = INVALID_HANDLE;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientParticipating(i)) g_bPlayerEliminated[i] = true;
		if(IsValidClient(i))
			TF2Attrib_RemoveByDefIndex(i, 10);
	}
	
	// Initialize the main round timer.
	if (g_iRoundTimeLimit > 0)
	{
		// Set round time.
		SetRoundTime(g_iRoundTimeLimit);
		g_hRoundTimer = CreateTimer(1.0, Timer_RoundTime, _, TIMER_REPEAT);
	}
	else
	{
		// Infinite round time.
		g_hRoundTimer = INVALID_HANDLE;
	}
	
	CPrintToChatAll("{dodgerblue}%t", "SF2 Grace Period End");
}

public Action Timer_RoundTime(Handle timer)
{
	if (timer != g_hRoundTimer) return Plugin_Stop;
	
	if (g_iRoundTime <= 0)
	{
		//The round ended trigger a security timer.
		SF_FailEnd();
		SF_FailRoundEnd(2.0);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_bPlayerEliminated[i] || IsClientInGhostMode(i)) continue;
			
			float flBuffer[3];
			GetClientAbsOrigin(i, flBuffer);
			ClientStartDeathCam(i, 0, flBuffer);
			g_bPlayerDied1Up[i] = false;
			g_bPlayerIn1UpCondition[i] = false;
			KillClient(i);
		}
		
		return Plugin_Stop;
	}

	if (SF_SpecialRound(SPECIALROUND_REVOLUTION))
	{
		if (g_iSpecialRoundTime % 60 == 0)
		{
			SpecialRoundCycleStart();
		}
	}

	if (g_bSpecialRound)
		g_iSpecialRoundTime++;
	
	SetRoundTime(g_iRoundTime - 1);
	
	if (SF_SpecialRound(SPECIALROUND_REALISM))
	{
		return Plugin_Continue;
	}
	
	int hours, minutes, seconds;
	FloatToTimeHMS(float(g_iRoundTime), hours, minutes, seconds);
	
	SetHudTextParams(-1.0, 0.1, 
		1.0,
		SF2_HUD_TEXT_COLOR_R, SF2_HUD_TEXT_COLOR_G, SF2_HUD_TEXT_COLOR_B, SF2_HUD_TEXT_COLOR_A,
		_,
		_,
		1.5, 1.5);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (g_bPlayerEliminated[i] && !IsClientInGhostMode(i))) continue;
		if(SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
			ShowSyncHudText(i, g_hRoundTimerSync, "%d/%d\n??:??", g_iPageCount, g_iPageMax);
		else
			ShowSyncHudText(i, g_hRoundTimerSync, "%d/%d\n%d:%02d", g_iPageCount, g_iPageMax, minutes, seconds);
	}
	
	return Plugin_Continue;
}

public Action Timer_RoundTimeEscape(Handle timer)
{
	if (timer != g_hRoundTimer) return Plugin_Stop;
	
	if (g_iRoundTime <= 0)
	{
		//The round ended trigger a security timer.
		SF_FailEnd();
		SF_FailRoundEnd(2.0);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_bPlayerEliminated[i] || IsClientInGhostMode(i) || DidClientEscape(i)) continue;
			
			float flBuffer[3];
			GetClientAbsOrigin(i, flBuffer);
			ClientStartDeathCam(i, 0, flBuffer);
			g_bPlayerDied1Up[i] = false;
			g_bPlayerIn1UpCondition[i] = false;
			KillClient(i);
		}
		return Plugin_Stop;
	}
	
	if(SF_SpecialRound(SPECIALROUND_REVOLUTION))
	{
		if(g_iSpecialRoundTime % 60 == 0)
		{
			SpecialRoundCycleStart();
		}
	}
	
	if ((1.0-((float(g_iRoundTime))/(float(g_iRoundEscapeTimeLimit+g_iTimeEscape)))) >= 0.65)
	{
		if (!g_bProxySurvivalRageMode)
		{
			bool bProxyBoss = false;
			for (int iBossIndex = 0; iBossIndex < MAX_BOSSES; iBossIndex++)
			{
				if (NPCGetUniqueID(iBossIndex) == -1) continue;
				
				if (!(NPCGetFlags(iBossIndex) & SFF_PROXIES)) continue;
				
				bProxyBoss = true;
				break;
			}
			
			if (bProxyBoss)
			{
				int iAlivePlayer = 0;
				for (int iClient = 1; iClient <= MaxClients; iClient++)
				{
					if (IsClientInGame(iClient) && IsPlayerAlive(iClient) && !g_bPlayerEliminated[iClient])
					{
						iAlivePlayer++;
					}
				}
				
				if (iAlivePlayer >= (GetMaxPlayersForRound()/2)) //Too many players are still alive... enter rage mode!
				{
					g_bProxySurvivalRageMode = true;
					EmitSoundToAll(PROXY_RAGE_MODE_SOUND);
					EmitSoundToAll(PROXY_RAGE_MODE_SOUND);
				}
			}
		}
	}
	
	int hours, minutes, seconds;
	FloatToTimeHMS(float(g_iRoundTime), hours, minutes, seconds);
	
	SetHudTextParams(-1.0, 0.1, 
		1.0,
		SF2_HUD_TEXT_COLOR_R, 
		SF2_HUD_TEXT_COLOR_G, 
		SF2_HUD_TEXT_COLOR_B, 
		SF2_HUD_TEXT_COLOR_A,
		_,
		_,
		1.5, 1.5);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (g_bPlayerEliminated[i] && !IsClientInGhostMode(i))) continue;
		
		if (!SF_SpecialRound(SPECIALROUND_REALISM))
		{
			char sText[512];
			if (SF_IsBoxingMap())
				FormatEx(sText, sizeof(sText), "%T", "SF2 Default Boxing Message", i);
			else 
			{
				if (SF_IsSurvivalMap() && g_iRoundTime > g_iTimeEscape)
					FormatEx(sText, sizeof(sText), "%T", "SF2 Default Survive Message", i);
				else
					FormatEx(sText, sizeof(sText), "%T", "SF2 Default Escape Message", i);
			}

			char sTimerText[128];
			if (SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
				strcopy(sTimerText, sizeof(sTimerText), "\n??:??");
			else
				FormatEx(sTimerText, sizeof(sTimerText), "\n%d:%02d", minutes, seconds);

			StrCat(sText, sizeof(sText), sTimerText);

			ShowSyncHudText(i, g_hRoundTimerSync, sText);
		}
	}

	if (g_bSpecialRound)
		g_iSpecialRoundTime++;
	
	SetRoundTime(g_iRoundTime - 1);
	
	return Plugin_Continue;
}

public Action Timer_VoteDifficulty(Handle timer, any data)
{
	Handle hArrayClients = view_as<Handle>(data);
	
	if (timer != g_hVoteTimer || IsRoundEnding()) 
	{
		delete hArrayClients;
		return Plugin_Stop;
	}
	
	if (IsVoteInProgress()) return Plugin_Continue; // There's another vote in progess. Wait.
	
	int iClients[MAXPLAYERS + 1] = { -1, ... };
	int iClientsNum;
	for (int i = 0, iSize = GetArraySize(hArrayClients); i < iSize; i++)
	{
		int iClient = GetClientOfUserId(GetArrayCell(hArrayClients, i));
		if (iClient <= 0) continue;
		
		iClients[iClientsNum] = iClient;
		iClientsNum++;
	}
	
	delete hArrayClients;
	
	RandomizeVoteMenu();
	VoteMenu(g_hMenuVoteDifficulty, iClients, iClientsNum, 15);
	
	return Plugin_Stop;
}

static bool Renevant_TryAddBossProfile(char[] sProfile, int iProfileLen, char[] sName, int iNameLen, bool bPlaySpawnSound=true)
{
	if (!GetRandomRenevantBossProfile(sProfile, iProfileLen))
		return false;

	GetProfileString(sProfile, "name", sName, iNameLen);
	if (!sName[0]) strcopy(sName, iNameLen, sProfile);
	AddProfile(sProfile, _, _, _, bPlaySpawnSound);

	return true;
}

static void Renevant_SpawnApollyon()
{
	ArrayList hSpawnPoint = new ArrayList();
	float flTeleportPos[3];
	int ent = -1, iSpawnTeam = 0;
	while ((ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1)
	{
		iSpawnTeam = GetEntProp(ent, Prop_Data, "m_iInitialTeamNum");
		if (iSpawnTeam == TFTeam_Red) 
		{
			hSpawnPoint.Push(ent);
		}
	}

	ent = -1;
	if (hSpawnPoint.Length > 0) ent = hSpawnPoint.Get(GetRandomInt(0,hSpawnPoint.Length-1));

	delete hSpawnPoint;

	if (ent > MaxClients)
	{
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flTeleportPos);
		for(int iNpc = 0;iNpc <= MAX_BOSSES; iNpc++)
		{
			SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(iNpc);
			if (!Npc.IsValid()) continue;
			if (Npc.Flags & SFF_NOTELEPORT)
			{
				continue;
			}
			Npc.UnSpawn();
			SpawnSlender(Npc, flTeleportPos);
		}
	}
}

static void Renevant_BroadcastMessage(const char[] sMessage, ...)
{
	char sFormat[512];
	VFormat(sFormat, sizeof(sFormat), sMessage, 2);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || g_bPlayerEliminated[i]) continue;

		ClientShowRenevantMessage(i, sFormat);
	}
}

enum RenevantWave
{
	RenevantWave_Normal = 0,
	RenevantWave_IncreaseDifficulty,
	RenevantWave_MultiEffect,
	RenevantWave_BaconSpray,
	RenevantWave_DoubleTrouble,
	RenevantWave_DoomBox,
	RenevantWave_Max
}

static void Renevant_DoWaveAction(RenevantWave action)
{
	char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH], sBuffer2[SF2_MAX_PROFILE_NAME_LENGTH], sBuffer3[SF2_MAX_PROFILE_NAME_LENGTH];
	char sName[SF2_MAX_NAME_LENGTH], sName2[SF2_MAX_NAME_LENGTH], sName3[SF2_MAX_NAME_LENGTH];

	char sBroadcastMessage[512]; char sBroadcastBuffer[256];
	FormatEx(sBroadcastMessage, sizeof(sBroadcastMessage), "Wave %d", g_iRenevantWaveNumber);

	int iAddedBossCount = 0;
	if (Renevant_TryAddBossProfile(sBuffer, sizeof(sBuffer), sName, sizeof(sName)))
		iAddedBossCount++;

	if (iAddedBossCount == 1 && action != RenevantWave_DoubleTrouble && action != RenevantWave_DoomBox)
	{
		FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nBoss: %s", sName); 
		StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
	}

	switch (action)
	{
		case RenevantWave_Normal:
		{
		}
		case RenevantWave_IncreaseDifficulty:
		{
			switch (g_cvDifficulty.IntValue)
			{
				case Difficulty_Normal:
				{
					g_cvDifficulty.IntValue = Difficulty_Hard;

					FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nDifficulty set to: %t",  "SF2 Hard Difficulty"); 
					StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
				}
				case Difficulty_Hard:
				{
					g_cvDifficulty.IntValue = Difficulty_Insane;

					FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nDifficulty set to: %t",  "SF2 Insane Difficulty"); 
					StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
				}
				case Difficulty_Insane:
				{
					g_cvDifficulty.IntValue = Difficulty_Nightmare;

					FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nDifficulty set to: %t",  "SF2 Nightmare Difficulty"); 
					StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
				}
				case Difficulty_Nightmare:
				{
					g_cvDifficulty.IntValue = Difficulty_Apollyon;

					g_bBossesChaseEndlessly = true;
					g_bRoundInfiniteSprint = true;
					
					Renevant_SpawnApollyon();

					CPrintToChatAll("The difficulty has been set to: {darkgray}Apollyon{default}!");
					
					for (int i = 0; i < sizeof(g_strSoundNightmareMode)-1; i++)
						EmitSoundToAll(g_strSoundNightmareMode[i]);
					
					SpecialRoundGameText("Apollyon mode!", "leaderboard_streak");

					int iRandomQuote = GetRandomInt(1, 8);
					switch (iRandomQuote)
					{
						case 1:
						{
							EmitSoundToAll(HYPERSNATCHER_NIGHTAMRE_1);
							CPrintToChatAll("{purple}Snatcher{default}: Oh no! You're not slipping out of your contract THAT easily.");
						}
						case 2:
						{
							EmitSoundToAll(HYPERSNATCHER_NIGHTAMRE_2);
							CPrintToChatAll("{purple}Snatcher{default}: You ready to die some more? Great!");
						}
						case 3:
						{
							EmitSoundToAll(HYPERSNATCHER_NIGHTAMRE_3);
							CPrintToChatAll("{purple}Snatcher{default}: Live fast, die young, and leave behind a pretty corpse, huh? At least you got two out of three right.");
						}
						case 4:
						{
							EmitSoundToAll(HYPERSNATCHER_NIGHTAMRE_4);
							CPrintToChatAll("{purple}Snatcher{default}: I love the smell of DEATH in the morning.");
						}
						case 5:
						{
							EmitSoundToAll(HYPERSNATCHER_NIGHTAMRE_5);
							CPrintToChatAll("{purple}Snatcher{default}: Oh ho ho! I hope you don't think one measely death gets you out of your contract. We're only getting started.");
						}
						case 6:
						{
							EmitSoundToAll(SNATCHER_APOLLYON_1);
							CPrintToChatAll("{purple}Snatcher{default}: Ah! It gets better every time!");
						}
						case 7:
						{
							EmitSoundToAll(SNATCHER_APOLLYON_2);
							CPrintToChatAll("{purple}Snatcher{default}: Hope you enjoyed that one kiddo, because theres a lot more where that came from!");
						}
						case 8:
						{
							EmitSoundToAll(SNATCHER_APOLLYON_3);
							CPrintToChatAll("{purple}Snatcher{default}: Killing you is hard work, but it pays off. HA HA HA HA HA HA HA HA HA HA");
						}
					}
				}
			}
		}
		case RenevantWave_MultiEffect:
		{
			g_bRenevantMultiEffect = true;
			StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), "\nBosses can now inflict Multieffect.");
		}
		case RenevantWave_BaconSpray:
		{
			g_bRenevantBeaconEffect = true;
			StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), "\nBosses are now alerted on spawn.");
		}
		case RenevantWave_DoubleTrouble:
		{
			if (Renevant_TryAddBossProfile(sBuffer2, sizeof(sBuffer2), sName2, sizeof(sName2)))
				iAddedBossCount++;

			if (iAddedBossCount == 1)
			{
				FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nBoss: %s", sName); 
				StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
			}
			else if (iAddedBossCount == 2)
			{
				FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nBosses: %s and %s", sName, sName2); 
				StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
			}
		}
		case RenevantWave_DoomBox:
		{
			if (Renevant_TryAddBossProfile(sBuffer2, sizeof(sBuffer2), sName2, sizeof(sName2)))
				iAddedBossCount++;
			if (Renevant_TryAddBossProfile(sBuffer3, sizeof(sBuffer3), sName3, sizeof(sName3)))
				iAddedBossCount++;

			if (iAddedBossCount == 1)
			{
				FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nBoss: %s", sName); 
				StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
			}
			else if (iAddedBossCount == 2)
			{
				FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nBosses: %s and %s", sName, sName2); 
				StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
			}
			else if (iAddedBossCount == 3)
			{
				FormatEx(sBroadcastBuffer, sizeof(sBroadcastBuffer), "\nBosses: %s, %s, and %s", sName, sName2, sName3); 
				StrCat(sBroadcastMessage, sizeof(sBroadcastMessage), sBroadcastBuffer);
			}
		}
	}

	Renevant_BroadcastMessage(sBroadcastMessage);
}

void Renevant_SetWave(int iWave, bool bResetTimer=false)
{
	if (!SF_IsRenevantMap() || g_iRenevantWaveNumber == iWave)
		return;
	
	g_iRenevantWaveNumber = iWave;

	if (bResetTimer && iWave < RENEVANT_MAXWAVES && iWave != 0)
	{
		float flTime = ((float(g_iRoundEscapeTimeLimit) - float(g_iRenevantFinaleTime)) / RENEVANT_MAXWAVES);
		g_hRenevantWaveTimer = CreateTimer(flTime, Timer_RenevantWave, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	if (iWave == 0 || iWave >= RENEVANT_MAXWAVES)
		g_hRenevantWaveTimer = INVALID_HANDLE; // At zero/max wave so stop it.

	switch (g_iRenevantWaveNumber)
	{
		case 1: //Wave 1
		{
			g_cvDifficulty.IntValue = Difficulty_Normal;

			Renevant_DoWaveAction(RenevantWave_Normal);

			CPrintToChatAll("The difficulty has been set to {yellow}%t{default}.", "SF2 Normal Difficulty");
		}
		case 2: //Wave 2
		{
			int iRandomWave = GetRandomInt(0, 2);
			switch (iRandomWave)
			{
				case 0:
				{
					Renevant_DoWaveAction(RenevantWave_Normal);
				}
				case 1:
				{
					Renevant_DoWaveAction(RenevantWave_IncreaseDifficulty);		
				}
				case 2:
				{
					Renevant_DoWaveAction(RenevantWave_MultiEffect);
				}
			}
		}
		case 3: //Wave 3
		{
			int iRandomWave = GetRandomInt(0, 3);
			switch (iRandomWave)
			{
				case 0:
				{
					Renevant_DoWaveAction(RenevantWave_Normal);
				}
				case 1:
				{
					Renevant_DoWaveAction(RenevantWave_DoubleTrouble);
				}
				case 2:
				{
					Renevant_DoWaveAction(RenevantWave_IncreaseDifficulty);
				}
				case 3:
				{
					Renevant_DoWaveAction(RenevantWave_BaconSpray);
				}
			}
		}
		case 4: //Wave 4
		{
			int iRandomWave = GetRandomInt(0, 2);
			switch (iRandomWave)
			{
				case 0:
				{
					Renevant_DoWaveAction(RenevantWave_Normal);
				}
				case 1:
				{
					Renevant_DoWaveAction(RenevantWave_DoubleTrouble);
				}
				case 2:
				{
					Renevant_DoWaveAction(RenevantWave_IncreaseDifficulty);
				}
			}
		}
		case 5: //Wave 5
		{
			int iRandomWave = GetRandomInt(0, 3);
			switch (iRandomWave)
			{
				case 0:
				{
					Renevant_DoWaveAction(RenevantWave_Normal);
				}
				case 1:
				{
					Renevant_DoWaveAction(RenevantWave_DoubleTrouble);
				}
				case 2:
				{
					Renevant_DoWaveAction(RenevantWave_IncreaseDifficulty);
				}
				case 3:
				{
					Renevant_DoWaveAction(RenevantWave_DoomBox);
				}
			}
		}
	}

	SF2MapEntity_OnRenevantWaveTriggered(g_iRenevantWaveNumber);

	Call_StartForward(fOnRenevantTriggerWave);
	Call_PushCell(g_iRenevantWaveNumber);
	Call_Finish();
}

public Action Timer_RenevantWave(Handle timer, any data)
{
	if (timer != g_hRenevantWaveTimer || IsRoundEnding())
		return Plugin_Stop;

	Renevant_SetWave(g_iRenevantWaveNumber + 1);
	
	if (g_iRenevantWaveNumber == RENEVANT_MAXWAVES)
		return Plugin_Stop;
	
	return Plugin_Continue;
}

void SF_FailRoundEnd(float time=2.0)
{
	//Check round win conditions again.
	CreateTimer((time-0.8), Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
	
	if (!g_cvIgnoreRoundWinConditions.BoolValue)
	{
		g_hTimerFail = CreateTimer(time, Timer_Fail, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

void SF_FailEnd()
{
	if (g_hTimerFail != INVALID_HANDLE)
		delete g_hTimerFail;
	g_hTimerFail = INVALID_HANDLE;
}

public Action Timer_Fail(Handle hTimer)
{
	LogSF2Message("Wow you hit a rare bug, where the round doesn't end after the timer ran out. Collecting info on your game...\nContact Mentrillum or The Gaben and give them the following log:");
	int iEscapedPlayers = 0;
	int iClientInGame = 0;
	int iRedPlayers = 0;
	int iBluPlayers = 0;
	int iEliminatedPlayers = 0;
	for (int iClient = 1;iClient <= MaxClients; iClient++)
	{
		if (IsValidClient(iClient))
		{
			iClientInGame++;
			LogSF2Message("Player %N (%i), Team: %d, Eliminated: %d, Escaped: %d.", iClient, iClient, GetClientTeam(iClient), g_bPlayerEliminated[iClient], DidClientEscape(iClient));
			if (GetClientTeam(iClient) == TFTeam_Blue)
				iBluPlayers++;
			else if (GetClientTeam(iClient) == TFTeam_Red)
				iRedPlayers++;
		}
		if (g_bPlayerEliminated[iClient])
		{
			iEliminatedPlayers++;
		}
		if (DidClientEscape(iClient))
		{
			iEscapedPlayers++;
		}
	}
	LogSF2Message("Total clients: %d, Blu players: %d, Red players: %d, Escaped players: %d, Eliminated players: %d", MaxClients, iBluPlayers, iRedPlayers, iEscapedPlayers, iEliminatedPlayers);
	//Force blus to win.
	ForceTeamWin(TFTeam_Blue);
	
	g_hTimerFail = INVALID_HANDLE;

	return Plugin_Stop;
}

/**
 *	Initialize pages and entities.
 */
static void InitializeMapEntities()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START InitializeMapEntities()");
#endif
	
	g_bIsSurvivalMap = false;
	g_bIsBoxingMap = false;
	g_bIsRenevantMap = false;
	g_bIsSlaughterRunMap = false;
	g_bIsRaidMap = false;
	g_bIsProxyMap = false;

	SF2GamerulesEntity gamerules = FindSF2GamerulesEntity();
	g_GamerulesEntity = gamerules;

	if (gamerules.IsValid())
	{
		if (g_iRoundActiveCount == 1)
			g_cvMaxPlayers.SetInt(gamerules.MaxPlayers);

		char sBossName[SF2_MAX_PROFILE_NAME_LENGTH];
		gamerules.GetBossName(sBossName, sizeof(sBossName));
		if (sBossName[0] != '\0') g_cvBossMain.SetString(sBossName);

		g_iPageMax = gamerules.MaxPages;

		g_iRoundTimeLimit = gamerules.InitialTimeLimit;
		g_iRoundTimeGainFromPage = gamerules.PageCollectAddTime;

		gamerules.GetPageCollectSoundPath(g_strPageCollectSound, sizeof(g_strPageCollectSound));
		if (g_strPageCollectSound[0] == '\0')
			strcopy(g_strPageCollectSound, sizeof(g_strPageCollectSound), PAGE_GRABSOUND); // Roll with default instead.

		g_iPageSoundPitch = gamerules.PageCollectSoundPitch;

		g_bRoundHasEscapeObjective = gamerules.HasEscapeObjective;
		g_iRoundEscapeTimeLimit = gamerules.EscapeTimeLimit;
		g_bRoundStopPageMusicOnEscape = gamerules.StopPageMusicOnEscape;
		g_bIsSurvivalMap = gamerules.Survive;
		g_iTimeEscape = gamerules.SurviveUntilTime;

		g_bRoundInfiniteFlashlight = gamerules.InfiniteFlashlight;
		g_bRoundInfiniteSprint = gamerules.InfiniteSprint;
		g_bRoundInfiniteBlink = gamerules.InfiniteBlink;

		g_bBossesChaseEndlessly = gamerules.BossesChaseEndlessly;

		gamerules.GetIntroMusicPath(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic));
		if (g_strRoundIntroMusic[0] == '\0') 
			strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), SF2_INTRO_DEFAULT_MUSIC); // Roll with default instead.
		
		gamerules.GetIntroFadeColor(g_iRoundIntroFadeColor);
		g_flRoundIntroFadeHoldTime = gamerules.IntroFadeHoldTime;
		g_flRoundIntroFadeDuration = gamerules.IntroFadeTime;
	}
	else 
	{
		g_iRoundTimeLimit = g_cvTimeLimit.IntValue;
		g_iRoundTimeGainFromPage = g_cvTimeGainFromPageGrab.IntValue;
		strcopy(g_strPageCollectSound, sizeof(g_strPageCollectSound), PAGE_GRABSOUND);
		g_iPageSoundPitch = 100;

		g_bRoundHasEscapeObjective = false;
		g_iRoundEscapeTimeLimit = g_cvTimeLimitEscape.IntValue;
		g_bRoundStopPageMusicOnEscape = false;
		g_iTimeEscape = g_cvTimeEscapeSurvival.IntValue;

		g_bRoundInfiniteFlashlight = false;
		g_bRoundInfiniteSprint = false;
		g_bRoundInfiniteBlink = false;

		g_bBossesChaseEndlessly = false;

		strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), SF2_INTRO_DEFAULT_MUSIC);

		g_iRoundIntroFadeColor[0] = 0;
		g_iRoundIntroFadeColor[1] = 0;
		g_iRoundIntroFadeColor[2] = 0;
		g_iRoundIntroFadeColor[3] = 255;
		g_flRoundIntroFadeHoldTime = g_cvIntroDefaultHoldTime.FloatValue;
		g_flRoundIntroFadeDuration = g_cvIntroDefaultFadeTime.FloatValue;
	}

	// Check the game type.
	if (FindLogicProxyEntity().IsValid())
	{
		g_bIsProxyMap = true;
		g_bIsSurvivalMap = true;
	}
	else if (FindLogicRaidEntity().IsValid())
	{
		g_bIsRaidMap = true;
	}
	else if (FindLogicBoxingEntity().IsValid())
	{
		g_bIsBoxingMap = true;
	}
	else if (FindLogicSlaughterEntity().IsValid())
	{
		g_bIsSlaughterRunMap = true;
	}
	else if ((g_RenevantLogicEntity = FindLogicRenevantEntity()).IsValid())
	{
		g_bIsRenevantMap = true;
	}

	if (SF_IsRenevantMap())
	{
		if (g_RenevantLogicEntity.IsValid())
		{
			g_iRenevantFinaleTime = g_RenevantLogicEntity.FinaleTime;
		}
		else 
		{
			g_iRenevantFinaleTime = 60;
		}
	}

	char targetName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0] == '\0')
			continue;

		if (!StrContains(targetName, "sf2_maxpages_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_maxpages_", "", false);
			g_iPageMax = StringToInt(targetName);
		}
		else if (!StrContains(targetName, "sf2_logic_escape", false) || !StrContains(targetName, "sf2_logic_escape_hyper", false))
		{
			g_bRoundHasEscapeObjective = true;
		}
		else if (strcmp(targetName, "sf2_escape_custommusic", false) == 0)
		{
			g_bRoundStopPageMusicOnEscape = true;
		}
		else if (!StrContains(targetName, "sf2_infiniteflashlight", false))
		{
			g_bRoundInfiniteFlashlight = true;
		}
		else if (!StrContains(targetName, "sf2_infiniteblink", false))
		{
			g_bRoundInfiniteBlink = true;
		}
		else if (!StrContains(targetName, "sf2_infinitesprint", false))
		{
			g_bRoundInfiniteSprint = true;
		}
		else if (!StrContains(targetName, "sf2_time_limit_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_time_limit_", "", false);
			g_iRoundTimeLimit = StringToInt(targetName);
			
			LogSF2Message("Found sf2_time_limit entity, set time limit to %d", g_iRoundTimeLimit);
		}
		else if (!StrContains(targetName, "sf2_escape_time_limit_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_escape_time_limit_", "", false);
			g_iRoundEscapeTimeLimit = StringToInt(targetName);
			
			LogSF2Message("Found sf2_escape_time_limit entity, set escape time limit to %d", g_iRoundEscapeTimeLimit);
		}
		else if (!StrContains(targetName, "sf2_time_gain_from_page_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_time_gain_from_page_", "", false);
			g_iRoundTimeGainFromPage = StringToInt(targetName);
			
			LogSF2Message("Found sf2_time_gain_from_page entity, set time gain to %d", g_iRoundTimeGainFromPage);
		}
		else if (g_iRoundActiveCount == 1 && (!StrContains(targetName, "sf2_maxplayers_", false)))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_maxplayers_", "", false);
			SetConVarInt(g_cvMaxPlayers, StringToInt(targetName));
			
			LogSF2Message("Found sf2_maxplayers entity, set maxplayers to %d", StringToInt(targetName));
		}
		else if (!StrContains(targetName, "sf2_boss_override_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_boss_override_", "", false);
			SetConVarString(g_cvBossProfileOverride, targetName);
			
			LogSF2Message("Found sf2_boss_override entity, set boss profile override to %s", targetName);
		}
		else if (!StrContains(targetName, "sf2_survival_map", false))
		{
			g_bIsSurvivalMap = true;
		}
		else if (!StrContains(targetName, "sf2_raid_map", false))
		{
			g_bIsRaidMap = true;
		}
		else if (!StrContains(targetName, "sf2_bosses_chase_endlessly", false))
		{
			g_bBossesChaseEndlessly = true;
		}
		else if (!StrContains(targetName, "sf2_proxy_map", false))
		{
			g_bIsProxyMap = true;
			g_bIsSurvivalMap = true;
		}
		else if (!StrContains(targetName, "sf2_boxing_map", false))
		{
			g_bIsBoxingMap = true;
		}
		else if (!StrContains(targetName, "sf2_survival_time_limit_", false))
		{
			ReplaceString(targetName, sizeof(targetName), "sf2_survival_time_limit_", "", false);
			g_iTimeEscape = StringToInt(targetName);
			
			LogSF2Message("Found sf2_survival_time_limit_ entity, set survival time limit to %d", g_iTimeEscape);
		}
		else if (!StrContains(targetName, "sf2_renevant_map", false))
		{
			g_bIsRenevantMap = true;
		}
		else if (!StrContains(targetName, "sf2_slaughterrun_map", false))
		{
			g_bIsSlaughterRunMap = true;
		}
	}

	ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0] == '\0')
			continue;
		
		if (strcmp(targetName, "sf2_page_sound", false) == 0)
		{
			char sPagePath[PLATFORM_MAX_PATH];
			GetEntPropString(ent, Prop_Data, "m_iszSound", sPagePath, sizeof(sPagePath));

			if (sPagePath[0] == '\0')
			{
				LogError("Found sf2_page_sound entity, but it has no sound path specified! Default page sound will be used instead.");
			}
			else
			{
				strcopy(g_strPageCollectSound, sizeof(g_strPageCollectSound), sPagePath);
			}
		}
	}

	// For old page spawn points, get the reference entity if it exists.
	g_bPageRef = false;
	strcopy(g_strPageRefModel, sizeof(g_strPageRefModel), PAGE_MODEL);
	g_flPageRefModelScale = 1.0;

	ent = -1;
	while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0] == '\0')
			continue;
		
		if (strcmp(targetName, "sf2_page_model", false) == 0)
		{
			g_bPageRef = true;
			GetEntPropString(ent, Prop_Data, "m_ModelName", g_strPageRefModel, sizeof(g_strPageRefModel));
			g_flPageRefModelScale = GetEntPropFloat(ent, Prop_Send, "m_flModelScale");
			break;
		}
	}

#if defined DEBUG
	LogSF2Message("ROUND SETTINGS:\n - Time limit: %i\n - Time gain from page: %i\n - Page collect sound: %s\n - Escape?: %i\n - Escape time limit: %i\n - Stop page music on escape: %i\n - Survive before escape?: %i\n - Survive until time: %i\n - Infinite flashlight: %i\n - Infinite sprint: %i\n - Infinite blink: %i\n - Bosses chase endlessly: %i\n - Intro music: %s\n - Intro fade hold time: %f\n - Intro fade time: %f",
		g_iRoundTimeLimit, g_iRoundTimeGainFromPage, g_strPageCollectSound, g_bRoundHasEscapeObjective, g_iRoundEscapeTimeLimit, g_bRoundStopPageMusicOnEscape, g_bIsSurvivalMap, g_iTimeEscape, g_bRoundInfiniteFlashlight, g_bRoundInfiniteSprint, g_bRoundInfiniteBlink, g_bBossesChaseEndlessly, g_strRoundIntroMusic, g_flRoundIntroFadeHoldTime, g_flRoundIntroFadeDuration);
#endif

	GetRoundIntroParameters();
	GetRoundEscapeParameters();
	GetPageMusicRanges();
	SpawnPages();

#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END InitializeMapEntities()");
#endif
}

void SpawnPages()
{
	g_hPages.Clear();

	ArrayList hArray = new ArrayList(2);
	StringMap hPageGroupsByName = new StringMap();
	
	ArrayList hPageSpawnPoints = new ArrayList();

	int ent = -1;
	char targetName[64];

	// Collect all possible page spawn points.
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (!StrContains(targetName, "sf2_page_spawnpoint", false))
			{
				hPageSpawnPoints.Push(EnsureEntRef(ent));
			}
		}
	}

	ent = -1;
	while ((ent = FindEntityByClassname(ent, "sf2_info_page_spawn")) != -1)
	{
		SF2PageSpawnEntity pageSpawn = SF2PageSpawnEntity(ent);
		if (pageSpawn.IsValid())
		{
			hPageSpawnPoints.Push(EnsureEntRef(ent));
		}
	}

	if (hPageSpawnPoints.Length > 0)
	{
		// Try to sort spawn points into their respective groups.

		char sPageGroup[64];

		for (int i = 0; i < hPageSpawnPoints.Length; i++)
		{
			int iSpawnPoint = hPageSpawnPoints.Get(i);
			if (!IsValidEntity(iSpawnPoint))
				continue;
			
			// Get page group if possible.
			SF2PageSpawnEntity pageSpawn = SF2PageSpawnEntity(iSpawnPoint);
			if (pageSpawn.IsValid())
			{
				pageSpawn.GetGroup(sPageGroup, sizeof(sPageGroup));
			}
			else
			{
				GetEntPropString(iSpawnPoint, Prop_Data, "m_iName", sPageGroup, sizeof(sPageGroup));

				if (!StrContains(sPageGroup, "sf2_page_spawnpoint_", false))
					ReplaceString(sPageGroup, sizeof(sPageGroup), "sf2_page_spawnpoint_", "", false);
				else
					sPageGroup[0] = '\0';
			}

			if (sPageGroup[0] != '\0')
			{
				// Spawn point belongs to a group.

				ArrayList hButtStallion;
				if (!hPageGroupsByName.GetValue(sPageGroup, hButtStallion))
				{
					// Initialize new page group since it didn't exist.
					hButtStallion = new ArrayList();
					hPageGroupsByName.SetValue(sPageGroup, hButtStallion);

					int iIndex = hArray.Push(hButtStallion);
					hArray.Set(iIndex, true, 1);
				}

				hButtStallion.Push(EnsureEntRef(iSpawnPoint));
			}
			else
			{
				int iIndex = hArray.Push(EnsureEntRef(iSpawnPoint));
				hArray.Set(iIndex, false, 1);
			}
		}
	}
	
	delete hPageSpawnPoints;
	
	int iPageCount = hArray.Length;
	if (iPageCount)
	{
		// Spawn all pages.
		hArray.Sort(Sort_Random, Sort_Integer);
		
		float vecPos[3], vecAng[3];
		int page;
		
		char sPageModel[PLATFORM_MAX_PATH];
		char sPageParentName[64];
		float flPageModelScale;
		int iPageSkin;
		RenderFx iPageRenderFx;
		RenderMode iPageRenderMode;
		int iPageBodygroup;
		int iPageRenderColor[4];
		char sPageAnimation[64];

		for (int i = 0; i < iPageCount && (i + 1) <= g_iPageMax; i++)
		{
			int iSpawnPoint = -1;
			if (view_as<bool>(hArray.Get(i, 1)))
			{
				ArrayList hButtStallion = view_as<ArrayList>(hArray.Get(i));
				iSpawnPoint = hButtStallion.Get(GetRandomInt(0, hButtStallion.Length - 1));
			}
			else
			{
				iSpawnPoint = hArray.Get(i);
			}

			SF2PageSpawnEntity spawnPoint = SF2PageSpawnEntity(iSpawnPoint);
			
			GetEntPropVector(iSpawnPoint, Prop_Data, "m_vecAbsOrigin", vecPos);
			GetEntPropVector(iSpawnPoint, Prop_Data, "m_angAbsRotation", vecAng);
			GetEntPropString(iSpawnPoint, Prop_Data, "m_iParent", sPageParentName, sizeof(sPageParentName));
			
			// Get model, scale, skin, and animation.
			if (spawnPoint.IsValid())
			{
				spawnPoint.GetModel(sPageModel, sizeof(sPageModel));
				flPageModelScale = spawnPoint.ModelScale;
				iPageSkin = spawnPoint.Skin == -1 ? i : spawnPoint.Skin;
				iPageBodygroup = spawnPoint.Bodygroup;
				iPageRenderFx = spawnPoint.RenderFx;
				iPageRenderMode = spawnPoint.RenderMode;
				spawnPoint.GetRenderColor(iPageRenderColor[0], iPageRenderColor[1], iPageRenderColor[2], iPageRenderColor[3]);
				spawnPoint.GetAnimation(sPageAnimation, sizeof(sPageAnimation));
			}
			else if (g_bPageRef)
			{
				strcopy(sPageModel, sizeof(sPageModel), g_strPageRefModel);
				flPageModelScale = g_flPageRefModelScale;
				iPageSkin = i;
				iPageBodygroup = 0;
				iPageRenderFx = RENDERFX_NONE;
				iPageRenderMode = RENDER_NORMAL;
				iPageRenderColor[0] = 255; iPageRenderColor[1] = 255; iPageRenderColor[2] = 255; iPageRenderColor[3] = 255; 
				sPageAnimation[0] = '\0';
			}
			else
			{
				strcopy(sPageModel, sizeof(sPageModel), PAGE_MODEL);
				flPageModelScale = PAGE_MODELSCALE;
				iPageSkin = i;
				iPageBodygroup = 0;
				iPageRenderFx = RENDERFX_NONE;
				iPageRenderMode = RENDER_NORMAL;
				iPageRenderColor[0] = 255; iPageRenderColor[1] = 255; iPageRenderColor[2] = 255; iPageRenderColor[3] = 255; 
				sPageAnimation[0] = '\0';
			}

			// Create fake page model
			char pageName[50];
			int page2 = CreateEntityByName("prop_dynamic_override");
			if (page2 != -1)
			{
				DispatchKeyValue(page2, "targetname", "sf2_page_ex");
				DispatchKeyValue(page2, "parentname", sPageParentName);
				DispatchKeyValue(page2, "solid", "0");
				SetEntityModel(page2, sPageModel);
				TeleportEntity(page2, vecPos, vecAng, NULL_VECTOR);
				DispatchSpawn(page2);
				ActivateEntity(page2);
				SetVariantInt(iPageSkin);
				AcceptEntityInput(page2, "Skin");
				SetVariantInt(iPageBodygroup);
				AcceptEntityInput(page2, "SetBodyGroup");
				AcceptEntityInput(page2, "DisableCollision");
				SetEntPropFloat(page2, Prop_Send, "m_flModelScale", flPageModelScale);
				SetEntityFlags(page2, GetEntityFlags(page2) | FL_EDICT_ALWAYS);
				SetEntityRenderMode(page2, iPageRenderMode);
				SetEntityRenderFx(page2, iPageRenderFx);
				SetEntityRenderColor(page2, iPageRenderColor[0], iPageRenderColor[1], iPageRenderColor[2], iPageRenderColor[3]);

				CreateTimer(1.0, Page_RemoveAlwaysTransmit, EntIndexToEntRef(page2), TIMER_FLAG_NO_MAPCHANGE);
				SDKHook(page2, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmitEx);

				if (sPageAnimation[0] != '\0')
				{
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page2, "SetDefaultAnimation");
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page2, "SetAnimation");
				}
			}

			// Create actual page entity
			page = CreateEntityByName("prop_dynamic_override");
			if (page != -1)
			{
				FormatEx(pageName, sizeof(pageName), "sf2_page_ex_%d", i);
				DispatchKeyValue(page, "targetname", pageName);
				DispatchKeyValue(page, "parentname", sPageParentName);
				DispatchKeyValue(page, "solid", "2");
				SetEntityModel(page, sPageModel);
				TeleportEntity(page, vecPos, vecAng, NULL_VECTOR);
				DispatchSpawn(page);
				ActivateEntity(page);
				SetVariantInt(iPageSkin);
				AcceptEntityInput(page, "Skin");
				SetVariantInt(iPageBodygroup);
				AcceptEntityInput(page, "SetBodyGroup");
				AcceptEntityInput(page, "EnableCollision");
				SetEntPropFloat(page, Prop_Send, "m_flModelScale", flPageModelScale);
				SetEntPropEnt(page, Prop_Send, "m_hOwnerEntity", page2);
				SetEntPropEnt(page, Prop_Send, "m_hEffectEntity", page2);
				SetEntProp(page, Prop_Send, "m_fEffects", EF_ITEM_BLINK);
				SetEntityFlags(page, GetEntityFlags(page) | FL_EDICT_ALWAYS);
				SetEntityRenderMode(page, iPageRenderMode);
				SetEntityRenderFx(page, iPageRenderFx);
				SetEntityRenderColor(page, iPageRenderColor[0], iPageRenderColor[1], iPageRenderColor[2], iPageRenderColor[3]);
				
				CreateTimer(1.0, Page_RemoveAlwaysTransmit, EntIndexToEntRef(page), TIMER_FLAG_NO_MAPCHANGE);
				SDKHook(page, SDKHook_OnTakeDamage, Hook_PageOnTakeDamage);
				SDKHook(page, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmit);

				if (sPageAnimation[0] != '\0')
				{
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page, "SetDefaultAnimation");
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page, "SetAnimation");
				}

				SF2PageEntityData pageData;
				pageData.EntRef = EnsureEntRef(page);
				spawnPoint.GetCollectSound(pageData.CollectSound, PLATFORM_MAX_PATH);
				pageData.CollectSoundPitch = spawnPoint.CollectSoundPitch;

				g_hPages.PushArray(pageData, sizeof(pageData));
			}
		}
		
		// Safely remove all handles.
		for (int i = 0, iSize = hArray.Length; i < iSize; i++)
		{
			if (view_as<bool>(hArray.Get(i, 1)))
			{
				delete view_as<ArrayList>(hArray.Get(i));
			}
		}
	
		Call_StartForward(fOnPagesSpawned);
		Call_Finish();
	}

	delete hPageGroupsByName;
	delete hArray;
}

public Action Page_RemoveAlwaysTransmit(Handle timer, int iRef)
{
	int iPage = EntRefToEntIndex(iRef);
	if (iPage > MaxClients && IsValidEdict(iPage))
	{
		//All the pages are now "registred" by the client, nuke the always transmit flag.
		SetEntityFlags(iPage, GetEntityFlags(iPage)^FL_EDICT_ALWAYS);
	}
}

static bool HandleSpecialRoundState()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START HandleSpecialRoundState()");
#endif
	
	bool bOld = g_bSpecialRound;
	bool bContinuousOld = g_bSpecialRoundContinuous;
	g_bSpecialRound = false;
	g_bSpecialRoundNew = false;
	g_bSpecialRoundContinuous = false;
	
	bool bForceNew = false;
	
	if (bOld)
	{
		if (bContinuousOld)
		{
			// Check if there are players who haven't played the special round yet.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsClientParticipating(i))
				{
					g_bPlayerPlayedSpecialRound[i] = true;
					continue;
				}
				
				if (!g_bPlayerPlayedSpecialRound[i])
				{
					// Someone didn't get to play this yet. Continue the special round.
					g_bSpecialRound = true;
					g_bSpecialRoundContinuous = true;
					break;
				}
			}
		}
	}
	
	int iRoundInterval = GetConVarInt(g_cvSpecialRoundInterval);
	
	if (iRoundInterval > 0 && g_iSpecialRoundCount >= iRoundInterval)
	{
		g_bSpecialRound = true;
		bForceNew = true;
	}
	
	// Do special round force override and reset it.
	if (GetConVarInt(g_cvSpecialRoundForce) >= 0)
	{
		g_bSpecialRound = GetConVarBool(g_cvSpecialRoundForce);
		SetConVarInt(g_cvSpecialRoundForce, -1);
	}
	
	if (g_bSpecialRound)
	{
		if (bForceNew || !bOld || !bContinuousOld)
		{
			g_bSpecialRoundNew = true;
		}
		
		if (g_bSpecialRoundNew)
		{
			if (GetConVarInt(g_cvSpecialRoundBehavior) == 1)
			{
				g_bSpecialRoundContinuous = true;
			}
			else
			{
				// new special round, but it's not continuous.
				g_bSpecialRoundContinuous = false;
			}
		}
	}
	else
	{
		g_bSpecialRoundContinuous = false;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END HandleSpecialRoundState() -> g_bSpecialRound = %d (count = %d, new = %d, continuous = %d)", g_bSpecialRound, g_iSpecialRoundCount, g_bSpecialRoundNew, g_bSpecialRoundContinuous);
#endif
}
/*
bool IsNewBossRoundRunning()
{
	return g_bNewBossRound;
}
*/
/**
 *	Returns an array which contains all the profile names valid to be chosen for a new boss round.
 */
static Handle GetNewBossRoundProfileList()
{
	Handle hBossList = CloneArray(GetSelectableBossProfileQueueList());
	
	if (GetArraySize(hBossList) > 0)
	{
		char sMainBoss[SF2_MAX_PROFILE_NAME_LENGTH];
		GetConVarString(g_cvBossMain, sMainBoss, sizeof(sMainBoss));
		
		int index = FindStringInArray(hBossList, sMainBoss);
		if (index != -1)
		{
			// Main boss exists; remove him from the list.
			RemoveFromArray(hBossList, index);
		}
		/*else
		{
			// Main boss doesn't exist; remove the first boss from the list.
			RemoveFromArray(hBossList, 0);
		}*/
	}
	
	return hBossList;
}

static void HandleNewBossRoundState()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START HandleNewBossRoundState()");
#endif
	
	bool bOld = g_bNewBossRound;
	bool bContinuousOld = g_bNewBossRoundContinuous;
	g_bNewBossRound = false;
	g_bNewBossRoundNew = false;
	g_bNewBossRoundContinuous = false;
	
	bool bForceNew = false;
	
	if (bOld)
	{
		if (bContinuousOld)
		{
			// Check if there are players who haven't played the boss round yet.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsClientParticipating(i))
				{
					g_bPlayerPlayedNewBossRound[i] = true;
					continue;
				}
				
				if (!g_bPlayerPlayedNewBossRound[i])
				{
					// Someone didn't get to play this yet. Continue the boss round.
					g_bNewBossRound = true;
					g_bNewBossRoundContinuous = true;
					break;
				}
			}
		}
	}
	
	// Don't force a new special round while a continuous round is going on.
	if (!g_bNewBossRoundContinuous)
	{
		int iRoundInterval = GetConVarInt(g_cvNewBossRoundInterval);
		
		if (/*iRoundInterval > 0 &&*/ iRoundInterval <= 0 || g_iNewBossRoundCount >= iRoundInterval)
		{
			g_bNewBossRound = true;
			bForceNew = true;
		}
	}
	
	// Do boss round force override and reset it.
	if (GetConVarInt(g_cvNewBossRoundForce) >= 0)
	{
		g_bNewBossRound = GetConVarBool(g_cvNewBossRoundForce);
		SetConVarInt(g_cvNewBossRoundForce, -1);
	}
	
	// Check if we have enough bosses.
	if (g_bNewBossRound)
	{
		Handle hBossList = CloneArray(GetNewBossRoundProfileList());
	
		if (GetArraySize(hBossList) < 1)
		{
			g_bNewBossRound = false; // Not enough bosses.
		}
		
		delete hBossList;
	}
	
	if (g_bNewBossRound)
	{
		if (bForceNew || !bOld || !bContinuousOld)
		{
			g_bNewBossRoundNew = true;
		}
		
		if (g_bNewBossRoundNew)
		{
			if (GetConVarInt(g_cvNewBossRoundBehavior) == 1)
			{
				g_bNewBossRoundContinuous = true;
			}
			else
			{
				// new "new boss round", but it's not continuous.
				g_bNewBossRoundContinuous = false;
			}
		}
	}
	else
	{
		g_bNewBossRoundContinuous = false;
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END HandleintBossRoundState() -> g_bNewBossRound = %d (count = %d, int = %d, continuous = %d)", g_bNewBossRound, g_iNewBossRoundCount, g_bNewBossRoundNew, g_bNewBossRoundContinuous);
#endif
}

/**
 *	Returns the amount of players that are in game and currently not eliminated.
 */
int GetActivePlayerCount()
{
	int count = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsClientParticipating(i)) continue;
		
		if (!g_bPlayerEliminated[i])
		{
			count++;
		}
	}
	
	return count;
}

static void SelectStartingBossesForRound()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START SelectStartingBossesForRound()");
#endif

	Handle hSelectableBossList = CloneArray(GetSelectableBossProfileQueueList());

	// Select which boss profile to use.
	char sProfileOverride[SF2_MAX_PROFILE_NAME_LENGTH];
	GetConVarString(g_cvBossProfileOverride, sProfileOverride, sizeof(sProfileOverride));
	
	if (!SF_IsBoxingMap())
	{
		if (sProfileOverride[0] != '\0' && IsProfileValid(sProfileOverride))
		{
			// Pick the overridden boss.
			strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), sProfileOverride);
			SetConVarString(g_cvBossProfileOverride, "");
		}
		else if (g_bNewBossRound)
		{
			if (g_bNewBossRoundNew)
			{
				Handle hBossList = GetNewBossRoundProfileList();
			
				GetArrayString(hBossList, GetRandomInt(0, GetArraySize(hBossList) - 1), g_strNewBossRoundProfile, sizeof(g_strNewBossRoundProfile));
			
				delete hBossList;
			}
			
			strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), g_strNewBossRoundProfile);
		}
		else
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			GetConVarString(g_cvBossMain, sProfile, sizeof(sProfile));
			
			if (sProfile[0] != '\0' && IsProfileValid(sProfile))
			{
				strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), sProfile);
			}
			else
			{
				if (GetArraySize(hSelectableBossList) > 0)
				{
					// Pick the first boss in our array if the main boss doesn't exist.
					GetArrayString(hSelectableBossList, 0, g_strRoundBossProfile, sizeof(g_strRoundBossProfile));
				}
				else
				{
					// No bosses to pick. What?
					g_strRoundBossProfile[0] = '\0';
				}
			}
		}
		
	#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END SelectStartingBossesForRound() -> boss: %s", g_strRoundBossProfile);
	#endif
	}
	else if (SF_IsBoxingMap())
	{
		if (sProfileOverride[0] != '\0' && IsProfileValid(sProfileOverride))
		{
			// Pick the overridden boss.
			strcopy(g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile), sProfileOverride);
			SetConVarString(g_cvBossProfileOverride, "");
		}
		else if (g_bNewBossRound)
		{
			if (g_bNewBossRoundNew)
			{
				Handle hBossList = GetNewBossRoundProfileList();
			
				GetArrayString(hBossList, GetRandomInt(0, GetArraySize(hBossList) - 1), g_strNewBossRoundProfile, sizeof(g_strNewBossRoundProfile));
			
				delete hBossList;
			}
			
			strcopy(g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile), g_strNewBossRoundProfile);
		}
		else
		{
			char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			GetConVarString(g_cvBossMain, sProfile, sizeof(sProfile));
			
			if (sProfile[0] != '\0' && IsProfileValid(sProfile))
			{
				strcopy(g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile), sProfile);
			}
			else
			{
				if (GetArraySize(hSelectableBossList) > 0)
				{
					// Pick the first boss in our array if the main boss doesn't exist.
					GetArrayString(hSelectableBossList, 0, g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile));
				}
				else
				{
					// No bosses to pick. What?
					g_strRoundBoxingBossProfile[0] = '\0';
				}
			}
		}
		
	#if defined DEBUG
		if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END SelectStartingBossesForRound() -> boss: %s", g_strRoundBoxingBossProfile);
	#endif
	}
	delete hSelectableBossList;
}

static void GetRoundIntroParameters()
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "env_fade")) != -1)
	{
		char sName[32];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (strcmp(sName, "sf2_intro_fade", false) == 0)
		{
			int iColorOffset = FindSendPropInfo("CBaseEntity", "m_clrRender");
			if (iColorOffset != -1)
			{
				g_iRoundIntroFadeColor[0] = GetEntData(ent, iColorOffset, 1);
				g_iRoundIntroFadeColor[1] = GetEntData(ent, iColorOffset + 1, 1);
				g_iRoundIntroFadeColor[2] = GetEntData(ent, iColorOffset + 2, 1);
				g_iRoundIntroFadeColor[3] = GetEntData(ent, iColorOffset + 3, 1);
			}
			
			g_flRoundIntroFadeHoldTime = GetEntPropFloat(ent, Prop_Data, "m_HoldTime");
			g_flRoundIntroFadeDuration = GetEntPropFloat(ent, Prop_Data, "m_Duration");
			
			break;
		}
	}
	
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		char sName[64];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (strcmp(sName, "sf2_intro_music", false) == 0)
		{
			char sSongPath[PLATFORM_MAX_PATH];
			GetEntPropString(ent, Prop_Data, "m_iszSound", sSongPath, sizeof(sSongPath));
			
			if (sSongPath[0] == '\0')
			{
				LogError("Found sf2_intro_music entity, but it has no sound path specified! Default intro music will be used instead.");
			}
			else
			{
				strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), sSongPath);
			}
			
			break;
		}
	}
}

static void GetRoundEscapeParameters()
{
	g_iRoundEscapePointEntity = INVALID_ENT_REFERENCE;
	
	char sName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (!StrContains(sName, "sf2_escape_spawnpoint", false))
		{
			g_iRoundEscapePointEntity = EntIndexToEntRef(ent);
			break;
		}
	}
}

void InitializeNewGame()
{
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("START InitializeNewGame()");
#endif

	InitializeMapEntities();

	//Tutorial_EnableHooks();
	
	if (SF_IsBoxingMap())
	{
		g_iSlenderBoxingBossCount = 0;
		g_iSlenderBoxingBossKilled = 0;
	}
	else if (SF_IsRenevantMap())
	{
		g_hRenevantWaveTimer = INVALID_HANDLE;
		g_bRenevantMultiEffect = false;
		g_bRenevantBeaconEffect = false;

		Renevant_SetWave(0);
	}

	// Choose round state.
	if (GetConVarBool(g_cvIntroEnabled))
	{
		// Set the round state to the intro stage.
		SetRoundState(SF2RoundState_Intro);
	}
	else
	{
		SetRoundState(SF2RoundState_Active);
		SF2_RefreshRestrictions();
	}
	
	if (g_iRoundActiveCount == 1)
	{
		SetConVarString(g_cvBossProfileOverride, "");
	}
	
	HandleSpecialRoundState();
	
	// Was a new special round initialized?
	if (g_bSpecialRound && !SF_IsRenevantMap())
	{
		if (g_bSpecialRoundNew)
		{
			// Reset round count.
			g_iSpecialRoundCount = 1;
			
			if (g_bSpecialRoundContinuous)
			{
				// It's the start of a continuous special round.
			
				// Initialize all players' values.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsClientParticipating(i))
					{
						g_bPlayerPlayedSpecialRound[i] = true;
						continue;
					}
					
					g_bPlayerPlayedSpecialRound[i] = false;
				}
			}
			
			SpecialRoundCycleStart();
		}
		else
		{
			SpecialRoundStart();
			
			if (g_bSpecialRoundContinuous)
			{
				// Display the current special round going on to late players.
				CreateTimer(3.0, Timer_DisplaySpecialRound);
			}
		}
	}
	else
	{
		g_iSpecialRoundCount++;
	
		SpecialRoundReset();
	}
	
	// Determine boss round state.
	HandleNewBossRoundState();
	
	if (g_bNewBossRound)
	{
		if (g_bNewBossRoundNew)
		{
			// Reset round count;
			g_iNewBossRoundCount = 1;
			
			if (g_bNewBossRoundContinuous)
			{
				// It's the start of a continuous "new boss round".
			
				// Initialize all players' values.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsClientParticipating(i))
					{
						g_bPlayerPlayedNewBossRound[i] = true;
						continue;
					}
					
					g_bPlayerPlayedNewBossRound[i] = false;
				}
			}
		}
	}
	else
	{
		g_iNewBossRoundCount++;
	}

	SelectStartingBossesForRound();
	
	ForceInNextPlayersInQueue(GetMaxPlayersForRound());
	
	// Respawn all players, if needed.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientParticipating(i))
		{
			if (!HandlePlayerTeam(i))
			{
				if (!g_bPlayerEliminated[i])
				{
					// Players currently in the "game" still have to be respawned.
					TF2_RespawnPlayer(i);
				}
			}
		}
	}
	
	if (GetRoundState() == SF2RoundState_Intro)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			
			if (!g_bPlayerEliminated[i])
			{
				if (!IsFakeClient(i))
				{
					// Currently in intro state, play intro music.
					g_hPlayerIntroMusicTimer[i] = CreateTimer(0.5, Timer_PlayIntroMusicToPlayer, GetClientUserId(i));
				}
				else
				{
					g_hPlayerIntroMusicTimer[i] = INVALID_HANDLE;
				}
			}
			else
			{
				g_hPlayerIntroMusicTimer[i] = INVALID_HANDLE;
			}
		}
	}
	else
	{
		// Spawn the boss!
		if (!SF_SpecialRound(SPECIALROUND_HYPERSNATCHER) && !SF_SpecialRound(SPECIALROUND_MODBOSSES))
		{
			if (!SF_IsBoxingMap() && !SF_IsRenevantMap())
			{
				if (SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) || SF_SpecialRound(SPECIALROUND_DOOMBOX) || SF_SpecialRound(SPECIALROUND_2DOUBLE) || SF_SpecialRound(SPECIALROUND_2DOOM))
				{
					AddProfile(g_strRoundBossProfile);
					RemoveBossProfileFromQueueList(g_strRoundBossProfile);
				}
				else if (SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
				{
					AddProfile(g_strRoundBossProfile);
					AddProfile(g_strRoundBossProfile,_,_,_,false);
					AddProfile(g_strRoundBossProfile,_,_,_,false);
					RemoveBossProfileFromQueueList(g_strRoundBossProfile);
				}
				else if (!SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) && !SF_SpecialRound(SPECIALROUND_DOOMBOX) && !SF_SpecialRound(SPECIALROUND_2DOUBLE) && !SF_SpecialRound(SPECIALROUND_2DOOM) && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
				{
					SelectProfile(view_as<SF2NPC_BaseNPC>(0), g_strRoundBossProfile);
					RemoveBossProfileFromQueueList(g_strRoundBossProfile);
				}
			}
			else if (SF_IsBoxingMap())
			{
				char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
				Handle hSelectableBosses = CloneArray(GetSelectableBoxingBossProfileList());
				if (GetArraySize(hSelectableBosses) > 0)
				{
					GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
				}
				delete hSelectableBosses;
			}
		}
	}
	
#if defined DEBUG
	if (GetConVarInt(g_cvDebugDetail) > 0) DebugMessage("END InitializeNewGame()");
#endif
}

public Action Timer_PlayIntroMusicToPlayer(Handle timer, any userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0) return;
	if (!IsClientInGame(iClient)) return;
	
	if (timer != g_hPlayerIntroMusicTimer[iClient]) return;
	
	g_hPlayerIntroMusicTimer[iClient] = INVALID_HANDLE;
	
	EmitSoundToClient(iClient, g_strRoundIntroMusic, _, MUSIC_CHAN, SNDLEVEL_NONE);
}

static void StartIntroTextSequence()
{
	g_iRoundIntroText = 1;
	g_bRoundIntroTextDefault = false;
	g_hRoundIntroTextTimer = null;

	if (g_GamerulesEntity.IsValid()) 
	{
		SF2GameTextEntity textEntity = g_GamerulesEntity.IntroTextEntity;
		if (textEntity.IsValid()) 
		{
			g_hRoundIntroTextTimer = CreateTimer(g_GamerulesEntity.IntroTextDelay, Timer_NewIntroTextSequence, textEntity.EntRef, TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	if (g_hRoundIntroTextTimer == null) 
	{
		// Use old intro text sequence.
		g_hRoundIntroTextTimer = CreateTimer(0.0, Timer_IntroTextSequence, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

static Action Timer_NewIntroTextSequence(Handle timer, any data)
{
	if (!g_bEnabled) return;
	if (g_hRoundIntroTextTimer != timer) return;

	SF2GameTextEntity textEntity = SF2GameTextEntity(data);
	if (!textEntity.IsValid()) return;

	int iClients[MAXPLAYERS + 1];
	int iClientsNum;
	
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient) || g_bPlayerEliminated[iClient]) continue;
		
		iClients[iClientsNum] = iClient;
		iClientsNum++;
	}
	
	char sMessage[512];
	textEntity.GetIntroMessage(sMessage, sizeof(sMessage));
	ShowHudTextUsingTextEntity(iClients, iClientsNum, textEntity.EntRef, g_hHudSync, sMessage);

	SF2GameTextEntity nextTextEntity = textEntity.NextIntroTextEntity;
	if (nextTextEntity.IsValid())
	{
		float flDuration = GetEntPropFloat(textEntity.EntRef, Prop_Data, "m_textParms.fadeinTime") 
			+ GetEntPropFloat(textEntity.EntRef, Prop_Data, "m_textParms.fadeoutTime") 
			+ GetEntPropFloat(textEntity.EntRef, Prop_Data, "m_textParms.holdTime")
			+ textEntity.NextIntroTextDelay;
		
		g_hRoundIntroTextTimer = CreateTimer(flDuration, Timer_NewIntroTextSequence, nextTextEntity.EntRef, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_IntroTextSequence(Handle timer)
{
	if (!g_bEnabled) return;
	if (g_hRoundIntroTextTimer != timer) return;
	
	float flDuration = 0.0;
	
	if (g_iRoundIntroText != 0)
	{
		bool bFoundGameText = false;
		
		int iClients[MAXPLAYERS + 1];
		int iClientsNum;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || g_bPlayerEliminated[i]) continue;
			
			iClients[iClientsNum] = i;
			iClientsNum++;
		}
		
		if (!g_bRoundIntroTextDefault)
		{
			char sTargetname[64];
			FormatEx(sTargetname, sizeof(sTargetname), "sf2_intro_text_%d", g_iRoundIntroText);
		
			int iGameText = FindEntityByTargetname(sTargetname, "game_text");
			if (iGameText && iGameText != INVALID_ENT_REFERENCE)
			{
				bFoundGameText = true;
				flDuration = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeinTime") + GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeoutTime") + GetEntPropFloat(iGameText, Prop_Data, "m_textParms.holdTime");
				
				char sMessage[512];
				GetEntPropString(iGameText, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
				ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameText, g_hHudSync, sMessage);
			}
		}
		else
		{
			if (g_iRoundIntroText == 2)
			{
				bFoundGameText = false;
				
				char sMessage[64];
				GetCurrentMap(sMessage, sizeof(sMessage));
				
				for (int i = 0; i < iClientsNum; i++)
				{
					ClientShowMainMessage(iClients[i], sMessage, 1);
				}
			}
		}
		
		if (g_iRoundIntroText == 1 && !bFoundGameText)
		{
			// Use default intro sequence. Eugh.
			g_bRoundIntroTextDefault = true;
			flDuration = GetConVarFloat(g_cvIntroDefaultHoldTime) / 2.0;
			
			for (int i = 0; i < iClientsNum; i++)
			{
				EmitSoundToClient(iClients[i], SF2_INTRO_DEFAULT_MUSIC, _, MUSIC_CHAN, SNDLEVEL_NONE);
			}
		}
		else
		{
			if (!bFoundGameText) return; // done with sequence; don't check anymore.
		}
	}
	
	g_iRoundIntroText++;
	g_hRoundIntroTextTimer = CreateTimer(flDuration, Timer_IntroTextSequence);
}

public Action Timer_ActivateRoundFromIntro(Handle timer)
{
	if (!g_bEnabled) return;
	if (g_hRoundIntroTimer != timer) return;
	
	// Obviously we don't want to spawn the boss when g_strRoundBossProfile isn't set yet.
	SetRoundState(SF2RoundState_Active);
	SF2_RefreshRestrictions();

	// Spawn the boss!
	if (!SF_SpecialRound(SPECIALROUND_HYPERSNATCHER) && !SF_SpecialRound(SPECIALROUND_MODBOSSES))
	{
		if (!SF_IsBoxingMap() && !SF_IsRenevantMap())
		{
			if (SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) || SF_SpecialRound(SPECIALROUND_DOOMBOX) || SF_SpecialRound(SPECIALROUND_2DOUBLE) || SF_SpecialRound(SPECIALROUND_2DOOM))
			{
				AddProfile(g_strRoundBossProfile);
				RemoveBossProfileFromQueueList(g_strRoundBossProfile);
			}
			else if (SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
			{
				AddProfile(g_strRoundBossProfile);
				AddProfile(g_strRoundBossProfile,_,_,_,false);
				AddProfile(g_strRoundBossProfile,_,_,_,false);
				RemoveBossProfileFromQueueList(g_strRoundBossProfile);
			}
			else if (!SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) && !SF_SpecialRound(SPECIALROUND_DOOMBOX) && !SF_SpecialRound(SPECIALROUND_2DOUBLE) && !SF_SpecialRound(SPECIALROUND_2DOOM) && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
			{
				SelectProfile(view_as<SF2NPC_BaseNPC>(0), g_strRoundBossProfile);
				RemoveBossProfileFromQueueList(g_strRoundBossProfile);
			}
		}
		else if (SF_IsBoxingMap())
		{
			char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
			Handle hSelectableBosses = CloneArray(GetSelectableBoxingBossProfileList());
			if (GetArraySize(hSelectableBosses) > 0)
			{
				GetArrayString(hSelectableBosses, GetRandomInt(0, GetArraySize(hSelectableBosses) - 1), sBuffer, sizeof(sBuffer));
				AddProfile(sBuffer);
			}
			delete hSelectableBosses;
		}
	}

}

void CheckRoundWinConditions()
{
	if (IsRoundInWarmup() || IsRoundEnding() || g_cvIgnoreRoundWinConditions.BoolValue) return;
	
	int iTotalCount = 0;
	int iAliveCount = 0;
	int iEscapedCount = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		iTotalCount++;
		if ((!g_bPlayerEliminated[i] && !IsClientInDeathCam(i)) || (SF_SpecialRound(SPECIALROUND_1UP) && g_bPlayerIn1UpCondition[i])) 
		{
			iAliveCount++;
			if (DidClientEscape(i)) iEscapedCount++;
		}
	}
	
	if (iAliveCount == 0)
	{
		ForceTeamWin(TFTeam_Blue);
	}
	else
	{
		if (g_bRoundHasEscapeObjective)
		{
			if (iEscapedCount == iAliveCount)
			{
				ForceTeamWin(TFTeam_Red);
			}
		}
		else
		{
			if (g_iPageMax > 0 && g_iPageCount == g_iPageMax)
			{
				ForceTeamWin(TFTeam_Red);
			}
		}
	}
}

//	==========================================================
//	API
//	==========================================================

public int Native_IsRunning(Handle plugin,int numParams)
{
	return view_as<bool>(g_bEnabled);
}

public int Native_GetRoundState(Handle plugin,int numParams)
{
	return view_as<int>(g_iRoundState);
}

public int Native_IsRoundInGracePeriod(Handle plugin, int numParams)
{
	return g_bRoundGrace;
}

public int Native_GetCurrentDifficulty(Handle plugin,int numParams)
{
	return GetConVarInt(g_cvDifficulty);
}

public int Native_GetDifficultyModifier(Handle plugin,int numParams)
{
	int iDifficulty = GetNativeCell(1);
	if (iDifficulty < Difficulty_Easy || iDifficulty >= Difficulty_Max)
	{
		LogError("Difficulty parameter can only be from %d to %d!", Difficulty_Easy, Difficulty_Max - 1);
		return 1;
	}
	
	switch (iDifficulty)
	{
		case Difficulty_Easy: return view_as<int>(DIFFICULTY_NORMAL);
		case Difficulty_Hard: return view_as<int>(DIFFICULTY_HARD);
		case Difficulty_Insane: return view_as<int>(DIFFICULTY_INSANE);
		case Difficulty_Nightmare: return view_as<int>(DIFFICULTY_NIGHTMARE);
		case Difficulty_Apollyon: return view_as<int>(DIFFICULTY_APOLLYON);
	}
	
	return view_as<int>(DIFFICULTY_NORMAL);
}

public int Native_IsClientEliminated(Handle plugin,int numParams)
{
	return view_as<bool>(g_bPlayerEliminated[GetNativeCell(1)]);
}

public int Native_IsClientInGhostMode(Handle plugin,int numParams)
{
	return IsClientInGhostMode(GetNativeCell(1));
}

public int Native_IsClientProxy(Handle plugin,int numParams)
{
	return view_as<bool>(g_bPlayerProxy[GetNativeCell(1)]);
}

public int Native_GetClientBlinkCount(Handle plugin,int numParams)
{
	return ClientGetBlinkCount(GetNativeCell(1));
}

public int Native_IsClientBlinking(Handle plugin,int numParams)
{
	return IsClientBlinking(GetNativeCell(1));
}

public int Native_GetClientBlinkMeter(Handle plugin,int numParams)
{
	return view_as<int>(ClientGetBlinkMeter(GetNativeCell(1)));
}

public int Native_SetClientBlinkMeter(Handle plugin,int numParams)
{
	ClientSetBlinkMeter(GetNativeCell(1), view_as<float>(GetNativeCell(2)));
}

public int Native_GetClientProxyMaster(Handle plugin,int numParams)
{
	return NPCGetFromUniqueID(g_iPlayerProxyMaster[GetNativeCell(1)]);
}

public int Native_GetClientProxyControlAmount(Handle plugin,int numParams)
{
	return g_iPlayerProxyControl[GetNativeCell(1)];
}

public int Native_GetClientProxyControlRate(Handle plugin,int numParams)
{
	return view_as<int>(g_flPlayerProxyControlRate[GetNativeCell(1)]);
}

public int Native_SetClientProxyMaster(Handle plugin,int numParams)
{
	g_iPlayerProxyMaster[GetNativeCell(1)] = NPCGetUniqueID(GetNativeCell(2));
}

public int Native_SetClientProxyControlAmount(Handle plugin,int numParams)
{
	g_iPlayerProxyControl[GetNativeCell(1)] = GetNativeCell(2);
}

public int Native_SetClientProxyControlRate(Handle plugin,int numParams)
{
	g_flPlayerProxyControlRate[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
}

public int Native_IsClientLookingAtBoss(Handle plugin,int numParams)
{
	return view_as<bool>(g_bPlayerSeesSlender[GetNativeCell(1)][GetNativeCell(2)]);
}

public int Native_DidClientEscape(Handle plugin,int numParams)
{
	return view_as<bool>(DidClientEscape(GetNativeCell(1)));
}

public int Native_ForceClientEscape(Handle plugin,int numParams)
{
	int client = GetNativeCell(1);

	ClientEscape(client);
	TeleportClientToEscapePoint(client);
}

public int Native_GetClientFlashlightBatteryLife(Handle plugin, int numParams)
{
	return view_as<int>(ClientGetFlashlightBatteryLife(GetNativeCell(1)));
}

public int Native_SetClientFlashlightBatteryLife(Handle plugin, int numParams)
{
	ClientSetFlashlightBatteryLife(GetNativeCell(1), view_as<float>(GetNativeCell(2)));
}

public int Native_IsClientUsingFlashlight(Handle plugin, int numParams)
{
	return IsClientUsingFlashlight(GetNativeCell(1));
}

public int Native_GetClientSprintPoints(Handle plugin, int numParams)
{
	return ClientGetSprintPoints(GetNativeCell(1));
}

public int Native_SetClientSprintPoints(Handle plugin, int numParams)
{
	g_iPlayerSprintPoints[GetNativeCell(1)] = GetNativeCell(2);
}

public int Native_IsClientSprinting(Handle plugin, int numParams)
{
	return IsClientSprinting(GetNativeCell(1));
}

public int Native_IsClientReallySprinting(Handle plugin, int numParams)
{
	return IsClientReallySprinting(GetNativeCell(1));
}

public int Native_IsClientTrapped(Handle plugin, int numParams)
{
	return g_bPlayerTrapped[GetNativeCell(1)];
}

public int Native_CollectAsPage(Handle plugin,int numParams)
{
	CollectPage(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetMaxBosses(Handle plugin,int numParams)
{
	return MAX_BOSSES;
}

public int Native_EntIndexToBossIndex(Handle plugin,int numParams)
{
	return NPCGetFromEntIndex(GetNativeCell(1));
}

public int Native_BossIndexToEntIndex(Handle plugin,int numParams)
{
	return EntRefToEntIndex(g_iSlender[GetNativeCell(1)]);
}

public int Native_BossIndexToEntIndexEx(Handle plugin,int numParams)
{
	return NPCGetEntIndex(GetNativeCell(1));
}

public int Native_BossIDToBossIndex(Handle plugin,int numParams)
{
	return NPCGetFromUniqueID(GetNativeCell(1));
}

public int Native_BossIndexToBossID(Handle plugin,int numParams)
{
	return NPCGetUniqueID(GetNativeCell(1));
}

public int Native_AddBoss(Handle plugin, int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, sizeof(sProfile));

	int flags = GetNativeCell(2);
	bool spawnCompanions = view_as<bool>(GetNativeCell(3));
	bool playSpawnSound = view_as<bool>(GetNativeCell(4));

	return view_as<int>(AddProfile(sProfile, flags, _, spawnCompanions, playSpawnSound));
}

public int Native_RemoveBoss(Handle plugin, int numParams)
{
	SF2NPC_BaseNPC boss = SF2NPC_BaseNPC(GetNativeCell(1));
	if (!boss.IsValid())
		return;
	
	RemoveProfile(boss.Index);
}

public int Native_GetBossName(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(GetNativeCell(1), sProfile, sizeof(sProfile));
	
	SetNativeString(2, sProfile, GetNativeCell(3));
}

public int Native_GetBossType(Handle plugin, int numParams)
{
	return NPCGetType(GetNativeCell(1));
}

public int Native_GetBossFlags(Handle plugin, int numParams)
{
	return NPCGetFlags(GetNativeCell(1));
}

public int Native_SetBossFlags(Handle plugin, int numParams)
{
	NPCSetFlags(GetNativeCell(1), GetNativeCell(2));
}

public int Native_SpawnBoss(Handle plugin, int numParams)
{
	SF2NPC_BaseNPC boss = SF2NPC_BaseNPC(GetNativeCell(1));
	if (!boss.IsValid())
		return;

	float position[3];
	GetNativeArray(2, position, 3);

	SpawnSlender(boss, position);
}

public int Native_DespawnBoss(Handle plugin, int numParams)
{
	SF2NPC_BaseNPC boss = SF2NPC_BaseNPC(GetNativeCell(1));
	if (!boss.IsValid())
		return;

	RemoveSlender(boss.Index);
}

public int Native_GetBossModelEntity(Handle plugin,int numParams)
{
	return EntRefToEntIndex(g_iSlender[GetNativeCell(1)]);
}

public int Native_GetBossTarget(Handle plugin,int numParams)
{
	return EntRefToEntIndex(g_iSlenderTarget[GetNativeCell(1)]);
}

public int Native_GetBossMaster(Handle plugin,int numParams)
{
	return g_iSlenderCopyMaster[GetNativeCell(1)];
}

public int Native_GetBossState(Handle plugin,int numParams)
{
	return g_iSlenderState[GetNativeCell(1)];
}

public int Native_GetBossEyePosition(Handle plugin, int numParams)
{
	SF2NPC_BaseNPC boss = SF2NPC_BaseNPC(GetNativeCell(1));
	if (!boss.IsValid() || !IsValidEntity(boss.EntIndex))
		return;
	
	float eyePos[3];
	boss.GetEyePosition(eyePos);

	SetNativeArray(2, eyePos, 3);
}

public int Native_GetBossEyePositionOffset(Handle plugin, int numParams)
{
	SF2NPC_BaseNPC boss = SF2NPC_BaseNPC(GetNativeCell(1));
	if (!boss.IsValid())
		return;
	
	float eyePos[3];
	boss.GetEyePositionOffset(eyePos);

	SetNativeArray(2, eyePos, 3);
}

public int Native_GetBossFOV(Handle plugin, int numParams)
{
	return view_as<int>(NPCGetFOV(GetNativeCell(1)));
}

public int Native_GetBossTimeUntilNoPersistence(Handle plugin, int numParams)
{
	return view_as<int>(g_flSlenderTimeUntilNoPersistence[GetNativeCell(1)]);
}

public int Native_SetBossTimeUntilNoPersistence(Handle plugin, int numParams)
{
	g_flSlenderTimeUntilNoPersistence[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
}

public int Native_GetBossTimeUntilIdle(Handle plugin, int numParams)
{
	return view_as<int>(g_flSlenderTimeUntilIdle[GetNativeCell(1)]);
}

public int Native_SetBossTimeUntilIdle(Handle plugin, int numParams)
{
	g_flSlenderTimeUntilIdle[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
}

public int Native_GetBossTimeUntilAlert(Handle plugin, int numParams)
{
	return view_as<int>(g_flSlenderTimeUntilAlert[GetNativeCell(1)]);
}

public int Native_SetBossTimeUntilAlert(Handle plugin, int numParams)
{
	g_flSlenderTimeUntilAlert[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
}

public int Native_IsBossStunnable(Handle plugin, int numParams)
{
	return SF2NPC_Chaser(GetNativeCell(1)).StunEnabled;
}

public int Native_IsBossStunnableByFlashlight(Handle plugin, int numParams)
{
	return SF2NPC_Chaser(GetNativeCell(1)).StunByFlashlightEnabled;
}

public int Native_IsBossCloaked(Handle plugin, int numParams)
{
	return g_bNPCHasCloaked[GetNativeCell(1)];
}

public int Native_GetBossStunHealth(Handle plugin, int numParams)
{
	return view_as<int>(SF2NPC_Chaser(GetNativeCell(1)).StunHealth);
}

public int Native_SetBossStunHealth(Handle plugin, int numParams)
{
	SF2NPC_Chaser(GetNativeCell(1)).StunHealth = view_as<float>(GetNativeCell(2));
}

public int Native_GetBossNextStunTime(Handle plugin, int numParams)
{
	return view_as<int>(g_flSlenderNextStunTime[GetNativeCell(1)]);
}

public int Native_SetBossNextStunTime(Handle plugin, int numParams)
{
	g_flSlenderNextStunTime[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
}

public int Native_ForceBossGiveUp(Handle plugin, int numParams)
{
	g_bSlenderGiveUp[GetNativeCell(1)] = false;
}

public int Native_GetBossGoalPosition(Handle plugin, int numParams)
{
	SetNativeArray(2, g_flSlenderGoalPos[GetNativeCell(1)], 3);
}

public int Native_CanBossHearClient(Handle plugin, int numParams)
{
	return SlenderCanHearPlayer(GetNativeCell(1), GetNativeCell(2), view_as<SoundType>(GetNativeCell(3)));
}

public int Native_CreateBossSoundHint(Handle plugin, int numParams)
{
	SF2NPC_Chaser boss = SF2NPC_Chaser(GetNativeCell(1));
	if (!boss.IsValid() || boss.Type != SF2BossType_Chaser || !IsValidEntity(boss.EntIndex))
		return;

	SoundType soundType = view_as<SoundType>(GetNativeCell(2));
	float position[3];
	GetNativeArray(3, position, 3);

	switch (soundType)
	{
		case SoundType_Footstep:
		{
			CopyVector(position, g_flSlenderTargetSoundTempPos[boss.Index]);
			g_iSlenderInterruptConditions[boss.Index] |= (COND_HEARDSUSPICIOUSSOUND | COND_HEARDFOOTSTEP);
			if (boss.State == STATE_ALERT && NPCChaserIsAutoChaseEnabled(boss.Index) && g_flSlenderAutoChaseCooldown[boss.Index] <= GetGameTime()) 
			{
				g_iSlenderAutoChaseCount[boss.Index] += NPCChaserAutoChaseAddFootstep(boss.Index);
				g_flSlenderAutoChaseCooldown[boss.Index] = GetGameTime() + 0.3;
			}
		}
		case SoundType_Voice:
		{
			CopyVector(position, g_flSlenderTargetSoundTempPos[boss.Index]);
			g_iSlenderInterruptConditions[boss.Index] |= (COND_HEARDSUSPICIOUSSOUND | COND_HEARDVOICE);
			if (boss.State == STATE_ALERT && NPCChaserIsAutoChaseEnabled(boss.Index) && g_flSlenderAutoChaseCooldown[boss.Index] <= GetGameTime()) 
			{
				g_iSlenderAutoChaseCount[boss.Index] += NPCChaserAutoChaseAddVoice(boss.Index);
				g_flSlenderAutoChaseCooldown[boss.Index] = GetGameTime() + 0.3;
			}
		}
		case SoundType_Weapon:
		{
			CopyVector(position, g_flSlenderTargetSoundTempPos[boss.Index]);
			g_iSlenderInterruptConditions[boss.Index] |= (COND_HEARDSUSPICIOUSSOUND | COND_HEARDWEAPON);
			if (boss.State == STATE_ALERT && NPCChaserIsAutoChaseEnabled(boss.Index) && g_flSlenderAutoChaseCooldown[boss.Index] <= GetGameTime()) 
			{
				g_iSlenderAutoChaseCount[boss.Index] += NPCChaserAutoChaseAddWeapon(boss.Index);	
				g_flSlenderAutoChaseCooldown[boss.Index] = GetGameTime() + 0.3;
			}
		}
		case SoundType_Flashlight:
		{
			CopyVector(position, g_flSlenderTargetSoundTempPos[boss.Index]);
			g_iSlenderInterruptConditions[boss.Index] |= (COND_HEARDSUSPICIOUSSOUND | COND_HEARDFLASHLIGHT);
			if (boss.State == STATE_ALERT && NPCChaserIsAutoChaseEnabled(boss.Index) && g_flSlenderAutoChaseCooldown[boss.Index] <= GetGameTime()) 
			{
				g_iSlenderAutoChaseCount[boss.Index] += NPCChaserAutoChaseAddWeapon(boss.Index);	
				g_flSlenderAutoChaseCooldown[boss.Index] = GetGameTime() + 0.3;
			}
		}
	}
}

public int Native_IsBossProfileValid(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);
	
	return IsProfileValid(sProfile);
}

public int Native_GetBossProfileNum(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);
	
	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	return GetProfileNum(sProfile, sKeyValue, GetNativeCell(3));
}

public int Native_GetBossProfileFloat(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	return view_as<int>(GetProfileFloat(sProfile, sKeyValue, view_as<float>(GetNativeCell(3))));
}

public int Native_GetBossProfileString(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	int iResultLen = GetNativeCell(4);
	char[] sResult = new char[iResultLen];
	
	char sDefaultValue[512];
	GetNativeString(5, sDefaultValue, sizeof(sDefaultValue));
	
	bool bSuccess = GetProfileString(sProfile, sKeyValue, sResult, iResultLen, sDefaultValue);
	
	SetNativeString(3, sResult, iResultLen);
	return bSuccess;
}

public int Native_GetBossProfileVector(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	float flResult[3];
	float flDefaultValue[3];
	GetNativeArray(4, flDefaultValue, 3);
	
	bool bSuccess = GetProfileVector(sProfile, sKeyValue, flResult, flDefaultValue);
	
	SetNativeArray(3, flResult, 3);
	return bSuccess;
}

public int Native_GetRandomStringFromBossProfile(Handle plugin,int numParams)
{
	char sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	GetNativeString(1, sProfile, SF2_MAX_PROFILE_NAME_LENGTH);

	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));
	
	int iBufferLen = GetNativeCell(4);
	char[] sBuffer = new char[iBufferLen];
	
	int iIndex = GetNativeCell(5);

	bool bSuccess = GetRandomStringFromProfile(sProfile, sKeyValue, sBuffer, iBufferLen, iIndex);
	SetNativeString(3, sBuffer, iBufferLen);
	return bSuccess;
}

public int Native_GetBossAttributeName(Handle plugin,int numParams)
{
	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));

	bool bSuccess = NPCHasAttribute(GetNativeCell(1), sKeyValue);
	return bSuccess;
}

public int Native_GetBossAttributeValue(Handle plugin,int numParams)
{
	char sKeyValue[256];
	GetNativeString(2, sKeyValue, sizeof(sKeyValue));

	if (!NPCHasAttribute(GetNativeCell(1), sKeyValue)) return view_as<int>(GetNativeCell(3));
	return view_as<int>(NPCGetAttributeValue(GetNativeCell(1), sKeyValue, view_as<float>(GetNativeCell(3))));
}

public int Native_GetBossProjectileType(Handle plugin,int numParams)
{
	return NPCChaserGetProjectileType(GetNativeCell(1));
}

public int Native_GetBossCurrentAttackIndex(Handle plugin,int numParams)
{
	return NPCGetCurrentAttackIndex(GetNativeCell(1));
}

public int Native_GetBossAttackIndexDamageType(Handle plugin,int numParams)
{
	return NPCChaserGetAttackDamageType(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetBossAttackIndexDamage(Handle plugin,int numParams)
{
	return view_as<int>(NPCChaserGetAttackDamage(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3)));
}

public int Native_GetBossAttackIndexType(Handle plugin,int numParams)
{
	return NPCChaserGetAttackType(GetNativeCell(1), GetNativeCell(2));
}

public int Native_IsSurvivalMap(Handle plugin, int numParams)
{
	return view_as<int>(SF_IsSurvivalMap());
}

public int Native_IsBoxingMap(Handle plugin, int numParams)
{
	return view_as<int>(SF_IsBoxingMap());
}

public int Native_IsRaidMap(Handle plugin, int numParams)
{
	return view_as<int>(SF_IsRaidMap());
}

public int Native_IsProxyMap(Handle plugin, int numParams)
{
	return view_as<int>(SF_IsProxyMap());
}

public int Native_IsRenevantMap(Handle plugin, int numParams)
{
	return view_as<int>(SF_IsRenevantMap());
}

public int Native_IsSlaughterRunMap(Handle plugin, int numParams)
{
	return view_as<int>(SF_IsSlaughterRunMap());
}