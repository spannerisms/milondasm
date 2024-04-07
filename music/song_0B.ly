\version "2.18.2"

\header {
	title = "The Bonus Begins"
	subtitle = "Milon's Secret Castle, Song 0B"
	composer = "Composed by Takeaki Kunimoto"
	arranger = "Arrangement by kan"
	copyright = "© 1986 Hudson Soft; © 2024 kan"
	tagline = ""
}

\pointAndClickOff
\language "english"

% quarter note = $10

music = <<

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"bassoon"
	\time 4/4
	\key c \major
	\tempo "Doo" 4 = 225
	b4.
	d'8
	fs'
	r
	a'
	r
	a'
	r8
	r4
	r4 r
}

\new Staff \absolute {
	\clef "tenor"
	\set Staff.midiInstrument = #"bassoon"
	gs4.
	gs8
	gs
	r
	cs'
	r
	cs'
	r8
	r4
	r4 r
}

\new Staff \absolute {
	\clef "bass"
	\set Staff.midiInstrument = #"bassoon"
	e4.
	e8
	e
	r
	a
	r
	a
	r8
	r4
	r4 r
}

\new DrumStaff \drummode {
	sn16
	sn
	sn
	sn
	sn8
	sn
	sn4
	sn
	sn
	r
	r4 r
}

>>

\score {
	\music
	\layout {
		\context {
			\Voice
			\remove "Note_heads_engraver"
			\consists "Completion_heads_engraver"
			\remove "Rest_engraver"
			\consists "Completion_rest_engraver" 
		}
	}
}

\score {
	\unfoldRepeats { \music }
	\midi {
		\context {
			\Staff
			\remove "Staff_performer"
		}
		\context {
			\Voice
			\consists "Staff_performer"
		}
	}
}

