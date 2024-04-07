\version "2.18.2"

\header {
	title = "Death"
	subtitle = "Milon's Secret Castle, Song 0A"
	composer = "Composed by Takeaki Kunimoto"
	arranger = "Arrangement by kan"
	copyright = "© 1986 Hudson Soft; © 2024 kan"
	tagline = ""
}

\pointAndClickOff
\language "english"

% quarter note = $18

music = <<

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"acoustic grand"
	\time 4/4
	\key c \major
	\tempo "Distraught" 4 = 120

	\repeat unfold 3 {
		cs'16
		d'
		g'
	}

	f'16
	r
	f'
	r
	f'
	r8
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"acoustic grand"

	\repeat unfold 3 {
		as16
		b
		e'
	}

	ds'16
	d'
	ds'
	d'
	ds'
	r8
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"acoustic grand"
	r16
	g''
	r
	d''
	r
	cs''
	r
	g'
	r
	a''
	gs''
	a'
	gs'
	a
	r8
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

