; Event Pump w/ Saved State for the Infinity 3-Pedal HID Input Device
; Current version by Cuyler Stuwe (salembeats).

; The majority of the code (the entirety of the lower-level code) was written by others and is credited below:

; Original script credit:
; http://musingsfromtheunderground.blogspot.com/2011/05/dream-autohotkey-powered-foot-pedal-for.html

; Credit for adapting to 64-bit AHK:
; https://autohotkey.com/board/topic/91506-broken-dllcall-to-registerrawinputdevices/?p=577346

#Persistent ; Not needed b/c of OnMessage, but nice to have here for clarity anyway.

#include AHKHID.ahk
#include Bin2Hex.ahk

; ============================================================================ ;
;                            PEDAL STATE VARIABLES.                            ;
; ============================================================================ ;

LastLeftPedalState := "Up"
LastMiddlePedalState := "Up"
LastRightPedalState := "Up"

LastPressedPedal := "None"

; ============================================================================ ;
;                             EVENT PUMP SECTION.                              ;
; ============================================================================ ;

; ======  DOWN EVENTS  ======

onLeftDown() {
    ; Default behavior. Feel free to remove this to customize behavior.
    SendInput {CtrlDown}
}

onMiddleDown() {
    ; Default behavior. Feel free to remove this to customize behavior.
    SendInput {ShiftDown}
}

onRightDown() {
    ; Default behavior. Feel free to remove this to customize behavior.
    SendInput {AltDown}
}

; =======  UP EVENTS  =======

onLeftUp() {
    ; Default behavior. Feel free to remove this to customize behavior.
    SendInput {CtrlUp}
}

onMiddleUp() {
    ; Default behavior. Feel free to remove this to customize behavior.
    SendInput {ShiftUp}
}

onRightUp() {
    ; Default behavior. Feel free to remove this to customize behavior.
    SendInput {AltUp}
}

onLeftStateChange() {
}

onMiddleStateChange() {
}

onRightStateChange() {
}

; ============================================================================ ;
;   DON'T EDIT ANYTHING BELOW THIS LINE UNLESS YOU MEAN TO CHANGE THE SYSTEM.  ;
; ============================================================================ ;

LeftDown() {
    global LastLeftPedalState
    global LastPressedPedal
    onLeftStateChange()
    onLeftDown()
    LastLeftPedalState := "Down"
    LastPressedPedal := "Left"
}

MiddleDown() {
    global LastMiddlePedalState
    global LastPressedPedal
    onMiddleStateChange()
    onMiddleDown()
    LastMiddlePedalState := "Down"
    LastPressedPedal := "Middle"
}

RightDown() {
    global LastRightPedalState
    global LastPressedPedal
    onRightStateChange()
    onRightDown()
    LastRightPedalState := "Down"
    LastPressedPedal := "Right"
}

LeftUp() {
    global LastLeftPedalState
    onLeftStateChange()
    onLeftUp()
    LastLeftPedalState := "Up"
}

MiddleUp() {
    global LastMiddlePedalState
    onMiddleStateChange()
    onMiddleUp()
    LastMiddlePedalState := "Up"
}

RightUp() {
    global LastRightPedalState
    onRightStateChange()
    onRightUp()
    LastRightPedalState := "Up"
}

DetectHiddenWindows, on
HWND_MINE := WinExist("ahk_class AutoHotkey ahk_pid " DllCall("GetCurrentProcessId"))
OutputDebug, tweak.ahk Running w/ Handle: %HWND_MINE%
DetectHiddenWindows, off

OnMessage(0x00FF, "InputMessage")

USAGE_PAGE_FOOTPEDAL := 12
USAGE_FOOTPEDAL := 3

AHKHID_Register(USAGE_PAGE_FOOTPEDAL, USAGE_FOOTPEDAL, HWND_MINE, RIDEV_INPUTSINK)

InputMessage(wParam, lParam, msg, hwnd) {
    
    Local r, h
    
    Critical
    
    r := AHKHID_GetInputInfo(lParam, II_DEVTYPE)
    
    If (r = RIM_TYPEHID) {
        
        h := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
        r := AHKHID_GetInputData(lParam, uData)
    
        vendor_id := AHKHID_GetDevInfo(h, DI_HID_VENDORID, True)
        product_id := AHKHID_GetDevInfo(h, DI_HID_PRODUCTID,True)
    
        data := Bin2Hex(&uData, r)
        
        If(data = "000100") {
            OutputDebug, Left Down
            LeftDown()
        }
        Else If(data = "000200") {
            OutputDebug, MiddleDown
            MiddleDown()
        }
        Else If(data = "000400") {
            OutputDebug, RightDown
            RightDown()
        }
        Else If(data = "000000") {
            
            OutputDebug, LastPedalReleased %LastPressedPedal%
        
            If(LastPressedPedal = "Left") {
                LeftUp()
            }
            Else If(LastPressedPedal = "Middle") {
                MiddleUp()
            }
            Else If(LastPressedPedal = "Right") {
                RightUp()
            }
        }
    
        ; Uncomment to show the info.
        ; OutputDebug, InputMessage vendor: [%vendor_id%] product: [%product_id%] data: [%data%]
        
    }
}

Return