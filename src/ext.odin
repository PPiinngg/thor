package plugin

import clap "../clap-odin"
import ext "../clap-odin/ext"

get_extension :: proc "c" (plugin: ^clap.Plugin, id: cstring) -> rawptr {
	switch id {
	case ext.EXT_LATENCY:
		return &ext_latency
	case ext.EXT_AUDIO_PORTS:
		return &ext_audio_ports
	case ext.EXT_NOTE_PORTS:
		return &ext_note_ports
	}

	return nil
}

ext_audio_ports := ext.Plugin_Audio_Ports {
	count = proc "c" (plugin: ^clap.Plugin, is_input: bool) -> u32 {
		return is_input ? AUDIO_INPUTS : AUDIO_OUTPUTS
	},
	get = proc "c" (
		plugin: ^clap.Plugin,
		index: u32,
		is_input: bool,
		info: ^ext.Audio_Port_Info,
	) -> bool {
		if (index > 0) {return false}

		info.id = 0
		portname := "Main"
		for chr, i in transmute([]u8)portname {
			info.name[i] = chr
		}

		info.channel_count = 2
		info.flags = u32(ext.Audio_Port_Flag.IS_MAIN)
		info.port_type = ext.AUDIO_PORT_STEREO
		info.in_place_pair = clap.INVALID_ID
		return true
	},
}

ext_note_ports := ext.Plugin_Note_Ports {
	count = proc "c" (plugin: ^clap.Plugin, is_input: bool) -> u32 {
		return is_input ? NOTE_INPUTS : NOTE_OUTPUTS
	},
	get = proc "c" (
		plugin: ^clap.Plugin,
		index: u32,
		is_input: bool,
		info: ^ext.Note_Port_Info,
	) -> bool {
		if (index > 0) {return false}

		info.id = 0
		portname := "Main"
		for chr, i in transmute([]u8)portname {
			info.name[i] = chr
		}

		info.preferred_dialects = ext.Note_Dialect.CLAP_NOTE_DIALECT_CLAP
		info.supported_dialects = ext.Note_Dialect.CLAP_NOTE_DIALECT_CLAP
		info.supported_dialects |= ext.Note_Dialect.CLAP_NOTE_DIALECT_MIDI
		return true
	},
}

ext_latency := ext.Plugin_Latency {
	get = proc "c" (plugin: ^clap.Plugin) -> u32 {
		state := cast(^State)plugin.plugin_data
		return state.latency
	},
}
