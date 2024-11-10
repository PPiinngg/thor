package plugin

import "base:runtime"
import "core:fmt"
import clap "../clap-odin"

start_processing :: proc "c" (plugin: ^clap.Plugin) -> bool {
    return true
}

stop_processing :: proc "c" (plugin: ^clap.Plugin) {}

reset :: proc "c" (plugin: ^clap.Plugin) {}

process :: proc "c" (plugin: ^clap.Plugin, clap_process: ^clap.Process) -> clap.Process_Status {
	context = runtime.default_context()

    main_in := clap_process.audio_inputs[0]
    main_out := clap_process.audio_outputs[0]

    // Error if no f32 buffer exists
    if main_out.data32 == nil {
        return clap.Process_Status.ERROR
    }

    // PROCESS LOOP
	ch_n := main_out.channel_count
	frm_n := clap_process.frames_count

    for ch_idx in 0..<ch_n {
		out_ch := main_out.data32[ch_idx]
		in_ch := main_in.data32[ch_idx]

		for frm_idx in 0..<frm_n {
			out_ch[frm_idx] = in_ch[frm_idx]
		}
	}

    return clap.Process_Status.CONTINUE
}
