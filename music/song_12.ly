\version "2.18.2"

\header {
	title = "Boss Theme"
	subtitle = "Milon's Secret Castle, Song 12"
	composer = "Composed by Takeaki Kunimoto"
	arranger = "Arrangement by kan"
	copyright = "© 1986 Hudson Soft; © 2024 kan"
	tagline = ""
}

\pointAndClickOff
\language "english"

% quarter note = $18

repamt = 10

music = <<

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"overdriven guitar"
	\numericTimeSignature
	\time 4/4
	\key c \major
	\tempo "Endangered" 8 = 320

	\repeat volta \repamt {

		\repeat unfold 4 {
			d''16
			g'
			d''
			cs''
			g'
			cs''
		}

		\repeat unfold 4 {
			e''16
			a'
			e''
			ds''
			a'
			ds''
		}

		\repeat unfold 4 {
			d''16
			g'
			d''
			cs''
			g'
			cs''
		}

		\repeat unfold 4 {
			e''16
			a'
			e''
			ds''
			a'
			ds''
		}

	}
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"overdriven guitar"
	\numericTimeSignature

	\repeat volta \repamt {

		\repeat unfold 8 {
			b16
			r
			b
		}

		\repeat unfold 8 {
			cs'16
			r
			cs'
		}

		\repeat unfold 8 {
			b16
			r
			b
		}


		\repeat unfold 8 {
			cs'16
			r
			cs'
		}

	}
}

\new Staff \absolute {
	\clef "treble_8"
	\set Staff.midiInstrument = #"overdriven guitar"
	\numericTimeSignature

	\repeat volta \repamt {

		\repeat unfold 8 {
			f16
			r
			f
		}

		\repeat unfold 8 {
			g16
			r
			g
		}

		\repeat unfold 4 {
			f8
			f'16
			g'
			ds'8
		}

		\repeat unfold 4 {
			g8
			g'16
			a'
			f'8
		}

	}
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

