\version "2.18.2"
\header {
	title = "Outside"
	subtitle = "Milon's Secret Castle, Song 02"
	composer = "Written by Takeaki Kunimoto"
	arranger = "Arrangement by kan"
	copyright = "© 1986 Hudson Soft; © 2024 kan"
	tagline = ""
}

% quarter note = $20

\pointAndClickOff
\language "english"

repamt = 10

music = <<

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"rock organ"
	\numericTimeSignature
	\time 6/8
	\key c \major
	\tempo "Chill" 4 = 120

	\repeat volta \repamt {
		g'16
		r4
		g'2~g'4~g'8~g'16
		r16
		e'8
		fs'16
		g'
		r4
		g'2~g'4~g'8~g'16
		r4
		g'16
		r4
		g'2~g'8~g'16
		r16
		fs'8.
		g'16
		e'8
		fs'16
		g'
		r4
		g'2~g'4~g'8~g'16
		r4
		c''16
		r4
		c''2~c''4~c''8~c''16
		r16
		a'8
		b'16
		c''
		r4
		c''2~c''4~c''8~c''16
		r4
		c''16
		r4
		c''2~c''4~c''16
		b'16
		b'
		c''
		a'8
		b'16
		c''
		r4
		c''2~c''4~c''8~c''16
		r4
		g'16
		r4
		g'2~g'4~g'8~g'16
		r16
		e'8
		fs'16
		g'
		r4
		g'2~g'4~g'8~g'16
		r4
		g'16
		r4
		g'2~g'8~g'16
		r16
		fs'8.
		g'16
		e'8
		fs'16
		g'
		r4
		g'2~g'4~g'8~g'16
		r4
		d'8
		d'
		cs'
		b
		a
		gs
		fs16
		r4
		d
		fs8
		g16
		g'
		r4
		g'4~g'8~g'16
		r8
		gs16
		r8
		gs4~gs8~gs16
	}
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"rock organ"
	\numericTimeSignature
	\repeat volta \repamt {
		d'16
		r4
		cs'2~cs'4~cs'8~cs'16
		r16
		b8
		cs'16
		d'
		r4
		cs'2~cs'4~cs'8~cs'16
		r4
		d'16
		r4
		cs'2~cs'8~cs'16
		r16
		c'8.
		cs'16
		g8
		a16
		d'
		r4
		cs'2~cs'4~cs'8~cs'16
		r4
		g'16
		r4
		fs'2~fs'4~fs'8~fs'16
		r16
		e'8
		fs'16
		g'
		r4
		fs'2~fs'4~fs'8~fs'16
		r4
		g'16
		r4
		fs'2~fs'4~fs'16
		f'16
		f'
		fs'
		e'8
		fs'16
		g'
		r4
		fs'2~fs'4~fs'8~fs'16
		r4
		d'16
		r4
		cs'2~cs'4~cs'8~cs'16
		r16
		b8
		cs'16
		d'
		r4
		cs'2~cs'4~cs'8~cs'16
		r4
		d'16
		r4
		cs'2~cs'8~cs'16
		r16
		c'8.
		cs'16
		g8
		a16
		d'
		r4
		cs'2~cs'4~cs'8~cs'16
		r4

		\repeat unfold 6 {
			e'8
		}

		d'16
		r4
		b8.
		c'16
		a8
		b16
		d'
		r4
		cs'4~cs'8~cs'16
		r8
		g'16
		r8
		r8 r16 r4
	}
}

\new Staff \absolute {
	\clef "bass_8"
	\set Staff.midiInstrument = #"acoustic bass"
	\numericTimeSignature
	\repeat volta \repamt {

		\repeat unfold 4 {
			a,,8
			a,,16
			cs,8
			cs,16
			e,8
			e,16
			g,8
			a,16
			a,8
			e,16
			g,8
			a,16
			g,8
			e,16
			d,
			ds,
			e,
		}


		\repeat unfold 4 {
			d,8
			d,16
			fs,8
			fs,16
			a,8
			a,16
			c8
			d16
			d8
			a,16
			c8
			d16
			c8
			a,16
			g,
			gs,
			a,
		}


		\repeat unfold 4 {
			a,,8
			a,,16
			cs,8
			cs,16
			e,8
			e,16
			g,8
			a,16
			a,8
			e,16
			g,8
			a,16
			g,8
			e,16
			d,
			ds,
			e,
		}


		\repeat unfold 6 {
			e,8
		}

		d,16
		r4 r8 r16
		d,16
		d8
		gs,16
		a,,8
		e,16
		r8
		a,4.
		a,,16
		e,8
		e,16
		r8
		e,8.
		e,16
		g,8
		r16
	}
}

\new DrumStaff \drummode {
	\numericTimeSignature
	\repeat volta \repamt {

		\repeat unfold 6 {
			hh16
			r8
			hh16
			r
			hh
			hh
			r8
			hh16
			r
			hh
			hh
			r8
			hh16
			r
			hh
			hh
			r8
			hh16
			r
			hh
			hh
			r
			hh
			hh
			r8
			hh16
			r
			hh
			hh
			r8
			hh16
			r
			hh
			hh
			r8
			hh16
			hh
			hh
			hh
			r
			hh
		}

		hh8
		hh
		hh
		hh
		hh
		hh
		hh16
		r2 r8 r16
		hh16
		r8
		hh16
		r
		hh
		hh
		r8
		hh16
		r
		hh
		r8
		hh16
		r8
		hh16
		r8.
		hh16
		r16 r16
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

