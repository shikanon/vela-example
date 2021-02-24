package hpa

//cue export hpa-trait.cue -e output --out yaml
parameter: {
	min:             1
	max:             1
	cpuPercent:      80
	downscaleWindow: "60m"
    upscaleWindow: "5m"
}

context: {
	name: "tools-grpcurl"
}
