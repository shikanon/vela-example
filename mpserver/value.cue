package server

//cue export mpserver.cue -e outputs --out yaml
parameter: {
	image: "crccheck/hello-world"
	ports: [8000]
	configmap: [{
		name: "config-test"
		mountPath: "/app/config/"
	}]
}

context: {
	name: "test-mpserver"
}
