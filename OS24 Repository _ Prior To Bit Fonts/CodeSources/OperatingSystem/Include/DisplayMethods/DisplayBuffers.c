#include "../Headers/DataTypes.h"

#define blue 0x000000FF
#define red  0x00FF0000
#define white 0xFFFFFFFF
#define test 0x12243648

struct pointsdelegate
{
    uint32 ModeInfoBlockAddress, ModeInfoBlockOffset;
    void(* ResetDisplay)(), (* SetGUI)();
    uint16 Width, Height, X, Y;
};

void DrawPixel(struct pointsdelegate* display)
{
    // From right to left:
    // Assigning frameBuffer to a 32 bit datatype
    // Dereferencing it to show the value of the address
    // Turning it into a pointer to those 32 bits
    // Setting up another pointer to that pointer,
    // so that one pointer allows iteration between the second
    uint32* FrameBuffer = (uint32*)*(uint32*)display->ModeInfoBlockOffset;

    display->Y = ((display->Height)/2);
    display->X = ((display->Width)/2);

    FrameBuffer += (display->Y * 1920 + display->X);
    *FrameBuffer = red;

    return;
}

void SetDisplay(struct pointsdelegate* display, void * delegate())
{
    uint32* FrameBuffer = (uint32*)*(uint32*)display->ModeInfoBlockOffset;
    
    for (uint32 pixel = 0; pixel < 1920*1080; pixel++)
    {
        // Each row has a block of 1920 pixels (that's how long it is)
        // For every Y column up you go, there is 1920 x 32bpp of space
        // Therefore, each Y location as a sectional row must be multiplied by 1920
        // To find its location in linear space (memory array)
        // To further dereference the pixel itself, it needs to be broken down by 32bpp
        // The mode info block is 32 bits per address (pixel).
        FrameBuffer[pixel] = test;
    }

    delegate(display);
    DrawPixel(display);

    return;
}

void SetTopStickyBox(struct pointsdelegate* display)
{
    uint32* FrameBuffer = (uint32*)*(uint32*)display->ModeInfoBlockOffset;

    for (uint32 pixel = 0; pixel < display->Width; pixel++)
    {
        FrameBuffer[pixel] = white;
    }

    display->Y = 24;

    for (uint32 pixel = 0; pixel < display->Width; pixel++)
    {
        FrameBuffer[pixel + (display->Y * display->Width)] = white;
    }

    display->X = 0;

    for (display->Y = 0; display->Y < 24; display->Y++)
    {
        FrameBuffer[(display->Y * display->Width) + display->X] = white;
    }

    display->X = display->Width - 1;

    for (display->Y = 0; display->Y < 24; display->Y++)
    {
        FrameBuffer[(display->Y * display->Width) + display->X] = white;
    }

    return;
}