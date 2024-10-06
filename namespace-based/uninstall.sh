helm uninstall kiosk loft/kiosk --namespace kiosk 
helm uninstall \
    capsule capsule/capsule \
    --namespace "$CAPSULE_NAMESPACE"