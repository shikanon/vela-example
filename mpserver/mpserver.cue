package server

import "strings"

output: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name: context.name
		labels: {
			"app.oam.dev/component": context.name
			"app":                   context.name
		}
	}
	spec: {
		selector: matchLabels: {
			"app.oam.dev/component": context.name
			"app":                   context.name
		}

		template: {
			metadata: labels: {
				"app.oam.dev/component": context.name
				"app":                   context.name
			}

			spec: {
				containers: [{
					name:  context.name
					image: parameter.image

					if parameter["cmd"] != _|_ {
						command: parameter.cmd
					}

					if parameter["env"] != _|_ {
						env: parameter.env
					}

					if parameter["configmap"] != _|_ {
						volumeMounts: [
							for _,c in parameter["configmap"] {
								mountPath: c.mountPath
								name: c.name
							}
						]
					}

					ports: [
						for k, v in parameter.ports {
							containerPort: v
							protocol:      "TCP"
						},
					]

					if parameter["cpu"] != _|_ || parameter["memory"] != _|_ {
						resources: {
							limits: {
								if parameter["cpu"] != _|_ {
									cpu: parameter.cpu
								}
								if parameter["memory"] != _|_ {
									memory: parameter.memory
								}
							}
							requests: {
								if parameter["cpu"] != _|_ {
									cpu: parameter.cpu
								}
								if parameter["memory"] != _|_ {
									memory: parameter.memory
								}
							}
						}
					}

				}]
				if strings.Contains(parameter.image, "swr.cn-north-4.myhuaweicloud.com") {
					imagePullSecrets: [
						{name: "regcred"}
					]
				}
				if parameter["configmap"] != _|_ {
					volumes: [
						for _,c in parameter["configmap"] {
							name: c.name
							configMap: {
								name: c.name
							}
						}
					]
				}
		}
		}
	}
}

outputs: service: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name: context.name
		labels: {
			"app.oam.dev/component": context.name
			"app":                   context.name
		}
	}
	spec: {
		type: "ClusterIP"
		selector: {
			"app.oam.dev/component": context.name
			"app":                   context.name
		}
		ports: [
			for k, v in parameter.ports {
				name:       "tcp-\(k)"
				port:       v
				targetPort: v
				protocol:   "TCP"
			},
		]
	}
}

parameter: {
	// +usage=Which image would you like to use for your service
	// +short=i
	image: string

	// +usage=Commands to run in the container
	cmd?: [...string]

	// +usage=Which port do you want customer traffic sent to
	// +short=p
	ports: [...int]
	// +usage=Define arguments by using environment variables
	env?: [...{
		// +usage=Environment variable name
		name: string
		// +usage=The value of the environment variable
		value?: string
		// +usage=Specifies a source the value of this var should come from
		valueFrom?: {
			// +usage=Selects a key of a secret in the pod's namespace
			secretKeyRef: {
				// +usage=The name of the secret in the pod's namespace to select from
				name: string
				// +usage=The key of the secret to select from. Must be a valid secret key
				key: string
			}
		}
	}]
	// +usage=Number of CPU units for the service, like `0.5` (0.5 CPU core), `1` (1 CPU core)
	cpu?: string
	// +usage=Number of CPU units for the service, like `0.5` (0.5 CPU core), `1` (1 CPU core)
	memory?: string
	// +usage=Define arguments by using config name and mount path
	configmap?: [...{
		name: string
		mountPath: string
	}]
}