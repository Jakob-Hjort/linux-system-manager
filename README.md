# Linux System Manager

Et Bash-baseret administrationsværktøj til Linux, udviklet som en del af et Linux-kursus.

## Funktioner

- Procesadministration
- Systeminformation
- Administration af services
- Filsøgning
- Brugere og grupper
- Systemrapportering
- Systemovervågning
- Fejlsøgning med journalctl
- Docker-status
- Portanalyse
- Health Check
- SSH-status og guidet SSH-hjælp

## Krav

- Linux (primært testet på Ubuntu)
- Bash
- Almindelige Linux-systemværktøjer
- Docker og OpenSSH-server til de tilhørende funktioner

Visse administrative funktioner kræver sudo-rettigheder.

## Installation

Klon repositoryet:

    git clone https://github.com/Jakob-Hjort/linux-system-manager.git

Åbn projektmappen:

    cd linux-system-manager

Start programmet:

    bash menu.sh

## Bemærkninger

Programmet er udviklet til undervisning og test. Funktioner, der ændrer brugere, grupper, processer eller services, bør anvendes med omtanke.

## Videreudvikling

Projektet kan senere udvides med yderligere systemadministrations- og automatiseringsfunktioner.
