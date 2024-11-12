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
	in_buf := main_in.data32
	out_buf := main_out.data32

	// Error if no f32 buffer exists
	if main_out.data32 == nil {
		return clap.Process_Status.ERROR
	}

	// PROCESS LOOP
	ch_n := main_out.channel_count
	frm_n := clap_process.frames_count
	ev_n := clap_process.in_events.size(clap_process.in_events)
	// if no events exist, next_ev_idx is set to the end of the buffer
	next_ev_frm := ev_n > 0 ? 0 : frm_n
    ev_i:  u32 = 0
	frm_i: u32 = 0
	for frm_i < frm_n {
        // handle this frame's events
        for ev_i < ev_n && next_ev_frm == frm_i {
            hdr := clap_process.in_events.get(clap_process.in_events, ev_i)
            if (hdr.time > frm_i) {
                next_ev_frm = hdr.time
                break
            }

            handle_event(transmute(^State)plugin.plugin_data, hdr)
            ev_i += 1

            if ev_i == ev_n {
                next_ev_frm = frm_n
                break
            }
        }

        // tick dsp until next event
		for frm_i < next_ev_frm {
            state := transmute(^State)plugin.plugin_data
			for ch_i in 0 ..< ch_n {
				out_buf[ch_i][frm_i] = in_buf[ch_i][frm_i]
			}
            frm_i += 1
		}
	}

	return clap.Process_Status.CONTINUE
}
