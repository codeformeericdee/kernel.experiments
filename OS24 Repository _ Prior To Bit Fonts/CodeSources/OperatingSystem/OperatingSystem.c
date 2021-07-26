#include "Include/DisplayMethods/DisplayBuffers.c"

void OperatingSystem()
{
    struct pointsdelegate Display = 
    {
        Display.ModeInfoBlockAddress = 0x6000,
        Display.ModeInfoBlockOffset = Display.ModeInfoBlockAddress + 40,
        Display.ResetDisplay = SetDisplay,
        Display.SetGUI = SetTopStickyBox,
        Display.Width = 1920, 
        Display.Height = 1080,
        Display.X = 0,
        Display.Y = 0,
    }; // Needs a constructor

    Display.ResetDisplay(&Display, Display.SetGUI);
    return;
}