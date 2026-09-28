from flask import Flask, render_template, request, jsonify
from datetime import datetime, timezone
import json

app = Flask(__name__)

REGIONS = ["UK South", "UK West", "West Europe", "North Europe"]
VM_SIZES = ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5"]
IMAGES = [
    "Windows 11 Enterprise multi-session + Microsoft 365 Apps",
    "Windows 11 Enterprise multi-session",
    "Windows 10 Enterprise multi-session + Microsoft 365 Apps",
]

@app.get("/")
def index():
    return render_template("index.html", regions=REGIONS, vm_sizes=VM_SIZES, images=IMAGES)

@app.get("/health")
def health():
    return {"status": "ok", "service": "avd-deployment-portal"}

@app.post("/api/validate")
def validate():
    data = request.get_json(force=True)
    required = ["request_name", "subscription_id", "resource_group", "location", "host_pool_name", "workspace_name", "session_host_prefix", "session_host_count", "vm_size", "image", "vnet_name", "subnet_name"]
    missing = [k for k in required if not str(data.get(k, "")).strip()]
    errors = []
    if missing:
        errors.append("Missing: " + ", ".join(missing))
    try:
        count = int(data.get("session_host_count", 0))
        if count < 1 or count > 100:
            errors.append("Session host count must be between 1 and 100.")
    except ValueError:
        errors.append("Session host count must be a number.")
    return jsonify({"valid": not errors, "errors": errors})

@app.post("/api/preview")
def preview():
    data = request.get_json(force=True)
    spec = {
        "request": {
            "name": data.get("request_name"),
            "requestedAt": datetime.now(timezone.utc).isoformat(),
            "environment": data.get("environment", "Non-Production"),
            "owner": data.get("owner", "")
        },
        "azure": {
            "subscriptionId": data.get("subscription_id"),
            "resourceGroup": data.get("resource_group"),
            "location": data.get("location")
        },
        "avd": {
            "hostPool": data.get("host_pool_name"),
            "hostPoolType": data.get("host_pool_type", "Pooled"),
            "loadBalancing": data.get("load_balancing", "Breadth-first"),
            "maxSessionLimit": int(data.get("max_session_limit", 10)),
            "workspace": data.get("workspace_name"),
            "applicationGroup": data.get("application_group", "Desktop Application Group")
        },
        "sessionHosts": {
            "prefix": data.get("session_host_prefix"),
            "count": int(data.get("session_host_count", 1)),
            "vmSize": data.get("vm_size"),
            "image": data.get("image"),
            "osDiskGb": int(data.get("os_disk_gb", 128)),
            "joinType": data.get("join_type", "Microsoft Entra ID")
        },
        "network": {
            "vnet": data.get("vnet_name"),
            "subnet": data.get("subnet_name"),
            "useExistingNetwork": True
        },
        "operations": {
            "scalingPlan": data.get("scaling_plan", "Business Hours"),
            "startVmOnConnect": bool(data.get("start_vm_on_connect", True)),
            "tags": {"ManagedBy": "AVD Deployment Portal", "Environment": data.get("environment", "Non-Production")}
        }
    }
    return jsonify(spec)

@app.post("/api/deploy")
def deploy():
    # Safe first milestone: portal captures and validates a deployable request.
    # Azure execution is deliberately gated until Azure service-principal / workload identity is configured.
    data = request.get_json(force=True)
    return jsonify({
        "status": "Ready for Azure connection",
        "message": "Request validated. Connect Azure credentials and Terraform state before enabling Apply.",
        "requestName": data.get("request_name", "AVD request")
    }), 202

if __name__ == "__main__":
    import os
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
