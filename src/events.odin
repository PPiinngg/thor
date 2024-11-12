package plugin

import clap "../clap-odin"
import "core:fmt"

Ev_T :: clap.Event_Type

handle_event :: proc(state: ^State, hdr: ^clap.Event_Header) {
	#partial switch hdr.event_type {
	case Ev_T.NOTE_ON: fallthrough
	case Ev_T.NOTE_OFF: fallthrough
	case Ev_T.NOTE_END: fallthrough
	case Ev_T.NOTE_CHOKE:
		handle_note_event(state, transmute(^clap.Event_Note)hdr)
	case Ev_T.NOTE_EXPRESSION:
		handle_note_expr_event(state, transmute(^clap.Event_Note_Expression)hdr)
	case Ev_T.MIDI:
		handle_midi_event(state, transmute(^clap.Event_Midi)hdr)
	}
}

handle_note_event :: proc(state: ^State, ev: ^clap.Event_Note) {
	// DO STUFF HERE FOR NOTES !!!!
}

handle_note_expr_event :: proc(state: ^State, ev: ^clap.Event_Note_Expression) {
    // MPE WOWWWW !!!!
}

handle_midi_event :: proc(state: ^State, ev: ^clap.Event_Midi) {
	type := Ev_T.NOTE_OFF
	switch ((ev.data[0] & 0xF0) >> 4) {
	case 0b1000:
		type = Ev_T.NOTE_OFF
	case 0b1001:
		type = Ev_T.NOTE_ON
	case: return
	}
	note_ev := clap.Event_Note {
		header = clap.Event_Header {
			size = 40,
			time = ev.header.time,
			space_id = ev.header.space_id,
			event_type = type,
			flags = ev.header.flags,
		},
		note_id = i32(ev.data[1]),
		port_index = i16(ev.port_index),
		channel = i16(ev.data[0] & 0x0F),
		key = i16(ev.data[1]),
		velocity = f64(ev.data[1]) /
		127,
	}
	handle_note_event(state, &note_ev)
}
