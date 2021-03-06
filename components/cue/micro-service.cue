import "strings"

output: {
    apiVersion: "apps/v1"
    kind:       "Deployment"
    metadata: {
    name: context.name
    }
    spec: {
    selector: matchLabels: {
        "app.oam.dev/component": context.name
        "workload.oam.dev/type": "micro-service"
        "app.kubernetes.io/instance": context.name
        "app.kubernetes.io/name": context.name
        if parameter.addRevisionLabel {
        "app.oam.dev/appRevision": context.appRevision
        }
    }

    template: {
        metadata: labels: {
        "app.oam.dev/component": context.name
        "workload.oam.dev/type": "micro-service"
        "app.kubernetes.io/instance": context.name
        "app.kubernetes.io/name": context.name
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
                protocol: "TCP"
                name: "\(p.protocol)-\(p.number)"
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

}

context: {
    name: "test-application"
    namespace: "test"
}

parameter: {
    image: "jupyterhub-component-with-addvolume"
    cmd: ["jupyterhub", "--port=8888"]
    env: [{
        name: "EXPORTPORT"
        value: "8888"
    }]
    port: [{
        protocol: "http"
        number: 8888
    }]
    
    volumes: [{
        name: "jupyter-test-pvc"
        mountPath: "/home/data"
        type: "pvc"
        claimName: "jupyter-test-pvc"
    }]

}