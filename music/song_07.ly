\version "2.18.2"

\header {
	title = "GAME OVER"
	subtitle = "Milon's Secret Castle, Song 07"
	composer = "Composed by Takeaki Kunimoto"
	arranger = "Arrangement by kan"
	copyright = "© 1986 Hudson Soft; © 2024 kan"
	tagline = ""
}

\pointAndClickOff
\language "english"

% quarter note = $20

music = <<

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"tuba"
	\numericTimeSignature
	\time 4/4
	\key c \major
	\tempo "Dead" 4 = 112
	e''8
	b'16
	c''4~c''16
	ds'16
	e'4.
	r2 r16
	r2
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"tuba"
	\numericTimeSignature
	g'4~g'16
	fs'16
	g'4~g'16
	b16
	c'8.
	r2 r16
	r2
}

\new Staff \absolute {
	\clef "bass"
	\set Staff.midiInstrument = #"tuba"
	\numericTimeSignature
	c2.
	r8.
	c'16~c'32
	r16 r32
	c16~c32
	r4 r32
	r2
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

