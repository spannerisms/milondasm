This is a complete disassembly of *Milon's Secret Castle*, the North American release of *迷宮組曲 ミロンの大冒険* (*Meikyū Kumikyoku: Milon no Daibōken*). As of release, this disassembly can be perfectly assembled to the original version, although you'll need to jiggle the tools a bit and provide your own graphics binaries.

# Acknowledgements:
* Zarby89, for figuring out a lot of the data related to tilemaps
* BluntBunny for sparking my interest in this game.

# Assembly
Look, I know nothing about NES mappers, but Milon's was simple enough that I just used SNES tools. If someone fluent in NES development wants to make a pull request to adjust the source files for NES tools, that's fine. The only requirement is that address annotation at the beginning of each line must remain (though it may be formatted differently to fit the assembler).

# Music
Because the music data was so simple, I was able to automatically create files for them by parsing the ROM data. These `.ly` files are found in the `music/` directory can be compiled with [LilyPond](https://lilypond.org/).

Takeaki Kunimoto is the composer of all the songs in this game, with the exception of the bonus game song, which was composed by Daisuke Inoue. Kunimoto is still composing music for the NES even today. If you're interested, you should check out [his blog](https://blog.goo.ne.jp/kinokowakame1962) (Japanese).

The Castle theme contain original lyrics (in Japanese), and you can hear them in this arrangement from Kunimoto's personal YouTube channel (with Kunimoto himself on bass): [CD「ひつじの丘」〜 #８「迷宮円舞曲」](https://www.youtube.com/watch?v=Wwd-ql-I8ak)
