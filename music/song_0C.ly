\version "2.18.2"

\header {
	title = "Escaping the Well"
	subtitle = "Milon's Secret Castle, Song 0C"
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
	\set Staff.midiInstrument = #"orchestral harp"
	\numericTimeSignature
	\time 4/4
	\key c \major
	\tempo "Bubbly" 4 = 140
	e'''16
	c'''
	a''
	f''
	d'''
	b''
	gs''
	f''
	d'''
	b''
	g''
	e''
	cs'''
	as''
	g''
	e''
	c'''
	a''
	f''
	d''
	b''
	gs''
	f''
	d''
	b''
	g''
	e''
	d''
	as''
	g''
	e''
	cs''
	e''
	f'
	a'
	c''
	d''
	e''8
	a'16
	c''
	d''
	f''8
	c''16
	d''
	f''
	a''8
	d''16
	f''
	a''
	c'''8
	f''16
	a''
	c'''
	e'''8
	a''16
	c'''
	d'''
	f'''8
	c'''16
	d'''
	f'''
	a'''4
	r2 r16
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"orchestral harp"
	\numericTimeSignature
	c''16
	a'
	f'
	d'
	b'
	gs'
	f'
	d'
	b'
	g'
	e'
	b
	as'
	g'
	e'
	cs'
	a'
	f'
	d'
	a
	gs'
	f'
	d'
	b
	g'
	e'
	d'
	b
	g'
	e'
	cs'
	as
	r8.
	e'16
	f
	a
	c'
	d'
	e'8
	a16
	c'
	d'
	f'8
	c'16
	d'
	f'
	a'8
	d'16
	f'
	a'
	c''8
	f'16
	a'
	c''
	e''8
	a'16
	c''
	d''
	f''8
	c''16
	d''
	f''
	a''4
	r4.
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"orchestral harp"
	\numericTimeSignature

	\repeat unfold 2 {
		d''4
		g''
		e''
		a''
	}

	d''1
	r1 r4
	r2
	r4
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

