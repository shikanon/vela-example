package httproute

outputs: virtualservices: {
	apiVersion: "networking.istio.io/v1beta1"
	kind:       "VirtualService"
	metadata: {
		name: context.name
	}
	spec: {
		gateways: parameter.gateways
		hosts: parameter.hosts
		http: [{
			route: [{
				destination: {
					host: "\(context.name).\(parameter.servernamespace).svc.cluster.local"
					port: {
						number: parameter.serverport
					}
				}
			}]
		}]
	}
}

parameter: {
	// +usage=Which gateways would you like to binds for your virtualservice
	// +short=g
	gateways: [...string]

	// +usage=hosts to access app url
	hosts: [...string]

	servernamespace: string
	serverport: int
}
