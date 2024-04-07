\version "2.18.2"

\header {
	title = "Bonus Stage!"
	subtitle = "Milon's Secret Castle, Song 10"
	composer = "Composed by Daisuke Inoue"
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
	\set Staff.midiInstrument = #"violin"
	\numericTimeSignature
	\time 4/4
	\key c \major
	\tempo "Extravagant" 4 = 112

	\repeat unfold 2 {
		a'8
		r16
		gs'
		a'
		r
		c'8
		f'
		a'
		c''4
		b'8
		as'4.
		g'8
		r16
		fs'
		g'
		r
		as8
		e'
		g'
		fs'
		g'
		gs'
		a'4.
		r8
		a'16
		gs'
		a'8
		c'
		f'
		a'
		a'
		as'
		c''
		d''4.
		f''8
		e''
		d''
		c''
		as'
		a'
		e'
		f'
		g'
		f'4.
	}

	d''8.
	cs''16
	d''8
	f''
	e''
	d''
	c''
	e'16
	f'
	g'
	gs'
	a'4.
	r8
	d''16
	cs''
	d''8
	f''
	e''
	d''
	c''16
	c'
	d'
	e'
	f'
	g'
	a'4.
	d''8
	r16
	cs''
	d''
	r
	f''8
	e''
	d''
	c''
	d''
	e''
	a''2~a''4~a''8~a''16
	r16
	r2
	as''8
	a''
	g''
	c''
	d''
	e''
	g''16
	g''
	g''
	r
	e''
	r
	f''
	f''
	f''
	r
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"orchestral harp"
	\numericTimeSignature

	\repeat unfold 4 {
		c''16
		a'
		f'
		c'
		a'
		f'
		c''
		a'
		e'
		c'
		a'
		f'
		c''
		a'
		ds'
		c'
		a'
		f'
		as'
		f'
		d'
		as
		as'
		a'
		c''
		g'
		e'
		c'
		g'
		e'
		c''
		g'
		e'
		d'
		g'
		e'
		c''
		g'
		e'
		ds'
		g'
		e'
		c''
		a'
		f'
		e'
		a'
		f'
	}

	\set Staff.midiInstrument = #"trumpet"

	\repeat unfold 2 {
		d''16
		d''
		as'
		as'
		f'
		f'
		d''
		d''
		b'
		b'
		f'
		f'
		f''
		f''
		c''
		c''
		a'
		a'
		f''
		f''
		c''
		c''
		a'
		a'
	}

	d''16
	d''
	as'
	as'
	f'
	f'
	d''
	d''
	b'
	b'
	f'
	f'
	f''
	f''
	c''
	c''
	a'
	a'
	f''
	b
	d'
	f'
	gs'
	b'
	d''
	f''
	gs''
	b''
	d'''
	d'''4.
	r4 r8 r16
	f''16
	f''
	d''
	d''
	as'
	as'
	g''
	g''
	e''
	e''
	c''
	c''
	c''
	c''
	e''
	r
	g''
	r
	a'
	c''
	f''
	r
}

\new Staff \absolute {
	\clef "treble^8"
	\set Staff.midiInstrument = #"ocarina"
	\numericTimeSignature

	\repeat unfold 2 {
		r8
		c'''16
		a''
		c'''
		a''
		r8
		c'''16
		a''
		c'''
		a''
		r8
		c'''16
		a''
		c'''
		a''
		r8
		d'''16
		ds'''
		e'''
		f'''
		r8
		g''16
		e''
		g''
		e''
		r8
		g''16
		e''
		g''
		e''
		r8
		g''16
		e''
		g''
		e''
		r8
		a'''16
		gs'''
		g'''
		f'''
		r8
		c'''16
		a''
		c'''
		a''
		r8
		c'''16
		a''
		c'''
		a''
		r8
		c'''16
		a''
		c'''
		a''
		r8
		d'''16
		ds'''
		e'''
		f'''
		r8
		g''16
		e''
		g''
		e''
		r8
		g''16
		e''
		g''
		e''
		r8
		g''16
		e''
		g''
		e''
		r8
		a'''16
		gs'''
		g'''
		f'''
	}

	r8
	d''16
	f''
	d''
	f''
	r8
	d''16
	f''
	d''
	f''
	r8
	f''16
	a''
	f''
	a''
	r8
	f''16
	a''
	f''
	a''
	r8
	d''16
	f''
	d''
	f''
	r8
	d''16
	f''
	d''
	f''
	r8
	f''16
	a''
	f''
	a''
	r8
	f''16
	a''
	f''
	a''
	r8
	d''16
	f''
	d''
	f''
	r8
	d''16
	f''
	d''
	f''
	r8
	f''16
	a''
	f''
	a''
	r8
	b'16
	d''
	f''
	gs''
	b''
	d'''
	f'''
	gs'''
	b'''
	d''''
	d''
	b'
	f''
	d''
	gs''
	f''
	b''
	gs''
	d'''
	b''
	f'''
	d'''
	r8
	d''16
	f''
	d''
	f''
	r8
	e''16
	c'''
	e''
	c'''
	r8
	r4 r
}



\new Staff \absolute {
	\clef "bass_8"
	\set Staff.midiInstrument = #"tuba"
	\numericTimeSignature

	\repeat unfold 2 {
		f,8 r r
		e,8 r r
		ds,8 r r
		d,8 r r
		c,8 r r
		d,8 r r
		e,8 r r
		f,8 r r
		f,8 r r
		e,8 r r
		ds,8 r r
		d,8 r r
		c,8 r r
		d,8 r r
		e,8 r r
		f,8 r r
	}

	as,,8 r r
	b,,8 r r
	c,8 r r
	f,8 r r
	as,,8 r r
	b,,8 r r
	c,8 r r
	f,8 r r
	as,,8 r r
	b,,8 r r
	c,8 r r
	d,8 r r
	r4 r r r r8
	as,,8 r r
	c,8 r r
	c,16
	c,
	c,
	r
	c,
	r
	f,
	f,
	f,
	r
}

\new DrumStaff \drummode {
	\numericTimeSignature

	\repeat unfold 21 {
		sn32
		sn
		sn
		sn
		sn16
		sn
		ss
		r
		ss8
		sn16
		sn
		sn
		r
	}

	sn32
	sn
	sn
	sn
	sn16
	sn
	ss
	r

	\repeat unfold 6 {
		r8
		sn
		sn
	}

	sn16
	sn
	sn
	r
	ss
	r
	sn
	sn
	sn
	r
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

