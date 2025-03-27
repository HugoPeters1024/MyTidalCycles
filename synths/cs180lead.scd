(
	SynthDef(\cs80lead, {

		arg freq=880, amp=0.5, attack=0.75, decay=0.5, sustain=0.8, release=1.0, fatt=0.75, fdecay=0.5, fsus=0.8, frel=1.0,
			cutoff=200, pan=0, dtune=0.002, vibrate=4, vibdepth=0.015, gate=1.0, ratio=1,out=0,cbus=1;
		var env,fenv,vib,ffreq,sig;
		cutoff=In.kr(cbus);
		vib=SinOsc.kr(vibrate).range(-1*vibdepth,vibdepth)+1;
		freq=Line.kr(freq,freq*ratio,5);
		freq=freq*vib;
		sig=Mix.ar(Saw.ar([freq,freq*(1+dtune)]));
		// keep this below nyquist!!
		ffreq=max(freq*12,cutoff)+100;
		sig=LPF.ar(sig,ffreq);


	    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));


	}).add;

SynthDef(\gabberkick, {
    var snd, freq, high, lfo;
    freq = \freq.kr(440) * (Env.perc(0.001, 0.08, curve: -1).ar * 48 * \bend.kr(1)).midiratio;
    snd = Saw.ar(freq);
    snd = (snd * 100).tanh + ((snd.sign - snd) * -8.dbamp);
    high = HPF.ar(snd, 300);
    lfo = SinOsc.ar(8, [0, 0.5pi]).range(0, 0.01);
    high = high.dup(2) + (DelayC.ar(high, 0.01, lfo) * -2.dbamp);
    snd = LPF.ar(snd, 100).dup(2) + high;
    snd = RLPF.ar(snd, 7000, 2);
    snd = BPeakEQ.ar(snd, \ffreq.kr(3000) * XLine.kr(1, 0.8, 0.3), 0.5, 15);
    snd = snd * Env.asr(0.001, 1, 0.05).ar(2, \gate.kr(1));
    Out.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;

  SynthDef("futureChoirPiano", {
    arg freq = 440, amp = 0.5, dur = 4.0, pan = 0, room = 0.5;
    var choir, piano, env, reverb, signal;

    // Choir-like sound using formant synthesis
    choir = Formant.ar(freq * [1, 1.5, 2], 200, 800) * 0.3;

    // Piano-like attack using a sharp pluck sound
    piano = Decay2.ar(Impulse.ar(1), 0.01, 0.1) * SinOsc.ar(freq * [0.99, 1, 1.01], 0, 0.3);

    // Envelope to shape the amplitude of the synth over time
    env = EnvGen.kr(Env.adsr(0.1, 0.2, 0.6, 0.8), doneAction: 2);

    // Combine the elements
    signal = (choir + piano) * env;

    // Add reverb for spaciousness
    reverb = FreeVerb.ar(signal, mix: 0.4, room: room, damp: 0.5);

    // Pan and output
    Out.ar(0, Pan2.ar(reverb, pan, amp));
  }).add;

  SynthDef(\dubstepStab, {
    arg out = 0, freq = 100, amp = 0.8, attack = 0.01, decay = 0.4, res = 0.7, modFreq = 2, modDepth = 50;
    var env, osc, mod, filter;
    env = EnvGen.kr(Env.perc(attack, decay), doneAction: 2);
    mod = SinOsc.kr(modFreq).range(0, modDepth);
    osc = Saw.ar(freq + mod) + Pulse.ar(freq * 0.5, 0.5);
    filter = RLPF.ar(osc, freq * 2, res) * env * amp;
    Out.ar(out, filter.dup);
}).add;

SynthDef('sonic-pi-piano', {|
	note = 52, amp = 1, amp_slide = 0, amp_slide_shape = 1, amp_slide_curve = 0,
	pan = 0, pan_slide = 0, pan_slide_shape = 1, pan_slide_curve = 0,
	attack = 0, decay = 0, sustain = 0, release = 1,
	attack_level = 1, decay_level = -1, sustain_level = 1, env_curve = 1,
	vel = 0.2, hard = 0.5, velcurve = 0.8, stereo_width = 0,
	out_bus = 0 |

	var snd, env;
	var rounded = round(note, 1);

	decay_level = Select.kr(decay_level < 0, [decay_level, sustain_level]);
	amp = amp.varlag(amp_slide, amp_slide_curve, amp_slide_shape);
	pan = pan.varlag(pan_slide, pan_slide_curve, pan_slide_shape);

	snd = MdaPiano.ar(freq: rounded.midicps, tune: note - rounded + 0.5, gate: 1,
		vel: vel.clip(0, 1).linlin(0, 1, 0, 127),
		hard: hard.clip(0, 1).linlin(0, 1, -3, 3),
		decay: decay, release: release, velhard: 0.8,
		muffle: 0.8, velmuff: 0.8, velcurve: velcurve, stereo: stereo_width,
		random: 0, stretch: 0, sustain: 0.1);
	snd = Balance2.ar(snd[0], snd[1], pan, amp) * 60;
	env = Env.new([0, attack_level, decay_level, sustain_level, 0],
		[attack, decay, sustain, release],
		env_curve);
	Out.ar(out_bus, snd * EnvGen.kr(env, doneAction: 2))}
).add;j
)
