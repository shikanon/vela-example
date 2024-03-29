patch: {
    spec: template: spec: {
    containers: [{
        livenessProbe:
        {
            if parameter.type == "tcp" {
                tcpSocket: port: parameter.port
            }
            if parameter.type == "http" {
                httpGet: {
                    path: parameter.httpPath
                    port: parameter.port
                }
            }
            if parameter.type == "grpc" {
                exec: {
                    command: ["grpc_health_probe","-addr=127.0.0.1:\(parameter.port)","-rpc-timeout=2s"]
                }
            }

            if parameter.type == "custom" {
                exec:{
                    command: parameter.healthCommand
                }
            }

            initialDelaySeconds: parameter.initCheckTime + parameter.initFailedTime
            periodSeconds: parameter.interval
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 2
        }
        
        readinessProbe: {
            if parameter.type == "tcp" {
                tcpSocket: port: parameter.port
            }
            if parameter.type == "http" {
                httpGet: {
                path: parameter.httpPath
                port: parameter.port
                }
            }
            if parameter.type == "grpc" {
                exec: {
                command: ["grpc_health_probe","-addr=127.0.0.1:\(parameter.port)","-rpc-timeout=2s"]
                }
            }
            if parameter.type == "custom" {
                exec: {
                command: parameter.healthCommand
                }
            }
            initialDelaySeconds: parameter.initCheckTime
            periodSeconds: parameter.initFailedTime div 3
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 2
        }
    }]
    }
}

parameter: {
    //+usage=the type of health checker type, "tcp","http","grpc","custom"
    type: *"tcp" | "http" | "grpc" | "custom"
    // +usage=the first checker time, if it finish the application will ready,the uint is seconds.
    initCheckTime: *10 | int
    // +usage=how long failed when the application not ready. it is will if it is multiples of three.
    initFailedTime: *15| int
    // +usage=how long check the application liveness. If is failed 3 times will be restart.
    interval: *5 | int
    // +usage=which port of application to checkout for health
    port: int
    if type == "http"{
        // +usage=which the path of health check interface
        httpPath: string
    }
    if type == "custom" {
        // +usage=which the command to check health with user custom.
        healthCommand: [...string]
    }
}