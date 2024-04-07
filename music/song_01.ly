\version "2.18.2"

\header {
	title = "Intro"
	subtitle = "Milon's Secret Castle, Song 01"
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
	\set Staff.midiInstrument = #"clarinet"
	\numericTimeSignature
	\time 4/4
	\key c \major
	\tempo "Chill" 4 = 120

	cs'16
	e'
	fs'
	a'
	r
	g'
	r
	as'
	cs''
	e''
	r
	g''
	d''8
	b'16
	fs'
	r
	d''4
	r8.
	r4 r
}

\new Staff \absolute {
	\clef "treble"
	\set Staff.midiInstrument = #"clarinet"
	\numericTimeSignature

	a16
	cs'
	d'
	e'
	r
	cs'
	r
	e'
	g'
	as'
	r
	cs''
	b'8
	fs'16
	b
	r
	gs'4
	r16 r8 r4 r
}

\new Staff \absolute {
	\clef "bass"
	\set Staff.midiInstrument = #"oboe"
	\numericTimeSignature

	a,16
	a,
	a,
	a,
	r
	as,
	r
	as,
	as,
	cs
	r
	as,
	b,8
	b,16
	b,8
	e
	r16
	b'
	e,8.
	r4 r
}

\new DrumStaff \drummode {
	\numericTimeSignature

	hh16
	hh
	hh
	hh
	r
	hh
	r
	hh
	r
	hh
	r
	hh
	hh
	r
	hh
	hh
	r
	hh
	r8 r4 r4 r4
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

