package hpa

import "encoding/json"

output: {
	apiVersion: "autoscaling/v1"
	kind:       "HorizontalPodAutoscaler"
	metadata: {
		name: context.name
		labels: {
			app: context.name
		}
		annotations: {
            if parameter["memoryPercent"] != _|_{
                "autoscaling.alpha.kubernetes.io/metrics": "[\(json.Marshal(memory_metrics))]"
            }
            "extendedhpa.option": "[\(json.Marshal(huawei_extendhpa))]"
		}
	}
	spec: {
		minReplicas:                    parameter.min
		maxReplicas:                    parameter.max
        if parameter["cpuPercent"] != _|_{
		    targetCPUUtilizationPercentage: parameter.cpuPercent
        }
		scaleTargetRef: {
			apiVersion: "apps/v1"
			kind:       "Deployment"
			name:       context.name
		}
	}
}

memory_metrics = {
    "type":"Resource",
    "resource":{
        "name":"memory",
        "targetAverageUtilization": *parameter.memoryPercent | 80
        }
    }

huawei_extendhpa = {
    "downscaleWindow": *parameter.downscaleWindow | "30m",
    "upscaleWindow": *parameter.upscaleWindow | "1m"
    }

parameter: {
	min:             *1 | >=1 & int
	max:             *1 | >=1 & int & >= min
	cpuPercent?:      >0 & int & < 100
	memoryPercent?:   >0 & int & < 100
	downscaleWindow?: string
    upscaleWindow?: string
}

