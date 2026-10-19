
#!/bin/bash
naeste_ssh_trin() {
    local svar

    read -r -p "Tryk Enter for næste trin, eller 0 for at afslutte: " svar

    if [[ "$svar" == "0" ]]; then
        return 1
    fi

    return 0
}


while true
do
    clear
    echo "=========================="
    echo "  Linux System Manager"
    echo "=========================="
    echo "1. Vis processer"
    echo "2. Afslut en proces"
    echo "3. System information"
    echo "4. Vis aktive servies"
    echo "5. Find fil med stats"
    echo "6. Vis Brugere"
	echo "7. Systemrapport"
	echo "8. SystemStatus"
	echo "9. Fejlsøgning"
	echo "10. Docker status"
	echo "11. Portanalyse"
	echo "12. Health Check"
	echo "13. SSH Information"
    echo "0. Afslut programmet"

    read -p "Vælg en funktion: " valg

	case "$valg" in
		1)
	  	  echo "Du valgte at vise processor"
		ps -eo pid,comm
		read -p "Tryk Enter for at vende tilbage til menuen"
		;;


		2)
	  	read -p "Indtast PID på processen: " pid
		if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
			echo  "Fejl: PID skal være et tal!"
			read -p "Tryk enter for at forsætte..."
			continue
		fi

		echo "Du valgte at afslutte en processen med PID: $pid" 
		read -p "Er du sikker på, at du vil afslutte processen? (j/n): " bekraeft 
		if [ "$bekraeft" = "j" ]; then
			if kill "$pid" 2>/dev/null; then
			echo "Signalet blev sendt til PID $pid"
			else
			echo "Fejl: Kunne ikke sende signalet til PID $pid"
			fi
		else
		echo "Handlingen blev annulleret"
		fi
		read -p "Tryk Enter for at vende tilbage..."
		;;

		3)
	  	  echo "System information"
		  echo "------------------------"
		  echo "CPU information "
		  echo "------------------------"
		       lscpu | grep "Model name"

		  echo "------------------------"
		  echo "Tilgengængelig ram "
		  echo "------------------------"
		  echo "RAM i alt: " $(free -h | grep "Mem:" | awk '{print $2}')

		  echo "------------------------"
		  echo "Diskplads "
		  echo "------------------------"
		       df -h / | tail -n 1

		  echo "Ledig Diskplads"
		  	df -h / | tail -n 1 | awk '{print $4}'

		read -p "Tryk Enter for at vende tilbage..."
		;;

		4)
		  echo "Aktive services"
		  echo  "------------------------"
		       systemctl list-units --type=service --state=running --no-pager --no-legend 
		  echo "Antal aktive services:  $(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | wc -l)"

		read -p "Tryk Enter for at vende tilbage..."
		;;

		5)
		  echo "Søg efer en fil"
		  echo "--------------------------"

			read -p "Indtast filnavn: " filnavn

			if [[ -z  "$filnavn" ]]; then
                        echo  "Du skal indtaste et filnavn!"
                        read -p "Tryk enter for at forsætte..."
                        continue
			fi

			resultat=$(find / -type f -name "$filnavn" 2>/dev/null)

			if [[ -n "$resultat" ]]; then
   				 find / -type f -name "$filnavn" -exec stat -c "%n | %s bytes | %w" {} \; 2>/dev/null
			else
    				echo "Der blev ikke fundet nogen filer."
			fi			

			read -p "Tryk Enter for at vende tilbage..."

		;;

		6)
		while true; do
		clear

		echo "BRUGERE OG GRUPPER"
        	echo "--------------------------"
        	echo "1. Vis alle brugere"
        	echo "2. Vis alle grupper"
        	echo "3. Tilføj bruger til gruppe"
        	echo "4. Fjern bruger fra gruppe"
        	echo "0. Tilbage"

        	read -p "Vælg en funktion: " gruppevalg		
		

		case "$gruppevalg" in
			1)
			  echo "Alle brugere"
			  cut -d: -f1 /etc/passwd
			  read -p  "Tryk Enter for at forsætte..."
			  ;;

			2)
			  echo "Alle grupper"
			  cut -d: -f1 /etc/group
			  read -p "Tryk for at forsætte..."
			  ;;

			3)
			  echo "Tilføj bruger til gruppe"
			  read -p "Indtast brugernavn: " brugernavn
			  if ! getent passwd "$brugernavn" > /dev/null; then
			 		echo "Fejl: Brugeren findes ikke!"
			  else
				read -p "Indtast gruppenavn: " gruppenavn

				if ! getent group "$gruppenavn" > /dev/null; then
            				echo "Fejl: Gruppen findes ikke!"
        			else
            				if sudo usermod -aG "$gruppenavn" "$brugernavn"; then
                				echo "Brugeren er tilføjet til gruppen!"
            				else
                				echo "Det lykkedes ikke at tilføje brugeren."
            				fi
        			fi
    			  fi
	
			  read -p "Tryk Enter for at forsætte..."
			  ;;

			4)
			  echo "Fjern bruger fra gruppe"

                          read -p "Indtast brugernavn: " brugernavn
                          if ! getent passwd "$brugernavn" > /dev/null; then
                                        echo "Fejl: Brugeren findes ikke!"
                          else
                                read -p "Indtast gruppenavn: " gruppenavn

                                if ! getent group "$gruppenavn" > /dev/null; then
                                        echo "Fejl: Gruppen findes ikke!"
                                else
                                        if sudo gpasswd -d "$brugernavn" "$gruppenavn"; then
                                                echo "Brugeren er fjernet fra gruppen!"
                                        else
                                                echo "Det lykkedes ikke at fjerne brugeren."
                                        fi
                                fi
                          fi

                          read -p "Tryk Enter for at forsætte..."
                          ;;
				
		         0)
                	break
                	;;

            		*)
                	echo "Ugyldigt valg"
                	read -p "Tryk Enter for at fortsætte..."
                	;;

		esac
		done
		;;

		7)
			echo "Genererer systemrapport..."

			echo "===== SYSTEMRAPPORT =====" > systemrapport.txt
			echo "Hostname: $(hostname)" >> systemrapport.txt
			echo "IP-adresse: $(hostname -I)" >> systemrapport.txt
			echo "CPU: $(lscpu | grep 'Model name')" >> systemrapport.txt
			echo "RAM-information:" >> systemrapport.txt
			free -h >> systemrapport.txt
			echo "Diskforbrug:" >> systemrapport.txt
			df -h / >> systemrapport.txt
			echo "Aktive services:" >> systemrapport.txt
			systemctl list-units --type=service --state=running --no-pager --no-legend >> systemrapport.txt

			echo "Systemrapport oprettet!"
			read -p "Tryk Enter for at fortsætte..."
			;;

		8)
	
    		echo "===== SYSTEMSTATUS ====="

    		echo "CPU-belastning:"
    		uptime

			echo ""
    		echo "RAM-forbrug:"
    		free -h

			echo ""
			echo "Diskforbrug:"
			df -h /


    		read -r -p "Tryk Enter for at fortsætte..."
    		;;

		9)
			echo "===== FEJLSØGNING ====="
    		echo ""

    		echo "De seneste 10 fejlmeddelelser:"
    		journalctl -p err -n 10 --no-pager

			echo ""
			echo "===== SENESTE 10 ADVARSLER ====="
			journalctl -p warning -n 10 --no-pager

			echo ""
			echo "===== KRITISKE FEJL ====="
			journalctl -p crit..crit -n 10 --no-pager

    		read -r -p "Tryk Enter for at fortsætte..."
    		;;
		
		10)
    				echo "===== DOCKER STATUS ====="

    				if systemctl is-active --quiet docker; then
        			echo "Docker kører"

        			antal=$(docker ps -q | wc -l)
        			echo "Antal kørende containere: $antal"

        				if [[ "$antal" -eq 0 ]]; then
            				echo "Ingen containere kører i øjeblikket."
        				else
            				echo "Kørende containere:"
            				docker ps --format '{{.Names}}'
        				fi
    				else
        				echo "Docker kører ikke"
    				fi

    			read -r -p "Tryk Enter for at fortsætte..."
    			;;

		11)
			while true; do
				clear

				echo "===== PORTANALYSE ====="
				echo "1. Vis alle åbne porte"
				echo "2. Undersøg bestemt port"
				echo "0. Tilbage"

				read -r -p "Vælg en funktion: " portvalg

				case "$portvalg" in
					1)
						echo "===== LYTTENDE PORTE ====="
						ss -tuln
						read -r -p "Tryk Enter for at fortsætte..."
						;;

					2)
						read -r -p "Indtast et portnummer: " port

						if [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )); then
							echo "Undersøger port $port..."
							if ss -tuln | grep -Eq ":${port}[[:space:]]"; then
								echo "Port $port lytter på computeren."
							else
								echo "Port $port blev ikke fundet blandt de lyttende porte."
							fi
						else
							echo "Ugyldigt portnummer!"
						fi

						read -r -p "Tryk Enter for at fortsætte..."
						;;

					0)
						break
						;;

					*)
						echo "Ugyldigt valg"
						read -r -p "Tryk Enter for at fortsætte..."
						;;
				esac
			done
			;;

		12)
			echo "===== HEALTH CHECK ====="

			diskforbrug=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

			echo "Diskforbrug: $diskforbrug%"

			if (( diskforbrug >= 90 )); then
				echo "Diskstatus: FEJL"
			elif (( diskforbrug >= 80 )); then
				echo "Diskstatus: ADVARSEL"
			else
				echo "Diskstatus: OK"
			fi

			echo ""
			echo "Kontrollerer Docker..."

			if ! command -v docker > /dev/null 2>&1; then
				echo "Docker: ADVARSEL - Docker er ikke installeret"
			elif systemctl is-active --quiet docker; then
				echo "Docker: OK - Docker kører"
			else
				echo "Docker: FEJL - Docker er ikke aktiv"
			fi

			echo ""
			echo "===== SSH HEALTH CHECK ====="

			# 1. Kontroller installation
			if ! dpkg-query -W -f='${Status}' openssh-server 2>/dev/null | grep -q "install ok installed"; then
				echo "SSH installation: ADVARSEL - Ikke installeret"
			else
				echo "SSH installation: OK - Installeret"
			fi

			# 2. Kontroller om SSH er aktiv
			if systemctl is-active --quiet ssh.service; then
				echo "SSH status: OK - ssh.service er aktiv"
			elif systemctl is-active --quiet ssh.socket; then
				echo "SSH status: OK - ssh.socket er aktiv"
			else
				echo "SSH status: FEJL - SSH er ikke aktiv"
			fi
			
			# 3. Kontroller om SSH-port 22 lytter
			echo ""
			echo "Kontrollerer SSH-port..."

			if ss -tlnH | awk '{print $4}' | grep -Eq '(^|:)22$'; then
				echo "SSH port: OK - Port 22 lytter"
			else
				echo "SSH port: FEJL - Port 22 lytter ikke"
			fi

			echo ""
			echo "Kontrollerer kritiske services..."

			if systemctl is-active --quiet systemd-journald; then
				echo "systemd-journald: OK"
			else
				echo "systemd-journald: FEJL - Tjenesten kører ikke"
			fi


			read -r -p "Tryk Enter for at fortsætte..."
			;;

		13)
    while true; do
        clear
        echo "===== SSH INFORMATION ====="
        echo "1. Vis SSH status"
        echo "2. Vis IP-adresse"
        echo "3. SSH hjælp"
        echo "0. Tilbage"

        read -r -p "Vælg en funktion: " sshvalg

        case "$sshvalg" in
            1)
				echo "===== SSH STATUS ====="

				if systemctl is-active --quiet ssh.service; then
					echo "SSH kører"
				elif systemctl is-active --quiet ssh.socket; then
					echo "SSH er klar til forbindelser (socket activation)"
				else
					echo "SSH kører ikke"
				fi

				read -r -p "Tryk Enter for at fortsætte..."
				;;
            2)
                echo "===== IP-ADRESSE ====="

				hostname -I

				read -r -p "Tryk Enter for at fortsætte..."
				;;
				
		3)
			echo ""
			echo "========== SSH GUIDE =========="
			echo ""
			echo "Hvordan vil du gennemføre guiden?"
			echo ""
			echo "1. Automatisk - programmet hjælper dig"
			echo "2. Manuel - du udfører selv kommandoerne"
			echo "0. Tilbage til SSH-menuen"
			echo ""

			read -r -p "Dit valg: " guidemode

			if [[ "$guidemode" != "1" && "$guidemode" != "2" ]]; then
				echo "Guiden afsluttes."
			else
				while true; do

				# TRIN 1 - SSH installation
				echo ""
				echo "===== TRIN 1 AF 8 - SSH INSTALLATION ====="
				echo "SSH bruges til sikker fjernadministration."
				echo ""

				if [[ "$guidemode" == "1" ]]; then
					if dpkg-query -W -f='${Status}' openssh-server 2>/dev/null | grep -q "install ok installed"; then
						echo "OK - OpenSSH-server er installeret."
					else
						echo "OpenSSH-server er ikke installeret."
						read -r -p "Vil du installere den? (j/n): " svar

						if [[ "$svar" == "j" ]]; then
							sudo apt install openssh-server
						fi
					fi
				else
					echo "Kontrollér installationen med:"
					echo "dpkg -l openssh-server"
					echo ""
					echo "Hvis SSH mangler, kan du installere med:"
					echo "sudo apt install openssh-server"
				fi

				if ! naeste_ssh_trin; then
    			break
				fi
				

				# TRIN 2 - SSH status
				echo ""
				echo "===== TRIN 2 AF 8 - SSH STATUS ====="
				echo "Vi undersøger, om SSH-serveren er klar."
				echo ""

				if [[ "$guidemode" == "1" ]]; then
					if systemctl is-active --quiet ssh.service; then
						echo "OK - SSH-serveren kører."
					elif systemctl is-active --quiet ssh.socket; then
						echo "OK - SSH er klar via socket activation."
					else
						echo "ADVARSEL - SSH-serveren er ikke aktiv."
					fi
				else
					echo "Kontrollér med:"
					echo "systemctl status ssh.service"
					echo "systemctl status ssh.socket"
					echo ""
					echo "På Ubuntu kan SSH være aktiv via ssh.socket."
				fi

				if ! naeste_ssh_trin; then
    			break
				fi

				# TRIN 3 - IP adresse
				echo ""
				echo "===== TRIN 3 AF 8 - IP ADRESSE ====="
				echo "En IP-adresse bruges til at finde serveren."
				echo ""

				if [[ "$guidemode" == "1" ]]; then
					echo "Computerens IP-adresser:"
					hostname -I
				else
					echo "Find IP-adressen med:"
					echo "hostname -I"
					echo ""
					echo "Vælg serverens IP på det netværk,"
					echo "som klienten kan nå."
				fi

				if ! naeste_ssh_trin; then
    			break
				fi

				# TRIN 4 - SSH nøgler
				echo ""
				echo "===== TRIN 4 AF 8 - SSH NØGLER ====="
				echo "SSH-nøgler kan bruges i stedet for adgangskoder."
				echo ""
				echo "Privat nøgle: Skal holdes hemmelig."
				echo "Offentlig nøgle: Kan kopieres til serveren."
				echo ""

				if [[ "$guidemode" == "1" ]]; then
					if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
						echo "OK - En Ed25519 privat nøgle findes."
						if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
							echo "OK - Den offentlige nøgle findes."
						else
							echo "ADVARSEL - Offentlig nøgle mangler."
							echo "Undersøg nøgleparret, før du fortsætter."
						fi
					else
						echo "Ingen Ed25519 nøgle fundet."
						read -r -p "Vil du oprette et nøglepar? (j/n): " svar

						if [[ "$svar" == "j" ]]; then
							mkdir -p "$HOME/.ssh"
							chmod 700 "$HOME/.ssh"
							ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519"
						fi
					fi
				else
					echo "Kontrollér eksisterende nøgler:"
					echo "ls -la ~/.ssh"
					echo ""
					echo "Opret et nøglepar med:"
					echo "ssh-keygen -t ed25519"
					echo ""
					echo "Overskriv aldrig en eksisterende nøgle"
					echo "uden først at undersøge konsekvenserne."
				fi

				if ! naeste_ssh_trin; then
    			break
				fi

				# TRIN 5 - Offentlig nøgle
				echo ""
				echo "===== TRIN 5 AF 8 - OFFENTLIG NØGLE ====="
				echo "Serveren skal kende din offentlige nøgle."
				echo ""
				echo "Den gemmes typisk i ~/.ssh/authorized_keys"
				echo "på serveren."
				echo ""

				if [[ "$guidemode" == "1" ]]; then
					read -r -p "Serverens brugernavn: " sshbruger
					read -r -p "Serverens IP eller hostname: " sshhost

					if [[ -n "$sshbruger" && -n "$sshhost" && -f "$HOME/.ssh/id_ed25519.pub" ]]; then
						echo ""
						echo "Mål: $sshbruger@$sshhost"
						echo "Den offentlige nøgle vil blive installeret."
						echo "Du kan blive bedt om serverens adgangskode."
						echo ""
						read -r -p "Vil du fortsætte? (j/n): " svar

						if [[ "$svar" == "j" ]]; then
							ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" -- "$sshbruger@$sshhost"
						fi
					else
						echo "Manglende oplysninger eller offentlig nøgle."
						echo "Trinnet springes over."
					fi
				else
					echo "Kopiér den offentlige nøgle til serveren:"
					echo "ssh-copy-id -i ~/.ssh/id_ed25519.pub bruger@server-ip"
					echo ""
					echo "Erstat bruger og server-ip med de rigtige værdier."
					echo "Kopiér aldrig din private nøgle til serveren."
				fi

				if ! naeste_ssh_trin; then
    			break
				fi

				# TRIN 6 - SSH forbindelse
				echo ""
				echo "===== TRIN 6 AF 8 - SSH FORBINDELSE ====="
				echo "Nu kan vi teste en SSH-forbindelse."
				echo ""

				if [[ "$guidemode" == "1" ]]; then
					if [[ -n "$sshbruger" && -n "$sshhost" ]]; then
						echo "Vi tester forbindelsen til:"
						echo "$sshbruger@$sshhost"
						echo ""
						read -r -p "Vil du teste forbindelsen? (j/n): " svar

						if [[ "$svar" == "j" ]]; then
							ssh -o ConnectTimeout=10 -- "$sshbruger@$sshhost" hostname
						fi
					else
						echo "Der er ikke valgt en server endnu."
						echo "Brug kommandoen:"
						echo "ssh bruger@server-ip"
					fi
				else
					echo "Opret en SSH-forbindelse med:"
					echo "ssh bruger@server-ip"
					echo ""
					echo "Kontrollér serverens fingeraftryk"
					echo "før du accepterer en ny forbindelse."
				fi

				if ! naeste_ssh_trin; then
    			break
				fi

				# TRIN 7 - Test forbindelse
				echo ""
				echo "===== TRIN 7 AF 8 - TEST FORBINDELSE ====="
				echo "SSH kan udføre kommandoer på en fjerncomputer."
				echo ""

				if [[ "$guidemode" == "1" ]]; then
					if [[ -n "$sshbruger" && -n "$sshhost" ]]; then
						echo "Tester serverens systemoplysninger..."
						ssh -o ConnectTimeout=10 -- "$sshbruger@$sshhost" uptime
					else
						echo "Ingen server valgt. Test springes over."
					fi
				else
					echo "Test forbindelsen med:"
					echo "ssh bruger@server-ip hostname"
					echo ""
					echo "Vis serverens oppetid med:"
					echo "ssh bruger@server-ip uptime"
				fi

				if ! naeste_ssh_trin; then
    			break
				fi

				# TRIN 8 - Afslutning
				echo ""
				echo "===== TRIN 8 AF 8 - AFSLUTNING ====="
				echo ""
				echo "Du har nu gennemgået SSH-guiden."
				echo ""
				echo "En interaktiv SSH-session afsluttes med:"
				echo "exit"
				echo ""
				echo "Husk:"
				echo "- Beskyt din private SSH-nøgle."
				echo "- Brug en stærk passphrase."
				echo "- Kontrollér serverens identitet."
				echo "- Giv kun adgang til betroede brugere."
				echo ""

				read -r -p "Tryk Enter for at vende tilbage..."
				break
				done
				fi
				;;

			0)
				break
				;;

			*)
				echo "Ugyldigt valg"
				read -r -p "Tryk Enter for at fortsætte..."
				;;
		esac
		done
		;;
		0)
			echo "Programmet afsluttes"
		break  
		;;
		*)
	  		echo "Ugyldigt valg"
		;;
	esac
done
