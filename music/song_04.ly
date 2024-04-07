\version "2.18.2"

\header {
	title = "A Scene of the Castle"
	subtitle = "Milon's Secret Castle, Song 04"
	composer = "Composed by Takeaki Kunimoto"
	arranger = "Arrangement by kan"
	copyright = "© 1986 Hudson Soft; © 2024 kan"
	tagline = ""
}

\pointAndClickOff
\language "english"

% quarter note = $20

repamt = 10

music = <<

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"concertina"
	\numericTimeSignature
	\time 3/4
	\key c \major
	\tempo "Serene" 4 = 120

	\repeat volta \repamt {

		\repeat unfold 2 {
			g'4
			a'8
			b'4
			c''8
			b'4
			a'8
			g'4.
			e'8
			f'
			g'
			a'
			b'
			c''
			cs''4.
			d''
			g'4
			a'8
			b'4
			c''8
			b'4
			a'8
			g'4.
			g'8
			a'
			b'
			c''
			d''
			ds''
			e''2.
			g'4
			a'8
			b'4
			c''8
			b'4
			a'8
			g'4.
			a'8
			b'
			cs''
			d''4
			e''8
			f''2.
			a'4
			b'8
			c''4
			d''8
			e''
			c''
			b''
			a''4.
			e''4
			d''8
			f''
			d''
			b'
			c''4.
			b
		}

		e'2.
		e'
		f'
		gs'
		e'
		e'
		f'
		gs'4.
		c''16
		r
		as'
		r
		gs'
		r

		\repeat unfold 2 {
			c''8
			e'16
			f'
			g'2
			d''8
			g'16
			a'
			as'2
			e''8
			a'16
			as'
			c''2
			d''8
			gs'16
			as'
			c''2
		}

		g'8.
		d'16
		e'
		g'
		b'8.
		e'16
		d''
		b'
		a'8.
		f'16
		a'
		c''
		b'8
		a'16
		r
		gs'
		r
		g'8.
		d'16
		e'
		g'
		b'8.
		e'16
		d''
		b'
		a'8.
		f'16
		a'
		c''
		b'4.
		b'8
		a'16
		r
		gs'
		r
		g'4.~

		% this 3/8 time signature is a dumb hack
		% it's really more like a pickup that's only played on repeat
		% but there's not anyway to notate that (that I like)
		\time 3/8

		g'4.
	}
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"vibraphone"
	\numericTimeSignature
	\repeat volta \repamt {

		\repeat unfold 2 {
			e''4.
			e''
			e''
			e''
			g''
			e''
			f''
			f''
			f''
			f''
			f''
			f''
			f''
			g''
			g''2.
			e''4.
			e''
			e''
			e''
			g''
			g''4
			a'8
			d''2.
			f''4.
			a''
			g''
			cs''
			a''
			gs''
			g''
			ds'16
			g
			b
			a'
			g'8
		}

		c''2.
		as'
		c''
		d''
		c''
		as'
		c''
		d''4.
		f''

		\repeat unfold 2 {
			e'8
			c'16
			d'
			e'4
			c'16
			d'
			e'4
			e'16
			f'
			g'4
			e'16
			f'
			g'8
			c''
			f'16
			g'
			a'4
			f'16
			g'
			a'8
			gs'
			f'16
			g'
			gs'8.
			f'16
			f''
			c''
			gs'
			f'
		}

		c'16
		b
		e'
		b8
		e'16
		g'
		fs'
		e'
		b8
		e'16
		f'
		a
		c'8
		f'
		g'16
		r
		f'
		r
		f'
		r
		c'
		b
		e'
		b8
		e'16
		g'
		fs'
		e'
		b8
		e'16
		f'
		a
		c'8
		f'
		g'4.
		g'8
		f'16
		r
		f'
		r
		e'4. r4.
	}
}

\new Staff \absolute {
	\clef "bass"
	\set Staff.midiInstrument = #"pizzicato strings"
	\numericTimeSignature
	\repeat volta \repamt {

		\repeat unfold 2 {
			c,8
			g16
			r
			g
			r
			g,,8
			g16
			r
			g
			r
			c,8
			g16
			r
			g
			r
			g,,8
			g16
			r
			g
			r
			c,8
			g16
			r
			g
			r
			g,,8
			g16
			r
			g
			r
			g,,8
			g16
			r
			g
			r
			d,8
			g16
			r
			g
			r
			g,,8
			f16
			r
			f
			r
			d,8
			f16
			r
			f
			r
			g,,8
			f16
			r
			f
			r
			d,8
			f16
			r
			f
			r
			g,,8
			f16
			r
			f
			r
			d,8
			f16
			r
			b
			r
			c,8
			g16
			r
			g
			r
			g,,8
			a16
			r
			g
			r
			c,8
			g16
			r
			g
			r
			g,,8
			g16
			r
			g
			r
			c,8
			g16
			r
			g
			r
			g,,8
			g16
			r
			g
			r
			cs,8
			g16
			r
			g
			r
			e,8
			g16
			r
			a,,8
			d,
			a16
			r
			a
			r
			a,,8
			a16
			r
			a
			r
			f,,8
			c16
			c
			f
			r
			fs,,8
			ds16
			ds
			gs
			r
			c,8
			g16
			r
			b,,8
			a,,
			g16
			r
			e
			r
			d,8
			f16
			r
			f
			r
			g,,8
			f16
			r
			d
			r
			c,8
			g16
			r
			g
			r
			g,,8
			g16
			r
			g
			r
		}


		\repeat unfold 2 {
			c,8
			e,16
			f,
			g,8
			c
			e,16
			f,
			g,8
			c,
			e,16
			f,
			g,8
			c
			e,16
			f,
			g,8
			f,
			a,16
			as,
			c8
			f
			a,16
			as,
			c8
			f,8.
			gs,16
			c
			f
			gs
			r
			g
			r
			f
			r
		}


		\repeat unfold 2 {
			c,8
			g16
			g
			c'8
			g,,
			g16
			r
			g8
			c,
			as16
			as
			as8
			g,,
			g16
			r
			as8
			f,,
			f16
			f
			f8
			c,
			f16
			r
			f8
			f,,
			f16
			f
			f8
			c,
			c16
			gs,
			f,
			d,
		}

		c,4~c,16
		g,,16
		e,4~e,16
		b,,16
		f,4~f,16
		c,16
		g,
		r
		g,
		r
		g,
		r
		c,4~c,16
		g,,16
		e,4~e,16
		b,,16
		f,4~f,16
		c,16
		g,8.
		d,16
		d
		b,
		g,4.
		g,
		g,,16
		r
		a,,
		r
		b,,

		r16
	}
}

\new DrumStaff \drummode {
	\numericTimeSignature
	\repeat volta \repamt {

		\repeat unfold 32 {
			r2.
		}


		\repeat unfold 3 {
			hh16
			r2 r16
			hh16
			hh
		}

		hh16
		r8.
		hh16
		hh
		hh
		r8.
		hh16
		hh

		\repeat unfold 3 {
			hh16
			r2 r16
			hh16
			hh
		}

		hh16
		r8.
		hh16
		hh
		hh
		r8.
		hh16
		hh
		hh
		r2 r8 r16

		\repeat unfold 11 {
			r2.
		}

		r2.
		r4.
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

