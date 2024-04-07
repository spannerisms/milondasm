\version "2.18.2"

\header {
	title = "Fanfare"
	subtitle = "Milon's Secret Castle, Song 11"
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
	\set Staff.midiInstrument = #"flute"
	\time 4/4
	\key c \major
	\tempo "Victorious" 4 = 225
	g'8.
	r16
	g'
	g'
	a'8
	f'
	a'
	b'4..
	r16 r4 r4 r4
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"flute"
	b8.
	r16
	b
	b
	c'8
	c'
	c'
	gs'4..
	r16 r4 r4 r4
}

\new Staff \absolute {
	\clef "bass"
	\set Staff.midiInstrument = #"flute"
	g8.
	r16
	g
	g
	f8
	f
	f
	e2.
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

