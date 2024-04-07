\version "2.18.2"

\header {
	title = "Continue"
	subtitle = "Milon's Secret Castle, Song 03"
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
	\set Staff.midiInstrument = #"trumpet"
	\numericTimeSignature
	\time 2/4
	\key c \major
	\tempo "Preppy" 4 = 120
	g''16
	r8
	g''16
	g''
	r
	gs''
	r8
	gs''16
	gs''
	r
	a''
	r8
	a''16
	a''
	r
	b''
	r
	b''
	r8.
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"trumpet"
	\numericTimeSignature
	d''16
	r8
	d''16
	d''
	r
	d''
	r8
	d''16
	d''
	r
	d''
	r8
	d''16
	f''
	r
	g''
	r
	g''
	r8.
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"trumpet"
	\numericTimeSignature

	\repeat unfold 2 {
		g16
		r
		g'
		b''
		g'
		r
	}

	g16
	r
	d'
	e'
	f'
	r
	g'
	r
	g
	r8.
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

