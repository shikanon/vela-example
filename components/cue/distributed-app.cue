import "strings"

output: {
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata: {
		name: context.name
	}
	spec: {
		serviceName: context.name
		replicas:    parameter.replicas
		selector: matchLabels: {
			"app.oam.dev/component":      context.name
			"workload.oam.dev/type":      "micro-service"
			"app.kubernetes.io/instance": context.name
			"app.kubernetes.io/name":     context.name
			if parameter.addRevisionLabel {
				"app.oam.dev/appRevision": context.appRevision
			}
		}

		template: {
			metadata: labels: {
				"app.oam.dev/component":      context.name
				"workload.oam.dev/type":      "micro-service"
				"app.kubernetes.io/instance": context.name
				"app.kubernetes.io/name":     context.name
				if parameter.addRevisionLabel {
					"app.oam.dev/appRevision": context.appRevision
				}
			}

			spec: {
				containers: [{
					name:  context.name
					image: parameter.image
					ports: [
						for p in parameter.port {
							containerPort: p.number
							protocol:      "TCP"
							name:          "\(p.protocol)-\(p.number)"
						},
					]

					if parameter["cmd"] != _|_ {
						command: parameter.cmd
					}

					if parameter["env"] != _|_ {
						env: parameter.env
					}

					if context["config"] != _|_ {
						env: context.config
					}

					if parameter["cpu"] != _|_ {
						resources: {
							limits:
								cpu: parameter.cpu
							requests:
								cpu: parameter.cpu
						}
					}

					if parameter["memory"] != _|_ {
						resources: {
							limits:
								memory: parameter.memory
							requests:
								memory: parameter.memory
						}
					}

					if parameter["volumes"] != _|_ {
						volumeMounts: [ for v in parameter.volumes {
							{
								mountPath: v.mountPath
								name:      v.name
							}}]
					}

				}]

			if parameter["volumes"] != _|_ {
				volumes: [ for v in parameter.volumes {
					{
						name: v.name
						if v.type == "pvc" {
							persistentVolumeClaim: {
								claimName: v.claimName
							}
						}
						if v.type == "configMap" {
							configMap: {
								defaultMode: v.defaultMode
								name:        v.cmName
								if v.items != _|_ {
									items: v.items
								}
							}
						}
						if v.type == "secret" {
							secret: {
								defaultMode: v.defaultMode
								secretName:  v.secretName
								if v.items != _|_ {
									items: v.items
								}
							}
						}
						if v.type == "emptyDir" {
							emptyDir: {
								medium: v.medium
							}
						}
					}}]
			}

			if strings.Contains(parameter.image, "swr.cn-north-4.myhuaweicloud.com") {
				imagePullSecrets: [{
					name: "default-secret"
				}]
			}
		}
	}
	if parameter["volumeClaim"] != _|_ {
		volumeClaimTemplates: [{
			for v in parameter.volumeClaim {
				apiVersion: "v1"
				kind:       "PersistentVolumeClaim"
				metadata: {
					name:      v.name
					namespace: context.namespace
					annotations: {
						if v.pvc == "ssd" {
							"everest.io/disk-volume-type": "SSD"
						}
						if v.pvc == "sas" {
							"everest.io/disk-volume-type": "SAS"
						}
						if v.pvc == "obs" {
							"everest.io/obs-volume-type": "STANDARD"
							"csi.storage.k8s.io/fstype":  "obsfs"
						}
					}
					if v.pvc == "ssd" || v.pvc == "sas" {
						labels: {
							"failure-domain.beta.kubernetes.io/region": v.region
							"failure-domain.beta.kubernetes.io/zone":   "\(v.region)\(v.zone)"
						}
					}

				}
				spec: {
					if v.pvc == "ssd" || v.pvc == "sas" {
						accessModes: ["ReadWriteOnce"]
					}
					if v.pvc == "nas" || v.pvc == "obs" {
						accessModes: ["ReadWriteMany"]
					}
					if v.pvc == "ssd" || v.pvc == "sas" {
						storageClassName: "csi-disk"
					}
					if v.pvc == "nas" {
						storageClassName: "csi-nas"
					}
					if v.pvc == "obs" {
						storageClassName: "csi-obs"
					}
					resources:
						requests:
							storage: "\(v.size)Gi"
				}
			}
		}]
	}

if parameter.updatePartition != _|_ {
	updateStrategy: {
		type: "RollingUpdate"
		rollingUpdate: {
			partition: parameter.updatePartition
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
}
spec: {
	selector: {
		"app.oam.dev/component": context.name
		"workload.oam.dev/type": "micro-service"
	}
	ports: [
		for p in parameter.port {
			port:       p.number
			targetPort: p.number
			name:       "\(p.protocol)-\(p.number)"
			protocol:   "TCP"
		},
	]
}
}
parameter: {
// +usage=Which image would you like to use for your service
// +short=i
image: string

// +usage=Replicas of instances
replicas: *2 | int

// +usage=Specify the exposion ports
port: [...{
	// +usage=The port value
	number: int
	// +usage=The port protocol
	protocol: *"tcp" | string
}]

// If addRevisionLabel is true, the appRevision label will be added to the underlying pods
addRevisionLabel: *false | bool

// +usage=Commands to run in the container
cmd?: [...string]

// +usage=Define arguments by using environment variables
env?: [...{
	// +usage=Environment variable name
	name: string
	// +usage=The value of the environment variable
	value?: string
}]

// +usage=Number of CPU units for the service, like `0.5` (0.5 CPU core), `1` (1 CPU core)
cpu?: string

// +usage=Specifies the attributes of the memory resource required for the container.
memory?: string

// +usage=Declare volumes and volumeMounts
volumes?: [...{
	name:      string
	mountPath: string
	// +usage=Specify volume type, options: "pvc","configMap","secret","emptyDir"
	type: "pvc" | "configMap" | "secret" | "emptyDir"
	if type == "pvc" {
		claimName: string
	}
	if type == "configMap" {
		defaultMode: *420 | int
		cmName:      string
		items?: [...{
			key:  string
			path: string
			mode: *511 | int
		}]
	}
	if type == "secret" {
		defaultMode: *420 | int
		secretName:  string
		items?: [...{
			key:  string
			path: string
			mode: *511 | int
		}]
	}
	if type == "emptyDir" {
		medium: *"" | "Memory"
	}
}]

// +usage=Defintion Persistent Volumns
volumeClaim?: [...{
	// +usage=the name created pvc 
	name: string
	// +usage=the type of pvc in huawei cloud, only "nas", "obs", "ssd", "sas"
	pvc: *"obs" | "nas" | "ssd" | "sas"
	// +usage=the storage size, unit is Gi, size=10 mean size is 10Gi
	size: *5 | int
	// +usage=regine and zone when the disk created which must mount the node, like "ssd" and "sas"
	region?: string
	zone?:   string
}]

// +usage=partition of rollingUpdate, look at https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#rolling-update
updatePartition?: 0 | int
}

context: {
	name:      "test-distributed-app"
	namespace: "default"
}

parameter: {
	image: "jupyterhub-component-with-statefulset"
	cmd: ["jupyterhub", "--port=8888"]
	env: [{
		name:  "EXPORTPORT"
		value: "8888"
	}]
	port: [{
		protocol: "http"
		number:   8888
	}]

	volumes: [{
		name:      "jupyter-test-pvc"
		mountPath: "/home/data"
		type:      "pvc"
		claimName: "jupyter-test-pvc"
	}]

	volumeClaim: [{
		name:   "jupyter-test-pvc"
		pvc:    "ssd"
		size:   1
		region: "cn-north-4"
		zone:   "a"
	}]

}
