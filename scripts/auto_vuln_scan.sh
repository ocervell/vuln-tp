#!/bin/bash
# auto_vuln_scan.sh - Automatisation d'évaluation de vulnérabilités

set -e  # Arrêt en cas d'erreur
LOG_DIR="/tmp/security_scan_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

echo "=== Démarrage Scan Sécurité $(date) ==="
echo "Logs sauvegardés dans: $LOG_DIR"

# Phase 1: Découverte Réseau
echo "=== Phase de Découverte Réseau ==="
nmap -sn 192.168.100.0/24 | tee "$LOG_DIR/discovery.txt"

# Extraction des IPs actives
ACTIVE_HOSTS=$(grep -oP '192\.168\.100\.\d+' "$LOG_DIR/discovery.txt" | sort -u)
echo "Hôtes découverts: $ACTIVE_HOSTS"

# Phase 2: Énumération de Services
echo "=== Phase d'Énumération de Services ==="
for host in $ACTIVE_HOSTS; do
    echo "Scan de $host..."
    nmap -sV -sC "$host" | tee "$LOG_DIR/services_$host.txt"
done

# Phase 3: Scan de Vulnérabilités
echo "=== Phase de Scan de Vulnérabilités ==="
for host in $ACTIVE_HOSTS; do
    echo "Scan vulnérabilités de $host..."
    nmap --script vuln "$host" | tee "$LOG_DIR/vulns_$host.txt"
done

# Phase 4: Génération de Rapport
echo "=== Génération de Rapport ==="
REPORT_FILE="$LOG_DIR/rapport_final.txt"
{
    echo "RAPPORT D'ÉVALUATION DE VULNÉRABILITÉS"
    echo "======================================"
    echo "Date: $(date)"
    echo "Réseau cible: 192.168.100.0/24"
    echo ""
    echo "HÔTES DÉCOUVERTS:"
    echo "$ACTIVE_HOSTS"
    echo ""
    echo "SERVICES IDENTIFIÉS:"
    for host in $ACTIVE_HOSTS; do
        if [ -f "$LOG_DIR/services_$host.txt" ]; then
            echo "--- Hôte $host ---"
            grep -E "(open|filtered)" "$LOG_DIR/services_$host.txt" || echo "Aucun service détecté"
        fi
    done
    echo ""
    echo "VULNÉRABILITÉS DÉTECTÉES:"
    for host in $ACTIVE_HOSTS; do
        if [ -f "$LOG_DIR/vulns_$host.txt" ]; then
            echo "--- Hôte $host ---"
            grep -B2 -A2 -i "vuln\|exploit\|cve" "$LOG_DIR/vulns_$host.txt" || echo "Aucune vulnérabilité automatiquement détectée"
        fi
    done
} > "$REPORT_FILE"

echo "Rapport final généré: $REPORT_FILE"
echo "=== Scan terminé $(date) ==="