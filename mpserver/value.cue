package server

//cue export mpserver.cue -e outputs --out yaml
parameter: {
	image: "crccheck/hello-world"
	ports: [{
		protocol: "http"
		number: 8000
	}]
	env: [{
		name: "appname"
		value: "test"
	}]
	configmap: [{
		name: "config-test"
		mountPath: "/app/config/"
	}]
}

context: {
	name: "test-mpserver"
	namespace: "rcmd"
}
