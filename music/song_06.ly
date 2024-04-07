\version "2.18.2"

\header {
	title = "Castle Garland Is Saved"
	subtitle = "Milon's Secret Castle, Song 06"
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
	\set Staff.midiInstrument = #"trumpet"
	\numericTimeSignature
	\time 4/4
	\key c \major
	\tempo "Bravely" 4 = 150

	\repeat volta 2 {
		c''4
		d''8
		e''4
		d''8
		c''
		g'
		a'1
		d''4
		e''8
		f''4
		e''8
		d''
		a'
		b'4.
		a'8
		g'2
		e''4
		f''8
		g''4
		f''8
		e''4
		f''
		g''8
		gs''4
		g''8
		f''4
		e''4.
		a'16
		c''
		e''2
		d''4.
		c''16
		d''
		g''2
	}

	c''2~c''4~c''16
	c''16
	e''
	g''
	c'''8
	r
	c'
	r8 r2
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"french horn"
	\numericTimeSignature

	\repeat volta 2 {
		e'16
		r
		e'
		f'
		g'8
		g''16
		c'''
		e''
		g''
		c''
		e''
		g'
		c''
		e'
		g'
		f'
		e'
		f'
		e'
		f'8
		f''16
		a''
		c''
		f''
		a'
		c''
		f'
		a'
		c'
		f'
		f'
		r
		f'
		g'
		a'8
		a''16
		c'''
		f''
		a''
		d''
		f''
		a'
		c''
		f'
		a'
		g'
		fs'
		g'
		fs'
		g'8
		d''16
		f''
		b'
		d''
		fs'
		g'
		gs'
		a'
		as'
		b'
		g'8
		e'4
		e''
		c''8
		g'
		as'
		c''
		c'4
		f''
		c''8
		gs'
		f'
		a'16
		r
		fs'
		a'
		c''4.
		c''16
		e''
		a''4
		c''16
		r
		g'
		c''
		d''4.
		d''16
		g''
		b''4
	}

	g'16
	e
	g
	c'
	e'
	g
	c'
	e'
	g'
	c'
	e'
	g'
	c''
	e'
	g'
	c''
	e''8
	r
	g
	r8 r2
}

\new Staff \absolute {
	\clef "bass"
	\set Staff.midiInstrument = #"trombone"
	\numericTimeSignature

	\repeat volta 2 {
		c8
		g4
		c'
		g'
		e'8
		f,
		c4
		f
		f'
		c'8
		d
		a4
		d'
		a'
		f'8
		g,
		d4
		g
		b
		d'8
		c
		c'4.
		as,8
		as4.
		a,8
		a4.
		gs,4
		gs
		fs,8
		fs,
		fs,
		fs,
		fs,
		fs,
		fs,
		fs,
		g,
		g,
		g,
		g,
		g,
		g,
		g,
		g,
	}

	c1
	g'8
	r
	c
	r8 r2 
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

