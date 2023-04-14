#!/usr/bin/env python3
#
# see also
#   https://pypi.org/project/nvidia-ml-py/
#   https://developer.nvidia.com/nvidia-management-library-nvml
#   https://developer.nvidia.com/ganglia-monitoring-system
#   https://metacpan.org/dist/nvidia-ml-pl/view/lib/nvidia/ml.pm
#

from pynvml import (
    nvmlInit, nvmlDeviceGetCount, nvmlDeviceGetHandleByIndex,
    nvmlDeviceGetTotalEnergyConsumption, nvmlShutdown
)

nvmlInit()

deviceCount = nvmlDeviceGetCount()
for i in range(deviceCount):
    handle = nvmlDeviceGetHandleByIndex(i)
    energy = nvmlDeviceGetTotalEnergyConsumption(handle)
    print(f"GPU {i}: {energy} mJ")

nvmlShutdown()
