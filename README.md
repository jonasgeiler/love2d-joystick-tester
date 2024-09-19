# love2d-joystick-tester

> A simple [LÖVE][love2d] application to test joysticks and gamepads.

This is a simple desktop application to view all detected joysticks/gamepads,
check vibration and see all reported values.  
It can be used to check for [stick drift][stick-drift] and other hardware issues,
or just to learn about using joysticks/gamepads with [LÖVE][love2d].

I initially wrote this application many years ago, and it was much more basic
before I rewrote it.  
If you want to see the old version, check out the [`old-version`][old-version] tag.

## Screenshot

![Screenshot](https://github.com/user-attachments/assets/612a4048-1ce7-4dee-abc6-6cf6530ec3bf)

## Requirements

- LÖVE 11.4 (Mysterious Mysteries)

## How to try

Download the latest release for your OS from the [releases page][releases] and
install it however you want.

> [!IMPORTANT]
> Unfortunately, a macOS package is not being provided at the moment.
> You'll have to download the `.love` file and run it with [LÖVE][love2d].

If you want to try running it from source instead, download the repository and
then run `love`:

```bash
love ./joysticktester/
```

[love2d]: https://love2d.org/
[stick-drift]: https://www.makeuseof.com/what-is-joystick-drift/
[old-version]: https://github.com/jonasgeiler/love2d-joystick-tester/tree/old-version
[releases]: https://github.com/jonasgeiler/love2d-joystick-tester/releases
