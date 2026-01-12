# afmt
Odin printing library that supports ANSI for color and attributes. The goal is to mirror the existing core:fmt library to provide a seamless alternative that includes support for ANSI.

License
https://github.com/odin-lang/Odin/blob/master/LICENSE

afmt (a for ansi) is designed to be used as a collection. If you already have a collection folder created for Odin, create an "afmt" folder inside that. Place afmt.odin and colors.odin in the root of that folder. Then inside the "afmt" folder, create an "examples" folder. Place the examples.odin file inside the "examples" folder. 

To use the library, add to the top of your project file:<br>
import "CollectionFolder:afmt"

To run the examples, navigate in the terminal to CollectionFolder\afmt\examples. Then build with odin "odin run ." You may need to update the import at the top of the examples.odin file to match the location of where you've placed the afmt library.

If you do not all ready have a collection folder created, check Odin's website for how to do this. Or, there should be a default collection folder in the odin directory named "shared". You can import with:<br>
import "shared:afmt"

See examples.odin for usage.
