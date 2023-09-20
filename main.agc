
// Project: PhysicsCreater 
// Created: 2021-11-05

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Physics Car Creater" )
SetWindowSize( 1480, 720, 0 )
SetWindowAllowResize( 0 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 1480, 720 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 60, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts
SetClearColor(127,201,255)
global pScale as float, pGravity, bodyMass, bodyFriction as float, bodyBounce, bodyRestitution as float, bodyDamping as float
pScale=0.2
pGravity=200
bodyFriction=0.0
bodyBounce=0
bodyRestitution=0.0
bodyDamping=0.0

SetPhysicsScale(pScale)
SetPhysicsMaxPolygonPoints(12)
ColorBox=MakeColor( 0,0,0)

GazUpImageID=LoadImage("gui/gaz.png")
GazDownImageID=LoadImage("gui/gaz.png")
BrakeUpImageID=LoadImage("gui/tormoz.png")
BrakeDownImageID=LoadImage("gui/tormoz.png")
// Create level
GroundBoxSprite=CreateSprite(LoadImage("level/ground_box.jpg"))
GroundTriangleSprite=CreateSprite(LoadImage("level/ground_triangle.png"))
GroundTestSprite=CreateSprite(LoadImage("level/ground_test.png"))

SetSpritePosition(GroundBoxSprite, 0, 520)
GroundBoxSprite=CloneSprite(GroundBoxSprite)
SetSpritePhysicsOn(GroundBoxSprite,1)
SetSpriteShape(GroundBoxSprite,2)

wbox=-2000
for box = 20 to 33
    CloneSprite(box,GroundBoxSprite)
    if box=20
		SetSpritePosition(box, wbox, 320)
	elseif box=21
		SetSpritePosition(box, wbox, 520)
	elseif box=33
		SetSpritePosition(box, wbox, 320)
	else
		SetSpritePosition(box, wbox, 520)
	endif
    SetSpritePhysicsOn(box,1)
    SetSpriteShape(box,2)
    inc wbox,1000
next box

SetSpritePosition(GroundTriangleSprite, 1800, 325)
GroundTriangleSprite_M=CloneSprite(GroundTriangleSprite)
SetSpriteFlip(GroundTriangleSprite_M,1,0)
SetSpritePosition(GroundTriangleSprite_M, 2800, 325)
SetSpritePosition(GroundTestSprite, 0, 505)
w=40
for t = 1 to 15
    CloneSprite(t,GroundTestSprite)
    SetSpritePosition(t, w, 505)
    SetSpritePhysicsOn(t,1)
    SetSpriteShape(t,3)
    inc w,40
next t

SetSpriteShape(GroundTriangleSprite,3)
SetSpriteShape(GroundTestSprite,3)
SetSpriteShape(GroundTriangleSprite_M,3)
SetSpritePhysicsOn(GroundTriangleSprite,1)
SetSpritePhysicsOn(GroundTriangleSprite_M,1)
// Load car
body=CreateSprite(LoadImage("body.png"))
SetSpritePositionByOffset(body,900,400)
f_wheel=CreateSprite(LoadImage("f_wheel.png"))
SetSpritePositionByOffset(f_wheel,1059,467)
b_wheel=CreateSprite(LoadImage("b_wheel.png"))
SetSpritePositionByOffset(b_wheel,763,467)

SetSpriteShape(body,3)
SetSpritePhysicsOn(body,2)
SetSpriteShape(f_wheel,1)
SetSpriteShape(b_wheel,1)
SetSpritePhysicsOn(f_wheel,2)
SetSpritePhysicsOn(b_wheel,2)

global BwheelMass=999
global FwheelMass=999

SetSpritePhysicsMass(f_wheel,999)
SetSpritePhysicsMass(b_wheel,999)
// Joints
global WheelFrontJointID, WheelBackJointID
WheelFrontJointID=CreateLineJoint(body,f_wheel,1059,467,0,7,0)
WheelBackJointID=CreateLineJoint(body,b_wheel,763,467,0,7,0)
// INTERFACE
// Loading the joystick to move the camera and zoom buttons
AddVirtualJoystick(1,60,60,100)

AddVirtualButton(1,140,35,45)
setVirtualButtonText(1,"+")
SetVirtualButtonColor(1,0,0,0)

AddVirtualButton(2,140,85,45)
setVirtualButtonText(2,"-")
SetVirtualButtonColor(2,0,0,0)

// Button to switch between a free camera and a fixed one
global CamMode=1 // Current camera mode, 0 - free camera, 1 - car camera

FreeCamOffImage=LoadImage("gui/cam_bt_off.png")
FreeCamOnImage=LoadImage("gui/cam_bt_on.png")
FreeCamButton=CreateSprite(FreeCamOffImage)
SetSpriteSize(FreeCamButton,50,-1)
SetSpritePositionByOffset(FreeCamButton,30,145)
FixSpriteToScreen(FreeCamButton, 1)

// Button for enabling disabling physics display
BtPhysicsOffImage=LoadImage("gui/physics_bt_off.png")
BtPhysicsOnImage=LoadImage("gui/physics_bt_on.png")
PhysicsDisplayButton=CreateSprite(BtPhysicsOffImage)
SetSpriteSize(PhysicsDisplayButton,50,-1)
SetSpritePositionByOffset(PhysicsDisplayButton,90,145)
FixSpriteToScreen(PhysicsDisplayButton, 1)

// Button car edit
global CarEditMode=0 // Current car edit mode, 0 - off, 1 - on

CarEditOffImage=LoadImage("gui/caredit_bt_off.png")
CarEditOnImage=LoadImage("gui/caredit_bt_on.png")
CarEditButton=CreateSprite(CarEditOffImage)
SetSpritePositionByOffset(CarEditButton,60,205)
FixSpriteToScreen(CarEditButton, 1)

// Brake
AddVirtualButton(4,90,GetVirtualHeight()-100,100)
SetVirtualButtonImageUp(4,BrakeUpImageID)
SetVirtualButtonImageDown(4,BrakeDownImageID)
SetVirtualButtonAlpha(4,200)

// Acceleration
AddVirtualButton(5,GetVirtualWidth()-90,GetVirtualHeight()-110,100)
SetVirtualButtonImageUp(5,GazUpImageID)
SetVirtualButtonImageDown(5,GazDownImageID)
SetVirtualButtonAlpha(5,200)

// Speedometer
global SpeedArrowSprite, currentSpeed
SpeedometrSprite=CreateSprite(LoadImage("gui/speedometr.png"))
SpeedArrowSprite=CreateSprite(LoadImage("gui/speed_arrow.png"))
SetSpriteSize(SpeedometrSprite, 300, -1)
SetSpritePosition(SpeedometrSprite,500,520)
FixSpriteToScreen(SpeedometrSprite, 1)

SetSpriteOffset(SpeedArrowSprite,141,5)
SetSpritePosition(SpeedArrowSprite,510,688)
FixSpriteToScreen(SpeedArrowSprite, 1)
//SetSpriteAngle(SpeedArrowSprite, 90)

// Transmission
GearboxDImage=LoadImage("gui/gearboxD.png")
GearboxRImage=LoadImage("gui/gearboxR.png")
GearboxID=CreateSprite(GearboxDImage)
SetSpriteSize(GearboxID,110,-1)
SetSpritePositionByOffset(GearboxID,GetVirtualWidth()-220,GetVirtualHeight()-110)
FixSpriteToScreen( GearboxID, 1)

// Physics scale TEXT
CreateText(1, "Physics Scale")
SetTextPosition(1, 180,10)
FixTextToScreen(1,1)
SetTextBold(1,1)
SetTextColor(1,0,0,0,255)
SetTextSize(1,20)

CreateText(31, str(pScale,2))
SetTextPosition(31, 198,30)
FixTextToScreen(31,1)
SetTextBold(31,1)
SetTextColor(31,0,0,0,255)
SetTextSize(31,40)

// Gravity TEXT/EDIT
CreateText(3, "Gravity")
SetTextPosition(3, 200,80)
FixTextToScreen(3,1)
SetTextBold(3,1)
SetTextColor(3,0,0,0,255)
SetTextSize(3,20)

CreateEditBox(1)
SetEditBoxPosition(1,210,105)
SetEditBoxSize(1, 40, 20 )
FixEditBoxToScreen(1,1)
SetEditBoxMaxChars(1,3)
SetEditBoxTextSize(1,100)
SetEditBoxText(1,str(pGravity))

// Body TEXT/EDIT
CreateText(4, "Body")
SetTextPosition(4, 345,10)
FixTextToScreen(4,1)
SetTextBold(4,1)
SetTextColor(4,0,0,0,255)
SetTextSize(4,30)

CreateText(5, "Weight(kg):")
SetTextPosition(5, 300,50)
FixTextToScreen(5,1)
SetTextBold(5,1)
SetTextColor(5,0,0,0,255)
SetTextSize(5,20)

bodyMass=GetSpritePhysicsMass(body)
CreateEditBox(3)
SetEditBoxPosition(3, 400, 50 )
SetEditBoxSize(3, 55, 20 )
FixEditBoxToScreen(3,1)
SetEditBoxMaxChars(3,5)
SetEditBoxTextSize(3,100)
SetEditBoxText(3,str(bodyMass))

CreateText(6, "Friction:")
SetTextPosition(6, 300,80)
FixTextToScreen(6,1)
SetTextBold(6,1)
SetTextColor(6,0,0,0,255)
SetTextSize(6,20)

CreateEditBox(4)
SetEditBoxPosition(4, 400, 80 )
SetEditBoxSize(4, 55, 20 )
FixEditBoxToScreen(4,1)
SetEditBoxMaxChars(4,5)
SetEditBoxTextSize(4,100)
SetEditBoxText(4,str(bodyFriction, 2))

CreateText(7, "Elasticity:")
SetTextPosition(7, 300,110)
FixTextToScreen(7,1)
SetTextBold(7,1)
SetTextColor(7,0,0,0,255)
SetTextSize(7,20)

CreateEditBox(5)
SetEditBoxPosition(5, 400, 110 )
SetEditBoxSize(5, 55, 20 )
FixEditBoxToScreen(5,1)
SetEditBoxMaxChars(5,5)
SetEditBoxTextSize(5,100)
SetEditBoxText(5,str(bodyRestitution, 2))

CreateText(8, "Air resistance:")
SetTextPosition(8, 300,140)
FixTextToScreen(8,1)
SetTextBold(8,1)
SetTextColor(8,0,0,0,255)
SetTextSize(8,20)

CreateEditBox(6)
SetEditBoxPosition(6, 420, 140 )
SetEditBoxSize(6, 55, 20 )
FixEditBoxToScreen(6,1)
SetEditBoxMaxChars(6,5)
SetEditBoxTextSize(6,100)
SetEditBoxText(6,str(bodyDamping, 2))

// Wheels TEXT/EDIT
CreateText(9, "Wheels")
SetTextPosition(9, 540,10)
FixTextToScreen(9,1)
SetTextBold(9,1)
SetTextColor(9,0,0,0,255)
SetTextSize(9,30)

CreateText(10, "Back")
SetTextPosition(10, 520,40)
FixTextToScreen(10,1)
SetTextBold(10,1)
SetTextColor(10,0,0,0,255)
SetTextSize(10,20)

CreateText(11, "Front")
SetTextPosition(11, 598,40)
FixTextToScreen(11,1)
SetTextBold(11,1)
SetTextColor(11,0,0,0,255)
SetTextSize(11,20)

CreateText(12, "Weight(kg):")
SetTextPosition(12, 535,60)
FixTextToScreen(12,1)
SetTextBold(12,1)
SetTextColor(12,0,0,0,255)
SetTextSize(12,20)

CreateEditBox(7)
SetEditBoxPosition(7, 510, 80 )
SetEditBoxSize(7, 60, 20 )
FixEditBoxToScreen(7,1)
SetEditBoxMaxChars(7,4)
SetEditBoxTextSize(7,100)
SetEditBoxText(7,str(GetSpritePhysicsMass(b_wheel),0))

CreateEditBox(8)
SetEditBoxPosition(8, 590, 80 )
SetEditBoxSize(8, 60, 20 )
FixEditBoxToScreen(8,1)
SetEditBoxMaxChars(8,4)
SetEditBoxTextSize(8,100)
SetEditBoxText(8,str(GetSpritePhysicsMass(f_wheel),0))

CreateText(13, "Friction:")
SetTextPosition(13, 540,100)
FixTextToScreen(13,1)
SetTextBold(13,1)
SetTextColor(13,0,0,0,255)
SetTextSize(13,20)

global bwheelFriction as float, fwheelFriction as float

CreateEditBox(9)
SetEditBoxPosition(9, 510, 120 )
SetEditBoxSize(9, 60, 20 )
FixEditBoxToScreen(9,1)
SetEditBoxMaxChars(9,4)
SetEditBoxTextSize(9,100)
SetEditBoxText(9,str(bwheelFriction, 1))

CreateEditBox(10)
SetEditBoxPosition(10, 590, 120 )
SetEditBoxSize(10, 60, 20 )
FixEditBoxToScreen(10,1)
SetEditBoxMaxChars(10,4)
SetEditBoxTextSize(10,100)
SetEditBoxText(10,str(fwheelFriction, 1))

CreateText(14, "Elasticity:")
SetTextPosition(14, 540,140)
FixTextToScreen(14,1)
SetTextBold(14,1)
SetTextColor(14,0,0,0,255)
SetTextSize(14,20)

global bwRestitution as float, fwRestitution as float

CreateEditBox(11)
SetEditBoxPosition(11, 510, 160 )
SetEditBoxSize(11, 60, 20 )
FixEditBoxToScreen(11,1)
SetEditBoxMaxChars(11,4)
SetEditBoxTextSize(11,100)
SetEditBoxText(11,str(bwRestitution, 2))

CreateEditBox(12)
SetEditBoxPosition(12, 590, 160 )
SetEditBoxSize(12, 60, 20 )
FixEditBoxToScreen(12,1)
SetEditBoxMaxChars(12,4)
SetEditBoxTextSize(12,100)
SetEditBoxText(12,str(fwRestitution, 2))

CreateText(15, "Air resistance:")
SetTextPosition(15, 525,180)
FixTextToScreen(15,1)
SetTextBold(15,1)
SetTextColor(15,0,0,0,255)
SetTextSize(15,20)

global bwDamping as float, fwdamping as float

CreateEditBox(13)
SetEditBoxPosition(13, 510, 200 )
SetEditBoxSize(13, 60, 20 )
FixEditBoxToScreen(13,1)
SetEditBoxMaxChars(13,4)
SetEditBoxTextSize(13,100)
SetEditBoxText(13,str(bwDamping, 2))

CreateEditBox(14)
SetEditBoxPosition(14, 590, 200 )
SetEditBoxSize(14, 60, 20 )
FixEditBoxToScreen(14,1)
SetEditBoxMaxChars(14,4)
SetEditBoxTextSize(14,100)
SetEditBoxText(14,str(fwdamping, 2))

// Drive TEXT/EDIT
CreateText(16, "Drive")
SetTextPosition(16, 680,10)
FixTextToScreen(16,1)
SetTextBold(16,1)
SetTextColor(16,0,0,0,255)
SetTextSize(16,30)

CreateText(17, "RWD")
SetTextPosition(17, 680,45)
FixTextToScreen(17,1)
SetTextBold(17,1)
SetTextColor(17,0,0,0,255)
SetTextSize(17,20)

CreateText(18, "FWD")
SetTextPosition(18, 680,65)
FixTextToScreen(18,1)
SetTextBold(18,1)
SetTextColor(18,0,0,0,255)
SetTextSize(18,20)

CreateText(19, "AWD")
SetTextPosition(19, 680,85)
FixTextToScreen(19,1)
SetTextBold(19,1)
SetTextColor(19,0,0,0,255)
SetTextSize(19,20)

global Radio_1, Radio_2, Radio_3, RadioOnImg, RadioOffImg
global RadioState=1
RadioOnImg=LoadImage("gui/radioON.png")
RadioOffImg=LoadImage("gui/radioOFF.png")
Radio_1=CreateSprite(RadioOffImg)
Radio_2=CloneSprite(Radio_1)
Radio_3=CloneSprite(Radio_1)
SetSpritePosition(Radio_1, 725, 45)
SetSpritePosition(Radio_2, 725, 65)
SetSpritePosition(Radio_3, 725, 85)
FixSpriteToScreen(Radio_1,1)
FixSpriteToScreen(Radio_2,1)
FixSpriteToScreen(Radio_3,1)
SetSpriteImage(Radio_1,RadioOnImg)

// Engine TEXT/EDIT
global powerEngine=70
global forceEngine=999999
CreateText(20, "Engine")
SetTextPosition(20, 790,10)
FixTextToScreen(20,1)
SetTextBold(20,1)
SetTextColor(20,0,0,0,255)
SetTextSize(20,30)

CreateText(21, "Power:")
SetTextPosition(21, 770,45)
FixTextToScreen(21,1)
SetTextBold(21,1)
SetTextColor(21,0,0,0,255)
SetTextSize(21,20)

CreateText(22, "Force:")
SetTextPosition(22, 770,75)
FixTextToScreen(22,1)
SetTextBold(22,1)
SetTextColor(22,0,0,0,255)
SetTextSize(22,20)

CreateEditBox(15)
SetEditBoxPosition(15, 835, 45 )
SetEditBoxSize(15, 60, 20 )
FixEditBoxToScreen(15,1)
SetEditBoxMaxChars(15,4)
SetEditBoxTextSize(15,100)
SetEditBoxText(15,str(powerEngine))

CreateEditBox(16)
SetEditBoxPosition(16, 835, 75 )
SetEditBoxSize(16, 75, 20 )
FixEditBoxToScreen(16,1)
SetEditBoxMaxChars(16,8)
SetEditBoxTextSize(16,100)
SetEditBoxText(16,str(forceEngine))

// Break TEXT/EDIT
global forceBreak=1000
CreateText(23, "Break")
SetTextPosition(23, 960,10)
FixTextToScreen(23,1)
SetTextBold(23,1)
SetTextColor(23,0,0,0,255)
SetTextSize(23,30)

CreateText(24, "Force:")
SetTextPosition(24, 940,45)
FixTextToScreen(24,1)
SetTextBold(24,1)
SetTextColor(24,0,0,0,255)
SetTextSize(24,20)

CreateEditBox(17)
SetEditBoxPosition(17, 1000, 45 )
SetEditBoxSize(17, 60, 20 )
FixEditBoxToScreen(17,1)
SetEditBoxMaxChars(17,5)
SetEditBoxTextSize(17,100)
SetEditBoxText(17,str(forceBreak))

CreateText(25, "Back")
SetTextPosition(25, 940,70)
FixTextToScreen(25,1)
SetTextBold(25,1)
SetTextColor(25,0,0,0,255)
SetTextSize(25,20)

CreateText(26, "Front")
SetTextPosition(26, 940,90)
FixTextToScreen(26,1)
SetTextBold(26,1)
SetTextColor(26,0,0,0,255)
SetTextSize(26,20)

CreateText(27, "Full")
SetTextPosition(27, 940,110)
FixTextToScreen(27,1)
SetTextBold(27,1)
SetTextColor(27,0,0,0,255)
SetTextSize(27,20)

global RadioB_1, RadioB_2, RadioB_3, RadioBOnImg, RadioBOffImg
global RadioBreakState=1
RadioBOnImg=LoadImage("gui/radioON.png")
RadioBOffImg=LoadImage("gui/radioOFF.png")
RadioB_1=CreateSprite(RadioBOffImg)
RadioB_2=CloneSprite(RadioB_1)
RadioB_3=CloneSprite(RadioB_1)
SetSpritePosition(RadioB_1, 1000, 70)
SetSpritePosition(RadioB_2, 1000, 90)
SetSpritePosition(RadioB_3, 1000, 110)
FixSpriteToScreen(RadioB_1,1)
FixSpriteToScreen(RadioB_2,1)
FixSpriteToScreen(RadioB_3,1)
SetSpriteImage(RadioB_1,RadioBOnImg)

// Suspension TEXT/EDIT
global cofSuspension as float = 0.7
global rateSuspension = 2

CreateText(28, "Suspension")
SetTextPosition(28, 1110,10)
FixTextToScreen(28,1)
SetTextBold(28,1)
SetTextColor(28,0,0,0,255)
SetTextSize(28,30)

CreateText(29, "Ratio(0 to 1):")
SetTextPosition(29, 1090,45)
FixTextToScreen(29,1)
SetTextBold(29,1)
SetTextColor(29,0,0,0,255)
SetTextSize(29,20)

CreateText(30, "Rate(max 30):")
SetTextPosition(30, 1090,75)
FixTextToScreen(30,1)
SetTextBold(30,1)
SetTextColor(30,0,0,0,255)
SetTextSize(30,20)

CreateEditBox(18)
SetEditBoxPosition(18, 1210, 45 )
SetEditBoxSize(18, 60, 20 )
FixEditBoxToScreen(18,1)
SetEditBoxMaxChars(18,3)
SetEditBoxTextSize(18,100)
SetEditBoxText(18,str(cofSuspension,1))

CreateEditBox(19)
SetEditBoxPosition(19, 1210, 75 )
SetEditBoxSize(19, 60, 20 )
FixEditBoxToScreen(19,1)
SetEditBoxMaxChars(19,2)
SetEditBoxTextSize(19,100)
SetEditBoxText(19,str(rateSuspension))

// Save
AddVirtualButton(6, 1375, 60, 100)
SetVirtualButtonText(6, "SAVE")
SetVirtualButtonSize(6, 160,90)
SetVirtualButtonAlpha(6,255)
//
PhysicsState=0
global HalfScreenWidth
global HalfScreenHeight
HalfScreenWidth=GetVirtualWidth()*0.5
HalfScreenHeight=GetVirtualHeight()*0.5
global body, f_wheel, b_wheel, gearID = 1

do
    PhysicsUpdate()
    PlayerX#=GetSpriteXByOffset(body)
	if CamMode=1
		SetViewOffset(PlayerX#-HalfScreenWidth+200,0)
	elseif CamMode=0
		SetViewOffset(getViewOffsetX()+(getVirtualJoystickX(1)/getViewZoom())*3.0,getViewOffsetY()+(getVirtualJoystickY(1))/getViewZoom()*3.0)
	endif
    if getVirtualButtonState(1)>0
		setViewZoom(getViewZoom()+0.05)
	endif
    if getVirtualButtonState(2)>0
		setViewZoom(getViewZoom()-0.05)
	endif
	if GetVirtualButtonState(4)=1 // ТОРМОЗ
		if RadioBreakState=1
			SetSpritePhysicsAngularDamping(b_wheel,forceBreak)
		elseif RadioBreakState=2
			SetSpritePhysicsAngularDamping(f_wheel,forceBreak)
		elseif RadioBreakState=3
			SetSpritePhysicsAngularDamping(b_wheel,forceBreak)
			SetSpritePhysicsAngularDamping(f_wheel,forceBreak)
		else
		endif
	else
		SetSpritePhysicsAngularDamping(b_wheel,bwdamping)
		SetSpritePhysicsAngularDamping(f_wheel,fwdamping)
	endif
	if GetVirtualButtonState(5)=1  // ГАЗ
		if gearID = 1
			if RadioState=1
				SetJointMotorOn(WheelBackJointID,powerEngine,forceEngine)
			elseif RadioState=2
				SetJointMotorOn(WheelFrontJointID,powerEngine,forceEngine)
			elseif RadioState=3
				SetJointMotorOn(WheelBackJointID,powerEngine,forceEngine)
				SetJointMotorOn(WheelFrontJointID,powerEngine,forceEngine)
			else
			endif
		elseif gearID = -1
			if RadioState=1
				SetJointMotorOn(WheelBackJointID,-6,forceEngine)
			elseif RadioState=2
				SetJointMotorOn(WheelFrontJointID,-6,forceEngine)
			elseif RadioState=3
				SetJointMotorOn(WheelBackJointID,-6,forceEngine)
				SetJointMotorOn(WheelFrontJointID,-6,forceEngine)
			else
			endif
		endif
	else
		SetJointMotorOff(WheelBackJointID)
		SetJointMotorOff(WheelFrontJointID)
	endif
	if GetPointerPressed() = 1
		if GetSpriteHitTest(GearboxID,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1 // Transmission
			If gearID = 1
				SetSpriteImage(GearboxID,GearboxRImage)
				gearID = -1
			Else
				SetSpriteImage(GearboxID,GearboxDImage)
				gearID = 1
			EndIf
		EndIf
		if GetSpriteHitTest(PhysicsDisplayButton,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1 // Physics display button
			If PhysicsState=0
				SetSpriteImage(PhysicsDisplayButton,BtPhysicsOnImage)
				SetPhysicsDebugOn()
				PhysicsState=1
			Else
				SetSpriteImage(PhysicsDisplayButton,BtPhysicsOffImage)
				SetPhysicsDebugOff()
				PhysicsState=0
			EndIf
		EndIf
		if GetSpriteHitTest(FreeCamButton,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1 // Switching camera mode
			If CamMode=1
				SetSpriteImage(FreeCamButton,FreeCamOnImage)
				CamMode=0
			Else
				SetSpriteImage(FreeCamButton,FreeCamOffImage)
				CamMode=1
			EndIf
		EndIf
		if GetSpriteHitTest(CarEditButton,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1 // Switching car edit button
			If CarEditMode=1
				SetSpriteImage(CarEditButton,CarEditOffImage)
				SetSpritePhysicsOn(body,2)
				SetSpritePhysicsOn(b_wheel,2)
				SetSpritePhysicsOn(f_wheel,2)
				UpdateSetCar()
				CarEditMode=0
			Elseif CarEditMode=0
				SetSpriteImage(CarEditButton,CarEditOnImage)
				SetSpritePhysicsOff(body)
				SetSpritePhysicsOff(b_wheel)
				SetSpritePhysicsOff(f_wheel)
				CarEditMode=1
			EndIf
		EndIf
	Endif
	if getPointerPressed()=1
		hit = getSpriteHitTest(body, ScreenToWorldX(getPointerX()), ScreenToWorldY(getPointerY()))
		hit_b_w = getSpriteHitTest(b_wheel, ScreenToWorldX(getPointerX()), ScreenToWorldY(getPointerY()))
		hit_f_w = getSpriteHitTest(f_wheel, ScreenToWorldX(getPointerX()), ScreenToWorldY(getPointerY()))
		if hit>0
			rem sprite picked up
			picked = body
			pX = getPointerX()
			pY = getPointerY()
		endif
		if hit_b_w>0 and CarEditMode=1
			rem sprite picked up
			picked = b_wheel
			pX = getPointerX()
			pY = getPointerY()
		endif
		if hit_f_w>0 and CarEditMode=1
			rem sprite picked up
			picked = f_wheel
			pX = getPointerX()
			pY = getPointerY()
		endif
	else
		if picked>0
			if getPointerState()>0
				rem Sprite being dragged
				cX = getPointerX()
				cY = getPointerY()
				setSpritePosition(picked,getSpriteX(picked)+cX-pX,getSpriteY(picked)+cY-pY)
				pX = cX
				pY = cY
			else
				rem Sprite Dropped
				picked=0
			endif
		endif
	endif
	if GetEditBoxChanged(1)=1 then pGravity= val(GetEditBoxText(1)) // Gravity
	if GetEditBoxChanged(3)=1 then bodyMass= Val(GetEditBoxText(3)) // Body mass
	if GetEditBoxChanged(4)=1 then bodyFriction= ValFloat(GetEditBoxText(4)) // Body friction
	if GetEditBoxChanged(5)=1 then bodyRestitution= ValFloat(GetEditBoxText(5)) // Bounced body
	if GetEditBoxChanged(6)=1 then bodyDamping= ValFloat(GetEditBoxText(6)) // Body air resistance
	
	if GetEditBoxChanged(7)=1 then BwheelMass=ValFloat(GetEditBoxText(7)) // Rear wheel mass
	if GetEditBoxChanged(8)=1 then FwheelMass=ValFloat(GetEditBoxText(8)) // Front wheel mass
	if GetEditBoxChanged(9)=1 then BwheelFriction=ValFloat(GetEditBoxText(9)) // Rear wheel friction
	if GetEditBoxChanged(10)=1 then FwheelFriction=ValFloat(GetEditBoxText(10)) // Front wheel friction
	if GetEditBoxChanged(11)=1 then bwRestitution= ValFloat(GetEditBoxText(11)) // Bounced rear wheel
	if GetEditBoxChanged(12)=1 then fwRestitution= ValFloat(GetEditBoxText(12)) // Bounced front wheel
	if GetEditBoxChanged(13)=1 then bwdamping= ValFloat(GetEditBoxText(13)) // Rear wheel air resistance
	if GetEditBoxChanged(14)=1 then fwdamping= ValFloat(GetEditBoxText(14)) // Front wheel air resistance
	if GetEditBoxChanged(15)=1 then powerEngine= Val(GetEditBoxText(15)) // Engine power
	if GetEditBoxChanged(16)=1 then forceEngine= Val(GetEditBoxText(16)) // Engine force
	if GetEditBoxChanged(17)=1 then forceBreak= Val(GetEditBoxText(17)) // Break force
	
	Speedometr()
	Privod()
	BreakType()
	hardSus()
	if GetVirtualButtonReleased(6)=1 // Save
		SaveSetCar()
	endif
    Sync()
loop

Function PhysicsUpdate()
	SetPhysicsGravity(0,pGravity) // Gravity
	SetSpritePhysicsMass(body, bodyMass) // Body mass
	SetSpritePhysicsMass(b_wheel, BwheelMass) // Rear wheel mass
	SetSpritePhysicsMass(f_wheel, FwheelMass) // Front wheel mass
	SetSpritePhysicsFriction(body, bodyFriction) // Body friction
	SetSpritePhysicsFriction(b_wheel, BwheelFriction) // Rear wheel friction
	SetSpritePhysicsFriction(f_wheel, FwheelFriction) // Front wheel friction
	SetSpritePhysicsRestitution(body, bodyRestitution) // Bounced body
	SetSpritePhysicsDamping(body, bodyDamping) // Body air resistance
	SetSpritePhysicsRestitution(b_wheel,bwRestitution) // Bounced rear wheel
	SetSpritePhysicsRestitution(f_wheel,fwRestitution) // Bounced front wheel
	SetSpritePhysicsAngularDamping(b_wheel,bwdamping) // Rear wheel air resistance
	SetSpritePhysicsAngularDamping(f_wheel,fwdamping) // Front wheel air resistance
	
EndFunction

Function Speedometr()
	r=GetSpritePhysicsVelocityX(body)/5
	if gearID=1
		if r>=0 then currentSpeed=r
		if r<0 then currentSpeed=0
		if r>180 then currentSpeed=180
	elseif gearID=-1
		if r<0 then currentSpeed=Abs(r)
	endif
	SetSpriteAngle(SpeedArrowSprite, currentSpeed)
EndFunction

Function Privod()
	if GetPointerPressed() = 1
		if GetSpriteHitTest(Radio_1,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1
			If RadioState = 2 or RadioState = 3
				SetSpriteImage(Radio_1,RadioOnImg)
				SetSpriteImage(Radio_2,RadioOffImg)
				SetSpriteImage(Radio_3,RadioOffImg)
				RadioState=1
			EndIf
		EndIf
		if GetSpriteHitTest(Radio_2,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1
			If RadioState = 1 or RadioState = 3
				SetSpriteImage(Radio_1,RadioOffImg)
				SetSpriteImage(Radio_2,RadioOnImg)
				SetSpriteImage(Radio_3,RadioOffImg)
				RadioState=2
			EndIf
		EndIf
		if GetSpriteHitTest(Radio_3,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1
			If RadioState = 1 or RadioState = 2
				SetSpriteImage(Radio_1,RadioOffImg)
				SetSpriteImage(Radio_2,RadioOffImg)
				SetSpriteImage(Radio_3,RadioOnImg)
				RadioState=3
			EndIf
		EndIf
	Endif
EndFunction

Function BreakType()
	if GetPointerPressed() = 1
		if GetSpriteHitTest(RadioB_1,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1
			If RadioBreakState = 2 or RadioBreakState = 3
				SetSpriteImage(RadioB_1,RadioBOnImg)
				SetSpriteImage(RadioB_2,RadioBOffImg)
				SetSpriteImage(RadioB_3,RadioBOffImg)
				RadioBreakState=1
			EndIf
		EndIf
		if GetSpriteHitTest(RadioB_2,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1
			If RadioBreakState = 1 or RadioBreakState = 3
				SetSpriteImage(RadioB_1,RadioBOffImg)
				SetSpriteImage(RadioB_2,RadioBOnImg)
				SetSpriteImage(RadioB_3,RadioBOffImg)
				RadioBreakState=2
			EndIf
		EndIf
		if GetSpriteHitTest(RadioB_3,ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = 1
			If RadioBreakState = 1 or RadioBreakState = 2
				SetSpriteImage(RadioB_1,RadioBOffImg)
				SetSpriteImage(RadioB_2,RadioBOffImg)
				SetSpriteImage(RadioB_3,RadioBOnImg)
				RadioBreakState=3
			EndIf
		EndIf
	Endif
EndFunction

Function hardSus()
	if GetEditBoxChanged(18)=1 or GetEditBoxChanged(19)=1
		cofSuspension=ValFloat(GetEditBoxText(18))
		rateSuspension=Val(GetEditBoxText(19))
		SetJointDamping(WheelFrontJointID,cofSuspension,rateSuspension)
		SetJointDamping(WheelBackJointID,cofSuspension,rateSuspension)
	endif
EndFunction

Function UpdateSetCar()
	bodyX = GetSpriteXByOffset(body)
	bodyY = GetSpriteYByOffset(body)
	
	b_wheel_x = GetSpriteXByOffset(b_wheel)
	b_wheel_y = GetSpriteYByOffset(b_wheel)
	f_wheel_x = GetSpriteXByOffset(f_wheel)
	f_wheel_y = GetSpriteYByOffset(f_wheel)
	
	DeleteJoint(WheelFrontJointID)
	DeleteJoint(WheelBackJointID)
	
	WheelBackJointID=CreateLineJoint(body,b_wheel,b_wheel_x,b_wheel_y,0,7,0)
	WheelFrontJointID=CreateLineJoint(body,f_wheel,f_wheel_x,f_wheel_y,0,7,0)
	
EndFunction

Function SaveSetCar()
	bodyX = GetSpriteXByOffset(body)
	bodyY = GetSpriteYByOffset(body)
	
	b_wheel_x = GetSpriteXByOffset(b_wheel)
	b_wheel_y = GetSpriteYByOffset(b_wheel)
	f_wheel_x = GetSpriteXByOffset(f_wheel)
	f_wheel_y = GetSpriteYByOffset(f_wheel)
	
	Filename$ = "raw:C:\CarSet\carset.txt"
	
	FN=OpenToWrite(Filename$)
	Note$="C:\CarSet\carset.txt"
	
	writeline(FN,"// Global physics settings")
	writeline(FN,"SetPhysicsScale("+str(pScale,2)+")")
	writeline(FN,"SetPhysicsGravity(0,"+str(pGravity)+")")
	writeline(FN,"")
	writeline(FN,"//Create car")
	writeline(FN,"body=CreateSprite(LoadImage('body.png')) // download the file of the car body")
	writeline(FN,"f_wheel=CreateSprite(LoadImage('f_wheel.png')) // uploading the front wheel file")
	writeline(FN,"b_wheel=CreateSprite(LoadImage('b_wheel.png')) // uploading the rear wheel file")
	writeline(FN,"")
	writeline(FN,"SetSpritePositionByOffset(body,"+str(bodyX)+","+str(bodyY)+") // setting the coordinates of the body ")
	writeline(FN,"SetSpritePositionByOffset(b_wheel,"+str(b_wheel_x)+","+str(b_wheel_y)+") // setting the coordinates of the rear wheel")
	writeline(FN,"SetSpritePositionByOffset(f_wheel,"+str(f_wheel_x)+","+str(f_wheel_y)+") // setting the coordinates of the front wheel")
	writeline(FN,"")
	writeline(FN,"//Turning on physics for cars")
	writeline(FN,"SetSpriteShape(body,3)")
	writeline(FN,"SetSpriteShape(f_wheel,1)")
	writeline(FN,"SetSpriteShape(b_wheel,1)")
	writeline(FN,"SetSpritePhysicsOn(body,2)")
	writeline(FN,"SetSpritePhysicsOn(f_wheel,2)")
	writeline(FN,"SetSpritePhysicsOn(b_wheel,2)")
	writeline(FN,"")
	writeline(FN,"//Create joints")
	writeline(FN,"WheelBackJointID=CreateLineJoint(body,b_wheel,"+str(b_wheel_x)+","+str(b_wheel_y)+",0,7,0) // Create rear wheel joint")
	writeline(FN,"WheelFrontJointID=CreateLineJoint(body,f_wheel,"+str(f_wheel_x)+","+str(f_wheel_y)+",0,7,0) // Create front wheel joint")
	writeline(FN,"")
	writeline(FN,"//Setting up Physics")
	writeline(FN,"")
	writeline(FN,"//Setting up Body Physics")
	writeline(FN,"SetSpritePhysicsMass(body,"+str(bodyMass)+") // Car mass")
	writeline(FN,"SetSpritePhysicsFriction(body,"+str(bodyFriction,2)+") // Car friction")
	writeline(FN,"SetSpritePhysicsRestitution(body,"+str(bodyRestitution,2)+") // Elasticity of car")
	writeline(FN,"SetSpritePhysicsDamping(body,"+str(bodyDamping,2)+") // Car air resistance")
	writeline(FN,"")
	writeline(FN,"//Setting up Wheels Physics")
	writeline(FN,"SetSpritePhysicsMass(b_wheel,"+str(BwheelMass)+") // Rear wheel weight")
	writeline(FN,"SetSpritePhysicsMass(f_wheel,"+str(FwheelMass)+") // Front wheel weight")
	writeline(FN,"SetSpritePhysicsFriction(b_wheel,"+str(BwheelFriction,2)+") // Rear wheel friction")
	writeline(FN,"SetSpritePhysicsFriction(f_wheel,"+str(FwheelFriction,2)+") // Front wheel friction")
	writeline(FN,"SetSpritePhysicsRestitution(b_wheel,"+str(bwRestitution,2)+") // Elasticity of the rear wheel")
	writeline(FN,"SetSpritePhysicsRestitution(f_wheel,"+str(fwRestitution,2)+") // Elasticity of the front wheel")
	writeline(FN,"SetSpritePhysicsAngularDamping(b_wheel,"+str(bwdamping,2)+") //Rear wheel air resistance")
	writeline(FN,"SetSpritePhysicsAngularDamping(f_wheel,"+str(fwdamping,2)+") //Front wheel air resistance")
	writeline(FN,"")
	writeline(FN,"// Engine - insert the code for your drive type into the acceleration button handler.  Or both lines for all-wheel drive.")
	writeline(FN,"SetJointMotorOn(WheelBackJointID,"+str(powerEngine)+","+str(forceEngine)+") // RWD")
	writeline(FN,"SetJointMotorOn(WheelFrontJointID,"+str(powerEngine)+","+str(forceEngine)+") // FWD")
	writeline(FN,"")
	writeline(FN,"// Break - insert the code for your type of brakes into the brake button handler.  Either both lines for a full brake.")
	writeline(FN,"SetSpritePhysicsAngularDamping(b_wheel,"+str(forceBreak)+") // Rear brakes)")
	writeline(FN,"SetSpritePhysicsAngularDamping(f_wheel,"+str(forceBreak)+") // Front brakes")
	writeline(FN,"")
	writeline(FN,"// Suspencion")
	writeline(FN,"SetJointDamping(WheelFrontJointID,"+str(cofSuspension,2)+","+str(rateSuspension)+")")
	writeline(FN,"SetJointDamping(WheelBackJointID,"+str(cofSuspension,2)+","+str(rateSuspension)+")")
	
	CloseFile(FN)
	
	ok= RunApp( 'Notepad.exe',Note$ )
EndFunction
