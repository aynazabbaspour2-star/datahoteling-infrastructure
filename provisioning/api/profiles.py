PACKAGE_PROFILES = {
    "vps-basic": {
        "num_cpus": 1,
        "memory_mb": 2048,
        "disk_size_gb": 20,
    },
    "vps-standard": {
        "num_cpus": 2,
        "memory_mb": 4096,
        "disk_size_gb": 40,
    },
    "vps-pro": {
        "num_cpus": 4,
        "memory_mb": 8192,
        "disk_size_gb": 80,
    },
}


def get_profile(package):
    return PACKAGE_PROFILES.get(package)
