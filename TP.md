# TP Détection de Vulnérabilités
**Durée : 8 heures (4 sections de 2h) • Niveau : Bachelor 3**

---

## Vue d'Ensemble du TP

### Objectifs Pédagogiques
Ce TP progressif vous permettra de maîtriser un processus complet de détection de vulnérabilités en adoptant à la fois la perspective de l'attaquant et du défenseur. Vous apprendrez à découvrir des services réseau, identifier leurs vulnérabilités, puis déployer des systèmes de détection pour monitorer ces activités.

### Architecture du Laboratoire
Votre environnement de laboratoire Docker simule un réseau entreprise avec :
- **Réseau cible** : 192.168.100.0/24 avec services vulnérables
- **Services exposés** : SSH (ports 22/2222), FTP (ports 21/2121), Web (ports 80/8080/8081)
- **Infrastructure de monitoring** : Suricata IDS et Zeek pour l'analyse de logs
- **Isolation sécurisée** : Environnement containerisé sans impact sur votre système

### Prérequis
- Docker et docker-compose installés
- Connaissances de base en ligne de commande Linux
- Concepts fondamentaux de sécurité informatique

---

## Section 1 : Découverte Réseau Basique (2h)

### 1.1 Introduction à Nmap (15 min)

**Qu'est-ce que Nmap ?**
Nmap (Network Mapper) envoie des paquets spécialement conçus vers les hôtes cibles et analyse les réponses pour déterminer quels services fonctionnent. C'est le standard de l'industrie pour la reconnaissance réseau car il peut contourner les firewalls et fournir un fingerprinting détaillé des services. Les professionnels de sécurité l'utilisent pour la découverte d'actifs, l'évaluation de vulnérabilités et l'audit de sécurité réseau.

**Installation et vérification :**
```bash
# Vérifiez l'installation
nmap --version

# Démarrez votre environnement Docker
docker-compose up -d
```

### 1.2 Découverte Progressive d'Hôtes (45 min)

Vous recevez un réseau cible avec des informations minimales. Votre mission : découvrir systématiquement tous les services exposés.

#### Étape 1 : Découverte d'Hôtes Basique (15 min)

```bash
# Scan basique du réseau
nmap 192.168.100.0/24
```

**Questions d'Analyse :**
1. Quels hôtes ont répondu ? Pourquoi certains ne répondent-ils pas ?
2. Que peut-on déduire des temps de réponse ?
3. Quelles sont les limites de cette approche ?

**Documentez vos résultats :**
- Nombre d'hôtes découverts
- Adresses IP actives
- Ports ouverts identifiés lors du scan initial

#### Étape 2 : Scan Complet des Ports (15 min)

```bash
# Scan de tous les ports pour un hôte spécifique
nmap -p- 192.168.100.10
```

**Questions d'Analyse :**
1. Combien de services supplémentaires ont été découverts ?
2. Pourquoi les administrateurs utilisent-ils des ports non-standards ?
3. Quels sont les compromis entre scan complet vs ciblé ?

**Exercice pratique :** Répétez le scan pour chaque hôte découvert et documentez les différences.

#### Étape 3 : Furtivité et Contournement de Firewall (15 min)

```bash
# Scan furtif sans ping
nmap -Pn -sS 192.168.100.0/24
```

**Questions d'Analyse :**
1. Quelle est la différence de résultats en contournant le ping ?
2. Comment les scans SYN évitent-ils la détection comparés aux scans connect ?
3. Quand utiliseriez-vous ces techniques en test légitime ?

### 1.3 Énumération de Services et Fingerprinting (45 min)

#### Techniques de Découverte Avancées

```bash
# Détection de versions et scripts par défaut
nmap -sV -sC 192.168.100.0/24

# Scan avec récupération de bannières
nmap --script=banner 192.168.100.0/24
```

#### Exercice Pratique : Cartographie Réseau
Créez une carte topologique complète incluant :
- **Inventaire d'hôtes :** IP, statut, OS probable
- **Services découverts :** Port, protocole, version, bannière
- **Vecteurs d'attaque potentiels :** Services obsolètes, configurations faibles
- **Priorités d'investigation :** Classement par criticité

**Template de documentation :**
```
Hôte : 192.168.100.X
├── Port 22/tcp  : OpenSSH 7.2p2
├── Port 80/tcp  : Apache httpd 2.4.41
├── Port 2222/tcp: OpenSSH 7.2p2
└── Évaluation   : [CRITIQUE/MOYEN/FAIBLE]
    Justification : [Votre analyse]
```

### 1.4 Documentation et Rapport Initial (15 min)

**Livrable Section 1 :** Rapport de découverte réseau contenant :
1. **Méthodologie** : Commandes utilisées et justifications
2. **Résultats** : Tableau récapitulatif des services découverts
3. **Analyse de risque initial** : Services préoccupants identifiés
4. **Recommandations** : Actions prioritaires pour la suite

---

## Section 2 : Analyse et Recherche de Vulnérabilités (2h)

### 2.1 Introduction aux Bases de Données CVE et CVSS (15 min)

**Qu'est-ce que CVE et CVSS ?**
CVE (Common Vulnerabilities and Exposures) est un système standardisé pour identifier les vulnérabilités de sécurité, tandis que CVSS (Common Vulnerability Scoring System) fournit un score numérique (0-10) représentant la gravité. Les professionnels de sécurité utilisent ces bases pour comprendre la difficulté d'exploitation, l'impact, et la priorisation du patching. Cette phase de recherche détermine quels services découverts ont des faiblesses connues exploitables par les attaquants.

**Ressources principales :**
- Base CVE officielle : https://cve.mitre.org/
- Base NVD (National Vulnerability Database) : https://nvd.nist.gov/
- Exploit Database : https://www.exploit-db.com/

### 2.2 Recherche Manuelle de Vulnérabilités (30 min)

En utilisant les versions de services découvertes dans la Section 1, recherchez systématiquement les vulnérabilités connues.

#### Étape 1 : Recherche Base CVE (15 min)

**Exercice :** Pour chaque service majeur identifié :
1. Recherchez dans la base CVE les vulnérabilités affectant la version exacte
2. Notez l'ID CVE, la description, et le score CVSS
3. Vérifiez la disponibilité d'exploits publics

**Template de recherche :**
```
Service : OpenSSH 7.2p2
├── CVE-2016-0777 : SSH Client Information Disclosure
│   ├── Score CVSS : 5.3 (MEDIUM)
│   ├── Exploitabilité : [Facile/Moyen/Difficile]
│   └── Exploit public : [Oui/Non]
└── CVE-XXXX-XXXX : [Autre vulnérabilité]
```

**Questions d'Analyse :**
1. Quel service a la vulnérabilité avec le score CVSS le plus élevé ?
2. Quels types de vulnérabilités sont les plus courants ? (RCE, DoS, Info Disclosure)
3. Comment différencier les vulnérabilités théoriques vs pratiquement exploitables ?

#### Étape 2 : Recherche Base d'Exploits (15 min)

```bash
# Installation de searchsploit (si nécessaire)
apt-get install exploitdb

# Recherche d'exploits pour vos services
searchsploit openssh 7.2
searchsploit vsftpd 2.3.4
searchsploit apache 2.4.41
```

**Exercice :** Documentez pour chaque vulnérabilité :
- Type d'exploit (Metasploit, script standalone, technique manuelle)
- Niveau de fiabilité et conditions d'exploitation
- Impact potentiel sur votre environnement lab

### 2.3 Introduction au Scan Automatisé avec Nmap NSE (15 min)

**Qu'est-ce que Nmap NSE ?**
Nmap NSE (Nmap Scripting Engine) étend le scan basique de ports avec des scripts spécialisés de détection de vulnérabilités qui testent des failles de sécurité spécifiques. Contrairement à la recherche manuelle, le scan automatisé peut rapidement tester des centaines de vulnérabilités simultanément mais peut produire des faux positifs. Les pentesteurs professionnels l'utilisent pour évaluation initiale avant validation manuelle.

### 2.4 Scan Automatisé et Validation (45 min)

#### Étape 1 : Scripts de Vulnérabilités Sécurisés (15 min)

```bash
# Scan général de vulnérabilités
nmap --script vuln 192.168.100.0/24
```

**Observation :** Combien de vulnérabilités automatiques vs recherche manuelle ?

#### Étape 2 : Scan Ciblé par Service (15 min)

```bash
# Scripts spécifiques SSH
nmap --script ssh-* 192.168.100.10

# Scripts spécifiques FTP  
nmap --script ftp-* 192.168.100.20

# Scripts spécifiques HTTP
nmap --script http-* 192.168.100.30
```

#### Étape 3 : Validation et Analyse des Faux Positifs (15 min)

**Exercice de corrélation :**
1. Comparez résultats automatisés avec votre recherche manuelle
2. Identifiez les discordances et faux positifs potentiels
3. Validez les findings critiques avec tests supplémentaires

**Questions d'Analyse :**
1. Quelles vulnérabilités NSE a-t-il manquées par rapport à votre recherche manuelle ?
2. Quels faux positifs avez-vous identifiés et pourquoi ?
3. Comment combineriez-vous approche manuelle et automatisée de façon optimale ?

### 2.5 Scoring CVSS et Évaluation de Risque (15 min)

**Exercice Pratique :** Complétez une matrice d'évaluation des vulnérabilités :

| Service | Vulnérabilité | CVE | Score CVSS | Exploitabilité | Impact Business | Priorité |
|---------|---------------|-----|------------|----------------|----------------|----------|
| SSH 7.2p2 | Info Disclosure | CVE-2016-0777 | 5.3/10 | Facile | Moyen | P2 |
| ... | ... | ... | ... | ... | ... | ... |

**Éléments à documenter :**
- **Description détaillée** de chaque vulnérabilité
- **Service et version affectés**
- **Vecteur CVSS** et justification du score
- **Preuves d'exploitation** : captures d'écran, sorties de commandes
- **Recommandations de remédiation** prioritaires

**Livrable Section 2 :** Rapport complet de vulnérabilités avec findings priorisés, preuves techniques, et plan de remédiation structuré.

---

## Section 3 : Configuration de Détection et Monitoring (2h)

### 3.1 Introduction à Suricata IDS (15 min)

**Qu'est-ce que Suricata ?**
Suricata est un Système de Détection d'Intrusion (IDS) qui monitor le trafic réseau en temps réel, comparant les paquets contre des règles de signatures pour détecter l'activité malveillante. Contrairement aux firewalls qui bloquent le trafic, les systèmes IDS analysent passivement et alertent sur des patterns suspects comme les scans de ports, tentatives d'exploits, ou exfiltration de données. Les centres opérationnels de sécurité (SOCs) utilisent l'IDS pour détecter les attaques qui contournent les défenses périmètriques et fournir des preuves légales d'incidents de sécurité.

### 3.2 Déploiement Basique Suricata (30 min)

#### Étape 1 : Setup Container et Configuration (15 min)

```bash
# Vérifier le déploiement Suricata
docker-compose ps suricata

# Vérifier la configuration
docker exec -it monitor-suricata suricata --dump-config
```

**Questions d'Analyse :**
1. Quelles interfaces réseau Suricata monitore-t-il ?
2. Comment le mode promiscuous permet la capture de paquets ?
3. Quelle est la différence entre déploiement IDS et IPS ?

#### Étape 2 : Chargement de Règles par Défaut (15 min)

```bash
# Vérifier les règles chargées
docker exec -it monitor-suricata suricata-update list-sources

# Examiner les catégories de règles
docker exec -it monitor-suricata cat /etc/suricata/suricata.yaml | grep rule-files
```

**Test de détection basique :**
```bash
# Générer trafic test pour déclencher alertes
# Relancez vos commandes nmap de la Section 1
nmap -sS 192.168.100.10
```

**Vérification des alertes :**
```bash
# Consulter les logs d'alertes
docker exec -it monitor-suricata tail -f /var/log/suricata/fast.log
```

### 3.3 Introduction à Zeek pour l'Analyse de Logs (15 min)

**Qu'est-ce que Zeek ?**
Zeek (anciennement Bro) est un framework d'analyse réseau qui crée des logs détaillés des connexions réseau, protocoles, et données de couche application. Tandis que Suricata se concentre sur la détection basée signatures, Zeek fournit l'analyse comportementale et crée des logs structurés que les analystes peuvent interroger. Les équipes de sécurité utilisent les logs Zeek pour investigation d'incidents, threat hunting, et comprendre les patterns de comportement réseau normal vs anormal.

### 3.4 Corrélation de Logs et Analyse d'Événements (45 min)

#### Étape 1 : Collection Multi-Source de Logs (15 min)

```bash
# Démarrer la capture Zeek
docker exec -it monitor-zeek zeek -C -i eth0

# Vérifier la génération de logs
docker exec -it monitor-zeek ls -la /opt/zeek/logs/current/
```

**Analyse des formats de logs :**
```bash
# Examiner les types de logs générés
docker exec -it monitor-zeek cat /opt/zeek/logs/current/conn.log
docker exec -it monitor-zeek cat /opt/zeek/logs/current/http.log
```

#### Étape 2 : Récréation d'Attaque et Détection (20 min)

**Exercice Principal :** Reproduisez vos activités des Sections 1-2 en monitorant en temps réel :

```bash
# Terminal 1 : Surveillance alertes Suricata
docker exec -it monitor-suricata tail -f /var/log/suricata/fast.log

# Terminal 2 : Surveillance connexions Zeek  
docker exec -it monitor-zeek tail -f /opt/zeek/logs/current/conn.log

# Terminal 3 : Relancez vos scans précédents
nmap -sS 192.168.100.0/24
nmap --script vuln 192.168.100.10
```

**Questions d'Analyse :**
1. Comment les différents types de scans nmap apparaissent dans les alertes Suricata ?
2. Quels patterns de connexion Zeek log-t-il pour les scans de ports ?
3. Pouvez-vous distinguer les outils automatisés de la reconnaissance manuelle ?

#### Étape 3 : Corrélation d'Événements (10 min)

**Exercice de timeline :**
1. Croisez les alertes Suricata avec les logs de connexion Zeek
2. Identifiez la timeline et progression de votre "attaque"
3. Mappez vos techniques au framework MITRE ATT&CK

**Template d'analyse d'incident :**
```
Timestamp : [HH:MM:SS]
Source IP : [Votre IP]
Activité  : [Scan de ports / Test exploit / etc.]
├── Détection Suricata : [Règle déclenchée]
├── Logs Zeek         : [Connexions observées]
└── TTPs MITRE        : [T1046: Network Service Scanning]
```

### 3.5 Création de Règles Personnalisées (15 min)

**Exercice Pratique :** Créez des règles de détection pour patterns spécifiques découverts :

#### Règle de détection brute force SSH
```bash
# Ajouter dans les règles locales
echo 'alert tcp any any -> any 22 (msg:"Brute force SSH potentiel"; flow:to_server; threshold:type threshold, track by_src, count 5, seconds 60; sid:1000001;)' >> /etc/suricata/rules/local.rules
```

#### Règle de détection scan de ports
```bash
# Détection scan de ports rapide
echo 'alert tcp any any -> any any (msg:"Scan de ports détecté"; flags:S; threshold:type threshold, track by_src, count 10, seconds 5; sid:1000002;)' >> /etc/suricata/rules/local.rules
```

**Test de vos règles :**
```bash
# Recharger la configuration
docker exec -it monitor-suricata suricatasc -c reload-rules

# Tester avec trafic généré
nmap -sS 192.168.100.10
```

**Questions d'Analyse :**
1. Comment les paramètres de seuil équilibrent faux positifs vs couverture de détection ?
2. Quels autres services nécessitent détection brute force personnalisée ?
3. Comment détecteriez-vous le scan de vulnérabilités de la Section 2 ?

**Livrable Section 3 :** Documentation de déploiement de détection incluant :
- Configuration Suricata et règles personnalisées
- Analyse d'alertes et corrélation multi-sources
- Reconstruction de timeline d'incident avec preuves
- Recommandations d'amélioration de la détection

---

## Section 4 : Automatisation et Intégration (2h)

### 4.1 Introduction au Scripting d'Automatisation Sécurité (15 min)

**Pourquoi l'automatisation sécurité ?**
Les scripts d'automatisation sécurité éliminent les tâches manuelles répétitives et assurent une méthodologie cohérente à travers les évaluations de sécurité. Plutôt que de lancer des commandes individuelles, les scripts automatisés peuvent effectuer des workflows complets d'évaluation de vulnérabilités, générer des rapports standardisés, et programmer des scans réguliers. Les équipes sécurité entreprise utilisent l'automatisation pour monitoring sécurité continu, reporting de conformité, et réponse rapide aux incidents pour réduire le temps entre découverte de vulnérabilité et remédiation.

### 4.2 Développement Script d'Évaluation de Vulnérabilités (45 min)

#### Étape 1 : Script d'Automatisation Basique (20 min)

**Exercice :** Créez un script bash automatisant le workflow complet des Sections 1-2 :

```bash
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

# Phase 4: Génération de Rapport Consolidé
echo "=== Génération de Rapport ==="
# TODO: Ajouter logique de parsing et reporting
echo "Scan terminé. Résultats dans $LOG_DIR"
```

**Questions d'Analyse :**
1. Comment l'automatisation change-t-elle la portée et fréquence des évaluations de sécurité ?
2. Quelle gestion d'erreurs et logging supplémentaires devraient être inclus ?
3. Comment modifieriez-vous ce script pour différents environnements réseau ?

#### Étape 2 : Reporting et Alertes Améliorés (15 min)

**Améliorations au script :**

```bash
# Ajout d'un générateur de rapport HTML
generate_report() {
    REPORT_FILE="$LOG_DIR/security_report.html"
    
    cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Rapport de Sécurité - $(date)</title>
    <style>
        .critical { color: red; font-weight: bold; }
        .medium { color: orange; }
        .low { color: green; }
    </style>
</head>
<body>
    <h1>Rapport d'Évaluation de Vulnérabilités</h1>
    <h2>Résumé Exécutif</h2>
    <p>Nombre d'hôtes scannés: $(echo "$ACTIVE_HOSTS" | wc -w)</p>
    
    <h2>Vulnérabilités Détectées</h2>
    <!-- Parsing automatique des résultats -->
EOF

    # Parser les résultats et ajouter au rapport
    for host in $ACTIVE_HOSTS; do
        echo "<h3>Hôte: $host</h3>" >> "$REPORT_FILE"
        # Extraire les vulnérabilités trouvées
        grep -A 5 -B 1 "VULNERABLE" "$LOG_DIR/vulns_$host.txt" >> "$REPORT_FILE" 2>/dev/null || true
    done
    
    echo "</body></html>" >> "$REPORT_FILE"
    echo "Rapport HTML généré: $REPORT_FILE"
}
```

#### Étape 3 : Tests d'Intégration (10 min)

```bash
# Rendre le script exécutable
chmod +x auto_vuln_scan.sh

# Tester sur votre environnement lab
./auto_vuln_scan.sh

# Valider les résultats
ls -la /tmp/security_scan_*/
```

### 4.3 Introduction à l'Intégration Sécurité CI/CD (15 min)

**Qu'est-ce que DevSecOps ?**
L'intégration sécurité Intégration Continue/Déploiement Continu (CI/CD) lance automatiquement des scans de sécurité chaque fois que du code est commité ou déployé. Cette approche "shift-left" capture les vulnérabilités tôt dans le développement plutôt qu'en production, réduisant les coûts de correction et la dette sécurité. Les équipes DevSecOps intègrent le scan de vulnérabilités dans les workflows Git, builds Docker, et pipelines de déploiement pour s'assurer que les gates sécurité empêchent le code vulnérable d'atteindre les environnements de production.

### 4.4 Intégration Pipeline Sécurité CI/CD (30 min)

#### Étape 1 : Setup Git Hooks (15 min)

**Exercice :** Créez un workflow GitHub Actions pour automatisation sécurité :

```yaml
# .github/workflows/security-scan.yml
name: Scan Sécurité Automatisé
on: 
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  vulnerability-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup Docker
      uses: docker/setup-buildx-action@v2
      
    - name: Démarrer environnement lab
      run: |
        docker-compose up -d
        sleep 30  # Attendre que les services démarrent
        
    - name: Lancer Scan de Vulnérabilités
      run: |
        chmod +x ./auto_vuln_scan.sh
        ./auto_vuln_scan.sh
        
    - name: Analyser Résultats
      run: |
        # Parser les résultats pour vulnérabilités critiques
        CRITICAL_VULNS=$(find /tmp/security_scan_* -name "*.txt" -exec grep -l "CRITICAL\|HIGH" {} \; | wc -l)
        echo "Vulnérabilités critiques détectées: $CRITICAL_VULNS"
        
        # Échouer le build si vulnérabilités critiques trouvées
        if [ "$CRITICAL_VULNS" -gt 0 ]; then
          echo "❌ Build échoué: Vulnérabilités critiques détectées"
          exit 1
        else
          echo "✅ Aucune vulnérabilité critique détectée"
        fi
        
    - name: Archiver Rapports
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: security-reports
        path: /tmp/security_scan_*/*
```

**Questions d'Analyse :**
1. À quelles étapes CI/CD les scans sécurité devraient-ils s'exécuter ?
2. Comment équilibrer minutie sécurité avec vitesse de build ?
3. Quels niveaux de sévérité de vulnérabilité devraient casser les builds ?

#### Étape 2 : Scan Sécurité Container (15 min)

```bash
# Ajouter scan d'images Docker au script
scan_docker_images() {
    echo "=== Scan Sécurité Images Docker ==="
    
    # Lister les images utilisées
    IMAGES=$(docker-compose config | grep image: | awk '{print $2}' | sort -u)
    
    for image in $IMAGES; do
        echo "Scan de l'image: $image"
        
        # Scan avec Docker Scout ou Trivy (si disponible)
        if command -v trivy &> /dev/null; then
            trivy image "$image" | tee "$LOG_DIR/image_scan_$(echo $image | tr '/' '_').txt"
        else
            echo "Trivy non installé - scan d'image ignoré"
        fi
    done
}
```

### 4.5 Introduction au Framework Secator (Section Avancée Optionnelle - 15 min)

**Qu'est-ce que Secator ?**
Secator est un framework d'automatisation sécurité complet qui chaîne plusieurs outils de sécurité ensemble en workflows standardisés. Au lieu de lancer manuellement des outils individuels comme nmap, puis nikto, puis nuclei, Secator orchestre des évaluations multi-outils complexes avec une seule commande. Les pentesteurs professionnels et consultants sécurité utilisent Secator pour standardiser leurs méthodologies, assurer une couverture complète, et générer un reporting cohérent à travers différents engagements.

**Exercice Avancé** (si les ressources le permettent) :

```bash
# Installation de Secator
pip install secator

# Lancer workflow complet de reconnaissance
secator x host_recon 192.168.100.10 -p all

# Comparer avec vos findings manuels
secator x web 192.168.100.30
```

**Questions d'Analyse :**
1. Comment le workflow de Secator se compare-t-il à votre approche manuelle ?
2. Quels outils Secator a-t-il inclus que vous n'avez pas utilisés manuellement ?
3. Quand utiliseriez-vous l'automatisation framework vs scripts personnalisés ?

**Livrable Section 4 :** Package complet d'automatisation incluant :
- Scripts d'automatisation testés et documentés
- Workflow CI/CD avec gates sécurité
- Analyse comparative efficacité manuelle vs automatisée
- Recommandations pour intégration en production

---

## Évaluation et Livrables Finaux

### Rapports Techniques Requis

#### 1. Rapport de Découverte Réseau
- **Méthodologie** détaillée avec commandes utilisées
- **Inventaire complet** des services découverts
- **Analyse de risque** initial basé sur les expositions

#### 2. Évaluation de Vulnérabilités
- **Matrice de vulnérabilités** avec scoring CVSS
- **Preuves techniques** : captures d'écran et sorties de commandes
- **Plan de remédiation** priorisé

#### 3. Documentation de Détection
- **Configuration IDS/logs** avec règles personnalisées
- **Analyse d'incidents** avec corrélation d'événements
- **Procédures d'investigation** documentées

#### 4. Package d'Automatisation
- **Scripts fonctionnels** avec documentation
- **Intégration CI/CD** testée
- **Métriques d'efficacité** comparative

### Critères d'Évaluation

- **Compréhension technique** (30%) : Réponses aux questions d'analyse avec justifications
- **Application pratique** (40%) : Commandes exécutées correctement avec résultats attendus  
- **Documentation** (20%) : Rapports structurés et professionnels
- **Innovation** (10%) : Améliorations ou découvertes au-delà des exigences minimales

### Conseils pour la Réussite

1. **Documentez tout** : Chaque commande, résultat, et analyse
2. **Testez vos scripts** : Vérifiez que l'automatisation fonctionne de façon répétable
3. **Corréllez les findings** : Liens entre découverte, vulnérabilités, et détection
4. **Pensez défense** : Comment un SOC détecterait-il vos activités ?
5. **Priorisez les risques** : Focus sur impact business réel

---

**Bonne chance dans votre exploration de la détection de vulnérabilités !**

*Ce TP vous a fait découvrir un cycle complet de sécurité : attaque, analyse, et défense. Ces compétences sont essentielles pour tout professionnel de cybersécurité moderne.*