# StarChart
The beta charter for the beta Beatstar clone, Clone Star

## What is it?
Well, as the tagline(?) says, it lets you chart Clone Star songs.

## Current features
- Creating and editing .json charts
- Attach an mp3 or ogg file as the song (ogg not tested yet, submit an issue if needed)
- Chart note lanes, and timings
- Export as a .json that can be read by Clonestar
- Play / Pause song as you're charting
- Speed control (s to slow down, w to speed up)

## Planned Features
- Held notes
- Swipe notes
- Easier playback controls (see quirks)
- Custom music location saving (see quirks)

## Charting
- Notes can be placed either by clicking in their respective lane, or by using 1, 2, or 3.
- If using a mouse it will offset by how high or low about the center you are
- The line in the middle is the present, and the top and bottom of the screen corresponds to -1s, and +1s.

## Quirks
- You can kindof rewind with the upwards scroll wheel, however it is very hard to do so<br>
I currently have it pause as soon as you scroll, and while I would like to make it work when paused, as far as I can tell it isn't a feature in godot, or at least my current implementation of the AudioStreamPlayer.
- When importing the song on android, you will need some kind of text editor to modify the json, specifically where the music file is stored.
<hr>
Please dont critize the code too harshly, i'm still learning Godot.

Bug fixes and improvements are welcome.
