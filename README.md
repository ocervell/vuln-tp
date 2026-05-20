# TP Détection de Vulnérabilités - Bachelor 3

## Prérequis Système

- **RAM minimum**: 4GB
- **Espace disque**: 10GB libre
- **Docker**: >= 20.10
- **Docker Compose**: >= 2.0
- **Ports libres**: 22, 80, 2121, 2222, 8080, 8081

## Installation Rapide

```bash
git clone <repo>
cd tp-detection-vuln
docker-compose up -d
```

## Vérification Installation

```bash
docker ps
nmap -p- localhost
```

## Support

- Documentation: TP.md
- Issues: Voir enseignant