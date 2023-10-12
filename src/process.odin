package test_plugin

import "core:runtime"
import clap "../clap-odin"

start_processing :: proc "c" (plugin: ^clap.Plugin) -> bool {
    return true
}

stop_processing :: proc "c" (plugin: ^clap.Plugin) {}

reset :: proc "c" (plugin: ^clap.Plugin) {}

process :: proc ($T: typeid, process: ^clap.Process, i_buf, o_buf: ^[^][^]T) {
	c_n := process.audio_inputs[0].channel_count
	fr_n := process.frames_count
	
	for c_i in 0..<c_n {
		o_ch := o_buf[c_i]
		i_ch := i_buf[c_i]

		for fr_i in 0..<fr_n {
			o_ch[fr_i] = i_ch[fr_i]
		}
	}
}

init_process :: proc "c" (plugin: ^clap.Plugin, clap_process: ^clap.Process) -> clap.Process_Status {
	context = runtime.default_context()

    main_in := clap_process.audio_inputs[0]
    main_out := clap_process.audio_outputs[0]

	ch_c := clap_process.audio_inputs[0].channel_count
	frm_c := clap_process.frames_count
    
    if clap_process.audio_outputs[0].data32 != nil {
		process(f32, clap_process, &main_in.data32, &main_out.data32)
    } else if clap_process.audio_outputs[0].data64 != nil {
		process(f64, clap_process, &main_in.data64, &main_out.data64)
    }

    return clap.Process_Status.CONTINUE
}
