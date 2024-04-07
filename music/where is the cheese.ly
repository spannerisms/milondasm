\version "2.18.2"
\header {
	title = "Where Is the Cheese?"
	subtitle = "Milon's Secret Castle, Song 05"
	composer = "Composed by Takeaki Kunimoto"
	arranger = "Arrangement and lyrics by kan"
	copyright = "© 1986 Hudson Soft; © 2024 kan"
	tagline = ""
}

\pointAndClickOff
\language "english"

repamt = 4

music = <<

\new Staff \absolute {

	\new Voice = "cheese" {
		\clef "treble"
		\set Staff.midiInstrument = #"violin"
		\numericTimeSignature
		\time 4/4
		\key c \major
		\tempo "Cheese" 4 = 150

		\repeat volta \repamt {

			\repeat unfold 2 {
				a'16
				r
				c''
				r
				e''
				r
				ds''4
				a'16
				r
				c''
				r
				e''
				r
				ds''4.
				e''8
				fs''
				g''16
				r
				fs''8
				g''16
				r
				a'
				r
				c''
				r
				e''
				r
				ds''4
				a'16
				r
				c''
				r
				e''
				r
				ds''4.
				e''8
				fs''16
				g''
				r
				g''
				fs''8
				g''16
				r
			}


			\repeat unfold 2 {
				c''16
				r
				ds''
				r
				g''
				r
				fs''4
				c''16
				r
				ds''
				r
				g''
				r
				fs''4.
				g''8
				a''
				as''16
				r
				a''8
				as''16
				r
				c''
				r
				ds''
				r
				g''
				r
				fs''4
				c''16
				r
				ds''
				r
				g''
				r
				fs''4.
				g''8
				a''16
				as''
				r
				as''
				a''8
				as''16
				r
			}

			r4
			as''8
			r
			gs''
			fs''
			r
			f''2.
			d''8
			ds''
			f''4.
			f''8
			ds''4
			cs''
			d''2
			as'4
			d''8
			f''
			as''
			r4
			a''8
			a''
			gs''
			fs''
			r
			e''2.
			cs''8
			d''
			e''2.

			\repeat unfold 2 {
				c''8
				d''
				e''2.
			}

			r4.
			e''8
			c''
			d''
			e''
			r
			d''4.
		}
	}

	\addlyrics {
		Where is the cheese?
		Where is the cheese?
		I want to eat it.

		Where is the cheese?
		Where is the cheese?
		Just where did I put it?

		Where is the cheese?
		Where is the cheese?
		I don't re -- mem -- ber.

		Where is the cheese?
		Where is the cheese?
		It's got -- ta be some -- where.

		Where is the cheese?
		Where is the cheese?
		I need it right now.

		Where is the cheese?
		Where is the cheese?
		I'm get -- ting im -- pa -- tient.

		Where is the cheese?
		Where is the cheese?
		This does -- n't make sense.

		Where is the cheese?
		Where is the cheese?
		I'm go -- ing to freak out!

		I found the cheese!
		It was hi -- ding in the fridge
		on the top shelf.
		Now I ate the cheese.
		Now it's gone...
		Now it's gone...
		Now it's gone...
		Now I want your cheese.
	}

	\addlyrics {
		Where is your cheese?
		Where is your cheese?
		I want to eat it.

		Where is your cheese?
		Where is your cheese?
		Tell me where you put it.

		Where is your cheese?
		Where is your cheese?
		You should -- n't hide it. % wag finger in disapproval

		Where is your cheese?
		Where is your cheese?
		I'm go -- ing to find it.

		Where is your cheese?
		Where is your cheese?
		I need it right now.

		Where is your cheese?
		Where is your cheese?
		I know that you have some.

		Where is your cheese?
		Where is your cheese?
		Save me the trou -- ble.

		Where is your cheese?
		Where is your cheese?
		Don't make me get vio -- lent.

		I found your cheese!
		It was hi -- ding in your fridge
		in the side door.
		Now I ate your cheese.
		Now it's gone...
		Now it's gone...
		Now it's gone...
		Now I want his cheese.
	}

	\addlyrics {
		Where is his cheese?
		Where is his cheese?
		I want to eat it.

		Where is his cheese?
		Where is his cheese?
		Why can I not find it?

		Where is his cheese?
		Where is his cheese?
		It should just be here.

		Where is his cheese?
		Where is his cheese?
		He could -- n't have lost it.

		Where is his cheese?
		Where is his cheese?
		I need it right now.

		Where is his cheese?
		Where is his cheese?
		He does -- n't de -- serve it.

		Where is his cheese?
		Where is his cheese?
		His cheese is mine now.

		Where is his cheese?
		Where is his cheese?
		He's mak -- ing me ang -- ry.

		I found his cheese!
		It was hi -- ding in his fridge
		in the cris -- per.
		Now I ate his cheese.
		Now it's gone...
		Now it's gone...
		Now it's gone...
		Now I want her cheese.
	}

	\addlyrics {
		Where is her cheese?
		Where is her cheese?
		I want to eat it.

		Where is her cheese?
		Where is her cheese?
		How come she won't tell me?

		Where is her cheese?
		Where is her cheese?
		She has to share some.

		Where is her cheese?
		Where is her cheese?
		Does she e -- ven want it?

		Where is her cheese?
		Where is her cheese?
		I need it right now.

		Where is her cheese?
		Where is her cheese?
		I'm lo -- sing my mind here.

		Where is her cheese?
		Where is her cheese?
		I need her chee -- ses.

		Where is her cheese?
		Where is her cheese?
		I'm hav -- ing a melt -- down.

		I found her cheese!
		It was hi -- ding in her fridge
		by the must -- ard.
		Now I ate her cheese.
		Now it's gone...
		Now it's gone...
		Now it's gone...
		It was de -- lic -- ious.
	}
}

\new Staff \absolute {
	\clef "alto"
	\set Staff.midiInstrument = #"viola"
	\numericTimeSignature

	\repeat volta \repamt {
		\repeat unfold 28 {
			r8
			c16
			r
		}

		r8
		e
		a
		c'
		b16
		c'
		r
		c'
		ds'8
		e'16
		r

		\repeat unfold 28 {
			r8
			ds16
			r
		}

		r8
		g
		c'
		ds'
		d'16
		ds'
		r
		ds'
		fs'8
		g'16
		r
		fs8
		as
		fs'
		ds'
		f'
		cs'
		fs
		a
		d'
		f
		as
		a4
		as8
		c'
		cs'
		as
		fs
		cs'
		as
		fs
		as
		ds
		fs
		f
		a
		d
		f4
		f8
		as
		d'
		a16
		fs
		a
		cs'
		fs'8
		d'
		e'
		a4.
		gs16
		a
		cs'
		e
		gs8
		a4
		e8
		b
		g
		r

		\repeat unfold 2 {
			b16
			r8.
			g16
			r8.
			e8
			f
			g4
		}

		b16
		r8.
		a16
		r8.
		g16
		r8.
		f16
		r

		\repeat unfold 4 {
			gs16
			a
		}

		gs8
		b,
		a,
		r
	}
}

\new Staff \absolute {

	\new Voice = "bass" {
		\clef "bass"
		\set Staff.midiInstrument = #"pizzicato strings"
		\numericTimeSignature
		\repeat volta \repamt {

			\repeat unfold 15 {
				a,,8
				e16
				r
				e,8
				e16
				r
			}

			a,,8
			e16
			r
			b,,8
			fs16
			r

			\repeat unfold 15 {
				c,8
				g16
				r
				g,,8
				g16
				r
			}

			c,8
			g16
			r
			d,8
			a16
			r
			ds,4.
			fs,4
			ds8
			as,4
			as,,4.
			d,4
			f,8
			as,4
			ds,4.
			fs,
			as,4
			as,,8
			as,4
			d,
			f,8
			as,
			c,
			d,
			fs,4
			a,
			d
			cs
			a,8
			e,
			cs,4
			a,,
			b,,8
			c,
			g16
			r
			c,8
			e16
			r
			c,8
			c16
			r
			c,8
			c16
			r
			f,,8
			g16
			r
			f,,8
			e16
			r

			\repeat unfold 2 {
				f,,8
				c16
				r
			}

			c,8
			g16
			r
			c,8
			f16
			r
			c,8
			e16
			r
			c,8
			d16
			r

			\repeat unfold 2 {
				e,8
				e16
				r
			}

			e,16
			e
			d,
			d
			c,
			c
			b,,
			b,
		}
	}

	\addlyrics {
		\repeat unfold 32 {
			Cheese \skip 1
			Cheese \skip 1
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
		\context {
			\Lyrics
			fontSize = #-1
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

