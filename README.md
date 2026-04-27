# afmt
Odin printing library with support for ANSI colors and attributes. The goal is to mirror the existing core:fmt library to provide a seamless alternative.

* afmt (a for ansi) is designed to be used as a collection.
* Reference examples.odin for idiomatic patterns for each procedure in the library.
## Odin License:
https://github.com/odin-lang/Odin/blob/master/LICENSE
## afmt License:
This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

## Steps
1. Clone afmt into odin/shared folder:
   ```bash
   cd $(odin root)shared
   git clone https://github.com/OnlyXuul/afmt.git
   ```
2. To use the library, add to the top of your project file:
   ```odin
   import "shared:afmt"
   ```
3. To run usage examples:
   ```bash
   cd $(odin root)shared/afmt/examples
   odin run .
   ```
## Example Output
![Alt text](/screenshots/screenshot01.jpg?raw=true)
![Alt text](/screenshots/screenshot02.jpg?raw=true)
![Alt text](/screenshots/screenshot03.jpg?raw=true)
![Alt text](/screenshots/screenshot04.jpg?raw=true)
![Alt text](/screenshots/screenshot05.jpg?raw=true)
![Alt text](/screenshots/screenshot06.jpg?raw=true)
![Alt text](/screenshots/screenshot07.jpg?raw=true)
